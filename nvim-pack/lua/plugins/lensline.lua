-- Plugin: oribarilan/lensline.nvim
-- Installed via store.nvim

return {
	"oribarilan/lensline.nvim",
	enabled = true,
	event = "LspAttach",
	config = function()
		require("lensline").setup({
			profiles = {
				{
					name = "default",
					providers = {
						{
							name = "usages",
							enabled = true,
							include = { "refs" },
							breakdown = true,
							show_zero = true,
						},
					},
				},
			},
		})
	end,
}

