{
  description = "basic dotnet MAUI shell";
  
  inputs = {

    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=master";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let 
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system ; };
    inherit (inputs.nixpkgs) lib; 
    in {
      
      devShells.${system}.default = import ./shell.nix {inherit pkgs;};

  };
}
