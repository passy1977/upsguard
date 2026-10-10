upsguard installed.

1. Set MAILTO in /etc/upsguard.env. Thresholds are in /etc/upsguard/apcupsd.conf.
2. Keep the apcupsd service of the package disabled and enable upsguard:
     rm -f /var/service/apcupsd
     ln -s /etc/sv/upsguard /var/service/
3. Check:  apcaccess status   and   upsguard-event --test
