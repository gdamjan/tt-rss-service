{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "tt-rss-plugin-readability";
  version = "unstable-2025-10-16";

  src = pkgs.fetchFromGitHub {
    owner = "tt-rss";
    repo = "tt-rss-plugin-af-readability";
    rev = "fce528aa69c2a7193fb7eb3a3cd9dd17885d6ab6";
    hash = "sha256-3rxrICtm6+ujlBHj5Su2sSEq3lgiHhQMJ/OVfzhzYXA=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/readability/
    cp -a * $out/readability/
    runHook postInstall
  '';
}
