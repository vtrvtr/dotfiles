return {
  "saghen/blink.cmp",
  enabled = require("helpers").enable_on_linux(),
  lazy = false, -- lazy loading handled internally
  -- optional: provides snippets for the snippet source
  dependencies = "rafamadriz/friendly-snippets",

  -- use a release tag to download pre-built binaries
  version = "v0.*",
  -- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',

  opts = {
    keymap = {
      accept = "<CR>",
    },
    windows = {
      autocomplete = { border = "double" },
      documentation = { border = "rounded" },
    },
    highlight = {
      -- sets the fallback highlight groups to nvim-cmp's highlight groups
      -- useful for when your theme doesn't support blink.cmp
      -- will be removed in a future release, assuming themes add support
      use_nvim_cmp_as_default = true,
    },
    -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- adjusts spacing to ensure icons are aligned
    nerd_font_variant = "normal",

    trigger = {
      completion = {
        -- regex used to get the text when fuzzy matching
        -- changing this may break some sources, so please report if you run into issues
        -- todo: shouldnt this also affect the accept command? should this also be per language?
        keyword_regex = "[%w_\\-]",
        -- LSPs can indicate when to show the completion window via trigger characters
        -- however, some LSPs (*cough* tsserver *cough*) return characters that would essentially
        -- always show the window. We block these by default
        blocked_trigger_characters = { " ", "\n", "\t", ":" },
        -- when true, will show the completion window when the cursor comes after a trigger character when entering insert mode
        show_on_insert_on_trigger_character = true,
        -- list of additional trigger characters that won't trigger the completion window when the cursor comes after a trigger character when entering insert mode
        show_on_insert_blocked_trigger_characters = { "'", '"' },
      },
    },

    -- experimental auto-brackets support
    -- accept = { auto_brackets = { enabled = true } },

    -- experimental signature help support
    -- trigger = { signature_help = { enabled = true } },
  },
}
