{ pkgs, ttRss, withSystemd ? true }:

let

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

  uwsgiConfig = pkgs.replaceVars ./files/uwsgi.tt-rss.ini {
    mimeTypes = "${pkgs.mailcap}/etc/mime.types";
    uwsgiLogger = if withSystemd then "systemd" else "stdio";
    siteRoot = ttRss;
  };

  tt-rss-service = pkgs.replaceVars ./files/tt-rss-uwsgi.service {
    inherit php ttRss uwsgi uwsgiConfig;
    inherit (pkgs) coreutils;
  };

  tt-rss-update-service = pkgs.replaceVars ./files/tt-rss-update.service {
    inherit php ttRss;
  };

  tt-rss-socket = pkgs.concatText "tt-rss-uwsgi.socket" [ ./files/tt-rss-uwsgi.socket ];
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
    { object = "${php}/bin/php"; symlink = "/usr/bin/php"; }
  ];
}
