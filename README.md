# Dap Sections for [sidebar.nvim](https://github.com/GustavoKatel/sidebar.nvim)

### Requirements:

- [nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [sidebar.nvim](https://github.com/GustavoKatel/sidebar.nvim)

## Available Sections

### Breakpoints

![screenshot](./docs/screenshot.png)

Show current breakpoints into the sidebar

#### Configuration

```lua
require("sidebar-nvim").setup({
    ...
    sections = {
        "datetime",
        "git",
        "diagnostics",
        require("dap-sidebar-nvim.breakpoints")
    },
    dap = {
        breakpoints = {
            icon = "🔍"
        }
    }
    ...
})
```

## Colors

| Highlight Group | Defaults To |
| --------------- | ----------- |
| *SidebarNvimDapBreakpointFileName* | Label |
| *SidebarNvimDapBreakpointTotalNumber* | Normal |
| *SidebarNvimDapBreakpointText* | Normal |
| *SidebarNvimDapBreakpointLineNumber* | LineNr |

