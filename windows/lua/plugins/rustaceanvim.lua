-- Plugin: mrcjkb/rustaceanvim
-- Installed via store.nvim

return {
	"mrcjkb/rustaceanvim",
	version = "^7",
	ft = { "rust" },
	dependencies = {
		{
			"saecki/crates.nvim",
			tag = "stable",
			dependencies = { "nvim-lua/plenary.nvim" },
		},
	},
	config = function()
		vim.g.rustaceanvim = {
			tools = {},
			server = {
				on_attach = function(client, bufnr)
					if client and client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(true)
					end
				end,
				settings = {
					["rust-analyzer"] = {
						checkOnSave = true,
						-- checkOnSave = {
						-- 	allFeatures = true,
						-- 	command = "clippy",
						-- 	extraArgs = { "--no-deps" },
						-- },
						diagnostics = {
							enableExperimental = true,
							disabled = { "unresolved-proc-macro" },
						},
						cargo = {
							features = "all",
							targetDir = true,
						},
					},
				},
			},
			dap = {
				adapter = {
					type = "executable",
					command = "lldb-vscode",
					name = "lldb",
				},
			},
		}
	end,
}
