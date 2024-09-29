return {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {},
    config = function()
        local opts = { noremap = true, silent = true }
        opts.desc = "Toggle Render Markdown"
        vim.keymap.set("n", "<leader>tm", "<Cmd>RenderMarkdown toggle<CR>", opts)
    end,
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
}
