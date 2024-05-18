return {
    'NvChad/nvim-colorizer.lua',
    config = function()
        require("colorizer").attach_to_buffer(0, { mode = "background", css = true})
    end,
}
