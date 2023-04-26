local M = {}

function M.should_show_filename(self)
  local bt = vim.api.nvim_buf_get_option(0, 'buftype')
      return (not bt or bt == '')
        and self.bufname
        and self.bufname ~= ''
        and not vim.startswith(self.bufname, 'component://')
end

return M
