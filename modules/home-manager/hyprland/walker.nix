{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.walkerConfig;
in {
  imports = [inputs.walker.homeManagerModules.default];

  options.walkerConfig = {
    enable = lib.mkEnableOption "Enable Walker module";
  };
  # TODO: Configure more options
  # config example: https://github.com/percygt/nix-dots/blob/52c1335f39d0a824493238b26f4a95c7ead47e74/desktop/niri/walker/config.toml
  config = lib.mkIf cfg.enable {
    programs.walker = {
      enable = true;
      runAsService = true;

      config = {
        theme = config.global.theme.name;

        force_keyboard_focus = true;
        close_when_open = true;
        click_to_close = true;
        selection_wrap = true;

        exact_search_prefix = "'";

        placeholders = {
          "default" = {
            input = " Search...";
            list = " No items found";
          };
        };

        keybinds = {
          close = ["Escape"];
          next = ["Down" "Tab"];
          previous = ["Up" "Shift+Tab"];
          left = ["Left"];
          right = ["Right"];
          down = ["Down"];
          up = ["Up"];
          toggle_exact = ["ctrl e"];
          resume_last_query = ["ctrl r"];
          quick_activate = ["F1" "F2" "F3" "F4"];
          page_down = ["Page_Down"];
          page_up = ["Page_Up"];
        };

        providers = {
          max_results = 20;
          default = ["desktopapplications" "calc" "runner" "menus"];
          empty = ["desktopapplications"];

          prefixes = [
            {
              prefix = ";";
              providers = ["providerlist"];
            }
            {
              prefix = "=";
              providers = ["calc"];
            }
            {
              prefix = ":";
              providers = ["commands"];
            }
            {
              prefix = "/";
              providers = ["files"];
            }
            {
              prefix = "@";
              providers = ["websearch"];
            }
            {
              prefix = ".";
              providers = ["symbols"];
            }
            # {
            #   prefix = ",";
            #   providers = ["mens:powermenu"];
            # }
          ];

          actions = {
            calc = [
              {
                action = "copy";
                default = true;
                bind = "Return";
              }
              {
                action = "delete";
                bind = "ctrl d";
                after = "AsyncReload";
              }
            ];
            files = [
              {
                action = "open";
                default = true;
                bind = "Return";
              }
              {
                action = "opendir";
                label = "open dir";
                bind = "ctrl Return";
              }
              {
                action = "copypath";
                label = "copy path";
                bind = "ctrl shift c";
              }
              {
                action = "copyfile";
                label = "copy file";
                bind = "ctrl c";
              }
            ];
            runner = [
              {
                action = "run";
                default = true;
                bind = "Return";
              }
              {
                action = "runterminal";
                label = "run in terminal";
                bind = "shift Return";
              }
            ];
          };
        };
      };

      themes = {
        "${config.global.theme.name}" = {
          style = lib.concatStringsSep "\n" [
            ''
              @define-color selected-text ${config.global.theme.colorPalette.color14};
              @define-color text ${config.global.theme.colorPalette.foreground};
              @define-color base ${config.global.theme.colorPalette.background};
              @define-color border ${config.global.theme.colorPalette.color04};
              @define-color foreground ${config.global.theme.colorPalette.foreground};
              @define-color background ${config.global.theme.colorPalette.background};
            ''
            (builtins.readFile ./../../dotfiles/walker/style.css)
          ];
          layouts = {
            "layout" = builtins.readFile ./../../dotfiles/walker/layout.xml;
          };
        };
      };
    };
  };
}
