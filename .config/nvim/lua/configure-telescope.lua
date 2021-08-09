local actions = require('telescope.actions')
local trouble = require('trouble.providers.telescope')

require('telescope').setup({
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--hidden',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--ignore-file',
      (os.getenv('HOME') .. '/.config/.ignore'),
    },
    prompt_prefix = '   ',
    file_sorter = require('telescope.sorters').get_fuzzy_file,
    dynamic_preview_title = true,
    mappings = {
      i = { ["<c-t>"] = trouble.open_with_trouble },
      n = { ["<c-t>"] = trouble.open_with_trouble },
    }
  },
  pickers = {
    find_files = {
      find_command = {
        'rg',
        '--hidden',
        '--no-heading',
        '--with-filename',
        '--files',
        '--column',
        '--smart-case',
        '--ignore-file',
        '~/.config/.ignore',
        '--iglob',
        '!.git'
      },
    },
  },
})
