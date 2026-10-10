# upsguard

**English** | [Italiano](README_IT.md)

APC UPS monitoring for Void Linux (runit): `apcupsd` for the UPS on USB, mail
notification of the events through postfix and a clean shutdown when the
battery runs low. Configured for an **APC Back-UPS BX750MI** on the server
`borgreplay`.

## Components

| File in the project       | Installed as                     | Role |
|---------------------------|----------------------------------|------|
| `bin/upsguard-event`      | `/usr/local/bin/upsguard-event`  | event handler: mail, then the default action of apcupsd |
| `etc/apccontrol`          | `/etc/upsguard/apccontrol`       | called by apcupsd for every event, runs `upsguard-event` |
| `etc/apcupsd.conf`        | `/etc/upsguard/apcupsd.conf`     | apcupsd configuration (UPS, shutdown thresholds) |
| `sv/upsguard/run`         | `/etc/sv/upsguard/run`           | runit service running apcupsd with that configuration |
| `xbps.d/upsguard.conf`    | `/etc/xbps.d/upsguard.conf`      | `ignorepkg=nullmailer`, see below |
| `.env` (from `.env.sample`) | `/etc/upsguard.env`            | site settings: mail recipient |

## Why `ignorepkg=nullmailer`

The Void `apcupsd` package depends on `nullmailer`, and `nullmailer` conflicts
with `postfix`: a plain `xbps-install apcupsd` **removes postfix**. postfix
already provides `sendmail`, so the dependency is ignored through
`/etc/xbps.d/upsguard.conf`. The file must be in place **before** apcupsd is
installed; `install.sh` takes care of it.

## How it works

apcupsd runs as the `upsguard` service with `/etc/upsguard/apcupsd.conf`, not as
the `apcupsd` service of the package (which must stay disabled). With
`SCRIPTDIR /etc/upsguard` every event goes to `/etc/upsguard/apccontrol`, which
runs `upsguard-event`:

| apcupsd event                 | Mail subject                         |
|-------------------------------|--------------------------------------|
| `onbattery`                   | `[host] UPS: ON BATTERY`             |
| `offbattery`                  | `[host] UPS: power restored`         |
| `commfailure` (> 120 s)       | `[host] UPS: communication lost`     |
| `commok` (after the above)    | `[host] UPS: communication restored` |
| `loadlimit`, `runlimit`, `timeout`, `failing`, `emergency`, `remotedown` | `[host] UPS: SHUTDOWN` |
| `changeme` (once a day)       | `[host] UPS: REPLACE BATTERY`        |
| `battdetach` / `battattach`   | `[host] UPS: battery disconnected` / `reconnected` |

Every mail ends with the UPS status (`apcaccess`): charge, load, estimated
runtime, last transfer.

A loss of the USB link shorter than `COMM_GRACE` (120 s) sends no mail: this
happens on resume from suspend.

`doshutdown`, `doreboot` and `killpower` are handed to `/etc/apcupsd/apccontrol`
of the package. Before `doshutdown` the script waits up to 30 seconds for
postfix to deliver the mail.

### Shutdown on battery

The shutdown starts at the first limit reached:

| Setting         | Value | Meaning |
|-----------------|-------|---------|
| `BATTERYLEVEL`  | 20    | remaining charge (%) |
| `MINUTES`       | 5     | runtime estimated by the UPS (minutes) |
| `TIMEOUT`       | 0     | time on battery (seconds, 0 = disabled) |

The apcupsd defaults (5% / 3 minutes) are too tight for a small battery like
the BX750MI.

During the shutdown apcupsd leaves the `/etc/apcupsd/powerfail` flag.
`/etc/runit/shutdown.d/89-apcupsd-powerfail.sh` (from the apcupsd package) then
switches off the UPS output at the end of the shutdown: when the power returns,
the UPS powers on again and the PC boots, as long as the BIOS is set to
**power on after AC loss** ("Restore on AC Power Loss: Power On").

## Configuration

```sh
cp .env.sample .env
```

| Variable     | Meaning |
|--------------|---------|
| `MAILTO`     | mail recipient |
| `COMM_GRACE` | seconds of lost USB link before the mail (optional, default 120) |

Shutdown thresholds and UPS settings are in `/etc/upsguard/apcupsd.conf`
(`man apcupsd.conf`). After a change: `sudo sv restart upsguard`.

## Installation

```sh
sudo ./install.sh
```

`install.sh` installs `/etc/xbps.d/upsguard.conf`, then `apcupsd` (asks for
confirmation: check that postfix is **not** in the list of packages to remove),
the scripts, `.env` as `/etc/upsguard.env`, disables the `apcupsd` service if
enabled and enables `upsguard`.

Dependencies: `apcupsd`, `libusb`, `postfix` (or another `sendmail`). `libusb`
is needed by `libusb-compat` at runtime but is not a dependency of the Void
package: without it apcupsd exits with
`error while loading libusb-1.0.so.0`.

### Void Linux package

Instead of `install.sh` you can build and install an `xbps` package:

```sh
packaging/void/build.sh
sudo install -Dm644 xbps.d/upsguard.conf /etc/xbps.d/upsguard.conf   # first!
sudo xbps-install --repository "$PWD/dist" upsguard
sudo ln -s /etc/sv/upsguard /var/service/    # enable the service
```

The package depends on `apcupsd`, so the `xbps.d` file must be copied by hand
before the first install; afterwards the package owns it and keeps it for
upgrades. `/etc/upsguard.env`, `/etc/upsguard/apcupsd.conf` and
`/etc/xbps.d/upsguard.conf` are configuration files: upgrades keep your
changes. Fill in `MAILTO` after the first install.

To move from `install.sh` to the package, run `sudo ./uninstall.sh` and install
the package: otherwise the copy in `/usr/local/bin` takes precedence. To build a
new version, raise `VERSION` or `REVISION` in `packaging/void/build.sh`.

## Usage

```sh
apcaccess status                         # full UPS status
sudo upsguard-event --stdout             # summary on screen
sudo upsguard-event --test               # test mail
sudo sv status upsguard                  # service status
cat /var/log/apcupsd.events              # event history
grep apcupsd /var/log/socklog/daemon/current   # apcupsd log
```

To test a real power failure, unplug the UPS from the wall for a minute: you
get the `ON BATTERY` mail and, after plugging it back in, `power restored`.

## Uninstallation

```sh
sudo ./uninstall.sh
```

## Notes

- On `borgreplay`, `borgreplay-check` already reads `apcaccess`: the UPS status
  appears in its report and a status other than `ONLINE` raises an alarm.
- While the machine is suspended (`borgreplay-cycle`) apcupsd does not run: on
  a power failure the UPS keeps the machine in S3 until the battery is empty,
  then the machine loses power without a shutdown. In S3 the disks are idle and
  the data already written, so the risk is low; when the power returns the
  machine boots from scratch (if the BIOS allows it).

## License

GPL-2.0-only, see [LICENSE](LICENSE).
