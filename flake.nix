{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mypkgs = {
      url = "github:cyrilschreiber3/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ssh-keys = {
      url = "https://github.com/cyrilschreiber3.keys";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-wsl,
    # plasma-manager,
    spicetify-nix,
    mypkgs,
    ssh-keys,
    ...
  } @ inputs: {
    nixosConfigurations = {
      scorpius-cl-01 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/scorpius-cl-01/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      scorpius-cl-01-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "24.05";
            wsl.enable = true;
          }
          ./hosts/scorpius-cl-01-wsl/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
    nixosModules = {
      mainUser = import ./modules/nixos/mainUser.nix;
      cachix = import ./modules/nixos/cachix/cachix.nix;
    };
    homeManagerModules = {
      btop = import ./modules/home-manager/btop.nix;
      cinnamon = import ./modules/home-manager/cinnamon.nix;
      firefox = import ./modules/home-manager/firefox.nix;
      git = import ./modules/home-manager/git.nix;
      gnome = import ./modules/home-manager/gnome.nix;
      spotify = import ./modules/home-manager/spotify.nix;
      vscode = import ./modules/home-manager/vscode.nix;
      zsh = import ./modules/home-manager/zsh.nix;
    };
  };
}
