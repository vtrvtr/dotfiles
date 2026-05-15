-- Plugin: nvim-treesitter/nvim-treesitter-context
-- Shows context of current code block at the top of the window

return {
	"nvim-treesitter/nvim-treesitter-context",
	dependencies = "nvim-treesitter/nvim-treesitter",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		enable = true,
		max_lines = 3,
		multiwindow = true,
	},
}
