{ pkgs ? import <nixpkgs> {}, withSystemd ? true }:

let
  squash-compression = "xz -Xdict-size 100%";
  uwsgiLogger = if withSystemd then "systemd" else "stdio";

  ttRss = (import ./tt-rss.nix { inherit pkgs; });

  php = (pkgs.php.override {
    embedSupport = true;
    cliSupport = true;
    cgiSupport = false;
    fpmSupport = false;
    phpdbgSupport = false;
    systemdSupport = false;
    apxs2Support = false;
  }).withExtensions ({ all, ... }: with all;
    [mysqli mysqlnd pdo pdo_mysql pcntl posix filter mbstring fileinfo iconv intl dom json curl gd opcache session]);

  uwsgi = pkgs.uwsgi.override {
    withPAM = false;
    withSystemd = withSystemd;
    plugins = ["php"];
    php = php;
  };

  rootfs = pkgs.stdenv.mkDerivation rec {
    name = "rootfs";
    inherit uwsgi php ttRss uwsgiLogger;
    coreutils = pkgs.coreutils;
    mimeTypes = pkgs.mime-types + "/etc/mime.types";

    buildCommand = ''
        # prepare the portable service file-system layout
        mkdir -p $out/etc/systemd/system $out/proc $out/sys $out/dev $out/run $out/tmp $out/var/tmp $out/usr/bin
        touch $out/etc/resolv.conf $out/etc/machine-id
        cp ${./files/os-release} $out/etc/os-release
        ln -s ${pkgs.bash}/bin/bash $out/usr/bin/sh
        ln -s ${php}/bin/php $out/usr/bin/php
        ln -s usr/bin $out/bin

        mkdir -p $out/srv
        ln -s ${ttRss} $out/srv/tt-rss

        # create empty directories as mount points for the services
        mkdir -p $out/var/lib/tt-rss $out/etc/tt-rss $out/etc/ssl/certs
        substituteAll ${./files/tt-rss.ini.in} $out/etc/tt-rss.ini
        substituteAll ${./files/tt-rss-update.service.in} $out/etc/systemd/system/tt-rss-update.service
        substituteAll ${./files/tt-rss.service.in} $out/etc/systemd/system/tt-rss.service
        mkdir $out/etc/systemd/system/tt-rss.service.d/
        cp ${./files/tt-rss.socket} $out/etc/systemd/system/tt-rss.socket
    '';
  };

in

pkgs.stdenv.mkDerivation {
  name = "tt-rss.raw";
  nativeBuildInputs = [ pkgs.squashfsTools ];

  buildCommand = ''
      closureInfo=${pkgs.closureInfo { rootPaths = [ rootfs ]; }}

      mkdir -p nix/store
      for i in $(< $closureInfo/store-paths); do
        cp -a "$i" "''${i:1}"
      done

      # archive the nix store
      mksquashfs nix $out \
        -noappend \
        -keep-as-directory \
        -all-root -root-mode 755 \
        -b 1048576 -comp ${squash-compression} \
        -ef ${./exclude.list} -wildcards

      # and now add the rootfs layout
      mksquashfs ${rootfs} $out \
        -all-root -root-mode 755
  '';
}
