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
vim.keymap.set('n', '<Space>bn', '<Cmd>BufferOrderByName<CR>', opts)
opts.desc = "Order buffer by directory"
vim.keymap.set('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', opts)
opts.desc = "Order buffer by language"
vim.keymap.set('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', opts)
opts.desc = "Order buffer by window number"
vim.keymap.set('n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', opts)
opts.desc = "Close buffer"
vim.keymap.set('n', '<Space>bc', '<Cmd>BufferClose<CR>', opts)
opts.desc = "Delete buffer"
vim.keymap.set('n', '<Space>bd', '<Cmd>BufferDelete<CR>', opts)

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

opts.desc = ""
vim.keymap.set("n", "<Esc>", "<Esc>", opts)
vim.keymap.set("i", "<Esc>", "<Esc>", opts)
vim.keymap.set("i", "<C-Enter>", "<Esc>o", opts)

