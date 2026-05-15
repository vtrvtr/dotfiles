return {
	{
		"mason-org/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog", "MasonUpdate" },
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim" },
		event = { "BufReadPre", "BufNewFile" },
		opts = function(_, opts)
			-- Source of truth for which servers are active is the
			-- `vim.lsp.enable(...)` list in lsp.lua. Keep this list in sync so the
			-- enabled servers are installed reproducibly. Servers are NOT
			-- auto-enabled here (mason-lspconfig automatic_enable is left off);
			-- enabling is done by hand in lsp.lua.
			opts.automatic_enable = false
			opts.ensure_installed = opts.ensure_installed or {}
			for _, server in ipairs({ "lua_ls", "pyrefly" }) do
				if not vim.tbl_contains(opts.ensure_installed, server) then
					table.insert(opts.ensure_installed, server)
				end
			end
		end,
	},
	-- Formatter tools (stylua/prettier) are driven by conform.nvim. Install them
	-- with `:Mason` (or `:MasonInstall stylua prettier`); none-ls/mason-null-ls
	-- were removed since conform is the sole formatter path.
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "mason-org/mason.nvim" },
		lazy = true,
		keys = {
			{ "<leader>d", desc = "Dap" },
		},
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			if not vim.tbl_contains(opts.ensure_installed, "python") then
				table.insert(opts.ensure_installed, "python")
			end
		end,
	},
}
