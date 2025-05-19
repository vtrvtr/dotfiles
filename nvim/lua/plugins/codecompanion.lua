return {
  "olimorris/codecompanion.nvim",
  opts = function()
    local opts = {
      extensions = {
        vectorcode = {
          opts = { add_tool = true, add_slash_command = true, tool_opts = {} },
        },
      },
      strategies = {
        chat = {
          adapter = "copilot",
          slash_commands = {
            ["file"] = {
              -- Location to the slash command in CodeCompanion
              callback = "strategies.chat.slash_commands.file",
              description = "Select a file using Snacks",
              opts = {
                provider = "snacks", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks"
                contains_code = true,
              },
            },
            ["buffer"] = {
              -- Location to the slash command in CodeCompanion
              callback = "strategies.chat.slash_commands.buffer",
              description = "Select a buffer using Snacks",
              opts = {
                provider = "snacks", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks"
                contains_code = true,
              },
            },
          },
        },
        inline = {
          adapter = "copilot",
        },
      },
      show_defaults = false,
      adapters = {
        copilot = function()
          local adapters = require "codecompanion.adapters"
          return adapters.extend("copilot", {
            schema = {
              model = {
                default = "claude-sonnet-4",
                -- default = "o4-mini",
              },
            },
          })
        end,
      },
      display = {
        chat = {
          window = {
            layout = "horizontal", -- float|vertical|horizontal|buffer
            position = nil, -- left|right|top|bottom (nil will default depending on vim.opt.splitright|vim.opt.splitbelow)
            border = "single",
            height = 0.3,
            width = 0.45,
            relative = "editor",
            full_height = true, -- when set to false, vsplit will be used to open the chat buffer vs. botright/topleft vsplit
            opts = {
              breakindent = true,
              cursorcolumn = false,
              cursorline = false,
              foldcolumn = "0",
              linebreak = true,
              list = false,
              numberwidth = 1,
              signcolumn = "no",
              spell = false,
              wrap = true,
            },
          },
        },
      },
    }

    -- Enables caching
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function()
        local cacher = require("vectorcode.config").get_cacher_backend()
        local bufnr = vim.api.nvim_get_current_buf()
        cacher.async_check(
          "config",
          function()
            cacher.register_buffer(bufnr, {
              n_query = 10,
            })
          end,
          nil
        )
      end,
      desc = "Register buffer for VectorCode",
    })

    local wk = require "which-key"
    wk.add {
      mode = { "n" },
      { "<leader>aa", "<cmd>CodeCompanionChat Toggle<CR>" },
      desc = "Code companion Chat",
    }
    wk.add {
      mode = { "n" },
      { "<leader>ac", "<cmd>CodeCompanionActions<CR>" },
      desc = "Code Companion actions",
    }
    return opts
  end,

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "Davidyz/VectorCode",
      version = "0.6.9", -- optional, depending on whether you're on nightly or release
      dependencies = { "nvim-lua/plenary.nvim" },
    },
    {
      "zbirenbaum/copilot.lua",
      cmd = "Copilot",
      build = ":Copilot auth",
      event = "BufReadPost",
      dependencies = {},
      opts = function(opts)
        opts = {
          suggestion = { enabled = false },
          panel = { enabled = false },
          filetypes = {
            markdown = true,
            help = true,
          },
        }
        return opts
      end,
    },
  },
}
