{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.firefoxConfig;
  firefox_bookmarks = import ./firefox_bookmarks.nix;
in {
  options.firefoxConfig = {
    enable = lib.mkEnableOption "Enable Firefox module";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;

      profiles = {
        cyril = {
          id = 0;
          name = "Cyril";
          isDefault = true;
          bookmarks = {
            force = true;
            settings = firefox_bookmarks.bookmarks;
          };

          search = {
            force = true;
            default = "StartPage";
            order = ["StartPage" "google"];
            engines = {
              "Nix Packages" = {
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = ["@np"];
              };
              "NixOS Wiki" = {
                urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
                icon = "https://nixos.wiki/favicon.png";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = ["@nw"];
              };
              "StartPage" = {
                urls = [{template = "https://startpage.com/do/dsearch?q={searchTerms}&cat=web&language=english";}];
                icon = "https://www.startpage.com/favicon.ico";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = ["@start"];
              };
              "bing".metaData.hidden = true;
              "google".metaData.alias = "@g";
            };
          };
        };
      };

      policies = {
        AppAutoUpdate = false;
        DisableAppUpdate = true;
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptominig = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "always";
        DisplayMenuBar = "default-off";
        SearchBar = "unified";
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        NoDefaultBookmarks = false;
        PromptForDownloadLocation = false;
        DownloadDirectory = "${config.home.homeDirectory}/Downloads";
        Homepage = {
          URL = "https://dashboard.schreibernet.dev";
          locked = true;
          StartPage = "previous-session";
        };

        Preferences = {
          "general.autoScroll" = true;
          "extensions.pocket.enabled" = false;
          "browser.disableResetPrompt" = true;
          "browser.download.panel.shown" = true;
          "extensions.autoDisableScopes" = 0;
          "browser.firefox-view.view-count" = 0;
          "extensions.activeThemeID" = "{4520dc08-80f4-4b2e-982a-c17af42e5e4d}";
          "browser.taskbar.lists.recent.enabled" = false;
          "browser.search.defaultEngineName" = "StartPage";
          "browser.search.order.1" = "StartPage";
        };

        # To get the extension ID, execute this in the browser console:
        # Object.keys(JSON.parse(document.getElementById("redux-store-state").innerHTML).addons.byGUID)[0]

        ExtensionsUpdate = false;
        ExtensionSettings = {
          # TODO: https://addons.mozilla.org/en-US/firefox/addon/fran%C3%A7ais-language-pack/
          "*" = {
            blocked_install_message = "Please install extensions from the NixOS configuration";
            installeation_mode = "blocked";
          };
          "langpack-fr@firefox.mozilla.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/français-language-pack/latest.xpi";
            installation_mode = "force_installed";
          };
          # Tokyonight Theme
          "{4520dc08-80f4-4b2e-982a-c17af42e5e4d}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tokyo-night-milav/latest.xpi";
            installation_mode = "force_installed";
          };
          # Bitwarden
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          # uBlock Origin
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          # Startpage Seach
          "{20fc2e06-e3e4-4b2b-812b-ab431220cada}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/startpage-private-search/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
          # Duplicate Tab Shortcut
          "duplicate-tab@firefox.stefansundin.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/duplicate-tab-shortcut/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
          # Everything Metric
          "{ffd50a6d-1702-4d87-83c3-ec468f67de6a}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/everything-metric-converter/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
          # TinyEye Reverse Image Search
          "tineye@ideeinc.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tineye-reverse-image-search/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
          # Vue.js Devtools
          "{5caff8cc-3d2e-4110-a88a-003cc85b3858}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/vue-js-devtools/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
          # # New Tab Homepage
          # "{66E978CD-981F-47DF-AC42-E3CF417C1467}" = {
          #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/new-tab-homepage/latest.xpi";
          #   installation_mode = "force_installed";
          #   default_area = "menupanel";
          # };
          # DuckDuckGo Privacy Essentials
          "jid1-ZAdIEUB7XOzOJw@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/duckduckgo-for-firefox/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
          # Refined GitHub
          "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/refined-github-/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
          # Dark Reader
          "addon@darkreader.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
        };
      };
    };

    xdg.mimeApps.defaultApplications = {
      "text/html" = ["firefox.desktop"];
      "text/xml" = ["firefox.desktop"];
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
    };

    # enable Wayland support
    home.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
  };
}
