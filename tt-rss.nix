{ pkgs }:

let
  tt-rss-plugin-readability = import ./tt-rss-readability.nix { pkgs=pkgs; };

in
  pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2024-04-21";
    rev = "d832907125a7711397da8ade5cfb51082d802542";
    sha256 = "sha256-XxwBMKnj+8bTVN0h7+sGYTZMvhD4pr0S02jiV21kqR8=";

    src = pkgs.fetchgit {
      url = "https://git.tt-rss.org/fox/tt-rss.git";
      inherit sha256 rev;
    };

    installPhase = ''
      mkdir -p $out/
      cp -a * $out/
      echo ${version}-${builtins.substring 0 8 rev} > $out/version_static.txt

      cp -a ${tt-rss-plugin-readability}/* $out/plugins/
    '';
  }
