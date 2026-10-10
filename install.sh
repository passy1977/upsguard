#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2026 Antonio Salsi
#
# install.sh - installs upsguard (Void Linux, runit)
#
# Usage (as root):   ./install.sh
#
# Installs apcupsd without nullmailer (postfix stays), the upsguard event handler
# and its runit service. Site settings are taken from .env (see .env.sample) and
# installed as /etc/upsguard.env. An existing /etc/upsguard/apcupsd.conf is not
# overwritten.

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "install.sh: must be run as root" >&2
    exit 2
fi

cd "$(dirname "$0")"

if [ ! -r .env ]; then
    echo "install.sh: .env missing, copy .env.sample to .env and fill it in" >&2
    exit 2
fi

# Before apcupsd: otherwise xbps replaces postfix with nullmailer
install -d -m 755 /etc/xbps.d
install -m 644 xbps.d/upsguard.conf /etc/xbps.d/upsguard.conf

# libusb: needed by libusb-compat at runtime, but not declared by the package
if ! xbps-query apcupsd >/dev/null 2>&1 || ! xbps-query libusb >/dev/null 2>&1; then
    xbps-install -S apcupsd libusb
fi

install -m 644 .env /etc/upsguard.env

install -m 755 bin/upsguard-event /usr/local/bin/upsguard-event

install -d -m 755 /etc/upsguard
install -m 755 etc/apccontrol /etc/upsguard/apccontrol
if [ ! -e /etc/upsguard/apcupsd.conf ]; then
    install -m 644 etc/apcupsd.conf /etc/upsguard/apcupsd.conf
else
    echo "leaving /etc/upsguard/apcupsd.conf unchanged"
fi

install -d -m 755 /etc/sv/upsguard
install -m 755 sv/upsguard/run /etc/sv/upsguard/run

# The apcupsd service of the package would drive the same UPS
if [ -e /var/service/apcupsd ]; then
    sv down apcupsd || true
    rm -f /var/service/apcupsd
    echo "apcupsd service disabled (replaced by upsguard)"
fi

if [ ! -e /var/service/upsguard ]; then
    ln -s /etc/sv/upsguard /var/service/
    echo "upsguard service enabled"
else
    sv restart upsguard
    echo "upsguard service restarted"
fi
