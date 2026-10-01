return {
	"folke/lazydev.nvim",
	ft = "lua", -- only load on lua files
	opts = {
		library = {
			-- Plugin libraries are opt-in because LuaLS indexes each one.
			-- Add entries only when richer navigation is needed.
			"atlas.nvim",

			-- Load luvit types when the `vim.uv` word is found
			{
				path = "${3rd}/luv/library",
				words = {
					"vim%.uv",
				},
			},
		},
	},
}
