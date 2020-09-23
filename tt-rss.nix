{ pkgs, php }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2020-09-23";
    rev = "d0ed7890df949669261f52235151c93cf324714e";
    sha256 = "1b2fczd41bqg9bq37r99svrqswr9qrp35m6gn3nz032yqcwc22ij";

    src = pkgs.fetchurl {
      url = "https://git.tt-rss.org/git/tt-rss/archive/${rev}.tar.gz";
      sha256 = sha256;
      curlOpts = "--user-agent Mozilla-5.0";
    };

    phpBin = php + "/bin/php";
    installPhase = ''
      mkdir $out
      cp -ra * $out/
      substituteAll ${./files/config.php.in} $out/config.php
      echo ${version}-${builtins.substring 0 8 rev} > $out/version_static.txt
    '';
}
