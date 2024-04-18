return {
    'hiphish/rainbow-delimiters.nvim',
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = "BufEnter",
    submodules = false,
    config = function()
        local rainbow = require 'rainbow-delimiters'

        vim.g.rainbow_delimiters = {
            -- Each language is based on a treesitter language name.

            -- Defines the highlighting strategy.
            strategy = {
                --[[
                'global' - Highlight all delimiters, updates with document
                           changes.
                'local'  - Highlight only the subtree that contains the cursor,
                           updates when the cursor moves.
                --]]
                -- Default Strategy
                [''] = rainbow.strategy['global'],
                html = rainbow.strategy['local'],
                latex = function()
                    -- Disabled for very large files,
                    if vim.fn.line('$') > 10000 then
                        return nil
                        -- global strategy for large files,
                    elseif vim.fn.line('$') > 1000 then
                        return rainbow.strategy['global']
                    end
                    -- local strategy otherwise
                    return rainbow.strategy['local']
                end
            },

            -- Defines what to match
            query = {
                -- Default Query - Reasonable set of parenthesis and similar
                -- delimiters in most languages
                [''] = 'rainbow-delimiters',
                -- Matches `\begin` and `\end` instructions
                latex = 'rainbow-blocks',
                -- Matches keywords like `function` and `end` as well as
                -- parenthesis
                lua = 'rainbow-blocks',
                -- Includes React support
                javascript = 'rainbow-delimiters-react',
                --[[
                -- Only parenthesis without React tags
                javascript = 'rainbow-parens',
                -- Only typescript highlighting without React tags
                tsx = 'rainbow-parens',
                --]]
                -- Matches keywords like `begin` and `end` as well as
                -- parenthesis
                verilog = 'rainbow-blocks',
            },
            highlight = {
                'RainbowDelimiterRed',
                'RainbowDelimiterYellow',
                'RainbowDelimiterBlue',
                'RainbowDelimiterOrange',
                'RainbowDelimiterGreen',
                'RainbowDelimiterViolet',
                'RainbowDelimiterCyan',
            },
            --[[
            blacklist = {
                'c',
                'cpp',
            },
            whitelist = {
                'python',
                'javascript',
            },
            log = {
                file = '~/.local/state/lvim/rainbow-delimiters.log',
                level = vim.log.levels.DEBUG,
            },
            --]]
        }
    end
}
