local width = 35

return {
  'nvim-tree/nvim-tree.lua',
  branch = '2189-api.tree.open-target_window',
  cmd = 'Tree',
  dependencies = {
    'stevearc/aerial.nvim',
    config = function()
      require('aerial').setup({
        layout = {
          max_width = { width },
          min_width = { width },
          placement = 'edge',
        },
        filter_kind = false,
        attach_mode = 'global',
        keymaps = {
          ['<C-j>'] = false,
          ['<C-k>'] = false,
          ['<C-y>'] = 'actions.up_and_scroll',
          ['<C-e>'] = 'actions.down_and_scroll',
        },
      })
    end,
  },
  config = function()
    require('legendary').command({
      'Tree',
      function()
        local a = require('aerial')
        local tree = require('nvim-tree.api').tree
        if a.is_open() or tree.is_visible() then
          a.close()
          tree.close_in_all_tabs()
          return
        end
        local curwin = vim.api.nvim_get_current_win()
        tree.open({ path = vim.loop.cwd() })
        local orig = vim.opt.splitbelow
        vim.opt.splitbelow = false
        vim.cmd(('%ssp'):format(width))
        vim.cmd('wincmd j')
        vim.opt.splitbelow = orig
        vim.schedule(function()
          a.open_in_win(0, curwin)
          vim.api.nvim_win_set_width(0, width)
          -- put cursor focus back where it was
          vim.api.nvim_set_current_win(curwin)
        end)
      end,
    })
    require('nvim-tree').setup({ view = { side = 'right' } })
    --- find all winid for normal windows
    --- @return number[]
    local function normal_winids()
      return vim.tbl_filter(function(id)
        local config = vim.api.nvim_win_get_config(id)
        return config and config.relative == ''
      end, vim.api.nvim_list_wins())
    end

    --- find the first non-floating window containing a file type
    --- @param ft string
    --- @return number|nil winid
    local function first_winid(ft)
      for _, winid in ipairs(normal_winids()) do
        local bufnr = vim.api.nvim_win_get_buf(winid)
        if vim.bo[bufnr] and vim.bo[bufnr].filetype == ft then
          return winid
        end
      end
    end

    local api = require('nvim-tree.api')
    local aerial = require('aerial')
    -- open/focus nvim-tree
    vim.keymap.set('n', '<space>e', function()
      -- just focus tree if it's visible
      if api.tree.is_visible() then
        api.tree.focus()
        return
      end

      -- scratch buffer to create the new window
      local scratch_bufnr = vim.api.nvim_create_buf(false, true)

      -- find the aerial window
      local aerial_winid = first_winid('aerial')
      local new_winid
      if aerial_winid then
        -- focus aerial
        vim.api.nvim_set_current_win(aerial_winid)

        -- create a horizontal split above
        vim.cmd('aboveleft sbuffer ' .. scratch_bufnr)
        new_winid = vim.api.nvim_get_current_win()
      else
        -- create a full height leftmost vertical split
        vim.cmd('topleft vertical sbuffer ' .. scratch_bufnr)
        new_winid = vim.api.nvim_get_current_win()
      end

      -- open the tree
      api.tree.open({ winid = new_winid })

      -- delete the scratch buffer
      vim.api.nvim_buf_delete(scratch_bufnr, { force = true })
    end, { noremap = true })

    -- open/focus aerial
    vim.keymap.set('n', '<space>j', function()
      -- just focus aerial if it's visible
      local aerial_winid = first_winid('aerial')
      if aerial_winid then
        aerial.focus()
        return
      end

      -- source window, current
      local source_winid = vim.api.nvim_get_current_win()

      -- scratch buffer to create the new window
      local scratch_bufnr = vim.api.nvim_create_buf(false, true)

      local new_winid
      if api.tree.is_visible() then
        -- focus nvim-tree
        api.tree.focus()

        -- create a horizontal split below
        vim.cmd('belowright sbuffer ' .. scratch_bufnr)
        new_winid = vim.api.nvim_get_current_win()
      else
        -- create a full height leftmost vertical split
        vim.cmd('topleft vertical sbuffer ' .. scratch_bufnr)
        new_winid = vim.api.nvim_get_current_win()
      end

      -- open aerial
      aerial.open_in_win(new_winid, source_winid)

      -- delete the scratch buffer
      vim.api.nvim_buf_delete(scratch_bufnr, { force = true })
    end, { noremap = true })
  end,
}
