{
  description = "GMail SSO";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ ];
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
    perSystem = { pkgs, ... }:
      let
        wrapShell = mkShell: attrs:
          mkShell (attrs // {
            preShellHook = ''
              export PATH=$PWD/bin:$PATH
            '';
          });
        venv = "./venv";
      in
      {
        devShells.default = wrapShell pkgs.mkShellNoCC {
          venvDir = "${venv}";
          packages = builtins.attrValues {
            inherit (pkgs)
              direnv
              nix-direnv

              nixpkgs-fmt
              deadnix
              shfmt
              shellcheck
              taplo
              codespell
              ;

            inherit (pkgs.python311Packages)
              python
              venvShellHook
              black
              ;
          };

          postShellHook = ''
            if [ -e requirements.txt ]; then
                ${venv}/bin/python3 -m pip install -r requirements.txt
            fi
          '';
        };

      };
  };
}
