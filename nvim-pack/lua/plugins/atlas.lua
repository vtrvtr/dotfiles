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
-- Neglect queues read oldest-first: the top row is the worst offender.
local BY_OLDEST = "created ASC"
local BY_STALEST = "updated ASC"

-- Jira exposes no lastComment field, so "time since last answer" falls back to
-- `updated`. A comment always bumps `updated`, so this yields no false positives,
-- but a field edit or automation bump can hide a genuinely unanswered ticket:
-- measured recall against real comment timestamps is 99% at 30d, 90% at 90d.
local ANSWERED = "numberOfComments > 0"
local UNANSWERED = "numberOfComments = 0"

-- The Jira provider ships no Created/Updated columns (upstream 0.5.0 has them
-- for GitHub only), and its issue search requests a fixed field list that omits
-- both timestamps. Two seams close that gap without patching the plugin:
-- widen the search payload, then supply the provider's optional ui.render.
local function add_timestamp_columns()
	local service = require("atlas.issues.providers.jira.api.service")
	local renderer = require("atlas.issues.providers.jira.ui.renderer")
	local table_tree = require("atlas.ui.components.table_tree")
	local icons = require("atlas.ui.shared.icons")
	local utils = require("atlas.ui.shared.utils")
	local state = require("atlas.issues.state")

	local request = service.request
	service.request = function(method, endpoint, data, on_done, ctx)
		if endpoint == "/search/jql" and type(data) == "table" and type(data.fields) == "table" then
			data = vim.tbl_extend("force", data, {
				fields = vim.list_extend(vim.deepcopy(data.fields), { "created", "updated" }),
			})
		end
		return request(method, endpoint, data, on_done, ctx)
	end

	---@class AtlasJiraRow
	---@field icon string
	---@field name string
	---@field assignee string
	---@field reporter string
	---@field status string
	---@field created string Relative age, or "-" when Jira returned no timestamp.
	---@field updated string
	---@field children AtlasJiraRow[]|nil
	---@field _issue Issue
	---@field _item table

	---@param issue Issue
	---@param is_child boolean
	---@param children Issue[]|nil
	---@return AtlasJiraRow
	local function to_row(issue, is_child, children)
		local fields = (issue._raw or {}).fields or {}
		local row = renderer.format_row(issue, is_child)
		row.created = utils.relative_time(fields.created)
		row.updated = utils.relative_time(fields.updated)
		row._issue = issue
		row._item = { kind = "issue", key = issue.key, _issue = issue }
		row.children = children
				and vim.tbl_map(function(child)
					return to_row(child, true, nil)
				end, children)
			or nil
		return row
	end

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

	local function cell_hl(row, col, ctx)
		if col.key == "created" or col.key == "updated" then
			return { { start_col = 0, end_col = #ctx.padded, hl_group = "AtlasTextMuted" } }
		end
		return renderer.cell_hl(row, col, ctx)
	end

	return function(issue_groups, layout, opts)
		local rows = layout == "compact"
				and vim.tbl_map(function(issue)
					return to_row(issue, false, nil)
				end, state.issues or {})
			or vim.tbl_map(function(group)
				return to_row(group.issue, false, group.children)
			end, issue_groups or {})

		local render_opts = {
			width = opts.width,
			margin = 1,
			columns = COLUMNS,
			rows = rows,
			cell_hl = cell_hl,
		}
		if layout ~= "compact" then
			-- Read per render, not per row: state replaces this table on reset.
			local collapsed = state.collapsed_issue_keys or {}
			render_opts.tree = {
				column_key = "icon",
				children_key = "children",
				default_expanded = true,
				indent = "",
				leaf_prefix = "",
				is_expanded = function(row)
					local key = row._issue and tostring(row._issue.key or "") or ""
					return key == "" or collapsed[key] ~= true
				end,
			}
		end

		local lines, line_map, spans = table_tree.render(render_opts)
		return { lines = lines, spans = spans, line_map = line_map }
	end
end

return {
	"emrearmagan/atlas.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- optional but recommended
		"MeanderingProgrammer/render-markdown.nvim", -- optional but recommended
		"esmuellert/codediff.nvim", -- optional (PullRequest diff)
		"sindrets/diffview.nvim", -- optional (PullRequest diff - alternative)
	},
	opts = {
		pulls = {
			providers = {
				---@type AtlasBitbucketConfig
				bitbucket = {}, -- See configuration below
				---@type AtlasGitHubConfig
				github = {}, -- See configuration below
				---@type AtlasGitLabPullsConfig
				gitlab = {}, -- See configuration below
			},
		},
		issues = {
			providers = {
				---@type AtlasJiraIssuesConfig
				jira = {
					token = vim.env.JIRA_TOKEN,
					base_url = vim.env.JIRA_BASE_URL,
					email = vim.env.JIRA_EMAIL,

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
				---@type AtlasGitHubIssuesConfig
				github = {}, -- See configuration below
				---@type AtlasGitLabIssuesConfig
				gitlab = {}, -- See configuration below
			},
		},
	},
	config = function(_, opts)
		require("atlas").setup(opts)
		require("atlas.issues.providers.jira").capabilities.ui.render = add_timestamp_columns()
	end,
}
