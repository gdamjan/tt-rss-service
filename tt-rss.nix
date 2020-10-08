{ pkgs, php }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2020-10-03";
    rev = "e13d66536caec340b5d1d483e231192c7a021546";
    sha256 = "072gryc81dlkxhm5gxyck8cz4bcdn82sqv8pn0cfs44lyib5r3aw";

    src = pkgs.fetchurl {
      url = "https://git.tt-rss.org/git/tt-rss/archive/${rev}.tar.gz";
      sha256 = sha256;
      curlOpts = "--user-agent Mozilla-5.0";
    };

    installPhase = ''
      mkdir $out
      cp -ra * $out/
      cp ${./files/config.php} $out/config.php
      echo ${version}-${builtins.substring 0 8 rev} > $out/version_static.txt
    '';
}
