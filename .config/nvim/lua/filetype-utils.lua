local fileTypeUtils = {}

function fileTypeUtils.buffer_to_string()
    local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
    return table.concat(content, "\n")
end

function fileTypeUtils.detect_filetypes()
  if vim.bo.filetype == "html" and string.find(buffer_to_string(), "{{") then
    vim.bo.filetype = "gohtmltmpl"
    return
  end

  local firstLine = table.concat(vim.api.nvim_buf_get_lines(0, 0, 1, false), "\n")
  -- if not a shebang line, return
  if not string.find(firstLine, "#!/") then
    return
  end

  -- otherwise set filetype based on shebang
  if string.find(firstLine, "zsh") then
    vim.bo.filetype = "zsh"
    return
  end

  if string.find(firstLine, "bash") then
    vim.bo.filetype = "bash"
    return
  end

  if string.find(firstLine, "fish") then
    vim.bo.filetype = "fish"
  end
end

return fileTypeUtils
