-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
return {
  -- first key is the mode
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      v = {
        ["<Enter><Enter>"] = {
          function() vim.lsp.buf.code_action() end,
          desc = "Show code actions",
        },
        ["<Leader>rv"] = {
          function() require("grug-far").with_visual_selection { prefills = { paths = vim.fn.expand "%" } } end,
          desc = "Search and replace selection",
        },
        ["<Leader>rf"] = {
          function() require("grug-far").open { prefills = { paths = vim.fn.expand "%" } } end,
          desc = "Search and replace current file",
        },
      },
      x = {
        ["<Enter><Enter>"] = {
          function() vim.lsp.buk.code_action() end,
          desc = "Show code actions",
        },
      },
      n = {
        -- second key is the lefthand side of the map
        -- mappings seen under group name "Buffer"
        ["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
        ["<Leader>bD"] = {
          function()
            require("astronvim.utils.status").heirline.buffer_picker(
              function(bufnr) require("astronvim.utils.buffer").close(bufnr) end
            )
          end,
          desc = "Pick to close",
        },
        -- Tabs
        ["gt"] = {
          function() vim.cmd.tabnext() end,
          desc = "Next tab",
        },
        -- tables with the `name` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        ["<Leader>b"] = { name = "Buffers" },
        -- Zen Mode
        ["<C-w>z"] = {
          function()
            require("zen-mode").toggle {
              window = {},
            }
          end,
          desc = "Zen Mode",
        },
        -- LSP
        ["<leader>ld"] = {
          function() vim.diagnostic.open_float() end,
          desc = "Diagnostics floaty",
        },
        ["<leader>lr"] = {
          function() vim.lsp.buf.rename() end,
          desc = "Rename",
        },
        ["<leader>lf"] = {
          function() vim.lsp.buf.format { async = true } end,
          desc = "Format",
        },
        ["gd"] = {
          function() vim.lsp.buf.definition() end,
          desc = "Go to definition",
        },
        ["gD"] = {
          "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>",
          desc = "Go to definition in split",
        },
        ["<Leader>q"] = {
          function() vim.lsp.buf.hover() end,
          desc = "Show hover info",
        },
        -- Function signature help
        ["<C-k>"] = {
          function() require("lsp_signature").toggle_float_win() end,
          desc = "Show function signature",
        },

        -- Neotest
        ["<Leader>te"] = {
          name = "Tests",
        },
        ["<Leader>ter"] = {
          function() require("neotest").run.run(vim.fn.expand "%") end,
          desc = "Run all tests.",
        },
        ["<Leader>te<space>"] = {
          function() require("neotest").run.run() end,
          desc = "Run test under cursor.",
        },
        ["<Leader>tef"] = {
          function() require("neotest").run.run_last() end,
          desc = "Run last test.",
        },
        ["<Leader>tes"] = {
          function() require("neotest").summary.toggle() end,
          desc = "Test summary",
        },
        ["<Leader>teo"] = {
          function() require("neotest").output_panel.toggle() end,
          desc = "Test output",
        },

        -- Split control
        ["<Leader>w"] = {
          "<c-w>",
          desc = "Window control",
        },
        ["<m-h>"] = {
          "<c-w><c-h>",
          desc = "Go to left split",
        },
        ["<m-j>"] = {
          "<c-w><c-j>",
          desc = "Go to up split",
        },
        ["<m-k>"] = {
          "<c-w><c-k>",
          desc = "Go to down split",
        },
        ["<m-l>"] = {
          "<c-w><c-l>",
          desc = "Go to right split",
        },
        ["<c-w><m-h>"] = {
          function(amount) require("smart-splits").swap_buf_left(amount) end,
          desc = "Swap left",
        },
        ["<c-w><m-j>"] = {
          function(amount) require("smart-splits").swap_buf_down(amount) end,
          desc = "Swap down",
        },
        ["<c-w><m-k>"] = {
          function(amount) require("smart-splits").swap_buf_up(amount) end,
          desc = "Swap up",
        },
        ["<c-w><m-l>"] = {
          function(amount) require("smart-splits").swap_buf_right(amount) end,
          desc = "Swap right",
        },
        ["<c-m-h>"] = {
          function(amount) require("smart-splits").resize_left(amount) end,
          desc = "Resize left",
        },
        ["<c-m-j>"] = {
          function(amount) require("smart-splits").resize_down(amount) end,
          desc = "Resize down",
        },
        ["<c-m-k>"] = {
          function(amount) require("smart-splits").resize_up(amount) end,
          desc = "Resize up",
        },
        ["ø"] = {
          function(amount) require("smart-splits").resize_right(amount) end,
          desc = "Resize right",
        },
        ["<c-m-l>"] = {
          function(amount) require("smart-splits").resize_right(amount) end,
          desc = "Resize right",
        },

        -- Mini files
        ["<Leader>e"] = {
          function()
            local mf = require "mini.files"
            mf.open(vim.api.nvim_buf_get_name(0))
          end,
          desc = "Open neogit",
        },

        -- quick save
        -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
      },
    },
  },
}
