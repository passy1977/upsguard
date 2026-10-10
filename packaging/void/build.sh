#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2026 Antonio Salsi
#
# build.sh - builds the upsguard Void Linux package with xbps-create
#
# Usage (as a normal user, from anywhere):   packaging/void/build.sh
#
# Writes the package and a local repository index to dist/. Install with:
#   sudo install -Dm644 xbps.d/upsguard.conf /etc/xbps.d/upsguard.conf
#   sudo xbps-install --repository "$PWD/dist" upsguard

set -e

VERSION="1.0"
REVISION="6"
PKGVER="upsguard-${VERSION}_${REVISION}"

TOP="$(cd "$(dirname "$0")/../.." && pwd)"
DIST="$TOP/dist"
DESTDIR="$(mktemp -d)"
trap 'rm -rf "$DESTDIR"' EXIT

cd "$TOP"

install -Dm755 bin/upsguard-event     "$DESTDIR/usr/bin/upsguard-event"
install -Dm755 tools/upsguard-test-logger "$DESTDIR/usr/bin/upsguard-test-logger"
install -Dm755 etc/apccontrol         "$DESTDIR/etc/upsguard/apccontrol"
install -Dm644 etc/apcupsd.conf       "$DESTDIR/etc/upsguard/apcupsd.conf"
install -Dm755 sv/upsguard/run        "$DESTDIR/etc/sv/upsguard/run"
install -Dm644 xbps.d/upsguard.conf   "$DESTDIR/etc/xbps.d/upsguard.conf"
# Site settings: the template with every value commented out
sed 's/^\([A-Z_]*=\)/#\1/' .env.sample > "$DESTDIR/etc/upsguard.env"
chmod 644 "$DESTDIR/etc/upsguard.env"

DOC="$DESTDIR/usr/share/doc/upsguard"
install -Dm644 README.md    "$DOC/README.md"
install -Dm644 README_IT.md "$DOC/README_IT.md"

install -Dm644 LICENSE "$DESTDIR/usr/share/licenses/upsguard/LICENSE"
install -m644 packaging/void/INSTALL.msg "$DESTDIR/INSTALL.msg"

mkdir -p "$DIST"
rm -f "$DIST/$PKGVER.noarch.xbps"
cd "$DIST"
xbps-create \
    -A noarch \
    -n "$PKGVER" \
    -s "APC UPS monitoring with mail notification and clean shutdown" \
    -S "Runs apcupsd for an APC UPS on USB, mails power failures, restores,
communication losses and battery alarms, and shuts the system down cleanly
when the battery runs low, keeping postfix as the mail transport." \
    -D "apcupsd>=0 libusb>=0" \
    -F "/etc/upsguard/apcupsd.conf /etc/upsguard.env /etc/xbps.d/upsguard.conf" \
    -l "GPL-2.0-only" \
    "$DESTDIR"
xbps-rindex -a "$DIST/$PKGVER.noarch.xbps"

echo "built $DIST/$PKGVER.noarch.xbps"
