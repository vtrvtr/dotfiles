return {
  "rebelot/heirline.nvim",
  enabled = true,
  opts = function(_, opts)
    local status = require "astronvim.utils.status"

    opts.winbar = { -- create custom winbar
      -- store the current buffer number
      init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
      fallthrough = false, -- pick the correct winbar based on condition
      -- inactive winbar
      {
        condition = function() return not status.condition.is_active() end,
        -- show the path to the file relative to the working directory
        status.component.separated_path { path_func = status.provider.filename { modify = ":.:h" } },
        -- add the file name and icon
        status.component.file_info {
          file_icon = { hl = status.hl.file_icon "winbar", padding = { left = 0 } },
          file_modified = false,
          file_read_only = false,
          hl = status.hl.get_attributes("winbarnc", true),
          surround = false,
          update = "BufEnter",
        },
      },
      -- active winbar
      {
        -- show the path to the file relative to the working directory
        status.component.separated_path { path_func = status.provider.filename { modify = ":.:h" } },
        -- add the file name and icon
        status.component.file_info { -- add file_info to breadcrumbs
          file_icon = { hl = status.hl.filetype_color, padding = { left = 0 } },
          file_modified = false,
          file_read_only = false,
          hl = status.hl.get_attributes("winbar", true),
          surround = false,
          update = "BufEnter",
        },
        -- show the breadcrumbs
        status.component.breadcrumbs {
          icon = { hl = true },
          hl = status.hl.get_attributes("winbar", true),
          prefix = true,
          padding = { left = 0 },
        },
      },
    }
    opts.statusline = {
      -- default highlight for the entire statusline
      hl = { fg = "fg", bg = "bg" },
      -- each element following is a component in astronvim.utils.status module
      -- Vim mode
      status.component.builder {

        -- get vim current mode, this information will be required by the provider
        -- and the highlight functions, so we compute it only once per component
        -- evaluation and store it as a component attribute
        init = function(self)
          self.mode = vim.fn.mode(1) -- :h mode()
        end,
        -- Now we define some dictionaries to map the output of mode() to the
        -- corresponding string and color. We can put these into `static` to compute
        -- them at initialisation time.
        static = {
          mode_names = { -- change the strings if you like it vvvvverbose!
            n = "N",
            no = "N?",
            nov = "N?",
            noV = "N?",
            ["no\22"] = "N?",
            niI = "Ni",
            niR = "Nr",
            niV = "Nv",
            nt = "Nt",
            v = "V",
            vs = "Vs",
            V = "V_",
            Vs = "Vs",
            ["\22"] = "^V",
            ["\22s"] = "^V",
            s = "S",
            S = "S_",
            ["\19"] = "^S",
            i = "I",
            ic = "Ic",
            ix = "Ix",
            R = "R",
            Rc = "Rc",
            Rx = "Rx",
            Rv = "Rv",
            Rvc = "Rv",
            Rvx = "Rv",
            c = "C",
            cv = "Ex",
            r = "...",
            rm = "M",
            ["r?"] = "?",
            ["!"] = "!",
            t = "T",
          },
          mode_colors = {
            n = "#fab387",
            i = "green",
            v = "cyan",
            V = "cyan",
            ["\22"] = "cyan",
            c = "orange",
            s = "purple",
            S = "purple",
            ["\19"] = "purple",
            R = "orange",
            r = "orange",
            ["!"] = "red",
            t = "red",
          },
        },
        -- We can now access the value of mode() that, by now, would have been
        -- computed by `init()` and use it to index our strings dictionary.
        -- note how `static` fields become just regular attributes once the
        -- component is instantiated.
        -- To be extra meticulous, we can also add some vim statusline syntax to
        -- control the padding and make sure our string is always at least 2
        -- characters long. Plus a nice Icon.
        -- Same goes for the highlight. Now the foreground will change according to the current mode.
        hl = function(self)
          local mode = self.mode:sub(1, 1) -- get only the first mode character
          return { fg = self.mode_colors[mode], bold = true }
        end,
        -- Re-evaluate the component only on ModeChanged event!
        -- Also allows the statusline to be re-evaluated when entering operator-pending mode
        update = {
          "ModeChanged",
          pattern = "*:*",
          callback = vim.schedule_wrap(function() vim.cmd "redrawstatus" end),
        },
        {
          provider = function(self) return "⧨%2(" .. self.mode_names[self.mode] .. "%)" end,
        },
        -- define the surrounding separator and colors to be used inside of the component
        -- and the color to the right of the separated out section
        surround = {
          separator = "right",
          color = { main = "blank_bg", right = "file_info_bg" },
        },
      },
      -- we want an empty space here so we can use the component builder to make a new section with just an empty string
      status.component.builder {
        { provider = "" },
        -- define the surrounding separator and colors to be used inside of the component
        -- and the color to the right of the separated out section
        surround = { separator = "left", color = { main = "blank_bg" } },
      },
      -- add a component for the current git branch if it exists and use no separator for the sections
      status.component.fill(),
      status.component.git_branch {
        padding = { left = 3 },
        separator = "right",
        color = { right = "file_info_bg" },
      },
      -- add a component for the current git diff if it exists and use no separator for the sections
      status.component.git_diff { separator = "right", color = { right = "file_info_bg" } },
      -- fill the rest of the statusline
      -- the elements after this will appear in the middle of the statusline
      -- add a component to display if the LSP is loading, disable showing running client names, and use no separator
      status.component.lsp {
        lsp_client_names = false,
        surround = { separator = "left", color = "bg" },
      },
      -- fill the rest of the statusline
      -- the elements after this will appear on the right of the statusline
      {
        status.component.builder {
          -- astronvim.get_icon gets the user interface icon for a closed folder with a space after it
          {
            provider = status.provider.macro_recording(),
          },
          -- use the right separator and define the background color
        },
      },

      -- add a component for the current diagnostics if it exists and use the right separator for the section
      status.component.diagnostics { surround = { separator = "right" } },
      -- add a component to display LSP clients, disable showing LSP progress, and use the right separator
      status.component.lsp {
        lsp_progress = false,
        surround = { separator = "right" },
        padding = { right = 2 },
      },
      -- all of the children of this table will be treated together as a single component
      {
        -- define a simple component where the provider is just a folder icon
        status.component.builder {
          -- astronvim.get_icon gets the user interface icon for a closed folder with a space after it
          { provider = require("astronvim.utils").get_icon "FolderClosed" },
          -- add padding after icon
          -- set the foreground color to be used for the icon
          hl = { fg = "bg" },
          -- use the right separator and define the background color
          surround = { separator = "right", color = "folder_icon_bg" },
        },
        -- add a file information component and only show the current working directory name
        status.component.file_info {
          -- we only want filename to be used and we can change the fname
          -- function to get the current working directory name
          filename = { fname = function(nr) return vim.fn.getcwd(nr) end, padding = { left = 1 } },
          hl = { fg = "bg" },
          -- disable all other elements of the file_info component
          file_icon = false,
          file_modified = false,
          file_read_only = false,
          -- use no separator for this part but define a background color
          surround = { separator = "none", color = "folder_icon_bg", condition = false },
        },
      },
      status.component.builder {
        { provider = "" },
        -- define the surrounding separator and colors to be used inside of the component
        -- and the color to the right of the separated out section
        surround = { separator = "left", color = { main = "folder_icon_bg" } },
      },
      status.component.fill(),
      { -- make nav section with icon border
        -- add a navigation component and just display the percentage of progress in the file
        status.component.nav {
          -- add some padding for the percentage provider
          -- disable all other providers
          ruler = false,
          scrollbar = false,
          hl = { fg = "bg" },
          -- use no separator and define the background color
          surround = { color = "nav_icon_bg" },
        },
      },
      status.component.builder {
        { provider = "" },
        -- define the surrounding separator and colors to be used inside of the component
        -- and the color to the right of the separated out section
        surround = { separator = "left", color = { main = "nav_icon_bg" } },
      },
    }

    -- return the final options table
    return opts
  end,
}
