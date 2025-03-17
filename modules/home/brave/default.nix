{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.myBrave;
in {
  options.myBrave = {
    enable = mkEnableOption "Enable Brave browser";
    
    extensions = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of extension IDs to install";
    };
  };
  
  config = mkIf cfg.enable {
    programs.brave = {
      enable = true;
      extensions = cfg.extensions;
    };
    
    # Set as default browser
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "brave-browser.desktop";
        "x-scheme-handler/http" = "brave-browser.desktop";
        "x-scheme-handler/https" = "brave-browser.desktop";
      };
    };
    
    # Create a standard desktop entry for Brave
    xdg.desktopEntries.brave-browser = {
      name = "Brave Web Browser";
      exec = "brave";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
    };
  };
} 
