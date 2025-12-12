-- check if sgconfig.yaml or sgconfig.yml exists in the project root
-- if it exists, use ast-grep lsp server, and also check if the yaml
-- file contains a top-level `customLanguages` field. If it does,
-- try to parse out the languages defined there and add them to the
-- filetypes list.
local filetypes = {
  'c',
  'cpp',
  'rust',
  'go',
  'java',
  'python',
  'javascript',
  'javascriptreact',
  'javascript.jsx',
  'typescript',
  'typescriptreact',
  'typescript.tsx',
  'html',
  'css',
  'kotlin',
  'dart',
  'lua',
}

---@return string[]
local function custom_langs()
  local sgconfig = vim.fs.find({ 'sgconfig.yaml', 'sgconfig.yml' }, { type = 'file', limit = 1 })[1]
  if not sgconfig then
    return {}
  end

  local result = vim.system({ 'yq', 'eval', '.customLanguages | keys | .[]', sgconfig }, { text = true }):wait()
  if result.code ~= 0 then
    return {}
  end
  local langs = {}
  for line in result.stdout:gmatch('[^\n]+') do
    if line and #line > 0 then
      table.insert(langs, line)
    end
  end
  return langs
end

return {
  cmd = { 'ast-grep', 'lsp' },
  filetypes = vim.list_extend(filetypes, custom_langs()),
  root_markers = { 'sgconfig.yaml', 'sgconfig.yml' },
  workspace_required = true,
  reuse_client = function(client, config)
    config.cmd_cwd = config.root_dir
    return client.config.cmd_cwd == config.cmd_cwd
  end,
  on_init = function(client)
    client.server_capabilities.hoverProvider = false
  end,
}
