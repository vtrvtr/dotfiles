-- Plugin: dmtrKovalenko/fff.nvim
-- Installed via store.nvim

return {
  "dmtrKovalenko/fff.nvim",
  build = "unset CARGO_TARGET_DIR && nix run .#release",
  opts = {},
  keys = {
    {
      "<leader>ff",
      function() require("fff").find_files() end,
      desc = "Open file picker",
    },
  },
}
