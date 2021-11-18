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
    [ pdo pdo_pgsql pcntl posix filter mbstring fileinfo iconv intl dom json curl gd opcache session ]);

  uwsgi = pkgs.uwsgi.override {
    withPAM = false;
    withSystemd = withSystemd;
    systemd = pkgs.systemdMinimal;
    plugins = ["php"];
    php = php;
  };

  uwsgiConfig = pkgs.substituteAll {
    name = "uwsgi.tt-rss.ini";
    src = ./files/uwsgi.tt-rss.ini.in;
    mimeTypes = pkgs.mime-types + "/etc/mime.types";
    inherit ttRss php uwsgiLogger;
  };

  rootfs = pkgs.stdenv.mkDerivation {
    name = "rootfs";
    inherit uwsgi php ttRss uwsgiConfig;
    coreutils = pkgs.coreutils;
    buildCommand = ''
        # prepare the portable service file-system layout
        mkdir -p $out/etc/systemd/system $out/proc $out/sys $out/dev $out/run $out/tmp $out/var/tmp $out/var/lib
        touch $out/etc/resolv.conf $out/etc/machine-id
        cp ${./files/os-release} $out/etc/os-release

        # global /usr/bin/php and bash symlinks for the update daemon
        mkdir -p $out/usr/bin
        ln -s ${php}/bin/php $out/usr/bin/php
        ln -s ${pkgs.bash}/bin/bash $out/usr/bin/sh
        ln -s $out/usr/bin/ $out/bin

        # create the mount-point for the cert store
        mkdir -p $out/etc/ssl/certs

        # setup systemd units
        substituteAll ${./files/tt-rss-update.service.in} $out/etc/systemd/system/tt-rss-update.service
        substituteAll ${./files/tt-rss.service.in} $out/etc/systemd/system/tt-rss.service
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
