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
			require("conform").format()
		end, "Formatttt buffer")
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

		-- UI Toggles
		map("n", "<leader>ub", function()
			vim.o.background = vim.o.background == "dark" and "light" or "dark"
			vim.notify("Background: " .. vim.o.background, vim.log.levels.INFO)
		end, "Toggle background (dark/light)")

		map("n", "<leader>uc", function()
			local conceallevel = vim.o.conceallevel > 0 and 0 or 2
			vim.o.conceallevel = conceallevel
			vim.notify("Conceal level: " .. conceallevel, vim.log.levels.INFO)
		end, "Toggle conceal")

		map("n", "<leader>ud", function()
			vim.diagnostic.enable(not vim.diagnostic.is_enabled())
			vim.notify("Diagnostics: " .. (vim.diagnostic.is_enabled() and "enabled" or "disabled"), vim.log.levels.INFO)
		end, "Toggle diagnostics")

		map("n", "<leader>ug", function()
			if vim.wo.signcolumn == "no" then
				vim.wo.signcolumn = "yes"
			elseif vim.wo.signcolumn == "yes" then
				vim.wo.signcolumn = "auto"
			else
				vim.wo.signcolumn = "no"
			end
			vim.notify("Signcolumn: " .. vim.wo.signcolumn, vim.log.levels.INFO)
		end, "Toggle signcolumn")

		map("n", "<leader>ui", function()
			vim.cmd("IBLToggle")
		end, "Toggle indent guides")

		map("n", "<leader>ul", function()
			vim.wo.number = not vim.wo.number
			vim.notify("Line numbers: " .. (vim.wo.number and "enabled" or "disabled"), vim.log.levels.INFO)
		end, "Toggle line numbers")

		map("n", "<leader>uL", function()
			vim.wo.relativenumber = not vim.wo.relativenumber
			vim.notify("Relative line numbers: " .. (vim.wo.relativenumber and "enabled" or "disabled"), vim.log.levels.INFO)
		end, "Toggle relative line numbers")

		map("n", "<leader>un", function()
			local enabled = vim.notify ~= nil
			if enabled then
				vim.g.notify_backup = vim.notify
				vim.notify = function() end
				vim.notify("Notifications: disabled", vim.log.levels.INFO)
				vim.notify = vim.g.notify_backup
			else
				vim.notify = vim.g.notify_backup
				vim.notify("Notifications: enabled", vim.log.levels.INFO)
			end
		end, "Toggle notifications")

		map("n", "<leader>up", function()
			vim.o.paste = not vim.o.paste
			vim.notify("Paste mode: " .. (vim.o.paste and "enabled" or "disabled"), vim.log.levels.INFO)
		end, "Toggle paste mode")

		map("n", "<leader>us", function()
			vim.wo.spell = not vim.wo.spell
			vim.notify("Spell check: " .. (vim.wo.spell and "enabled" or "disabled"), vim.log.levels.INFO)
		end, "Toggle spell check")

		map("n", "<leader>uS", function()
			if vim.o.laststatus == 0 then
				vim.o.laststatus = 2
			else
				vim.o.laststatus = 0
			end
			vim.notify("Statusline: " .. (vim.o.laststatus > 0 and "enabled" or "disabled"), vim.log.levels.INFO)
		end, "Toggle statusline")

		map("n", "<leader>ut", function()
			if vim.o.showtabline == 0 then
				vim.o.showtabline = 2
			else
				vim.o.showtabline = 0
			end
			vim.notify("Tabline: " .. (vim.o.showtabline > 0 and "enabled" or "disabled"), vim.log.levels.INFO)
		end, "Toggle tabline")

		map("n", "<leader>uw", function()
			vim.wo.wrap = not vim.wo.wrap
			vim.notify("Line wrap: " .. (vim.wo.wrap and "enabled" or "disabled"), vim.log.levels.INFO)
		end, "Toggle line wrap")

		map("n", "<leader>ux", function()
			local syntax_on = vim.fn.exists("syntax_on")
			if syntax_on == 1 then
				vim.cmd("syntax off")
				vim.notify("Syntax highlighting: disabled", vim.log.levels.INFO)
			else
				vim.cmd("syntax on")
				vim.notify("Syntax highlighting: enabled", vim.log.levels.INFO)
			end
		end, "Toggle syntax highlighting")

		map("n", "<leader>uy", function()
			if vim.lsp.inlay_hint then
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
				vim.notify("Inlay hints: " .. (vim.lsp.inlay_hint.is_enabled() and "enabled" or "disabled"), vim.log.levels.INFO)
			else
				vim.notify("Inlay hints not available", vim.log.levels.WARN)
			end
		end, "Toggle LSP inlay hints")

		map("n", "<leader>uT", function()
			if vim.o.colorcolumn == "" then
				vim.o.colorcolumn = "80"
			else
				vim.o.colorcolumn = ""
			end
			vim.notify("Color column: " .. (vim.o.colorcolumn ~= "" and vim.o.colorcolumn or "disabled"), vim.log.levels.INFO)
		end, "Toggle color column")

		map("n", "<leader>uv", function()
			vim.wo.list = not vim.wo.list
			vim.notify("List chars: " .. (vim.wo.list and "visible" or "hidden"), vim.log.levels.INFO)
		end, "Toggle list chars (visible)")

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
