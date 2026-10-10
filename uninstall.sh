#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2026 Antonio Salsi
#
# uninstall.sh - removes upsguard
#
# Usage (as root):   ./uninstall.sh
#
# Leaves /etc/upsguard.env, /etc/upsguard/apcupsd.conf, /etc/xbps.d/upsguard.conf
# and the apcupsd package in place.

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "uninstall.sh: must be run as root" >&2
    exit 2
fi

if [ -e /var/service/upsguard ]; then
    sv down upsguard || true
    rm -f /var/service/upsguard
fi

rm -rf /etc/sv/upsguard
rm -f /etc/upsguard/apccontrol
rm -f /usr/local/bin/upsguard-event /usr/local/bin/upsguard-test-logger

echo "removed; the UPS is no longer monitored"
