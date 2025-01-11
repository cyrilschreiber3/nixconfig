{
  config,
  lib,
  ...
}: let
  cfg = config.mimeApps;

  # Convert the override list to an attrset
  overrideSet =
    lib.foldl (
      acc: override:
        acc // {"${override.mimeType}" = override.application;}
    ) {}
    cfg.override;
in {
  options.mimeApps = {
    enable = lib.mkEnableOption "Enable mimeApps module";

    defaultApps = {
      audioPlayer = lib.mkOption {
        type = lib.types.str;
        default = "vlc.desktop";
        description = "Default audio player";
      };
      browser = lib.mkOption {
        type = lib.types.str;
        default = "firefox.desktop";
        description = "Default browser";
      };
      documentViewer = lib.mkOption {
        type = lib.types.str;
        default = "xreader.desktop";
        description = "Default document viewer";
      };
      imageViewer = lib.mkOption {
        type = lib.types.str;
        default = "pix.desktop";
        description = "Default image viewer";
      };
      textEditor = lib.mkOption {
        type = lib.types.str;
        default = "org.x.editor.desktop";
        description = "Default text editor";
      };
      videoPlayer = lib.mkOption {
        type = lib.types.str;
        default = "vlc.desktop";
        description = "Default video player";
      };
    };

    override = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.str);
      default = [];
      description = "Override default applications";
      example = lib.literalExpression ''
        [
          {
            mimeType = "application/pdf";
            application = "org.x.pdfviewer.desktop";
          }
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.mimeApps.enable = true;
    xdg.mimeApps.defaultApplications = lib.mkMerge [
      {
        "application/octet-stream" = cfg.defaultApps.textEditor;
        "application/pdf" = cfg.defaultApps.documentViewer;
        "application/x-shellscript" = cfg.defaultApps.textEditor;
        "image/jpg" = cfg.defaultApps.imageViewer;
        "image/png" = cfg.defaultApps.imageViewer;
        "image/x-adobe-dng" = cfg.defaultApps.imageViewer;
        "image/x-canon-cr2" = cfg.defaultApps.imageViewer;
        "image/x-panasonic-rw2" = cfg.defaultApps.imageViewer;
        "text/plain" = cfg.defaultApps.textEditor;
        "video/mp4" = cfg.defaultApps.videoPlayer;
        "x-scheme-handler/http" = cfg.defaultApps.browser;
        "x-scheme-handler/https" = cfg.defaultApps.browser;
      }
      overrideSet
    ];
  };
}
