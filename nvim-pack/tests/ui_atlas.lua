local atlas_path = assert(vim.env.ATLAS_NVIM_PATH, "ATLAS_NVIM_PATH is required")
vim.opt.runtimepath:append(atlas_path)
local dotfiles_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")

local function equal(actual, expected, label)
	assert(vim.deep_equal(actual, expected), (label or "values differ") .. ": " .. vim.inspect(actual) .. " ~= " .. vim.inspect(expected))
end

---@class PendingSystem
---@field cmd string[]
---@field opts table
---@field callback function
local pending = {}
local waited = false
local original_system = vim.system
vim.system = function(cmd, opts, callback)
	assert(callback, "affected UI path attempted a synchronous vim.system call")
	local request = { cmd = cmd, opts = opts or {}, callback = callback }
	table.insert(pending, request)
	return {
		wait = function()
			waited = true
			error(":wait() must not be used by affected UI paths")
		end,
		kill = function() end,
	}
end

local function respond(request, code, stdout, stderr)
	request.callback({ code = code or 0, signal = 0, stdout = stdout or "", stderr = stderr or "" })
end

local function wait_for(predicate, message)
	assert(vim.wait(1000, predicate), message or "timed out")
end

local function shift(name)
	wait_for(function() return #pending > 0 end, "no process for " .. name)
	local request = table.remove(pending, 1)
	assert(table.concat(request.cmd, " "):find(name, 1, true), "unexpected command: " .. table.concat(request.cmd, " "))
	return request
end

-- Apply the real dotfiles setup, including the jj current-branch override.
local spec = dofile(dotfiles_root .. "/lua/plugins/atlas.lua")
spec.config(nil, spec.opts)

local notifications = {}
package.loaded["atlas.core.notify"] = {
	error = function(message) table.insert(notifications, "error:" .. tostring(message)) end,
	warn = function(message) table.insert(notifications, "warn:" .. tostring(message)) end,
	info = function(message) table.insert(notifications, "info:" .. tostring(message)) end,
}

local git = require("atlas.core.git")

-- Pure Git takes the ordinary branch and never invokes jj.
local git_result
git.current_branch("/pure-git", function(branch, err)
	git_result = { branch, err }
end)
respond(shift("rev-parse"), 0, "feature/git\n")
wait_for(function() return git_result ~= nil end)
equal(git_result, { "feature/git", nil }, "pure Git branch")
equal(#pending, 0, "pure Git should not invoke jj")

-- Exercise delayed input while the actual pipeline UI preparation is suspended.
local pipeline_opens = {}
package.loaded["atlas.pulls.pipelines"] = {
	get = function() return true end,
	open = function(target) table.insert(pipeline_opens, target) end,
}
local providers = require("atlas.providers")
local original_load = providers.load
providers.load = function() return {} end
package.loaded["atlas.commands.pipelines"] = nil
local pipeline_command = require("atlas.commands.pipelines")
local key_seen = false
vim.keymap.set("n", "x", function() key_seen = true end)
pipeline_command.open(".")
local root_request = shift("rev-parse")
vim.api.nvim_feedkeys("x", "xt", false)
wait_for(function() return key_seen end, "mapped key was blocked during preparation")
respond(root_request, 0, "/repo-one\n")
respond(shift("rev-parse"), 0, "feature/jj\n")
respond(shift("remote"), 0, "git@github.com:owner/repo.git\n")
wait_for(function() return #pipeline_opens == 1 end, "pipeline did not open")
equal(pipeline_opens[1].target, "feature/jj", "pipeline branch")

-- Cwd is captured at invocation and an older preparation cannot open stale UI.
local cwd_one, cwd_two = vim.fn.tempname(), vim.fn.tempname()
vim.fn.mkdir(cwd_one, "p")
vim.fn.mkdir(cwd_two, "p")
vim.cmd.cd(vim.fn.fnameescape(cwd_one))
pipeline_command.open(".")
local stale_root = shift("rev-parse")
equal(stale_root.cmd[3], cwd_one, "captured cwd")
vim.cmd.cd(vim.fn.fnameescape(cwd_two))
pipeline_command.open(".")
local current_root = shift("rev-parse")
respond(stale_root, 0, "/stale\n")
vim.wait(20)
equal(#pending, 0, "obsolete invocation continued")
respond(current_root, 0, "/current\n")
respond(shift("rev-parse"), 0, "feature/current\n")
respond(shift("remote"), 0, "git@github.com:owner/repo.git\n")
wait_for(function() return #pipeline_opens == 2 end)
equal(pipeline_opens[2].target, "feature/current", "new invocation wins")

-- Detached jj repositories: success, zero/multiple names, and process failure.
local original_executable, original_isdirectory = vim.fn.executable, vim.fn.isdirectory
vim.fn.executable = function(name) return name == "jj" and 1 or original_executable(name) end
vim.fn.isdirectory = function(path)
	if path:match("/%.jj$") then return 1 end
	return original_isdirectory(path)
end
local function jj_case(stdout, code, stderr)
	local result
	git.current_branch("/jj-repo", function(branch, err)
		result = { branch, err }
	end)
	respond(shift("rev-parse"), 0, "HEAD\n")
	local request = shift("jj --repository /jj-repo --ignore-working-copy --color never bookmark list")
	equal(request.cmd[#request.cmd], 'name ++ "\n"', "jj template")
	respond(request, code or 0, stdout or "", stderr or "")
	wait_for(function() return result ~= nil end)
	return result
end
equal(jj_case("topic\ntopic\n"), { "topic", nil }, "jj bookmark")
local zero = jj_case("")
assert(zero[1] == nil and zero[2]:find("No jj bookmark", 1, true), vim.inspect(zero))
local multiple = jj_case("zeta\nalpha\n")
assert(multiple[1] == nil and multiple[2]:find("alpha, zeta", 1, true), vim.inspect(multiple))
local failed = jj_case("", 2, "fixture failed\n")
assert(failed[1] == nil and failed[2]:find("fixture failed", 1, true), vim.inspect(failed))
vim.fn.executable, vim.fn.isdirectory = original_executable, original_isdirectory

-- Full PR preparation traverses all git/description subprocess boundaries asynchronously.
local pr = require("atlas.pulls.create.pr")
local pr_opens = {}
pr.open = function(opts) table.insert(pr_opens, opts) end
vim.cmd.cd(vim.fn.fnameescape(cwd_one))
pr.start()
respond(shift("rev-parse"), 0, cwd_one .. "\n")
respond(shift("rev-parse"), 0, "feature/pr\n")
respond(shift("remote"), 0, "git@github.com:owner/repo.git\n")
respond(shift("symbolic-ref"), 0, "refs/remotes/origin/main\n")
respond(shift("branch -r"), 0, "origin/main\norigin/other\n")
-- commit_range revisions
respond(shift("rev-parse"), 0, "basehash\n")
respond(shift("rev-parse"), 0, "headhash\n")
respond(shift("git -C"), 0, "abc123 fix: async UI\n") -- log
-- diff_stat revisions and diff
respond(shift("rev-parse"), 0, "basehash\n")
respond(shift("rev-parse"), 0, "headhash\n")
respond(shift("diff"), 0, " file.lua | 1 +\n")
respond(shift("remote"), 0, "git@github.com:owner/repo.git\n")
wait_for(function() return #pr_opens == 1 end, "PR form did not open")
equal(pr_opens[1].head, "feature/pr", "PR head")
equal(pr_opens[1].base, "main", "PR base")
assert(pr_opens[1].initial_body:find("async UI", 1, true), "description was not built")

assert(not waited, "a process wait occurred")
assert(#pending == 0, "unanswered process fixtures: " .. #pending)
providers.load = original_load
vim.system = original_system
print("ui_atlas: ok")
