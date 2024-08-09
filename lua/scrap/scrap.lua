local M = {}

local win_id = nil
local buf_id = nil
local scrap_file = vim.fn.stdpath('data') .. '/scrap.txt'

function M.toggle_pad()
  -- close window if exists
  if win_id and vim.api.nvim_win_is_valid(win_id) then
    if not vim.api.nvim_buf_is_valid(buf_id) then
      return
    end

    local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
    local file = io.open(scrap_file, 'w')
    if file then
      file:write(table.concat(lines, '\n'))
      file:close()
    end
    if vim.api.nvim_buf_is_valid(buf_id) then
      vim.api.nvim_buf_delete(buf_id, { force = true })
    end
    buf_id = nil
    if vim.api.nvim_win_is_valid(win_id) then
      vim.api.nvim_win_close(win_id, true)
    end
    win_id = nil
  else
    -- create new buffer if doesnt exist or is invalid
    if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
      buf_id = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf_id, 'scrap')
    end

    -- read file into buffer
    local file = io.open(scrap_file, 'r')
    if file then
      local content = file:read('*a')
      file:close()
      vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, vim.split(content, '\n'))
    end
    -- current editor dimensions
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    -- define floating window dimensions
    local win_width = math.floor(width * 0.8)
    local win_height = math.floor(height * 0.8 - 4)

    -- window opts
    local opts = {
      style = "minimal",
      relative = "editor",
      width = win_width,
      height = win_height,
      row = math.floor((height - win_height) / 2),
      col = math.floor((width - win_width) / 2)
    }

    -- Create the floating window
    win_id = vim.api.nvim_open_win(buf_id, true, opts)

    -- keymap for closing with esc
    vim.api.nvim_buf_set_keymap(buf_id, 'n', '<Esc>',
      '<Cmd>lua require("scrap.scrap").toggle_pad()<CR>',
      { noremap = true, silent = true })
    -- optional: set buffer options
    -- vim.api.nvim_buf_set_option(buf_id, "bufhidden", "wipe")
  end
end

return M
