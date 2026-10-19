local atlas_path = vim.env.ATLAS_NVIM_PATH or (vim.fn.stdpath("data") .. "/site/pack/core/opt/atlas.nvim")
assert(vim.fn.isdirectory(atlas_path) == 1, "Set ATLAS_NVIM_PATH to an installed atlas.nvim checkout")
vim.opt.runtimepath:append(atlas_path)

local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local spec = dofile(root .. "/lua/plugins/atlas.lua")
spec.config(nil, spec.opts)

local function has_timestamps(provider)
	local counts = vim.iter(provider.columns):fold({ created_at = 0, updated_at = 0 }, function(acc, column)
		return {
			created_at = acc.created_at + (column.key == "created_at" and 1 or 0),
			updated_at = acc.updated_at + (column.key == "updated_at" and 1 or 0),
		}
	end)
	assert(counts.created_at <= 1, "Duplicate timestamp column: created_at")
	assert(counts.updated_at <= 1, "Duplicate timestamp column: updated_at")
	assert(counts.created_at == counts.updated_at, "A layout must expose both timestamps or neither")
	return counts.created_at == 1
end

local layouts = vim.tbl_map(function(provider)
	return { provider = provider, has_timestamps = has_timestamps(provider) }
end, {
	require("atlas.issues.ui.layouts.plain").jira,
	require("atlas.issues.ui.layouts.compact").jira,
})
assert(vim.iter(layouts):any(function(layout) return layout.has_timestamps end), "No Jira layout has timestamps")

for _, layout in ipairs(layouts) do
	if layout.has_timestamps then
		local row = layout.provider.values({
			key = "PIPE-1",
			title = "Broken authentication",
			status = "In Progress",
			status_id = "3",
			created_at = "2026-09-01T12:00:00Z",
			updated_at = "2026-10-01T12:00:00Z",
		}, { reloading = {}, spinner = "spin" })
		assert(type(row.created_at) == "string" and row.created_at ~= "", "Created value missing")
		assert(type(row.updated_at) == "string" and row.updated_at ~= "", "Updated value missing")
	end
end

print("Atlas timestamp layout handoff checks passed")
vim.cmd("qa!")
