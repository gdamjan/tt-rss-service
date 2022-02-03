{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2022-01-21";
    rev = "56fd06d611d7bd4896f886f3e20ac778f47771cb";
    sha256 = "059hrn24x3d6q9ml2p2ymsf0hc734mdp7jq2jxmv7wq8xpjwlxd8";

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
