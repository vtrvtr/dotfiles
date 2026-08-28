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
			-- The stock rust formatters render enums as raw `$variants$`/`$discr$`
			-- trees; the prettifier turns them into `Some(7)` / `Kind::Tagged(9)`.
			-- Neither covers third-party string types, hence compact_str.
			local lldb_dir = vim.fn.stdpath("config") .. "/lldb/"
			local formatters = {
				'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"',
				'command source -s 0 "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_commands"',
				'command script import "' .. lldb_dir .. 'rust_prettifier_for_lldb.py"',
				'command script import "' .. lldb_dir .. 'compact_str.py"',
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

		-- rust-analyzer emits no runnable for tests generated inside a macro
		-- invocation, so `:RustLsp debuggables` can only offer the crate-level
		-- target. Resolve the hashed test binary from cargo's JSON output instead.
		---@param cargo_args string[]
		---@param want string target name to prefer when cargo emits several
		---@param on_binary fun(path: string)
		local function cargo_test_binary(cargo_args, want, on_binary)
			-- Not `--all-features`: crates commonly gate parser/verbose tracing
			-- behind a `debug` feature that buries the run in output.
			local cmd = vim.list_extend(
				{ "cargo", "test", "--no-run", "--message-format=json" },
				cargo_args
			)
			vim.notify("building: " .. table.concat(cmd, " "), vim.log.levels.INFO)
			vim.system(cmd, { text = true }, function(res)
				vim.schedule(function()
					if res.code ~= 0 then
						vim.notify("cargo test --no-run failed:\n" .. vim.trim(res.stderr or ""), vim.log.levels.ERROR)
						return
					end
					local first, exact
					for line in vim.gsplit(res.stdout, "\n", { trimempty = true }) do
						local ok, msg = pcall(vim.json.decode, line)
						if ok and msg.executable and msg.executable ~= vim.NIL then
							first = first or msg.executable
							if msg.target and msg.target.name == want then
								exact = msg.executable
							end
						end
					end
					local binary = exact or first
					if not binary then
						vim.notify("no test executable for: " .. table.concat(cargo_args, " "), vim.log.levels.ERROR)
						return
					end
					on_binary(binary)
				end)
			end)
		end

		-- Nearest test name at or above the cursor: a plain `fn name`, or the
		-- first ident of a macro invocation (`some_test!(name => {`), which is how
		-- macro-generated tests get their name. Enclosing `mod`s are prepended,
		-- since `--exact` matches the full `a::b::test_name` path.
		local function test_name_at_cursor()
			local row = vim.api.nvim_win_get_cursor(0)[1]
			local name, indent
			for i = row, 1, -1 do
				local line = vim.fn.getline(i)
				local found = line:match("^%s*[%w_]+!%(%s*([%w_]+)") or line:match("fn%s+([%w_]+)")
				if found then
					name, indent = found, #line:match("^%s*")
					for j = i - 1, 1, -1 do
						local outer = vim.fn.getline(j)
						local mod = outer:match("^%s*mod%s+([%w_]+)%s*{")
						if mod and #outer:match("^%s*") < indent then
							name, indent = mod .. "::" .. name, #outer:match("^%s*")
						end
					end
					return name
				end
			end
			return ""
		end

		-- Ask cargo which package/target owns the current file, and which features
		-- that target requires -- guessing the package from the directory name or
		-- hardcoding a feature only works in the repo it was written for.
		---@param on_target fun(cargo_args: string[], target_name: string)
		local function cargo_target_at_cursor(on_target)
			local path = vim.api.nvim_buf_get_name(0)
			local manifest = vim.fs.find("Cargo.toml", { path = vim.fs.dirname(path), upward = true })[1]
			if not manifest then
				vim.notify("no Cargo.toml above " .. path, vim.log.levels.ERROR)
				return
			end
			local cmd = { "cargo", "metadata", "--no-deps", "--format-version", "1", "--manifest-path", manifest }
			vim.system(cmd, { text = true }, function(res)
				vim.schedule(function()
					if res.code ~= 0 then
						vim.notify("cargo metadata failed:\n" .. vim.trim(res.stderr or ""), vim.log.levels.ERROR)
						return
					end
					local meta = vim.json.decode(res.stdout)
					local pkg = vim.iter(meta.packages):find(function(p)
						return p.manifest_path == manifest
					end) or meta.packages[1]

					-- The target whose root file is this buffer (an integration test or
					-- bin); a unit test in any other file belongs to the lib.
					local target = vim.iter(pkg.targets):find(function(t)
						return t.src_path == path
					end) or vim.iter(pkg.targets):find(function(t)
						return vim.tbl_contains(t.kind, "lib")
					end)
					if not target then
						vim.notify("no cargo target owns " .. path, vim.log.levels.ERROR)
						return
					end

					local kind = target.kind[1]
					local flag = (kind == "test" and "--test") or (kind == "bin" and "--bin") or "--lib"
					local args = { "-p", pkg.name, flag }
					if flag ~= "--lib" then
						table.insert(args, target.name)
					end
					if not vim.tbl_isempty(target["required-features"] or {}) then
						vim.list_extend(args, { "--features", table.concat(target["required-features"], ",") })
					end
					on_target(args, target.name)
				end)
			end)
		end

		-- Resolve everything from the current buffer, then hand dap a config with
		-- no callbacks left in it. Prompting or blocking from inside dap's own
		-- coroutine hangs the editor once the debug UI has taken over.
		vim.api.nvim_create_user_command("RustDebugTest", function()
			local name = test_name_at_cursor()
			if name == "" then
				vim.notify("no test found at or above the cursor", vim.log.levels.ERROR)
				return
			end
			cargo_target_at_cursor(function(cargo_args, want)
				cargo_test_binary(cargo_args, want, function(binary)
				dap.run({
					name = "cargo test " .. name,
					type = "lldb",
					request = "launch",
					program = binary,
					-- No `--nocapture`: a chatty test streams every line through the
					-- DAP socket and drowns the editor. Read output in the repl instead.
					args = { name, "--exact", "--test-threads=1" },
					cwd = vim.fn.getcwd(),
					stopOnEntry = false,
					})
				end)
			end)
		end, { desc = "Debug the Rust test at the cursor" })
		vim.keymap.set("n", "<leader>dt", "<cmd>RustDebugTest<cr>", { desc = "Debug Rust test at cursor" })

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
