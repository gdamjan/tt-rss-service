{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2022-08-22";
    rev = "c0e77241d34f494c98b877df655fc5a5c5a9cb14";
    sha256 = "sha256-tKIh8MyOFQFbOhDcEFGOSQ08rxj0BWtFuZD9cBPmdyQ=";

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
