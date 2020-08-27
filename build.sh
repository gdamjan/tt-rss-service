#! /bin/bash

set -Eeuo pipefail

PORTABLE_IMAGE=${1:-tt-rss.raw}
TMPDIR=${TMPDIR:-/tmp}
DISTRO=focal
MIRROR=http://archive.ubuntu.com/ubuntu/

mapfile -t PACKAGES < packages.list
EXCLUDE_PACKAGES=(e2fsprogs fdisk sysvinit-utils login bsdutils)

set +u
if [ -z "$2" ]; then
    WORKDIR=`mktemp -d -p $TMPDIR`
else
    WORKDIR=$2
    mkdir -p $WORKDIR
fi
set -u

## bootstrap a minimal ubuntu + uwsgi + php
debootstrapArgs=(
    --arch=amd64
    --variant=minbase
    --components=main,universe
    --exclude=$(IFS=',' ; echo "${EXCLUDE_PACKAGES[*]}")
    --include=$(IFS=',' ; echo "${PACKAGES[*]}")
)
if [ -n "${CACHE_DIR:-}" ]; then
    mkdir -p $CACHE_DIR
    debootstrapArgs+=(--cache-dir=$CACHE_DIR)
fi

debootstrap \
    "${debootstrapArgs[@]}" \
    $DISTRO $WORKDIR $MIRROR


## download and unpack tiny tiny rss
wget -c https://git.tt-rss.org/fox/tt-rss/archive/master.tar.gz -O /tmp/tt-rss.tgz
tar xf /tmp/tt-rss.tgz -C $WORKDIR/srv


## copy config files
cp files/tt-rss.ini $WORKDIR/srv
cp files/tt-rss.service files/tt-rss.socket files/tt-rss-update.service $WORKDIR/etc/systemd/system/
cp files/config.php $WORKDIR/srv/tt-rss

## some basic file paths required in a portable service image
touch $WORKDIR/etc/machine-id $WORKDIR/etc/resolv.conf
mkdir -p $WORKDIR/var/lib/tt-rss

mksquashfs $WORKDIR "$PORTABLE_IMAGE" -all-root -root-mode 755 -noappend -ef exclude.list -wildcards

## probably remove workdir here
# rm -rf $WORKDIR
