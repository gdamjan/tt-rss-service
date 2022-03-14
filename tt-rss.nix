{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2022-03-10";
    rev = "079f6dfdd0a26e9ba68aff6f05072d1720f6a6af";
    sha256 = "18b6781vm7klqrhd1z192mg0zq6pr91ffqyb53988815q4h8qqkr";

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
