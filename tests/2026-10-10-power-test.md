# Power test 2026-10-10 / Prova di blackout 2026-10-10

APC Back-UPS BX750MI on `borgreplay`, load about 4%.

## 1. First test, upsguard 1.0_3 (no shutdown check)

Events from `/var/log/apcupsd.events`:

```
2026-10-10 12:43:36 +0200  Battery disconnected.
2026-10-10 12:43:37 +0200  Battery reattached.
2026-10-10 12:43:45 +0200  Power failure.
2026-10-10 12:43:51 +0200  Running on UPS batteries.
2026-10-10 12:43:58 +0200  Mains returned. No longer on UPS batteries.
2026-10-10 12:43:58 +0200  Power is back. UPS running on mains.
2026-10-10 12:44:11 +0200  Power failure.
2026-10-10 12:44:16 +0200  Power is back. UPS running on mains.
2026-10-10 12:44:16 +0200  Power failure.
2026-10-10 12:44:16 +0200  Battery disconnected.
2026-10-10 12:44:21 +0200  Battery power exhausted.
2026-10-10 12:44:21 +0200  Initiating system shutdown!
2026-10-10 12:44:21 +0200  User logins prohibited
2026-10-10 12:44:22 +0200  Battery reattached.
2026-10-10 12:44:22 +0200  Running on UPS batteries.
2026-10-10 12:44:22 +0200  apcupsd exiting, signal 15
2026-10-10 12:44:22 +0200  apcupsd shutdown succeeded
2026-10-10 12:47:25 +0200  apcupsd 3.14.14 (31 May 2016) unknown startup succeeded
2026-10-10 12:47:26 +0200  UPS Self Test switch to battery.
2026-10-10 12:47:31 +0200  Battery power exhausted.
2026-10-10 12:47:31 +0200  Initiating system shutdown!
2026-10-10 12:47:31 +0200  User logins prohibited
2026-10-10 12:47:32 +0200  Running on UPS batteries.
2026-10-10 12:47:33 +0200  apcupsd exiting, signal 15
2026-10-10 12:47:33 +0200  apcupsd shutdown succeeded
2026-10-10 12:48:49 +0200  apcupsd 3.14.14 (31 May 2016) unknown startup succeeded
```

The UPS reported `ONBATT LOWBATT REPLACEBATT NOBATT` with the charge at 100%:
apcupsd shut the system down 5 seconds after the power failure, and again at
the self-test on the next boot. Fixed in 1.0_5 (critical battery confirmed for
30 seconds before a shutdown).

L'UPS ha segnalato `ONBATT LOWBATT REPLACEBATT NOBATT` con la carica al 100%:
apcupsd ha spento il sistema 5 secondi dopo il blackout, e di nuovo durante
l'autotest al riavvio. Corretto nella 1.0_5 (batteria critica confermata per
30 secondi prima dello spegnimento).

## 2. Second test, upsguard 1.0_5

UPS unplugged 14:34:44, plugged back 14:37:21 (2 min 37 s on battery).
UPS staccato alle 14:34:44, ricollegato alle 14:37:21 (2 min 37 s a batteria).

| Check / Verifica | Result / Esito |
|---|---|
| system stayed up / sistema rimasto acceso | yes / si' (uptime from 12:48) |
| `ON BATTERY` mail | sent 14:34:51 |
| `power restored` mail | sent 14:37:22 |
| charge / carica | 77% -> 69% |
| runtime / autonomia | 24.9 -> 22.3 min |
| spurious battery detach 14:37:45 / distacco spurio | no mail, as expected / nessuna mail, come previsto |
| false `LOWBATT` | **not reported this time** / **non segnalato questa volta** |

The UPS did not send the false `LOWBATT`, so the shutdown cancellation of 1.0_5
was not exercised by this test (only by simulation). It will be at the next
self-test (every 14 days and at power-on): expected mail `shutdown cancelled`.

L'UPS non ha mandato il falso `LOWBATT`, quindi l'annullamento dello
spegnimento della 1.0_5 non e' stato provato da questo test (solo in
simulazione). Lo sara' al prossimo autotest (ogni 14 giorni e all'accensione):
mail attesa `shutdown cancelled`.

### Log (`upsguard-test-logger`)

```
=== start 2026-10-10 14:33:29
14:33:29  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:31  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:33  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:35  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:37  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:39  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:41  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:43  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:45  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:47  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:49  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:51  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:53  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:55  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:57  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:33:59  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:34:01  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:03  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:05  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:07  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:09  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:11  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:13  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:15  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:17  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:19  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:21  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:23  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:25  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:27  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:29  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:31  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:33  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:35  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:37  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:39  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.9 Minutes  
14:34:41  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.9 Minutes  
14:34:43  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.9 Minutes  
14:34:45  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.9 Minutes  
14:34:47  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.9 Minutes  
14:34:49  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:51  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:53  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.8 Minutes  
14:34:56  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:34:58  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:35:00  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:35:02  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =77.0 Percent  TIMELEFT =24.7 Minutes  
14:35:04  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =76.0 Percent  TIMELEFT =24.7 Minutes  
14:35:06  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =76.0 Percent  TIMELEFT =24.6 Minutes  
14:35:08  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =76.0 Percent  TIMELEFT =24.6 Minutes  
14:35:10  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =76.0 Percent  TIMELEFT =24.5 Minutes  
14:35:12  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =76.0 Percent  TIMELEFT =24.5 Minutes  
14:35:14  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =76.0 Percent  TIMELEFT =24.5 Minutes  
14:35:16  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =76.0 Percent  TIMELEFT =24.4 Minutes  
14:35:18  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =76.0 Percent  TIMELEFT =24.4 Minutes  
14:35:20  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =76.0 Percent  TIMELEFT =24.3 Minutes  
14:35:22  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =76.0 Percent  TIMELEFT =24.3 Minutes  
14:35:24  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =75.0 Percent  TIMELEFT =24.3 Minutes  
14:35:26  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =75.0 Percent  TIMELEFT =24.2 Minutes  
14:35:28  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =75.0 Percent  TIMELEFT =24.2 Minutes  
14:35:30  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =75.0 Percent  TIMELEFT =24.1 Minutes  
14:35:32  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =75.0 Percent  TIMELEFT =24.1 Minutes  
14:35:34  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =75.0 Percent  TIMELEFT =24.1 Minutes  
14:35:36  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =75.0 Percent  TIMELEFT =24.1 Minutes  
14:35:38  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =75.0 Percent  TIMELEFT =24.1 Minutes  
14:35:40  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =75.0 Percent  TIMELEFT =24.0 Minutes  
14:35:43  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =74.0 Percent  TIMELEFT =24.0 Minutes  
14:35:45  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =74.0 Percent  TIMELEFT =23.9 Minutes  
14:35:47  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =74.0 Percent  TIMELEFT =23.9 Minutes  
14:35:49  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =74.0 Percent  TIMELEFT =23.8 Minutes  
14:35:51  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =74.0 Percent  TIMELEFT =23.8 Minutes  
14:35:53  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =74.0 Percent  TIMELEFT =23.8 Minutes  
14:35:55  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =74.0 Percent  TIMELEFT =23.8 Minutes  
14:35:58  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =74.0 Percent  TIMELEFT =23.8 Minutes  
14:36:00  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =74.0 Percent  TIMELEFT =23.6 Minutes  
14:36:02  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =73.0 Percent  TIMELEFT =23.6 Minutes  
14:36:04  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =73.0 Percent  TIMELEFT =23.6 Minutes  
14:36:06  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =73.0 Percent  TIMELEFT =23.6 Minutes  
14:36:08  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =73.0 Percent  TIMELEFT =23.6 Minutes  
14:36:10  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =73.0 Percent  TIMELEFT =23.5 Minutes  
14:36:12  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =73.0 Percent  TIMELEFT =23.5 Minutes  
14:36:14  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =73.0 Percent  TIMELEFT =23.5 Minutes  
14:36:16  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =73.0 Percent  TIMELEFT =23.4 Minutes  
14:36:18  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =73.0 Percent  TIMELEFT =23.4 Minutes  
14:36:20  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =73.0 Percent  TIMELEFT =23.3 Minutes  
14:36:22  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =72.0 Percent  TIMELEFT =23.3 Minutes  
14:36:24  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =72.0 Percent  TIMELEFT =23.2 Minutes  
14:36:26  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =72.0 Percent  TIMELEFT =23.2 Minutes  
14:36:28  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =72.0 Percent  TIMELEFT =23.2 Minutes  
14:36:30  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =72.0 Percent  TIMELEFT =23.2 Minutes  
14:36:32  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =72.0 Percent  TIMELEFT =23.2 Minutes  
14:36:34  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =72.0 Percent  TIMELEFT =23.1 Minutes  
14:36:36  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =72.0 Percent  TIMELEFT =23.1 Minutes  
14:36:38  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =72.0 Percent  TIMELEFT =23.1 Minutes  
14:36:40  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =71.0 Percent  TIMELEFT =23.0 Minutes  
14:36:42  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =71.0 Percent  TIMELEFT =23.0 Minutes  
14:36:44  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =71.0 Percent  TIMELEFT =23.0 Minutes  
14:36:46  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =71.0 Percent  TIMELEFT =22.9 Minutes  
14:36:48  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =71.0 Percent  TIMELEFT =22.9 Minutes  
14:36:50  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =71.0 Percent  TIMELEFT =22.8 Minutes  
14:36:52  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =71.0 Percent  TIMELEFT =22.8 Minutes  
14:36:54  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =71.0 Percent  TIMELEFT =22.8 Minutes  
14:36:56  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =71.0 Percent  TIMELEFT =22.8 Minutes  
14:36:58  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =71.0 Percent  TIMELEFT =22.8 Minutes  
14:37:00  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =70.0 Percent  TIMELEFT =22.7 Minutes  
14:37:02  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =70.0 Percent  TIMELEFT =22.7 Minutes  
14:37:05  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =70.0 Percent  TIMELEFT =22.6 Minutes  
14:37:07  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =70.0 Percent  TIMELEFT =22.6 Minutes  
14:37:09  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =70.0 Percent  TIMELEFT =22.5 Minutes  
14:37:11  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =70.0 Percent  TIMELEFT =22.5 Minutes  
14:37:13  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =70.0 Percent  TIMELEFT =22.5 Minutes  
14:37:15  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =70.0 Percent  TIMELEFT =22.4 Minutes  
14:37:17  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =70.0 Percent  TIMELEFT =22.4 Minutes  
14:37:19  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:37:21  STATUS   =ONBATT  LINEV    =0.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:23  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:25  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:27  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:29  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:31  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:33  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:35  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:37  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:39  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:41  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:43  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:46  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:48  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:50  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:52  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:54  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:56  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:37:58  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:00  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:02  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:04  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:06  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:08  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:10  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:12  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:14  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:16  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:18  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:20  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:22  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:24  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:26  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:28  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:30  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:32  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:34  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.3 Minutes  
14:38:36  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:38:38  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:38:40  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:38:42  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:38:44  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:38:46  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:38:49  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:38:51  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:38:53  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:38:55  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:38:57  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:38:59  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:01  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:03  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:05  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:07  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:09  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:11  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:13  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:15  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:17  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:19  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:21  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:23  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:25  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:27  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:29  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:31  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:33  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:35  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.4 Minutes  
14:39:37  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:39:39  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:39:41  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:39:43  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:39:45  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:39:47  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:39:49  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:39:51  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:39:53  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:39:55  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:39:57  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:39:59  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:01  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:03  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:05  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:07  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:09  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:11  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:13  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:15  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:17  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:19  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:21  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:23  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:25  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.6 Minutes  
14:40:27  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:29  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:32  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:34  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:36  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:38  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:40  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:42  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:44  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:46  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:48  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:50  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:52  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:54  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:56  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:40:58  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:41:00  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:41:02  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:41:04  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:41:06  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:41:08  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:41:10  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:41:12  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.8 Minutes  
14:41:14  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:16  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:18  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:20  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:22  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:24  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:26  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:28  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:30  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:32  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:34  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:36  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:38  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:40  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:42  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:44  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =22.9 Minutes  
14:41:46  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:41:48  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:41:51  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:41:53  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:41:55  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:41:57  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:41:59  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:01  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:03  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:05  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:07  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:09  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:11  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:13  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:15  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:17  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:19  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:21  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:23  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:25  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:27  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:29  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:31  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:33  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:35  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:37  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:39  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:41  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:43  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:45  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:47  STATUS   =ONLINE  LINEV    =245.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.0 Minutes  
14:42:49  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:42:51  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:42:53  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:42:55  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:42:57  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:42:59  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:43:02  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:43:04  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:43:06  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:43:08  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:43:10  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:43:12  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:43:14  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:43:16  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:43:18  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:43:20  STATUS   =ONLINE  LINEV    =243.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.1 Minutes  
14:43:22  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:24  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:26  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:28  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:30  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:32  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:34  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:36  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:38  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:40  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:42  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:44  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:46  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:48  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:50  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:52  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:54  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:56  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:43:58  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:00  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:02  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:04  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:06  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:08  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:10  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:12  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:14  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:16  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:18  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:20  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:22  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:24  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:26  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:28  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:30  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:32  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.2 Minutes  
14:44:34  STATUS   =ONLINE  LINEV    =239.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:44:36  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:44:38  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:44:40  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:44:42  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:44:44  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:44:46  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:44:48  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:44:50  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:44:52  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:44:54  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:44:56  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:44:58  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:45:00  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:45:02  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:45:04  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:45:06  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:45:08  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:45:10  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:45:12  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:45:14  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:45:16  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.4 Minutes  
14:45:18  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:20  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:22  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:24  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:26  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:28  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:30  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:32  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:34  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:37  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:39  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:41  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:43  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:45  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:47  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:49  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:51  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:53  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:55  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
14:45:57  STATUS   =ONLINE  LINEV    =241.0 Volts  BCHARGE  =69.0 Percent  TIMELEFT =23.6 Minutes  
```
