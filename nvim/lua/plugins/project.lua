return {
  "ahmedkhalf/project.nvim",
  config = function(config)
    require("project_nvim").setup {
      patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "Cargo.toml", "package.py" },
      manual_mode = true,
      silent_chdir = false,
      detection_methods = { "pattern" },
    }

    local wk = require "which-key"

    wk.add {
      {
        "<leader>fr",
        function() require("telescope").extensions.projects.projects {} end,
        desc = "Recent projects",
      },
    }
  end,
}
