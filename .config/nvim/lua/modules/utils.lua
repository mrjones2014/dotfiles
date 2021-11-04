local M = {}

function M.filter(subject, predicate)
  local filtered = {}
  for k, v in pairs(subject) do
    if predicate(k, v, subject) then
      table.insert(filtered, v)
    end
  end

  return filtered
end

return M
