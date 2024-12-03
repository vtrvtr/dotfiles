---@diagnostic disable: lowercase-global
function confirm(confirm, mark, path)
  local Menu = require "nui.menu"

  local menu = Menu({
    position = "50%",
    size = {
      width = "50%",
      height = 2,
    },
    border = {
      style = "rounded",
      text = {
        top = string.format("Replace mark %s %s?", mark, path),
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
    if t.name == mark then return true end
  end
  return false
end

function sep()
  if jit then
    local os = string.lower(jit.os)
    if os ~= "windows" then
      return "/"
    else
      return "\\"
    end
  else
    return "/"
  end
end

function truncate_path(path)
  local parts = vim.split(path, sep(), { trimempty = true })
  return string.format("[%s/%s..%s/%s]", parts[1], parts[2], parts[#parts - 1], parts[#parts])
end

function find_tag(key)
  local tags = require("grapple").tags()
  for i = 1, #tags do
    local tag = tags[i]
    if tag ~= nil and key == tag.name then return tag end
    return nil
  end
end

function file_name_from_tag(key)
  local tag = find_tag(key)
  if tag == nil then return string.format("Mark %s", key) end
  return string.format("%s %s", key, truncate_path(tag["path"]))
end

function make_key(key)
  return {
    "m" .. string.lower(key),
    function()
      if exists(key) then
        confirm(function()
          vim.notify(string.format("🗡%s File marked.", key))
          require("grapple").tag { name = key }
        end, key, truncate_path(require("grapple").find({ name = key })["path"]))
      else
        vim.notify(string.format("🗡%s File marked.", key))
        require("grapple").tag { name = key }
      end
    end,
    desc = file_name_from_tag(key),
  }
end

function make_get_key(key)
  return {
    "," .. string.lower(key),
    function() require("grapple").select { name = key } end,
    desc = string.format("Go %s", key),
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

    wk.add {
      { "m", group = "+Mark Grapple" },
      make_key "Q",
      make_key "W",
      make_key "E",
      make_key "R",
      make_key "T",
      make_key "Y",
      make_key "A",
      make_key "S",
      make_key "D",
      make_key "Z",
      make_key "C",
      make_key "X",
      { ",", group = "+Go Grapple" },
      make_get_key "Q",
      make_get_key "W",
      make_get_key "E",
      make_get_key "R",
      make_get_key "T",
      make_get_key "Y",
      make_get_key "A",
      make_get_key "S",
      make_get_key "D",
      make_get_key "Z",
      make_get_key "C",
      make_get_key "X",
      { ",f", function() require("grapple").open_tags() end, desc = "Show tags" },
      { "mf", function() require("grapple").open_tags() end, desc = "Show tags" },
    }
  end,
}
