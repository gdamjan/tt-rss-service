{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "tt-rss-plugin-readability";
  version = "unstable-2026-08-04";

  src = pkgs.fetchFromGitHub {
    owner = "tt-rss";
    repo = "tt-rss-plugin-af-readability";
    rev = "c5412fd92eee49db589eff668e9cc8839bc16fcf";
    hash = "sha256-OX1sc20upo3DxD4FALxqFSS1FUBCrAQkH0kLg+otivU=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/readability/
    cp -a * $out/readability/
    runHook postInstall
  '';
}
