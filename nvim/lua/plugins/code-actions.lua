return {
  'weilbith/nvim-code-action-menu',
  cmd = "CodeActionLoad",
  name = "code-action",
  config = function()
    require("nvim-code-action-menu").setup() {}
  end
}
