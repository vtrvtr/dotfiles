-- Plugin: FluxxField/smart-motion.nvim
-- Installed via store.nvim

return {
	"FluxxField/smart-motion.nvim",
	enabled = false,
	opts = {
		presets = {
			words = true, -- w, b, e, ge
			lines = true, -- j, k
			search = true, -- s, f, F, t, T, ;, ,, gsm
			delete = true, -- d, dt, dT, rdw, rdl
			yank = true, -- y, yt, yT, ryw, ryl
			change = true, -- c, ct, cT
			paste = true, -- p, P
			treesitter = true, -- ]], [[, ]c, [c, ]b, [b, daa, caa, yaa, dfn, cfn, yfn, saa
			diagnostics = true, -- ]d, [d, ]e, [git = true, -- ]g, [g
			quickfix = true, -- ]q, [q, ]l, [l
			marks = true, -- g', gmm
			misc = true, -- . (repeat), gmd, gmy
		},
	},
}
