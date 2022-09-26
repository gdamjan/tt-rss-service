{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2022-09-03";
    rev = "d47b8c8494ed41c8a72c21b238dde74e606c5f0e";
    sha256 = "sha256-aX4nn/06QKgyQ9FDBH5yAG+6zJQMFPoCd7NBRIfZ9Io=";

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
