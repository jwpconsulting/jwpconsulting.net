# Nix Flakes file
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.simpleFlake {
      inherit self nixpkgs;
      name = "Flake for jwpconsulting.net";
      shell = ./shell.nix;
    };
}
