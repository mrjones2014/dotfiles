return {
  'nvim-telescope/telescope.nvim',
  module = 'telescope',
  cmd = 'Telescope',
  before = 'trouble.nvim',
  requires = {
    'nvim-telescope/telescope-symbols.nvim',
    'folke/trouble.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  },
  config = function()
    local trouble = require('trouble.providers.telescope')
    local paths = require('paths')

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
          (paths.join(paths.config, '.ignore')),
        },
        prompt_prefix = '   ',
        file_sorter = require('telescope.sorters').get_fuzzy_file,
        dynamic_preview_title = true,
        mappings = {
          i = {
            ['<C-t>'] = trouble.open_with_trouble,
            ['<C-u>'] = false, -- clear prompt with ctrl+u
            ['<C-d>'] = require('telescope.actions').preview_scrolling_down,
            ['<C-f>'] = require('telescope.actions').preview_scrolling_up,
          },
          n = { ['<C-t>'] = trouble.open_with_trouble },
        },
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
            (paths.join(paths.config, '.ignore')),
            '--iglob',
            '!.git',
          },
          on_input_filter_cb = function(prompt)
            local result = vim.split(prompt, ' ')
            if #result == 2 then
              return { prompt = result[2] .. '.' .. result[1] }
            else
              return { prompt = prompt }
            end
          end,
        },
        oldfiles = {
          only_cwd = true,
          file_ignore_patterns = {
            'COMMIT_EDITMSG',
          },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = 'smart_case',
        },
      },
    })

    require('telescope').load_extension('fzf')
  end,
}
