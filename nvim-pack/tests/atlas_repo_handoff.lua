local atlas_path = vim.env.ATLAS_NVIM_PATH or (vim.fn.stdpath("data") .. "/site/pack/core/opt/atlas.nvim")
assert(vim.fn.isdirectory(atlas_path) == 1, "Set ATLAS_NVIM_PATH to an installed atlas.nvim checkout")
vim.opt.runtimepath:append(atlas_path)

local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local spec = dofile(root .. "/lua/plugins/atlas.lua")
spec.config(nil, spec.opts)

local api = require("atlas.pulls.providers.github.api.pullrequests")
local queries
api.fetch_search = function(value, _, on_done)
	queries = value
	on_done({ items = {} }, nil)
	return { cancel = function() end }
end

vim.cmd.edit(vim.fn.fnameescape(root .. "/tests/atlas_repo_handoff.lua"))
local outside = vim.fn.tempname()
vim.fn.mkdir(outside, "p")
vim.cmd.cd(vim.fn.fnameescape(outside))

local provider = require("atlas.pulls.providers.github")
local completed = false
provider.capabilities.core.fetch_pullrequests(provider.views()[1], { pagelen = 50 }, function()
	completed = true
end)
assert(vim.wait(1000, function() return completed end), "Repo view resolution timed out")

local expected = "repo:vtrvtr/dotfiles is:pr archived:false sort:updated-desc is:open"
assert(queries and queries[1] == expected, string.format("Repo view is not scoped\nexpected: %s\nactual:   %s", expected, vim.inspect(queries)))

vim.fn.delete(outside, "d")
print("Atlas Repo view follows the active buffer repository")
vim.cmd("qa!")
