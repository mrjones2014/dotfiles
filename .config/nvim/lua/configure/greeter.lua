return {
  'goolord/alpha-nvim',
  config = function()
    local dashboard = require('alpha.themes.dashboard')
    dashboard.section.header.val = {
      '╭──────────────────────────────────────────────────────────╮',
      '│                                                          │',
      '│    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗    │',
      '│    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║    │',
      '│    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║    │',
      '│    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║    │',
      '│    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    │',
      '│    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    │',
      '│                                                          │',
      '╰──────────────────────────────────────────────────────────╯',
    }

    dashboard.section.buttons.val = {
      dashboard.button('e', '  > New file', ':enew <BAR> startinsert <CR>'),
      dashboard.button('q', '  > Quit', ':qa<CR>'),
    }

    dashboard.config.layout[1].val = 15

    require('alpha').setup(dashboard.config)
  end,
}
