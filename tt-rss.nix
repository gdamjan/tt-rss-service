{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2021-02-28";
    rev = "b05d4e3d9ff2803b28dd68d807b57500f8c3078f";
    sha256 = "0r35wawv0jdp8gbkcnc2h2s9phb9jkmnppra8phj4mgrnnz6q8rv";

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
