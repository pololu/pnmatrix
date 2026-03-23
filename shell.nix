let
  nixpkgs = fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/NixOS/nixpkgs/archive/76701a179d3a98b07653e2b0409847499b2a07d3.tar.gz";
    sha256 = "1nj2z9jy99zzqr7mmclr99gh71b26njh66hssmqm1flgxl64svg4";
  };
  pkgs = import nixpkgs {};
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    ruby_3_4
    bundler
    gcc
    libgcc
  ];
}