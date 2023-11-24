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
    -- tables with the `name` key will be registered with which-key if it's installed
    -- this is useful for naming menus
    ["<leader>b"] = { name = "Buffers" },
    ["gt"] = {
      function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
      desc = "Next buffer",
    },
    -- Zen Mode
    ["<C-w>z"] = {
      function()
        require("zen-mode").toggle {
          window = {},
        }
      end,
      desc = "Zen Mode",
    },
    -- Hover
    ["<leader>q"] = {
      function() vim.lsp.buf.hover() end,
      desc = "Show hover info",
    },
    -- Search recent
    -- ["<C-e>"] = {
    --   function()
    --     require("telescope.builtin").oldfiles()
    --   end,
    --   desc = "Search recent files used"
    -- },
    ["<C-e>"] = {
      function()
        local query = require("portal.builtin").jumplist.query()
        require("portal.builtin").jumplist.tunnel(query)
      end,
      desc = "Search recent files used",
    },
    ["<C-o>"] = {
      function()
        local query = require("portal.builtin").jumplist.query()
        require("portal.builtin").jumplist.tunnel_forward(query)
      end,
      desc = "Search recent files used forward",
    },
    ["<C-i>"] = {
      function()
        local query = require("portal.builtin").jumplist.query()
        require("portal.builtin").jumplist.tunnel_backward(query)
      end,
      desc = "Search recent files used backwards",
    },
    -- Code Actions
    ["<Enter><Enter>"] = {
      function() vim.lsp.buf.code_action() end,
      desc = "Show code actions",
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

    -- Navigate with alt
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
    -- Telescope 
    ["/"] = {
      "<cmd>Telescope current_buffer_fuzzy_find<cr>",
      desc = "Fuzzy search with Telescope",
    },

    -- quick save
    -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
}
