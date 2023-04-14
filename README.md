## Description

This Plugin extend's the capability of find, till and text manipulation(yank/delete/change)
command's in nvim. With the help of this Plugin you can find multiple characters rather than
one at a time.

🔥 This Plugins Effects the following commands:

    f|F (find commands)
    t|T (till commands)
    ;|, (repat last pattern commands)
    c{t|T|f|f} (change command)
    d{t|T|f|f} (delete command)
    y{t|T|f|f} (yank command)

By default after pressing any of these commands now you have to type two
characters(or more you can specify characters length) rather than One to
go to next position.

## ✨ Features

- adds capability to find `2` characters rather then `1`.
- yank/delete/change(y/d/c) text same as finding.
- highlight the yanked area.
- count is also accepted.
- highlight the matches, like [leap.nvim](https://github.com/ggandor/leap.nvim).

## 🚀 Usage

I have only provided demos for find and delete commands y,c,t,y commands take characters
input same as these.

#### find forward

<img alt="f command" src="https://github.com/TheSafdarAwan/assets/blob/main/find-extender.nvim/fir.gif">

#### find backwards

<img alt="F command" src="https://github.com/TheSafdarAwan/assets/blob/main/find-extender.nvim/backwards_Fir.gif">

#### delete

<img alt="d command" src="https://github.com/TheSafdarAwan/assets/blob/main/find-extender.nvim/dtir.gif">

## 📦 Installation

Install with your preferred package manager:

[vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'TheSafdarAwan/find-extender.nvim'
```

[packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "TheSafdarAwan/find-extender.nvim",
    config = function()
        -- configuration here
    end,
}
```

[lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    lazy = false,
    "TheSafdarAwan/find-extender.nvim",
    config = function()
        -- configuration here
    end,
}
```

## Setup

```lua
require("find-extender").setup({
    ---@field highlight_matches table controls the highlighting of the pattern matches
    highlight_matches = {
        ---@field min_matches number minimum matches, if number of matches exceeds this amount
        --- then highlight the matches
        min_matches = 2,
        ---@field hl table highlight options for the Virtual text see :h nvim_set_hl
        hl = { fg = "#c0caf5", bg = "#545c7e" },
    },
    ---@field keymaps table information for keymaps.
    keymaps = {
        ---@field finding table finding keys config
        finding = {
            ---@field modes string modes in which the finding keys should be added.
            modes = "nv",
            ---@field till table table of till keys backward and forward both by default.
            till = { "T", "t" },
            ---@field find table table of find keys backward and forward both by default.
            find = { "F", "f" },
        },
        ---@field text_manipulation table information about text manipulation keys including yank/delete/change.
        text_manipulation = {
            ---@field yank table keys related to finding yanking area of text in a line.
            yank = { "f", "F", "t", "T" },
            ---@field delete table keys related to finding deleting area of text in a line.
            delete = { "f", "F", "t", "T" },
            ---@field change table keys related to finding changing area of text in a line.
            change = { "f", "F", "t", "T" },
        },
    },
    ---@field highlight_on_yank table highlight the yanked area
    highlight_on_yank = {
        ---@field enable boolean to enable the highlight_on_yank
        enable = true,
        ---@field timeout number timeout for the yank highlight
        timeout = 40,
        ---@field hl_group string highlight groups for highlighting the yanked area
        hl_group = "IncSearch",
    },
})
```

## Commands

There are three commands available.

- FindExtenderDisable
- FindExtenderEnable
- FindExtenderToggle

## ⚙️ Configuration

### ⌨ keymaps

Keymaps are exposed to user, if any key you want to remove just remove it from the
table.

```lua
keymaps = {
    ---@field finding table finding keys config
    finding = {
        ---@field modes string modes in which the finding keys should be added.
        modes = "nv",
        ---@field till table table of till keys backward and forward both by default.
        till = { "T", "t" },
        ---@field find table table of find keys backward and forward both by default.
        find = { "F", "f" },
    },
    ---@field text_manipulation table information about text manipulation keys including yank/delete/change.
    text_manipulation = {
        ---@field yank table keys related to finding yanking area of text in a line.
        yank = { "f", "F", "t", "T" },
        ---@field delete table keys related to finding deleting area of text in a line.
        delete = { "f", "F", "t", "T" },
        ---@field change table keys related to finding changing area of text in a line.
        change = { "f", "F", "t", "T" },
    },
},
```

### Finding keys

Keys related to finding text. Remove any of the you want to disable.

```lua
---@field finding table finding keys config
finding = {
    ---@field modes string modes in which the finding keys should be added.
    modes = "nv",
    ---@field till table table of till keys backward and forward both by default.
    till = { "T", "t" },
    ---@field find table table of find keys backward and forward both by default.
    find = { "F", "f" },
},
```

modes is a string with the modes name initials.

### text_manipulation

Mappings related to the text manipulation change, delete and yank(copy).
If you want to disable any of these keys then remove key from the table.

```lua
-- to delete, copy or change using t,f or T,F commands
text_manipulation = {
    ---@field yank table keys related to finding yanking area of text in a line.
    yank = { "f", "F", "t", "T" },
    ---@field delete table keys related to finding deleting area of text in a line.
    delete = { "f", "F", "t", "T" },
    ---@field change table keys related to finding changing area of text in a line.
    change = { "f", "F", "t", "T" },
},
```

### highlight on yank

These options control the highlight when yanking text.

```lua
highlight_on_yank = {
    -- whether to highlight the yanked are or not
    enable = true,
    -- time for which the area will be highlighted
    timeout = 40,
    -- highlight group for the yanked are color
    hl_group = "IncSearch",
}
```

### Related Plugins

👉 Written in lua

- [leap.nvim](https://github.com/ggandor/leap.nvim),
- [lightspeed.nvim](https://github.com/ggandor/lightspeed.nvim)
- [flit.nvim](https://github.com/ggandor/flit.nvim/)

👉 Written in vimscript

- [vim-easymotion](https://github.com/easymotion/vim-easymotion)
- [vim-sneak](https://github.com/justinmk/vim-sneak)
- [clever-f.vim](https://github.com/rhysd/clever-f.vim)
