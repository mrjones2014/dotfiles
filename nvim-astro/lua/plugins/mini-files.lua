---@type LazySpec
return {
  { import = 'astrocommunity.file-explorer.mini-files' },
  {
    'echasnovski/mini.files',
    lazy = true,
    opts = {
      mappings = {
        go_in_plus = '<CR>',
      },
      windows = {
        preview = true,
        width_preview = 120,
      },
      options = { permanent_delete = false },
    },
  },
  {
    'AstroNvim/astrocore',
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          ['<Leader>e'] = {
            function()
              local minifiles = require('mini.files')
              if vim.bo.filetype == 'minifiles' then
                minifiles.close()
                return
              end
              local file = vim.api.nvim_buf_get_name(0)
              minifiles.open(vim.fn.filereadable(file) ~= 0 and file or nil)
              minifiles.reveal_cwd()
            end,
            desc = 'Explorer',
          },
        },
      },
      autocmds = {
        mini_files_close_keys = {
          {
            event = 'User',
            pattern = 'MiniFilesBufferCreate',
            desc = 'Close mini.files with q or <Esc>',
            callback = function(args)
              for _, key in ipairs({ 'q', '<Esc>' }) do
                vim.keymap.set('n', key, function()
                  require('mini.files').close()
                end, { buffer = args.data.buf_id, desc = 'Close mini.files' })
              end
            end,
          },
        },
      },
    },
  },
}
