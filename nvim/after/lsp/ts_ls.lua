-- Upstream (nvim-lspconfig) resolves the project root from package-manager *lock* files.
-- My pnpm workspaces don't always have a committed lock at the workspace root, so
-- `pnpm-workspace.yaml` is added to the same equal-priority marker group.
--
-- This has to override `root_dir` rather than `root_markers`, because upstream defines
-- `root_dir` as a function and that takes precedence over `root_markers`. The deno
-- exclusion logic below is copied from upstream and should be re-synced if ts_ls breaks
-- in a deno project.
---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local root_markers = {
      'pnpm-workspace.yaml',
      'pnpm-workspace.yml',
      'package-lock.json',
      'yarn.lock',
      'pnpm-lock.yaml',
      'bun.lockb',
      'bun.lock',
    }
    -- give the root markers equal priority by wrapping them in a table
    root_markers = { root_markers, { '.git' } }

    -- exclude deno
    local deno_root = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
    local deno_lock_root = vim.fs.root(bufnr, { 'deno.lock' })
    local project_root = vim.fs.root(bufnr, root_markers)
    if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
      return
    end
    if deno_root and (not project_root or #deno_root >= #project_root) then
      return
    end

    on_dir(project_root or vim.fn.getcwd())
  end,
}
