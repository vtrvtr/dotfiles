-- Plugin: folke/zen-mode.nvim
-- Installed via store.nvim

return {
	"folke/zen-mode.nvim",
	cmd = "ZenMode",
	event = "BufEnter",
	enabled = true,
	opts = {
		window = {
			backdrop = 0.9,
			width = function() return math.min(120, vim.o.columns * 0.75) end,
			height = 0.9,
			options = {
				number = true,
				relativenumber = true,
				foldcolumn = "0",
				list = false,
				showbreak = "NONE",
				signcolumn = "no",
			},
		},
		plugins = {
			options = {
				cmdheight = 1,
				laststatus = 0,
			},
			wezterm = {
				enabled = true,
				font = "22",
			},
		},
	},
}
