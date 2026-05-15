return {
	"neovim/nvim-lspconfig",
	-- Load when a real file buffer is opened so dashboard-only sessions stay light.
	event = { "BufReadPre", "BufNewFile" },
	enabled = true,
	config = function()
		local lsp = vim.lsp

		local capabilities = lsp.protocol.make_client_capabilities()
		local ok_blink, blink = pcall(require, "blink.cmp")
		if ok_blink then
			capabilities = blink.get_lsp_capabilities(capabilities)
		end

		local on_attach = function(_, bufnr)
			local map = function(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
			end

			map("n", "gd", lsp.buf.definition, "Goto definition")
			map("n", "gD", lsp.buf.declaration, "Goto declaration")
			map("n", "gr", lsp.buf.references, "References")
			map("n", "gi", lsp.buf.implementation, "Goto implementation")

			map("n", "K", lsp.buf.hover, "Hover")
			map("n", "<leader>rn", lsp.buf.rename, "Rename symbol")
			map("n", "<leader>ca", lsp.buf.code_action, "Code action")

			map("n", "[d", function()
				vim.diagnostic.jump({ count = -1, float = true })
			end, "Prev diagnostic")
			map("n", "]d", function()
				vim.diagnostic.jump({ count = 1, float = true })
			end, "Next diagnostic")
			map("n", "<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
		end

		-- Lua LSP using new API
		vim.lsp.config("lua_ls", {
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "lua" },
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					workspace = { checkThirdParty = false },
					telemetry = { enable = false },
				},
			},
		})

		-- Python LSP using new API
		vim.lsp.config("pyrefly", {
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "python" },
			settings = { python = {
				pyrefly = { displayTypeError = true },
			} },
		})

		vim.lsp.config("ty", {
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "python" },
		})

		-- basedpyright (experimental; enable via vim.lsp.enable below). For richer
		-- settings (pythonPath, analysis, inlayHints, exclude, ...), add a `settings`
		-- table here as documented at basedpyright's LSP settings reference.
		vim.lsp.config("basedpyright", {
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "python" },
		})

		-- Enable the configured servers
		vim.lsp.enable("lua_ls")
		vim.lsp.enable("pyrefly")
		-- vim.lsp.enable("ty")
		-- vim.lsp.enable("basedpyright")
	end,
}
