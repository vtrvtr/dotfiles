-- -- Plugin: saghen/blink.cmp
-- -- Installed via store.nvim
--
-- return {
-- 	"saghen/blink.cmp",
-- 	enabled = true,
-- 	lazy = false, -- lazy loading handled internally
-- 	-- optional: provides snippets for the snippet source
-- 	dependencies = { "rafamadriz/friendly-snippets", "fang2hou/blink-copilot" },
--
-- 	-- use a release tag to download pre-built binaries
-- 	version = "v1.*",
-- 	-- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
-- 	build = "unset CARGO_TARGET_DIR && cargo build --release",
--
-- 	opts = {
-- 		keymap = {
-- 			preset = "default",
-- 			["<CR>"] = { "accept", "select_and_accept", "fallback" },
-- 			["<Up>"] = { "select_prev", "fallback" },
-- 			["<Down>"] = { "select_next", "fallback" },
-- 			["<Tab>"] = {
-- 				"snippet_forward",
-- 				function() -- sidekick next edit suggestion
-- 					return require("sidekick").nes_jump_or_apply()
-- 				end,
-- 			},
-- 		},
--
-- 		sources = {
-- 			default = { "copilot" },
--
-- 			providers = {
-- 				cmdline = {
-- 					-- ignores cmdline completions when executing shell commands
-- 					enabled = function()
-- 						return vim.fn.getcmdtype() ~= ":" or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
-- 					end,
-- 				},
-- 				copilot = {
-- 					name = "copilot",
-- 					module = "blink-copilot",
-- 					score_offset = 100,
-- 					async = true,
-- 				},
-- 			},
-- 		},
--
-- 		completion = {
-- 			documentation = {
-- 				auto_show = true,
-- 				auto_show_delay_ms = 500,
-- 			},
-- 			-- documentation = { auto_show = true, window = { border = "double" } },
--
-- 			ghost_text = { enabled = true },
--
-- 			menu = { draw = { treesitter = { "lsp " } }, border = "single" },
-- 			trigger = {
-- 				-- LSPs can indicate when to show the completion window via trigger characters
-- 				-- however, some LSPs (*cough* tsserver *cough*) return characters that would essentially
-- 				-- always show the window. We block these by default
-- 				show_on_blocked_trigger_characters = { " ", "\n", "\t", ":" },
-- 				-- when true, will show the completion window when the cursor comes after a trigger character when entering insert mode
-- 				show_on_insert_on_trigger_character = true,
-- 				-- list of additional trigger characters that won't trigger the completion window when the cursor comes after a trigger character when entering insert mode
-- 				show_on_x_blocked_trigger_characters = { "'", '"', "(" },
-- 			},
-- 		},
--
-- 		signature = {
-- 			window = {
-- 				border = "double",
-- 			},
-- 		},
--
-- 		-- experimental auto-brackets support
-- 		-- accept = { auto_brackets = { enabled = true } },
-- 		-- --
-- 		-- -- -- experimental signature help support
-- 		-- trigger = { signature_help = { enabled = true } },
-- 	}
-- }

return {
	"saghen/blink.cmp",
	-- optional: provides snippets for the snippet source
	dependencies = { "rafamadriz/friendly-snippets" },

	-- use a release tag to download pre-built binaries
	version = "1.*",
	-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
	-- build = 'cargo build --release',
	-- If you use nix, you can build from source using latest nightly rust with:
	-- build = 'nix run .#build-plugin',

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
		-- 'super-tab' for mappings similar to vscode (tab to accept)
		-- 'enter' for enter to accept
		-- 'none' for no mappings
		--
		-- All presets have the following mappings:
		-- C-space: Open menu or open docs if already open
		-- C-n/C-p or Up/Down: Select next/previous item
		-- C-e: Hide menu
		-- C-k: Toggle signature help (if signature.enabled = true)
		--
		-- See :h blink-cmp-config-keymap for defining your own keymap
		--     keymap = { preset = 'super-tab' },
		keymap = {
			preset = "default",
			["<CR>"] = { "accept", "select_and_accept", "fallback" },
			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<Tab>"] = {
				"snippet_forward",
				function() -- sidekick next edit suggestion
					return require("sidekick").nes_jump_or_apply()
				end,
			},
		},

		appearance = {
			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
		},

		-- (Default) Only show the documentation popup when manually triggered
		completion = { documentation = { auto_show = false } },

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},

		-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
		-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
		-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
		--
		-- See the fuzzy documentation for more information
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
