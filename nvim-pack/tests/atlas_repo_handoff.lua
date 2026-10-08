local atlas_path = vim.env.ATLAS_NVIM_PATH or (vim.fn.stdpath("data") .. "/site/pack/core/opt/atlas.nvim")
assert(vim.fn.isdirectory(atlas_path) == 1, "Set ATLAS_NVIM_PATH to an installed atlas.nvim checkout")
vim.opt.runtimepath:append(atlas_path)

local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.cmd.cd(root)
local spec = dofile(root .. "/lua/plugins/atlas.lua")
spec.config(nil, spec.opts)

local views = require("atlas.pulls.providers.github").views()
local actual = views[1].search
local expected = "repo:vtrvtr/dotfiles is:pr is:open archived:false sort:updated-desc"
assert(actual == expected, string.format("Repo view is not scoped\nexpected: %s\nactual:   %s", expected, actual))
print("Atlas Repo view is scoped to the current repository")
vim.cmd("qa!")
