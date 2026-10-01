local atlas_path = vim.env.ATLAS_NVIM_PATH or (vim.fn.stdpath("data") .. "/site/pack/core/opt/atlas.nvim")
assert(vim.fn.isdirectory(atlas_path) == 1, "Set ATLAS_NVIM_PATH to an installed atlas.nvim checkout")
vim.opt.runtimepath:append(atlas_path)

local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local spec = dofile(root .. "/lua/plugins/atlas.lua")
spec.config(nil, spec.opts)

local displays = require("atlas.issues.ui.components.issue_list.providers")
local opts = { reloading = { ["PIPE-1"] = true }, spinner = "spin" }
local jira = displays.get("jira", opts)
local issue = {
	key = "PIPE-1",
	title = "Broken authentication",
	status = "In Progress",
	status_id = "3",
	created_at = "2026-09-01T12:00:00Z",
	updated_at = "2026-10-01T12:00:00Z",
}

local keys = vim.tbl_map(function(column)
	return column.key
end, jira.columns("plain"))
assert(
	vim.deep_equal(keys, { "icon", "name", "assignee", "reporter", "status", "created_at", "updated_at" }),
	vim.inspect(keys)
)

local row = jira.values(issue, false, "plain")
assert(type(row.created_at) == "string" and row.created_at ~= "", "Created value missing")
assert(type(row.updated_at) == "string" and row.updated_at ~= "", "Updated value missing")
assert(row.status:find("spin", 1, true), "Render options were not preserved")

local spans = jira.highlights(
	row,
	{ key = "created_at" },
	{ padded = row.created_at, text = row.created_at, width = #row.created_at }
)
assert(vim.deep_equal(spans, {}), "Created timestamp should use default styling")

local github = displays.get("github", opts)
assert(vim.tbl_contains(vim.tbl_map(function(column)
	return column.key
end, github.columns("plain")), "reporter"), "Non-Jira provider was modified")

print("Atlas Jira column regression checks passed")
