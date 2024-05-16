# Wardrobe.nvim
And very early stage [neovim](https://github.com/neovim/neovim) plugin for choosing and previewing themes/colorschemes. Themes/Colorschemes can be added hovever wanted, when using a package manager I would suggest to directly download and load them with the package manager.

![Screen Preview](https://github.com/EKQRCalamity/wardrobe.nvim/blob/assets/assets/Screen.png)

### Installation
As it is typical, just install with your favorite package manager, example using lazy:

```lua
{
  {
    "EKQRCalamity/wardrobe.nvim",
    dependencies = {
    "maxmx03/fluoromachine.nvim",
    { "catppuccin/nvim", name="catppuccin" },
    "Yazeed1s/minimal.nvim",
    -- More themes you want to add...
  }
}
```

### Usage
After installation just use it as follows: 

`init.lua`
```lua
local wardrobe = require("wardrobe")
-- For the :Wardrobe command
wardrobe.window.register_commands()
-- For the <leader>th keymap
wardrobe.window.register_keymaps()
-- For loading the previously chosen theme on startup
wardrobe.window.register_theme()
```

### Keybinds

| Keybind    | Function                         | In Window? |
|------------|----------------------------------|------------|
| <leader>th | Open the theme changer window    | No         |
| q          | Close all theme changer windows  | Yes        |
| p          | Preview the theme under cursor   | Yes        |
| \<CR>      | Apply theme under cursor & close | Yes        |
