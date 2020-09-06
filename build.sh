#! /bin/bash

set -Eeuo pipefail

PORTABLE_IMAGE=${1:-tt-rss.raw}
TMPDIR=${TMPDIR:-/tmp}
VER=3.12.0
TARBALL=alpine-minirootfs-$VER-x86_64.tar.gz
ALPINE_URL=http://dl-cdn.alpinelinux.org/alpine/v${VER%.*}/releases/x86_64/$TARBALL
TT_RSS_URL=https://git.tt-rss.org/fox/tt-rss/archive/master.tar.gz

mapfile -t PACKAGES < packages.list

if [ -z "${2:-}" ]; then
    WORKDIR=`mktemp -d -p $TMPDIR`
else
    WORKDIR=$2
    mkdir -p $WORKDIR
fi

[ "$ALPINE_URL" ] && wget -c $ALPINE_URL -O $TMPDIR/alpine.tgz

# bootstrap alpine
tar xf $TMPDIR/alpine.tgz -C $WORKDIR/

# create mount points
touch $WORKDIR/etc/machine-id $WORKDIR/etc/resolv.conf

systemd-nspawn -D image-workdir/ /sbin/apk add "${PACKAGES[*]}"

## download and unpack tiny tiny rss
wget -c $TT_RSS_URL -O $TMPDIR/tt-rss.tgz
tar xf $TMPDIR/tt-rss.tgz -C $WORKDIR/srv


## copy config files
mkdir -p $WORKDIR/etc/systemd/system/
cp files/tt-rss.ini $WORKDIR/srv
cp files/tt-rss.service files/tt-rss.socket files/tt-rss-update.service $WORKDIR/etc/systemd/system/
cp files/config.php $WORKDIR/srv/tt-rss

## some basic file paths required in a portable service image
mkdir -p $WORKDIR/var/lib/tt-rss

chmod 755 $WORKDIR
mksquashfs $WORKDIR "$PORTABLE_IMAGE" -all-root -noappend -ef exclude.list -wildcards

## probably remove workdir here
# rm -rf $WORKDIR
