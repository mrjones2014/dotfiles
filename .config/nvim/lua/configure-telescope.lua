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
      '~/.config/.ignore',
    },
    prompt_prefix = '   ',
    file_sorter = require('telescope.sorters').get_fuzzy_file,
    dynamic_preview_title = true,
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
