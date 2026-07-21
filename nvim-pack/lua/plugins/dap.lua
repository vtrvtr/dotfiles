return {
	"jay-babu/mason-nvim-dap.nvim",
	dependencies = {
		"mfussenegger/nvim-dap",
		{
			"igorlfs/nvim-dap-view",
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
	keys = {
		{ "<leader>d", desc = "Dap" },
	},
	config = function(_, opts)
		-- Register lldb adapter for rustaceanvim and launch.json. Deferred here
		-- (was an eager `init`) so the blocking `rustc --print sysroot` call no
		-- longer runs on every startup / file open — only when DAP loads.
		local dap = require("dap")

		-- Get Rust sysroot for LLDB formatters
		local handle = io.popen("rustc --print sysroot")
		local rustc_sysroot = handle:read("*a"):gsub("[\n\r]", "")
		handle:close()

		-- Absolute path is required: lldb-vscode's runInTerminal reverse-request
		-- echoes back argv[0] resolved against the debuggee cwd, so a bare name
		-- becomes "<cwd>/lldb-vscode" and jobstart rejects it.
		dap.adapters.lldb = {
			type = "executable",
			command = vim.fn.exepath("lldb-vscode"),
			name = "lldb",
		}

		-- Prepend Rust LLDB formatters to every type="lldb" config. An on_config
		-- listener rather than a dap.run wrapper: wrapping dropped run()'s second
		-- `opts` argument, breaking restart and new-session handling.
		dap.listeners.on_config["rust.lldb_formatters"] = function(config)
			if config.type ~= "lldb" then
				return config
			end
			local formatters = {
				'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"',
				'command source -s 0 "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_commands"',
			}
			return vim.tbl_extend("force", config, {
				initCommands = vim.list_extend(formatters, config.initCommands or {}),
			})
		end

		-- nvim-dap has no preLaunchTask support (it is a VSCode tasks.json
		-- feature), so run it here. on_config is invoked inside a coroutine, so
		-- blocking on the build is safe; a failed build aborts the session
		-- rather than launching a stale binary.
		dap.listeners.on_config["prelaunchtask"] = function(config)
			local task = config.preLaunchTask
			if not task then
				return config
			end

			local cmd = type(task) == "table" and task or { "sh", "-c", task }
			local cwd = config.cwd
			if not cwd or cwd == "" or cwd:find("${", 1, true) then
				cwd = vim.fn.getcwd()
			end

			local co = assert(coroutine.running(), "on_config runs in a coroutine")
			vim.notify("preLaunchTask: " .. table.concat(cmd, " "), vim.log.levels.INFO)
			vim.system(cmd, { cwd = cwd, text = true }, function(res)
				vim.schedule(function()
					coroutine.resume(co, res)
				end)
			end)
			local res = coroutine.yield()

			if res.code ~= 0 then
				local out = vim.trim((res.stderr or "") .. (res.stdout or ""))
				vim.notify(
					("preLaunchTask failed (exit %d), not launching:\n%s"):format(res.code, out),
					vim.log.levels.ERROR
				)
				return vim.tbl_extend("force", config, { preLaunchTask = dap.ABORT })
			end

			return vim.tbl_extend("force", config, { preLaunchTask = nil })
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

		require("mason-nvim-dap").setup(opts)
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
