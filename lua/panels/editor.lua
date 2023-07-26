local u = require('utils')
local get_win_base = require("panels.get_win_base")

return {
    win = get_win_base(),
    current_request_title = nil,
    receiveEditor = function(self, requestFilePath)
        require("tabs.runner"):enter()
        self.win:set_focus();
        vim.cmd.edit(requestFilePath);
        self.current_request_title = u.trunc_extension(vim.fn.expand('%:~:.'))
        local potential_output_place = OUTPUT_BASE .. "/" .. self.current_request_title;
        api.nvim_win_set_option(self.win.id, "statusline", "%= Editor — " .. self.current_request_title .. "%=")
        local last_output = vim.fn.trim(vim.fn.system("[ -d '".. potential_output_place .. "' ] && " .. "ls -t '".. potential_output_place .."' | head -n1"))
        require("panels.output"):receive_output(last_output ~= "" and "".. potential_output_place .. "/" .. last_output .. "",nil)
    end,
}
