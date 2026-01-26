-- Plugin: nvim-neotest/neotest
-- Installed via store.nvim

return {
	"nvim-neotest/neotest",
	lazy = true,
	event = "VeryLazy",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"jfpedroza/neotest-elixir",
		"nvim-neotest/neotest-python",
		"rouge8/neotest-rust",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-python")({
					-- Extra arguments for nvim-dap configuration
					-- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
					dap = { justMyCode = false },
					-- Command line arguments for runner
					-- Can also be a function to return dynamic values
					args = { "--log-level", "DEBUG" },
					-- Runner to use. Will use pytest if available by default.
					-- Can be a function to return dynamic value.
					runner = "pytest",
				-- Custom python path for the runner.
				-- Can be a string or a list of strings.
				-- Can also be a function to return dynamic value.
				-- If not provided, the path will be inferred by checking for
				-- virtual envs in the local directory and for Pipenev/Poetry configs
				python = vim.env.PYTHON_EXE or nil,
					-- Returns if a given file path is a test file.
					-- NB: This function is called a lot so don't perform any heavy tasks within it.
					is_test_file = function(file_path)
						local filename = vim.fn.fnamemodify(file_path, ":t")
						return filename:match("^test_") and not file_path:match("[/\\]build[/\\]")
					end,
					-- !!EXPERIMENTAL!! Enable shelling out to `pytest` to discover test
					-- instances for files containing a parametrize mark (default: false)
					pytest_discover_instances = true,
				}),
				require("neotest-elixir"),
				require("neotest-rust"),
			},
		})
		local wk = require("which-key")
		wk.add({
			{ "<leader>te", group = "Test" },
			{
				"<leader>ted",
				function()
					require("neotest").run.run({ strategy = "dap" })
				end,
				desc = "Test Debug",
			},
			{
				"<leader>ter",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "Run all tests.",
			},
			{
				"<leader>te<space>",
				function()
					require("neotest").run.run()
				end,
				desc = "Run test under cursor.",
			},
			{
				"<leader>tef",
				function()
					require("neotest").run.run_last()
				end,
				desc = "Run last test.",
			},
			{
				"<leader>tes",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "Test summary",
			},
			{
				"<leader>teo",

				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "Test output",
			},
		})
	end,
}
