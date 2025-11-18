return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		-- Setup textobjects module
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
				include_surrounding_whitespace = false,
			},
			move = {
				set_jumps = true,
			},
		})

		-- Movement keymaps
		local move = require("nvim-treesitter-textobjects.move")

		-- Next movements
		vim.keymap.set({ "n", "x", "o" }, "]f", function()
			move.goto_next_start("@function.outer", "textobjects")
		end, { desc = "Next function" })

		vim.keymap.set({ "n", "x", "o" }, "]c", function()
			move.goto_next_start("@class.outer", "textobjects")
		end, { desc = "Next class" })

		vim.keymap.set({ "n", "x", "o" }, "]i", function()
			move.goto_next_start("@conditional.outer", "textobjects")
		end, { desc = "Next conditional" })

		vim.keymap.set({ "n", "x", "o" }, "]l", function()
			move.goto_next_start("@loop.outer", "textobjects")
		end, { desc = "Next loop" })

		-- Previous movements
		vim.keymap.set({ "n", "x", "o" }, "[f", function()
			move.goto_previous_start("@function.outer", "textobjects")
		end, { desc = "Previous function" })

		vim.keymap.set({ "n", "x", "o" }, "[c", function()
			move.goto_previous_start("@class.outer", "textobjects")
		end, { desc = "Previous class" })

		vim.keymap.set({ "n", "x", "o" }, "[i", function()
			move.goto_previous_start("@conditional.outer", "textobjects")
		end, { desc = "Previous conditional" })

		vim.keymap.set({ "n", "x", "o" }, "[l", function()
			move.goto_previous_start("@loop.outer", "textobjects")
		end, { desc = "Previous loop" })

		-- Select text objects
		local select = require("nvim-treesitter-textobjects.select")

		vim.keymap.set({ "x", "o" }, "af", function()
			select.select_textobject("@function.outer", "textobjects")
		end, { desc = "Around function" })

		vim.keymap.set({ "x", "o" }, "if", function()
			select.select_textobject("@function.inner", "textobjects")
		end, { desc = "Inside function" })

		vim.keymap.set({ "x", "o" }, "ac", function()
			select.select_textobject("@class.outer", "textobjects")
		end, { desc = "Around class" })

		vim.keymap.set({ "x", "o" }, "ic", function()
			select.select_textobject("@class.inner", "textobjects")
		end, { desc = "Inside class" })
	end,
}