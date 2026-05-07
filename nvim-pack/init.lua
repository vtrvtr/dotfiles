-- Capture startup time for the dashboard (ns)
vim.g.start_time = vim.uv.hrtime()
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.g.ui_enter_ms = (vim.uv.hrtime() - vim.g.start_time) / 1e6
  end,
})

-- Leader keys (must be set before zpack so keymaps in specs see them)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.laststatus = 3   -- single global statusline
vim.opt.cmdheight = 1    -- minimum height for command line to avoid E36
vim.opt.ruler = false    -- handled by statusline
vim.opt.showmode = false -- mode shown in statusline

-- Keep cursor centered
vim.opt.scrolloff = 999  -- keep cursor centered vertically
vim.opt.sidescrolloff = 8 -- keep some context on sides

-- Bootstrap zpack.nvim via Neovim 0.12+ vim.pack
vim.pack.add({ "https://github.com/zuqini/zpack.nvim" })

-- Load all specs from lua/plugins/*.lua via zpack's import directive
require("zpack").setup({
  { import = "plugins" },
})
