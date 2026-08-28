-- Board parity: filter 11836 backs Jira board 562 "All Pipe" and already drops
-- Closed/Cancelled/Resolved/Done plus on-hold items with a future due date.
-- Referencing it keeps these views in sync when the board owners retune it.
local PIPE_BOARD = "filter = 11836 AND issuetype = Support"

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

local BY_PRIORITY = "priority DESC, created DESC"
local BY_UPDATED = "updated DESC"

-- GitHub search. Every view wants open PRs, no archived repos, and most recent
-- activity first, so all three live in the helper rather than per query.
---@param clause string
---@return string
local function gh_search(clause)
	return string.format("is:pr is:open archived:false %s sort:updated-desc", clause)
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

-- atlas parses the remote's host but spawns a bare `gh`, passing the repo as an
-- unqualified `--repo owner/name`. An explicit --repo overrides gh's own remote
-- inference, so on a self-hosted forge every call hits github.com and fails with
-- "Could not resolve to a Repository". GH_HOST fixes both call shapes (`--repo`
-- and `api repos/<slug>`), where a host-qualified slug would break the latter.
-- gh reads it from the environment only, so this cannot live in git config.
local function route_gh_to_remote_host()
	local system = vim.system
	local DEFAULT_HOST = "github.com"

	-- Keying on cwd is wrong here: atlas spawns gh without one, and the repo
	-- being viewed need not be the repo nvim was started in. The slug travels in
	-- the command itself, so learn each slug's host as atlas resolves repos.
	local host_by_slug = {}

	-- atlas points gh at a repo three different ways: positionally
	-- (`repo view <slug>`), by flag (`--repo <slug>`) and inside an API path
	-- (`repos/<slug>/issues/1`). Rather than model each shape, look for any
	-- known slug anywhere in the command.
	---@param cmd string[]
	---@param known table<string, string>
	---@return string|nil host
	local function host_for_command(cmd, known)
		for _, arg in ipairs(cmd) do
			if type(arg) == "string" then
				if known[arg] then
					return known[arg]
				end
				local embedded = arg:match("repos/([^/]+/[^/?#]+)")
				if embedded and known[embedded] then
					return known[embedded]
				end
			end
		end
		return nil
	end

	-- atlas resolves the remote through this one function for every repo it
	-- touches, which is where the slug -> host mapping becomes known.
	local git = require("atlas.core.git")
	local local_repository = git.local_repository
	git.local_repository = function(cwd)
		local info = local_repository(cwd)
		if info and info.slug and info.host and info.host ~= DEFAULT_HOST then
			host_by_slug[info.slug] = info.host
		end
		return info
	end

	vim.system = function(cmd, opts, on_exit)
		if type(cmd) == "table" and cmd[1] == "gh" then
			local host = host_for_command(cmd, host_by_slug)
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
		"MeanderingProgrammer/render-markdown.nvim", -- optional but recommended
		"esmuellert/codediff.nvim", -- optional (PullRequest diff)
		"sindrets/diffview.nvim", -- optional (PullRequest diff - alternative)
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
					{ name = "Mine", key = "1", layout = "plain", search = gh_search(MINE) },
					{
						name = "Answered",
						key = "2",
						layout = "plain",
						search = gh_search(MINE .. " " .. REVIEWED),
					},
					{ name = "Review", key = "3", layout = "plain", search = gh_search("review-requested:@me") },
					{ name = "All", key = "4", layout = "plain", search = gh_search("involves:@me") },
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
						jql = board_jql("priority in (High, Urgent)", BY_PRIORITY),
					},
					{
						name = "Mine",
						key = "2",
						layout = "plain",
						jql = board_jql("assignee = currentUser()", BY_UPDATED),
					},
					{
						name = "Triage",
						key = "3",
						layout = "compact",
						jql = board_jql(BACKLOG_COLUMNS .. " AND assignee is EMPTY", BY_PRIORITY),
					},
					{
						name = "Backlog",
						key = "4",
						layout = "compact",
						jql = board_jql(BACKLOG_COLUMNS, BY_PRIORITY),
					},
					{
						name = "Active",
						key = "5",
						layout = "compact",
						jql = board_jql(ACTIVE_COLUMNS, BY_UPDATED),
					},
					{
						name = "Unanswered",
						key = "6",
						layout = "compact",
						jql = board_jql(UNANSWERED, "priority DESC, " .. BY_OLDEST),
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
		resolve_jj_bookmarks()
		route_gh_to_remote_host()
	end,
}
