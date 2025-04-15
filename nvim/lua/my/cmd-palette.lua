---@class PaletteEntry
---@field text string|fun(buf:number, win:number):string
---@field on_selected fun(buf:number, win:number)

---@type PaletteEntry[]
return {
  {
    text = ' Copy relative filepath',
    on_selected = function(buf)
      local filepath = vim.api.nvim_buf_get_name(buf)
      if not filepath or #filepath == 0 then
        vim.notify('Could not expand filepath')
        return
      end

      local relpath = vim.fn.simplify(require('my.utils.path').relative(vim.fn.expand('%') --[[@as string]]))
      require('my.utils.clipboard').copy(relpath)
      vim.notify('Relative filepath copied to clipboard')
    end,
  },
  {
    text = '󰊢 Copy git branch name',
    on_selected = function(buf)
      local branch = vim.g.gitsigns_head or vim.b[buf].gitsigns_head
      if not branch or #branch == 0 then
        vim.notify('Could not determine git branch')
        return
      end
      require('my.utils.clipboard').copy(branch)
    end,
  },
}
