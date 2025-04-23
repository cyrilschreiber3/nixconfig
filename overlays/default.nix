{inputs, ...}: {
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # packages-2405 = final: _prev: {
  #   legacyPackages-2405 = import inputs.nixpkgs-2405 {
  #     system = final.system;
  #     config.allowUnfree = true;
  #   };
  # };

  mypkgs = final: _prev: {
    mypkgs = import inputs.mypkgs {
      pkgs = import inputs.nixpkgs {
        system = final.system;
        config.allowUnfree = true;
      };
    };
  };

  mypkgs-2405 = final: _prev: {
    mypkgs-2405 = import inputs.mypkgs {
      pkgs = import inputs.nixpkgs-2405 {
        system = final.system;
        config.allowUnfree = true;
      };
    };
  };
}
