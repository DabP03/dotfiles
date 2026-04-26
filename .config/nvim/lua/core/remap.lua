local opts = { noremap = true, silent = true }

--Remap space as leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("", "<Space>", "<Nop>", { desc = "" })
vim.keymap.set("", "<C-Space>", "<Nop>", { desc = "" })

vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Insert mode - move right" })
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Insert mode - move left" })
vim.keymap.set("n", "<CR>", vim.cmd.noh, { desc = "Disable search highlighting" })
vim.keymap.set("", "<C-c>", "<NOP>", { desc = "Disable C-c" })
vim.keymap.set("", "<C-c>", "<ESC>", { desc = "Exit mode with C-c with abbreviations" })

-- Navigate buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Visual --
vim.keymap.set("v", "<", "<gv", { desc = "Tab highlighted text left" })
vim.keymap.set("v", ">", ">gv", { desc = "Tab highlighted text right" })

-- Move text up and down
vim.keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv", { desc = "Move text down in visual block" })
vim.keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv", { desc = "Move text up in visual block" })
vim.keymap.set("n", "<C-A-k>", "<CMD>lua vim.diagnostic.open_float()<CR>", { desc = "Show floating diagnostic window" })

vim.keymap.set({ "n", "i" }, "<Esc>", "<Esc>", { desc = "" })
vim.keymap.set("n", "<leader>lf", '<CMD>lua require("conform").format()<CR>', { desc = "Format current buffer" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>bc", "<CMD>bd<CR>", { desc = "Close current buffer" })

-- LSP
vim.keymap.set("n", "<leader>lR", "<cmd>Telescope lsp_references<CR>", { desc = "Show LSP references" })
vim.keymap.set("n", "<leader>lD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "<leader>ld", "<cmd>Telescope lsp_definitions<CR>", { desc = "Show LSP definitions" })
vim.keymap.set("n", "<leader>li", "<cmd>Telescope lsp_implementations<CR>", { desc = "Show LSP implementations" })
vim.keymap.set("n", "<leader>lt", "<cmd>Telescope lsp_type_definitions<CR>", { desc = "Show LSP type definitions" })
vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, { desc = "See available code actions" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Smart rename" })
vim.keymap.set("n", "<leader>llD", "<cmd>Telescope diagnostics bufnr=0<CR>", { desc = "Show buffer diagnostics" })
vim.keymap.set("n", "<leader>lld", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show documentation for what is under cursor" })
vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", { desc = "Restart LSP" })

-- Neogit
vim.keymap.set("n", "<leader>ng", "<CMD>Neogit<CR>", { desc = "Launch Neogit" })

