local Loclist = require("sidebar-nvim.components.loclist")
local Debouncer = require("sidebar-nvim.debouncer")
local breakpoints = require("dap.breakpoints")

local loclist = Loclist:new({
    highlights = {
        group = "SidebarNvimDapBreakpointFileName",
        group_count = "SidebarNvimDapBreakpointTotalNumber",
        item_text = "SidebarNvimDapBreakpointText",
        item_lnum = "SidebarNvimDapBreakpointLineNumber",
        item_col = "SidebarNvimDapBreakpointColNumber",
    },
})

local function update_breakpoints()
    loclist:clear()

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

            loclist:add_item({
                group = vim.fn.fnamemodify(filename, ":t"),
                lnum = bp.line,
                col = 0,
                text = line_text,
                filepath = filename,
            })
        end
    end
end

local update_breakpoints_debounced = Debouncer:new(vim.schedule_wrap(update_breakpoints), 1000)

return {
    title = "Dap Breakpoints",
    icon = "🔎",
    draw = function(ctx)
        local lines = {}
        local hl = {}

        update_breakpoints_debounced:call()

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
            SidebarNvimDapBreakpointColNumber = "LineNr",
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
