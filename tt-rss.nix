{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2022-05-30";
    rev = "d391a01de7cb8509cf92fa005b51b282f34c39d7";
    sha256 = "sha256-ELC36yIIFJl4ne9wwphkM4ulQDU6sbdVPYpD6wWCkOM=";

    src = pkgs.fetchgit {
      url = "https://git.tt-rss.org/fox/tt-rss.git";
      inherit sha256 rev;
    };

    installPhase = ''
      mkdir -p $out/
      cp -R * $out/
      echo ${version}-${builtins.substring 0 8 rev} > $out/version_static.txt
    '';
}
