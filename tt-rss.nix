{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2022-02-03";
    rev = "a7d6ead956784152423b3bae75b46631f5f108c4";
    sha256 = "1jf507m926jl8bxjqcm8lcx3sgbxiqqsyqiqg3h3vb03mhfpyx1w";

    src = pkgs.fetchurl {
      url = "https://git.tt-rss.org/git/tt-rss/archive/${rev}.tar.gz";
      sha256 = sha256;
      curlOpts = "--user-agent Mozilla-5.0";
    };

    installPhase = ''
      mkdir $out
      cp -ra * $out/
      echo ${version}-${builtins.substring 0 8 rev} > $out/version_static.txt
    '';
}
