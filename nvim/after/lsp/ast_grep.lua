local function sgconfig_path(root)
  for _, name in ipairs({ 'sgconfig.yml', 'sgconfig.yaml' }) do
    local p = vim.fs.joinpath(root, name)
    if vim.uv.fs_stat(p) then
      return p
    end
  end
end

local function has_custom_languages(path)
  return vim.system({ 'jaq', '-e', 'has("customLanguages")', path }):wait().code == 0
end

return {
  on_init = function(client)
    -- disable hover provider to avoid erroneous "No information available" notifications
    client.server_capabilities.hoverProvider = false
  end,
  -- Pass `--custom-language=allow` only if manually trusted from interactive prompt,
  -- since native libraries (such as the tree-sitter parsers) can execute arbitrary code
  cmd = function(dispatchers, config)
    local cmd = { 'ast-grep', 'lsp' }
    local cfg = config.root_dir and sgconfig_path(config.root_dir)
    if cfg and has_custom_languages(cfg) then
      -- returns contents only when the file hash is in the trust db;
      -- otherwise prompts ignore/view/deny and returns nil if not approved
      if vim.secure.read(cfg) then
        vim.list_extend(cmd, { '--custom-languages', 'allow' })
      else
        vim.notify(
          (
            'ast-grep: %s declares customLanguages but is untrusted; '
            .. 'custom-language rules are off, which may disable all ast-grep diagnostics. '
            .. 'Open it, run :trust, then :LspRestart ast_grep.'
          ):format(vim.fn.fnamemodify(cfg, ':~:.')),
          vim.log.levels.WARN
        )
      end
    end
    return vim.lsp.rpc.start(cmd, dispatchers, {
      cwd = config.cmd_cwd,
      env = config.cmd_env,
      detached = config.detached,
    })
  end,
}
