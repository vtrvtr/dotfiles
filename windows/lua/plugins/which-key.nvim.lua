-- Plugin: folke/which-key.nvim
-- Installed via store.nvim

local function safe_notify(msg)
	vim.notify(msg, vim.log.levels.WARN)
end

local function safe_require(mod)
	local ok, lib = pcall(require, mod)
	if ok then
		return lib
	end
	safe_notify(string.format("%s not installed", mod))
	return nil
end

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300

		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { desc = desc })
		end

		-- Visual mode mappings
		map("v", "<CR><CR>", function()
			vim.lsp.buf.code_action()
		end, "Code action (range)")
		map("v", "<Leader>rv", function()
			local grug = safe_require("grug-far")
			if grug then
				grug.with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
			end
		end, "Search and replace selection")
		map("v", "<Leader>rf", function()
			local grug = safe_require("grug-far")
			if grug then
				grug.open({ prefills = { paths = vim.fn.expand("%") } })
			end
		end, "Search and replace current file")

		-- Visual-block (x) mode mappings
		map("x", "<CR><CR>", function()
			vim.lsp.buf.code_action()
		end, "Code action (range)")
		map("x", "<Leader>/", function()
			vim.commen()
		end, "Code action (range)")

		-- Normal mode mappings
		map("n", "<Leader>bn", "<cmd>tabnew<cr>", "New tab")
		map("n", "<Leader>bD", function()
			vim.cmd("bdelete")
		end, "Close buffer")
		map("n", "gt", function()
			vim.cmd.tabnext()
		end, "Next tab")
		map("n", "<C-w>z", function()
			require("zen-mode").toggle({})
		end, "Zen Mode")

		-- LSP
		map("n", "<leader>ld", function()
			vim.diagnostic.open_float()
		end, "Diagnostics float")
		map("n", "<leader>lr", function()
			vim.lsp.buf.rename()
		end, "Rename symbol")
		map("n", "<leader>lf", function()
			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
				if vim.api.nvim_win_is_valid(win) then
					local buf = vim.api.nvim_win_get_buf(win)
					require("conform").format({ bufnr = buf })
				end
			end
		end, "Format buffer")
		map("n", "gd", function()
			vim.lsp.buf.definition()
		end, "Go to definition")
		map("n", "gD", "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>", "Definition in split")
		map("n", "<Leader>q", function()
			vim.lsp.buf.hover()
		end, "Show hover info")
		map("n", "<C-k>", function()
			local sig = safe_require("lsp_signature")
			if sig then
				sig.toggle_float_win()
			end
		end, "Show function signature")

		-- Neotest (only if available)
		map("n", "<Leader>ter", function()
			local neotest = safe_require("neotest")
			if neotest then
				neotest.run.run(vim.fn.expand("%"))
			end
		end, "Run all tests")
		map("n", "<Leader>te ", function()
			local neotest = safe_require("neotest")
			if neotest then
				neotest.run.run()
			end
		end, "Run test under cursor")
		map("n", "<Leader>tef", function()
			local neotest = safe_require("neotest")
			if neotest then
				neotest.run.run_last()
			end
		end, "Run last test")
		map("n", "<Leader>tes", function()
			local neotest = safe_require("neotest")
			if neotest then
				neotest.summary.toggle()
			end
		end, "Test summary")
		map("n", "<Leader>teo", function()
			local neotest = safe_require("neotest")
			if neotest then
				neotest.output_panel.toggle()
			end
		end, "Test output")

		-- Split control
		map("n", "<Leader>w", "<c-w>", "Window control")
		map("n", "<m-h>", "<c-w><c-h>", "Go to left split")
		map("n", "<m-j>", "<c-w><c-j>", "Go to up split")
		map("n", "<m-k>", "<c-w><c-k>", "Go to down split")
		map("n", "<m-l>", "<c-w><c-l>", "Go to right split")
		map("n", "<c-w><m-h>", function(amount)
			local ss = safe_require("smart-splits")
			if ss then
				ss.swap_buf_left(amount)
			end
		end, "Swap left")
		map("n", "<c-w><m-j>", function(amount)
			local ss = safe_require("smart-splits")
			if ss then
				ss.swap_buf_down(amount)
			end
		end, "Swap down")
		map("n", "<c-w><m-k>", function(amount)
			local ss = safe_require("smart-splits")
			if ss then
				ss.swap_buf_up(amount)
			end
		end, "Swap up")
		map("n", "<c-w><m-l>", function(amount)
			local ss = safe_require("smart-splits")
			if ss then
				ss.swap_buf_right(amount)
			end
		end, "Swap right")
		map("n", "<c-m-h>", function(amount)
			local ss = safe_require("smart-splits")
			if ss then
				ss.resize_left(amount)
			end
		end, "Resize left")
		map("n", "<c-m-j>", function(amount)
			local ss = safe_require("smart-splits")
			if ss then
				ss.resize_down(amount)
			end
		end, "Resize down")
		map("n", "<c-m-k>", function(amount)
			local ss = safe_require("smart-splits")
			if ss then
				ss.resize_up(amount)
			end
		end, "Resize up")
		map("n", "<c-m-l>", function(amount)
			local ss = safe_require("smart-splits")
			if ss then
				ss.resize_right(amount)
			end
		end, "Resize right")

		-- Mini files
		map("n", "<Leader>e", function()
			local mf = require("mini.files")
			mf.open(vim.api.nvim_buf_get_name(0))
		end, "Open file explorer")
	end,
	opts = {
		icons = {
			breadcrumb = "»",
			separator = "➜",
			group = "+",
		},
		notify = false,
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
