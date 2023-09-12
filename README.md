## TODO

This fork allows for bi-directional search (e.g., allowing pressing `f` or `t` to search the target in both directions, i.e., left and right at the same time. Ref: [Example: bidirectional and all-windows search](https://github.com/ggandor/leap.nvim#calling-leap-with-custom-arguments))

This plugin extends the capability of **find**, **till** and **text manipulation** commands.

## ✨ Features

- supports prefix: you can use this to not let this plugin hijack the default finding commands.
- extends the find characters limit to `2` characters form `1`.
- adds support for yank/delete/change(y/d/c) commands(same behaviour like finding
  commands).
- Repeat the last pattern using `;` and `,` commands.
- Accepts count before commands.
- Adds movements to navigate through the matches. Two type of movements are
  supported:
  - **leap**: this movement is inspired from [leap.nvim](https://github.com/ggandor/leap.nvim),
    this movement lets you pick the match by picking virtual text symbol assigned to it.
- Lets you ignore certain characters. Using this feature you can use default `1`
  character search for certain characters like punctuations(`{`,`(`,`,`, etc).

Text Manipulation(yank/delete/change) command's are invoked, only if the second
key after y/d/c is a finding command. That means it won't hijack the movements
like `{c|d|y}w`, `{c|d|y}e`, etc.

🔥 This Plugins Effects the following commands:

> If you enable prefix key then it will be `prefix{key}`. Which won't effect
> these keys instead you would have to specify prefix key before any of these keys.

```
f|F (find commands)
t|T (till commands)
;|, (repat last pattern commands)
c{t|T|f|f} (change command)
d{t|T|f|f} (delete command)
y{t|T|f|f} (yank command)
```

After pressing any of these commands, now you have to type `2` characters rather than `1`
to go to next match.
You can change this behaviour by changing the `input_length`.

## Commands

There are three commands available.

- FindExtenderDisable
- FindExtenderEnable
- FindExtenderToggle

## 🚀 Usage

TODO: Add demos

### Finding

##### f command

<img alt="f command" src="https://github.com/TheSafdarAwan/assets/blob/main/find-extender.nvim/fir.gif">

##### F command

<img alt="F command" src="https://github.com/TheSafdarAwan/assets/blob/main/find-extender.nvim/backwards_Fir.gif">

##### d command

<img alt="d command" src="https://github.com/TheSafdarAwan/assets/blob/main/find-extender.nvim/dtir.gif">

#### Movmenets

#### Leap

<img alt="leap movement" src="https://github.com/TheSafdarAwan/assets/blob/main/find-extender.nvim/movements-leap.gif">

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
  ---@field prefix table if you don't want this plugin to hijack the default
  --- finding commands use a prefix to use this plugin.
  prefix = {
    key = "g",
    enable = false,
  },
  ---@field input_length number how much characters should we take input for
  --- default is `2` you can change it to `1`.
  input_length = 2,
  ---@field ignore_case boolean whether to ignore case or not when searching
  ignore_case = false,
  movements = {
    ---@field min_matches number minimum number of matches required after which
    min_matches = 1,
    ---@field highlight_match table highlights the match
    highlight_match = { fg = "#c0caf5", bg = "#545c7e" },
    ---@field leap table pick match, with virtual text symbol for that match.
    leap = {
      enable = true,
      ---@field symbols string virtual text symbols, that represent matches
      symbols = "abcdefgh",
    },
  },
  ---@field no_wait table don't wait for second char if one of these is the first
  --- char, very helpful if you don't want to enter 2 chars if the first one
  --- is a punctuation.
  no_wait = {
    "}",
    "{",
    "[",
    "]",
    "(",
    ")",
  },
  ---@field keymaps table
  keymaps = {
    ---@field finding table finding keys config
    finding = {
      ---@field modes string modes in which the finding keys should be added.
      modes = "nv",
      ---@field till table table of till keys backward and forward
      till = { "T", "t" },
      ---@field find table table of find keys backward and forward
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
    ---@field hl_group string highlight the yanked area
    hl = { bg = "#565f89" },
  },
})
```

## ⚙️ Configuration

### prefix

If you don't like this plugin hijacking the default finding commands. Then you
can enable **prefix** key.

Use **prefix** key same as `<leader>` key to activate the finding Commands.

Although i wouldn't recommend this because this plugin was developed to
compliment default finding commands. And using this instead of default find
command's makes you more efficient in movement. But its up to you to decide.

> NOTE: using `<leader>` or `<localleader>` won't work use the key like
> `<space>`, if that's your leader.

```lua
---@field prefix table if you don't want this plugin to hijack the default
--- finding commands use a prefix to use this plugin.
prefix = {
  key = "g",
  enable = false,
},
```

### ignore case

You can ignore case of your search by setting this to `true`

```lua
---@field ignore_case boolean whether to ignore case or not when searching
ignore_case = false,
```

### movements

Movements allow you to move through matches.
This plugin allows two types of movements.

1. Leap like movement, by picking match like [leap.nvim](https://github.com/ggandor/leap.nvim).

```lua
movements = {
  ---@field min_matches number minimum number of matches required after which
  min_matches = 1,
  ---@field highlight_match table highlights the match
  highlight_match = { fg = "#c0caf5", bg = "#545c7e" },
  ---@field leap table pick match, with virtual text symbol for that match.
  leap = {
    enable = true,
    ---@field symbols string virtual text symbols, that represent matches
    symbols = "abcdefgh",
  },
},
```

##### Matches highlighting

If there are multiple matches, then the matches will be highlighted to give you
map of where all the match positions are. You can change the default highlighting
colors using the `highlight_match` table.

This table accepts all the options you can specify to the `nvim_set_hl`.

```lua
---@field highlight_match table highlights the match
highlight_match = { fg = "#c0caf5", bg = "#545c7e" },
```

### `no_wait`

Don't for second char if the first one is present in this table.

```lua
---@field no_wait table don't wait for second char if one of these is the first
--- char, very helpful if you don't wait to enter 2 chars if the first one
--- is a punctuation.
no_wait = {
  "}",
  "{",
  "[",
  "]",
  "(",
  ")",
  ",",
},

```

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

Keys related to finding text. Remove any of the key you want to disable.
modes is a string with the modes name initials.

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
  -- highlight the yanked text
  hl = { bg = "#565f89" },
}
```

### Highlight Groups

- FEVirtualText
- FECurrentMatchCursor
- FEHighlightOnYank

### Related Plugins

👉 Written in lua

- [leap.nvim](https://github.com/ggandor/leap.nvim),
- [lightspeed.nvim](https://github.com/ggandor/lightspeed.nvim)
- [flit.nvim](https://github.com/ggandor/flit.nvim/)

👉 Written in vimscript

- [vim-easymotion](https://github.com/easymotion/vim-easymotion)
- [vim-sneak](https://github.com/justinmk/vim-sneak)
- [clever-f.vim](https://github.com/rhysd/clever-f.vim)
