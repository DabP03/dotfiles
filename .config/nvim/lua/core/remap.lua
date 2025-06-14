local opts = { noremap = true, silent = true }
local keymap_set = function(mode, keybind, action, desc)
	opts.desc = desc
	vim.keymap.set(mode, keybind, action, opts)
end

--Remap space as leader key
keymap_set("", "<Space>", "<Nop>", "")
keymap_set("", "<C-Space>", "<Nop>", "")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap_set("i", "<C-l>", "<Right>", "Insert mode - move right")
keymap_set("i", "<C-h>", "<Left>", "Insert mode - move left")
keymap_set("n", "<CR>", vim.cmd.noh, "Disable search highlighting")
keymap_set("", "<C-c>", "<NOP>", "Disable C-c")
keymap_set("", "<C-c>", "<ESC>", "Exit mode with C-c with abbreviations")

-- Navigate buffers
keymap_set("n", "<S-l>", ":bnext<CR>", "Next buffer")
keymap_set("n", "<S-h>", ":bprevious<CR>", "Previous buffer")

-- Move text up and down
keymap_set("n", "<A-k>", "<Esc>:m .-2<CR>==gi", "Move text up in normal")
keymap_set("n", "<A-j>", "<Esc>:m .+1<CR>==gi", "Move text down in normal")
keymap_set("v", "p", '"_dP', "Paste in visual")

-- Visual --
keymap_set("v", "<", "<gv", "Tab highlighted text left")
keymap_set("v", ">", ">gv", "Tab highlighted text right")

-- Visual Block --
-- Move text up and down
keymap_set("x", "<A-j>", ":move '>+1<CR>gv-gv", "Move text down in visual block")
keymap_set("x", "<A-k>", ":move '<-2<CR>gv-gv", "Move text up in visual block")
keymap_set("n", "<C-A-k>", "<CMD>lua vim.diagnostic.open_float()<CR>", "Show floating diagnostic window")

keymap_set({ "n", "i" }, "<Esc>", "<Esc>", "")
