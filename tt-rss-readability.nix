{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "tt-rss-plugin-readability";
  version = "unstable-2024-06-13";

  src = pkgs.fetchgit {
    url    = "https://git.tt-rss.org/fox/ttrss-af-readability.git";
    rev = "6fa51adb5e663fe01d7d01f75f8029393f3fbc2e";
    hash = "sha256-b0nmOTld789Civw43XgQ0SBv1MyNHiMsv7bZSUiMBfU=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/readability/
    cp -a * $out/readability/
    runHook postInstall
  '';
}
