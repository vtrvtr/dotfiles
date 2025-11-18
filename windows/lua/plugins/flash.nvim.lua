-- Plugin: folke/flash.nvim
-- Installed via store.nvim
--

local function with_casing(exec)
	local gi = vim.go.ignorecase
	local gs = vim.go.smartcase
	vim.go.ignorecase = true
	vim.go.smartcase = false
	r = exec()
	vim.go.ignorecase = gi
	vim.go.smartcase = gs
	return r
end

return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
	opts = {
		modes = {
			treesitter = {
				label = {
					rainbow = { enabled = true },
				},
			},
		},
	},
	keys = {
		{
			"s",
			mode = { "n", "x", "o" },
			function()
				with_casing(require("flash").jump)
			end,
			desc = "Flash",
		},
		{
			"S",
			mode = { "n", "x", "o" },
			function()
				with_casing(require("flash").treesitter)
			end,
			desc = "Flash Treesitter",
		},
		{
			"R",
			mode = "o",
			function()
				with_casing(require("flash").remote)
			end,
			desc = "Remote Flash",
		},
		{
			"r",
			mode = { "o" },
			function()
				with_casing(function()
					require("flash").treesitter_search({ remote_op = { restore = true, motion = true } })
				end)
			end,
			desc = "Treesitter Search",
		},
		{
			"<c-s>",
			mode = { "c" },
			function()
				with_casing(require("flash").toggle)
			end,
			desc = "Toggle Flash Search",
		},
	},
}
