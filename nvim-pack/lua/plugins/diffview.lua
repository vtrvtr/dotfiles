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
		},
	},
	config = function(_, opts)
		local actions = require("diffview.actions")

		-- `[[`/`]]` for hunk navigation, alongside the built-in `[c`/`]c`.
		-- diff1_inline has `diff=false`, so native `]c` does nothing there and the
		-- renderer's own hunk-walking actions are required. The real diff-mode
		-- layouts use native `]c`/`[c`, wrapped with `zz` to recenter.
		-- `]c`/`[c` never raise: at the last hunk they just leave the cursor put.
		local function native_hunk(lhs)
			return function()
				vim.cmd("normal! " .. lhs)
				vim.cmd("normal! zz")
			end
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
				{ "n", "]]", actions.next_inline_hunk, { desc = "Next hunk" } },
				{ "n", "[[", actions.prev_inline_hunk, { desc = "Previous hunk" } },
			},
		}
		for _, group in ipairs({ "diff1", "diff2", "diff3", "diff4" }) do
			keymaps[group] = {
				{ "n", "]]", native_hunk("]c"), { desc = "Next hunk" } },
				{ "n", "[[", native_hunk("[c"), { desc = "Previous hunk" } },
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
