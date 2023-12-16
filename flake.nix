{
  description = ''Portable "Tiny Tiny Rss" service run by uwsgi-php and built with Nix'';

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.11;

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      nixos = (nixpkgs.lib.nixosSystem { system = "x86_64-linux"; modules = []; }).config.system.nixos;
      ttRss = (import ./tt-rss.nix { inherit pkgs; });
    in {
      packages.x86_64-linux.default = (import ./build.nix { inherit pkgs ttRss; withSystemd = false; });
      packages.x86_64-linux.release-info = pkgs.writeText "release-info.txt" ''
        php: ${pkgs.php.version}
        uwsgi: ${pkgs.uwsgi.version}
        tt-rss: ${ttRss.version}
        ${nixos.distroName} ${nixos.release} (${nixos.codeName})
        ${nixos.distroId} ${nixos.label}
      '';
    };
}
