-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.laststatus = 3 -- single global statusline
vim.opt.cmdheight = 0 -- hide command line when not used
vim.opt.ruler = false -- handled by statusline
vim.opt.showmode = false -- mode shown in statusline

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load all plugins from lua/plugins/*.lua
require("lazy").setup({
	spec = {
		{ import = "plugins" },
	},
})
require("config.utils.statusline")
