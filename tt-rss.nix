{ pkgs }:

let
  tt-rss-plugin-readability = import ./tt-rss-readability.nix { pkgs=pkgs; };

in
  pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2026-01-28";
    rev = "c625ca6b7c6950580c68a70594894d1755d2badf";
    hash = "sha256-VI3SNDrktTK6I3WC2aBraTZXOexLo0Tj7wkKuMvYVXU=";

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
