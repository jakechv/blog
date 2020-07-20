{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    hugo
    killall

    # keep this line if you use bash
    bashInteractive
  ];
}
