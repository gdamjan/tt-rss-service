{ pkgs ? import <nixpkgs> {} }:

let
    tt-rss = (import ./tt-rss.nix { inherit pkgs; });
    php = (pkgs.php.override {
        embedSupport = true;
        cliSupport = true;
        cgiSupport = false;
        fpmSupport = false;
        phpdbgSupport = false;
        systemdSupport = false;
        apxs2Support = false;
    }).withExtensions ({ all, ... }: with all;
        [pdo pdo_pgsql pgsql mbstring fileinfo intl xml json curl posix gd opcache session]);

    uwsgi-php = pkgs.uwsgi.override {
        withPAM = false;
        withSystemd = true;
        plugins = ["php"];
        php = php;
    };

    squash-compression = "xz -Xdict-size 100%";

in pkgs.stdenv.mkDerivation {
  name = "tt-rss.raw";
  nativeBuildInputs = [ pkgs.squashfsTools ];

  buildCommand =
    ''
      closureInfo=${pkgs.closureInfo { rootPaths = [ uwsgi-php tt-rss pkgs.coreutils ]; }}
      cp $closureInfo/registration nix-path-registration

      mkdir -p nix/store
      for i in $(< $closureInfo/store-paths); do
        cp -a "$i" "''${i:1}"
      done

      # prepare the portable service file-system
      mkdir -p etc/systemd/system var/lib/tt-rss proc sys dev run tmp var/tmp srv usr/bin bin
      touch etc/resolv.conf etc/machine-id
      cp ${./files/os-release} etc/os-release
      cp ${./files/tt-rss.service} etc/systemd/system/tt-rss.service
      cp ${./files/tt-rss.socket} etc/systemd/system/tt-rss.socket
      cp ${./files/tt-rss-update.service} etc/systemd/system/tt-rss-update.service
      cp ${./files/tt-rss.ini} srv/tt-rss.ini


      ln -s ${tt-rss} srv/tt-rss
      ln -s ${uwsgi-php}/bin/uwsgi usr/bin/uwsgi
      ln -s ${php}/bin/php usr/bin/php
      ln -s ${pkgs.coreutils}/bin/mkdir bin/mkdir


      mksquashfs . $out \
        -all-root -root-mode 755 \
        -b 1048576 -comp ${squash-compression} \
        -ef ${./exclude.list} -wildcards
    '';
}
