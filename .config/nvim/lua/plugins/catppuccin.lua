return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require('catppuccin').setup({
            flavour = "frappe",
            show_end_of_buffer = false,
            styles = {
                comments = {"italic"},
                conditionals = {"bold"},
                loops = {"bold"},
                functions = {},
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
                operators = {},
            },
            integrations = {
                cmp = true,
                gitsigns = true,
                nvimtree = true,
                treesitter = true,
                barbar = true,
                dashboard = true,
                mason = true,
            },
        })
        vim.cmd.colorscheme "catppuccin"
    end,
}