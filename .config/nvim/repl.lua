local node_types = {
  'function_declaration',
  'struct_item',
  'interface_declaration',
  'export_statement',
  'lexical_declaration',
}

local function check_node_type(node)
  for _, node_type in pairs(node_types) do
    if node_type == node:type() then
      return true
    end
  end
  return false
end

local ts = require('nvim-treesitter.ts_utils')
local current_node = ts.get_node_at_cursor
local max_iters = 20
local i = 0
while i < max_iters and not check_node_type(current_node) do
  current_node = current_node:parent()
  i = i + 1
end
print(current_node:range())
print(current_node:type())
