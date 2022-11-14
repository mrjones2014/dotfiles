return {
  'nvim-telescope/telescope.nvim',
  module = 'telescope',
  cmd = 'Telescope',
  requires = {
    'nvim-telescope/telescope-symbols.nvim',
    'folke/trouble.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  },
  config = function()
    local trouble = require('trouble.providers.telescope')

    local function file_extension_filter(prompt)
      -- if prompt starts with escaped @ then treat it as a literal
      if (prompt):sub(1, 2) == '\\@' then
        return { prompt = prompt:sub(2) }
      end

      local result = vim.split(prompt, ' ', {})
      -- if prompt starts with, for example, @rs
      -- then only search files ending in *.rs
      if #result == 2 and result[1]:sub(1, 1) == '@' and (#result[1] == 2 or #result[1] == 3 or #result[1] == 4) then
        return { prompt = result[2] .. '.' .. result[1]:sub(2) }
      else
        return { prompt = prompt }
      end
    end

    local utils = require('telescope.utils')

    --- Override function to get icons until this is merged
    --- https://github.com/nvim-telescope/telescope.nvim/pull/2235
    --- Here I'm using 1 function to handle 2 separate telescope utils
    --- by just massaging the params a bit
    --- We need the following overloads:
    --- function(filename, display, disable_devicons)
    --- function(filename, disable_devicons)
    local function get_icon(filename, display, disable_devicons)
      local devicons = require('nvim-web-devicons')

      local conf = require('telescope.config').values
      if disable_devicons or not filename then
        return ''
      end

      local basename = utils.path_tail(filename)
      -- the double :e:e gets multipart extensions, if one exists, like *.test.js, for example
      local icon, icon_highlight = devicons.get_icon(basename, vim.fn.fnamemodify(basename, ':e:e'), { default = true })
      if display == nil then
        if conf.color_devicons then
          return icon, icon_highlight
        else
          return icon, nil
        end
      else
        local icon_display = (icon or ' ') .. ' ' .. (display or '')
        if conf.color_devicons then
          return icon_display, icon_highlight
        else
          return icon_display, nil
        end
      end
    end

    require('telescope.utils').get_devicons = function(filename, disable_devicons)
      return get_icon(filename, nil, disable_devicons)
    end
    require('telescope.utils').transform_devicons = get_icon

    local telescope = require('telescope')

    telescope.setup({
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
          (Path.join(vim.env.HOME, '.config', '.ignore')),
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
            ['<C-n>'] = require('telescope.actions').move_selection_next,
            ['<C-p>'] = require('telescope.actions').move_selection_previous,
          },
          n = {
            ['<C-t>'] = trouble.open_with_trouble,
            ['q'] = require('telescope.actions').close,
            ['<C-n>'] = require('telescope.actions').move_selection_next,
            ['<C-p>'] = require('telescope.actions').move_selection_previous,
          },
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
            (Path.join(vim.env.HOME, '.config', '.ignore')),
            '--iglob',
            '!.git',
          },
          on_input_filter_cb = file_extension_filter,
        },
        oldfiles = {
          only_cwd = true,
          file_ignore_patterns = {
            '.git/COMMIT_EDITMSG',
          },
          on_input_filter_cb = file_extension_filter,
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
            result = vim.trim(result)

            if result == 'js' or result == 'ts' then
              result = string.format('{%s,%sx}', result, result)
            end

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
        command_history = {
          mappings = {
            i = {
              ['<CR>'] = require('telescope.actions').edit_command_line,
            },
            n = {
              ['<CR>'] = require('telescope.actions').edit_command_line,
            },
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

    telescope.load_extension('fzf')
  end,
}
