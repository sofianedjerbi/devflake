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

    userConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional custom Neovim configuration in Lua";
      example = ''
        -- Example custom configuration
        vim.opt.relativenumber = true
      '';
    };
    
    plugins = mkOption {
      type = types.listOf types.str;
      default = [
        "telescope" "lsp" "treesitter" "completion" 
        "autopairs" "git" "theme" "statusline"
      ];
      description = "List of plugin groups to enable";
    };
    
    theme = mkOption {
      type = types.str;
      default = "catppuccin";
      description = "Colorscheme to use";
      example = "tokyonight";
    };
    
    fontSize = mkOption {
      type = types.int;
      default = 12;
      description = "Font size for Neovim";
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
      viAlias = true;
      vimAlias = true;
      withNodeJs = true; # Required for Copilot and some LSP servers
      withPython3 = true; # Required for some plugins
      
      extraPackages = with pkgs; [
        # Languages and LSP servers
        nodePackages.typescript
        nodePackages.typescript-language-server
        gopls
        rust-analyzer
        lua-language-server
        nil # Nix language server
        nodePackages.bash-language-server
        
        # Tools used by plugins
        ripgrep # Required for Telescope
        fd # Required for Telescope
        tree-sitter # Required for Treesitter
      ];
      
      plugins = with pkgs.vimPlugins; (
        # Base plugins always included
        [
          # Plugin manager
          lazy-nvim
        ]
      );

      # Create a custom init.lua with sensible defaults and our plugins
      extraLuaConfig = ''
        -- Basic Options
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.mouse = 'a'
        vim.opt.clipboard = 'unnamedplus'
        vim.opt.breakindent = true
        vim.opt.undofile = true
        vim.opt.ignorecase = true
        vim.opt.smartcase = true
        vim.opt.signcolumn = 'yes'
        vim.opt.updatetime = 250
        vim.opt.timeoutlen = 300
        vim.opt.splitright = true
        vim.opt.splitbelow = true
        vim.opt.list = true
        vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
        vim.opt.inccommand = 'split'
        vim.opt.cursorline = true
        vim.opt.scrolloff = 10
        vim.opt.hlsearch = true
        vim.opt.termguicolors = true
        vim.opt.guifont = 'monospace:h${toString cfg.fontSize}'
        
        -- Better tabs
        vim.opt.tabstop = 2
        vim.opt.softtabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.expandtab = true
        
        -- Use space as leader key
        vim.g.mapleader = ' '
        vim.g.maplocalleader = ' '
        
        -- Keymaps
        vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
        
        -- Better window navigation
        vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
        vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
        vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
        vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })
        
        -- Buffer navigation
        vim.keymap.set('n', '<S-h>', ':bprevious<CR>', { desc = 'Previous buffer' })
        vim.keymap.set('n', '<S-l>', ':bnext<CR>', { desc = 'Next buffer' })
        
        -- Move lines in visual mode
        vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
        vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
        
        -- Clear search with <Esc>
        vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
        
        -- Diagnostics
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic error messages' })
        vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix list' })
        
        -- Bootstrap lazy.nvim 
        local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
        if not vim.loop.fs_stat(lazypath) then
          vim.fn.system({
            'git',
            'clone',
            '--filter=blob:none',
            'https://github.com/folke/lazy.nvim.git',
            '--branch=stable',
            lazypath,
          })
        end
        vim.opt.rtp:prepend(lazypath)
        
        -- Plugins
        require('lazy').setup({
          -- Theme/Appearance
          ${lib.optionalString (elem "theme" cfg.plugins) ''
          {
            'catppuccin/nvim',
            name = 'catppuccin',
            priority = 1000,
            config = function()
              require('catppuccin').setup({
                flavour = 'mocha',
                background = {
                  light = 'latte',
                  dark = 'mocha',
                },
                styles = {
                  comments = { 'italic' },
                  conditionals = { 'italic' },
                  loops = {},
                  functions = {},
                  keywords = {},
                  strings = {},
                  variables = {},
                  numbers = {},
                  booleans = {},
                  properties = {},
                  types = {},
                  operators = {},
                },
                integrations = {
                  cmp = true,
                  gitsigns = true,
                  nvimtree = true,
                  telescope = true,
                  which_key = true,
                },
              })
              vim.cmd.colorscheme('${cfg.theme}')
            end,
          },
          ''}
          
          -- Statusline
          ${lib.optionalString (elem "statusline" cfg.plugins) ''
          {
            'nvim-lualine/lualine.nvim',
            event = "VeryLazy",
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            opts = {
              options = {
                theme = '${cfg.theme}',
                component_separators = '|',
                section_separators = { left = "", right = "" },
              },
              sections = {
                lualine_a = {'mode'},
                lualine_b = {'branch', 'diff', 'diagnostics'},
                lualine_c = {'filename'},
                lualine_x = {'encoding', 'fileformat', 'filetype'},
                lualine_y = {'progress'},
                lualine_z = {'location'}
              },
            },
          },
          ''}
          
          -- File explorer
          ${lib.optionalString (elem "explorer" cfg.plugins) ''
          {
            'nvim-neo-tree/neo-tree.nvim',
            branch = 'v3.x',
            dependencies = {
              'nvim-lua/plenary.nvim',
              'nvim-tree/nvim-web-devicons',
              'MunifTanjim/nui.nvim',
            },
            config = function()
              require('neo-tree').setup {
                close_if_last_window = true,
                filesystem = {
                  follow_current_file = {
                    enabled = true,
                  },
                  use_libuv_file_watcher = true,
                },
              }
              vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Toggle Explorer' })
              vim.keymap.set('n', '<leader>o', '<cmd>Neotree focus<CR>', { desc = 'Focus Explorer' })
            end,
          },
          ''}
          
          -- Telescope (Fuzzy finder)
          ${lib.optionalString (elem "telescope" cfg.plugins) ''
          {
            'nvim-telescope/telescope.nvim',
            branch = '0.1.x',
            dependencies = { 
              'nvim-lua/plenary.nvim',
              {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
              }
            },
            config = function()
              local telescope = require('telescope')
              local actions = require('telescope.actions')
              
              telescope.setup({
                defaults = {
                  path_display = { 'truncate' },
                  sorting_strategy = 'ascending',
                  layout_config = {
                    horizontal = {
                      prompt_position = 'top',
                      preview_width = 0.55,
                    },
                    vertical = {
                      mirror = false,
                    },
                    width = 0.87,
                    height = 0.80,
                    preview_cutoff = 120,
                  },
                  mappings = {
                    i = {
                      ['<C-k>'] = actions.move_selection_previous,
                      ['<C-j>'] = actions.move_selection_next,
                      ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
                    }
                  }
                }
              })
              telescope.load_extension('fzf')
              
              -- Keymaps
              local builtin = require('telescope.builtin')
              vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
              vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find by Grep' })
              vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find Buffers' })
              vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find Help' })
              vim.keymap.set('n', '<leader>fs', builtin.current_buffer_fuzzy_find, { desc = 'Find in Current Buffer' })
              vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Find Recent Files' })
              vim.keymap.set('n', '<leader>fc', builtin.grep_string, { desc = 'Find Word Under Cursor' })
              vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Find Diagnostics' })
              vim.keymap.set('n', '<leader>/', function()
                builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                  winblend = 10,
                  previewer = false,
                })
              end, { desc = 'Search in Current Buffer' })
            end,
          },
          ''}
          
          -- Treesitter (Syntax highlighting)
          ${lib.optionalString (elem "treesitter" cfg.plugins) ''
          {
            'nvim-treesitter/nvim-treesitter',
            build = ':TSUpdate',
            event = { 'BufReadPost', 'BufNewFile' },
            dependencies = {
              'nvim-treesitter/nvim-treesitter-textobjects',
            },
            config = function()
              require('nvim-treesitter.configs').setup({
                highlight = { enable = true },
                indent = { enable = true },
                ensure_installed = {
                  'bash',
                  'c',
                  'cpp',
                  'go',
                  'javascript',
                  'json',
                  'lua',
                  'luadoc',
                  'markdown',
                  'markdown_inline',
                  'nix',
                  'python',
                  'regex',
                  'tsx',
                  'typescript',
                  'vim',
                  'vimdoc',
                  'yaml',
                },
                textobjects = {
                  select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                      ['af'] = '@function.outer',
                      ['if'] = '@function.inner',
                      ['ac'] = '@class.outer',
                      ['ic'] = '@class.inner',
                    },
                  },
                },
              })
            end,
          },
          ''}
          
          -- LSP Configuration
          ${lib.optionalString (elem "lsp" cfg.plugins) ''
          {
            'neovim/nvim-lspconfig',
            dependencies = {
              'williamboman/mason.nvim',
              'williamboman/mason-lspconfig.nvim',
              'hrsh7th/cmp-nvim-lsp',
              'folke/neodev.nvim', -- For Lua LSP config
            },
            config = function()
              -- Neodev setup (must be called before lspconfig)
              require('neodev').setup()
              
              -- Mason setup
              require('mason').setup()
              require('mason-lspconfig').setup({
                ensure_installed = {
                  'lua_ls',
                  'tsserver',
                  'bashls',
                  'gopls',
                  'rust_analyzer',
                  'pyright',
                  'nil_ls', -- Nix language server
                },
                automatic_installation = true,
              })
              
              -- LSP Configuration
              local capabilities = require('cmp_nvim_lsp').default_capabilities()
              local lspconfig = require('lspconfig')
              
              -- Global mappings
              vim.keymap.set('n', '<leader>ll', vim.lsp.buf.format, { desc = 'Format current buffer' })
              
              -- Use LspAttach autocommand to configure servers after they attach
              vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('UserLspConfig', {}),
                callback = function(ev)
                  local bufnr = ev.buf
                  local client = vim.lsp.get_client_by_id(ev.data.client_id)
                  
                  -- Buffer local mappings
                  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = bufnr, desc = 'Go to Declaration' })
                  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr, desc = 'Go to Definition' })
                  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = 'Hover Documentation' })
                  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr, desc = 'Go to Implementation' })
                  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = bufnr, desc = 'Signature Help' })
                  vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, { buffer = bufnr, desc = 'Rename Symbol' })
                  vim.keymap.set({ 'n', 'v' }, '<leader>la', vim.lsp.buf.code_action, { buffer = bufnr, desc = 'Code Actions' })
                  vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = bufnr, desc = 'References' })
                  
                  -- Create a command `:Format` local to the LSP buffer
                  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
                    vim.lsp.buf.format({
                      filter = function(client)
                        -- Only use null-ls for formatting instead of LSP server
                        return client.name == "null-ls"
                      end,
                      bufnr = bufnr,
                    })
                  end, { desc = 'Format current buffer with LSP' })
                end,
              })
              
              -- Configure servers
              lspconfig.lua_ls.setup({
                capabilities = capabilities,
                settings = {
                  Lua = {
                    diagnostics = {
                      globals = { 'vim', 'use' },
                    },
                    workspace = {
                      library = vim.api.nvim_get_runtime_file("", true),
                      checkThirdParty = false,
                    },
                    telemetry = { enable = false },
                  },
                },
              })
              
              lspconfig.nil_ls.setup({
                capabilities = capabilities,
                settings = {
                  ['nil'] = {
                    formatting = {
                      command = { "nixpkgs-fmt" },
                    },
                  },
                },
              })
              
              -- Set up all other servers without custom settings
              for _, server in ipairs({
                'tsserver', 'bashls', 'gopls', 'rust_analyzer', 'pyright'
              }) do 
                lspconfig[server].setup({
                  capabilities = capabilities,
                })
              end
            end,
          },
          ''}
          
          -- Completion
          ${lib.optionalString (elem "completion" cfg.plugins) ''
          {
            'hrsh7th/nvim-cmp',
            dependencies = {
              'hrsh7th/cmp-buffer',
              'hrsh7th/cmp-path',
              'hrsh7th/cmp-nvim-lsp',
              'hrsh7th/cmp-nvim-lua',
              'saadparwaiz1/cmp_luasnip',
              'L3MON4D3/LuaSnip',
              'rafamadriz/friendly-snippets',
            },
            config = function()
              local cmp = require('cmp')
              local luasnip = require('luasnip')
              
              require('luasnip.loaders.from_vscode').lazy_load()
              luasnip.config.setup {}
              
              cmp.setup({
                snippet = {
                  expand = function(args)
                    luasnip.lsp_expand(args.body)
                  end,
                },
                mapping = cmp.mapping.preset.insert({
                  ['<C-n>'] = cmp.mapping.select_next_item(),
                  ['<C-p>'] = cmp.mapping.select_prev_item(),
                  ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                  ['<C-f>'] = cmp.mapping.scroll_docs(4),
                  ['<C-Space>'] = cmp.mapping.complete {},
                  ['<CR>'] = cmp.mapping.confirm {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                  },
                  ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                      luasnip.expand_or_jump()
                    else
                      fallback()
                    end
                  end, { 'i', 's' }),
                  ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                      luasnip.jump(-1)
                    else
                      fallback()
                    end
                  end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                  { name = 'nvim_lsp' },
                  { name = 'nvim_lua' },
                  { name = 'luasnip' },
                  { name = 'path' },
                }, {
                  { name = 'buffer' },
                }),
                formatting = {
                  format = function(_, vim_item)
                    vim_item.kind = string.format('%s', vim_item.kind)
                    return vim_item
                  end
                },
                experimental = {
                  ghost_text = {
                    hl_group = "Comment",
                  },
                },
              })
            end,
          },
          ''}
          
          -- Auto pairs
          ${lib.optionalString (elem "autopairs" cfg.plugins) ''
          {
            'windwp/nvim-autopairs',
            event = "InsertEnter",
            config = function()
              require('nvim-autopairs').setup({
                check_ts = true,
                ts_config = {
                  lua = {'string'},
                  javascript = {'template_string'},
                  java = false,
                },
                disable_filetype = { "TelescopePrompt", "vim" },
              })
              
              -- Make autopairs and completion work together
              local cmp_autopairs = require('nvim-autopairs.completion.cmp')
              local cmp = require('cmp')
              cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
            end,
          },
          ''}
          
          -- Git integration
          ${lib.optionalString (elem "git" cfg.plugins) ''
          {
            'lewis6991/gitsigns.nvim',
            event = { 'BufReadPre', 'BufNewFile' },
            config = function()
              require('gitsigns').setup({
                signs = {
                  add = { text = '+' },
                  change = { text = '~' },
                  delete = { text = '_' },
                  topdelete = { text = '‾' },
                  changedelete = { text = '~' },
                },
                on_attach = function(bufnr)
                  local gs = package.loaded.gitsigns
                  
                  local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                  end
                  
                  -- Navigation
                  map('n', ']h', function()
                    if vim.wo.diff then return ']h' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                  end, {expr=true, desc="Next Hunk"})
                  
                  map('n', '[h', function()
                    if vim.wo.diff then return '[h' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                  end, {expr=true, desc="Previous Hunk"})
                  
                  -- Actions
                  map('n', '<leader>hs', gs.stage_hunk, { desc = "Stage Hunk" })
                  map('n', '<leader>hr', gs.reset_hunk, { desc = "Reset Hunk" })
                  map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Stage Selected Hunk" })
                  map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Reset Selected Hunk" })
                  map('n', '<leader>hS', gs.stage_buffer, { desc = "Stage Buffer" })
                  map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
                  map('n', '<leader>hR', gs.reset_buffer, { desc = "Reset Buffer" })
                  map('n', '<leader>hp', gs.preview_hunk, { desc = "Preview Hunk" })
                  map('n', '<leader>hb', function() gs.blame_line{full=true} end, { desc = "Blame Line" })
                  map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = "Toggle Line Blame" })
                  map('n', '<leader>hd', gs.diffthis, { desc = "Diff This" })
                  map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = "Diff This ~" })
                  map('n', '<leader>td', gs.toggle_deleted, { desc = "Toggle Delete" })
                end,
              })
            end,
          },
          ''}
          
          -- Better UI
          {
            'stevearc/dressing.nvim',
            event = 'VeryLazy',
            config = true,
          },
          
          -- Which Key (show keybindings)
          {
            'folke/which-key.nvim',
            event = 'VeryLazy',
            config = function()
              require('which-key').setup({
                plugins = { spelling = true },
                key_labels = { ['<leader>'] = 'SPC' },
                triggers_nowait = {
                  -- marks
                  '`',
                  "'",
                  "g`",
                  "g'",
                  -- registers
                  '"',
                  '<c-r>',
                  -- spelling
                  'z=',
                },
              })
              
              -- Document existing key chains
              require('which-key').register({
                ['<leader>f'] = { name = 'Find', _ = 'which_key_ignore' },
                ['<leader>g'] = { name = 'Git', _ = 'which_key_ignore' },
                ['<leader>h'] = { name = 'More Git', _ = 'which_key_ignore' },
                ['<leader>l'] = { name = 'LSP', _ = 'which_key_ignore' },
                ['<leader>t'] = { name = 'Toggle', _ = 'which_key_ignore' },
              })
            end,
          },
          
          -- Add additional plugins here
          
          ${cfg.userConfig}
        })
      '';
    };
  };
} 