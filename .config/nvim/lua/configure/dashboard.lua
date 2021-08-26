return {
  'glepnir/dashboard-nvim',
  setup = function()
    vim.g.dashboard_custom_header = {
      ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
      ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
      ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
      ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
      ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
      ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
    }
    vim.g.dashboard_custom_section = {
      session = {
        description = { '  Load Last Session   <leader>sl' },
        command = 'SessionLoad',
      },
      recents = {
        description = { '  Search Recent Files         fh' },
        command = 'lua require("telescope.builtin").oldfiles()',
      },
      files = {
        description = { '  Search Files                ff' },
        command = 'lua require("telescope.builtin").find_files()',
      },
    }
  end,
}
