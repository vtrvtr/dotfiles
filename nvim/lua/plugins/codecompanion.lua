return {
  "olimorris/codecompanion.nvim",
  enabled = true,
  opts = function()
    local opts = {
      extensions = {
        history = {
          opts = {
            keymap = "<leader>ah",
            picker = "snacks",
          },
        },
        vectorcode = {
          -- TODO: vectorcode (mb chromadb) is a pita to install
          enabled = false,
          ---@type VectorCode.CodeCompanion.ExtensionOpts
          opts = {
            tool_group = {
              -- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
              enabled = true,
              -- a list of extra tools that you want to include in `@vectorcode_toolbox`.
              -- if you use @vectorcode_vectorise, it'll be very handy to include
              -- `file_search` here.
              extras = {},
              collapse = false, -- whether the individual tools should be shown in the chat
            },
            tool_opts = {
              ---@type VectorCode.CodeCompanion.ToolOpts
              ["*"] = {},
              ---@type VectorCode.CodeCompanion.LsToolOpts
              ls = {},
              ---@type VectorCode.CodeCompanion.VectoriseToolOpts
              vectorise = {},
              ---@type VectorCode.CodeCompanion.QueryToolOpts
              query = {
                max_num = { chunk = -1, document = -1 },
                default_num = { chunk = 50, document = 10 },
                include_stderr = false,
                use_lsp = false,
                no_duplicate = true,
                chunk_mode = false,
                ---@type VectorCode.CodeCompanion.SummariseOpts
                summarise = {
                  ---@type boolean|(fun(chat: CodeCompanion.Chat, results: VectorCode.QueryResult[]):boolean)|nil
                  enabled = false,
                  adapter = nil,
                  query_augmented = true,
                },
              },
              files_ls = {},
              files_rm = {},
            },
          },
        },
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            show_result_in_chat = true, -- Show mcp tool results in chat
            make_vars = true, -- Convert resources to #variables
            make_slash_commands = true, -- Add prompts as /slash commands
          },
        },
        contextfiles = {
          opts = {
            {
              slash_command = {
                enabled = true,
                name = "context",
                ctx_opts = {
                  context_dir = ".claude/",
                  root_markers = { ".git" },
                  gist_ids = {},
                  enable_local = true,
                },
                format_opts = {
                  ---@param context_file ContextFiles.ContextFile the context file to prepend the prefix
                  prefix = function(context_file)
                    return string.format(
                      "Please follow the rules located at `%s`:",
                      vim.fn.fnamemodify(context_file.file, ":.")
                    )
                  end,
                  suffix = "",
                  separator = "",
                },
              },
            },
          },
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
        http = {
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
        diff = {
          enabled = true,
          close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
          layout = "horizontal", -- vertical|horizontal split for default provider
          -- opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
          provider = "mini_diff", -- default|mini_diff
        },
      },

      prompt_library = {
        ["Code Expert"] = {
          strategy = "chat",
          description = "Get some special advice from an LLM",
          opts = {
            auto_submit = true,
            stop_context_insertion = true,
            user_prompt = true,
          },
          prompts = {
            {
              role = "system",
              content = function(context)
                return "I want you to act as a senior "
                  .. context.filetype
                  .. " developer. You're only answering questions, so we you don't actually change the code of the current repository. You're happy to create new files for debugging if necessary."
              end,
            },
            {
              role = "user",
              content = function(context)
                -- Leverage auto_tool_mode which disables the requirement of approvals and automatically saves any edited buffer
                vim.g.codecompanion_auto_tool_mode = true

                -- Some clear instructions for the LLM to follow
                return [[### Instructions

### Steps to Follow

You must answer the questions based on the current repository. You're allowed to use @{sequentialthinking} @{neovim__read_multiple_files} @{file_search} @{grep_search} @{memory} @{neovim__read_multiple_files} @{neovim__list_directory} @{neovim__find_files} @{cmd_runner} @{vectorcode_toolbox} to crawl this code base.

**IMPORTANT**: Be efficient in your queries, don't use more tokens than necessary.

1. We don't want to change any files, unless specified. 
2. Check memories to see if there's any relevant with @{memory}
3. Start by reading .claude/ or CLAUDE.md for pointers for this particular project. Update memory.
4. You can create new files if needed. 
5. Clean up any temporary files afterwards. 

]]
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
      },
      diff = {
        enabled = true,
        close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
        layout = "horizontal", -- vertical|horizontal split for default provider
        opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
        provider = "mini_diff", -- default|mini_diff
      },
    }

    -- Enables caching
    -- FIX: VectorCode installation is broken on .7.4
    --     vim.api.nvim_create_autocmd("LspAttach", {
    --       callback = function()
    --         local cacher = require("vectorcode.config").get_cacher_backend()
    --         local bufnr = vim.api.nvim_get_current_buf()
    -- --         vectorcode.cacher.default.async_check is deprecated, use require("vectorcode.cacher").utils.async_check instead.
    -- -- Feature will be removed in VectorCode 0.7.0
    --         cacher.utils.async_check(
    --           "config",
    --           function()
    --             cacher.register_buffer(bufnr, {
    --               n_query = 10,
    --             })
    --           end,
    --           nil
    --         )
    --       end,
    --       desc = "Register buffer for VectorCode",
    --     })

    local wk = require "which-key"
    wk.add {
      { "<leader>a7", "<cmd>CodeCompanionChat Toggle<CR>" },
      desc = "Code companion Chat",
    }
    wk.add {
      mode = { "n" },
      { "<leader>a8", "<cmd>CodeCompanionActions<CR>" },
      desc = "Code Companion actions",
    }
    return opts
  end,

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",

    {
      "ravitemer/codecompanion-history.nvim",
    },
    {
      "Davidyz/VectorCode",
      version = "0.7.7", -- optional, depending on whether you're on nightly or release
      dependencies = { "nvim-lua/plenary.nvim" },
      cmd = "VectorCode", -- if you're lazy-loading VectorCode
      lazy = true,
    },

    {
      "ravitemer/mcphub.nvim",
      build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
      cmd = { "MCPhub", "MCPhubConnect", "MCPhubDisconnect" }, -- Only load when needed
      lazy = true,
      config = function() require("mcphub").setup() end,
    },
    {
      "zbirenbaum/copilot.lua",
      cmd = "Copilot",
      build = ":Copilot auth",
      event = "BufReadPost",
      dependencies = {
        "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
      },
      init = function() vim.g.copilot_nes_debounce = 500 end,
      opts = function(opts)
        opts = {
          nes = {
            enabled = true,
            keymap = {
              accept_and_goto = "<leader>p",
              accept = false,
              dismiss = "<Esc>",
            },
          },
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
    "banjo/contextfiles.nvim",
  },
}
