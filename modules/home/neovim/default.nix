{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myNeovim;
in {
  options.myNeovim = {
    enable = mkEnableOption "Enable custom Neovim configuration";
    
    defaultEditor = mkOption {
      type = types.bool;
      default = true;
      description = "Set Neovim as the default editor";
    };
    
    fontSize = mkOption {
      type = types.int;
      default = 12;
      description = "Font size for GUI clients";
    };
    
    plugins = mkOption {
      type = types.listOf types.str;
      default = [ "telescope" "lsp" "treesitter" "completion" "theme" "statusline" ];
      description = "List of plugins to enable";
    };
    
    theme = mkOption {
      type = types.str;
      default = "tokyonight";
      description = "Colorscheme to use";
    };
    
    userConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional custom Neovim configuration in Lua";
    };
  };

  config = mkIf cfg.enable {
    # Set Neovim as default editor if requested
    home.sessionVariables = mkIf cfg.defaultEditor {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    
    # Basic Neovim configuration
    programs.neovim = {
      enable = true;
      defaultEditor = cfg.defaultEditor;
      
      # Packages needed for our configuration
      extraPackages = with pkgs; [
        # Core dependencies
        (lib.mkIf (builtins.elem "lsp" cfg.plugins) nil)                           # Nix LSP
        (lib.mkIf (builtins.elem "lsp" cfg.plugins) nodePackages.typescript-language-server) # TypeScript LSP
        
        # Core utilities for Telescope and other plugins
        (lib.mkIf (builtins.elem "telescope" cfg.plugins) ripgrep)                 # Fast grep for telescope
        (lib.mkIf (builtins.elem "telescope" cfg.plugins) fd)                      # Fast find for telescope
      ];
      
      plugins = with pkgs.vimPlugins; [
        # Core plugins - always enabled
        plenary-nvim
        which-key-nvim
        
        # Conditional plugins based on the plugins list
        (lib.mkIf (builtins.elem "theme" cfg.plugins && cfg.theme == "tokyonight") tokyonight-nvim)
        (lib.mkIf (builtins.elem "theme" cfg.plugins && cfg.theme == "catppuccin") catppuccin-nvim)
        (lib.mkIf (builtins.elem "statusline" cfg.plugins) lualine-nvim)
        (lib.mkIf (builtins.elem "telescope" cfg.plugins) telescope-nvim)
        (lib.mkIf (builtins.elem "treesitter" cfg.plugins) {
          plugin = nvim-treesitter;
          type = "lua";
          # Install treesitter with all grammars with Nix
          config = ''
            require('nvim-treesitter.configs').setup {
              ensure_installed = { "lua", "nix", "typescript", "javascript" },
              highlight = { enable = true },
              -- Use a local parser directory in the XDG cache directory
              parser_install_dir = vim.fn.stdpath('cache') .. '/treesitter',
            }
            -- Add the custom parser installation path to runtimepath
            vim.opt.runtimepath:append(vim.fn.stdpath('cache') .. '/treesitter')
          '';
        })
        (lib.mkIf (builtins.elem "lsp" cfg.plugins) nvim-lspconfig)
        (lib.mkIf (builtins.elem "completion" cfg.plugins) nvim-cmp)
        (lib.mkIf (builtins.elem "completion" cfg.plugins) cmp-nvim-lsp)
        (lib.mkIf (builtins.elem "completion" cfg.plugins) cmp-buffer)
        (lib.mkIf (builtins.elem "completion" cfg.plugins) cmp-path)
        (lib.mkIf (builtins.elem "autopairs" cfg.plugins) nvim-autopairs)
        (lib.mkIf (builtins.elem "git" cfg.plugins) gitsigns-nvim)
        (lib.mkIf (builtins.elem "explorer" cfg.plugins) nvim-tree-lua)
      ];
      
      extraLuaConfig = ''
        -- Basic settings
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.expandtab = true
        vim.opt.shiftwidth = 2
        vim.opt.tabstop = 2
        vim.opt.smartindent = true
        vim.opt.termguicolors = true
        vim.opt.mouse = 'a'
        vim.opt.clipboard = 'unnamedplus'
        vim.opt.undofile = true
        vim.g.mapleader = ' '
        
        -- Basic keymaps
        vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
        vim.keymap.set('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })
        
        ${lib.optionalString (builtins.elem "theme" cfg.plugins) ''
        -- Theme configuration
        ${if cfg.theme == "catppuccin" then ''
        require('catppuccin').setup({
          flavour = "mocha", -- latte, frappe, macchiato, mocha
          term_colors = true,
          transparent_background = false,
          no_italic = false,
          no_bold = false,
          styles = {
            comments = { "italic" },
            conditionals = { "italic" },
            loops = {},
            functions = {},
            keywords = {},
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = {},
            types = {},
            operators = {}
          },
          integrations = {
            cmp = true,
            gitsigns = true,
            telescope = true,
            which_key = true,
            treesitter = true
          }
        })
        '' else ""}
        vim.cmd('colorscheme ${cfg.theme}')
        ''}
        
        ${lib.optionalString (builtins.elem "statusline" cfg.plugins) ''
        -- Status line
        require('lualine').setup {
          options = {
            icons_enabled = true,
            theme = '${if cfg.theme == "catppuccin" then "catppuccin" else cfg.theme}',
            component_separators = "",
            section_separators = ""
          }
        }
        ''}
        
        ${lib.optionalString (builtins.elem "telescope" cfg.plugins) ''
        -- Telescope
        require('telescope').setup{}
        vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find Files' })
        vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Find Text' })
        ''}
        
        ${lib.optionalString (builtins.elem "lsp" cfg.plugins) ''
        -- LSP Configuration
        local lspconfig = require('lspconfig')
        
        -- Basic keymaps for LSP
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to Definition' })
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation' })
        vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { desc = 'Rename Symbol' })
        
        -- Setup for specific LSPs
        lspconfig.nil_ls.setup{}
        
        -- Use typescript-language-server instead of deprecated tsserver
        lspconfig.typescript_language_server.setup{
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }
        }
        ''}
        
        ${lib.optionalString (builtins.elem "completion" cfg.plugins) ''
        -- Completion
        local cmp = require('cmp')
        cmp.setup {
          mapping = cmp.mapping.preset.insert({
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm({ select = true })
          }),
          sources = {
            { name = 'nvim_lsp' },
            { name = 'buffer' },
            { name = 'path' }
          }
        }
        ''}
        
        ${lib.optionalString (builtins.elem "autopairs" cfg.plugins) ''
        -- Auto pairs
        require('nvim-autopairs').setup{}
        ''}
        
        ${lib.optionalString (builtins.elem "git" cfg.plugins) ''
        -- Git signs
        require('gitsigns').setup{}
        ''}
        
        ${lib.optionalString (builtins.elem "explorer" cfg.plugins) ''
        -- File Explorer
        require('nvim-tree').setup{}
        vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle Explorer' })
        ''}
        
        -- User config
        ${cfg.userConfig}
      '';
    };
  };
} 