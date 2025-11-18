return {
  "echasnovski/mini.nvim",
  version = false,
  dependencies = {
    "folke/which-key.nvim",
  },
  config = function()
    local files = require "mini.files"
    files.setup {
      windows = {
        max_number = math.huge,
        preview = true,
        width_focus = 50,
        width_nofocus = 15,
        width_preview = 75,
      },
    }

    local function map_split(buf_id, lhs, direction)
      local rhs = function()
        local new_target_window
        vim.api.nvim_win_call(MiniFiles.get_target_window(), function()
          vim.cmd(direction .. " split")
          new_target_window = vim.api.nvim_get_current_win()
        end)
        MiniFiles.set_target_window(new_target_window)
      end
      local desc = "Split " .. direction
      vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local buf_id = args.data.buf_id
        map_split(buf_id, "gs", "belowright horizontal")
        map_split(buf_id, "gv", "belowright vertical")
      end,
    })

    local function files_set_cwd()
      local cur_entry_path = MiniFiles.get_fs_entry().path
      local cur_directory = vim.fs.dirname(cur_entry_path)
      vim.notify("Cwd set to " .. cur_directory, "info")
      vim.fn.chdir(cur_directory)
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        vim.keymap.set("n", "c", files_set_cwd, { buffer = args.data.buf_id, desc = "Set cwd" })
      end,
    })

    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add {
        {
          "<leader>e",
          function()
            local path = vim.api.nvim_buf_get_name(0)
            if path == "" then path = vim.loop.cwd() end
            files.open(path)
          end,
          desc = "File explorer (mini.files)",
          mode = "n",
        },
      }
    end

    require("mini.surround").setup {
      highlight_duration = 500,
      mappings = {
        add = "<leader>sa",
        delete = "<leader>sd",
        find = "<leader>sf",
        find_left = "<leader>sF",
        highlight = "<leader>sh",
        replace = "<leader>sr",
        update_n_lines = "<leader>sn",
        suffix_last = "l",
        suffix_next = "n",
      },
      n_lines = 20,
      respect_selection_type = true,
      search_method = "cover",
      silent = false,
    }
  end,
}




