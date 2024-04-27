local vim = vim
local context = [[
	You are AI coding assistant for editor designed to provide code snippets and programming solutions.
	Your responses will be directly inserted into the working within the editor.
	The code you provide should be complete, accurate, and ready to be integrated into the user's project seamlessly.
	Avoid using any formatting, such as backticks or code tags, and focus solely on providing the raw code.
	Remember, your response will be inserted directly into file with file type: %s.

	Request: %s
]]

local has_undo = false

local function isCursorAtEndOfFile()
	local total_lines = vim.api.nvim_buf_line_count(0)
	local cur_pos = vim.api.nvim_win_get_cursor(0)
	local cur_line = cur_pos[1]
	local cur_col = cur_pos[2]
	local last_line_content = vim.api.nvim_buf_get_lines(0, total_lines - 1, total_lines, false)[1]
	cur_col = cur_col + 1
	if cur_line == total_lines and cur_col >= #last_line_content then
		return true
	else
		return false
	end
end

local function replace_with_api_output(text, request)
	local escaped_text = vim.fn.shellescape(text)
	local file_type = vim.bo.filetype
	local escaped_request = vim.fn.shellescape(string.format(context, file_type, request))
	local cmd = "sh"
	local args = {"-c", "echo " .. escaped_text .. " | aichat " .. escaped_request}
	local stdout = vim.loop.new_pipe()
	local stderr = vim.loop.new_pipe()
	local stderr_chunks = {}

	local handle, err
	local start_line, start_col, end_line, end_col
	local function on_stdout_read(_, chunk)
		if chunk then
			vim.schedule(function()
				if start_line == nil then
					local cursor_pos = vim.api.nvim_win_get_cursor(0)
					start_line, start_col = cursor_pos[1], cursor_pos[2]
				end
				local lines = vim.split(chunk, '\n', true)
				if has_undo then
					vim.cmd([[undojoin]])
				end
				vim.api.nvim_put(lines, 'c', true, true)
				has_undo = true
				local cursor_pos = vim.api.nvim_win_get_cursor(0)
				end_line, end_col = cursor_pos[1], cursor_pos[2]
			end)
		end
	end

	local function on_stderr_read(_, chunk)
		if chunk then
			table.insert(stderr_chunks, chunk)
		end
	end

	local function on_complete(error)
		if error then
			print(error)
		end
	end

	-- If there is selection, remove it cuz we will replace it with content
	if text ~= '' then
		has_undo = true
		vim.cmd('normal! gv^d')
		if text:match("\n$") ~= nil then
			vim.cmd([[undojoin]])
			vim.cmd('normal! O')
		end
	end

	handle, err = vim.loop.spawn(cmd, {
		args = args,
		stdio = { nil, stdout, stderr },
	}, function(code)
			stdout:close()
			stderr:close()
			if handle ~= nil then
				handle:close()
				vim.schedule(function()
					vim.cmd([[undojoin]])
					vim.cmd('normal! ' .. start_line .. 'G' .. start_col .. 'v' .. end_line .. 'G' .. end_col .. '|=`]')
					-- If we have blank new line (block mode of typing, remove it)
					if end_col == 0 and not isCursorAtEndOfFile() then
						vim.cmd([[undojoin]])
						vim.cmd('normal! dd$')
					end
				end)
			end

			vim.schedule(function()
				-- We are done, reset state var
				has_undo = false
				if code ~= 0 then
					on_complete(vim.trim(table.concat(stderr_chunks, "")))
				end
			end)
		end)

	if not handle then
		print('Error while processing: ' .. err)
	else
		stdout:read_start(on_stdout_read)
		stderr:read_start(on_stderr_read)
	end
end

local function region_to_text(region)
	local text = ''
	local maxcol = vim.v.maxcol
	for line, cols in vim.spairs(region) do
		local endcol = cols[2] == maxcol and -1 or cols[2]
		local chunk = vim.api.nvim_buf_get_text(0, line, cols[1], line, endcol, {})[1]
		text = ('%s%s\n'):format(text, chunk)
	end
	return text
end

vim.api.nvim_create_user_command('Assist',
	function(args)
		local selection = ""
		if args.range > 0 then
			local r = vim.region(0, "'<", "'>", vim.fn.visualmode(), true)
			selection = region_to_text(r)
		end

		local request = ''
		if args.args ~= "" then
			request = args.args -- The text passed as an argument
		else
			print("Please provide text as an argument.")
		end

		replace_with_api_output(selection, request)
	end,
	{ nargs = "*", range = true } -- Changed nargs to "*" to accept any text as a single argument
)

