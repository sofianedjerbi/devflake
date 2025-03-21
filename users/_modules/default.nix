{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    # Import the Neovim module
    ../../modules/home/neovim
  ];

  # === Common Home Manager settings for all users ============================
  home = {
    stateVersion = "24.11";
    
    packages = with pkgs; [
      brave
      catppuccin-cursors
      psmisc
    ];
    
    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      SHELL = "${pkgs.zsh}/bin/zsh";
      XDG_SESSION_TYPE = "wayland";
    };
  };
  
  # Set a reasonable font configuration
  fonts.fontconfig.enable = true;

  # XDG base directory specification
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # Catppuccin theme
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };

  # Default program associations
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = [ "nvim.desktop" ];
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "image/png" = [ "imv.desktop" ];
      "image/jpeg" = [ "imv.desktop" ];
    };
  };

  # Common shell configuration
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -lah";
      update = "sudo nixos-rebuild switch";
      home-update = "home-manager switch";
    };
  };

  # Common zsh configuration (if user enables it)
  programs.zsh = {
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -lah";
      update = "sudo nixos-rebuild switch";
      home-update = "home-manager switch";
    };
  };
  
  # Common git configuration (user info set by each user)
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

  # Common terminal tools
  programs.bat = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  # Common SSH configuration
  programs.ssh = {
    enable = true;
    compression = true;
    controlMaster = "auto";
    controlPersist = "10m";
  };

  # Common cursor and icon themes
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    x11.enable = true;
  };

  # GTK theme
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

  # File manager configuration - using Yazi (terminal-based)
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

  # Silence Home Manager news
  news.display = "silent";

  # Enable Neovim with our custom configuration for all users
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