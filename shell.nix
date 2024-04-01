# Nix shell file
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = [
    pkgs.hugo
    pkgs.netlify-cli
    pkgs.nodejs_20
  ];
}
