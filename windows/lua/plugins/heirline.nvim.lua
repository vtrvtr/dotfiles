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
				local status = grapple.statusline and grapple.statusline() or ""
				return status ~= ""
			end,
			provider = function()
				local grapple = require("grapple")
				return " " .. grapple.statusline()
			end,
			hl = { fg = "cyan" },
		}

		local VersionControl = {
			init = function(self)
				local now = vim.uv and vim.uv.now() or vim.loop.now()

				-- Cache for 5 seconds
				if not self._cache or (now - self._cache.time) > 5000 then
					local text = ""
					local has_jj = false

					local jj_check = io.popen("jj root 2>/dev/null")
					if jj_check then
						local jj_root = jj_check:read("*a")
						jj_check:close()

						if jj_root and jj_root ~= "" then
							has_jj = true
							text = " " .. vim.fn.nr2char(0xf062c) -- 󰘬 jujutsu icon

							local handle = io.popen(
								"jj log -r @ --no-graph --template 'concat(bookmarks, \"\\n\", description.first_line())' 2>/dev/null"
							)
							if handle then
								local output = handle:read("*a")
								handle:close()
								if output and output ~= "" then
									local lines = {}
									for line in output:gmatch("[^\n]+") do
										table.insert(lines, line)
									end

									local bookmark = lines[1] or ""
									local description = lines[2] or ""

									bookmark = bookmark:gsub("^%s+", ""):gsub("%s+$", "")
									if bookmark == "(no bookmarks set)" or bookmark == "" then
										bookmark = nil
									end

									description = description:gsub("^%s+", ""):gsub("%s+$", "")

									if bookmark then
										text = text .. " " .. bookmark
									end
									if description ~= "" then
										local max_desc_len = bookmark and 20 or 30
										if #description > max_desc_len then
											description = description:sub(1, max_desc_len - 3) .. "..."
										end

										if bookmark then
											text = text .. ": " .. description
										else
											text = text .. " " .. description
										end
									elseif not bookmark then
										text = text .. " (new change)"
									end
								end
							end
							text = text .. " "
						end
					end

					self._cache = {
						time = now,
						text = text,
						has_jj = has_jj,
					}
				end

				self.has_jj = self._cache.has_jj
				self.text = self._cache.text
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
			Rv = "violet",
			cv = "red",
			ce = "red",
			r = "cyan",
			rm = "cyan",
			["r?"] = "cyan",
			["!"] = "red",
			t = "red",
		}

		-- Mode indicator line (simulating the border)
		local ModeIndicator = {
			provider = "▔",
			hl = function()
				local mode = vim.fn.mode()
				local color = mode_colors_map[mode] or "blue"
				return { fg = color, bg = "NONE" }
			end,
			update = "ModeChanged",
		}

		-- Fill/Align component
		local Align = { provider = "%=" }

		-- Mode-colored full-width separator
		local ModeSeparator = {
			provider = function()
				-- Use a repeating pattern to create a visual separator
				local width = vim.api.nvim_win_get_width(0) - 2
				return string.rep("─", width)
			end,
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

		-- Complete statusline
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
			Align,
			Diagnostics,
			Grapple,
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
