#! /bin/bash

set -euo pipefail

PORTABLE_IMAGE=${1:-tt-rss.raw}
TMPDIR=${TMPDIR:-/tmp}
DISTRO=focal
MIRROR=http://archive.ubuntu.com/ubuntu/

PACKAGES=(
    ca-certificates
    uwsgi-core
    uwsgi-plugin-php
    php-mbstring
    php-mysql
    php-pgsql
    php-xml
    php-intl
    php-gd
    php-curl
)
EXCLUDE=(e2fsprogs fdisk sysvinit-utils login bsdutils)

set +u
if [ -z "$2" ]; then
    WORKDIR=`mktemp -d -p $TMPDIR`
else
    WORKDIR=$2
    mkdir -p $WORKDIR
fi
set -u

## bootstrap a minimal ubuntu + uwsgi + php
debootstrap \
    --arch=amd64 \
    --variant=minbase \
    --components=main,universe \
    --exclude=$(IFS=',' ; echo "${EXCLUDE[*]}") \
    --include=$(IFS=',' ; echo "${PACKAGES[*]}") \
    $DISTRO \
    $WORKDIR \
    $MIRROR


## download and unpack tiny tiny rss
wget -c https://git.tt-rss.org/fox/tt-rss/archive/master.tar.gz -O /tmp/tt-rss.tgz
tar xf /tmp/tt-rss.tgz -C $WORKDIR/srv


## copy config files
cp tt-rss.ini $WORKDIR/srv
cp tt-rss.service tt-rss.socket tt-rss-update.service $WORKDIR/etc/systemd/system/
cp config.php $WORKDIR/srv/tt-rss

## some basic file paths required in a portable service image
touch $WORKDIR/etc/machine-id $WORKDIR/etc/resolv.conf
mkdir -p $WORKDIR/var/lib/tt-rss

## clean-ups - these just take up space
rm -rf $WORKDIR/usr/share/man $WORKDIR/usr/share/doc $WORKDIR/usr/share/info $WORKDIR/usr/share/locale $WORKDIR/var/cache/apt/archives/*.deb

mksquashfs $WORKDIR "$PORTABLE_IMAGE" -all-root -noappend

## probably remove workdir here
# rm -rf $WORKDIR
