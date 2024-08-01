return {
  "ahmedkhalf/project.nvim",
  config = function(config)
    require("project_nvim").setup {
      patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "Cargo.toml", "package.py" },
    }
  end,
}
