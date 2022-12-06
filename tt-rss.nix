{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2022-12-02";
    rev = "fa9c614ff144153ca1f4c0744fe0bc7d8f3a82ad";
    sha256 = "sha256-m3MV/2m1bXDJfHBbI9bZRXeQehaPYDVQ46vyJLX7a7I=";

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
