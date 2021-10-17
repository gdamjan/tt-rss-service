{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2021-10-16";
    rev = "d1ffe6d6cfc982540c6d195dc3943eb4dbe2ca05";
    sha256 = "05lkac3i43f1wg1yh6lb27ca09vinpq8w4xfnwq995dyhaxy4f09";

    src = pkgs.fetchurl {
      url = "https://git.tt-rss.org/git/tt-rss/archive/${rev}.tar.gz";
      sha256 = sha256;
      curlOpts = "--user-agent Mozilla-5.0";
    };

    installPhase = ''
      mkdir $out
      cp -ra * $out/
      echo ${version}-${builtins.substring 0 8 rev} > $out/version_static.txt
    '';
}
