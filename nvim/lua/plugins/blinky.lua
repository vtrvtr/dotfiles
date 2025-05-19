return {
  "saghen/blink.cmp",
  enabled = require("helpers").enable_on_linux(),
  lazy = false, -- lazy loading handled internally
  -- optional: provides snippets for the snippet source
  dependencies = { "rafamadriz/friendly-snippets", "fang2hou/blink-copilot" },

  -- use a release tag to download pre-built binaries
  version = "v1.*",
  -- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  build = "cargo build --release",

  opts = {
    keymap = {
      preset = "default",
      ["<CR>"] = { "accept", "select_and_accept", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
    },

    sources = {
      default = { "copilot" },

      providers = {
        cmdline = {
          -- ignores cmdline completions when executing shell commands
          enabled = function() return vim.fn.getcmdtype() ~= ":" or not vim.fn.getcmdline():match "^[%%0-9,'<>%-]*!" end,
        },
        copilot = {
          name = "copilot",
          module = "blink-copilot",
          score_offset = 100,
          async = true,
        },
      },
    },

    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
      },
      -- documentation = { auto_show = true, window = { border = "double" } },

      ghost_text = { enabled = true },

      menu = { draw = { treesitter = { "lsp " } }, border = "single" },
      trigger = {
        -- LSPs can indicate when to show the completion window via trigger characters
        -- however, some LSPs (*cough* tsserver *cough*) return characters that would essentially
        -- always show the window. We block these by default
        show_on_blocked_trigger_characters = { " ", "\n", "\t", ":" },
        -- when true, will show the completion window when the cursor comes after a trigger character when entering insert mode
        show_on_insert_on_trigger_character = true,
        -- list of additional trigger characters that won't trigger the completion window when the cursor comes after a trigger character when entering insert mode
        show_on_x_blocked_trigger_characters = { "'", '"', "(" },
      },
    },

    signature = {
      window = {
        border = "double",
      },
    },

    -- experimental auto-brackets support
    -- accept = { auto_brackets = { enabled = true } },

    -- experimental signature help support
    -- trigger = { signature_help = { enabled = true } },
  },
}
