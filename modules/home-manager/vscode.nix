{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.vscodeConfig;
in {
  options.vscodeConfig = {
    enable = lib.mkEnableOption "Enable Visual Studio Code module";
    enableBaseExtensions = lib.mkEnableOption "Enable base extensions";
    enableLanguageExtensions = lib.mkEnableOption "Enable language specific extensions";
    mutableExtensionsDir = lib.mkEnableOption "Enable mutable extensions directory";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      inputs.nix-vscode-extensions.overlays.default
      inputs.nix4vscode.overlays.forVscode
    ];

    home.packages = with pkgs; [
      # Needed for foxundermoon.shell-format
      shfmt
    ];

    programs.vscode = {
      enable = true;
      package = pkgs.vscode;

      mutableExtensionsDir = cfg.mutableExtensionsDir;

      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;

        extensions = with pkgs.vscode-marketplace;
          lib.flatten [
            (lib.optional cfg.enableBaseExtensions [
                # utilities
                formulahendry.auto-close-tag
                formulahendry.auto-rename-tag
                aaron-bond.better-comments
                ryuta46.multi-command
                chunsen.bracket-select
                esbenp.prettier-vscode
                ritwickdey.liveserver
                rangav.vscode-thunder-client
                shardulm94.trailing-spaces
                usernamehw.errorlens
                gruntfuggly.todo-tree
                selfrefactor.order-props
                jkillian.custom-local-formatters
                arrterian.nix-env-selector

                # remote development
                ms-vscode.remote-server
                ms-vscode.remote-explorer
                ms-vscode-remote.remote-ssh
                ms-vscode.remote-repositories
                ms-vscode-remote.remote-containers

                # theme
                enkia.tokyo-night
                vscode-icons-team.vscode-icons

                # Copilot
                github.copilot
              ]
              ++ pkgs.nix4vscode.forVscodeVersion pkgs.vscode.version [
                "github.copilot-chat"
              ])

            (lib.optional cfg.enableLanguageExtensions [
              # Actions
              github.vscode-github-actions

              # Ansible
              redhat.ansible
              wolfmah.ansible-vault-inline

              # Bash
              foxundermoon.shell-format

              # CSS
              bradlc.vscode-tailwindcss

              # Docker
              ms-azuretools.vscode-docker

              # DotEnv
              mikestead.dotenv

              # Go
              golang.go
              jinliming2.vscode-go-template
              otovo-oss.htmx-tags

              # HTML
              adrianwilczynski.format-selection-as-html
              ecmel.vscode-html-css
              zignd.html-css-class-completion

              # Json
              zainchen.json

              # Makefile
              ms-vscode.makefile-tools

              # Nix
              jnoortheen.nix-ide
              kamadorueda.alejandra

              # Powershell
              ms-vscode.powershell

              # Python
              ms-python.python
              ms-python.vscode-pylance
              ms-python.debugpy

              # SQL
              formulahendry.vscode-mysql
              qwtel.sqlite-viewer
              mtxr.sqltools

              # Templ
              a-h.templ

              # Toml
              tamasfe.even-better-toml

              # Vue
              vue.volar

              # XML
              dotjoshjohnson.xml

              # YAML
              redhat.vscode-yaml
            ])
          ]
          ++ [
            pkgs.vscode-extensions.ms-vscode-remote.vscode-remote-extensionpack
          ];

        userSettings = {
          "[dotenv]" = {
            "editor.defaultFormatter" = "foxundermoon.shell-format";
          };
          "[go]" = {
            "editor.defaultFormatter" = "golang.go";
          };
          "[ignore]" = {
            "editor.defaultFormatter" = "foxundermoon.shell-format";
          };
          "[nix]" = {
            "editor.defaultFormatter" = "kamadorueda.alejandra";
          };
          "[powershell]" = {
            "editor.defaultFormatter" = "ms-vscode.powershell";
          };
          "[properties]" = {
            "editor.defaultFormatter" = "foxundermoon.shell-format";
          };
          "[shellscript]" = {
            "editor.defaultFormatter" = "foxundermoon.shell-format";
          };
          "[templ]" = {
            "editor.defaultFormatter" = "a-h.templ";
          };
          "[vue]" = {
            "editor.defaultFormatter" = "Vue.volar";
          };
          "ansible.lightspeed.enabled" = false;
          "ansible.lightspeed.suggestions.enabled" = false;
          "better-comments.tags" = [
            {
              "tag" = "[ ]";
              "color" = "#FF8C00";
              "strikethrough" = false;
              "underline" = false;
              "backgroundColor" = "transparent";
              "bold" = false;
              "italic" = false;
            }
            {
              "tag" = "[x]";
              "color" = "#FF8C00";
              "strikethrough" = true;
              "underline" = false;
              "backgroundColor" = "transparent";
              "bold" = false;
              "italic" = false;
            }
            {
              "tag" = "fixme";
              "color" = "#FFFFFF";
              "strikethrough" = false;
              "underline" = false;
              "backgroundColor" = "transparent";
              "bold" = false;
              "italic" = false;
            }
            # Default tags
            {
              "tag" = "!";
              "color" = "#FF2D00";
              "strikethrough" = false;
              "underline" = false;
              "backgroundColor" = "transparent";
              "bold" = false;
              "italic" = false;
            }
            {
              "tag" = "?";
              "color" = "#3498DB";
              "strikethrough" = false;
              "underline" = false;
              "backgroundColor" = "transparent";
              "bold" = false;
              "italic" = false;
            }
            {
              "tag" = "//";
              "color" = "#474747";
              "strikethrough" = true;
              "underline" = false;
              "backgroundColor" = "transparent";
              "bold" = false;
              "italic" = false;
            }
            {
              "tag" = "todo";
              "color" = "#FF8C00";
              "strikethrough" = false;
              "underline" = false;
              "backgroundColor" = "transparent";
              "bold" = false;
              "italic" = false;
            }
            {
              "tag" = "*";
              "color" = "#98C379";
              "strikethrough" = false;
              "underline" = false;
              "backgroundColor" = "transparent";
              "bold" = false;
              "italic" = false;
            }
          ];
          "diffEditor.ignoreTrimWhitespace" = false;
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.fontFamily" = "MesloLGS Nerd Font";
          "editor.fontLigatures" = false;
          "editor.formatOnPaste" = false;
          "editor.formatOnSave" = true;
          "editor.formatOnType" = true;
          "editor.inlineSuggest.enabled" = true;
          "editor.linkedEditing" = true;
          "editor.minimap.enabled" = true;
          "explorer.confirmDelete" = false;
          "explorer.confirmDragAndDrop" = false;
          "explorer.fileNesting.patterns" = {
            "*.ts" = "\${capture}.js";
            "*.js" = "\${capture}.js.map, \${capture}.min.js, \${capture}.d.ts";
            "*.jsx" = "\${capture}.js";
            "*.tsx" = "\${capture}.ts";
            "tsconfig.json" = "tsconfig.*.json";
            "package.json" = "package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb";
            "*.sqlite" = "\${capture}.\${extname}-*";
            "*.db" = "\${capture}.\${extname}-*";
            "*.sqlite3" = "\${capture}.\${extname}-*";
            "*.db3" = "\${capture}.\${extname}-*";
            "*.sdb" = "\${capture}.\${extname}-*";
            "*.s3db" = "\${capture}.\${extname}-*";
          };
          "extensions.autoCheckUpdates" = false;
          "files.associations" = {
            "*.gohtml" = "html";
          };
          "files.autoSave" = "onFocusChange";
          "formattingToggle.affects" = ["editor.formatOnSave" "editor.formatOnType"];
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.enableCommitSigning" = true;
          "git.enableSmartCommit" = true;
          "git.replaceTagsWhenPull" = true;
          "github.copilot.editor.enableAutoCompletions" = true;
          "github.copilot.enable" = {
            "*" = true;
            "yaml" = false;
            "plaintext" = false;
            "markdown" = true;
            "html" = true;
            "php" = true;
            "vue" = true;
            "javascript" = true;
            "jsonc" = true;
            "python" = true;
          };
          "latex-workshop.intellisense.package.enabled" = true;
          "latex-workshop.latex.tools" = [
            {
              "name" = "latexmk";
              "command" = "latexmk";
              "args" = ["-xelatex" "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "%DOC%"];
            }
          ];
          "latex-workshop.message.badbox.show" = false;
          "latex-workshop.view.pdf.viewer" = "tab";
          "liveServer.settings.CustomBrowser" = "firefox";
          "liveServer.settings.donotShowInfoMsg" = true;
          "liveServer.settings.donotVerifyTags" = true;
          "liveServer.settings.useWebExt" = true;
          "ltex.additionalRules.motherTongue" = "fr";
          "ltex.enabled" = ["bibtex" "context" "context.tex" "latex" "markdown" "org" "restructuredtext" "rsweave"];
          "prettier.printWidth" = 120;
          "prettier.quoteProps" = "consistent";
          "prettier.singleQuote" = false;
          "prettier.tabWidth" = 2;
          "prettier.useTabs" = true;
          "redhat.telemetry.enabled" = false;
          "remote.SSH.connectTimeout" = 1800;
          "remote.SSH.useLocalServer" = false;
          "security.workspace.trust.untrustedFiles" = "open";
          "shellformat.path" = "/home/${config.home.username}/.nix-profile/bin/shfmt";
          "terminal.integrated.defaultProfile.linux" = "zsh";
          "terminal.integrated.enableMultiLinePasteWarning" = "never";
          "terminal.integrated.fontFamily" = "MesloLGS Nerd Font";
          "terminal.integrated.fontSize" = 12;
          "terminal.integrated.profiles.linux" = {
            "bash" = {
              "path" = "bash";
              "icon" = "terminal-bash";
            };
            "zsh" = {
              "path" = "zsh";
            };
            "fish" = {
              "path" = "fish";
            };
            "tmux" = {
              "path" = "tmux";
              "icon" = "terminal-tmux";
            };
            "pwsh" = {
              "path" = "pwsh";
              "icon" = "terminal-powershell";
            };
            "ash" = {
              "path" = "/bin/ash";
            };
            "sh" = {
              "path" = "/bin/sh";
            };
          };
          "terminal.integrated.sendKeybindingsToShell" = true;
          "todo-tree.highlights.enabled" = false;
          "turboConsoleLog.insertEmptyLineAfterLogMessage" = true;
          "turboConsoleLog.insertEmptyLineBeforeLogMessage" = true;
          "turboConsoleLog.wrapLogMessage" = true;
          "workbench.colorTheme" = "Tokyo Night";
          "workbench.editorAssociations" = {
            "*.copilotmd" = "vscode.markdown.preview.editor";
            "*.gohtml" = "html";
            "*.ipynb" = "jupyter-notebook";
            "*.jpeg" = "imagePreview.previewEditor";
            "{git,gitlens,git-graph}:/**/*.{md,csv,svg}" = "default";
            "*.toml" = "toml";
          };
          "workbench.iconTheme" = "vscode-icons";
          "workbench.startupEditor" = "none";
        };

        keybindings = [
          {
            key = "shift+alt+f";
            command = "editor.action.formatDocument";
            when = "editorHasDocumentFormattingProvider && editorTextFocus && !editorReadonly && !inCompositeEditor";
          }
          {
            key = "ctrl+shift+i";
            command = "-editor.action.formatDocument";
            when = "editorHasDocumentFormattingProvider && editorTextFocus && !editorReadonly && !inCompositeEditor";
          }
          {
            key = "ctrl+[BracketRight]";
            command = "workbench.action.terminal.toggleTerminal";
            when = "terminal.active";
          }
          {
            key = "ctrl+shift+[Equal]";
            command = "-workbench.action.terminal.toggleTerminal";
            when = "terminal.active";
          }
          {
            key = "ctrl+shift+up";
            command = "-editor.action.insertCursorAbove";
            when = "editorTextFocus";
          }
          {
            key = "ctrl+shift+down";
            command = "-editor.action.insertCursorBelow";
            when = "editorTextFocus";
          }
          {
            key = "shift+alt+up";
            command = "-editor.action.insertCursorAbove";
            when = "editorTextFocus";
          }
          {
            key = "shift+alt+down";
            command = "-editor.action.insertCursorBelow";
            when = "editorTextFocus";
          }
          {
            key = "shift+alt+down";
            command = "editor.action.copyLinesDownAction";
            when = "editorTextFocus && !editorReadonly";
          }
          {
            key = "ctrl+shift+alt+down";
            command = "-editor.action.copyLinesDownAction";
            when = "editorTextFocus && !editorReadonly";
          }
          {
            key = "shift+alt+up";
            command = "editor.action.copyLinesUpAction";
            when = "editorTextFocus && !editorReadonly";
          }
          {
            key = "ctrl+shift+alt+up";
            command = "-editor.action.copyLinesUpAction";
            when = "editorTextFocus && !editorReadonly";
          }
          {
            key = "ctrl+k ctrl+c";
            command = "-editor.action.addCommentLine";
            when = "editorTextFocus && !editorReadonly";
          }
          {
            key = "ctrl+[Backquote]";
            command = "editor.action.commentLine";
            when = "editorTextFocus && !editorReadonly";
          }
          {
            key = "shift+alt+f";
            command = "editor.action.formatDocument.none";
            when = "editorTextFocus && !editorHasDocumentFormattingProvider && !editorReadonly";
          }
          {
            key = "alt+y";
            command = "bracket-select.undo-select";
            when = "editorTextFocus";
          }
          {
            key = "ctrl+shift+alt+s";
            command = "multiCommand.nixosRebuildSwitch";
          }
          {
            key = "ctrl+shift+alt+a";
            command = "multiCommand.moveTaskTerminalRight";
          }
        ];
      };
    };

    # # enable Wayland support
    # home.sessionVariables.NIXOS_OZONE_WL = "1";

    # # enable vscode-server
    # imports = [
    #   "${
    #     fetchTarball {
    #       url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
    #       sha256 = "09j4kvsxw1d5dvnhbsgih0icbrxqv90nzf0b589rb5z6gnzwjnqf";
    #     }
    #   }/modules/vscode-server/home.nix"
    # ];
    # services.vscode-server.enable = true;
    # services.vscode-server.enableFHS = true;
    # services.vscode-server.installPath = "$HOME/.vscode";
    # services.vscode-server.extraRuntimeDependencies = with pkgs; [
    #   nixd
    #   alejandra
    #   nixpkgs-fmt
    # ];

    # systemd.user.services.code-tunnel = {
    #   Unit = {
    #     Description = "Visual Studio Code Tunnel";
    #     After = ["network.target" "multi-user.target" "nix-deamon.socket"];
    #   };
    #   Service = {
    #     Type = "idle";
    #     Environment = "PATH=${pkgs.lib.makeBinPath [pkgs.vscode pkgs.nixd pkgs.alejandra pkgs.nixpkgs-fmt pkgs.bash pkgs.coreutils]}/bin:/run/current-system/sw/bin";
    #     ExecStart = "${pkgs.vscode}/lib/vscode/bin/code-tunnel --verbose --cli-data-dir ${config.home.homeDirectory}/.vscode/cli tunnel service internal-run";
    #     Restart = "always";
    #     RestartSec = 10;
    #   };
    #   Install = {
    #     WantedBy = ["basic.target"];
    #   };
    # };
  };
}
