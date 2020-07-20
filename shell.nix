{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.hello
    pkgs.hugo

    # keep this line if you use bash
    pkgs.bashInteractive
  ];
}
