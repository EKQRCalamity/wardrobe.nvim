local WINDOW = {}

local function get_colorschemes()
  return vim.fn.getcompletion('', 'color')
end

local function vim_colorscheme(colorscheme)
  vim.cmd('colorscheme ' .. colorscheme)
end

local function vim_background(background)
  vim.cmd("set background=" .. background)
end

local function split(str, sep)
  local ret = {}

  for s in string.gmatch(str, "([^"..sep.."]+)") do
    table.insert(ret, s)
  end

  return ret
end

local function apply_colorscheme(wincontent, closewindow, main_win, preview_win)
  local current_line = vim.fn.line('.')
  local content = wincontent[current_line]
  if content then

    if content == "dark bg" then
      vim_background("dark")
    elseif content == "light bg" then
      vim_background("light")
    else
      content = split(content, " ")[2]
      vim_colorscheme(content)
      if closewindow then
        WINDOW.save_theme(content)
        if main_win then
          vim.api.nvim_win_close(main_win, true)
        end
        if preview_win then
          vim.api.nvim_win_close(preview_win, true)
        end
      end
    end
  end
end

local function set_keymap(buf, key, func)
  vim.api.nvim_buf_set_keymap(buf, 'n', key, '', {
    noremap = true,
    silent = true,
    callback = func
  })
end

local function close(window)
  if window then
    vim.api.nvim_win_close(window, true)
  end
end

local function close_all(window1, window2)
  close(window1)
  close(window2)end

WINDOW.save_theme = function (name)
  local config_dir = vim.fn.stdpath('data')
  local config_file = config_dir .. '\\wardrobe-nvim-theme.chosen'

  vim.fn.writefile({name}, config_file)
end

WINDOW.load_theme = function ()
  local config_dir = vim.fn.stdpath('data')
  local config_file = config_dir .. '\\wardrobe-nvim-theme.chosen'

  if vim.fn.filereadable(config_file) == 1 then
    local data = vim.fn.readfile(config_file)
    if #data > 0 then
      return data[1]
    end
  end

  return nil
end

WINDOW.open_preview_window = function()
  local min_term_width = 160
  if vim.o.columns < min_term_width then
    return nil
  end
end

WINDOW.open_window = function()
  -- Get the current colors for the Normal highlight group
  local normal_hl = vim.api.nvim_get_hl_by_name("Normal", true)
  local normal_bg = normal_hl.background
  local normal_fg = normal_hl.foreground

  -- Set the NormalFloat highlight group to use the same colors
  vim.api.nvim_set_hl(0, "NormalFloat", {bg = normal_bg, fg = normal_fg})

  -- Set the FloatBorder highlight group to use the same background and a different border color
  vim.api.nvim_set_hl(0, "FloatBorder", {bg = normal_bg, fg = normal_fg})  -- Example uses same colors for simplicity
  local preview = vim.o.columns > 160
  local buf = vim.api.nvim_create_buf(false, true)
  local preview_buf = vim.api.nvim_create_buf(true, true)
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
  local colorschemes = get_colorschemes()
  local modes = {"dark bg", "light bg"}
  local main_win_content = {}

  -- Append modes to main_win_content
  for _, value in ipairs(modes) do
    table.insert(main_win_content, value)
  end

  -- Append colorschemes to main_win_content
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

    local example_code = {
      "-- This is an example lua code file to preview the scheme",
      "local function hello_world()",
      "  print('Hello, World!')",
      "end",
      "hello_world()"
    }

    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, true, example_code)

    vim.api.nvim_buf_set_option(preview_buf, 'modifiable', false)

    local lines = vim.api.nvim_buf_get_lines(preview_buf, 0, -1, false)
    for i = 0, #lines do
      vim.api.nvim_buf_add_highlight(preview_buf, -1, "Normal", i, 0, -1)
    end
    local empty_lines = {}
    for _ = 1, height - #example_code do
      table.insert(empty_lines, "")
    end
    vim.api.nvim_buf_set_lines(buf, #example_code, -1, false, empty_lines)
  end

  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  set_keymap(buf, "<CR>", function()
    apply_colorscheme(main_win_content, true, window, preview_win)
  end)

  set_keymap(buf, "p", function()
    apply_colorscheme(main_win_content, false, window, preview_win)
  end)

  set_keymap(preview_buf, "<esc>", function()
    close_all(window, preview_win)
  end)

  set_keymap(preview_buf, "q", function()
    close_all(window, preview_win)
  end)


  set_keymap(buf, "<esc>", function()
    close_all(window, preview_win)
  end)

  set_keymap(buf, "q", function()
    close_all(window, preview_win)
  end)
end

WINDOW.register_commands = function()
  vim.api.nvim_create_user_command('Wardrobe', WINDOW.open_window, {})
end

WINDOW.register_keymaps = function()
  vim.api.nvim_set_keymap('n', '<leader>th', "<cmd>:Wardrobe<CR>", {})
end

WINDOW.register_theme = function()
  local theme = WINDOW.load_theme()

  if theme then
    vim_colorscheme(theme)
  end
end

return WINDOW
