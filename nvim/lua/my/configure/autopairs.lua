local function is_not_inside_nix_list()
  local node = require('nvim-treesitter.ts_utils').get_node_at_cursor(0)
  if not node then
    return false
  end
  if node:type() == 'list_expression' then
    return false
  end
  -- if top-level, then don't add `;`
  local parent = node:parent()
  if not parent then
    return false
  end
  -- check a maximum of 2 parents
  for _ = 1, 2 do
    if not parent then
      return true
    end
    if parent:type() == 'list_expression' then
      return false
    end
    parent = parent:parent()
  end
  return true
end
return {
  'windwp/nvim-autopairs',
  event = { 'InsertEnter' },
  config = function()
    local Rule = require('nvim-autopairs.rule')
    local npairs = require('nvim-autopairs')
    npairs.setup({})
    npairs.add_rules({
      Rule('{', '};', 'nix'):with_pair(is_not_inside_nix_list),
      Rule('[', '];', 'nix'):with_pair(is_not_inside_nix_list), -- TODO why doesn't this one work?
    })
  end,
}
