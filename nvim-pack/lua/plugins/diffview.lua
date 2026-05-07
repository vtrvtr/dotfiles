-- Plugin: sindrets/diffview.nvim
-- Installed via store.nvim

return {
	"sindrets/diffview.nvim",
	enabled = false,
	event = "VeryLazy",
	opts = {
		view = {
			default = {
				layout = "diff3_mixed",
			},
		},
	},
}
