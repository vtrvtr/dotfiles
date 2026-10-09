local function fail(message)
  error(message, 0)
end

local function eq(expected, actual, message)
  if not vim.deep_equal(expected, actual) then
    fail((message or "values differ") .. "\nexpected: " .. vim.inspect(expected) .. "\nactual: " .. vim.inspect(actual))
  end
end

local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp .. "/bin", "p")
local mode_file = tmp .. "/mode"
local calls_file = tmp .. "/calls"
local rustc = tmp .. "/bin/rustc"
vim.fn.writefile({
  "#!/bin/sh",
  'printf "%s\\n" "$PWD" >> "' .. calls_file .. '"',
  "sleep 0.20",
  'mode=$(cat "' .. mode_file .. '")',
  '[ "$mode" = fail ] && { echo "fixture rustc failed" >&2; exit 9; }',
  '[ "$mode" = empty ] && exit 0',
  'printf "/fixture/sysroot\\n"',
}, rustc)
vim.fn.setfperm(rustc, "rwx------")
vim.env.PATH = tmp .. "/bin:" .. vim.env.PATH
vim.fn.writefile({ "success" }, mode_file)

local dap = {
  ABORT = {},
  adapters = {},
  configurations = {},
  listeners = { on_config = {} },
}
package.loaded.dap = dap
package.preload["mason-nvim-dap"] = function()
  return { setup = function() end }
end

local spec = dofile("nvim-pack/lua/plugins/dap.lua")
spec.config(nil, {})
eq(0, vim.fn.filereadable(calls_file), "plugin load spawned rustc")

local on_config = assert(dap.listeners.on_config["rust.lldb_formatters"])
local untouched = { type = "python", marker = {} }
eq(untouched, on_config(untouched), "non-lldb config changed")
eq(0, vim.fn.filereadable(calls_file), "non-lldb config spawned rustc")

local notifications = {}
vim.notify = function(message, level)
  table.insert(notifications, { message = message, level = level })
end

local function invoke(caller, config)
  local outcome = { requests = 0 }
  local co = coroutine.create(function()
    outcome.config = on_config(config)
    -- run() scans the returned config before this point; restart() does not.
    -- A raised resolution error must prevent both callers reaching their request.
    if caller == "initial" or caller == "restart" then
      outcome.requests = outcome.requests + 1
    end
  end)
  local ok, err = coroutine.resume(co)
  if not ok then
    outcome.error = err
  elseif coroutine.status(co) ~= "dead" then
    outcome.yielded = true
    if not vim.wait(5000, function()
      return coroutine.status(co) == "dead"
    end, 10) then
      fail(caller .. " fixture timed out")
    end
  end
  return outcome
end

local input_processed = false
vim.keymap.set("n", "<F6>", function()
  input_processed = true
end)
vim.defer_fn(function()
  vim.api.nvim_feedkeys(vim.keycode("<F6>"), "xt", false)
end, 40)
local success = invoke("initial", { type = "lldb", cwd = tmp, initCommands = { "existing command" } })
eq(true, success.yielded, "sysroot discovery did not yield")
eq(true, input_processed, "queued input was blocked during sysroot discovery")
eq(1, success.requests, "successful initial launch did not reach adapter request")
eq({
  'command script import "/fixture/sysroot/lib/rustlib/etc/lldb_lookup.py"',
  'command source -s 0 "/fixture/sysroot/lib/rustlib/etc/lldb_commands"',
  'command script import "' .. vim.fn.stdpath("config") .. '/lldb/rust_prettifier_for_lldb.py"',
  'command script import "' .. vim.fn.stdpath("config") .. '/lldb/compact_str.py"',
  "existing command",
}, success.config.initCommands, "formatter imports/order changed")
eq(tmp, vim.fn.readfile(calls_file)[1], "rustc did not use concrete debug cwd")

vim.fn.writefile({ "fail" }, mode_file)
local failed_initial = invoke("initial", { type = "lldb", cwd = tmp })
eq(0, failed_initial.requests, "failed initial resolution reached adapter request")
eq(nil, failed_initial.config, "failed initial resolution produced usable config")
local initial_notice = notifications[#notifications] and notifications[#notifications].message or ""
eq(true, initial_notice:find("Unable to resolve Rust sysroot", 1, true) ~= nil, "initial failure was not actionable")

vim.fn.writefile({ "empty" }, mode_file)
local failed_restart = invoke("restart", { type = "lldb", cwd = "${workspaceFolder}" })
eq(0, failed_restart.requests, "failed restart resolution reached restart request")
eq(nil, failed_restart.config, "failed restart resolution produced usable config")
local restart_notice = notifications[#notifications] and notifications[#notifications].message or ""
eq(true, restart_notice:find("rustc returned no sysroot", 1, true) ~= nil, "restart failure was not actionable")
local calls = vim.fn.readfile(calls_file)
eq(vim.fn.getcwd(), calls[#calls], "placeholder cwd did not fall back to current cwd")

vim.env.PATH = tmp
local missing = invoke("restart", { type = "lldb", cwd = tmp })
eq(0, missing.requests, "spawn failure reached restart request")
eq(nil, missing.config, "spawn failure produced usable config")
eq(true, missing.error:find("Unable to start `rustc --print sysroot`", 1, true) ~= nil, "spawn failure was not actionable")

vim.fn.delete(tmp, "rf")
print("ui_dap: ok")
