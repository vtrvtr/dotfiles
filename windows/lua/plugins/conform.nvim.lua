-- Plugin: stevearc/conform.nvim
-- Installed via store.nvim

return {
	"stevearc/conform.nvim",
	opts = {
		-- format_on_save = {
		-- 	enabled = false,
		-- 	-- These options will be passed to conform.format()
		-- 	timeout_ms = 500,
		-- 	lsp_format = "fallback",
		-- },
		formatters_by_ft = {
			lua = { "stylua" },
			-- Conform will run multiple formatters sequentially
			python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
			-- You can customize some of the format options for the filetype (:help conform.format)
			rust = { "rustfmt", lsp_format = "fallback" },
			-- Conform will run the first available formatter
			javascript = { "prettierd", "prettier", stop_after_first = true },
		},
	},
}
