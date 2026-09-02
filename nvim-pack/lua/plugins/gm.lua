return {
	"NnoFLy/gm.nvim",
	event = "VeryLazy",
	config = function()
		local gm = require("gm")
		gm.setup({
			store_path = vim.fn.stdpath("data") .. "/gm",
			log_level = "warn",
			auto_save = true, -- auto-save gm.txt on close
		})

		vim.keymap.set("n", "m", gm.set_mark, { desc = "Gm: Set mark" })
		vim.keymap.set("n", "'", gm.jump_to_mark, { desc = "Gm: Jump to mark" })
		vim.keymap.set("n", "<M-e>", gm.edit_marks, { desc = "Gm: Edit marks" })
	end,
}

