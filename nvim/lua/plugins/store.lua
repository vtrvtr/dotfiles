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
		-- Get the real absolute path dynamically
		local info = debug.getinfo(1, "S")
		local current_file = info.source:sub(2) -- Remove @ prefix
		local absolute_file = vim.fn.fnamemodify(current_file, ":p") -- Get absolute path
		local resolved_file = vim.fn.resolve(absolute_file) -- Resolve symlinks
		local plugins_dir = vim.fn.fnamemodify(resolved_file, ":h") -- Get directory

		-- Hook into Store command to disable/enable blink.pairs
		local original_store_open = store.open
		store.open = function(...)
			-- Disable blink.pairs when Store opens
			local ok, blink_pairs = pcall(require, "blink.pairs.mappings")
			if ok then
				blink_pairs.disable()
			end
			return original_store_open(...)
		end

		-- Create an autocmd to re-enable blink.pairs when Store buffer is closed
		vim.api.nvim_create_autocmd("BufUnload", {
			pattern = "Store",
			callback = function()
				local ok, blink_pairs = pcall(require, "blink.pairs.mappings")
				if ok then
					blink_pairs.enable()
				end
			end,
		})

		local err = store.setup({
			plugins_folder = plugins_dir,
		})
		if err then
			vim.notify(err, vim.log.levels.ERROR)
			vim.api.nvim_create_user_command("Store", function()
				vim.notify(err, vim.log.levels.ERROR)
			end, { force = true })
		end
	end,
}
