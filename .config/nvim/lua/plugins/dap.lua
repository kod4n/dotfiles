---@diagnostic disable: missing-fields
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = { 'delve', 'codelldb', 'python', 'ruff', 'debugpy' },
    }

    vim.keymap.set('n', '<F5>', function()
      if dap.session() then
        dap.continue()
        return
      end

      local vscode = require 'dap.ext.vscode'
      local launch_json = vim.fn.getcwd() .. '/.vscode/launch.json'

      if vim.fn.filereadable(launch_json) == 1 then
        local configs = vscode.getconfigs(launch_json)

        for _, config in ipairs(configs) do
          if config.name == 'Debug Game' then
            local build_script = vim.fn.getcwd() .. '/build.bat'
            if vim.fn.filereadable(build_script) == 1 then
              vim.fn.system { 'cmd.exe', '/c', build_script }

              if vim.v.shell_error ~= 0 then
                vim.notify('Build failed:\n' .. vim.v.shell_error, vim.log.levels.ERROR)
                return
              end
            end
            dap.run(config)
            return
          end
        end

        -- Fall back to the first project configuration.
        if #configs > 0 then
          dap.run(configs[1])
          return
        end
      end

      -- No project configuration: use normal DAP behavior.
      dap.continue()
    end, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })
    vim.keymap.set('n', '<leader>td', function()
      require('dap-go').debug_test()
    end, { silent = true, desc = 'Debug Test' })
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })
    -- Debug: Hover current runtime value
    vim.keymap.set('n', '<leader>dh', function()
      dapui.eval()
    end, { desc = 'Debug: Hover Variable' })
    -- Debug: Evaluate visually selected expression
    vim.keymap.set('v', '<leader>dh', function()
      dapui.eval()
    end, { desc = 'Debug: Evaluate Selection' })

    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    local is_windows = vim.fn.has 'win32' == 1

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    if not is_windows then
      dap.listeners.after.event_terminated['dapui_config'] = dapui.close
      dap.listeners.after.event_exited['dapui_config'] = dapui.close
    end

    local codelldb = vim.fn.exepath 'codelldb'
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = codelldb,
        args = { '--port', '${port}' },
        detached = is_windows,
      },
    }
    require('dap-go').setup {
      delve = {
        detached = is_windows,
      },
    }
    require('dap-python').setup()
  end,
}
