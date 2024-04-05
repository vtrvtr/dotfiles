return {
  'Pocco81/auto-save.nvim',
  event = "BufEnter",
  opts = function(_, config)
    config.debounce_delay = 1000
    config.execution_message = {
      message = function() return "" end,
    }
    -- config.trigger_events = {"InsertLeave"}
    return config -- return final config table
  end,
}
