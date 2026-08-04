vim.pack.add({"https://github.com/nvim-tree/nvim-web-devicons"})
vim.pack.add({"https://github.com/MeanderingProgrammer/render-markdown.nvim"})
vim.pack.add({"https://github.com/esmuellert/codediff.nvim"})
vim.pack.add({"https://github.com/sindrets/diffview.nvim"})
vim.pack.add({"https://github.com/emrearmagan/atlas.nvim"})
require("atlas").setup(
    {
        pulls = {
            providers = {
                ---@type AtlasBitbucketConfig
                bitbucket = {}, -- See configuration below
                ---@type AtlasGitHubConfig
                github = {}, -- See configuration below
                ---@type AtlasGitLabPullsConfig
                gitlab = {} -- See configuration below
            }
        },
        issues = {
            providers = {
                ---@type AtlasJiraIssuesConfig
                jira = {}, -- See configuration below
                ---@type AtlasGitHubIssuesConfig
                github = {}, -- See configuration below
                ---@type AtlasGitLabIssuesConfig
                gitlab = {} -- See configuration below
            }
        }
    }
)
