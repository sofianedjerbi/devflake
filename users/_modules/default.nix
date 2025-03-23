{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ../../modules/home/neovim
    ../../modules/desktop
  ];

  # Core Home Manager settings
  home = {
    stateVersion = "24.11";
    
    packages = with pkgs; [
      brave
      catppuccin-cursors
      psmisc
    ];
    
    sessionVariables = {
      EDITOR = "nvim";
      SHELL = "${pkgs.zsh}/bin/zsh";
      XDG_SESSION_TYPE = "wayland";
    };
  };
  
  # Font configuration
  fonts.fontconfig.enable = true;

  # XDG directories
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # Theme configuration
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };

  # Default applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = [ "nvim.desktop" ];
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "image/png" = [ "imv.desktop" ];
      "image/jpeg" = [ "imv.desktop" ];
    };
  };

  # Shell configurations
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -lah";
      update = "sudo nixos-rebuild switch";
      home-update = "home-manager switch";
    };
  };

  programs.zsh = {
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -lah";
      update = "sudo nixos-rebuild switch";
      home-update = "home-manager switch";
    };
  };
  
  # Git configuration (user info set in user configs)
  programs.git = {
    enable = true;
    aliases = {
      co = "checkout";
      ci = "commit";
      st = "status";
      br = "branch";
      hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  # CLI utilities
  programs.bat = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  # SSH configuration
  programs.ssh = {
    enable = true;
    compression = true;
    controlMaster = "auto";
    controlPersist = "10m";
  };

  # Cursor and UI themes
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # File manager
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      manager = {
        show_hidden = false;
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
      };
      preview = {
        max_width = 3072;
        max_height = 2048;
      };
    };
  };

  # Disable Home Manager news
  news.display = "silent";

  # Neovim configuration
  myNeovim = {
    enable = true;
    defaultEditor = true;
    fontSize = 13;
    plugins = [
      "telescope" "lsp" "treesitter" "completion" 
      "autopairs" "git" "theme" "statusline" "explorer"
    ];
  };
} 