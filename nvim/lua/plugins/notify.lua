return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  config = function(_, _)
    vim.notify = require "notify"
    require("notify").setup {
      max_width = 300,
      max_height = 100,
      background_colour = "NotifyBackground",
      on_open = function() end,
      on_close = function() end,
      fps = 60,
      icons = {
        DEBUG = "",
        ERROR = "",
        INFO = "",
        TRACE = "✎",
        WARN = "",
      },
      level = 2,
      minimum_width = 50,
      render = "default",
      time_formats = {
        notification = "%T",
        notification_history = "%FT%T",
      },
      timeout = 100,
      top_down = true,
      stages = {
        function(state)
          local stages_util = require "notify.stages.util"
          local next_height = state.message.height + 2
          local next_row = stages_util.available_slot(state.open_windows, next_height, stages_util.DIRECTION.BOTTOM_UP)
          if not next_row then return nil end
          return {
            relative = "editor",
            anchor = "NE",
            width = state.message.width,
            height = state.message.height,
            col = (vim.opt.columns:get() / 2) + state.message.width / 2,
            row = 100,
            border = "double",
            style = "minimal",
            opacity = 0,
          }
        end,
        function()
          return {
            opacity = { 100 },
            row = 100,
          }
        end,
        function()
          return {
            width = {
              1,
              frequency = 0.5,
              damping = 0.4,
              complete = function(cur_width) return cur_width < 10 end,
            },
            opacity = {
              0,
              frequency = 2,
              damping = 0.4,
              complete = function(cur_opacity) return cur_opacity <= 4 end,
            },
            col = { -vim.opt.columns:get() },
            row = { 100 },
          }
        end,
      },
    }
  end,
}
