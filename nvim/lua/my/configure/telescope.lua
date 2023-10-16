return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  dependencies = {
    'nvim-telescope/telescope-symbols.nvim',
    'nvim-telescope/telescope-fzy-native.nvim',
    {
      'folke/trouble.nvim',
      keys = {
        {
          '<leader>d',
          function()
            require('trouble').toggle()
          end,
          desc = 'Open LSP diagnostics in quickfix window',
        },
      },
      opts = { action_keys = { hover = {} } },
    },
    {
      'kevinhwang91/nvim-bqf',
      ft = 'qf', -- load on quickfix list opened,
      opts = {
        func_map = {
          pscrolldown = '<C-d>',
          pscrollup = '<C-f>',
        },
      },
    },
  },
  config = function()
    local actions = require('telescope.actions')

    local function smart_send_to_qflist(...)
      vim.cmd.cexpr('[]')
      actions.smart_add_to_qflist(...)
      vim.cmd.copen()
    end

    local function parse_prompt(prompt)
      local first_word, rest = prompt:match('^%s*@(%S+)%s*(.*)$')
      if first_word == nil then
        return { prompt = prompt, filetype = nil }
      end

      first_word = first_word:lower()
      if first_word == 'makefile' then
        return { prompt = rest, filetype = 'Makefile' }
      elseif first_word:match('^[tj]s$') then
        return { prompt = rest, filetype = { 'ts', 'tsx', 'js', 'jsx' } }
      elseif #first_word > 1 then
        return { prompt = rest, filetype = first_word }
      else
        return { prompt = prompt, filetype = nil }
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

    local ripgrep_ignore_file_path = (
      Path.join(vim.env.XDG_CONFIG_HOME or Path.join(vim.env.HOME, '.config'), 'ripgrep_ignore')
    )

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
          ripgrep_ignore_file_path,
        },
        prompt_prefix = '  ',
        file_sorter = require('telescope.sorters').get_fuzzy_file,
        dynamic_preview_title = true,
        -- preview = {
        --   mime_hook = function(filepath, bufnr, opts)
        --     local is_image = function(fp)
        --       local image_extensions = { 'png', 'jpg' } -- Supported image formats
        --       local split_path = vim.split(fp:lower(), '.', { plain = true })
        --       local extension = split_path[#split_path]
        --       return vim.tbl_contains(image_extensions, extension)
        --     end
        --     if is_image(filepath) then
        --       local term = vim.api.nvim_open_term(bufnr, {})
        --       local function send_output(_, data, _)
        --         for _, d in ipairs(data) do
        --           vim.api.nvim_chan_send(term, d .. '\r\n')
        --         end
        --       end
        --       vim.fn.jobstart({
        --         'catimg',
        --         filepath, -- Terminal image viewer command
        --       }, { on_stdout = send_output, stdout_buffered = true, pty = true })
        --     else
        --       require('telescope.previewers.utils').set_preview_message(bufnr, opts.winid, 'Binary cannot be previewed')
        --     end
        --   end,
        -- },
        mappings = {
          i = {
            ['<C-t>'] = smart_send_to_qflist,
            ['<C-r>'] = smart_send_to_qflist,
            ['<C-u>'] = false, -- clear prompt with ctrl+u
            ['<C-d>'] = actions.preview_scrolling_down,
            ['<C-f>'] = actions.preview_scrolling_up,
            ['<C-n>'] = actions.move_selection_next,
            ['<C-p>'] = actions.move_selection_previous,
          },
          n = {
            ['<C-t>'] = smart_send_to_qflist,
            ['<C-r>'] = smart_send_to_qflist,
            ['q'] = actions.close,
            ['<C-n>'] = actions.move_selection_next,
            ['<C-p>'] = actions.move_selection_previous,
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
            ripgrep_ignore_file_path,
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

            local pattern
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
              ['<CR>'] = actions.edit_command_line,
            },
            n = {
              ['<CR>'] = actions.edit_command_line,
            },
          },
        }),
        buffers = require('telescope.themes').get_dropdown({ previewer = false }),
      },
      extensions = {
        fzy_native = {
          override_generic_sorter = true,
          override_file_sorter = true,
        },
      },
    })

    telescope.load_extension('fzy_native')
  end,
}
