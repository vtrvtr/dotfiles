-- modified version of code from this config
--https://github.com/fredrikaverpil/dotfiles/blob/main/nvim-fredrik/lua/fredrik/plugins/core/treesitter.lua
return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		event = { "BufReadPost", "BufNewFile" },
		branch = "main",
		build = ":TSUpdate",
		config = function()
			-- Main treesitter configuration
			require("nvim-treesitter").setup({
				-- Parser installation
				ensure_installed = {
					"rust",
					"astro",
					"bash",
					"c",
					"css",
					"diff",
					"go",
					"gomod",
					"gowork",
					"gosum",
					"graphql",
					"html",
					"javascript",
					"jsdoc",
					"json",
					"jsonc",
					"json5",
					"lua",
					"luadoc",
					"luap",
					"markdown",
					"markdown_inline",
					"python",
					"query",
					"regex",
					"toml",
					"tsx",
					"typescript",
					"vim",
					"vimdoc",
					"yaml",
					"ruby",
				},
				-- Automatically install missing parsers when entering buffer
				auto_install = true,
				sync_install = false,

				-- Enable highlighting
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},

				-- Enable indentation
				indent = {
					enable = true,
				},
			})

			local group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true })

			-- Only enable treesitter for common buffer types (allowlist approach)
			local allowed_filetypes = {
				"rust",
				"astro",
				"bash",
				"sh",
				"c",
				"cpp",
				"css",
				"diff",
				"go",
				"gomod",
				"gowork",
				"gosum",
				"graphql",
				"html",
				"javascript",
				"javascriptreact",
				"jsdoc",
				"json",
				"jsonc",
				"json5",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"python",
				"query",
				"regex",
				"toml",
				"tsx",
				"typescript",
				"typescriptreact",
				"vim",
				"help",
				"yaml",
				"ruby",
			}
			local allowed_set = {}
			for _, ft in ipairs(allowed_filetypes) do
				allowed_set[ft] = true
			end

			local ts = require("nvim-treesitter")
			-- Auto-enable highlighting only for allowed filetypes
			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				desc = "Enable treesitter highlighting and indentation",
				callback = function(event)
					if not allowed_set[event.match] then
						return
					end

					local lang = vim.treesitter.language.get_lang(event.match) or event.match
					local buf = event.buf

					-- Start highlighting immediately (works if parser exists)
					pcall(vim.treesitter.start, buf, lang)

					-- Enable treesitter indentation
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

					-- Install missing parsers (async, no-op if already installed)
					ts.install({ lang })
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "BufRead",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			enable = true,
			max_lines = 5,
			multiwindow = true,
		},
	},
}
