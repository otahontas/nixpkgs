{
  description = "Personal Nix package collection";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = lib.genAttrs systems;
      packageFile = name: ./packages + "/${name}/package.nix";
      packageNames = builtins.attrNames (
        lib.filterAttrs
          (name: type: type == "directory" && builtins.pathExists (packageFile name))
          (builtins.readDir ./packages)
      );
      mkPackages = pkgs:
        lib.genAttrs packageNames (name: pkgs.callPackage (packageFile name) { });
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in mkPackages pkgs);

      overlays.default = final: _prev: mkPackages final;

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
              jq
              nodejs
              prefetch-npm-deps
              trash-cli
            ];
          };
        });
    };
}
