return {
  "jay-babu/mason-nvim-dap.nvim",
  dependencies = {
    "mfussenegger/nvim-dap",
    {
      "igorlfs/nvim-dap-view",
      commit = "21ae3b522e1ee4ec82f3e3624abd621e578aabc6",
      config = function()
        local dap = require("dap")
        local dv = require("dap-view")

        dv.setup({
          winbar = {
            show = true,
            sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
            default_section = "watches",
          },
        })

        dap.listeners.before.attach["dap-view-config"] = function()
          dv.open()
        end
        dap.listeners.before.launch["dap-view-config"] = function()
          dv.open()
        end
        dap.listeners.before.event_terminated["dap-view-config"] = function()
          dv.close()
        end
        dap.listeners.before.event_exited["dap-view-config"] = function()
          dv.close()
        end
      end,
    },
    { "theHamsta/nvim-dap-virtual-text", opts = {} },
  },
  lazy = true,
  opts = {
    handlers = {},
  },
}
