# assist.nvim

## Enhance Your Neovim Coding with AI

Assist.nvim is a powerful plugin that brings the capabilities of AI code generation to your Neovim editor. By integrating with the aichat tool, it provides intelligent suggestions and streamlines your coding process.

[![asciicast](https://asciinema.org/a/656675.svg)](https://asciinema.org/a/656675)

## Installation

To install assist.nvim, use your preferred plugin manager. If you're using vim-plug, add the following line to your plugin configuration:

```vim
Plug 'donhardman/assist.nvim'
```

## Setup

After installation, configure assist.nvim in your Neovim Lua init file:

```lua
require("assist").setup()
```

**Important:** Make sure you have the [aichat](https://github.com/sigoden/aichat) tool installed and available in your system's PATH. 

## Key Features

*   **AI-Powered Code Generation:** Leverage the power of AI to generate code snippets directly within Neovim.
*   **Customizable Command Binding:** While assist.nvim doesn't come with predefined keybindings, you can easily map the `:Assist` command to your preferred key combination. For example, in Neovim:

```lua
vim.api.nvim_set_keymap('n', '<leader>a', ':Assist ', {noremap = true, silent = true})
```

*   **Context-Aware Suggestions:** Select text or position your cursor, then invoke `:Assist` with your instructions. The plugin analyzes the surrounding code and offers relevant suggestions.
*   **Seamless Workflow Integration:** Generate and insert code directly into your Neovim buffer, eliminating the need to switch between applications.
*   **Increased Productivity:** Automate code generation tasks to save time and effort, allowing you to focus on more complex aspects of your projects.

## Connect with the Developer

Follow Don Hardman on X (formerly Twitter): https://x.com/donhardman88 

## License

    This plugin is released under the MIT License. Copyright (c) 2024 Don Hardman

## Disclaimer

    Assist.nvim is provided "as is" without warranty of any kind, either express or implied. 


