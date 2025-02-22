{ config, pkgs, ... }: {

  # === Home Manager Configuration ============================================
  home.username = "sofiane";
  home.homeDirectory = "/home/sofiane";
  home.stateVersion = "24.11";

  # === Essential Packages ===================================================
  home.packages = with pkgs; [
    # Terminal Tools
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

    # Dev Tools
    # None! Use dev containers or project flakes
    #gcc
    #python3
    #nodejs
  ];

  # === Enable Zsh ===========================================================
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -lah";
    };
  };

  # === Git Configuration ====================================================
  programs.git = {
    enable = true;
    userName = "Sofiane Djerbi";
    userEmail = "contact@sofianedjerbi.com";
    aliases = {
      co = "checkout";
      ci = "commit";
      st = "status";
    };
  };

  # === Starship Prompt ======================================================
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

  # === Bat (Better `cat`) ===================================================
  programs.bat = {
    enable = true;
    config = { theme = "Dracula"; };
  };

  # === FZF (Fuzzy Finder) ===================================================
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # === Home Manager Finishing ===============================================
  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "${pkgs.zsh}/bin/zsh";
    XDG_SESSION_TYPE = "wayland";
  };
}
