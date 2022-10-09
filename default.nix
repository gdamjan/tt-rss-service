{ pkgs ? import <nixpkgs> {}, withSystemd ? true }:

let

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
    [ pdo pdo_pgsql pcntl posix filter ctype mbstring fileinfo iconv intl dom curl gd opcache session ]);

  uwsgi = pkgs.uwsgi.override {
    withPAM = false;
    systemd = pkgs.systemdMinimal;
    plugins = ["php"];
    inherit php withSystemd;
  };

  uwsgiConfig = pkgs.substituteAll {
    name = "uwsgi.tt-rss.ini";
    src = ./files/uwsgi.tt-rss.ini.in;
    mimeTypes = "${pkgs.mime-types}/etc/mime.types";
    uwsgiLogger = if withSystemd then "systemd" else "stdio";
    inherit php ttRss;
  };

  tt-rss-service = pkgs.substituteAll {
    name = "tt-rss.service";
    src = ./files/tt-rss.service.in;
    inherit php ttRss uwsgi uwsgiConfig;
    inherit (pkgs) coreutils;
  };

  tt-rss-update-service = pkgs.substituteAll {
    name = "tt-rss-update.service";
    src = ./files/tt-rss-update.service.in;
    inherit php ttRss;
  };

  tt-rss-socket = pkgs.concatText "tt-rss.socket" [ ./files/tt-rss.socket ];
in

pkgs.portableService {
  pname = "tt-rss";
  version = ttRss.version;
  description = ''Portable "Tiny Tiny Rss" service run by uwsgi-php and built with Nix'';
  homepage = "https://github.com/gdamjan/tt-rss-service/";

  units = [ tt-rss-service tt-rss-update-service tt-rss-socket ];

  symlinks = [
    { object = "${pkgs.cacert}/etc/ssl"; symlink = "/etc/ssl"; }
    { object = "${pkgs.bash}/bin/bash"; symlink = "/bin/sh"; }
    { object = "${php}/bin/php"; symlink = "/bin/php"; }
  ];
}
