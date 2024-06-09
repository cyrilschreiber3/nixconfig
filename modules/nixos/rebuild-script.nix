{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "rebuild.sh" ''
      # A rebuild script that commits on a successfull build

      set -e

      # cd in the config dir
      pushd ~/nixconfig

      # return if no changes
      if git diff --quiet "*.nix"; then
      echo "No changes detected, exiting..."
      popd
      exit 0
      fi

      # Autoformat nix file
      alejandra . &>/dev/null \
      || (alejandra .; echo "Formating failed" && exit 1)

      # Show the changes
      git diff -U0 "*.nix"

      echo "NixOS Rebuilding..."

      # Rebuild and output simplified errors
      sudo nixos-rebuild switch --flake ./#default &>nixos-switch.log || (cat nixos-switch.log | grep --color error && exit 1)

      # Get current generation metadata
      gen=$(nixos-rebuild list-generations | grep current)

      # Commit all changes with generation metadata
      git commit -am "$gen"

      # Go back to the initial dir
      popd


      # Send notification
      notify-send -e "NixOS Rebuild successful!" --icon=software-update-available

    '')
  ];
}
