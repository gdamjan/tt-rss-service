{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2022-02-05";
    rev = "079f6dfdd0a26e9ba68aff6f05072d1720f6a6af";
    sha256 = "18qdnr22nyh841xg0xdk14c11n1vsxssjg2y5i7af914mn8rcin0";

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
