local WINDOW = {}

UTILS = require("wardrobe.utils")

local example_code = {
  "-- Function to draw a vortex pattern",
  "function drawVortexPattern()",
  "    local centerX = 20",
  "    local centerY = 10",
  "    local maxRadius = 10",
  "    ",
  "    for y = 1, 20 do",
  "        local row = \"\"",
  "        for x = 1, 40 do",
  "            local distance = math.sqrt((x - centerX)^2 + (y - centerY)^2)",
  "            local angle = math.atan2(y - centerY, x - centerX)",
  "            local displacement = math.sin(distance / maxRadius * math.pi * 4 - angle * 2) * 0.8",
  "            local value = math.sin(displacement) * 1.5 + math.cos(displacement) * 1.5",
  "            local character = \" \"",
  "            if value > 1 then",
  "                character = \"*\"",
  "            elseif value > 0.5 then",
  "                character = \"+\"",
  "            elseif value > 0 then",
  "                character = \".\"",
  "            end",
  "            row = row .. character",
  "        end",
  "        print(row)",
  "    end",
  "end",
  "",
  "-- Draw the vortex pattern",
  "drawVortexPattern()",
}

local selectedColorscheme = ""

-- Autocommand to update highlight groups on colorscheme change
vim.cmd([[
  augroup UpdateHighlightGroups
    autocmd!
    autocmd ColorScheme * lua update_highlight_groups()
  augroup END
]])

-- Initial call to set the highlight groups
update_highlight_groups()


local function apply_colorscheme(wincontent, closewindow, main_win, preview_win, preview_buf)
  local current_line = vim.fn.line('.')
  local content = wincontent[current_line]
  if content then
    if content == "dark bg" then
      UTILS.vim_background("dark")
      if closewindow then
        UTILS.save_mode("dark")
      end
    elseif content == "light bg" then
      UTILS.vim_background("light")
      if closewindow then
        UTILS.save_mode("light")
      end
    else
      content = UTILS.split(content, " ")[2]
      UTILS.vim_colorscheme(content)
      if closewindow then
        UTILS.save_theme(content)
        if main_win then
          vim.api.nvim_win_close(main_win, true)
        end
        if preview_win then
          vim.api.nvim_win_close(preview_win, true)
        end
      else
        vim.api.nvim_buf_set_option(preview_buf, 'modifiable', true)


        vim.api.nvim_buf_set_option(preview_buf, 'filetype', 'lua')
        
        UTILS.reload_syntax()

        -- Clear buffer contents
        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, {})

        -- Add new content to the buffer
        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, example_code)
        vim.api.nvim_buf_set_option(preview_buf, 'modifiable', false)
      end
    end
  end
end

WINDOW.open_preview_window = function()
  local min_term_width = 160
  if vim.o.columns < min_term_width then
    return nil
  end
end

WINDOW.open_window = function()
  update_highlight_groups() -- Ensure highlight groups are set initially

  selectedColorscheme = UTILS.get_selected_colorscheme()

  local preview = vim.o.columns > 160
  local buf = vim.api.nvim_create_buf(false, true)
  local preview_buf = vim.api.nvim_create_buf(false, true)
  local width = 50
  local main_win_width = 60
  if preview then
    main_win_width = 24
  end
  local height = 20
  local col
  if preview then
    col = math.floor((vim.o.columns - width) / 2) - (width / 2)
  else
    col = math.floor((vim.o.columns - width) / 2) + 1
  end
  local row = math.floor((vim.o.lines - height) / 2) + 4

  local options = {
    title = "Wardrobe",
    title_pos = "center",
    style = "minimal",
    relative = 'editor',
    width = main_win_width,
    height = height,
    col = col,
    row = row,
    border = 'single'
  }

  local window = vim.api.nvim_open_win(buf, true, options)
  local colorschemes = UTILS.get_colorschemes()
  local modes = {"dark bg", "light bg"}
  local main_win_content = {}

  for _, value in ipairs(modes) do
    table.insert(main_win_content, value)
  end

  for i, value in ipairs(colorschemes) do
    table.insert(main_win_content, i .. " " .. value)
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, main_win_content)

  local preview_win = nil
  if preview then
    local preview_options = {
      relative = 'editor',
      width = 60,
      height = height,
      col = col + (width / 2) + 1,
      row = row,
      border = 'single'
    }

    vim.api.nvim_buf_set_option(preview_buf, 'filetype', 'lua')
    preview_win = vim.api.nvim_open_win(preview_buf, false, preview_options)
       
    UTILS.reload_syntax()

    -- Clear buffer contents
    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, {})

    -- Add new content to the buffer
    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, example_code)
    vim.api.nvim_buf_set_option(preview_buf, 'modifiable', false)

  end

  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  UTILS.set_keymap(buf, "<CR>", function()
    apply_colorscheme(main_win_content, true, window, preview_win, preview_buf)
  end)

  UTILS.set_keymap(buf, "p", function()
    apply_colorscheme(main_win_content, false, window, preview_win, preview_buf)
  end)

  UTILS.set_keymap(preview_buf, "<esc>", function()
    if selectedColorscheme ~= UTILS.get_selected_colorscheme() then
      UTILS.vim_colorscheme(selectedColorscheme)
    end
    UTILS.close_all(window, preview_win)
  end)

  UTILS.set_keymap(preview_buf, "q", function()
    if selectedColorscheme ~= UTILS.get_selected_colorscheme() then
      UTILS.vim_colorscheme(selectedColorscheme)
    end
    UTILS.close_all(window, preview_win)
  end)

  UTILS.set_keymap(buf, "<esc>", function()
    if selectedColorscheme ~= UTILS.get_selected_colorscheme() then
      UTILS.vim_colorscheme(selectedColorscheme)
    end
    UTILS.close_all(window, preview_win)
  end)

  UTILS.set_keymap(buf, "q", function()
    if selectedColorscheme ~= UTILS.get_selected_colorscheme() then
      UTILS.vim_colorscheme(selectedColorscheme)
    end
    UTILS.close_all(window, preview_win)
  end)
end

WINDOW.register_commands = function()
  vim.api.nvim_create_user_command('Wardrobe', WINDOW.open_window, {})
end

WINDOW.register_keymaps = function()
  vim.api.nvim_set_keymap('n', '<leader>th', "<cmd>:Wardrobe<CR>", {})
end

WINDOW.register_theme = function()
  local theme = UTILS.load_from_fs()

  if theme then
    UTILS.vim_colorscheme(theme)
  end
end

return WINDOW
