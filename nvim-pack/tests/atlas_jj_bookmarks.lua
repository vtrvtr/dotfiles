local atlas_path = assert(vim.env.ATLAS_NVIM_PATH, "ATLAS_NVIM_PATH is required")
vim.opt.runtimepath:append(atlas_path)
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")

local pending = {}
local kill_error
local original_system = vim.system
vim.system = function(cmd, opts, callback)
	local request = { cmd = cmd, opts = opts or {}, callback = callback }
	table.insert(pending, request)
	return {
		pid = 1,
		kill = function()
			request.cancelled = true
			if kill_error then error(kill_error) end
		end,
	}
end

local function shift(program)
	assert(vim.wait(1000, function() return #pending > 0 end), "No request for " .. program)
	local request = table.remove(pending, 1)
	assert(request.cmd[1] == program, vim.inspect(request.cmd))
	return request
end

local function respond(request, code, stdout, stderr)
	request.callback({ code = code, signal = 0, stdout = stdout or "", stderr = stderr or "" })
end

local original_executable, original_isdirectory = vim.fn.executable, vim.fn.isdirectory
vim.fn.executable = function(name) return name == "jj" and 1 or original_executable(name) end
vim.fn.isdirectory = function(path)
	if path == "/repo/.jj" then return 1 end
	return original_isdirectory(path)
end

local spec = dofile(root .. "/lua/plugins/atlas.lua")
spec.config(nil, spec.opts)
local git = require("atlas.core.git")
local branch, branch_error
git.current_branch("/repo", function(value, err)
	branch, branch_error = value, err
end)
respond(shift("git"), 0, "HEAD\n")
local jj = shift("jj")
assert(jj.cmd[#jj.cmd] == 'name ++ "\n"', vim.inspect(jj.cmd))
respond(jj, 0, "feature/atlas\n")
assert(vim.wait(1000, function() return branch ~= nil or branch_error ~= nil end), "Branch lookup timed out")
assert(branch == "feature/atlas" and branch_error == nil, vim.inspect({ branch, branch_error }))

local notifications = {}
local original_notify = vim.notify
vim.notify = function(message, level)
	table.insert(notifications, { message = message, level = level })
end
local cancelled = git.current_branch("/repo", function() error("Cancelled lookup completed") end)
respond(shift("git"), 0, "HEAD\n")
shift("jj")
kill_error = "fixture kill failed"
cancelled.cancel()
assert(#notifications == 1, vim.inspect(notifications))
assert(notifications[1].message:find(kill_error, 1, true), notifications[1].message)
vim.notify = original_notify

vim.fn.executable, vim.fn.isdirectory = original_executable, original_isdirectory
vim.system = original_system
print("Atlas jj bookmark checks passed")
vim.cmd("qa!")
