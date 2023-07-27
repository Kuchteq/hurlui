local u = require('utils')

return {
    current_tab = 1,
    _boiler_line_prepare = function(self, num)
        return '%' .. num .. 'T' .. (num == self.current_tab and '%#TabLineSel# ' or '%#TabLine# ')
    end,
    urgent_status = nil,
    get_line = function(self)
        local env_tab = require("tabs.env")
        local runner_tab = require("tabs.runner")
        -- Runner always has the tabId of 1 and env page 2
        self.current_tab = vim.fn.tabpagenr()
        -- tab_info is essentially what is displayed on the left
        local tab_info = self:_boiler_line_prepare(1) .. "Runner ";
        tab_info = tab_info .. self:_boiler_line_prepare(2) .. env_tab:get_tabline_name() .. " %#TabLineFill#%=";      -- %= gives the alignment to right
        local env_info = env_tab.selected and "%#EnvBarFill# env: " .. u.get_file_name(env_tab.selected) .. " " or ''; -- Env info expects path
        return tab_info .. (self.urgent_status and self.urgent_status
            or (self.current_tab == 1 and runner_tab.status.text or env_tab.status.text) .. env_info);
    end,
    shift = function(self)
        local env_tab = require("tabs.env")
        vim.cmd.tabNext()
        env_tab:enter()
        self.current_tab = vim.fn.tabpagenr();
        self:redraw_line()
    end,
    redraw_line = function()
        vim.cmd.redrawtabline()
    end
}
