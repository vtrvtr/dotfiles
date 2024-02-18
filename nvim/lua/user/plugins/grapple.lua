function confirm(confirm, mark)
  local Menu = require "nui.menu"
  local event = require("nui.utils.autocmd").event

  local menu = Menu({
    position = "50%",
    size = {
      width = 25,
      height = 2,
    },
    border = {
      style = "rounded",
      text = {
        top = string.format("Replace mark %s?", mark),
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
    lines = {
      Menu.item "Yes",
      Menu.item "No",
    },
    max_width = 20,
    keymap = {
      focus_next = { "j", "<Down>", "<Tab>" },
      focus_prev = { "k", "<Up>", "<S-Tab>" },
      close = { "<Esc>", "<C-c>" },
      submit = { "<CR>", "<Space>" },
    },
    -- on_close = function() print "Menu Closed!" end,
    on_submit = function(item)
      if item.text == "Yes" then confirm() end
    end,
  })

  -- mount the component
  menu:mount()
end

function exists(mark)
  local grapple = require "grapple"
  for _, t in ipairs(grapple.tags()) do
    if t.key == mark then return true end
  end
  return false
end

function truncate_path(path)
  local len = string.len(path)
  if len > 20 then
    local begin = string.sub(path, 0, 5)
    local finish = string.sub(path, len - 20, string.len(path))
    return string.format("%s..%s", begin, finish)
  end
  return path
end

function file_name_from_tag(key)
  local tag = require("grapple").find { key = key }
  if tag == nil then return string.format("Mark %s", key) end
  return string.format("Mark %s %s", key, truncate_path(tag["file_path"]))
end

function make_key(key)
  return {
    function()
      if exists(key) then
        confirm(function()
          vim.notify(string.format("🗡%s File marked.", key))
          require("grapple").tag { key = key }
        end, key)
      else
        vim.notify(string.format("🗡%s File marked.", key))
        require("grapple").tag { key = key }
      end
    end,
    file_name_from_tag(key),
  }
end

function make_get_key(key)
  return {
    function() require("grapple").select { key = key } end,
    string.format("Go %s", file_name_from_tag(key)),
  }
end

return {
  "cbochs/grapple.nvim",
  event = "BufEnter",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("grapple").setup {
      popup_options = {
        relative = "editor",
        width = 60,
        height = 7,
        style = "minimal",
        focusable = true,
        border = "rounded",
      },
    }
    local wk = require "which-key"
    wk.register {
      m = {
        name = "+Mark Grapple",
        w = make_key "W",
        e = make_key "E",
        r = make_key "R",
        q = make_key "Q",
        t = make_key "T",
        c = make_key "C",
        x = make_key "X",
        s = make_key "S",
        a = make_key "A",
        d = make_key "D",
        f = {
          function() require("grapple").popup_tags() end,
          "All tags",
        },
      },
      [","] = {
        name = "+Go Grapple",
        w = make_get_key "W",
        e = make_get_key "E",
        r = make_get_key "R",
        q = make_get_key "Q",
        t = make_get_key "T",
        c = make_get_key "C",
        x = make_get_key "X",
        s = make_get_key "S",
        a = make_get_key "A",
        d = make_get_key "D",
        f = {
          function() require("grapple").popup_tags() end,
          "All tags",
        },
      },
    }
  end,
}
