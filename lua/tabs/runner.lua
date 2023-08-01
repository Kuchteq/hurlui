local picker_panel = require("panels.picker")
local editor_panel = require("panels.editor")
local output_panel = require("panels.output")
local env_tab = require("tabs.env")

return {
    inited = false,
    is_smaller = false,
    update_win_size = function(self)
        if self.inited then
            local nvim_width = vim.go.columns;
            if nvim_width >= 80 then -- Choose the larger variant
                if self.is_smaller == true then
                    self.from_smaller_layout()
                    self.is_smaller = false
                end
                picker_panel.win:set_width(nvim_width * 0.22)
                output_panel.win:set_width(nvim_width * 0.35)
            else
                if nvim_width < 80 then -- Choose the smaller variant
                    if self.is_smaller == false then
                        self.to_smaller_layout();
                        self.is_smaller = true;
                    end
                    picker_panel.win:set_width(nvim_width * 0.22)
                    output_panel.win:set_width(nvim_width * 0.78)
                end
            end
        end
    end,
    to_smaller_layout = function()
        local last_buf = output_panel.win:get_buf()
        output_panel.win:close()
        editor_panel.win:set_focus()
        vim.cmd("belowright split output")
        api.nvim_set_current_buf(last_buf)
        output_panel.win.id = api.nvim_get_current_win() -- keep win_id up to date
        editor_panel.win:set_focus()
    end,
    from_smaller_layout = function()
        local last_buf = output_panel.win:get_buf()
        output_panel.win:close()
        editor_panel.win:set_focus()
        vim.cmd("vsplit output")
        output_panel.win.id = api.nvim_get_current_win();
        api.nvim_set_current_buf(last_buf)
        api.nvim_set_current_buf(output_panel.win:get_buf())
        output_panel.win:set_focus();
    end,
    run_hurl = function(self)
        api.nvim_command('silent! update')
        local Job = require('plenary.job')
        self.start_request_time = vim.loop.new_timer()
        local hurl_file_path = editor_panel.win:get_file_path()
        local appended_env_path = env_tab.selected and env_tab.selected or "";
        Job:new({
            command = 'executer',
            args = { hurl_file_path, vim.fn.getcwd(), appended_env_path },
        }):start()
        self.stopwatch.start_time = vim.loop.now()
        self.stopwatch:start_display()
    end,
    stopwatch = {
        start_time = nil,
        display_timer = vim.loop.new_timer(),
        get_elapsed = function(self)
            return vim.loop.now() - self.start_time
        end,
        start_display = function(self)
            self.display_timer:start(0, 100, vim.schedule_wrap(function()
                local elapsed_time = self:get_elapsed()
                output_panel.win:set_status("%= Elapsed time: " .. elapsed_time .. " ms%=")
            end))
        end,
        stop_display = function(self)
            self.display_timer:stop()
        end
    },
    -- We should probably seperate init from enter
    enter = function(self)
        vim.api.nvim_set_current_tabpage(1)
        if not self.inited then
            vim.cmd.vsplit()
            editor_panel.win.id = api.nvim_get_current_win();
            vim.cmd.vsplit()
            output_panel.win.id = api.nvim_get_current_win();

            vim.keymap.set("n", "<F1>", function() picker_panel.win:set_focus() end)
            vim.keymap.set({ "t", "n" }, "<F2>", function() editor_panel.win:set_focus() end)
            vim.keymap.set({ "t", "n" }, "<F3>", function() output_panel.win:set_focus() end)
                        self.inited = true
            self:update_win_size()
        end
    end,
    status = {
        text = "Welcome to hurlui, select a workspace, press <c-n> to initialise one or <c-s-n> to initialize at " .. vim.fn.getcwd() .. "  ",
        update = function(self, incoming)
            self.text = incoming;
        end
    }
}
