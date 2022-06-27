{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2022-06-20";
    rev = "b148d2f5153f9711120b3a3ac50ee84509c9cdfb";
    sha256 = "sha256-oX07AsIcHUilFidTxpgpAdOztBRwIhnLW7fzQ9k+vS0=";

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
