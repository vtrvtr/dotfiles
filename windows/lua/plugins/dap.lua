return {
	"jay-babu/mason-nvim-dap.nvim",
	dependencies = {
		"mfussenegger/nvim-dap",
		{
			"igorlfs/nvim-dap-view",
			commit = "21ae3b522e1ee4ec82f3e3624abd621e578aabc6",
			config = function()
				local dap = require("dap")
				local dv = require("dap-view")

				dv.setup({
					winbar = {
						show = true,
						sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
						default_section = "watches",
					},
				})

				dap.listeners.before.attach["dap-view-config"] = function()
					dv.open()
				end
				dap.listeners.before.launch["dap-view-config"] = function()
					dv.open()
				end
				dap.listeners.before.event_terminated["dap-view-config"] = function()
					dv.close()
				end
				dap.listeners.before.event_exited["dap-view-config"] = function()
					dv.close()
				end
			end,
		},
		-- { "theHamsta/nvim-dap-virtual-text", opts = {} },
	},
	lazy = true,
	init = function()
		-- Register lldb adapter early for rustaceanvim and launch.json
		local dap = require("dap")

		-- Get Rust sysroot for LLDB formatters
		local handle = io.popen("rustc --print sysroot")
		local rustc_sysroot = handle:read("*a"):gsub("[\n\r]", "")
		handle:close()

		dap.adapters.lldb = {
			type = "executable",
			command = "lldb-vscode",
			name = "lldb",
		}

		-- Add default initCommands for all LLDB configurations
		-- This will be merged with any configuration that uses type="lldb"
		local original_run = dap.run
		dap.run = function(config)
			if config.type == "lldb" and not config.initCommands then
				config.initCommands = {
					'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"',
					'command source -s 0 "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_commands"',
				}
			elseif config.type == "lldb" and config.initCommands then
				-- Prepend Rust formatters to existing initCommands
				local rust_commands = {
					'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"',
					'command source -s 0 "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_commands"',
				}
				for _, cmd in ipairs(config.initCommands) do
					table.insert(rust_commands, cmd)
				end
				config.initCommands = rust_commands
			end
			return original_run(config)
		end

		-- Configure default Rust debugging configuration
		dap.configurations.rust = {
			{
				name = "Launch",
				type = "lldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = {},
			},
		}
	end,
	opts = {
		handlers = {
			python = function(config)
				local dap = require("dap")
				dap.adapters.python = {
					type = "executable",
					command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
					args = { "-m", "debugpy.adapter" },
				}
				dap.configurations.python = {
					{
						type = "python",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						pythonPath = function()
							return "/usr/bin/python3"
						end,
					},
				}
			end,
		},
	},
}
