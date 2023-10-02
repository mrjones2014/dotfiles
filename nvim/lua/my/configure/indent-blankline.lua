return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  event = 'BufRead',
  opts = {
    exclude = {
      buftypes = {
        'terminal',
        'nofile',
        'quickfix',
        'prompt',
      },
      filetypes = {
        'terminal',
        'term',
        'gitcommit',
        'qf',
        'lspinfo',
        'packer',
        'checkhealth',
        'help',
        'man',
        'gitcommit',
        'TelescopePrompt',
        'TelescopeResults',
        '',
      },
    },

    scope = {
      enabled = true,
      char = '│',
      include = {
        node_type = {
          ['*'] = {
            '*',
          },
        },
      },
    },
  },
}
