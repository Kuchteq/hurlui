local get_win_base = require("panels.get_win_base")

return {
    win = get_win_base(),
    receive_output = function(self, output_path, status_response)
        local runner = require("tabs.runner")
        local editor_request_title = require("panels.editor").current_request_title
        runner:enter()
        if output_path then
            vim.api.nvim_win_call(self.win.id, function ()
                vim.cmd.edit(output_path) -- fetch the given file and create a buffer for it
            end)
            -- self.win:set_buf(output_buffer_id);
            api.nvim_win_set_option(self.win.id, "statusline", "%= " .. editor_request_title .. " at %t %=")
        else
            -- self.win:set_buf(self.blank_buffer);
            api.nvim_win_set_option(self.win.id, "statusline", "%= No history here %=")
        end

        local stopwatch = require("tabs.runner").stopwatch
        local time_status = ""
        if stopwatch.start_time then
            time_status = "in " .. stopwatch:get_elapsed() .. " ms "
            stopwatch:stop_display()
        end
        if status_response ~= nil then
            if string.find(status_response, "error") then
                runner.status:update("%#HttpErrorFill#" .. status_response .. " " .. time_status)
            else
                runner.status:update("%#HttpSuccessFill#" .. status_response .. " " .. time_status)
            end
        else
            runner.status:update("")
        end
    end,
    blank_buffer = api.nvim_create_buf(false, true)
}
