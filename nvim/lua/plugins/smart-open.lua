return {
  "danielfalk/smart-open.nvim",
  enabled = false,
  branch = "main",
  config = function()
    local os = string.lower(jit.os)
    if os ~= "windows" then require("telescope").load_extension "smart_open" end
  end,
  -- enabled = function()
  --   local os = string.lower(jit.os)
  --   if os ~= "windows" then
  --     return true
  --   else
  --     return false
  --   end
  -- end,
  dependencies = {
    "kkharji/sqlite.lua",
    -- Only required if using match_algorithm fzf
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-telescope/telescope-fzy-native.nvim" },
  },
}
