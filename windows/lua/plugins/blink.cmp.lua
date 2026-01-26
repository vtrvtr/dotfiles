-- -- Plugin: saghen/blink.cmp
-- -- Installed via store.nvim
--
return {
	"saghen/blink.cmp",
	lazy = false, -- Load immediately to prevent race conditions
	-- optional: provides snippets for the snippet source
	dependencies = { "rafamadriz/friendly-snippets" },

	-- use a release tag to download pre-built binaries
	version = "v1.*",
	-- Build from source for better stability
	-- build = "unset CARGO_TARGET_DIR && cargo build --release",

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
		keymap = {
			preset = "default",
			["<CR>"] = { "accept", "select_and_accept", "fallback" },
			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			-- ["<Tab>"] = {
			-- 	"snippet_forward",
			-- 	function() -- sidekick next edit suggestion
			-- 		return require("sidekick").nes_jump_or_apply()
			-- 	end,
			-- },
		},

		appearance = {
			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
		},

		-- Completion settings with proper trigger configuration
		completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 500,
			},
			ghost_text = { enabled = true },
			menu = { draw = { treesitter = { "lsp" } }, border = "single" },
			trigger = {
				-- Critical for LSP completion stability
				show_on_blocked_trigger_characters = { " ", "\n", "\t", ":" },
				show_on_insert_on_trigger_character = true,
				show_on_x_blocked_trigger_characters = { "'", '"', "(" },
			},
		},

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
		fuzzy = { implementation = "rust" },
	},
	opts_extend = { "sources.default" },
}
