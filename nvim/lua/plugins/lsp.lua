return {
	"neovim/nvim-lspconfig",
	lazy = false,
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

			map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
			map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
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

		-- Basedpyright with full configuration
		local python_path = vim.fn.system("which python"):gsub("\n", "")

		vim.lsp.config("basedpyright", {
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "python" },
			-- settings = {
			-- 	python = {
			-- 		pythonPath = python_path,
			-- 		analysis = {
			-- 			autoSearchPaths = true,
			-- 			useLibraryCodeForTypes = true,
			-- 			diagnosticMode = "workspace",
			-- 			typeCheckingMode = "standard",
			-- 		},
			-- 	},
			-- 	basedpyright = {
			-- 		analysis = {
			-- 			pythonPath = python_path,
			-- 			inlayHints = {
			-- 				variableTypes = true,
			-- 				functionReturnTypes = true,
			-- 			},
			-- 			diagnosticMode = "workspace",
			-- 			reportUnknownVariableType = "none",
			-- 			typeCheckingMode = "standard",
			-- 			-- Properly exclude folders
			-- 			exclude = {
			-- 				"**/build",
			-- 				"**/build/**",
			-- 				"**/.venv",
			-- 				"**/.venv/**",
			-- 				"**/node_modules",
			-- 				"**/__pycache__",
			-- 			},
			-- 			ignore = {
			-- 				"**/build",
			-- 				"**/build/**",
			-- 			},
			-- 		},
			-- 	},
			-- },
		})

		-- Enable the configured servers
		vim.lsp.enable("lua_ls")
		vim.lsp.enable("pyrefly")
		-- vim.lsp.enable("ty")
		-- vim.lsp.enable("basedpyright")
	end,
}
