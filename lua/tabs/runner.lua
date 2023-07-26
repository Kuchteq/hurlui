local u = require('utils')
local picker_panel = require("panels.picker")
local editor_panel = require("panels.editor")
local output_panel = require("panels.output")
local tabs_controller = require("tabs.controller")
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
                output_panel.win:set_width(nvim_width * 0.30)
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
        output_panel.win:close()
        editor_panel.win:set_focus()
        vim.cmd("belowright split output")
        output_panel.win.id = api.nvim_get_current_win() -- keep win_id up to date
        editor_panel.win.set_focus()
    end,
    from_smaller_layout = function()
        output_panel.win:close()
        editor_panel.win:set_focus()
        vim.cmd("vsplit output")
        output_panel.win.id = api.nvim_get_current_win();
        output_panel.win:set_focus();
    end,
    run_hurl = function(self)
        api.nvim_command('silent! update')
        require("plenary.async")
        local Job = require 'plenary.job'
        self.start_request_time = vim.loop.new_timer()
        local hurl_file_path = editor_panel.win:get_file_path()
        local appended_env_path = env_tab.selected and env_tab.selected or "";
        Job:new({
            command = 'executer',
            args = { hurl_file_path, appended_env_path },
        }):start()
        self.stopwatch:start_display()
        self.stopwatch.start_time = vim.loop.now()
    end,
    stopwatch = {
        start_time = nil,
        display_timer = vim.loop.new_timer(),
        get_elapsed = function (self)
            return (vim.loop.now() - self.start_time)
        end,
        start_display = function(self)
            self.display_timer:start(0, 100, vim.schedule_wrap(function()
                local elapsed_time = self:get_elapsed()
                output_panel.win:set_status("%= Elapsed time: " .. elapsed_time .. " ms%=")
            end))
        end,
        stop_display = function(self)
            self.display_timer:stop()
            self.start_time = nil
        end
    },
    enter = function(self)
        if not self.inited then
            vim.o.splitright = true;
            vim.cmd.vsplit()
            editor_panel.win.id = api.nvim_get_current_win();
            vim.cmd.vsplit()
            output_panel.win.id = api.nvim_get_current_win();
            --            output_panel.win:set_buf(blank_buf_id)
            --           api.nvim_buf_set_name(blank_buf_id, "output");

            -- KEYBINDINGS
            vim.keymap.set({ "n", "t" }, "<C-h>", "<C-w>h")
            vim.keymap.set({ "n", "t" }, "<C-j>", "<C-w>j")
            vim.keymap.set({ "n", "t" }, "<C-k>", "<C-w>k")
            vim.keymap.set({ "n", "t" }, "<C-l>", "<C-w>l")

            vim.keymap.set("n", "<F1>", function() picker_panel.win:set_focus() end)
            vim.keymap.set({ "t", "n" }, "<F2>", function() editor_panel.win:set_focus() end)
            vim.keymap.set({ "t", "n" }, "<F3>", function() output_panel.win:set_focus() end)
            vim.keymap.set("n", "<S-enter>", function()
                if tabs_controller.current_tab == 2 then
                    env_tab.alternator = api.nvim_buf_get_name(0);
                    --api. = "grzyb %f %=" -- Center the bottom status line
                end
            end);
            vim.keymap.set("n", "<leader>a", function()
                env_tab:alternate();
            end);

            vim.keymap.set("n", "<enter>", function()
                if tabs_controller.current_tab == 1 then
                    self:run_hurl();
                else
                    env_tab:select(api.nvim_buf_get_name(0));
                    env_tab:buf_labels_refresh();
                end
            end, { silent = true });
            vim.keymap.set({ "n", "t" }, "<Tab>", function() tabs_controller:shift() end);
            -- unfortunately these need to be wrapped with anonymous(anoyingmous)
            -- functions because we are accessing self inside the function
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
