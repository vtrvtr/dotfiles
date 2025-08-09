return {
  "dmtrKovalenko/fff.nvim",
  build = "unset CARGO_TARGET_DIR && nix run .#release",
  -- "cargo build --release",
  -- or if you are using nixos
  -- build = ,
  opts = {
    -- pass here all the options
  },
  keys = {
    {
      "<leader>ff", -- try it if you didn't it is a banger keybinding for a picker
      function()
        require("fff").find_files() -- or find_in_git_root() if you only want git files
      end,
      desc = "Open file picker",
    },
  },
}
