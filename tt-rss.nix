{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2022-10-01";
    rev = "68dee4578230306da895d5090b7997d8dd23952e";
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
