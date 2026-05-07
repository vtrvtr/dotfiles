-- Plugin: oribarilan/lensline.nvim
-- Installed via store.nvim

return {
	"oribarilan/lensline.nvim",
	enabled = true,
	event = "LspAttach",
	config = function()
		require("lensline").setup()
	end,
}

