{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    android-tools
    zip
    unzip
    ripgrep
    jq
    jadx
  ];
}
