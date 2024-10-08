local M = {}

function M.enable_on_linux()
  local os = string.lower(jit.os)
  if os ~= "windows" then
    return true
  else
    return false
  end
end

function M.is_win()
  local os = string.lower(jit.os)
  if os ~= "windows" then
    return false
  else
    return true
  end
end

return M
