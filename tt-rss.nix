{ pkgs }:

let
  tt-rss-plugin-readability = import ./tt-rss-readability.nix { pkgs=pkgs; };

in
  pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2026-10-18";
    rev = "86c8385985fa6c91eb3b4d539a9852372db33b61";
    hash = "sha256-OX1sc20upo3DxD4FALxqFSS1FUBCrAQkH0kLg+otivU=";

    src = pkgs.fetchFromGitHub {
      owner = "tt-rss";
      repo = "tt-rss";
      inherit hash rev;
    };

    installPhase = ''
      mkdir -p $out/
      cp -a * $out/
      echo ${version}-${builtins.substring 0 8 rev} > $out/version_static.txt

      cp -a ${tt-rss-plugin-readability}/* $out/plugins/
    '';
  }
