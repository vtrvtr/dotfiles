return {
	"alex-popov-tech/store.nvim",
	dependencies = { "OXY2DEV/markview.nvim" },
	cmd = "Store",
	opts = {},
	config = function(_, opts)
		local MIN_WIDTH, MIN_HEIGHT = 85, 18
		local cols, lines = vim.o.columns, vim.o.lines
		if cols < MIN_WIDTH or lines < MIN_HEIGHT then
			vim.notify(
				string.format("Store needs at least %dx%d (you have %dx%d)", MIN_WIDTH, MIN_HEIGHT, cols, lines),
				vim.log.levels.WARN
			)
			vim.api.nvim_create_user_command("Store", function()
				vim.notify(
					string.format("Resize to at least %dx%d columns/lines to open Store", MIN_WIDTH, MIN_HEIGHT),
					vim.log.levels.WARN
				)
			end, { force = true })
			return
		end
		local store = require("store")

		-- zpack's directory walk strips only the trailing ".lua" and `require`s what
		-- remains, so any other dot in the stem reads as a path separator:
		-- "atlas.nvim.lua" becomes require("plugins.atlas.nvim"), which resolves to
		-- plugins/atlas/nvim.lua and never loads. Store names install files after the
		-- repo, and most Neovim repos end in ".nvim", so untouched installs fail.
		-- Dropping the ".nvim" suffix matches how the rest of lua/plugins/ is named,
		-- but it can alias onto an unrelated existing spec (mini.nvim -> mini.lua,
		-- which already configures mini modules). Store writes with "w", so an alias
		-- would silently destroy that file; fall back to the dashed full stem then.
		---@param stem string Filename without its ".lua" extension
		---@param taken fun(candidate: string): boolean True when candidate is another spec
		---@return string stem containing no dots
		local function dotless_stem(stem, taken)
			local short = stem:match("^(.+)%.n?vim$")
			if short and not taken(short) then
				return (short:gsub("%.", "-"))
			end
			return (stem:gsub("%.", "-"))
		end

		-- Store names the install buffer after the target file and reads the save
		-- path back out of line 1 on :w, so both have to be rewritten. BufFilePost
		-- lands before line 1 is populated, hence the scheduled fixup.
		vim.api.nvim_create_autocmd("BufFilePost", {
			group = vim.api.nvim_create_augroup("StoreZpackSpecName", { clear = true }),
			pattern = "*.lua",
			callback = function(args)
				if vim.bo[args.buf].buftype ~= "acwrite" then
					return
				end

				local path = vim.api.nvim_buf_get_name(args.buf)
				local stem = vim.fn.fnamemodify(path, ":t:r")
				if not stem:find("%.") then
					return
				end

				local dir = vim.fn.fnamemodify(path, ":h")
				local fixed = dotless_stem(stem, function(candidate)
					return vim.uv.fs_stat(("%s/%s.lua"):format(dir, candidate)) ~= nil
				end)
				local new_path = ("%s/%s.lua"):format(dir, fixed)

				vim.schedule(function()
					if not vim.api.nvim_buf_is_valid(args.buf) then
						return
					end
					local first = vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)[1]
					if not (first and first:match("^%-%- Save path: ")) then
						return
					end
					vim.api.nvim_buf_set_lines(args.buf, 0, 1, false, { "-- Save path: " .. new_path })
					-- Renaming fails when another buffer already holds new_path, e.g. the
					-- target spec is open for editing. The save still lands on the right
					-- file because line 1 is what BufWriteCmd reads, so report the stale
					-- buffer name rather than letting the two silently disagree.
					local renamed, rename_err = pcall(vim.api.nvim_buf_set_name, args.buf, new_path)
					if not renamed then
						vim.notify(
							("store.nvim: install buffer still named %s, saves go to %s: %s")
								:format(vim.fn.fnamemodify(path, ":t"), new_path, rename_err),
							vim.log.levels.WARN
						)
					end
					vim.bo[args.buf].modified = false
				end)
			end,
		})

		-- Get the real absolute path dynamically
		local info = debug.getinfo(1, "S")
		local current_file = info.source:sub(2) -- Remove @ prefix
		local absolute_file = vim.fn.fnamemodify(current_file, ":p") -- Get absolute path
		local resolved_file = vim.fn.resolve(absolute_file) -- Resolve symlinks
		local plugins_dir = vim.fn.fnamemodify(resolved_file, ":h") -- Get directory

		-- zpack drives vim.pack underneath, so vim.pack.get() is the accurate
		-- source for "is it installed", but the spec files it imports are
		-- lazy.nvim-shaped. Point the vim.pack slot at the lazy catalogue.
		local err = store.setup({
			plugins_folder = plugins_dir,
			plugin_manager = "vim.pack",
			install_catalogue_urls = {
				["vim.pack"] = "https://github.com/alex-popov-tech/store.nvim.crawler/releases/latest/download/lazy_db_minified.json",
			},
		})
		if err then
			vim.notify(err, vim.log.levels.ERROR)
			vim.api.nvim_create_user_command("Store", function()
				vim.notify(err, vim.log.levels.ERROR)
			end, { force = true })
		end
	end,
}
