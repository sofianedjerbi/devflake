{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myStarship;
in {
  options.myStarship = {
    enable = mkEnableOption "Starship prompt";
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = {
        # Basic configuration
        add_newline = true;
        scan_timeout = 10;
        command_timeout = 1000;
        
        # Main prompt format - simplified elegant design
        format = ''
          $directory$git_branch$git_status$character'';
        
        # Individual component styling
        directory = {
          style = "bold cyan";
          truncation_length = 3;
          truncate_to_repo = true;
          truncation_symbol = "…/";
          read_only = " 🔒";
          home_symbol = "🏠";
          format = "[$home_symbol $path]($style) ";
        };
        
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✗](bold red)";
          vimcmd_symbol = "[V](bold green)";
        };
        
        git_branch = {
          symbol = "🌱 ";
          style = "bold purple";
          format = "[$symbol$branch]($style) ";
        };
        
        git_status = {
          style = "bold red";
          format = "[\\[$all_status$ahead_behind\\]]($style) ";
          modified = "M";
          staged = "S";
          untracked = "?";
          deleted = "D";
          renamed = "R";
          stashed = "≡";
          ahead = "A";
          behind = "B";
          diverged = "AB";
          conflicted = "C";
          up_to_date = "✓";
        };
        
        cmd_duration = {
          min_time = 2000;
          format = "[⏱️ $duration](yellow) ";
          disabled = false;
        };
      };
    };
  };
} 