{ pkgs, php }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2020-10-01";
    rev = "8a02a728c8726f65efb78a1f07911b8e4065b4ef";
    sha256 = "0bfhdnhxh8rdn9pdz7gvjjlw3vnsj0yxg2k2ckz2ws6pshcbm7ap";

    src = pkgs.fetchurl {
      url = "https://git.tt-rss.org/git/tt-rss/archive/${rev}.tar.gz";
      sha256 = sha256;
      curlOpts = "--user-agent Mozilla-5.0";
    };

    installPhase = ''
      mkdir $out
      cp -ra * $out/
      substituteAll ${./files/config.php.in} $out/config.php
      echo ${version}-${builtins.substring 0 8 rev} > $out/version_static.txt
    '';
}
