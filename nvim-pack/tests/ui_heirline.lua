local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(root)

local configured
local notifications = {}
local original_notify = vim.notify
vim.notify = function(message, level)
	notifications[#notifications + 1] = { message = tostring(message), level = level }
end
package.preload["heirline"] = function()
	return {
		load_colors = function() end,
		setup = function(value)
			configured = value
		end,
	}
end
package.preload["heirline.conditions"] = function()
	return { has_diagnostics = function() return false end }
end
package.preload["heirline.utils"] = function()
	return {}
end
package.preload["theme.colors"] = function()
	return { dark = setmetatable({}, { __index = function() return "#000000" end }) }
end

local calls = {}
local original_system = vim.system
local function record_system(command, options, callback)
	calls[#calls + 1] = { command = command, options = options, callback = callback }
	return {}
end
vim.system = record_system

local spec = dofile(root .. "/lua/plugins/heirline.lua")
spec.config()
assert(configured, "production heirline config did not load")
local statusline = configured.statusline[2]
local version_control = statusline[#statusline]
assert(type(version_control.init) == "function" and type(version_control.provider) == "function", "VersionControl seam not found")

local function call_for(cwd)
	if vim.uv.cwd() ~= cwd then
		vim.cmd.cd(vim.fn.fnameescape(cwd))
	end
	local instance = setmetatable({}, { __index = version_control })
	instance:init()
	return instance
end

local fixtures = vim.fn.tempname()
vim.fn.mkdir(fixtures .. "/a", "p")
vim.fn.mkdir(fixtures .. "/b", "p")
vim.fn.mkdir(fixtures .. "/c", "p")
vim.fn.mkdir(fixtures .. "/git", "p")
vim.fn.mkdir(fixtures .. "/error", "p")
vim.fn.mkdir(fixtures .. "/missing", "p")
vim.fn.mkdir(fixtures .. "/spawn", "p")
vim.fn.mkdir(fixtures .. "/real", "p")
vim.fn.mkdir(fixtures .. "/bin", "p")

local started = vim.uv.hrtime()
local a = call_for(fixtures .. "/a")
local render_ms = (vim.uv.hrtime() - started) / 1e6
assert(#calls == 1, "first render did not start exactly one jj root")
assert(render_ms < 50, string.format("render blocked for %.2fms", render_ms))

call_for(fixtures .. "/a")
assert(#calls == 1, "in-flight refresh was not deduplicated")
calls[1].callback({ code = 0, stdout = "/shared/repo\n", stderr = "" })
assert(#calls == 2 and calls[2].command[5] == "log", "jj log was not started after jj root")
calls[2].callback({ code = 0, stdout = "\nA multiline\ndescription\n", stderr = "" })
a = call_for(fixtures .. "/a")
assert(a:provider():find("A multiline description", 1, true), "empty bookmark or multiline description was lost")

-- A late result for the old cwd may populate its own cache, but must not alter
-- the currently rendered cwd.
local b = call_for(fixtures .. "/b")
local b_root_call = #calls
local c = call_for(fixtures .. "/c")
local c_root_call = #calls
assert(c_root_call == b_root_call + 1, "cwd caches were not independent")
calls[b_root_call].callback({ code = 0, stdout = "/repo/b\n", stderr = "" })
local b_log_call = #calls
calls[b_log_call].callback({ code = 0, stdout = "bookmark-b\nold cwd\n", stderr = "" })
c = call_for(fixtures .. "/c")
assert(c:provider() == "", "late old-cwd result leaked into current cwd")
calls[c_root_call].callback({ code = 0, stdout = "/repo/c\n", stderr = "" })
local c_log_call = #calls
calls[c_log_call].callback({ code = 0, stdout = "bookmark-c\ncurrent cwd\n", stderr = "" })
c = call_for(fixtures .. "/c")
assert(c:provider():find("bookmark-c", 1, true), "current cwd label was not retained")

-- No jj repository is a normal state and retains the Git fallback.
vim.b.gitsigns_status_dict = { head = "main" }
local git = call_for(fixtures .. "/git")
local git_root_call = #calls
calls[git_root_call].callback({ code = 1, stdout = "", stderr = 'Error: There is no jj repo in "."' })
git = call_for(fixtures .. "/git")
assert(git:provider():find("main", 1, true), "no-jj state did not use Git fallback")

local error_instance = call_for(fixtures .. "/error")
local error_root_call = #calls
calls[error_root_call].callback({ code = 0, stdout = "/shared/repo\n", stderr = "" })
local error_log_call = #calls
calls[error_log_call].callback({ code = 2, stdout = "", stderr = "fixture command failed" })
error_instance = call_for(fixtures .. "/error")
assert(error_instance:provider():find("A multiline description", 1, true), "command error discarded last good root label")
assert(vim.wait(200, function()
	for _, message in ipairs(notifications) do
		if message.message:find("fixture command failed", 1, true) then return true end
	end
	return false
end, 1), "real jj command error was not reported")

local notification_count = #notifications
vim.system = function()
	error("ENOENT: no such file or directory (cmd): 'jj'")
end
local missing = call_for(fixtures .. "/missing")
assert(missing:provider():find("main", 1, true), "missing jj did not use Git fallback")
vim.wait(20)
assert(#notifications == notification_count, "missing jj emitted a warning")

vim.system = record_system
local fake_now = vim.uv.now()
local original_now = vim.uv.now
vim.uv.now = function() return fake_now end
local spawn_root_call = #calls + 1
local spawn = call_for(fixtures .. "/spawn")
assert(#calls == spawn_root_call, "spawn fixture root did not start")
calls[spawn_root_call].callback({ code = 0, stdout = "/repo/spawn\n", stderr = "" })
local spawn_log_call = #calls
calls[spawn_log_call].callback({ code = 0, stdout = "spawn-bookmark\nknown good\n", stderr = "" })
fake_now = fake_now + 5001
vim.system = function()
	error("EACCES: permission denied (cmd): 'jj'")
end
spawn = call_for(fixtures .. "/spawn")
assert(spawn:provider():find("spawn-bookmark", 1, true), "root spawn error discarded last good label")
assert(vim.wait(200, function()
	for _, message in ipairs(notifications) do
		if message.message:find("EACCES", 1, true) then return true end
	end
	return false
end, 1), "non-ENOENT spawn failure was not reported")
vim.uv.now = original_now

local real_jj = fixtures .. "/bin/jj"
vim.fn.writefile({
	"#!/bin/sh",
	"sleep 0.15",
	"if [ \"$4\" = root ]; then",
	string.format("  printf '%s\\n'", fixtures .. "/real"),
	"else",
	"  printf 'real-bookmark\\nreal delayed process\\n'",
	"fi",
}, real_jj)
vim.uv.fs_chmod(real_jj, 493)
vim.env.PATH = fixtures .. "/bin:" .. vim.env.PATH
vim.system = original_system
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
vim.api.nvim_win_set_cursor(0, { 1, 0 })
local key_at
local on_key_ns = vim.api.nvim_create_namespace("ui_heirline_input")
vim.on_key(function(key)
	if key == "x" then key_at = vim.uv.hrtime() end
end, on_key_ns)
local real_started = vim.uv.hrtime()
local real = call_for(fixtures .. "/real")
vim.api.nvim_input("x")
local queued = vim.fn.getchar(0)
vim.on_key(nil, on_key_ns)
assert(queued == string.byte("x"), "queued normal-mode input was not received")
assert(key_at, "queued normal-mode input was not handled")
local key_ms = (key_at - real_started) / 1e6
assert(not real:provider():find("real-bookmark", 1, true), "real process unexpectedly completed before queued input")
assert(key_ms < 100, string.format("queued mapped input took %.2fms", key_ms))
assert(vim.wait(1000, function()
	real = call_for(fixtures .. "/real")
	return real:provider():find("real-bookmark", 1, true) ~= nil
end, 5), "real delayed process did not complete")

for _, call in ipairs(calls) do
	assert(call.command[2] == "--ignore-working-copy", "jj query may snapshot the working copy")
	assert(call.command[3] == "--color" and call.command[4] == "never", "jj color was not disabled")
end

vim.fn.delete(fixtures, "rf")
vim.system = original_system
vim.notify = original_notify
print(string.format("ui_heirline: ok (render %.2fms, queued key %.2fms, %d controlled async calls)", render_ms, key_ms, #calls))
vim.cmd("qa!")
