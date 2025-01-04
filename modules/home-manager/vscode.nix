{
  inputs,
  config,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;

    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-marketplace; [
      # utilities
      formulahendry.auto-close-tag
      formulahendry.auto-rename-tag
      aaron-bond.better-comments
      ryuta46.multi-command
      chunsen.bracket-select
      tombonnike.vscode-status-bar-format-toggle
      esbenp.prettier-vscode
      ritwickdey.liveserver
      rangav.vscode-thunder-client
      shardulm94.trailing-spaces

      # theme
      enkia.tokyo-night
      vscode-icons-team.vscode-icons

      # remote
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit

      # Copilot
      github.copilot
      github.copilot-chat

      # languages

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

      # HTML
      adrianwilczynski.format-selection-as-html
      ecmel.vscode-html-css
      zignd.html-css-class-completion

      # Json
      zainchen.json

      # Nix
      jnoortheen.nix-ide

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

      # Vue
      vue.volar
      vue.vscode-typescript-vue-plugin

      # XML
      dotjoshjohnson.xml

      # YAML
      redhat.vscode-yaml
    ];

    userSettings = {
      "explorer.confirmDragAndDrop" = false;
      "explorer.confirmDelete" = false;
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
      "files.autoSave" = "onFocusChange";
      "workbench.editorAssociations" = {
        "*.copilotmd" = "vscode.markdown.preview.editor";
        "*.ipynb" = "jupyter-notebook";
        "*.jpeg" = "imagePreview.previewEditor";
        "{git,gitlens,git-graph}:/**/*.{md,csv,svg}" = "default";
      };
      "workbench.colorTheme" = "Tokyo Night";
      "workbench.iconTheme" = "vscode-icons";
      "editor.formatOnPaste" = false;
      "editor.formatOnSave" = true;
      "editor.formatOnType" = true;
      "editor.inlineSuggest.enabled" = true;
      "editor.fontFamily" = "MesloLGS Nerd Font";
      "editor.fontLigatures" = false;
      "editor.linkedEditing" = true;
      "editor.minimap.enabled" = true;
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "terminal.integrated.sendKeybindingsToShell" = true;
      "terminal.integrated.fontFamily" = "MesloLGS Nerd Font";
      "terminal.integrated.fontSize" = 12;
      "terminal.integrated.defaultProfile.linux" = "zsh";
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
      "security.workspace.trust.untrustedFiles" = "open";
      "diffEditor.ignoreTrimWhitespace" = false;
      "git.enableCommitSigning" = true;
      "git.replaceTagsWhenPull" = true;
      "git.confirmSync" = false;
      "git.autofetch" = true;
      "git.enableSmartCommit" = true;
      "formattingToggle.affects" = ["editor.formatOnSave" "editor.formatOnType"];
      "prettier.printWidth" = 120;
      "prettier.tabWidth" = 2;
      "prettier.useTabs" = true;
      "prettier.singleQuote" = false;
      "[vue]" = {
        "editor.defaultFormatter" = "Vue.volar";
      };
      "[powershell]" = {
        "editor.defaultFormatter" = "ms-vscode.powershell";
      };
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
      "remote.SSH.useLocalServer" = false;
      "remote.SSH.connectTimeout" = 1800;
      "liveServer.settings.donotVerifyTags" = true;
      "liveServer.settings.useWebExt" = true;
      "liveServer.settings.donotShowInfoMsg" = true;
      "liveServer.settings.CustomBrowser" = "chromium";
      "redhat.telemetry.enabled" = false;
      "turboConsoleLog.insertEmptyLineAfterLogMessage" = true;
      "turboConsoleLog.insertEmptyLineBeforeLogMessage" = true;
      "turboConsoleLog.wrapLogMessage" = true;
      "latex-workshop.intellisense.package.enabled" = true;
      "latex-workshop.view.pdf.viewer" = "tab";
      "latex-workshop.message.badbox.show" = false;
      "latex-workshop.latex.tools" = [
        {
          "name" = "latexmk";
          "command" = "latexmk";
          "args" = ["-xelatex" "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "%DOC%"];
        }
      ];
      "ltex.additionalRules.motherTongue" = "fr";
      "ltex.enabled" = ["bibtex" "context" "context.tex" "latex" "markdown" "org" "restructuredtext" "rsweave"];
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
        key = "ctrl+shift+alt+s";
        command = "multiCommand.nixosRebuildSwitch";
      }
      {
        key = "ctrl+shift+alt+a";
        command = "multiCommand.moveTaskTerminalRight";
      }
    ];
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
}
