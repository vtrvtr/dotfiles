-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "catppuccin-mocha",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- Normal = { bg = "#000000" },
      },
      astrotheme = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
      },
    },

    status = {
      -- colors = function(hl)
      --   local C = require("astroui.status").fallback_colors
      --   local get_hlgroup = require("astroui").get_hlgroup
      --   -- use helper function to get highlight group properties
      --   local comment_fg = get_hlgroup("Comment").fg
      --   hl.git_branch_fg = C.light_blue
      --   hl.git_added = C.green
      --   hl.git_changed = C.yellow
      --   hl.git_removed = C.red
      --   hl.blank_bg = get_hlgroup("Folded").fg
      --   hl.file_info_bg = get_hlgroup("Visual").bg
      --   hl.nav_icon_bg = get_hlgroup("String").fg
      --   hl.nav_fg = hl.nav_icon_bg
      --   hl.folder_icon_bg = get_hlgroup("Error").fg
      --   return hl
      -- end,

      separators = {
        left = { "", "" }, -- separator for the left side of the statusline
        right = { "", "" }, -- separator for the right side of the statusline
      },
      attributes = {
        mode = { bold = true },
      },
      icon_highlights = {
        file_icon = {
          statusline = false,
        },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
      VimIcon = "",
      ScrollText = "",
      GitBranch = "",
      GitAdd = "",
      GitChange = "",
      GitDelete = "",
    },
  },
}
