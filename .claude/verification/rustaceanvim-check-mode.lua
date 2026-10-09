local spec = dofile("nvim-pack/lua/plugins/rustaceanvim.lua")
spec.config()

local settings = vim.g.rustaceanvim.server.settings["rust-analyzer"]
local check = settings.check

assert(settings.numThreads == nil, "rust-analyzer must choose its analysis worker count")
assert(settings.cachePriming == nil, "rust-analyzer must choose its cache-priming worker count")
assert(settings.checkOnSave == true, "Clippy must run on save")
assert(type(check) == "table", "rust-analyzer.check must use the current settings schema")
assert(check.command == "clippy", "the save-time check must run Clippy")
assert(check.allTargets == false, "background checks must not build every target")
assert(check.workspace == false, "background checks must remain package-scoped")
assert(vim.deep_equal(check.features, {}), "background Clippy must not enable every feature")
assert(vim.deep_equal(check.extraArgs, { "--no-deps" }), "Clippy must skip dependency linting")

local jobs = tonumber(check.extraEnv.CARGO_BUILD_JOBS)
assert(jobs and jobs >= 1 and jobs <= 4, "CARGO_BUILD_JOBS must stay between 1 and 4")

print("rust-analyzer uses automatic concurrency; save-time Clippy uses two Cargo jobs")
