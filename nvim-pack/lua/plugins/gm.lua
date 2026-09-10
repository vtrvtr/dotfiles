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

		local store = require("gm.store")
		local wk = require("which-key")

		local function set_mark()
			local key = vim.fn.getcharstr()
			if key == "" or key == "<Esc>" or key == "\027" then
				return
			end

			local mark, err = store.get(key)
			if err then
				vim.notify("gm: " .. err, vim.log.levels.ERROR)
				return
			end
			if mark and vim.fn.confirm("Replace mark " .. key .. "?", "&Yes\n&No", 2) ~= 1 then
				return
			end

			vim.api.nvim_feedkeys(key, "n", false)
			gm.set_mark()
			vim.api.nvim_exec_autocmds("User", { pattern = "GmChanged" })
		end

		vim.keymap.set("n", "m", set_mark, { desc = "Gm: Set mark" })
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
