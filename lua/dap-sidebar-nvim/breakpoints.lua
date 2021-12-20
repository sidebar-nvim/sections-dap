local Loclist = require("sidebar-nvim.components.loclist")
local base_config = require("sidebar-nvim.config")
local Debouncer = require("sidebar-nvim.debouncer")
local breakpoints = require("dap.breakpoints")

local loclist = Loclist:new({
    highlights = {
        group = "SidebarNvimDapBreakpointFileName",
        group_count = "SidebarNvimDapBreakpointTotalNumber",
    },
})

local function update_breakpoints()
    loclist:clear()

    local items = {}
    local breakpoints_by_buf = breakpoints.get()
    for buf, buf_bps in pairs(breakpoints_by_buf) do
        for _, bp in ipairs(buf_bps) do
            local filename = vim.fn.bufname(buf)

            local line_text = vim.api.nvim_buf_get_lines(buf, bp.line - 1, bp.line, false)
            if #line_text < 1 then
                line_text = filename
            else
                line_text = line_text[1]
                line_text = line_text:gsub("^%s*(.-)%s*$", "%1")
            end

            table.insert(items, {
                group = vim.fn.fnamemodify(filename, ":t"),
                lnum = bp.line,
                col = 0,
                left = {
                    { text = bp.line, hl = "SidebarNvimDapBreakpointLineNumber" },
                    { text = ": " },
                    { text = line_text, hl = "SidebarNvimDapBreakpointText" },
                },
                filepath = filename,
            })
        end
    end

    local previous_state = vim.tbl_map(function(group)
        return group.is_closed
    end, loclist.groups)

    loclist:set_items(items, { remove_groups = true })
    loclist:close_all_groups()

    for group_name, is_closed in pairs(previous_state) do
        if loclist.groups[group_name] ~= nil then
            loclist.groups[group_name].is_closed = is_closed
        end
    end
end

local update_breakpoints_debounced = Debouncer:new(vim.schedule_wrap(update_breakpoints), 1000)

return {
    title = "Dap Breakpoints",
    icon = function()
        local config = base_config.dap or {}
        config = config.breakpoints or {}

        return config.icon or ""
    end,
    draw = function(ctx)
        update_breakpoints_debounced:call()

        local lines = {}
        local hl = {}

        loclist:draw(ctx, lines, hl)

        if #lines == 0 then
            lines = { "<no breakpoints>" }
        end

        return { lines = lines, hl = hl }
    end,
    highlights = {
        -- { MyHLGroup = { gui=<color>, fg=<color>, bg=<color> } }
        groups = {},
        -- { MyHLGroupLink = <string> }
        links = {
            SidebarNvimDapBreakpointFileName = "Label",
            SidebarNvimDapBreakpointTotalNumber = "Normal",
            SidebarNvimDapBreakpointText = "Normal",
            SidebarNvimDapBreakpointLineNumber = "LineNr",
        },
    },
    bindings = {
        ["e"] = function(line)
            local location = loclist:get_location_at(line)
            if location == nil then
                return
            end
            vim.cmd("wincmd p")
            vim.cmd("e " .. location.filepath)
        end,
    },
}
