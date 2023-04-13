return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  dependencies = {
    'nvim-telescope/telescope-symbols.nvim',
    'folke/trouble.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
  },
  config = function()
    local trouble = require('trouble.providers.telescope')

    local function parse_prompt(prompt)
      if (prompt or ''):sub(1, 2) == '\\@' then
        return { prompt = prompt:sub(2), filetype = nil }
      end

      local result = vim.split(prompt, ' ', {})
      if #result < 2 or result[1]:sub(1, 1) ~= '@' then
        return { prompt = prompt, filetype = nil }
      end

      local query = table.concat(vim.list_slice(result, 2, #result), '')

      if result[1]:lower() == '@makefile' then
        return { prompt = query, filetype = 'Makefile' }
      end

      -- if it looks like a file extension
      if #result[1] > 1 and #result[1] < 5 then
        local filetype = result[1]:sub(2):lower()
        -- treat TS/TSX/JS/JSX as equivalent
        if filetype == 'ts' or filetype == 'tsx' or filetype == 'js' or filetype == 'jsx' then
          return { prompt = query, filetype = { 'ts', 'tsx', 'js', 'jsx' } }
        end

        return { prompt = query, filetype = filetype }
      end
    end

    local function file_extension_filter(prompt)
      local parsed = parse_prompt(prompt)
      if parsed.filetype == nil then
        return { prompt = prompt }
      end

      local pattern = parsed.filetype
      if type(parsed.filetype) == 'table' then
        pattern = string.format('(%s)', table.concat(parsed.filetype, '|')) ---@diagnostic disable-line
      end

      return {
        prompt = string.format(
          '%s%s%s',
          parsed.prompt,
          tostring(pattern):lower() == 'makefile' and '/' or '.',
          pattern
        ),
      }
    end

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
        preview = {
          mime_hook = function(filepath, bufnr, opts)
            local is_image = function(fp)
              local image_extensions = { 'png', 'jpg' } -- Supported image formats
              local split_path = vim.split(fp:lower(), '.', { plain = true })
              local extension = split_path[#split_path]
              return vim.tbl_contains(image_extensions, extension)
            end
            if is_image(filepath) then
              local term = vim.api.nvim_open_term(bufnr, {})
              local function send_output(_, data, _)
                for _, d in ipairs(data) do
                  vim.api.nvim_chan_send(term, d .. '\r\n')
                end
              end
              vim.fn.jobstart({
                'catimg',
                filepath, -- Terminal image viewer command
              }, { on_stdout = send_output, stdout_buffered = true, pty = true })
            else
              require('telescope.previewers.utils').set_preview_message(bufnr, opts.winid, 'Binary cannot be previewed')
            end
          end,
        },
        mappings = {
          i = {
            ['<C-t>'] = trouble.open_with_trouble,
            ['<C-r>'] = trouble.open_selected_with_trouble,
            ['<C-u>'] = false, -- clear prompt with ctrl+u
            ['<C-d>'] = require('telescope.actions').preview_scrolling_down,
            ['<C-f>'] = require('telescope.actions').preview_scrolling_up,
            ['<C-n>'] = require('telescope.actions').move_selection_next,
            ['<C-p>'] = require('telescope.actions').move_selection_previous,
          },
          n = {
            ['<C-t>'] = trouble.open_with_trouble,
            ['<C-r>'] = trouble.open_selected_with_trouble,
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
        live_grep = {
          on_input_filter_cb = function(prompt)
            local parsed = parse_prompt(prompt)
            if parsed.filetype == nil then
              return {
                prompt = parsed.prompt,
                updated_finder = require('telescope.finders').new_job(function(new_prompt)
                  return vim.tbl_flatten({
                    require('telescope.config').values.vimgrep_arguments,
                    '--',
                    new_prompt,
                  })
                end, require('telescope.make_entry').gen_from_vimgrep({}), nil, nil),
              }
            end

            local pattern = parsed.filetype
            if type(parsed.filetype) == 'table' then
              pattern = string.format('*.{%s}', table.concat(parsed.filetype, ',')) ---@diagnostic disable-line
            elseif parsed.filetype:lower() == 'makefile' then ---@diagnostic disable-line
              pattern = '*Makefile'
            else
              pattern = string.format('*.%s', parsed.filetype)
            end

            return {
              prompt = parsed.prompt,
              updated_finder = require('telescope.finders').new_job(function(new_prompt)
                return vim.tbl_flatten({
                  require('telescope.config').values.vimgrep_arguments,
                  '-g',
                  pattern,
                  '--',
                  new_prompt,
                })
              end, require('telescope.make_entry').gen_from_vimgrep({}), nil, nil),
            }
          end,
        },
        command_history = require('telescope.themes').get_dropdown({
          mappings = {
            i = {
              ['<CR>'] = require('telescope.actions').edit_command_line,
            },
            n = {
              ['<CR>'] = require('telescope.actions').edit_command_line,
            },
          },
        }),
        buffers = require('telescope.themes').get_dropdown({ previewer = false }),
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
