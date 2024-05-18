return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', opt = true },
    config = function()
        require('lualine').setup {
            options = {
                theme = "catppuccin",
                -- ... the rest of your lualine config
                globalstatus = true,
                ignore_focus = {"NeoTree"}
            }
        }
    end,
}
