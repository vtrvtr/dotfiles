return {
  "nvim-telescope/telescope.nvim",
  lazy = true,
  dependencies = {
    {
      "nvim-telescope/telescope-live-grep-args.nvim",
      "debugloop/telescope-undo.nvim",
      "Myzel394/jsonfly.nvim",
      -- This will not install any breaking changes.
      -- For major updates, this must be adjusted manually.
      version = "^1.0.0",
    },
  },
  commit = "a4432dfb9b0b960c4cbc8765a42dc4fe2e029e8f",
  config = function(_, opts)
    vim.notify("Using telescope commit version, update when possible...", "info", { height = 400 })
    local actions = require "telescope.actions"
    local get_icon = require("astroui").get_icon
    local function flash(prompt_bufnr)
      require("flash").jump {
        pattern = "^",
        label = { after = { 0, 0 } },
        search = {
          mode = "search",
          exclude = {
            function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults" end,
          },
        },
        action = function(match)
          local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
          picker:set_selection(match.pos[1] - 1)
        end,
      }
    end

    local wk = require "which-key"

    wk.register({
      f = {
        w = {
          function() require("telescope").extensions.live_grep_args.live_grep_args() end,
          "Search words with rg",
        },
        f = {
          function() require("telescope").extensions.smart_open.smart_open() end,
          "Search smart open",
        },
        u = {
          "<cmd>Telescope undo<CR>",
          "Undo",
        },
        p = {
          function()
            local function get_filename_from_bufnr(bufnr)
              local info = vim.fn.getbufinfo(bufnr)
              if info and info[1] and info[1].name ~= "" then return info[1].name end
              return nil
            end

            local jumplist = vim.fn.getjumplist()[1]
            local sorted_jumplist = {}
            local added_files = {}
            for i = #jumplist, 1, -1 do
              if vim.api.nvim_buf_is_valid(jumplist[i].bufnr) then
                local filename = get_filename_from_bufnr(jumplist[i].bufnr)
                if not added_files[filename] and filename then
                  table.insert(sorted_jumplist, filename)
                  added_files[filename] = true
                end
              end
            end

            require("telescope").extensions.live_grep_args.live_grep_args { search_dirs = sorted_jumplist }
          end,
          "Grep jumplist",
        },
      },
    }, {
      prefix = "<leader>",
    })

    require("telescope").setup {
      defaults = {
        set_env = {
          LESS = "",
          DELTA_PAGER = "less",
        },
        git_worktrees = vim.g.git_worktrees,
        prompt_prefix = string.format("%s ", get_icon "Search"),
        selection_caret = string.format("%s ", get_icon "Selected"),
        path_display = {
          filename_first = {
            reverse_directories = false,
          },
        },
        sorting_strategy = "ascending",
        preview = {
          filesize_limit = 3,
          timeout = 100,
        },

        mappings = {
          i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<M-s>"] = actions.select_horizontal,
            ["<M-v>"] = actions.select_vertical,
            ["<c-s>"] = flash,
          },
          n = {
            ["q"] = actions.close,
            ["<C-s>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            s = flash,
          },
        },
      },
      extensions = {
        undo = {
          use_delta = true,
          side_by_side = true,
          diff_context_lines = 3,
          layout_strategy = "vertical",
          layout_config = {
            preview_height = 0.5,
          },
        },
      },
    }
    require("telescope").load_extension "live_grep_args"
    require("telescope").load_extension "undo"
    require("telescope").load_extension "yank_history"
    require("telescope").load_extension "jsonfly"
  end,
}
