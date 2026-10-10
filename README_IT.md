# upsguard

[English](README.md) | **Italiano**

Monitoraggio di un UPS APC per Void Linux (runit): `apcupsd` per l'UPS su USB,
notifica degli eventi via mail tramite postfix e spegnimento pulito quando la
batteria si sta esaurendo. Configurato per un **APC Back-UPS BX750MI** sul server
`borgreplay`.

## Componenti

| File nel progetto         | Installato in                    | Ruolo |
|---------------------------|----------------------------------|-------|
| `bin/upsguard-event`      | `/usr/local/bin/upsguard-event`  | gestore degli eventi: mail, poi l'azione predefinita di apcupsd |
| `etc/apccontrol`          | `/etc/upsguard/apccontrol`       | chiamato da apcupsd a ogni evento, esegue `upsguard-event` |
| `etc/apcupsd.conf`        | `/etc/upsguard/apcupsd.conf`     | configurazione di apcupsd (UPS, soglie di spegnimento) |
| `sv/upsguard/run`         | `/etc/sv/upsguard/run`           | servizio runit che esegue apcupsd con quella configurazione |
| `xbps.d/upsguard.conf`    | `/etc/xbps.d/upsguard.conf`      | `ignorepkg=nullmailer`, vedi sotto |
| `.env` (da `.env.sample`) | `/etc/upsguard.env`              | impostazioni locali: destinatario delle mail |

## Perche' `ignorepkg=nullmailer`

Il pacchetto Void `apcupsd` dipende da `nullmailer`, e `nullmailer` e' in
conflitto con `postfix`: un semplice `xbps-install apcupsd` **rimuove postfix**.
postfix fornisce gia' `sendmail`, quindi la dipendenza viene ignorata tramite
`/etc/xbps.d/upsguard.conf`. Il file deve esserci **prima** di installare
apcupsd; `install.sh` se ne occupa.

## Funzionamento

apcupsd gira come servizio `upsguard` con `/etc/upsguard/apcupsd.conf`, non come
servizio `apcupsd` del pacchetto (che deve restare disattivato). Con
`SCRIPTDIR /etc/upsguard` ogni evento passa da `/etc/upsguard/apccontrol`, che
esegue `upsguard-event`:

| Evento apcupsd                | Oggetto della mail                   |
|-------------------------------|--------------------------------------|
| `onbattery`                   | `[host] UPS: ON BATTERY`             |
| `offbattery`                  | `[host] UPS: power restored`         |
| `commfailure` (> 120 s)       | `[host] UPS: communication lost`     |
| `commok` (dopo il precedente) | `[host] UPS: communication restored` |
| `doshutdown` (confermato) | `[host] UPS: SHUTDOWN` |
| `doshutdown` (falso allarme) | `[host] UPS: shutdown cancelled` |
| `changeme` (ancora attivo dopo 120 s, una volta al giorno) | `[host] UPS: REPLACE BATTERY`     |
| `battdetach` (> 60 s) / `battattach` | `[host] UPS: battery disconnected` / `reconnected` |

Ogni mail termina con lo stato dell'UPS (`apcaccess`): carica, carico, autonomia
stimata, ultimo intervento.

Una perdita del collegamento USB piu' breve di `COMM_GRACE` (120 s) non manda
mail: succede alla ripresa dalla sospensione. Allo stesso modo un distacco della
batteria piu' breve di `BATT_GRACE` (60 s) non manda mail: la serie BX segnala
una coppia spuria "Battery disconnected" / "Battery reattached" ogni minuto
circa, che resta visibile in `/var/log/apcupsd.events`. A volte lo stesso
disturbo attiva per un istante "UPS battery must be replaced": `changeme` manda
la mail solo se il flag (bit 0x80 di `STATFLAG`) e' ancora attivo dopo 120
secondi.

`doshutdown`, `doreboot` e `killpower` vengono passati a `/etc/apcupsd/apccontrol`
del pacchetto. `doshutdown` viene eseguito solo se la batteria e' davvero
critica (vedi sotto); prima lo script aspetta fino a 30 secondi che postfix
consegni la mail.

### Spegnimento a batteria

Lo spegnimento parte al primo limite raggiunto:

| Impostazione    | Valore | Significato |
|-----------------|--------|-------------|
| `BATTERYLEVEL`  | 20     | carica residua (%) |
| `MINUTES`       | 5      | autonomia stimata dall'UPS (minuti) |
| `TIMEOUT`       | 0      | tempo a batteria (secondi, 0 = disattivato) |

I default di apcupsd (5% / 3 minuti) sono troppo stretti per una batteria
piccola come quella del BX750MI.

### Falsa batteria scarica (serie BX)

A ogni passaggio a batteria (blackout, calo di tensione, l'autotest automatico
all'accensione e ogni 14 giorni) il BX750MI segnala per qualche secondo
`ONBATT LOWBATT REPLACEBATT NOBATT`, con la carica ancora al 100%. apcupsd 3.14
lo interpreta come "Battery power exhausted" e spegne il sistema in pochi
secondi; non ha un'opzione per ignorare la batteria scarica segnalata dall'UPS.

Per questo `doshutdown` viene eseguito solo dopo `CONFIRM_SEC` (30) secondi in
cui la batteria resta critica a ogni controllo (ogni 3 secondi): a batteria,
batteria presente (niente `NOBATT`) e `LOWBATT` oppure carica/autonomia pari o
sotto `BATTERYLEVEL`/`MINUTES`. Altrimenti lo spegnimento viene annullato:
`/etc/apcupsd/powerfail` e `/etc/nologin` vengono rimossi, apcupsd viene
riavviato perche' possa avviare un nuovo spegnimento e parte una mail
`[host] UPS: shutdown cancelled` (al massimo una all'ora). Se apcupsd non
risponde, lo spegnimento procede. `timeout` e `remotedown` non vengono
verificati.

La mail `SHUTDOWN` parte solo quando lo spegnimento e' confermato.

Durante lo spegnimento apcupsd lascia il flag `/etc/apcupsd/powerfail`.
`/etc/runit/shutdown.d/89-apcupsd-powerfail.sh` (del pacchetto apcupsd) spegne
allora l'uscita dell'UPS alla fine dello shutdown: quando torna la corrente
l'UPS si riaccende e il PC si avvia, purche' il BIOS sia impostato per
**accendersi al ritorno della corrente** ("Restore on AC Power Loss: Power On").

## Configurazione

```sh
cp .env.sample .env
```

| Variabile    | Significato |
|--------------|-------------|
| `MAILTO`     | destinatario delle mail |
| `COMM_GRACE` | secondi di collegamento USB perso prima della mail (facoltativa, default 120) |
| `BATT_GRACE` | secondi di batteria staccata prima della mail (facoltativa, default 60) |

Le soglie di spegnimento e le impostazioni dell'UPS sono in
`/etc/upsguard/apcupsd.conf` (`man apcupsd.conf`). Dopo una modifica:
`sudo sv restart upsguard`.

## Installazione

```sh
sudo ./install.sh
```

`install.sh` installa `/etc/xbps.d/upsguard.conf`, poi `apcupsd` (chiede
conferma: controllare che postfix **non** sia tra i pacchetti da rimuovere), gli
script, `.env` come `/etc/upsguard.env`, disattiva il servizio `apcupsd` se
attivo e attiva `upsguard`.

Dipendenze: `apcupsd`, `libusb`, `postfix` (o un altro `sendmail`). `libusb`
serve a `libusb-compat` a runtime ma non e' una dipendenza del pacchetto Void:
senza, apcupsd termina con `error while loading libusb-1.0.so.0`.

### Pacchetto Void Linux

In alternativa a `install.sh` si puo' costruire e installare un pacchetto `xbps`:

```sh
packaging/void/build.sh
sudo install -Dm644 xbps.d/upsguard.conf /etc/xbps.d/upsguard.conf   # prima!
sudo xbps-install --repository "$PWD/dist" upsguard
sudo ln -s /etc/sv/upsguard /var/service/    # attiva il servizio
```

Il pacchetto dipende da `apcupsd`, quindi il file `xbps.d` va copiato a mano
prima della prima installazione; dopo e' il pacchetto a gestirlo e a
mantenerlo negli aggiornamenti. `/etc/upsguard.env`, `/etc/upsguard/apcupsd.conf`
e `/etc/xbps.d/upsguard.conf` sono file di configurazione: gli aggiornamenti
conservano le modifiche. Compilare `MAILTO` dopo la prima installazione.

Per passare da `install.sh` al pacchetto, eseguire `sudo ./uninstall.sh` e
installare il pacchetto: altrimenti la copia in `/usr/local/bin` ha la
precedenza. Per una nuova versione, aumentare `VERSION` o `REVISION` in
`packaging/void/build.sh`.

## Uso

```sh
apcaccess status                         # stato completo dell'UPS
sudo upsguard-event --stdout             # riepilogo a schermo
sudo upsguard-event --test               # mail di prova
sudo sv status upsguard                  # stato del servizio
cat /var/log/apcupsd.events              # storico degli eventi
grep apcupsd /var/log/socklog/daemon/current   # log di apcupsd
```

Per provare un vero blackout, staccare l'UPS dalla presa per un minuto: arriva
la mail `ON BATTERY` e, dopo averlo ricollegato, `power restored`.

## Disinstallazione

```sh
sudo ./uninstall.sh
```

## Note

- Su `borgreplay`, `borgreplay-check` legge gia' `apcaccess`: lo stato dell'UPS
  compare nel suo report e uno stato diverso da `ONLINE` genera un allarme.
- Mentre la macchina e' sospesa (`borgreplay-cycle`) apcupsd non gira: in caso
  di blackout l'UPS tiene la macchina in S3 finche' la batteria non si esaurisce,
  poi la macchina perde l'alimentazione senza shutdown. In S3 i dischi sono
  fermi e i dati gia' scritti, quindi il rischio e' basso; al ritorno della
  corrente la macchina riparte da zero (se il BIOS lo consente).

## Licenza

GPL-2.0-only, vedi [LICENSE](LICENSE).
