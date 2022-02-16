return {
  'startup-nvim/startup.nvim',
  config = function()
    local settings = require('startup.themes.dashboard')
    settings.header.content = {
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
    settings.footer.content = { require('utils').relative_cwd() }
    settings.parts = { 'header', 'footer' }
    settings.options.paddings[1] = 10
    require('startup').setup()
  end,
}
