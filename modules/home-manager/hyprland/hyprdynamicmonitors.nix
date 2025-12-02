{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hyprlandConfig;

  tomlUtils = pkgs.formats.toml {};

  # Helper function to recursively remove null values from attrs and lists
  filterNulls = attrs:
    lib.filterAttrsRecursive (name: value: value != null)
    (lib.mapAttrsRecursive (
        path: value:
          if lib.isList value
          then
            map (
              item:
                if lib.isAttrs item
                then lib.filterAttrs (name: val: val != null) item
                else item
            ) (lib.filter (item: item != null) value)
          else value
      )
      attrs);

  profileType = lib.types.submodule {
    options = {
      config_file_type = lib.mkOption {
        type = lib.types.enum ["static" "template"];
        description = "Type of configuration file";
      };

      config_file = lib.mkOption {
        type = lib.types.path;
        description = "Path to the configuration file";
      };

      conditions = lib.mkOption {
        type = lib.types.submodule {
          options = {
            power_state = lib.mkOption {
              type = lib.types.nullOr (lib.types.enum ["AC" "BAT"]);
              default = null;
              description = "Power state condition for applying this profile";
            };
            lid_state = lib.mkOption {
              type = lib.types.nullOr (lib.types.enum ["Opened" "Closed"]);
              default = null;
              description = "Lid state condition for applying this profile";
            };
            required_monitors = lib.mkOption {
              type = lib.types.nonEmptyListOf (lib.types.addCheck (lib.types.submodule {
                options = {
                  name = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "Monitor name";
                  };
                  description = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "Monitor description";
                  };
                  monitor_tag = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "Monitor tag";
                  };
                  match_description_using_regex = lib.mkOption {
                    type = lib.types.nullOr lib.types.bool;
                    default = null;
                    description = "Whether to match the description using regex";
                  };
                  match_name_using_regex = lib.mkOption {
                    type = lib.types.nullOr lib.types.bool;
                    default = null;
                    description = "Whether to match the name using regex";
                  };
                };
              }) (monitor: monitor.name != null || monitor.description != null));
              default = [];
              description = "List of required monitors for this profile";
            };
          };
        };
        description = "Conditions for applying this profile";
      };
    };
  };
in {
  imports = [
    inputs.hyprdynamicmonitors.homeManagerModules.default
  ];

  options.hyprlandConfig = {
    dynamicMonitors = lib.mkEnableOption "Enable HyprDynamicMonitors module";
    monitorProfiles = lib.mkOption {
      type = lib.types.attrsOf profileType;
      default = {};
      description = "Monitor profiles configuration";
      example = lib.literalExpression ''
        {
          home = {
            config_file_type = "static";
            config_file = "path/to/config";
            conditions.required_monitors = [
              { name = "Virtual-1"; monitor_tag = "laptop"; }
            ];
          };
          home-docked = {
            config_file_type = "template";
            config_file = "path/to/config_template";
            conditions.required_monitors = [
              { name = "Virtual-1"; monitor_tag = "laptop"; }
              { name = "HDMI-A-1"; monitor_tag = "external"; }
            ];
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.dynamicMonitors {
    wayland.windowManager.hyprland.settings = {
      source = [
        "${config.home.homeDirectory}/.config/hypr/monitors.conf"
      ];
      monitor = lib.mkForce [];
    };

    home.hyprdynamicmonitors = {
      enable = true;
      configFile = tomlUtils.generate "config.toml" {
        general = {
          destination = "${config.home.homeDirectory}/.config/hypr/monitors.conf";
          post_apply_exec = "notify-send 'Profile applied'";
        };
        profiles = filterNulls cfg.monitorProfiles;
      };
    };
  };
}
