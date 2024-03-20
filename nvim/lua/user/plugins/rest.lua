return {
  "vhyrro/luarocks.nvim",
  event = "VeryLazy",
  -- branch = "go-away-python",
  -- config = function() require("luarocks").setup {} end,
  opts = {
    rocks = { "lua-curl", "nvim-nio", "mimetypes", "xml2lua" }, -- Specify LuaRocks packages to install
  },
}
