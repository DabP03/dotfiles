vim.lsp.enable("tinymist")
-- vim.opt.spell = true
-- vim.opt.spelllang = { "pl", "en_us" }

vim.cmd([[
    set makeprg=typst\ compile\ %
]])
