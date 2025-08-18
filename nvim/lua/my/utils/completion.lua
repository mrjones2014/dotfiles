local M = {}

---Dynamically register a completion source specific to a filetype,
---this is used to extend completion config from other modules.
---Currently uses blink.cmp
---@param base_opts table base opts from blink.cmp
---@param ft string filetype to activate for
---@param providers table the providers to activate
---@param extra_providers table|nil extra providers to configure, if any
function M.register_filetype_source(base_opts, ft, providers, extra_providers)
  -- nil safety
  base_opts.sources = base_opts.sources or {}
  base_opts.sources.per_filetype = base_opts.sources.per_filetype or {}
  base_opts.sources.providers = base_opts.sources.providers or {}

  -- config
  if type(providers) == 'string' then
    providers = { providers }
  end
  base_opts.sources.per_filetype[ft] = providers
  base_opts.sources.providers = vim.tbl_deep_extend('force', base_opts.sources.providers, extra_providers or {})
end

return M
