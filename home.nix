{ config, pkgs, lib, username ? "sofiane", ... }: 

let
  # Define common values to avoid repetition and enable easier changes
  userFullName = "Sofiane Djerbi";
  userEmail = "contact@sofianedjerbi.com";
  homeDir = "/home/${username}";
in {
  imports = [
    ./modules/home/hyprland
  ];

  # === Hyprland Configuration ================================================
  myHyprland = {
    enable = true;
    wallpaper = ./resources/wallpapers/neon.jpg; # Changed to path reference
    terminal = "kitty";
    launcher = "fuzzel";
  };

  # === Home Manager Configuration ============================================
  home = {
    inherit username;
    homeDirectory = homeDir;
    stateVersion = "24.11"; # Do not change after initial setup
    
    # === Essential Packages ===================================================
    packages = with pkgs; [
      # Terminal Utilities
      neofetch
      neovim
      zsh
      git
      htop
      bat
      fzf
      ripgrep
      jq
      wget
      curl
      tree

      # Applications
      code-cursor
      brave
      spotify
    ];
    
    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      SHELL = "${pkgs.zsh}/bin/zsh";
      XDG_SESSION_TYPE = "wayland";
    };
  };

  # === Program Configurations ================================================
  
  # --- Shell Configuration ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -lah";
      update = "sudo nixos-rebuild switch";
      home-update = "home-manager switch";
    };
  };

  # --- Git Configuration ---
  programs.git = {
    enable = true;
    userName = userFullName;
    userEmail = userEmail;
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

  # --- Terminal Prompt ---
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "$username@$hostname $directory $git_branch $character";
      username = { show_always = true; };
      directory = { truncate_to_repo = false; };
      git_branch = { symbol = "🌱 "; };
    };
  };

  # --- Better Tools ---
  programs.bat = {
    enable = true;
    config = { theme = "Dracula"; };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
