return {
  "AckslD/muren.nvim",
  cmd = "MurenToggle",
  opts = {
    two_step = false,
    all_on_line = true,
    preview = true,
    cwd = true,
    files = "**/*",
    -- ui sizes
    patterns_width = 50,
    patterns_height = 10,
    options_width = 40,
    preview_height = 30,
    keys = {
      close = "q",
      toggle_side = "<Tab>",
      toggle_options_focus = "s",
      toggle_option_under_cursor = "<CR>",
      scroll_preview_up = "<Up>",
      scroll_preview_down = "<Down>",
      do_replace = "<CR>",
      -- NOTE these are not guaranteed to work, what they do is just apply `:normal! u` vs :normal! <C-r>`
      -- on the last affected buffers so if you do some edit in these buffers in the meantime it won't do the correct thing
      do_undo = "<localleader>u",
      do_redo = "<localleader>r",
    },
  },
}
