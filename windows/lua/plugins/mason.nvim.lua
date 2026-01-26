return {
	{ "mason-org/mason.nvim", opts = {} },
	{
		"williamboman/mason-lspconfig.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			if not vim.tbl_contains(opts.ensure_installed, "lua_ls") then
				table.insert(opts.ensure_installed, "lua_ls")
			end
		end,
	},
	{
		"jay-babu/mason-null-ls.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			for _, tool in ipairs({ "prettier", "stylua" }) do
				if not vim.tbl_contains(opts.ensure_installed, tool) then
					table.insert(opts.ensure_installed, tool)
				end
			end
		end,
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
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
