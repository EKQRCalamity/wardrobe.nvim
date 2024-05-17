local UTILS = {}

UTILS.get_colorschemes = function()
  return vim.fn.getcompletion('', 'color')
end

UTILS.get_selected_colorscheme = function()
    return vim.api.nvim_get_option('colorscheme')
end

UTILS.vim_colorscheme = function(colorscheme)
  vim.cmd('colorscheme ' .. colorscheme)
end

UTILS.vim_background = function(background)
  vim.cmd("set background=" .. background)
end

UTILS.split = function(str, sep)
  local ret = {}

  for s in string.gmatch(str, "([^"..sep.."]+)") do
    table.insert(ret, s)
  end

  return ret
end

-- Define the function in the global scope
_G.update_highlight_groups = function()
  local normal_hl = vim.api.nvim_get_hl_by_name("Normal", true)
  local normal_bg = normal_hl.background or 'none'
  local normal_fg = normal_hl.foreground or 'none'

  vim.api.nvim_set_hl(0, "NormalFloat", {bg = normal_bg, fg = normal_fg})
  vim.api.nvim_set_hl(0, "FloatBorder", {bg = normal_bg, fg = normal_fg})
end


UTILS.set_keymap = function(buf, key, func)
  vim.api.nvim_buf_set_keymap(buf, 'n', key, '', {
    noremap = true,
    silent = true,
    callback = func
  })
end

UTILS.close = function(window)
  if window then
    vim.api.nvim_win_close(window, true)
  end
end

UTILS.close_all = function(window1, window2)
  UTILS.close(window1)
  UTILS.close(window2)
end

UTILS.save_mode = function(mode)
  local config_dir = vim.fn.stdpath("data")
  local config_file = config_dir .. "/wardrobe-nvim-background.chosen"

  vim.fn.writefile({mode}, config_file)
end

UTILS.save_theme = function(colorscheme)
  local config_dir = vim.fn.stdpath('data')
  local config_file = config_dir .. '/wardrobe-nvim-theme.chosen'

  vim.fn.writefile({colorscheme}, config_file)
end

UTILS.load_from_fs = function()
  local config_dir = vim.fn.stdpath("data")
  local theme_config_file = config_dir .. "/wardrobe-nvim-theme.chosen"
  local mode_config_file = config_dir .. "/wardrobe-nvim-background.chosen"

  if vim.fn.filereadable(mode_config_file) == 1 then
    local data = vim.fn.readfile(mode_config_file)
    if #data > 0 then
      UTILS.vim_background(data[1])
    end
  end

  if vim.fn.filereadable(theme_config_file) == 1 then
    local data = vim.fn.readfile(theme_config_file)
    if #data > 0 then
      return data[1]
    end
  end

  return nil
end

return UTILS
