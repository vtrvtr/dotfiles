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
				}, -- See configuration below
				---@type AtlasGitHubIssuesConfig
				github = {}, -- See configuration below
				---@type AtlasGitLabIssuesConfig
				gitlab = {}, -- See configuration below
			},
		},
	},
}
