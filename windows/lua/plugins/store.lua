return {
  "alex-popov-tech/store.nvim",
  dependencies = { "OXY2DEV/markview.nvim" },
  cmd = "Store",
  opts = {},
  config = function(_, opts)
    local MIN_WIDTH, MIN_HEIGHT = 85, 18
    local cols, lines = vim.o.columns, vim.o.lines
    if cols < MIN_WIDTH or lines < MIN_HEIGHT then
      vim.notify(
        string.format("Store needs at least %dx%d (you have %dx%d)", MIN_WIDTH, MIN_HEIGHT, cols, lines),
        vim.log.levels.WARN
      )
      vim.api.nvim_create_user_command("Store", function()
        vim.notify(
          string.format("Resize to at least %dx%d columns/lines to open Store", MIN_WIDTH, MIN_HEIGHT),
          vim.log.levels.WARN
        )
      end, { force = true })
      return
    end

    local store = require "store"
    local err = store.setup(opts or {})
    if err then
      vim.notify(err, vim.log.levels.ERROR)
      vim.api.nvim_create_user_command("Store", function()
        vim.notify(err, vim.log.levels.ERROR)
      end, { force = true })
    end
  end,
}
