return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    picker = {
      enabled = true,
      matcher = { sort_empty = true, frecency = true, cwd_bonus = true },
      layout = {
        cycle = true,
        --- Use the default layout or vertical if the window is too narrow
        preset = function() return vim.o.columns >= 160 and "default" or "vertical" end,
      },
      formatters = {
        file = {
          filename_first = true,
        },
      },
      layouts = {
        vertical = {
          layout = {
            width = 0.8,
            min_width = 100,
            height = 0.7,
            box = "vertical",
            border = "rounded",
            title = "{title} {live} {flags}",
            title_pos = "center",
            { win = "input", height = 1, border = "bottom" },
            { win = "list", border = "none" },
            { win = "preview", title = "{preview}", height = 0.7, border = "top" },
          },
        },
      },
    },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    animate = { enabled = true },
    dashboard = {
      -- your dashboard configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      --
      --
      --
      --
      --
      sections = {
        { section = "keys", gap = 1, padding = 1 },
        { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        {
          pane = 2,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function() return Snacks.git.get_root() ~= nil end,
          cmd = "git status --short --branch --renames",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        },
        { section = "startup" },
      },
    },
  },
  keys = {
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    -- find
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fc", function() Snacks.picker.files { cwd = vim.fn.stdpath "config" } end, desc = "Find Config File" },
    { "<leader>ff", function() Snacks.picker.smart() end, desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    { "<leader>fo", function() Snacks.picker.recent() end, desc = "Recent" },
    { "<leader>fn", function() Snacks.picker.notifications() end, desc = "Notifications" },
    { "<leader>fr", function() Snacks.picker.resume() end, desc = "Resume" },
    -- git
    { "<leader>gc", function() Snacks.picker.git_log() end, desc = "Git Log" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    -- Grep
    { "/", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
    { "<leader>fw", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>fW", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    -- search
    { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
    { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
    { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
    { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
    { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
    { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>fr", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
    { "<leader>qp", function() Snacks.picker.projects() end, desc = "Projects" },
    -- LSP
    { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
    { "<leader>ls", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>faa", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
  },
}
