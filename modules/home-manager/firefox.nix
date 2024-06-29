{
  config,
  pkgs,
  ...
}: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    languagePacks = ["en-US" "fr-CH"];

    profiles = {
      cyril = {
        id = 69;
        name = "Cyril";
        isDefault = true;
        bookmarks = "${import ./firefox_bookmarks.nix}".bookmarks;

        search = {
          force = true;
          default = "StartPage";
          order = ["StartPage" "Google"];
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
              iconUpdateURL = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = ["@nw"];
            };
            "StartPage" = {
              urls = [{template = "https://startpage.com/do/dsearch?q={searchTerms}&cat=web&language=english";}];
              iconUpdateURL = "https://www.startpage.com/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = ["@start"];
            };
            "Bing".metaData.hidden = true;
            "Google".metaData.alias = "@g";
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
      PopupBlocking = {
        Default = true;
        Allow = ["https://*.schreibernet.dev" "https://*.the127001.ch" "https://*.cyrilschreiber.ch"];
      };
      PrompttForDownloadLocation = false;
      DownloadDirectory = "${config.home.homeDirectory}/Downloads";
      Homepage = {
        URL = "https://dashboard.schreibernet.dev";
        locked = true;
        StartPage = "previous-session";
      };

      Preferences = {
        "extensions.pocket.enabled" = false;
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "extensions.autoDisableScopes" = 0;
        "extensions.activeThemeID" = "{4520dc08-80f4-4b2e-982a-c17af42e5e4d}";
        "browser.taskbar.lists.recent.enabled" = false;
        "browser.search.defaultEngineName" = "StartPage";
        "browser.search.order.1" = "StartPage";
      };

      ExtensionsUpdate = true;
      ExtensionsSettings = {
        "*" = {
          blocked_install_message = "Please install extensions from the NixOS configuration";
          installeation_mode = "blocked";
        };
        # Tokyonight Theme
        "{4520dc08-80f4-4b2e-982a-c17af42e5e4d}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/tokyo-night-milav/latest.xpi";
          installation_mode = "force_installed";
        };
        # Bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/tokyo-night-milav/latest.xpi";
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
        # Google Seach
        "google@search.mozilla.org" = {
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
}
