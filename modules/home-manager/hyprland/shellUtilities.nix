{
  config,
  lib,
  pkgs,
  ...
}: let
  hyprlandScripts = {
    hyprland-window-pop = pkgs.writeShellScriptBin "hyprland-window-pop" ''
      #! /usr/bin/env nix-shell

      # Toggle to pop-out a tile to stay fixed on a display basis.

      # Usage:
      # hyprland-window-pop [width height [x y]]
      #
      # Arguments:
      #   width   Optional. Width of the floating window. Default: 1300
      #   height  Optional. Height of the floating window. Default: 900
      #   x       Optional. X position of the window. Must provide both X and Y to take effect.
      #   y       Optional. Y position of the window. Must provide both X and Y to take effect.
      #
      # Behavior:
      #   - If the window is already pinned, it will be unpinned and removed from the pop layer.
      #   - If the window is not pinned, it will be floated, resized, moved/centered, pinned, brought to top, and popped.

      width=$${1:-1300}
      height=$${2:-900}
      x=$${3:-}
      y=$${4:-}

      active=$(hyprctl activewindow -j)
      pinned=$(echo "$active" | jq ".pinned")
      addr=$(echo "$active" | jq -r ".address")

      if [[ $pinned == "true" ]]; then
        hyprctl -q --batch \
          dispatch pin address:$addr; \
          dispatch togglefloating address:$addr; \
          dispatch tagwindow -pop address:$addr;
      elif [[ -n $addr ]]; then
        hyprctl dispatch togglefloating address:$addr
        hyprctl dispatch resizeactive exact $width $height address:$addr

        if [[ -n $x && -n $y ]]; then
          hyprctl dispatch moveactive $x $y address:$addr
        else
          hyprctl dispatch centerwindow address:$addr
        fi

        hyprctl -q --batch \
          dispatch pin address:$addr; \
          dispatch alterzorder top address:$addr; \
          dispatch tagwindow +pop address:$addr;
      fi
    '';
  };
in {
  options.hyprlandConfig = {
    shellUtilities = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Hyprland shell utilities.";
    };

    hyprlandScripts = lib.mkOption {
      type = lib.types.attrsOf lib.types.package;
      description = "Hyprland utility scripts.";
      readOnly = true;
    };
  };

  config = lib.mkIf config.hyprlandConfig.shellUtilities {
    home.packages = builtins.attrValues hyprlandScripts;
    hyprlandConfig.hyprlandScripts = hyprlandScripts;
  };
}
