local opts = { noremap = true, silent = true }

--local term_opts = { silent = true }

--Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

opts.desc = "Insert mode - move right"
vim.keymap.set("i", "<C-l>", "<Right>", opts)
opts.desc = "Insert mode - move left"
vim.keymap.set("i", "<C-h>", "<Left>", opts)
opts.desc = "Disable search highlighting"
vim.keymap.set("n", "<CR>", vim.cmd.noh, opts)

-- Navigate buffers
opts.desc = "Next buffer"
vim.keymap.set("n", "<S-l>", ":bnext<CR>", opts)
opts.desc = "Previous buffer"
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
opts.desc = "Order buffer by number"
vim.keymap.set("n", "<Space>bb", "<Cmd>BufferOrderByBufferNumber<CR>", opts)
opts.desc = "Order buffer by name"
vim.keymap.set("n", "<Space>bn", "<Cmd>BufferOrderByName<CR>", opts)
opts.desc = "Order buffer by directory"
vim.keymap.set("n", "<Space>bd", "<Cmd>BufferOrderByDirectory<CR>", opts)
opts.desc = "Order buffer by language"
vim.keymap.set("n", "<Space>bl", "<Cmd>BufferOrderByLanguage<CR>", opts)
opts.desc = "Order buffer by window number"
vim.keymap.set("n", "<Space>bw", "<Cmd>BufferOrderByWindowNumber<CR>", opts)
opts.desc = "Close buffer"
vim.keymap.set("n", "<Space>bc", "<Cmd>BufferClose<CR>", opts)
opts.desc = "Delete buffer"
vim.keymap.set("n", "<Space>bd", "<Cmd>BufferDelete<CR>", opts)

-- Move text up and down
opts.desc = "Move text up in normal"
vim.keymap.set("n", "<A-k>", "<Esc>:m .-2<CR>==gi", opts)
opts.desc = "Move text down in normal"
vim.keymap.set("n", "<A-j>", "<Esc>:m .+1<CR>==gi", opts)
opts.desc = "Paste in visual"
vim.keymap.set("v", "p", '"_dP', opts)

-- Visual --
opts.desc = "Tab highlighted text left"
vim.keymap.set("v", "<", "<gv", opts)
opts.desc = "Tab highlighted text right"
vim.keymap.set("v", ">", ">gv", opts)

-- Visual Block --
-- Move text up and down
opts.desc = "Move text down in visual block"
vim.keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
opts.desc = "Move text up in visual block"
vim.keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

opts.desc = "Show floating diagnostic window"
vim.keymap.set("n", "<C-S-k>", "<CMD>lua vim.diagnostic.open_float()<CR>", opts)

opts.desc = ""
vim.keymap.set("n", "<Esc>", "<Esc>", opts)
vim.keymap.set("i", "<Esc>", "<Esc>", opts)
vim.keymap.set("i", "<C-Enter>", "<Esc>o", opts)

-- opts.desc = "Show LSP references"
-- vim.keymap.set("n", "sR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

-- opts.desc = "Go to declaration"
-- vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

-- opts.desc = "Show LSP definitions"
-- vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

-- opts.desc = "Show LSP implementations"
-- vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

-- opts.desc = "Show LSP type definitions"
-- vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

-- opts.desc = "See available code actions"
-- vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

-- opts.desc = "Smart rename"
-- vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

-- opts.desc = "Show buffer diagnostics"
-- vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

-- opts.desc = "Show line diagnostics"
-- vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

-- opts.desc = "Go to previous diagnostic"
-- vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

-- opts.desc = "Go to next diagnostic"
-- vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

-- opts.desc = "Show documentation for what is under cursor"
-- vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

-- opts.desc = "Restart LSP"
-- vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
