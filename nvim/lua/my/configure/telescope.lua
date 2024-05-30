local path = require('my.utils.path')

---@param picker string
---@param preexec fun()|nil
local function search(picker, preexec)
  return function()
    if preexec then
      preexec()
    end
    require('telescope.builtin')[picker]()
  end
end

return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  keys = {
    {
      '<C-f>',
      function()
        local prompt = vim.fn.getcmdline()
        vim.fn.setcmdline('')
        require('telescope.builtin').command_history({ default_text = prompt })
      end,
      mode = 'c',
      desc = 'Fuzzy find command history',
    },
    { 'ff', search('find_files'), desc = 'Find files' },
    { 'fh', search('oldfiles'), desc = 'Find oldfiles' },
    { 'fb', search('buffers'), desc = 'Find buffers' },
    { 'ft', search('live_grep'), desc = 'Find text' },
    { 'fr', search('resume'), desc = 'Resume last finder' },
    {
      '<leader>w',
      function()
        local word = vim.fn.expand('<cword>')
        require('telescope.builtin').live_grep({ default_text = word })
      end,
      desc = 'Grep word under cursor',
    },
    { '<leader>f', search('find_files', vim.cmd.vsp), desc = 'Split vertically, then find files' },
    { '<leader>h', search('oldfiles', vim.cmd.vsp), desc = 'Split vertically, then find oldfiles' },
    { '<leader>b', search('buffers', vim.cmd.vsp), desc = 'Split vertically, then find buffers' },
    { '<leader>t', search('live_grep', vim.cmd.vsp), desc = 'Split vertically, then find text' },
  },
  dependencies = {
    'nvim-telescope/telescope-symbols.nvim',
    'nvim-telescope/telescope-fzy-native.nvim',
    {
      'folke/trouble.nvim',
      cmd = 'Trouble',
      keys = {
        { '<leader>d', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Toggle diagnostics list' },
        { '<leader>q', '<cmd>Trouble qflist toggle<cr>', desc = 'Toggle quickfix list' },
        { '<leader>r', '<cmd>Trouble lsp toggle win.position=right<cr>' },
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

    local function switch_picker(new_picker)
      return function(prompt_bufnr)
        local prompt = require('telescope.actions.state').get_current_line()
        actions.close(prompt_bufnr)
        require('telescope.builtin')[new_picker]({ default_text = prompt })
      end
    end

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
        pattern = string.format('(%s)', table.concat(parsed.filetype --[[@as table]], '|'))
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
      path.join(vim.env.XDG_CONFIG_HOME or path.join(vim.env.HOME, '.config'), 'ripgrep_ignore')
    )

    local telescope = require('telescope')
    local open_with_trouble = require('trouble.sources.telescope').open

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
        path_display = { 'filename_first' },
        mappings = {
          i = {
            ['<C-t>'] = open_with_trouble,
            ['<C-u>'] = false, -- clear prompt with ctrl+u
            ['<C-d>'] = actions.preview_scrolling_down,
            ['<C-f>'] = actions.preview_scrolling_up,
            ['<C-n>'] = actions.move_selection_next,
            ['<C-p>'] = actions.move_selection_previous,
          },
          n = {
            ['<C-t>'] = open_with_trouble,
            ['q'] = actions.close,
            ['<C-n>'] = actions.move_selection_next,
            ['<C-p>'] = actions.move_selection_previous,
            ['ff'] = switch_picker('find_files'),
            ['fh'] = switch_picker('oldfiles'),
            ['fb'] = switch_picker('buffers'),
            ['ft'] = switch_picker('live_grep'),
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
                  return vim
                    .iter({
                      require('telescope.config').values.vimgrep_arguments,
                      '--',
                      new_prompt,
                    })
                    :flatten()
                    :totable()
                end, require('telescope.make_entry').gen_from_vimgrep({}), nil, nil),
              }
            end

            local pattern
            if type(parsed.filetype) == 'table' then
              pattern = string.format('*.{%s}', table.concat(parsed.filetype --[[@as table]], ','))
            elseif
              (parsed.filetype --[[@as string]]):lower() == 'makefile'
            then
              pattern = '*Makefile'
            else
              pattern = string.format('*.%s', parsed.filetype)
            end

            return {
              prompt = parsed.prompt,
              updated_finder = require('telescope.finders').new_job(function(new_prompt)
                return vim
                  .iter({
                    require('telescope.config').values.vimgrep_arguments,
                    '-g',
                    pattern,
                    '--',
                    new_prompt,
                  })
                  :flatten()
                  :totable()
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
