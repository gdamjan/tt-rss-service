{ pkgs }:

pkgs.stdenv.mkDerivation rec {
    pname = "tt-rss";
    version = "2021-12-23";
    rev = "97baf3e8b9be699d972b91a159ccbe0891efe8ae";
    sha256 = "1c07cjnx5w0hggrgh7m4hxj6nvsr673b82qc8wpjiakxwpfsn42q";

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
