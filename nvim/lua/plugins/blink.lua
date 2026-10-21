local _cached_github_token
local function get_github_token()
  if _cached_github_token then
    return _cached_github_token
  end

  -- NB: long timeout since there may be a 1Password auth prompt
  local res = vim.system({ 'gh', 'auth', 'token' }):wait(15000)
  if res.code ~= 0 or res.stdout == nil then
    error(('Failed to retrieve GitHub token: %s'):format(res.stderr or 'stderr is nil'))
  end

  return vim.trim(res.stdout)
end

---@type LazySpec
return {
  'saghen/blink.cmp',
  specs = {
    {
      'yus-works/csc.nvim',
      ft = 'jjdescription',
      opts = {},
      config = function(_, opts)
        require('csc').setup(opts)
        -- upstream only registers the source for `gitcommit`
        require('blink.cmp').add_filetype_source('jjdescription', 'csc')
      end,
    },
    {
      'Kaiser-Yang/blink-cmp-git',
      ft = { 'markdown', 'gitcommit', 'jjdescription' },
      opts = {},
      config = function()
        -- only load on markdown if its because I'm editing a PR with jj-gh
        if vim.o.ft == 'markdown' and vim.env.JJ_GH ~= '1' then
          return
        end
        local blink = require('blink.cmp')
        ---@type blink-cmp-git.GCSCompletionOptions
        local completer_opts = { enable = true, get_command = 'curl' }
        if require('my-utils').is_work_repo() then
          completer_opts = {
            enable = true,
            get_command = 'gh',
            get_token = get_github_token,
          }
        end
        blink.add_source_provider('github', {
          module = 'blink-cmp-git',
          name = 'Git',
          ---@module 'blink-cmp-git'
          ---@type blink-cmp-git.Options
          opts = {
            commit = { enable = false },
            git_centers = {
              github = {
                mention = completer_opts,
                issue = completer_opts,
                pull_request = completer_opts,
              },
            },
          },
        })
        blink.add_filetype_source('markdown', 'github')
        blink.add_filetype_source('gitcommit', 'github')
        blink.add_filetype_source('jjdescription', 'github')
      end,
    },
  },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      ['<CR>'] = { 'select_and_accept', 'fallback' },
    },
    completion = {
      list = { selection = { preselect = true } },
      menu = { border = 'none' },
      documentation = { window = { border = 'none' } },
    },
    signature = { window = { border = 'none' } },
    cmdline = {
      completion = {
        menu = { auto_show = true },
        list = { selection = { preselect = false } },
      },
    },
  },
}
