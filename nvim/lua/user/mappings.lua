-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
return {
  -- first key is the mode
  v = {
    ["<Enter><Enter>"] = {
      function() vim.lsp.buf.code_action() end,
      desc = "Show code actions",
    },
  },
  x = {
    ["<Enter><Enter>"] = {
      function() vim.lsp.buf.code_action() end,
      desc = "Show code actions",
    },
  },
  n = {
    -- second key is the lefthand side of the map
    -- mappings seen under group name "Buffer"
    ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    ["<leader>bD"] = {
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
    ["<leader>b"] = { name = "Buffers" },
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
    ["<leader>l"] = {
      f = {
        function() vim.lsp.buf.format() end,
        "Format buffer",
      },
      R = {
        function() require("telescope.builtin").lsp_references() end,
        "Find all references",
      },
      D = {
        function() require("telescope.builtin").diagnostics() end,
        "Show diagonostics Telescope",
      },
      d = {
        function() vim.diagnostic.open_float() end,
        "Show diagonostics float",
      },
      r = {
        function() vim.lsp.buf.rename() end,
        "Rename symbol",
      },
    },
    ["g"] = {
      D = {
        "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>",
        "Go to definition in split",
      },
      d = {
        function() vim.lsp.buf.definition() end,
        "Go to definition",
      },
    },
    ["<leader>q"] = {
      function() vim.lsp.buf.hover() end,
      desc = "Show hover info",
    },
    -- Recent jumps
    ["<s-e>"] = {
      function() require("portal.builtin").jumplist.tunnel { max_results = 10 } end,
      desc = "Search recent files used",
    },
    -- Function signature help
    ["<C-k>"] = {
      function() require("lsp_signature").toggle_float_win() end,
      desc = "Show function signature",
    },
    -- Toggle TErm

    ["<leader>1"] = {
      "<cmd>1ToggleTerm<cr>",
      desc = "Toggle Terminal 1",
    },
    ["<leader>2"] = {
      "<cmd>2ToggleTerm<cr>",
      desc = "Toggle Terminal 2",
    },
    ["<leader>3"] = {
      "<cmd>3ToggleTerm<cr>",
      desc = "Toggle Terminal 3",
    },
    ["<leader>4"] = {
      "<cmd>4ToggleTerm<cr>",
      desc = "Toggle Terminal 4",
    },

    -- Neotest
    ["<leader>te"] = {
      name = "Tests",
    },
    ["<leader>ter"] = {
      function() require("neotest").run.run(vim.fn.expand "%") end,
      desc = "Run all tests.",
    },
    ["<leader>te<space>"] = {
      function() require("neotest").run.run() end,
      desc = "Run test under cursor.",
    },
    ["<leader>tef"] = {
      function() require("neotest").run.run_last() end,
      desc = "Run last test.",
    },
    ["<leader>tes"] = {
      function() require("neotest").summary.toggle() end,
      desc = "Test summary",
    },
    ["<leader>teo"] = {
      function() require("neotest").output_panel.toggle() end,
      desc = "Test output",
    },

    -- Split control
    ["<leader>w"] = {
      "<c-w>",
      name = "Window control",
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

    -- Telescope
    ["/"] = {
      "<cmd>Telescope current_buffer_fuzzy_find<cr>",
      desc = "Search in current buffer",
    },

    ["<leader>faa"] = {
      "<cmd>Telescope aerial<cr>",
      desc = "Document symbol search",
    },
    ["<leader>f"] = {
      y = {
        function() require("telescope").extensions.yank_history.yank_history() end,
        "Search clipboard",
      },
      q = {
        function() require("telescope").extensions.macroscope.default() end,
        "Search macros",
      },
      ["/"] = {
        "<cmd>MurenToggle<cr>",
        "Muren search and replace",
      },
    },
    -- Neogit
    ["<leader>gg"] = {
      function() require("neogit").open { kind = "split_above" } end,
      desc = "Open neogit",
    },

    -- quick save
    -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
}
