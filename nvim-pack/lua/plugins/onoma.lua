return {
	"ryanmab/onoma.nvim",
	opts = {},
	enabled = true,
	sem_version = "*",
	version = vim.version.range("*"),
	build = function()
		-- onoma's download_bridge() is written for lazy.nvim, which runs build
		-- hooks inside a coroutine and consumes the progress it yields. zpack
		-- calls the hook on the main thread, so drive it in an explicit
		-- coroutine here to keep the yields legal.
		local co = coroutine.create(require("bridge.download").download_bridge)
		while true do
			local ok, msg = coroutine.resume(co)
			if not ok then
				error(msg)
			end
			if msg then
				vim.notify("[onoma] " .. tostring(msg), vim.log.levels.INFO)
			end
			if coroutine.status(co) == "dead" then
				break
			end
		end
	end,
	-- Lazy-load on the keymap: onoma.setup() synchronously indexes the whole
	-- cwd via a blocking resolver/watcher, which is very slow to run at startup
	-- in large trees. Deferring to first <leader>fs press pays that cost once,
	-- on demand, instead of on every nvim launch.
	keys = {
		{
			"<leader>fs",
			function()
				Snacks.picker.get_symbols()
			end,
			mode = { "n", "v", "x" },
			desc = "Symbols",
			silent = true,
		},
	},
	config = function()
		require("onoma").setup({
			-- Default configuration can be found in: "lua/config.lua"
			picker = { "snacks" },
		})
	end,
}
