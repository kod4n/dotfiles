return {
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/nvim-cmp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      { 'j-hui/fidget.nvim', opts = {} },
      { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
      local ui = require 'config.ui'

      vim.o.winborder = 'rounded'
      vim.api.nvim_set_hl(0, 'FloatBorder', ui.float_border)

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local telescope = require 'telescope.builtin'
          map('gd', telescope.lsp_definitions, '[G]oto [D]efinition')
          map('gr', telescope.lsp_references, '[G]oto [R]eferences')
          map('gI', telescope.lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', telescope.lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', telescope.lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', telescope.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('K', function()
            vim.lsp.buf.hover {
              border = ui.border,
              max_width = 80,
              max_height = 20,
            }
          end, 'Hover Documentation')
          map('<C-Space>', vim.lsp.buf.signature_help, 'Hover Documentation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Handle document highlight
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end

          -- Handle inlay hints
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end

          -- Handle custom on_attach triggers (like eslint autofix)
          -- Neovim 0.12 merges configurations instead of passing old on_attach callbacks directly
          if client and client.name == 'eslint' then
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = event.buf,
              command = 'EslintFixAll',
            })
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Tweak default capabilities to safely handle file watchers
      capabilities.workspace = vim.tbl_deep_extend('force', capabilities.workspace or {}, {
        didChangeWatchedFiles = {
          dynamicRegistration = false,
          relativePatternSupport = false,
        },
      })

      local servers = {
        clangd = {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--header-insertion=iwyu',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
          },
          root_markers = {
            'compile_commands.json',
            'compile_flags.txt',
            'Makefile',
            'meson.build',
            'build.ninja',
            '.git',
          },
          capabilities = { offsetEncoding = { 'utf-16' } },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
        pyright = {},
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },
        rust_analyzer = {},
        ts_ls = {},
        eslint = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = {
                globals = { 'vim' },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
              },
            },
          },
        },
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
      require('mason-lspconfig').setup { ensure_installed = ensure_installed }

      for server_name, server_opts in pairs(servers) do
        server_opts.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_opts.capabilities or {})
        vim.lsp.config(server_name, server_opts)
        vim.lsp.enable(server_name)
      end
    end,
  },
}
