{ pkgs ? import <nixpkgs> {} }:

let
    tt-rss = pkgs.stdenv.mkDerivation rec {
        pname = "tt-rss";
        version = "2020-08-29";
        rev = "67f02e2aa7b246ef7ca2b2aa4c62e2826327d219";

        src = pkgs.fetchurl {
          url = "https://git.tt-rss.org/git/tt-rss/archive/${rev}.tar.gz";
          sha256 = "12gybaawwx8pgshj7lcpwm98waj7cqyy2jp5hsa3m9bnsd23rhld";
        };

        installPhase = ''
          mkdir $out
          cp -ra * $out/
          cp ${./files/config.php} $out/config.php
        '';
    };

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

    squash-compression = "zstd";

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
