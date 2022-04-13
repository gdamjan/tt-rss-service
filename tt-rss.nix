{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2022-04-03";
    rev = "2654b3c6be408113ede52180ae283afa72da5f3c";
    sha256 = "15bxlrqgw5zv5pr40ff5v80fxqpxcvp0gmm972dj5bsh0fn0lamg";

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
