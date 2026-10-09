return {
	"rebelot/heirline.nvim",
	enabled = true,
	event = "VeryLazy",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"lewis6991/gitsigns.nvim",
	},
	config = function()
		local heirline = require("heirline")
		local conditions = require("heirline.conditions")
		local utils = require("heirline.utils")

		local theme_colors = require("theme.colors").dark

		local function setup_colors()
			return {
				bg = theme_colors.bg_alt,
				fg = theme_colors.fg,
				yellow = theme_colors.yellow,
				cyan = theme_colors.cyan,
				darkblue = theme_colors.dark_blue,
				green = theme_colors.green,
				orange = theme_colors.orange,
				violet = theme_colors.violet,
				magenta = theme_colors.magenta,
				blue = theme_colors.blue,
				red = theme_colors.red,
				grey = theme_colors.grey,
			}
		end

		heirline.load_colors(setup_colors())

		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				heirline.load_colors(setup_colors())
			end,
		})

		-- Track debug mode state
		local dmode_enabled = false
		vim.api.nvim_create_autocmd("User", {
			pattern = "DebugModeChanged",
			callback = function(args)
				dmode_enabled = args.data.enabled
				vim.cmd("redrawstatus") -- Force statusline refresh
			end,
		})

		local function is_ignored()
			local buftype = vim.bo.buftype
			local filetype = vim.bo.filetype
			local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")

			local ignored_buftypes = { nofile = true, nowrite = true, prompt = true, popup = true, terminal = true }
			local ignored_filetypes = { fugitive = true, oil = true, snacks_dashboard = true }
			local ignored_names = { ["[LSP Eldoc]"] = true, ["NvimTree_1"] = true, ["No Name"] = true }

			return ignored_buftypes[buftype] or ignored_filetypes[filetype] or ignored_names[bufname]
		end

		local FileIcon = {
			init = function(self)
				local filename = vim.api.nvim_buf_get_name(0)
				local extension = vim.fn.fnamemodify(filename, ":e")
				local tail = vim.fn.fnamemodify(filename, ":t")
				self.icon, self.icon_color =
					require("nvim-web-devicons").get_icon_color(tail, extension, { default = true })
				if not self.icon or self.icon == "" then
					self.icon = vim.fn.nr2char(0xf15b) --  Default file icon
				end
				if not self.icon_color then
					self.icon_color = "fg"
				end
			end,
			provider = function(self)
				return " " .. (self.icon or "") .. " "
			end,
			hl = function(self)
				return { fg = self.icon_color }
			end,
		}

		function isRecording()
			local reg = vim.fn.reg_recording()
			if reg == "" then
				return ""
			end -- not recording
			return "recording to " .. reg
		end

		local Macro = {
			init = function(self) end,
			provider = function(self)
				return isRecording()
			end,
			hl = function(self)
				return { fg = "fg", bold = true }
			end,
		}

		local DebugMode = {
			condition = function()
				return dmode_enabled
			end,
			provider = " 🐛 DEBUG ",
			hl = { fg = "bg", bg = "red", bold = true },
			update = { "User" },
		}

		local FileName = {
			init = function(self)
				self.filename = vim.api.nvim_buf_get_name(0)
			end,
			provider = function(self)
				local filename = vim.fn.fnamemodify(self.filename, ":.")
				if filename == "" then
					filename = "[No Name]"
				end
				local suffix = ""
				if vim.bo.modified then
					suffix = vim.fn.nr2char(0xf03eb) .. " " -- 󰏫 modified icon
				elseif vim.bo.readonly then
					suffix = vim.fn.nr2char(0xf03ee) .. " " -- 󰏮 readonly icon
				end
				return " " .. filename .. " " .. suffix
			end,
			hl = function(self)
				if vim.bo.modified then
					return { fg = "yellow", bold = true }
				elseif vim.bo.readonly then
					return { fg = "red", bold = true }
				else
					return { fg = "fg", bold = true }
				end
			end,
		}

		local GitDiff = {
			condition = function()
				return vim.b.gitsigns_status_dict ~= nil
			end,
			init = function(self)
				self.status_dict = vim.b.gitsigns_status_dict
				self.icon_added = vim.fn.nr2char(0xf457) --
				self.icon_modified = vim.fn.nr2char(0xf0764) -- 󰝤
				self.icon_removed = vim.fn.nr2char(0xf068) --  (minus icon, more standard)
			end,
			{
				provider = function(self)
					local has_changes = (self.status_dict.added or 0) > 0
						or (self.status_dict.changed or 0) > 0
						or (self.status_dict.removed or 0) > 0
					return has_changes and " " or ""
				end,
			},
			{
				provider = function(self)
					local count = self.status_dict.added or 0
					return count > 0 and (self.icon_added .. " " .. count .. " ") or ""
				end,
				hl = { fg = "green" },
			},
			{
				provider = function(self)
					local count = self.status_dict.changed or 0
					return count > 0 and (self.icon_modified .. " " .. count .. " ") or ""
				end,
				hl = { fg = "orange" },
			},
			{
				provider = function(self)
					local count = self.status_dict.removed or 0
					return count > 0 and (self.icon_removed .. " " .. count .. " ") or ""
				end,
				hl = { fg = "red" },
			},
		}

		local Diagnostics = {
			condition = conditions.has_diagnostics,
			init = function(self)
				local count = vim.diagnostic.count(0)
				self.errors = count[vim.diagnostic.severity.ERROR] or 0
				self.warnings = count[vim.diagnostic.severity.WARN] or 0
				self.info = count[vim.diagnostic.severity.INFO] or 0
				self.hints = count[vim.diagnostic.severity.HINT] or 0
			end,
			{
				provider = " ",
			},
			{
				provider = function(self)
					local total_hints = self.hints + self.info
					return total_hints > 0 and (vim.fn.nr2char(0xf0eb) .. " " .. total_hints .. " ") or ""
				end,
				hl = { fg = "cyan" },
			},
			{
				provider = function(self)
					return self.warnings > 0 and (vim.fn.nr2char(0xf071) .. " " .. self.warnings .. " ") or ""
				end,
				hl = { fg = "yellow" },
			},
			{
				provider = function(self)
					return self.errors > 0 and (vim.fn.nr2char(0xf46e) .. " " .. self.errors .. " ") or ""
				end,
				hl = { fg = "red" },
			},
			update = { "DiagnosticChanged", "BufEnter" },
		}

		local Grapple = {
			condition = function()
				local ok, grapple = pcall(require, "grapple")
				if not ok or not grapple.statusline then
					return false
				end
				return grapple.statusline() ~= ""
			end,
			provider = function()
				return " " .. require("grapple").statusline()
			end,
			hl = { fg = "cyan" },
		}

		-- gm.nvim exposes no statusline API, so read gm.store directly.
		-- heirline runs `condition` and `provider` on every redraw, so the read
		-- and the rendered string are cached and refreshed from autocmds plus the
		-- User GmChanged event.
		local gm_icon = vim.fn.nr2char(0xf02e) -- 
		local gm_marks = {}
		local gm_rendered = ""

		---@return { key: string, path: string, row: integer? }[]?, string?
		local function gm_read()
			local ok, store = pcall(require, "gm.store")
			if not ok then
				return nil, "module unavailable"
			end
			local marks, err = store.get_all()
			if err then
				return nil, err
			end
			local built = {}
			for key, mark in pairs(marks) do
				built[#built + 1] = {
					key = key,
					path = store.to_absolute(mark.path),
					row = mark.cursor_position and mark.cursor_position.row,
				}
			end
			table.sort(built, function(a, b)
				return a.key < b.key
			end)
			return built, nil
		end

		local function gm_render(marks, current)
			if #marks == 0 then
				return ""
			end
			local out = {}
			for _, mark in ipairs(marks) do
				local label = mark.key .. " → " .. vim.fn.fnamemodify(mark.path, ":.")
				if mark.row then
					label = label .. ":" .. mark.row
				end
				out[#out + 1] = string.format(mark.path == current and "[%s]" or " %s ", label)
			end
			return " " .. gm_icon .. " " .. table.concat(out)
		end

		local function gm_refresh()
			local marks, err = gm_read()
			if marks then
				gm_marks = marks
			else
				-- A failed read must not silently degrade to "no marks".
				vim.notify_once("gm.store: " .. tostring(err), vim.log.levels.WARN)
			end
			local current = vim.api.nvim_buf_get_name(0)
			gm_rendered = gm_render(gm_marks, current ~= "" and vim.fs.normalize(current) or nil)
		end

		gm_refresh()
		-- BufEnter carries the store re-read because gm.nvim rewrites gm.txt on
		-- every BufLeave (cursor persistence) and its gm.txt float saves via
		-- BufWriteCmd, so no event reliably signals "marks changed".
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "DirChanged" }, {
			callback = gm_refresh,
		})
		vim.api.nvim_create_autocmd("User", {
			pattern = "GmChanged",
			callback = gm_refresh,
		})

		local Gm = {
			condition = function()
				return not is_ignored() and gm_rendered ~= ""
			end,
			provider = function()
				return gm_rendered
			end,
			hl = { fg = "cyan" },
		}

		-- Set by the furnace launcher before nvim starts, so the label never changes.
		local furnace_ctx = vim.env.FURNACE_CONTEXT_NAME
		if furnace_ctx == "" then
			furnace_ctx = nil
		end
		local furnace_label = furnace_ctx and (" " .. vim.fn.nr2char(0xf0e7) .. " " .. furnace_ctx .. " ") --  bolt

		local FurnaceContext = {
			condition = function()
				return furnace_ctx ~= nil
			end,
			provider = furnace_label,
			hl = { fg = "orange", bold = true },
		}

		local jj_icon = " " .. vim.fn.nr2char(0xf062c) -- 󰘬 jujutsu icon

		---@param output string
		---@return string
		local function format_jj_label(output)
			local newline = output:find("\n", 1, true)
			local bookmark = newline and output:sub(1, newline - 1) or output
			local description = newline and output:sub(newline + 1) or ""

			bookmark = bookmark:gsub("^%s+", ""):gsub("%s+$", "")
			if bookmark == "(no bookmarks set)" or bookmark == "" then
				bookmark = nil
			end
			description = description:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

			local text = jj_icon
			if bookmark then
				text = text .. " " .. bookmark
			end
			if description ~= "" then
				local max_desc_len = bookmark and 20 or 30
				if #description > max_desc_len then
					description = description:sub(1, max_desc_len - 3) .. "..."
				end
				text = text .. (bookmark and ": " or " ") .. description
			elseif not bookmark then
				text = text .. " (new change)"
			end
			return text .. " "
		end

		---@alias VersionControlState "idle"|"refreshing"|"ready"|"no_repository"|"error"
		---@class VersionControlCache
		---@field generation integer
		---@field state VersionControlState
		---@field refreshed_at number
		---@field text string
		---@field has_jj boolean
		---@field root string?

		---@type table<string, VersionControlCache>
		local version_control_cache = {}
		---@type table<string, string>
		local last_good_by_root = {}

		local function redraw_status()
			vim.schedule(function()
				vim.cmd("redrawstatus")
			end)
		end

		---@param message string
		local function report_jj_error(message)
			vim.schedule(function()
				vim.notify("jj statusline: " .. message, vim.log.levels.WARN)
			end)
		end

		---@param cwd string
		---@param args string[]
		---@param callback fun(result: vim.SystemCompleted)
		---@return boolean started
		---@return boolean unavailable
		local function run_jj(cwd, args, callback)
			local command = { "jj", "--ignore-working-copy", "--color", "never" }
			vim.list_extend(command, args)
			local ok, err = pcall(vim.system, command, { cwd = cwd, text = true }, callback)
			if not ok then
				local spawn_error = tostring(err):lower()
				if spawn_error:find("enoent", 1, true) or spawn_error:find("no such file or directory", 1, true) then
					return false, true
				end
				report_jj_error(tostring(err))
				return false, false
			end
			return true, false
		end

		---@param cwd string
		---@param entry VersionControlCache
		local function refresh_version_control(cwd, entry)
			entry.generation = entry.generation + 1
			local generation = entry.generation
			entry.state = "refreshing"

			local started, unavailable = run_jj(cwd, { "root" }, function(root_result)
				if version_control_cache[cwd] ~= entry or entry.generation ~= generation then
					return
				end
				local stderr = root_result.stderr or ""
				if root_result.code ~= 0 then
					local no_repository = root_result.code == 127
						or stderr:lower():find("no jj repo", 1, true)
						or stderr:lower():find("not a jj repo", 1, true)
						or stderr:lower():find("there is no jj repo", 1, true)
					entry.state = no_repository and "no_repository" or "error"
					entry.refreshed_at = (vim.uv and vim.uv.now() or vim.loop.now())
					if no_repository then
						entry.has_jj = false
						entry.text = ""
					else
						entry.has_jj = entry.root ~= nil
						entry.text = (entry.root and last_good_by_root[entry.root]) or entry.text
						report_jj_error(stderr ~= "" and stderr or ("root exited " .. root_result.code))
					end
					redraw_status()
					return
				end

				local root = (root_result.stdout or ""):gsub("%s+$", "")
				entry.root = root
				entry.has_jj = true
				entry.text = last_good_by_root[root] or jj_icon .. " "
				local log_started = run_jj(cwd, {
					"log",
					"-r",
					"@",
					"--no-graph",
					"--template",
					'concat(bookmarks, "\\n", description.first_line())',
				}, function(log_result)
					if version_control_cache[cwd] ~= entry or entry.generation ~= generation then
						return
					end
					entry.refreshed_at = (vim.uv and vim.uv.now() or vim.loop.now())
					if log_result.code == 0 then
						entry.text = format_jj_label(log_result.stdout or "")
						last_good_by_root[root] = entry.text
						entry.state = "ready"
					else
						entry.text = last_good_by_root[root] or entry.text
						entry.state = "error"
						report_jj_error((log_result.stderr ~= "" and log_result.stderr) or ("log exited " .. log_result.code))
					end
					redraw_status()
				end)
				if not log_started then
					entry.state = "error"
					entry.refreshed_at = (vim.uv and vim.uv.now() or vim.loop.now())
					redraw_status()
				end
			end)

			if not started then
				entry.state = unavailable and "no_repository" or "error"
				entry.refreshed_at = (vim.uv and vim.uv.now() or vim.loop.now())
				if unavailable then
					entry.has_jj = false
					entry.text = ""
				else
					entry.has_jj = entry.root ~= nil
					entry.text = (entry.root and last_good_by_root[entry.root]) or entry.text
				end
			end
		end

		local VersionControl = {
			init = function(self)
				local cwd = vim.uv.cwd()
				local now = vim.uv and vim.uv.now() or vim.loop.now()
				local entry = version_control_cache[cwd]
				if not entry then
					entry = { generation = 0, state = "idle", refreshed_at = 0, text = "", has_jj = false }
					version_control_cache[cwd] = entry
				end
				if entry.state ~= "refreshing" and (entry.state == "idle" or (now - entry.refreshed_at) > 5000) then
					refresh_version_control(cwd, entry)
				end
				self.has_jj = entry.has_jj
				self.text = entry.text
			end,
			provider = function(self)
				if self.has_jj then
					return self.text
				else
					local signs = vim.b.gitsigns_status_dict
					if signs and signs.head then
						return " " .. vim.fn.nr2char(0xf1d3) .. " " .. signs.head .. " " --  git branch icon
					end
					return ""
				end
			end,
			hl = { fg = "violet", bold = true },
		}

		local mode_colors_map = {
			n = "blue",
			i = "green",
			v = "red",
			["\22"] = "red", -- Visual block
			V = "red",
			c = "magenta",
			no = "red",
			s = "orange",
			S = "orange",
			["\19"] = "orange",
			ic = "yellow",
			R = "violet",
			hl = function()
				local mode = vim.fn.mode()
				local color = mode_colors_map[mode] or "blue"
				return { fg = color, bg = "NONE" }
			end,
			update = {
				"ModeChanged",
				"WinResized",
			},
		}

		local Align = { provider = "%=" }

		local StatusLine = {
			condition = function()
				return not is_ignored()
			end,
			static = {
				mode_colors = mode_colors_map,
			},
			-- Mode indicator (simple colored block at the beginning)
			{
				provider = "█ ", -- Solid block with space
				hl = function()
					local mode = vim.fn.mode()
					local color = mode_colors_map[mode] or "blue"
					return { fg = color }
				end,
				update = "ModeChanged",
			},
			-- Main statusline content
			FileIcon,
			FileName,
			GitDiff,
			Macro,
			DebugMode,
			Align,
			Diagnostics,
			Grapple,
			FurnaceContext,
			VersionControl,
		}

		-- Statusline for ignored buffers
		local IgnoredStatusLine = {
			condition = function()
				return is_ignored()
			end,
			provider = "",
			hl = { bg = "NONE" },
		}

		-- Setup statusline with proper highlights
		heirline.setup({
			statusline = {
				IgnoredStatusLine,
				StatusLine,
			},
			winbar = Gm,
			opts = {
				colors = setup_colors(),
			},
		})

		-- Set statusline highlights to match your custom config
		vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE", fg = "NONE" })
		vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE", fg = "NONE" })

		-- Set the fillchars to customize the statusline appearance
		vim.opt.fillchars:append({
			stl = " ", -- Active statusline fill
			stlnc = " ", -- Inactive statusline fill
		})

		-- Set laststatus to always show statusline
		vim.opt.laststatus = 3 -- Global statusline
	end,
}
