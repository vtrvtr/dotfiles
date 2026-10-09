local uv = vim.uv
local script = debug.getinfo(1, "S").source:sub(2)

if vim.env.NVIM_UI_FORMAT_CHILD ~= "1" then
  local env = vim.fn.environ()
  env.NVIM_UI_FORMAT_CHILD = "1"
  local result = vim.system({
    vim.v.progpath,
    "--headless",
    "-u", "NONE",
    "-i", "NONE",
    "-c", "lua dofile(" .. string.format("%q", script) .. ")",
  }, { env = env, text = true }):wait()
  assert(result.code == 0, result.stderr ~= "" and result.stderr or result.stdout)
  io.write(result.stdout)
  return
end

local root = vim.fn.getcwd() .. "/nvim-pack"
local conform_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/conform.nvim"
assert(vim.fn.isdirectory(conform_path) == 1, "real conform.nvim is not installed at " .. conform_path)
vim.opt.runtimepath:append(conform_path)

local formatter = vim.fn.tempname()
vim.fn.writefile({ "#!/bin/sh", "sleep 0.3", "sed 's/original/formatted/g'" }, formatter)
assert(vim.fn.setfperm(formatter, "rwx------") == 1, "could not make formatter executable")

local buffer = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buffer)
vim.bo[buffer].filetype = "ui_format_test"
vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "original" })

require("conform").setup({
  formatters = {
    ui_slow = { command = formatter, stdin = true },
  },
  formatters_by_ft = {
    ui_format_test = { "ui_slow" },
  },
})

vim.g.mapleader = " "
dofile(root .. "/lua/plugins/which-key.lua").init()

local started
local key_processed_ms
local formatted_ms
vim.keymap.set("n", "<F6>", function()
  key_processed_ms = (uv.hrtime() - started) / 1e6
end, { buffer = buffer })

local function finish(code, message)
  vim.fn.delete(formatter)
  local output = code == 0 and io.stdout or io.stderr
  output:write(message .. "\n")
  vim.cmd(code == 0 and "qa!" or "cquit 1")
end

vim.defer_fn(function()
  started = uv.hrtime()
  vim.defer_fn(function()
    vim.api.nvim_input("<F6>")
  end, 50)
  vim.api.nvim_input(" lf")

  local function check()
    if not formatted_ms and vim.api.nvim_buf_get_lines(buffer, 0, 1, false)[1] == "formatted" then
      formatted_ms = (uv.hrtime() - started) / 1e6
    end
    if key_processed_ms and formatted_ms then
      if key_processed_ms >= formatted_ms then
        return finish(1, string.format(
          "queued key ran at %.1fms, not before formatter completion at %.1fms",
          key_processed_ms,
          formatted_ms
        ))
      end
      if key_processed_ms >= 200 then
        return finish(1, string.format("queued key was delayed until %.1fms", key_processed_ms))
      end
      return finish(0, string.format(
        "ok: queued key %.1fms; formatter applied %.1fms",
        key_processed_ms,
        formatted_ms
      ))
    end
    if (uv.hrtime() - started) / 1e6 >= 2000 then
      return finish(1, "timed out waiting for input and formatter")
    end
    vim.defer_fn(check, 10)
  end
  check()
end, 10)
