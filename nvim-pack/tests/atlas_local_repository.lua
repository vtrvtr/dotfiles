local atlas_path = assert(vim.env.ATLAS_NVIM_PATH, "ATLAS_NVIM_PATH is required")
vim.opt.runtimepath:append(atlas_path)
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")

local pending
local original_system = vim.system
vim.system = function(cmd, opts, callback)
	pending = { cmd = cmd, opts = opts or {}, callback = callback }
	return { pid = 1, kill = function() end }
end

local spec = dofile(root .. "/lua/plugins/atlas.lua")
spec.config(nil, spec.opts)
local result, result_error
local handle = require("atlas.core.git").local_repository("/repo", function(info, err)
	result, result_error = info, err
end)
assert(handle and handle.cancel, "Request handle was not preserved")
assert(pending and pending.cmd[1] == "git", vim.inspect(pending))
pending.callback({ code = 0, signal = 0, stdout = "git@github.com:owner/repo.git\n", stderr = "" })
assert(vim.wait(1000, function() return result ~= nil or result_error ~= nil end), "Repository lookup timed out")
assert(result_error == nil, result_error)
assert(result.repo_full_name == "owner/repo", vim.inspect(result))

vim.system = original_system
print("Atlas local repository checks passed")
vim.cmd("qa!")
