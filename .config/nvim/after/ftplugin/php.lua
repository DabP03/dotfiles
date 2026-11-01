vim.lsp.config('intelephense', {
  cmd = { 'intelephense', '--stdio' },
  filetypes = { 'php', 'blade' },
  root_markers = { 'artisan', 'composer.json', '.git' },
  settings = {
    intelephense = {
      files = { maxSize = 5000000 },
      environment = { phpVersion = '8.3.0' }, -- match your project
      format = { enable = false }, -- let Pint handle formatting
      -- licenceKey = '...',  -- only needed for premium features (rename, etc.)
    },
  },
})

vim.lsp.config('tailwindcss', {
  filetypes = { 'html', 'blade', 'php', 'javascript', 'typescript', 'vue' },
  settings = {
    tailwindCSS = {
      includeLanguages = { blade = 'html' },
    },
  },
})

vim.lsp.config('emmet_ls', {
  filetypes = { 'html', 'blade', 'css' },
})

vim.lsp.enable({ 'intelephense', 'tailwindcss', 'html', 'emmet_ls' })
