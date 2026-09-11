-- Fork of sindrets/diffview.nvim. Upstream has no jj adapter and no inline
-- layout; this fork adds both (`preferred_adapter`, `diff1_inline`).
return {
	"dlyongemallo/diffview-plus.nvim",
	-- Eager: jj.nvim's diffview backend guards on `pcall(require, "diffview")`,
	-- which fails while the pack is still unloaded and aborts every jj diff.
	event = "VeryLazy",
	opts = {
		-- Colocated repo (.jj + .git): pick jj, otherwise git wins detection.
		preferred_adapter = "jj",
		view = {
			-- winbar_info names the rev shown in each window ("WORKING TREE - path",
			-- or "<hash>:path" for a commit).
			default = { layout = "diff1_inline", winbar_info = true },
			merge_tool = { layout = "diff3_mixed", winbar_info = true },
			file_history = { layout = "diff1_inline", winbar_info = true },
			foldlevel = 0,
			-- `foldlevel` only sets the level; diff1_inline needs this to build
			-- the folds at all.
			inline = { fold_unchanged = true },
		},
	},
	config = function(_, opts)
		local actions = require("diffview.actions")

		local function native_hunk(lhs)
			return function(win)
				local before = vim.api.nvim_win_get_cursor(win)
				vim.cmd("normal! " .. lhs)
				return not vim.deep_equal(before, vim.api.nvim_win_get_cursor(win))
			end
		end

		local function inline_hunk(jump)
			return function(win)
				local row = jump(vim.api.nvim_win_get_buf(win), vim.api.nvim_win_get_cursor(win)[1] - 1)
				if not row then
					return false
				end
				vim.api.nvim_win_set_cursor(win, { row + 1, 0 })
				return true
			end
		end

		local function hunk_or_file(jump, next_file)
			return function()
				if jump(vim.api.nvim_get_current_win()) then
					vim.cmd("normal! zz")
				else
					next_file()
				end
			end
		end

		local function mark_viewed()
			local view = require("diffview.lib").get_current_view()
			local panel = view and view.panel
			if not (panel and panel.select_file and view.infer_cur_file and view._save_selections_now) then
				return
			end

			local file = view:infer_cur_file()
			local files = panel:ordered_file_list()
			local index = require("diffview.utils").vec_indexof(files, file)
			if index == -1 then
				return
			end

			panel:select_file(file)
			if not panel.hide_selected then
				panel:toggle_hide_selected()
			end
			panel:render()
			panel:redraw()

			local next_file = files[index % #files + 1]
			if next_file ~= file then
				view:set_file(next_file, true, true)
			else
				panel:reconstrain_cursor()
			end
			view:_save_selections_now()
		end

		-- `actions.close` is only handled by the help / commit-log / option
		-- panels; in the diff view and file panels it is an unhandled no-op, so
		-- `q` has to go through `:DiffviewClose`.
		local quit = { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } }

		local keymaps = {
			view = { quit },
			file_panel = { quit },
			file_history_panel = { quit },
			diff1_inline = {
				{
					"n",
					"]]",
					hunk_or_file(inline_hunk(require("diffview.scene.inline_diff").next_hunk_row), actions.select_next_entry),
					{ desc = "Next hunk or file" },
				},
				{
					"n",
					"[[",
					hunk_or_file(inline_hunk(require("diffview.scene.inline_diff").prev_hunk_row), actions.select_prev_entry),
					{ desc = "Previous hunk or file" },
				},
				{ "n", "x", mark_viewed, { desc = "Mark file viewed and hide" } },
			},
		}
		for _, group in ipairs({ "diff1", "diff2", "diff3", "diff4" }) do
			keymaps[group] = {
				{
					"n",
					"]]",
					hunk_or_file(native_hunk("]c"), actions.select_next_entry),
					{ desc = "Next hunk or file" },
				},
				{
					"n",
					"[[",
					hunk_or_file(native_hunk("[c"), actions.select_prev_entry),
					{ desc = "Previous hunk or file" },
				},
				{ "n", "x", mark_viewed, { desc = "Mark file viewed and hide" } },
			}
		end

		require("diffview").setup(vim.tbl_deep_extend("force", opts, { keymaps = keymaps }))

		local function close_diffview()
			if require("diffview.lib").get_current_view() then
				vim.cmd("DiffviewClose")
			end
		end

		vim.keymap.set("n", "<leader>di", "<cmd>DiffviewOpen<cr>", { desc = "Diffview open" })
		vim.keymap.set("n", "<leader>dq", close_diffview, { desc = "Diffview close" })
		vim.keymap.set("n", "<leader>dh", "<cmd>DiffviewFileHistory<cr>", { desc = "Diffview file history (repo)" })
		vim.keymap.set("n", "<leader>dH", "<cmd>DiffviewFileHistory %<cr>", { desc = "Diffview file history (file)" })
	end,
}
