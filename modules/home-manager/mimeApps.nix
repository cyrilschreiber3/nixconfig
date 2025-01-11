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
      documentEditor = lib.mkOption {
        type = lib.types.str;
        default = "onlyoffice-desktopeditors.desktop";
        description = "Default document editor";
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
        "application/excel" = cfg.defaultApps.documentEditor;
        "application/html" = cfg.defaultApps.browser;
        "application/json" = cfg.defaultApps.textEditor;
        "application/msword" = cfg.defaultApps.documentEditor;
        "application/octet-stream" = cfg.defaultApps.textEditor;
        "application/pdf" = cfg.defaultApps.documentViewer;
        "application/plain" = cfg.defaultApps.textEditor;
        "application/powerpoint" = cfg.defaultApps.documentEditor;
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = cfg.defaultApps.documentEditor;
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = cfg.defaultApps.documentEditor;
        "application/x-latex" = cfg.defaultApps.textEditor;
        "application/x-shellscript" = cfg.defaultApps.textEditor;
        "application/xml" = cfg.defaultApps.textEditor;
        "audio/flac" = cfg.defaultApps.audioPlayer;
        "audio/mpeg" = cfg.defaultApps.audioPlayer;
        "audio/mpeg3" = cfg.defaultApps.audioPlayer;
        "audio/ogg" = cfg.defaultApps.audioPlayer;
        "audio/wav" = cfg.defaultApps.audioPlayer;
        "audio/x-matroska" = cfg.defaultApps.audioPlayer;
        "image/bmp" = cfg.defaultApps.imageViewer;
        "image/gif" = cfg.defaultApps.imageViewer;
        "image/jpeg" = cfg.defaultApps.imageViewer;
        "image/png" = cfg.defaultApps.imageViewer;
        "image/svg+xml" = cfg.defaultApps.imageViewer;
        "image/tiff" = cfg.defaultApps.imageViewer;
        "image/webp" = cfg.defaultApps.imageViewer;
        "image/x-adobe-dng" = cfg.defaultApps.imageViewer;
        "image/x-canon-cr2" = cfg.defaultApps.imageViewer;
        "image/x-panasonic-rw2" = cfg.defaultApps.imageViewer;
        "text/css" = cfg.defaultApps.textEditor;
        "text/csv" = cfg.defaultApps.documentEditor;
        "text/html" = cfg.defaultApps.browser;
        "text/plain" = cfg.defaultApps.textEditor;
        "text/xml" = cfg.defaultApps.textEditor;
        "video/avi" = cfg.defaultApps.videoPlayer;
        "video/mpeg" = cfg.defaultApps.videoPlayer;
        "video/mp4" = cfg.defaultApps.videoPlayer;
        "video/ogg" = cfg.defaultApps.videoPlayer;
        "video/quicktime" = cfg.defaultApps.videoPlayer;
        "video/webm" = cfg.defaultApps.videoPlayer;
        "video/x-matroska" = cfg.defaultApps.videoPlayer;
        "x-scheme-handler/http" = cfg.defaultApps.browser;
        "x-scheme-handler/https" = cfg.defaultApps.browser;
      }
      overrideSet
    ];
  };
}
