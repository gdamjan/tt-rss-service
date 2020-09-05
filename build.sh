#! /bin/bash

set -Eeuo pipefail

PORTABLE_IMAGE=${1:-tt-rss.raw}
TMPDIR=${TMPDIR:-/tmp}

mapfile -t PACKAGES < packages.list

if [ -z "${2:-}" ]; then
    WORKDIR=`mktemp -d -p $TMPDIR`
else
    WORKDIR=$2
    mkdir -p $WORKDIR
fi

## bootstrap a minimal arch + uwsgi + php
pacstrap -c -C pacman.conf \
    $WORKDIR ${PACKAGES[*]}


## download and unpack tiny tiny rss
wget -c https://git.tt-rss.org/fox/tt-rss/archive/master.tar.gz -O /tmp/tt-rss.tgz
tar xf /tmp/tt-rss.tgz -C $WORKDIR/srv


## copy config files
mkdir -p $WORKDIR/etc/systemd/system/
cp files/tt-rss.ini $WORKDIR/srv
cp files/tt-rss.service files/tt-rss.socket files/tt-rss-update.service $WORKDIR/etc/systemd/system/
cp files/config.php $WORKDIR/srv/tt-rss

## some basic file paths required in a portable service image
touch $WORKDIR/etc/machine-id $WORKDIR/etc/resolv.conf
mkdir -p $WORKDIR/var/lib/tt-rss

chmod 755 $WORKDIR
mksquashfs $WORKDIR "$PORTABLE_IMAGE" -all-root -noappend -ef exclude.list -wildcards

## probably remove workdir here
# rm -rf $WORKDIR
