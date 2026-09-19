let
  # nixos-26.05 from 2026-06-03:
  nixpkgs-version = "b51242d";
  nixpkgs = fetchTarball {
    name = "nixpkgs-${nixpkgs-version}";
    url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgs-version}.tar.gz";
    sha256 = "0ldd02kkfzndk0x98zsg992gqz84ip18hvrq01wws6p96ki176rb";
  };
  pkgs = (import nixpkgs {});
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    ruby_3_4
    bundler
    gcc
    libgcc
    blas
    lapack
  ];
}
