{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hyprlandConfig;

  colors = config.global.theme.colorPalette;
in {
  options.hyprlandConfig = {
    enable = lib.mkEnableOption "Enable Hyprland module";
    idleSuspend = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable system suspend after idle timeout";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprland
      hyprlock
      hypridle
      hyprshot
      hyprpicker
      wl-clipboard
      brightnessctl
      playerctl
      waybar
      kitty
      nemo
      wofi
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      settings = {
        # Default applications
        "$terminal" = "kitty";
        "$file_manager" = "nemo";
        "$browser" = "chromium --new-window --ozone-platform=wayland";
        "$launcher" = "walker";
        "$webapp" = "chromium --ozone-platform=wayland --app";
        "$music_player" = "spotify";

        # Aliases
        "$start" = "uwsm app --";

        exec-once = [
          "$start hypridle"
          "$start mako"
          "$start waybar"
          "$start elephant"
          "$start walker --gapplication-service"
        ];

        monitor = lib.optionals (config.hyprlandConfig.dynamicMonitors == false) [",preferred,auto,auto"];

        #####################
        ### Look and Feel ###
        #####################

        general = {
          gaps_in = 5;
          gaps_out = 10;

          border_size = 2;

          "col.active_border" = colors.formats.color04.rgbaString 1.0;
          "col.inactive_border" = colors.formats.color07.rgbaString 1.0;

          resize_on_border = false;

          allow_tearing = false;

          layout = "dwindle";
        };

        decoration = {
          rounding = 4;

          shadow = {
            enabled = false;
            range = 30;
            render_power = 3;
            ignore_window = true;
            color = "rgba(00000045)";
          };

          blur = {
            enabled = true;
            size = 5;
            passes = 2;

            vibrancy = 0.1696;
          };
        };

        animations = {
          enabled = true; # yes, please :)

          bezier = [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];

          animation = [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 0, 0, ease"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
          force_split = 2;
        };

        master = {
          new_status = "master";
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };

        #############
        ### Input ###
        #############

        input = {
          kb_layout = "ch";
          kb_variant = "fr";
          # kb_model =
          kb_options = "compose:caps";
          # kb_rules =

          follow_mouse = 1;

          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

          touchpad = {
            natural_scroll = false;
          };
        };

        gestures = {
          workspace_swipe = false;
        };

        ###################
        ### Keybindings ###
        ###################

        bindd = [
          ####################
          ### Applications ###
          ####################

          # Default Apps
          "SUPER, space, Launcher, exec, walker"
          "SUPER, RETURN, Terminal, exec, $start kitty"
          "SUPER, L, Lock Screen, exec, hyprlock"
          "SUPER, F, File Manager, exec, $start $file_manager"
          "SUPER, B, Web Browser, exec, $start $browser"
          "SUPER, M, Music Player, exec, $start $music_player"

          # Menus
          # TODO: setup walker

          # Screenshot
          ", PRINT, Screenshot Region, exec, hyprshot -m region --clipboard-only --freeze"
          "SHIFT, PRINT, Screenshot Window, exec, hyprshot -m active -m window --clipboard-only --freeze"
          "CTRL, PRINT, Screenshot Monitor, exec, hyprshot -m active -m output --clipboard-only --freeze"
          "SUPER, PRINT, Screenshot Monitor to disk, exec, hyprshot -m active -m output --freeze"

          # Color Picker
          "SUPER, C, Color Picker, exec, hyprpicker --autocopy --format=hex"

          # Clipboard Manager
          # TODO: setup wl-clipboard

          #########################
          ### Window Management ###
          #########################

          # Close windows
          "SUPER, W, Close Window, killactive,"

          # Control tiling
          "SUPER, J, Toggle window split mode, togglesplit,"
          "SUPER, P , Toggle window pseudo tiling, pseudo,"
          "SUPER, T, Toggle floating mode, togglefloating,"
          "SUPER, F, Fullscreen, fullscreen, 0"
          "SUPER CTRL, F, Tiled fullscreen, fullscreenstate, 0 2"
          "SUPER ALT , F, Full width, fullscreen, 1"
          "SUPER, O, Pop window out (fload & pin), exec, ${config.hyprlandConfig.hyprlandScripts.hyprland-window-pop}"

          # Move focus
          "SUPER, LEFT, Move focus left, movefocus, l"
          "SUPER, RIGHT, Move focus right, movefocus, r"
          "SUPER, UP, Move focus up, movefocus, u"
          "SUPER, DOWN, Move focus down, movefocus, d"

          # Switch workspaces
          "SUPER, code:10, Switch to workspace 1, workspace, 1"
          "SUPER, code:11, Switch to workspace 2, workspace, 2"
          "SUPER, code:12, Switch to workspace 3, workspace, 3"
          "SUPER, code:13, Switch to workspace 4, workspace, 4"
          "SUPER, code:14, Switch to workspace 5, workspace, 5"
          "SUPER, code:15, Switch to workspace 6, workspace, 6"
          "SUPER, code:16, Switch to workspace 7, workspace, 7"
          "SUPER, code:17, Switch to workspace 8, workspace, 8"
          "SUPER, code:18, Switch to workspace 9, workspace, 9"
          "SUPER, code:19, Switch to workspace 10, workspace, 10"

          # Move window to workspace
          "SUPER SHIFT, code:10, Move window to workspace 1, movetoworkspace, 1"
          "SUPER SHIFT, code:11, Move window to workspace 2, movetoworkspace, 2"
          "SUPER SHIFT, code:12, Move window to workspace 3, movetoworkspace, 3"
          "SUPER SHIFT, code:13, Move window to workspace 4, movetoworkspace, 4"
          "SUPER SHIFT, code:14, Move window to workspace 5, movetoworkspace, 5"
          "SUPER SHIFT, code:15, Move window to workspace 6, movetoworkspace, 6"
          "SUPER SHIFT, code:16, Move window to workspace 7, movetoworkspace, 7"
          "SUPER SHIFT, code:17, Move window to workspace 8, movetoworkspace, 8"
          "SUPER SHIFT, code:18, Move window to workspace 9, movetoworkspace, 9"
          "SUPER SHIFT, code:19, Move window to workspace 10, movetoworkspace, 10"

          # Control scratchpad
          "SUPER, S, Toggle scratchpad, togglespecialworkspace, scratchpad"
          "SUPER ALT, S, Send window to scratchpad, movetoworkspacesilent, special:scratchpad"

          # TAB between workspaces
          "SUPER, TAB, Next workspace, workspace, e+1"
          "SUPER SHIFT, TAB, Previous workspace, workspace, e-1"
          "SUPER CTRL, TAB, Last workspace, workspace, previous"

          # Move workspace to monitor
          "SUPER SHIFT ALT, LEFT, Move workspace to left monitor, movecurrentworkspacetomonitor, l"
          "SUPER SHIFT ALT, RIGHT, Move workspace to right monitor, movecurrentworkspacetomonitor, r"

          # Swap active window with the one next to it
          "SUPER SHIFT, LEFT, Swap window to the left, swapwindow, l"
          "SUPER SHIFT, RIGHT, Swap window to the right, swapwindow, r"
          "SUPER SHIFT, UP, Swap window up, swapwindow, u"
          "SUPER SHIFT, DOWN, Swap window down, swapwindow, d"

          # Scroll through workspaces
          "SUPER, mouse_down, Scroll active workspace forward, workspace, e+1"
          "SUPER, mouse_up, Scroll active workspace backward, workspace, e-1"
        ];

        bindmd = [
          # Move/resize windows with mouse
          "SUPER, mouse:272, Move window, movewindow"
          "SUPER, mouse:273, Resize window, resizewindow"
        ];

        bindeld = [
          # Laptop multimedia keys for volume and LCD brightness
          ",XF86AudioRaiseVolume, Volume up, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, Volume down, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, Mute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioMicMute, Mute microphone, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ",XF86MonBrightnessUp, Brightness up, exec, brightnessctl -e4 -n2 set 5%+"
          ",XF86MonBrightnessDown, Brightness down, exec, brightnessctl -e4 -n2 set 5%-"
        ];

        bindld = [
          # Requires playerctl
          ", XF86AudioNext, Next track, exec, playerctl next"
          ", XF86AudioPause, Pause, exec, playerctl play-pause"
          ", XF86AudioPlay, Play, exec, playerctl play-pause"
          ", XF86AudioPrev, Previous track, exec, playerctl previous"
          # TODO: add scrtipt to change audio output with keybind
        ];

        windowrule = [
          # Fix some dragging issues with XWayland
          "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        ];
      };
    };

    programs.zsh.initContent = ''
      # Start Hyprland
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
          exec uwsm start -S hyprland-uwsm.desktop
      fi
    '';

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          no_fade_in = false;
        };
        auth = {
          fingerprint.enabled = true;
        };
        background = {
          monitor = "";
          path = "${pkgs.copyPathToStore ./../../../modules/assets/wallpaper.jpg}";
          blur_passes = 3;
          brightness = 0.5;
        };

        input-field = let
          surfaceRgb = colors.formats.color02.rgbString;
          foregroundRgb = colors.formats.color05.rgbString;
          foregroundMutedRgb = colors.formats.color04.rgbString;
        in {
          monitor = "";
          size = "600, 100";
          position = "0, 0";
          halign = "center";
          valign = "center";

          inner_color = surfaceRgb;
          outer_color = foregroundRgb;
          outline_thickness = 4;

          font_family = config.global.fonts.sansSerif;
          font_size = 32;
          font_color = foregroundRgb;

          placeholder_color = foregroundMutedRgb;
          placeholder_text = "  Enter Password 󰈷 ";
          check_color = "rgba(131, 192, 146, 1.0)";
          fail_text = "Wrong password";

          rounding = 0;
          shadow_passes = 0;
          fade_on_empty = false;
        };

        label = {
          monitor = "";
          text = "\$FPRINTPROMPT";
          text_align = "center";
          color = "rgb(211, 198, 170)";
          font_size = 24;
          font_family = config.global.fonts.sansSerif;
          position = "0, -100";
          halign = "center";
          valign = "center";
        };
      };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener =
          [
            {
              # Lock screen after 5 minutes of inactivity
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
            {
              # Turn off display after 10 minutes of inactivity
              timeout = 600;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
            }
          ]
          ++ (lib.optional cfg.idleSuspend [
            {
              # Suspend system after 20 minutes of inactivity
              timeout = 900;
              on-timeout = "systemctl suspend";
              on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
            }
          ]);
      };
    };

    programs.kitty = {
      enable = true;
      settings = {
        background = colors.background;
        foreground = colors.foreground;

        selection_background = colors.color12;
        selection_foreground = colors.color15;

        cursor = colors.foreground;
        cursor_text_color = colors.background;

        # Black
        color0 = colors.color00;
        color8 = colors.color08;

        # Red
        color1 = colors.color01;
        color9 = colors.color09;

        # Green
        color2 = colors.color02;
        color10 = colors.color10;

        # Yellow
        color3 = colors.color03;
        color11 = colors.color11;

        # Blue
        color4 = colors.color04;
        color12 = colors.color12;

        # Magenta
        color5 = colors.color05;
        color13 = colors.color13;

        # Cyan
        color6 = colors.color06;
        color14 = colors.color14;

        # White
        color7 = colors.color07;
        color15 = colors.color15;
      };
    };

    makoConfig = {
      enable = true;
      theme = "tokyonight";
      font = config.global.fonts.sansSerif;
    };

    walkerConfig = {
      enable = true;
    };

    waybarConfig = {
      enable = true;
    };
    # xdg.configFile."hypr/hyprland.conf".source = "${pkgs.copyPathToStore ../dotfiles/hypr/hyprland.conf}";
  };
}
