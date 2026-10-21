---@type LazySpec
return {
  'saecki/crates.nvim',
  event = { 'BufRead Cargo.toml' },
  config = function(_, opts)
    -- at work we use `package.path = "..."` syntax in Cargo.toml
    -- a lot, and this breaks the parser
    if require('my-utils').is_work_repo() then
      return
    end
    require('crates').setup(opts)
  end,
}
