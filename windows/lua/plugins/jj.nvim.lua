-- Plugin: NicolasGB/jj.nvim
-- Installed via store.nvim

return {
	"nicolasgb/jj.nvim",
	config = function()
		require("jj").setup({
			-- Setup snacks as a picker
			picker = {
				-- Here you can pass the options as you would for snacks.
				-- It will be used when using the picker
				snacks = {},
			},

			-- Customize syntax highlighting colors for the describe buffer
			highlights = {
				editor = {
					added = { fg = "#3fb950", ctermfg = "Green" }, -- Added files
					modified = { fg = "#56d4dd", ctermfg = "Cyan" }, -- Modified files
					deleted = { fg = "#f85149", ctermfg = "Red" }, -- Deleted files
					renamed = { fg = "#d29922", ctermfg = "Yellow" }, -- Renamed files
				},
				log = {
					selected = { bg = "#3d2c52", ctermbg = "DarkMagenta" },
					targeted = { fg = "#5a9e6f", ctermfg = "Green" },
				},
			},

			-- Configure terminal behavior
			terminal = {
				-- Cursor render delay in milliseconds (default: 10)
				-- If cursor column is being reset to 0 when refreshing commands, try increasing this value
				-- This delay allows the terminal emulator to complete rendering before restoring cursor position
				cursor_render_delay = 10,
			},

			-- Configure diff module
			diff = {
				-- Default backend for viewing diffs
				-- "native" - Built-in split diff using Neovim's diff mode (default)
				-- "diffview" - Use diffview.nvim plugin (requires diffview.nvim)
				-- "codediff" - Use codediff.nvim plugin (requires codediff.nvim)
				-- Or any custom backend name you've registered
				backend = "native",
			},

			-- Configure cmd module (describe editor, keymaps)
			cmd = {
				-- Configure describe editor
				describe = {
					editor = {
						-- Choose the editor mode for describe command
						-- "buffer" - Opens a Git-style commit message buffer with syntax highlighting (default)
						-- "input" - Uses a simple vim.ui.input prompt
						type = "buffer",
						-- Customize keymaps for the describe editor buffer
						keymaps = {
							close = { "<Esc>", "<C-c>", "q" }, -- Keys to close editor without saving
						},
					},
				},

				-- Configure log command behavior
				log = {
					close_on_edit = false, -- Close log buffer after editing a change
				},

				-- Configure bookmark command
				bookmark = {
					prefix = "",
				},

				-- Configure keymaps for command buffers
				keymaps = {
					-- Log buffer keymaps (set to nil to disable)
					log = {
						checkout = "<CR>", -- Edit revision under cursor
						checkout_immutable = "<S-CR>", -- Edit revision (ignore immutability)
						describe = "d", -- Describe revision under cursor
						diff = "<S-d>", -- Diff revision under cursor
						edit = "e", -- Edit revision under cursor
						new = "n", -- Create new change branching off
						new_after = "<C-n>", -- Create new change after revision
						new_after_immutable = "<S-n>", -- Create new change after (ignore immutability)
						undo = "u", -- Undo last operation
						redo = "<S-u>", -- Redo last undone operation
						abandon = "a", -- Abandon revision under cursor
						bookmark = "b", -- Create or move bookmark to revision under cursor
						fetch = "f", -- Fetch from remote
						push = "p", -- Push bookmark of revision under cursor
						push_all = "<S-p>", -- Push all changes to remote
						open_pr = "o", -- Open PR/MR for revision under cursor
						open_pr_list = "<S-o>", -- Open PR/MR by selecting from all bookmarks
						rebase = "r", -- Enter rebase mode targeting revision under cursor or selected revisions
						rebase_mode = {
							onto = { "<CR>", "o" }, -- Select revision under cursor as rebase onto destination
							after = { "a", "A" }, -- Rebase after revision under cursor
							before = { "b", "B" }, -- Rebase before revision under cursor
							onto_immutable = { "<S-CR>", "<S-o>" }, -- Select revision  as a rebase onto destination (ignore immutability)
							after_immutable = "<S-a>", -- Rebase after revision under cursor (ignore immutability)
							before_immutable = "<S-b>", -- Rebase before revision under cursor (ignore immutability)
							exit_mode = { "<Esc>", "<C-c>" }, -- Exit rebase mode
						},
						squash = "s", -- Enter squash mode targeting revision under cursor or selected revisions
						squash_mode = {
							into = "<CR>", -- Squash into revision under cursor
							into_immutable = "<S-CR>", -- Squash into revision under cursor (ignore immutability)
							exit_mode = { "<Esc>", "<C-c>" }, -- Exit squash mode
						},
						quick_squash = "<S-s>", -- Quick squash revision under cursor into its parent (ignore immutability)
						summary = "<S-k>", -- Show summary tooltip for revision under cursor
						summary_tooltip = {
							diff = "<S-d>", -- Diff file at this revision
							edit = "<CR>", -- Edit revision and open file
							edit_immutable = "<S-CR>", -- Edit revision (ignore immutability) and open file
						},
					},
					-- Status buffer keymaps (set to nil to disable)
					status = {
						open_file = "<CR>", -- Open file under cursor
						restore_file = "<S-x>", -- Restore file under cursor
					},
					-- Close keymaps (shared across all buffers)
					close = { "q", "<Esc>" },
				},
			},
		})

		local wk = require("which-key")
		local cmd = require("jj.cmd")

		wk.add({
			{
				"<leader>jj",
				cmd.log
			},
			desc = "JJ"
		})
	end,
}
