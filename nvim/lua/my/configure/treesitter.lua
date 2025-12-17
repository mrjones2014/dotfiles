local function sto(selector, query_group)
  return function()
    require('nvim-treesitter-textobjects.select').select_textobject(selector, query_group)
  end
end

return {
  {
    'calops/hmts.nvim',
    version = '*',
    ft = 'nix',
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    event = 'BufRead',
    cmd = { 'TSInstall', 'TSUpdate', 'TSUpdateSync' },
    build = function()
      if #vim.api.nvim_list_uis() == 0 then
        -- update sync if running headless
        vim.cmd.TSUpdateSync()
      else
        -- otherwise update async
        vim.cmd.TSUpdate()
      end
    end,
    dependencies = {
      {
        'hiphish/rainbow-delimiters.nvim',
        config = function()
          local rainbow = require('rainbow-delimiters')
          vim.g.rainbow_delimiters = {
            strategy = {
              [''] = rainbow.strategy['global'],
              vim = rainbow.strategy['local'],
            },
            query = {
              [''] = 'rainbow-delimiters',
              lua = 'rainbow-blocks',
              html = 'rainbow-tags',
            },
            highlight = {
              'RainbowDelimiterRed',
              'RainbowDelimiterYellow',
              'RainbowDelimiterBlue',
              'RainbowDelimiterOrange',
              'RainbowDelimiterGreen',
              'RainbowDelimiterViolet',
              'RainbowDelimiterCyan',
            },
          }
        end,
      },
      {
        'JoosepAlviste/nvim-ts-context-commentstring',
        init = function()
          vim.g.skip_ts_context_commentstring_module = true
        end,
        opts = {},
      },
      {
        'andymass/vim-matchup',
        init = function()
          vim.g.matchup_matchparen_offscreen = {
            method = 'popup',
          }
        end,
      },
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        opts = {},
        keys = {
          { 'af', sto('@function.outer'), mode = { 'x', 'o' }, desc = 'function' },
          { 'if', sto('@function.inner'), mode = { 'x', 'o' }, desc = 'function' },
          { 'ac', sto('@class.outer'), mode = { 'x', 'o' }, desc = 'class' },
          { 'ic', sto('@class.inner'), mode = { 'x', 'o' }, desc = 'class' },
          { 'as', sto('@local.scope', 'locals'), mode = { 'x', 'o' }, desc = 'scope' },
          { 'is', sto('@local.scope', 'locals'), mode = { 'x', 'o' }, desc = 'scope' },
        },
      },
    },
    config = function(plug)
      if vim.fn.executable('tree-sitter') ~= 1 then
        error('tree-sitter CLI is not installed!')
      end
      -- ensure this comes first on runtimepath; see: https://github.com/nvim-treesitter/nvim-treesitter/issues/3092
      vim.opt.rtp:prepend(plug.dir)
      require('nvim-treesitter').install(require('my.ftconfig').treesitter_parsers)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = '*',
        callback = function(ev)
          local ft = ev.match
          local lang = vim.treesitter.language.get_lang(ft)
          if lang and vim.treesitter.language.add(lang) then
            vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
            vim.treesitter.start(ev.buf, lang)
          end
        end,
      })
    end,
  },
}
