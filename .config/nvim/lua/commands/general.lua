vim.api.nvim_create_augroup("general", { clear = true })

-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	group = "general",
-- 	callback = function()
-- 		vim.cmd("BufferOrderByBufferNumber")
-- 	end,
-- })
--
vim.api.nvim_create_user_command("Tsplit", function(opts)
	local separator = opts.args
	if separator == "" then
		separator = " "
	end

	-- Get line range (either from command range or current line)
	local start_line = opts.line1
	local end_line = opts.line2

	-- Process each line in the range
	local all_new_lines = {}
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	for _, line in ipairs(lines) do
		-- Split the line by the separator
		local parts = {}
		for part in string.gmatch(line, "([^" .. vim.pesc(separator) .. "]+)") do
			table.insert(parts, part .. separator)
		end

		-- Remove separator from the last part
		if #parts > 0 then
			parts[#parts] = parts[#parts]:sub(1, -#separator - 1)
		end

		-- Add split parts to the collection
		for _, part in ipairs(parts) do
			table.insert(all_new_lines, part)
		end
	end

	-- Replace the range with all split lines
	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, all_new_lines)

	-- Position cursor at the beginning of the first split line
	vim.api.nvim_win_set_cursor(0, { start_line, 0 })
end, {
	nargs = "?",
	range = true,
	desc = "Split lines in range on specified character",
})
