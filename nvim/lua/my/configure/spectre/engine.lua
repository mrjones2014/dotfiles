local spectre_search = require('spectre.search')
local spectre_state = require('spectre.state')
local spectre_state_utils = require('spectre.state_utils')
local spectre_utils = require('spectre.utils')

local Tree = require('nui.tree')

local M = {}

function M.process(options)
  options = options or {}

  return vim
    .iter(spectre_state.groups)
    :map(function(filename, group)
      local children = vim
        .iter(ipairs(group))
        :map(function(_, entry)
          local id = tostring(math.random())

          local diff = spectre_utils.get_hl_line_text({
            search_query = options.search_query,
            replace_query = options.replace_query,
            search_text = entry.text,
            padding = 0,
          }, spectre_state.regex)

          return Tree.Node({ text = diff.text, _id = id, diff = diff, entry = entry })
        end)
        :totable()

      local id = tostring(math.random())
      local node = Tree.Node({ text = filename:gsub('^./', ''), _id = id }, children)

      node:expand()

      return node
    end)
    :totable()
end

local function search_handler(options, signal)
  local start_time = 0
  local total = 0

  spectre_state.groups = {}

  return {
    on_start = function()
      spectre_state.is_running = true
      start_time = vim.loop.hrtime()
    end,
    on_result = function(item)
      if not spectre_state.is_running then
        return
      end

      if not spectre_state.groups[item.filename] then
        spectre_state.groups[item.filename] = {}
      end

      table.insert(spectre_state.groups[item.filename], item)
      total = total + 1
    end,
    on_error = function(_) end,
    on_finish = function()
      if not spectre_state.is_running then
        return
      end

      local end_time = (vim.loop.hrtime() - start_time) / 1E9

      signal.search_results = M.process(options)
      signal.search_info = string.format('Total: %s match, time: %ss', total, end_time)

      spectre_state.finder_instance = nil
      spectre_state.is_running = false
    end,
  }
end

function M.stop()
  if not spectre_state.finder_instance then
    return
  end

  spectre_state.finder_instance:stop()
  spectre_state.finder_instance = nil
end

function M.search(options, signal)
  options = options or {}

  M.stop()

  local search_engine = spectre_search['rg']
  spectre_state.options['ignore-case'] = not options.is_case_insensitive_checked
  spectre_state.finder_instance =
    search_engine:new(spectre_state_utils.get_search_engine_config(), search_handler(options, signal))
  spectre_state.regex = require('spectre.regex.vim')

  pcall(function()
    spectre_state.finder_instance:search({
      cwd = vim.fn.getcwd(),
      search_text = options.search_query,
      replace_query = options.replace_query,
      -- path = spectre_state.query.path,
      search_paths = #options.search_paths > 0 and options.search_paths or nil,
    })
  end)
end

return M
