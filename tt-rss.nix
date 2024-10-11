{ pkgs }:

let
  tt-rss-plugin-readability = import ./tt-rss-readability.nix { pkgs=pkgs; };

in
  pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2024-10-10";
    rev = "468f464b486e2ed0527cfd7e80113d37cdd4d07c";
    hash = "sha256-aCBi8moCxfDuRyizZkVlvbQEQKq2ZasZEbG5/EuovPE=";

    src = pkgs.fetchgit {
      url = "https://git.tt-rss.org/fox/tt-rss.git";
      inherit hash rev;
    };

    installPhase = ''
      mkdir -p $out/
      cp -a * $out/
      echo ${version}-${builtins.substring 0 8 rev} > $out/version_static.txt

      cp -a ${tt-rss-plugin-readability}/* $out/plugins/
    '';
  }
