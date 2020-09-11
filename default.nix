{ pkgs ? import <nixpkgs> {} }:

let
  squash-compression = "xz -Xdict-size 100%";
  withSystemd = true;
  uwsgiLogger = if withSystemd then "systemd" else "stdio";

  ttRss = (import ./tt-rss.nix { inherit pkgs php; });

  php = (pkgs.php.override {
    embedSupport = true;
    cliSupport = true;
    cgiSupport = false;
    fpmSupport = false;
    phpdbgSupport = false;
    systemdSupport = false;
    apxs2Support = false;
  }).withExtensions ({ all, ... }: with all;
    [mysqli mysqlnd pdo pdo_mysql pcntl posix mbstring fileinfo intl dom xml json curl gd opcache session]);

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
        mkdir -p $out/etc/systemd/system $out/proc $out/sys $out/dev $out/run $out/tmp $out/var/tmp
        touch $out/etc/resolv.conf $out/etc/machine-id
        cp ${./files/os-release} $out/etc/os-release

        # create an empty directory as a mount point for StateDir
        mkdir -p $out/var/lib/tt-rss
        substituteAll ${./files/tt-rss.ini.in} $out/tt-rss.ini
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
      cp $closureInfo/registration nix-path-registration

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
