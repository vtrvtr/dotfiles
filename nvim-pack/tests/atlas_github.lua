local atlas_path = vim.env.ATLAS_NVIM_PATH or (vim.fn.stdpath("data") .. "/site/pack/core/opt/atlas.nvim")
assert(vim.fn.isdirectory(atlas_path) == 1, "Set ATLAS_NVIM_PATH to an installed atlas.nvim checkout")
vim.opt.runtimepath:append(atlas_path)
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local cache_dir = vim.fn.tempname()
vim.env.XDG_CACHE_HOME = cache_dir

---@class PendingGhRequest
---@field host string
---@field variables table<string, string>
---@field on_exit fun(result: vim.SystemCompleted)
---@field cancelled boolean

---@type PendingGhRequest[]
local requests = {}
vim.system = function(cmd, opts, on_exit)
	assert(cmd[1] == "gh", "Unexpected process: " .. cmd[1])
	local variables = {}
	local host = (opts.env or {}).GH_HOST or "github.com"
	for index, arg in ipairs(cmd) do
		local key, value = arg:match("^(%w+)=(.*)$")
		if key then
			variables[key] = value
		end
		if arg == "--hostname" then
			host = cmd[index + 1]
		elseif arg:match("^--hostname=") then
			host = arg:sub(#"--hostname=" + 1)
		end
	end
	local request = {
		host = host,
		variables = variables,
		on_exit = on_exit,
		cancelled = false,
	}
	table.insert(requests, request)
	return {
		pid = 1,
		kill = function()
			request.cancelled = true
		end,
	}
end

local spec = dofile(root .. "/lua/plugins/atlas.lua")
spec.config(nil, spec.opts)
local api = require("atlas.pulls.providers.github.api.pullrequests")
local provider = require("atlas.pulls.providers.github")
local query = "is:pr author:@me sort:updated-desc is:open"

---@param actual any
---@param expected any
local function equal(actual, expected)
	assert(vim.deep_equal(actual, expected), vim.inspect(actual) .. " ~= " .. vim.inspect(expected))
end

---@param host string
---@return PendingGhRequest
local function request_for(host)
	local matches = vim.tbl_filter(function(request)
		return request.host == host
	end, requests)
	assert(#matches == 1, string.format("Expected one request to %s, got %d", host, #matches))
	return matches[1]
end

---@param request PendingGhRequest
---@param numbers integer[]
---@param cursor string|nil
local function respond(request, numbers, cursor)
	local searches = {}
	for index = 1, 3 do
		if request.variables["include" .. index] == "true" then
			searches["search" .. index] = {
				issueCount = 4,
				nodes = vim.tbl_map(function(number)
					local repo = request.host == "github.com" and "personal/demo" or "nas/demo"
					return {
						id = request.host .. ":pr:" .. number,
						number = number,
						updatedAt = string.format("2026-01-%02dT00:00:00Z", number),
						url = "https://" .. request.host .. "/" .. repo .. "/pull/" .. number,
						repository = { nameWithOwner = repo, name = "demo" },
					}
				end, numbers),
				pageInfo = { hasNextPage = cursor ~= nil, endCursor = cursor },
			}
		end
	end
	request.on_exit({ code = 0, signal = 0, stdout = vim.json.encode({ data = searches }), stderr = "" })
end

local function run()
	local first, failure
	provider.capabilities.core.fetch_pullrequests({ search = query }, { pagelen = 2 }, function(page, errors)
		first, failure = page, errors
	end)
	equal(#requests, 2)
	local public = request_for("github.com")
	local enterprise = request_for("netflix.ghe.com")
	equal(public.variables.query1, query)
	equal(enterprise.variables.query1, query .. " org:nas")
	respond(enterprise, { 4, 2 }, "enterprise-next")
	respond(public, { 3, 1 })
	assert(
		vim.wait(1000, function()
			return first ~= nil
		end),
		"First page timed out"
	)
	equal(failure, nil)
	equal(
		vim.tbl_map(function(pr)
			return pr.id
		end, first.items),
		{ "4", "3", "2", "1" }
	)

	requests = {}
	local second
	provider.capabilities.core.fetch_pullrequests(
		{ search = query },
		{ pagelen = 2, cursor = first.next_cursor },
		function(page, errors)
			second, failure = page, errors
		end
	)
	equal(#requests, 1)
	enterprise = request_for("netflix.ghe.com")
	equal(enterprise.variables.after1, "enterprise-next")
	respond(enterprise, { 6, 5 })
	assert(
		vim.wait(1000, function()
			return second ~= nil
		end),
		"Second page timed out"
	)
	equal(failure, nil)
	equal(#second.items, 2)
	equal(second.next_cursor, nil)

	requests = {}
	local cached
	api.fetch_search({ query }, { pagelen = 2 }, function(page, errors)
		cached, failure = page, errors
	end)
	equal(#requests, 0)
	equal(cached, first)
	equal(failure, nil)

	---@class ApprovalCase
	---@field pr GitHubPullRequest
	---@field review PullsReview
	---@field host AtlasGhHost
	---@field mutation "addPullRequestReview"|"submitPullRequestReview"

	---@type ApprovalCase[]
	local approvals = {
		{
			pr = first.items[1],
			review = { pending = false },
			host = "netflix.ghe.com",
			mutation = "addPullRequestReview",
		},
		{
			pr = first.items[1],
			review = { pending = true, id = "pending-review" },
			host = "netflix.ghe.com",
			mutation = "submitPullRequestReview",
		},
		{ pr = first.items[2], review = { pending = false }, host = "github.com", mutation = "addPullRequestReview" },
	}
	for _, case in ipairs(approvals) do
		requests = {}
		local approved, review_error
		provider.capabilities.reviews.approve(case.pr, case.review, "", function(ok, err)
			approved, review_error = ok, err
		end)
		local request = request_for(case.host)
		equal(request.variables.event, "APPROVE")
		equal(request.variables.pullRequestId or request.variables.reviewId, case.review.id or case.pr.node_id)
		request.on_exit({
			code = 0,
			signal = 0,
			stderr = "",
			stdout = vim.json.encode({
				data = { [case.mutation] = { pullRequestReview = { id = "submitted-review", state = "APPROVED" } } },
			}),
		})
		assert(
			vim.wait(1000, function()
				return approved ~= nil
			end),
			"Approval timed out"
		)
		equal(approved, true)
		equal(review_error, nil)
	end

	requests = {}
	local details_done = false
	api.get_pr("nas", "demo", 4, function(_, err)
		equal(err, "offline")
		details_done = true
	end)
	enterprise = request_for("netflix.ghe.com")
	enterprise.on_exit({ code = 1, signal = 0, stdout = "", stderr = "offline" })
	assert(
		vim.wait(1000, function()
			return details_done
		end),
		"Details timed out"
	)

	requests = {}
	local partial
	api.fetch_search({ query }, { pagelen = 2, force_refresh = true }, function(page, errors)
		partial, failure = page, errors
	end)
	equal(#requests, 2)
	request_for("github.com").on_exit({ code = 1, signal = 0, stdout = "", stderr = "offline" })
	respond(request_for("netflix.ghe.com"), { 7 })
	assert(
		vim.wait(1000, function()
			return partial ~= nil
		end),
		"Partial page timed out"
	)
	equal(#partial.items, 1)
	equal(failure, { "github.com: offline" })

	requests = {}
	local completed = false
	local scope = api.fetch_search({ query, "review-requested:@me" }, { pagelen = 2, force_refresh = true }, function()
		completed = true
	end)
	equal(#requests, 2)
	equal(request_for("netflix.ghe.com").variables.query2, "review-requested:@me org:nas")
	scope.cancel()
	for _, request in ipairs(requests) do
		assert(request.cancelled, "Cancellation did not reach every host")
		respond(request, { 8 })
	end
	assert(not vim.wait(50, function()
		return completed
	end), "Cancelled search invoked its callback")
	print("Atlas GitHub regression checks passed")
end

local ok, err = xpcall(run, debug.traceback)
vim.fn.delete(cache_dir, "rf")
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd("cquit 1")
end
vim.cmd("qa!")
