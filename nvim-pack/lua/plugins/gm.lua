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

		local wk = require("which-key")

		wk.add({
			{
				"m",
				function()
					gm.set_mark()
					-- Setting a mark changes no buffer, so statusline listeners
					-- have nothing else to key off.
					vim.api.nvim_exec_autocmds("User", { pattern = "GmChanged" })
				end,
				desc = "Gm: Set mark",
				mode = "n",
			},
		})
		wk.add({
			{
				"mf",
				gm.edit_marks,
				desc = "Gm: Edit marks",
				mode = "n",
			},
		})
		wk.add({
			{
				",",
				gm.jump_to_mark,
				desc = "Gm: Jump to mark",
				mode = "n",
			},
		})
	end,
}
