return {
  "folke/flash.nvim",

  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    modes = {
      treesitter = {
        label = {
          rainbow = {
            enabled = true,
          },
        },
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "R", mode = "o",               function() require("flash").remote() end,     desc = "Remote Flash" },
    {
      "r",
      mode = { "o", "x" },
      function()
        require("flash").treesitter_search(
          {
            remote_op = {
              restore = true,
              motion = true,

            },

          }

        )
      end,
      desc = "Treesitter Search"

    },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
