return {
  "jay-babu/mason-nvim-dap.nvim",
  dependencies = {
    {
      "igorlfs/nvim-dap-view",
      config = function(plugin, opts)
        opts.winbar = {
          show = true,
          -- You can add a "console" section to merge the terminal with the other views
          sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
          -- Must be one of the sections declared above
          default_section = "watches",
        }

        winbar = {
          show = true,
          -- You can add a "console" section to merge the terminal with the other views
          sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
          -- Must be one of the sections declared above
          default_section = "watches",
        }

        local dap, dv = require "dap", require "dap-view"
        dap.listeners.before.attach["dap-view-config"] = function() dv.open() end
        dap.listeners.before.launch["dap-view-config"] = function() dv.open() end
        dap.listeners.before.event_terminated["dap-view-config"] = function() dv.close() end
        dap.listeners.before.event_exited["dap-view-config"] = function() dv.close() end
      end,
    },
    { "theHamsta/nvim-dap-virtual-text", opts = {} },
  },
  lazy = true,
  opts = {
    handlers = {},
  },
}
