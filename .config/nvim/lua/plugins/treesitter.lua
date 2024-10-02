return {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
        require("nvim-treesitter.configs").setup({
            -- indent = {
            --     enable = true,
            -- },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<leader>is", -- set to `false` to disable one of the mappings
                    node_incremental = "<leader>ni",
                    scope_incremental = "<leader>si",
                    node_decremental = "<leader>nd",
                },
            },
            textobjects = {
                select = {
                    enable = true,

                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,

                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ["af"] = { query = "@function.outer", desc = "Select outer function"},
                        ["if"] = { query = "@function.inner", desc = "Select inner function"},
                        ["ac"] = { query = "@class.outer", desc = "Select outer class" },
                        ["ic"] = { query = "@class.inner", desc = "Select inner class" },
                        ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                        ["ii"] = { query = "@conditional.inner", desc = "Select inner conditional" },
                        ["ai"] = { query = "@conditional.outer", desc = "Select outer conditional" },
                        ["il"] = { query = "@loop.inner", desc = "Select inner loop" },
                        ["al"] = { query = "@loop.outer", desc = "Select outer loop" },
                    },
                    selection_modes = {
                        ['@parameter.outer'] = 'v', -- charwise
                        ['@function.outer'] = 'V', -- linewise
                        ['@class.outer'] = '<c-v>', -- blockwise
                    },
                    include_surrounding_whitespace = false,
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>a"] = { query = "@parameter.inner", desc = "Move parameter right" },
                    },
                    swap_previous = {
                        ["<leader>A"] = { query = "@parameter.outer", desc = "Move parameter left" },
                    }
                }
            },
        })
    end
}
