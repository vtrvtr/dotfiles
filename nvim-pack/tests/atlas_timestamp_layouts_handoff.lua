local atlas_path = vim.env.ATLAS_NVIM_PATH or (vim.fn.stdpath("data") .. "/site/pack/core/opt/atlas.nvim")
assert(vim.fn.isdirectory(atlas_path) == 1, "Set ATLAS_NVIM_PATH to an installed atlas.nvim checkout")
vim.opt.runtimepath:append(atlas_path)

local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local spec = dofile(root .. "/lua/plugins/atlas.lua")
spec.config(nil, spec.opts)

local function timestamp_keys(provider)
	local found = {}
	for _, column in ipairs(provider.columns) do
		if column.key == "created_at" or column.key == "updated_at" then
			assert(not found[column.key], "Duplicate timestamp column: " .. column.key)
			found[column.key] = true
		end
	end
	assert(found.created_at == found.updated_at, "A layout must expose both timestamps or neither")
	return found.created_at == true
end

local plain = require("atlas.issues.ui.layouts.plain").jira
local compact = require("atlas.issues.ui.layouts.compact").jira
assert(timestamp_keys(plain) or timestamp_keys(compact), "Choose at least one Jira layout for timestamp columns")

for _, provider in ipairs({ plain, compact }) do
	if timestamp_keys(provider) then
		local row = provider.values({
			key = "PIPE-1",
			title = "Broken authentication",
			status = "In Progress",
			status_id = "3",
			created_at = "2026-09-01T12:00:00Z",
			updated_at = "2026-10-01T12:00:00Z",
		}, { reloading = {}, spinner = "spin" }, false)
		assert(type(row.created_at) == "string" and row.created_at ~= "", "Created value missing")
		assert(type(row.updated_at) == "string" and row.updated_at ~= "", "Updated value missing")
	end
end

print("Atlas timestamp layout handoff checks passed")
vim.cmd("qa!")
