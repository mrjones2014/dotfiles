-- Statusline and winbar, ported from my old hand-written heirline config.
-- astroui builtins are used where they match (file icon, diagnostics, breadcrumbs);
-- the bubble separators, mode icons and toggle chips are bespoke because no distro
-- component produces that shape.

local ROUNDED_LEFT = ''
local ROUNDED_RIGHT = ''

local function relpath(p)
  return vim.fn.fnamemodify(p, ':~:.') or p
end

local function is_tempfile(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return vim.startswith(name, '/tmp')
    or vim.startswith(name, '/private/tmp')
    or vim.startswith(name, '/var/folders/')
    or vim.startswith(name, '/private/var/folders/')
end

local function copy_to_clipboard(str)
  vim.fn.setreg('+', str)
  vim.notify(('Copied %s'):format(str))
end

local function autoformat_enabled()
  return vim.F.if_nil(vim.b.autoformat, vim.g.autoformat, true)
end

local function has_formatter()
  local ok, conform = pcall(require, 'conform')
  if ok and #conform.list_formatters_for_buffer(0) > 0 then
    return true
  end
  return #vim.lsp.get_clients({ bufnr = 0, method = vim.lsp.protocol.Methods.textDocument_formatting }) > 0
end

---Clickable toggle chip: `<icon> <switch> <label>`. The whole chip is the click
---target, not just the switch.
local function toggle_chip(icon, label, check_fn, toggle_fn, id)
  return {
    hl = { bg = 'surface0' },
    on_click = { callback = toggle_fn, name = 'heirline_toggle_' .. id },
    provider = function()
      return string.format(' %s %s %s ', check_fn() and '' or '', icon, label)
    end,
  }
end

---@type LazySpec
return {
  {
    'AstroNvim/astroui',
    ---@type AstroUIOpts
    opts = {
      status = {
        winbar = {
          -- NOTE: no `enabled` block. astroui checks `enabled` first and returns early
          -- on a match, which would force the winbar on for every normal-buftype buffer
          -- and make the `disabled` list below dead code (jjdescription, help, ...).
          disabled = {
            filetype = {
              'codecompanion', -- codecompanion draws its own winbar
              'Trouble',
              'snacks_picker_input',
              'snacks_picker_list',
              'snacks_picker_preview',
              'help',
              'dbui',
              'jjdescription',
              'minifiles',
            },
          },
        },
      },
    },
  },
  {
    'rebelot/heirline.nvim',
    opts = function(_, opts)
      local status = require('astroui.status')
      local conditions = require('heirline.conditions')
      local tn = require('tokyonight.colors').setup()

      opts.opts = opts.opts or {}

      local astro_disable_winbar_cb = opts.opts.disable_winbar_cb
      opts.opts.disable_winbar_cb = function(args)
        if vim.api.nvim_win_get_config(0).relative ~= '' then
          return true
        end
        return astro_disable_winbar_cb and astro_disable_winbar_cb(args) or false
      end

      opts.opts.colors = vim.tbl_deep_extend('force', opts.opts.colors or {}, {
        black = tn.bg_dark,
        gray = tn.dark5,
        -- statusline text. The old config set no root fg, so it inherited `StatusLine`,
        -- which tokyonight sets to fg_dark. Matching that exactly.
        text = tn.fg_dark,
        green = tn.green,
        blue = tn.blue,
        cyan = tn.cyan,
        -- the old config referenced orange/purple without defining them
        orange = tn.orange,
        purple = tn.purple,
        yellow = tn.terminal.yellow_bright,
        base = tn.bg,
        surface0 = tn.fg_gutter,
        surface1 = tn.dark3,
        surface2 = tn.blue7,
      })

      local Align = { provider = '%=', hl = { bg = 'surface0' } }

      local Mode = {
        init = function(self)
          self.mode = vim.fn.mode(0):lower()
        end,
        static = {
          mode_icons = {
            n = '',
            v = '',
            ['\22'] = '',
            ['\22s'] = '',
            s = '󱐁',
            ['\19'] = '󱐁',
            i = '',
            r = '',
            c = '',
            ['!'] = '',
            t = '',
          },
          mode_colors = {
            n = 'green',
            i = 'blue',
            v = 'yellow',
            ['\22'] = 'cyan',
            c = 'orange',
            s = 'yellow',
            ['\19'] = 'orange',
            r = 'purple',
            ['!'] = 'green',
            t = 'green',
          },
        },
        {
          provider = function(self)
            return string.format(' %s ', self.mode_icons[self.mode] or self.mode_icons.n)
          end,
          hl = function(self)
            local mode = self.mode:sub(1, 1)
            return { bg = self.mode_colors[mode] or 'green', fg = 'black', bold = true }
          end,
        },
        {
          provider = ROUNDED_RIGHT,
          hl = function(self)
            local mode = self.mode:sub(1, 1)
            return { fg = self.mode_colors[mode] or 'green', bg = 'surface0' }
          end,
        },
      }

      -- keep showing the last real file when focus moves to a non-file buffer
      local active_buffer_id = nil

      local FileInfo = {
        init = function(self)
          local is_file = vim.uv.fs_stat(vim.api.nvim_buf_get_name(0)) ~= nil
          if is_file then
            active_buffer_id = vim.api.nvim_get_current_buf()
          elseif
            not (
              active_buffer_id ~= nil
              and vim.iter(vim.api.nvim_list_wins()):map(vim.api.nvim_win_get_buf):any(function(buf)
                return buf == active_buffer_id
              end)
            )
          then
            active_buffer_id = nil
          end
          self.bufnr = active_buffer_id or vim.api.nvim_get_current_buf()
          self.bufname = vim.api.nvim_buf_get_name(self.bufnr)
          self.temporary = is_tempfile(self.bufnr)
        end,
        {
          hl = { bg = 'surface0' },
          {
            condition = function(self)
              return self.temporary
            end,
            provider = ' 󰪺',
          },
        },
        status.component.file_info({
          filetype = false,
          filename = false,
          file_modified = false,
          file_read_only = false,
          -- right = 0: the separate ' ' provider below supplies the gap, otherwise
          -- the icon and the path end up two spaces apart
          file_icon = { padding = { left = 1, right = 0 } },
          surround = false,
          hl = { bg = 'surface0' },
        }),
        {
          hl = { bg = 'surface0' },
          provider = ' ',
          {
            provider = function(self)
              if vim.env.JJ_GH == '1' then
                return 'Pull Request'
              end
              if vim.bo.ft == 'jjdescription' then
                return 'JJ Commit'
              end
              return relpath(self.temporary and vim.fn.fnamemodify(self.bufname, ':t') or self.bufname)
            end,
            on_click = {
              callback = function(self)
                copy_to_clipboard(relpath(self.bufname))
              end,
              name = 'heirline_copy_filepath_statusline',
            },
          },
        },
      }

      local UnsavedChanges = {
        init = function(self)
          self.unsaved = #vim
            .iter(vim.api.nvim_list_bufs())
            :filter(function(buf)
              return vim.bo[buf].ft ~= 'minifiles'
                and vim.bo[buf].ft ~= 'dap-repl'
                and vim.bo[buf].bt ~= 'acwrite'
                and vim.bo[buf].modifiable
                and vim.bo[buf].modified
                and vim.bo[buf].buflisted
            end)
            :totable()
        end,
        {
          condition = function(self)
            return self.unsaved > 0
          end,
          { provider = ROUNDED_LEFT, hl = { fg = 'yellow', bg = 'surface0' } },
          {
            provider = function(self)
              return string.format('  %s', self.unsaved)
            end,
            hl = { bg = 'yellow', fg = 'black' },
          },
          { provider = ROUNDED_RIGHT, hl = { fg = 'yellow', bg = 'surface0' } },
        },
      }

      local RecordingMacro = {
        provider = function()
          local reg = vim.fn.reg_recording()
          if reg == '' then
            return ''
          end
          return string.format(' Recording macro: %s  ', reg)
        end,
        hl = { bg = 'surface0' },
      }

      local LspFormatToggle = toggle_chip('󰗈', 'Formatting', function()
        return has_formatter() and autoformat_enabled()
      end, function()
        vim.b.autoformat = not autoformat_enabled()
      end, 'format')

      local SpellCheckToggle = toggle_chip('󰓆', 'Spellcheck', function()
        return vim.o.spell
      end, function()
        require('astrocore.toggles').spell()
      end, 'spell')

      local NixShell = {
        condition = function()
          return (vim.env.IN_NIX_SHELL or '') ~= ''
        end,
        { provider = ROUNDED_LEFT, hl = { fg = 'blue', bg = 'surface0' } },
        { provider = '   ', hl = { bg = 'blue', fg = 'surface0' } },
      }

      -- astroui's breadcrumbs component only ever colours the icon (and only when
      -- `icon_highlights.breadcrumbs` is on); the symbol names stay uncoloured. The old
      -- navic config coloured both, so this rebuilds it with that kind -> highlight map.
      local kind_hl = {
        File = 'Directory',
        Module = '@include',
        Namespace = '@namespace',
        Package = '@include',
        Class = '@structure',
        Method = '@method',
        Property = '@property',
        Field = '@field',
        Constructor = '@constructor',
        Enum = '@field',
        Interface = '@type',
        Function = '@function',
        Variable = '@variable',
        Constant = '@constant',
        String = '@string',
        Number = '@number',
        Boolean = '@boolean',
        Array = '@field',
        Object = '@type',
        Key = '@keyword',
        Null = '@comment',
        EnumMember = '@field',
        Struct = '@structure',
        Event = '@keyword',
        Operator = '@operator',
        TypeParameter = '@type',
      }

      local Breadcrumbs = {
        condition = function()
          return status.condition.aerial_available()
        end,
        update = 'CursorMoved',
        hl = { bg = 'surface0' },
        init = function(self)
          local data = require('aerial').get_location(true) or {}
          local children = {}
          for i, d in ipairs(data) do
            -- pull fg off the treesitter group but keep the winbar background
            local group = kind_hl[d.kind]
            local hl = group and { fg = require('astroui').get_hlgroup(group).fg, bg = 'surface0' }
              or { bg = 'surface0' }
            local child = {
              { provider = string.format('%s ', d.icon or ''), hl = hl },
              { provider = (d.name or ''):gsub('%%', '%%%%'):gsub('%s*->%s*', ''), hl = hl },
            }
            if #data > 1 and i < #data then
              table.insert(child, { provider = ' > ', hl = { bg = 'surface0' } })
            end
            table.insert(children, child)
          end
          self.child = self:new(children, 1)
        end,
        provider = function(self)
          return string.format(' %s', self.child:eval())
        end,
      }

      local Tabs = {
        -- only show when there are 2 or more tabpages
        condition = function()
          return #vim.api.nvim_list_tabpages() >= 2
        end,
        status.heirline.make_tablist({
          provider = function(self)
            return string.format(' 󱥟 %s ', self.tabpage)
          end,
          hl = function(self)
            if self.is_active then
              return { bg = 'cyan', fg = 'surface0' }
            end
            return { bg = 'surface1' }
          end,
          on_click = {
            callback = function(self)
              vim.api.nvim_set_current_tabpage(self.tabnr)
            end,
            name = function(self)
              return 'heirline_switch_tab_' .. tostring(self.tabnr)
            end,
          },
        }),
      }

      opts.statusline = {
        hl = { fg = 'text', bg = 'surface0' },
        Tabs,
        Mode,
        FileInfo,
        Align,
        UnsavedChanges,
        RecordingMacro,
        LspFormatToggle,
        SpellCheckToggle,
        NixShell,
      }

      -- `showtabline = 0` only hides it; heirline still builds and evaluates the
      -- bufferline. Drop it so nothing renders if showtabline is ever turned back on.
      opts.tabline = nil

      opts.winbar = {
        init = function(self)
          self.bufnr = vim.api.nvim_get_current_buf()
        end,
        -- filename bubble on `base`, rounded off into whatever section comes next
        {
          status.component.file_info({
            unique_path = {},
            filename = { modify = ':t' },
            filetype = false,
            file_read_only = false,
            file_modified = { padding = { left = 1 } },
            surround = false,
            hl = { bg = 'base' },
          }),
          {
            provider = ROUNDED_RIGHT,
            hl = function()
              return { fg = 'base', bg = conditions.has_diagnostics() and 'surface1' or 'surface0' }
            end,
          },
        },
        -- diagnostic counts on `surface1`, rounded off into `surface0`
        {
          condition = conditions.has_diagnostics,
          status.component.diagnostics({ surround = false, hl = { bg = 'surface1' } }),
          { provider = ROUNDED_RIGHT, hl = { fg = 'surface1', bg = 'surface0' } },
        },
        { provider = '%<' },
        Breadcrumbs,
        { provider = '%=', hl = { bg = 'surface0' } },
      }

      return opts
    end,
  },
}
