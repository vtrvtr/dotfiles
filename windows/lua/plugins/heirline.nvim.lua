-- Plugin: rebelot/heirline.nvim
-- Installed via store.nvim

local function fallback_components()
	vim.g.heirline_using_fallback = true
	local conditions = require("heirline.conditions")
	local Space = { provider = " " }
	local Align = { provider = "%=" }

	local Mode = {
		provider = function()
			return (" %s "):format(vim.fn.mode():upper())
		end,
		hl = { bold = true },
	}

	local Git = {
		condition = conditions.is_git_repo,
		provider = function()
			local branch = vim.b.gitsigns_head
			if not branch or branch == "" then
				return "<No branch>"
			end
			return (" %s "):format(branch)
		end,
		hl = { fg = "cyan" },
	}

	local FileName = {
		provider = function()
			local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
			return name ~= "" and name or "[No Name]"
		end,
	}

	local Diagnostics = {
		condition = conditions.has_diagnostics,
		provider = function()
			local icons = { Error = " ", Warn = " ", Info = " ", Hint = " " }
			local counts = { 0, 0, 0, 0 }
			for _, diag in ipairs(vim.diagnostic.get(0)) do
				counts[diag.severity] = counts[diag.severity] + 1
			end
			local parts = {}
			for severity, icon in pairs(icons) do
				local num = counts[vim.diagnostic.severity[severity]] or 0
				if num > 0 then
					parts[#parts + 1] = icon .. num
				end
			end
			return table.concat(parts, " ")
		end,
		hl = { fg = "yellow" },
	}

	local Ruler = { provider = "%7(%l:%c%)" }

	return {
		statusline = { Mode, Space, Git, FileName, Space, Diagnostics, Align, Ruler },
	}
end

return {
	"rebelot/heirline.nvim",
	enabled = true,
	event = "VeryLazy",
	dependencies = {
		"Zeioth/heirline-components.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	opts = function()
		vim.g.heirline_using_fallback = false
		local ok, hpc = pcall(require, "heirline-components.all")
		if not ok or not hpc.component then
			return fallback_components()
		end

		local required = {
			"mode",
			"git_branch",
			"file_info",
			"git_diff",
			"diagnostics",
			"fill",
			"lsp",
			"nav",
			"separated_path",
			"breadcrumbs",
			"tabline_buffers",
			"tabline_tabpages",
		}
		for _, key in ipairs(required) do
			if type(hpc.component[key]) ~= "function" then
				return fallback_components()
			end
		end

		local colors = require("heirline-components.core.hl").get_colors()
		local utils = require("heirline.utils")

		local function bubble(component, color)
			return utils.surround({ "", "" }, color or colors.section_bg, component)
		end

		-- align colors with catppuccin if available
		local ok_catppuccin, catppuccin_palettes = pcall(require, "catppuccin.palettes")
		if ok_catppuccin and type(catppuccin_palettes) == "table" then
			local p = catppuccin_palettes.get_palette("mocha")
			colors.bg = p.mantle
			colors.fg = p.text
			colors.section_bg = p.surface0
			colors.section_fg = p.text
			colors.git_branch_bg = p.surface1
			colors.git_diff_bg = p.surface1
			colors.diagnostics_bg = p.surface1
			colors.file_info_bg = p.surface0
			colors.lsp_bg = p.surface1
			colors.nav_bg = p.surface1
			colors.buffer_picker_fg = p.peach
			colors.winbar_bg = p.mantle
			colors.winbar_fg = p.subtext1
		end

		return {
			opts = {
				colors = colors,
				disable_winbar_cb = function(args)
					return not require("heirline-components.core.condition").has_filetype(args)
				end,
			},
			statusline = {
				-- bubble(hpc.component.mode({ mode_text = { padding = { left = 1, right = 1 } } }), colors.mode_bg),
				-- hpc.component.fill(),
				-- hpc.component.fill(),
				-- bubble(hpc.component.git_branch(), colors.git_branch_bg),
				-- hpc.component.fill(),
				-- bubble(hpc.component.git_diff(), colors.git_diff_bg),
				-- hpc.component.fill(),
				-- bubble(hpc.component.diagnostics(), colors.diagnostics_bg),
				-- hpc.component.fill(),
				-- bubble({
				-- 	provider = function()
				-- 		local ok, status = pcall(require, "grapple")
				-- 		if not ok or not status.statusline then
				-- 			return "[]"
				-- 		end
				-- 		local val = status.statusline()
				-- 		if not val or val == "" then
				-- 			return "[]"
				-- 		end
				-- 		return val
				-- 	end,
				-- 	hl = { fg = colors.bg, bg = colors.buffer_picker_fg },
				-- }, colors.buffer_picker_fg),
				-- hpc.component.fill(),
				-- bubble(hpc.component.lsp(), colors.lsp_bg),
				-- hpc.component.fill(),
				-- bubble(hpc.component.nav(), colors.nav_bg),
			},
			winbar = {
				bubble(hpc.component.separated_path(), colors.winbar_bg),
				bubble(hpc.component.breadcrumbs({ padding = { left = 0, right = 3 } }), colors.winbar_bg),
			},
			tabline = {
				hpc.component.tabline_buffers({ filetypes = { "neo-tree" } }),
				hpc.component.fill(),
				hpc.component.tabline_tabpages(),
			},
		}
	end,
}
