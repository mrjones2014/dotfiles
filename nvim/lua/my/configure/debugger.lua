return {
  'mfussenegger/nvim-dap',
  dependencies = {
    { 'rcarriga/nvim-dap-ui', opts = {} },
  },
  config = function()
    local lldb_path = vim.trim(vim.fn.system('which lldb-vscode') or '')
    local dap = require('dap')
    dap.adapters.lldb = {
      type = 'executable',
      command = lldb_path,
      name = 'lldb',
    }

    dap.configurations.rust = {
      {
        name = 'Debug Rust Process',
        type = 'lldb',
        request = 'attach',
        pid = require('dap.utils').pick_process,
        args = {},
        initCommands = function()
          -- Find out where to look for the pretty printer Python module
          local rustc_sysroot = vim.fn.trim(vim.fn.system('rustc --print sysroot'))

          local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
          local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

          local commands = {}
          local file = io.open(commands_file, 'r')
          if file then
            for line in file:lines() do
              table.insert(commands, line)
            end
            file:close()
          end
          table.insert(commands, 1, script_import)

          return commands
        end,
      },
    }

    local dapui = require('dapui')
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end
  end,
}
