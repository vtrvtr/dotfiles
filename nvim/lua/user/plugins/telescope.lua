return {
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  dependencies = {
    {
      "nvim-telescope/telescope-live-grep-args.nvim",
      "debugloop/telescope-undo.nvim",
      -- This will not install any breaking changes.
      -- For major updates, this must be adjusted manually.
      version = "^1.0.0",
    },
  },
  config = function(_, opts)
    local actions = require "telescope.actions"
    local get_icon = require("astronvim.utils").get_icon
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
        u = {
          "<cmd>Telescope undo<CR>",
          "Undo",
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
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        preview = {
          filesize_limit = 3,
          timeout = 100,
        },
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
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
            preview_height = 0.8,
          },
        },
      },
    }
    require("telescope").load_extension "live_grep_args"
    require("telescope").load_extension "undo"
  end,
}
