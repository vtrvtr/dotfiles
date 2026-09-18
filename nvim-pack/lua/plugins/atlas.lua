-- Board parity: filter 11836 backs Jira board 562 "All Pipe" and already drops
-- Closed/Cancelled/Resolved/Done plus on-hold items with a future due date.
-- Referencing it keeps these views in sync when the board owners retune it.
local PIPE_BOARD = "filter = 11836"

-- Board 562 column groupings, by status.
local BACKLOG_COLUMNS = 'status in (Open, "More Info Needed", Backlog)'
local ACTIVE_COLUMNS =
	'status in (Ready, "To Do", "In Progress", "On Hold", "Code Review", "Pending Release", "Pending Feedback", "Pending Sign Off")'

---@param clause string
---@param order string
---@return string
local function board_jql(clause, order)
	return PIPE_BOARD .. " AND " .. clause .. " ORDER BY " .. order
end

-- Views read newest-first. `created`, not `updated`: an automation or field bump
-- would otherwise float an old ticket above genuinely new arrivals.
local BY_RECENT = "created DESC"
local BY_PRIORITY = "priority DESC, created DESC"
local BY_UPDATED = "updated DESC"

-- GitHub search. Every view wants open PRs, no archived repos, and most recent
-- activity first, so all three live in the helper rather than per query.
---@param clause string
---@return string
local function gh_search(clause)
	local qualifier = clause ~= "" and " " .. clause or ""
	return string.format("is:pr is:open archived:false%s sort:updated-desc", qualifier)
end

local MINE = "author:@me"

-- "Somebody responded" has no direct qualifier: GitHub exposes no "commented
-- since I last looked". `-review:none` is the closest true signal, matching PRs
-- carrying a review of any state (approved, changes requested, or commented) and
-- excluding the ones nobody has touched. Note `review:changes_requested,approved`
-- looks equivalent but silently matches nothing, since `review:` takes a single
-- value and rejects comma-OR lists.
local REVIEWED = "-review:none"
-- Neglect queues read oldest-first: the top row is the worst offender.
local BY_OLDEST = "created ASC"
local BY_STALEST = "updated ASC"

-- Jira exposes no lastComment field, so "time since last answer" falls back to
-- `updated`. A comment always bumps `updated`, so this yields no false positives,
-- but a field edit or automation bump can hide a genuinely unanswered ticket:
-- measured recall against real comment timestamps is 99% at 30d, 90% at 90d.
local ANSWERED = "numberOfComments > 0"
local UNANSWERED = "numberOfComments = 0"
local INVOLVED = "(commentedBy = currentUser() OR comment ~ currentUser())"

-- The Jira dashboard ships Assignee/Reporter but no Created/Updated columns
-- (upstream has them for GitHub only, and only in compact layout). The search
-- already requests both timestamps and the mapper exposes them on the issue, so
-- swapping Reporter for the two dates is purely a display change: mutate the
-- provider's display table in place, which is what the dashboard reads per render.
local function add_timestamp_columns()
	local displays = require("atlas.issues.ui.dashboard.providers")
	local icons = require("atlas.ui.shared.icons")
	local utils = require("atlas.ui.shared.utils")

	local jira = displays.get("jira")
	local values, highlights = jira.values, jira.highlights

	-- table_tree deepcopies opts.columns, so one shared list is safe to reuse.
	local COLUMNS = {
		{ key = "icon", name = "", can_grow = false, align = "center" },
		{ key = "name", name = "Issue" },
		{
			key = "assignee",
			name = string.format("%s Assignee", icons.general("user")),
			max_width = 22,
			can_grow = false,
		},
		{ key = "created", name = icons.general("created"), can_grow = false },
		{ key = "updated", name = icons.general("updated"), can_grow = false },
		{ key = "status", name = " Status", can_grow = false },
	}

	jira.columns = function()
		return COLUMNS
	end

	jira.values = function(issue, is_child, layout)
		local row = values(issue, is_child, layout)
		row.created = utils.relative_time(issue.created_at)
		row.updated = utils.relative_time(issue.updated_at)
		return row
	end

	jira.highlights = function(row, col, ctx)
		if col.key == "created" or col.key == "updated" then
			return { { start_col = 0, end_col = #ctx.padded, hl_group = "AtlasTextMuted" } }
		end
		return highlights(row, col, ctx)
	end
end

-- atlas 0.7.3 hardcodes `parsed.host ~= "github.com"` in the GitHub resolver, so
-- every enterprise remote resolves to nil and each command aborts with "Could not
-- resolve the origin repository". Earlier releases matched any host containing
-- "github". Resolve against a spoofed github.com host, then put the real host back
-- on the target: route_gh_to_remote_host below reads it to pick GH_HOST.
local function resolve_github_enterprise()
	local resolver = require("atlas.providers.github.resolve")
	local resolve = resolver.resolve
	local DEFAULT_HOST = "github.com"

	---@param host string
	---@return boolean
	local function is_enterprise(host)
		return host ~= DEFAULT_HOST and (host:find("github", 1, true) or host:find(".ghe.com", 1, true)) ~= nil
	end

	resolver.resolve = function(value, parsed)
		if parsed == nil or not is_enterprise(parsed.host) then
			return resolve(value, parsed)
		end
		local host = parsed.host
		local target, err = resolve(value, vim.tbl_extend("force", parsed, { host = DEFAULT_HOST }))
		if not target then
			return nil, err
		end
		target.host = host
		local default = "^https://" .. vim.pesc(DEFAULT_HOST)
		for _, key in ipairs({ "url", "repository_url" }) do
			if type(target[key]) == "string" then
				target[key] = target[key]:gsub(default, "https://" .. host)
			end
		end
		return target, nil
	end
end

local DEFAULT_GH_HOST = "github.com"

-- Keying on cwd is wrong here: atlas spawns gh without one, and the repo being
-- viewed need not be the repo nvim was started in. The slug travels in the
-- command itself, so learn each slug's host instead: from local remotes as atlas
-- resolves them, and from search results as they arrive.
local host_by_slug = {}

-- A dashboard search names no repo, so nothing in the command reveals its host.
-- search_github_hosts sets this immediately before spawning, and gh is spawned
-- synchronously inside the search call, so the value is always the right one.
local forced_gh_host = nil

-- atlas parses the remote's host but spawns a bare `gh`, passing the repo as an
-- unqualified `--repo owner/name`. An explicit --repo overrides gh's own remote
-- inference, so on a self-hosted forge every call hits github.com and fails with
-- "Could not resolve to a Repository". GH_HOST fixes both call shapes (`--repo`
-- and `api repos/<slug>`), where a host-qualified slug would break the latter.
-- gh reads it from the environment only, so this cannot live in git config.
local function route_gh_to_remote_host()
	local system = vim.system

	-- atlas points gh at a repo four different ways: positionally
	-- (`repo view <slug>`), by flag (`--repo <slug>`), inside an API path
	-- (`repos/<slug>/issues/1`), and split across GraphQL variables
	-- (`-f owner=x -f repo=y`). Rather than model each shape, look for any known
	-- slug anywhere in the command, reassembling the split pair as we go.
	---@param cmd string[]
	---@param known table<string, string>
	---@return string|nil host
	local function host_for_command(cmd, known)
		local owner, repo
		for _, arg in ipairs(cmd) do
			if type(arg) == "string" then
				if known[arg] then
					return known[arg]
				end
				local embedded = arg:match("repos/([^/]+/[^/?#]+)") or arg:match("repo:([^%s]+)")
				if embedded and known[embedded] then
					return known[embedded]
				end
				owner = arg:match("^owner=(.+)$") or owner
				repo = arg:match("^repo=(.+)$") or arg:match("^name=(.+)$") or repo
			end
		end
		if owner and repo then
			return known[owner .. "/" .. repo]
		end
		return nil
	end

	-- atlas resolves the remote through this one function for every repo it
	-- touches, which is where the slug -> host mapping becomes known.
	local git = require("atlas.core.git")
	local local_repository = git.local_repository
	git.local_repository = function(cwd)
		local info = local_repository(cwd)
		if info and info.repo_full_name and info.host and info.host ~= DEFAULT_GH_HOST then
			host_by_slug[info.repo_full_name] = info.host
		end
		return info
	end

	vim.system = function(cmd, opts, on_exit)
		if type(cmd) == "table" and cmd[1] == "gh" then
			local host = forced_gh_host or host_for_command(cmd, host_by_slug)
			if host then
				local given = opts or {}
				opts = vim.tbl_extend("force", given, {
					env = vim.tbl_extend("force", given.env or {}, { GH_HOST = host }),
				})
			end
		end
		return system(cmd, opts, on_exit)
	end
end

-- Every PR view funnels through search_prs, and atlas gives it one host, so work
-- PRs on netflix.ghe.com never appear. Run each search once per host and merge.
-- The enterprise half is scoped to org:nas, which also keeps the two halves on
-- distinct cache keys, since atlas derives the key from the query string.
local GH_HOSTS = {
	{ host = DEFAULT_GH_HOST },
	{ host = "netflix.ghe.com", scope = "org:nas" },
}

local function prompt_required_jira_fields()
	local issues_api = require("atlas.issues.providers.jira.api.issues")
	if issues_api.required_custom_fields_prompted then
		return
	end

	local create_issue = issues_api.create_issue
	local picker = require("atlas.ui.picker")
	local service = require("atlas.issues.providers.jira.api.service")

	---@param field table
	---@return string
	local function field_name(field)
		return tostring(field.name or field.fieldId or "Custom field")
	end

	---@param field table
	---@return { id: string, label: string, value: { id: string } }[]
	local function options(field)
		return vim.tbl_map(function(value)
			local id = tostring(value.id or "")
			return {
				id = id,
				label = tostring(value.value or value.name or id),
				value = { id = id },
			}
		end, vim.tbl_filter(function(value)
			return tostring(value.id or "") ~= ""
		end, field.allowedValues or {}))
	end

	---@param fields table[]
	---@param payload table
	---@param done fun(err: string|nil)
	local function prompt(fields, payload, done)
		local function next_field(index)
			local field = fields[index]
			if not field then
				done(nil)
				return
			end

			local id = tostring(field.fieldId or field.key or "")
			if id == "" or payload[id] ~= nil then
				next_field(index + 1)
				return
			end

			local schema = type(field.schema) == "table" and field.schema or {}
			local values = options(field)
			local name = field_name(field)
			if schema.type == "option" and #values > 0 then
				picker.select({
					title = "Select " .. name,
					items = values,
					format_item = function(item)
						return item.label
					end,
					on_select = function(item)
						if not item then
							done(name .. " is required")
							return
						end
						payload[id] = item.value
						next_field(index + 1)
					end,
				})
				return
			end
			if schema.type == "array" and schema.items == "option" and #values > 0 then
				picker.multi_select({
					title = "Select " .. name,
					items = values,
					selected = {},
					key = function(item)
						return item.id
					end,
					format_item = function(item)
						return item.label
					end,
					on_done = function(selected)
						if #selected == 0 then
							done(name .. " is required")
							return
						end
						payload[id] = vim.tbl_map(function(item)
							return item.value
						end, selected)
						next_field(index + 1)
					end,
				})
				return
			end
			done(string.format("Required Jira field %q has unsupported type %q", name, tostring(schema.type)))
		end

		next_field(1)
	end

	issues_api.create_issue = function(fields, callback)
		local project = tostring(((fields or {}).project or {}).key or "")
		local issue_type = tostring(((fields or {}).issuetype or {}).id or "")
		if project == "" or issue_type == "" then
			return create_issue(fields, callback)
		end

		return service.request(
			"GET",
			string.format("/issue/createmeta/%s/issuetypes/%s", project, issue_type),
			nil,
			function(result, err)
				if err then
					callback(nil, err)
					return
				end
				local required = vim.tbl_filter(function(field)
					return field.required == true and tostring(field.fieldId or field.key or ""):match("^customfield_") ~= nil
				end, result.fields or {})
				prompt(required, fields, function(prompt_err)
					if prompt_err then
						callback(nil, prompt_err)
						return
					end
					create_issue(fields, callback)
				end)
			end,
			{ action = "Fetch create fields", project_key = project, issue_type_id = issue_type }
		)
	end
	issues_api.required_custom_fields_prompted = true
end

local function search_github_hosts()
	local api = require("atlas.pulls.providers.github.api.pullrequests")
	local request_scope = require("atlas.core.requests")
	local search_prs = api.search_prs

	---@param pulls PullRequest[]
	---@param host string
	local function remember_hosts(pulls, host)
		if host == DEFAULT_GH_HOST then
			return
		end
		for _, pr in ipairs(pulls) do
			if pr.repo_full_name then
				host_by_slug[pr.repo_full_name] = host
			end
		end
	end

	---@param batches table<string, PullRequest[]>
	---@param limit integer
	---@return PullRequest[]
	local function merge(batches, limit)
		local pulls = {}
		for _, batch in pairs(batches) do
			vim.list_extend(pulls, batch or {})
		end
		-- Same sort atlas applies when it fans a view out over several queries.
		table.sort(pulls, function(left, right)
			if left.updated_on == right.updated_on then
				return tostring(left.link.html) < tostring(right.link.html)
			end
			return left.updated_on > right.updated_on
		end)
		while #pulls > limit do
			table.remove(pulls)
		end
		return pulls
	end

	api.search_prs = function(search, on_done, opts)
		local scope = request_scope.new()
		local starts = {}
		for _, target in ipairs(GH_HOSTS) do
			local host, query = target.host, search
			if target.scope then
				query = query .. " " .. target.scope
			end
			starts[host] = function(done)
				forced_gh_host = host
				local ok, handle = pcall(search_prs, query, function(pulls, errors)
					remember_hosts(pulls or {}, host)
					done(pulls or {}, errors and errors[1])
				end, opts)
				forced_gh_host = nil
				if not ok then
					error(handle)
				end
				return handle
			end
		end

		scope.all(starts, function(values, errors)
			local failures = {}
			for host, err in pairs(errors) do
				table.insert(failures, host .. ": " .. tostring(err))
			end
			-- A reachable host still has results worth showing, so a partial
			-- failure reports alongside them rather than replacing them.
			local limit = math.min(100, math.max(1, tonumber((opts or {}).limit) or 50))
			on_done(merge(values, limit), #failures > 0 and failures or nil)
		end)
		return scope
	end
end

-- jj leaves colocated repos on a detached git HEAD, so atlas.core.git's
-- `rev-parse --abbrev-ref HEAD` yields "HEAD" and every PR command aborts with
-- "Detached HEAD". Bookmarks in a colocated repo are real refs/heads/*, so only
-- detection is broken: resolve the name via jj and the existing git plumbing
-- (commit_range, push, ls-remote) keeps working untouched.
local function resolve_jj_bookmarks()
	local git = require("atlas.core.git")
	local detect_branch = git.current_branch

	---@param stdout string
	---@return string[] names Deduplicated and sorted, so the pick below is
	--- deterministic rather than dependent on jj's output order.
	local function parse_bookmark_names(stdout)
		local names, seen = {}, {}
		for line in tostring(stdout):gmatch("[^\r\n]+") do
			local name = line:match("^%s*(.-)%s*$")
			if name ~= "" and not seen[name] then
				seen[name] = true
				table.insert(names, name)
			end
		end
		table.sort(names)
		return names
	end

	---@param names string[]
	---@return string|nil branch, string|nil err
	local function pick_bookmark(names)
		if #names == 0 then
			return nil, "No jj bookmark on or before @ — run `jj bookmark create <name>` first"
		end
		if #names > 1 then
			-- Guessing risks opening a PR from the wrong head.
			return nil,
				string.format(
					"Ambiguous jj bookmarks at @ (%s) — move or delete one to pick a PR head",
					table.concat(names, ", ")
				)
		end
		return names[1], nil
	end

	---@param root string
	---@return string[]|nil names Bookmarks on the nearest bookmarked ancestor of
	--- @, or nil when jj itself failed.
	---@return string|nil err
	local function bookmarks_at_head(root)
		-- @ is typically an empty working-copy commit, so walk back to the
		-- closest ancestor that carries a bookmark. --ignore-working-copy keeps
		-- this read-only: no snapshot, no operation-log entry.
		local res = vim
			.system({
				"jj",
				"--repository",
				root,
				"--ignore-working-copy",
				"--color",
				"never",
				"bookmark",
				"list",
				"-r",
				"heads(::@ & bookmarks())",
				"-T",
				'name ++ "\n"',
			}, { text = true })
			:wait()
		if res.code ~= 0 then
			local stderr = tostring(res.stderr or ""):gsub("%s+", " "):match("^%s*(.-)%s*$")
			return nil, stderr ~= "" and stderr or ("jj exited with code " .. tostring(res.code))
		end
		return parse_bookmark_names(res.stdout or ""), nil
	end

	---@param root string
	---@return string|nil branch, string|nil err
	git.current_branch = function(root)
		local branch, err = detect_branch(root)
		if branch then
			return branch, nil
		end
		if vim.fn.executable("jj") ~= 1 or vim.fn.isdirectory(root .. "/.jj") ~= 1 then
			return nil, err
		end

		local names, jj_err = bookmarks_at_head(root)
		if not names then
			return nil, "jj bookmark lookup failed: " .. tostring(jj_err)
		end
		return pick_bookmark(names)
	end
end

return {
	"emrearmagan/atlas.nvim",
	keys = {
		{ "<leader>ap", "<cmd>Atlas pulls github<cr>", desc = "Pull requests" },
		{ "<leader>at", "<cmd>Atlas issues jira<cr>", desc = "Jira tickets" },
		{ "<leader>agc", "<cmd>Atlas create pr<cr>", desc = "Create pull request" },
	},
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- optional but recommended
		{ "MeanderingProgrammer/render-markdown.nvim", opts = {} },
		"esmuellert/codediff.nvim", -- optional (PullRequest diff)
		-- No upstream diffview: it shares the `diffview` Lua namespace with
		-- diffview-plus.nvim, and whichever loads first wins per-module, so
		-- mixed halves break the fork's layouts.
	},
	opts = {
		-- Credentials and transport, shared by both domains. A provider is only
		-- selectable once it has an entry here, so github needs one even though it
		-- authenticates through `gh` and takes no options.
		---@type AtlasProvidersConfig
		providers = {
			---@type AtlasGitHubConfig
			github = {},
			---@type AtlasJiraConfig
			jira = {
				token = vim.env.JIRA_TOKEN,
				base_url = vim.env.JIRA_BASE_URL,
				email = vim.env.JIRA_EMAIL,
			},
		},
		pulls = {
			---@type AtlasGitHubPullsConfig
			github = {
				---@type AtlasGitHubViewConfig[]
				views = {
					{ name = "Repo", key = "1", layout = "plain", current_repo = true, search = gh_search("") },
					{ name = "Mine", key = "2", layout = "plain", search = gh_search(MINE) },
					{
						name = "Answered",
						key = "3",
						layout = "plain",
						search = gh_search(MINE .. " " .. REVIEWED),
					},
					{ name = "Review", key = "4", layout = "plain", search = gh_search("review-requested:@me") },
					{ name = "All", key = "5", layout = "plain", search = gh_search("involves:@me") },
				},

				bookmarks = {
					items = {
						["Approved"] = gh_search(MINE .. " review:approved"),
						["Awaiting review"] = gh_search(MINE .. " review:required"),
						["Failing checks"] = gh_search(MINE .. " status:failure"),
						["Drafts"] = gh_search(MINE .. " is:draft"),

						["Reviewed by me"] = gh_search("reviewed-by:@me"),
						["Mentions me"] = gh_search("mentions:@me"),
						["Recently merged"] = "is:pr is:merged author:@me sort:updated-desc",
					},
				},
			},
		},
		issues = {
			---@type AtlasJiraIssuesConfig
			jira = {
				---@type AtlasJiraViewConfig[]
				views = {
					{
						name = "Priority",
						key = "1",
						layout = "plain",
						jql = board_jql("priority in (High, Urgent)", BY_RECENT),
					},
					{
						name = "Mine",
						key = "2",
						layout = "plain",
						jql = board_jql("assignee = currentUser()", BY_RECENT),
					},
					{
						name = "Involved",
						key = "3",
						layout = "plain",
						jql = board_jql(INVOLVED, BY_RECENT),
					},
					{
						name = "Triage",
						key = "4",
						layout = "compact",
						jql = board_jql(BACKLOG_COLUMNS .. " AND assignee is EMPTY", BY_RECENT),
					},
					{
						name = "Backlog",
						key = "5",
						layout = "compact",
						jql = board_jql(BACKLOG_COLUMNS, BY_RECENT),
					},
					{
						name = "Active",
						key = "6",
						layout = "compact",
						jql = board_jql(ACTIVE_COLUMNS, BY_RECENT),
					},
					{
						name = "Unanswered",
						key = "7",
						layout = "compact",
						jql = board_jql(UNANSWERED, BY_RECENT),
					},
				},

				bookmarks = {
					items = {
						-- Board 562 quick filters, scoped to support tickets.
						["New this week"] = board_jql("created >= -1w", "created DESC"),
						["Stale 30d+"] = board_jql("updated < -30d", "updated ASC"),
						["More info needed"] = board_jql('status = "More Info Needed"', BY_UPDATED),
						["No components"] = board_jql("component is EMPTY", BY_PRIORITY),
						["Bugs"] = board_jql("labels in (bug)", BY_PRIORITY),
						["Feature requests"] = board_jql("labels in (feature_request, feature)", BY_PRIORITY),

						["Unanswered 14d+"] = board_jql(UNANSWERED .. " AND created < -14d", BY_OLDEST),
						["No reply 30d+"] = board_jql(ANSWERED .. " AND updated < -30d", BY_STALEST),
						["No reply 90d+"] = board_jql(ANSWERED .. " AND updated < -90d", BY_STALEST),
						["Barely discussed"] = board_jql("numberOfComments <= 1", "priority DESC, " .. BY_OLDEST),
					},
				},

				---@type AtlasJiraProjectConfig
				project_config = {
					PIPE = {
						components = {
							name = "Component",
							format = function(value)
								if type(value) ~= "table" or #value == 0 then
									return nil
								end
								local names = vim.tbl_map(function(component)
									return component.name
								end, value)
								return table.concat(names, ", ")
							end,
							hl_group = "AtlasChipActive",
							display = "chip",
						},
						labels = {
							name = "Labels",
							format = function(value)
								if type(value) ~= "table" or #value == 0 then
									return nil
								end
								return table.concat(value, ", ")
							end,
							hl_group = "AtlasTextMuted",
							display = "chip",
						},
						customfield_10053 = {
							name = "Impact",
							format = function(value)
								return type(value) == "table" and value.value or nil
							end,
						hl_group = "AtlasTextWarning",
						display = "table",
					},
				},
				},
			},
		},
	},
	config = function(_, opts)
		require("atlas").setup(opts)
		add_timestamp_columns()
		prompt_required_jira_fields()
		resolve_github_enterprise()
		resolve_jj_bookmarks()
		route_gh_to_remote_host()
		search_github_hosts()
	end,
}
