local root = vim.fs.joinpath(vim.fn.getcwd(), "nvim-pack")
local enabled = { lua_ls = true, pyrefly = true }
local calls = {}
local maps = {}

vim.lsp = {
  protocol = {
    make_client_capabilities = function()
      return { workspace = { didChangeWatchedFiles = {} } }
    end,
  },
  buf = {},
  config = function() end,
  enable = function(names, value)
    names = type(names) == "table" and names or { names }
    calls[#calls + 1] = { names = names, value = value }
  end,
  get_clients = function()
    return {
      { name = "pyrefly" },
      { name = "lua_ls" },
      { name = "pyrefly" },
      { name = "manually_started" },
    }
  end,
  is_enabled = function(name)
    return enabled[name] == true
  end,
}
vim.keymap = {
  set = function(_, lhs, rhs)
    maps[lhs] = rhs
  end,
}
vim.diagnostic = {
  jump = function() end,
  open_float = function() end,
}
vim.schedule = function(callback)
  callback()
end

require("package").loaded["blink.cmp"] = nil
dofile(vim.fs.joinpath(root, "lua", "plugins", "lsp.lua")).config()

local restart = assert(maps["<leader>ls"], "<leader>ls is not mapped")
restart()

assert(#calls == 4, "expected startup plus disable/enable calls")
local disabled = calls[3]
local reenabled = calls[4]
assert(disabled.value == false, "clients were not disabled")
assert(reenabled.value == nil or reenabled.value == true, "clients were not re-enabled")
assert(table.concat(disabled.names, ",") == "lua_ls,pyrefly", "restart names were not unique and sorted")
assert(table.concat(reenabled.names, ",") == "lua_ls,pyrefly", "re-enabled names differ")

print("ok: <leader>ls restarts every enabled active LSP config")
