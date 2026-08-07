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
}
