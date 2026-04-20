-- Plugin: rachartier/tiny-code-action.nvim
-- Installed via store.nvim

return {
	"rachartier/tiny-code-action.nvim",
	dependencies = {
		{
			"folke/snacks.nvim",
			opts = {
				terminal = {},
			},
		},
	},
	event = "LspAttach",
	opts = function()
		vim.keymap.set({ "n", "x" }, "<enter><enter>", function()
			if vim.bo.filetype == "qf" then
				return
			end
			require("tiny-code-action").code_action()
		end, { noremap = true, silent = true })

		return
	end,
}

