local M = {}

function M.check()
  vim.health.start('codecompanion-ui')

  -- Check codecompanion.nvim
  local ok_cc, cc = pcall(require, 'codecompanion')
  if ok_cc then
    vim.health.ok('codecompanion.nvim found')
  else
    vim.health.error('codecompanion.nvim not found', { 'Install olimorris/codecompanion.nvim' })
  end

  -- Check required codecompanion functions that we wrap
  if ok_cc then
    if cc.buf_get_chat then
      vim.health.ok('codecompanion.buf_get_chat found')
    else
      vim.health.warn('codecompanion.buf_get_chat not found (completion may not work)')
    end

    local ok_completion, completion = pcall(require, 'codecompanion.providers.completion')
    if ok_completion then
      if completion.interaction_type then
        vim.health.ok('codecompanion.providers.completion.interaction_type found')
      else
        vim.health.warn('completion.interaction_type not found (completion may not work)')
      end
      if completion.acp_commands then
        vim.health.ok('codecompanion.providers.completion.acp_commands found')
      else
        vim.health.warn('completion.acp_commands not found (slash commands may not work)')
      end
    else
      vim.health.warn('codecompanion.providers.completion not found')
    end
  end
end

return M
