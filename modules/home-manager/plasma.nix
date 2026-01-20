{
  config,
  inputs,
  lib,
  nixosConfig,
  pkgs,
  ...
}: let
  cfg = config.plasmaConfig;
in {
  options.plasmaConfig = {
    enable = lib.mkEnableOption "Enable KDE Plasma 6 module";
    enableBatteryWidget = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable battery widget in the system tray";
    };
    disableSleep = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable the sleep function";
    };
  };

  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  config = lib.mkIf cfg.enable {
    programs.plasma = {
      enable = true;

      workspace = {
        clickItemTo = "select";
        theme = config.global.theme.plasma.style;
        lookAndFeel = config.global.theme.plasma.lookAndFeel;
        colorScheme = config.global.theme.plasma.colorScheme;
        cursor = {
          theme = config.global.theme.cursorTheme.name;
          cursorFeedback = "None";
        };
        iconTheme = config.global.theme.iconTheme.name;
        soundTheme = "ocean";
        wallpaper = config.global.theme.wallpaper;
        wallpaperFillMode = "preserveAspectCrop";
        windowDecorations = {
          theme = config.global.theme.plasma.kwin.theme;
          library = config.global.theme.plasma.kwin.library;
        };
      };

      fonts = {
        general = {
          family = config.global.fonts.sansSerif;
          pointSize = 10;
        };
      };

      input.keyboard = {
        numlockOnStartup = "on";
        layouts = [
          {
            displayName = "CH";
            layout = "ch";
            variant = "fr";
          }
        ];
      };

      shortcuts = {
        "services/foot.desktop" = {
          _launch = "Meta+Shift+Return";
        };
      };

      panels = [
        {
          location = "bottom";
          alignment = "center";
          floating = true;
          height = 44;
          hiding = "none";
          lengthMode = "fill";
          opacity = "adaptive";
          widgets = [
            {
              kickoff = {
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
                label = "";
                sortAlphabetically = false;
                compactDisplayStyle = false;
                sidebarPosition = "left";
                favoritesDisplayMode = "list";
                applicationsDisplayMode = "list";
                showButtonsFor.custom = [
                  "logout"
                  "suspend"
                  "reboot"
                  "shutdown"
                ];
                showActionButtonCaptions = false;
                pin = false;
                settings = {
                  General.switchCategoryOnHover = true;
                };
              };
            }
            {
              iconTasks = {
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:firefox.desktop"
                  "applications:foot.desktop"
                ];
                appearance = {
                  highlightWindows = true;
                  fill = true;
                  rows.multirowView = "never";
                  iconSpacing = "small";
                };
                behavior = {
                  grouping = {
                    method = "byProgramName";
                    clickAction = "cycle";
                  };
                  sortingMethod = "manually";
                  minimizeActiveTaskOnClick = true;
                  middleClickAction = "close";
                  wheel = {
                    switchBetweenTasks = true;
                    ignoreMinimizedTasks = true;
                  };
                  showTasks = {
                    onlyInCurrentScreen = false;
                    onlyInCurrentDesktop = true;
                    onlyInCurrentActivity = false;
                    onlyMinimized = false;
                  };
                  unhideOnAttentionNeeded = true;
                  newTasksAppearOn = "right";
                };
              };
            }
            "org.kde.plasma.marginsseparator"
            {
              systemTray = {
                pin = false;
                icons = {
                  spacing = "small";
                  scaleToFit = true;
                };
                items = {
                  # TODO: fix items not respecting shown/hidden
                  shown = [
                    "org.kde.plasma.notifications"
                    "org.kde.plasma.networkmanagement"
                    "org.kde.plasma.volume"
                    (lib.mkIf cfg.enableBatteryWidget "org.kde.plasma.battery")
                  ];
                  hidden = [];
                  configs = {
                    battery.showPercentage = true;
                  };
                };
              };
            }
            {
              digitalClock = {
                date = {
                  enable = true;
                  format.custom = "dd.MM.yyyy";
                  position = "belowTime";
                };
                time = {
                  showSeconds = "onlyInTooltip";
                  format = "24h";
                };
                timeZone = {
                  selected = [nixosConfig.time.timeZone];
                  lastSelected = nixosConfig.time.timeZone;
                  changeOnScroll = false;
                  format = "code";
                  alwaysShow = false;
                };
                calendar = {
                  firstDayOfWeek = "monday";
                  showWeekNumbers = true;
                };
              };
            }
          ];
        }
      ];

      powerdevil.AC = lib.mkIf cfg.disableSleep {
        autoSuspend.action = "nothing";
        autoSuspend.idleTimeout = null;
      };

      kscreenlocker = {
        appearance = {
          alwaysShowClock = true;
          showMediaControls = true;
          wallpaper = config.global.theme.wallpaper;
        };
        autoLock = true;
        lockOnResume = true;
        passwordRequired = true;
        passwordRequiredDelay = 0;
        timeout = 5; # minutes
      };

      kwin = {
        titlebarButtons = {
          left = lib.mkDefault [];
          right = lib.mkDefault ["minimize" "maximize" "close"];
        };

        virtualDesktops = {
          names = [
            "Main"
            "Communication"
            "Dev"
            "Nixconfig"
          ];
        };

        edgeBarrier = 0;
      };

      session = {
        sessionRestore.restoreOpenApplicationsOnLogin = "onLastLogout";
      };

      spectacle = {
        shortcuts = {
          captureRectangularRegion = "Print";
          # TODO: add more shortcuts here
        };
      };

      # https://github.com/Eryoneta/nixos-config/blob/cb4ab5e3f8a7408d54fa0e892793aeb92a0c4130/public-config/programs/desktop-environments/plasma%2Bshortcuts.nix#L10
      shortcuts = {
        # Virtual desktop actions
        "kwin"."Switch One Desktop to the Left" = "Meta+Ctrl+Left"; # Switch to virtual desktop at left
        "kwin"."Switch One Desktop to the Right" = "Meta+Ctrl+Right"; # Switch to virtual desktop at righ
        # Window actions (Move)
        "kwin"."Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left"; # Move window to the virtual desktop at left
        "kwin"."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right"; # Move window to the virtual desktop at right
        # Window actions (Switch)
        "kwin"."Switch Window Up" = "Meta+Alt+Up"; # Switch to the window above
        "kwin"."Switch Window Down" = "Meta+Alt+Down"; # Switch to the window below
        "kwin"."Switch Window Left" = "Meta+Alt+Left"; # Switch to the window at left
        "kwin"."Switch Window Right" = "Meta+Alt+Right"; # Switch to the window at right
        "kwin"."Walk Through Windows" = "Alt+Tab"; # Switch through a list of windows
        "kwin"."Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
      };

      windows.allowWindowsToRememberPositions = true;
    };
  };
}
