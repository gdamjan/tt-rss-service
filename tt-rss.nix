{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2021-11-02";
    rev = "7a52560e4e3b0652d32645b60ae13e4904f606bc";
    sha256 = "0lv0mlrblv8k9fxxmblfrsiwsvl99sbq272m20mkp2ap318wg29q";

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
