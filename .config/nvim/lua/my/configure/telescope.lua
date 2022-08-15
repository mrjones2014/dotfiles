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
    local paths = require('my.paths')

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
        prompt_prefix = '  ',
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
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            preview_width = 0.5,
          },
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
            -- if prompt starts with escaped @ then treat it as a literal
            if (prompt):sub(1, 2) == '\\@' then
              return { prompt = prompt:sub(2) }
            end

            local result = vim.split(prompt, ' ')
            -- if prompt starts with, for example, @rs
            -- then only search files ending in *.rs
            if
              #result == 2
              and result[1]:sub(1, 1) == '@'
              and (#result[1] == 2 or #result[1] == 3 or #result[1] == 4)
            then
              print(result[2], result[1]:sub(2))
              return { prompt = result[2] .. '.' .. result[1]:sub(2) }
            else
              return { prompt = prompt }
            end
          end,
        },
        live_grep = { -- TODO see https://github.com/nvim-telescope/telescope.nvim/issues/1865
          on_input_filter_cb = function(prompt)
            -- if prompt starts with escaped @ then treat it as a literal
            if (prompt):sub(1, 2) == '\\@' then
              return { prompt = prompt:sub(2) }
            end
            -- if prompt starts with, for example, @rs
            -- only search files that end in *.rs
            local result = string.match(prompt, '@%a*%s')
            if not result then
              return {
                prompt = prompt,
                updated_finder = require('telescope.finders').new_job(function(new_prompt)
                  return vim.tbl_flatten({
                    require('telescope.config').values.vimgrep_arguments,
                    '--',
                    new_prompt,
                  })
                end, require('telescope.make_entry').gen_from_vimgrep({}), nil, nil),
              }
            end

            local result_len = #result

            result = result:sub(2)
            result = result:gsub('%s+', '') -- trim

            return {
              prompt = prompt:sub(result_len + 1),
              updated_finder = require('telescope.finders').new_job(function(new_prompt)
                return vim.tbl_flatten({
                  require('telescope.config').values.vimgrep_arguments,
                  string.format('-g*.%s', result),
                  '--',
                  new_prompt,
                })
              end, require('telescope.make_entry').gen_from_vimgrep({}), nil, nil),
            }
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
