local u = require('utils')
local get_win_base = require("panels.get_win_base")
local env_tab = require("tabs.env")

local diricon = "  "
local fileicon = "|"

return {
        win = get_win_base(),
        workspace_name = "",
        dir_stack = {}, -- if there are no elements, it means the Picker is at $PWD
        get_dir_string = function(self) return table.concat(self.dir_stack, "/") end,
        buf = {
                id = nil
        },
        init = function(self)
                if not self.win.id then
                        api.nvim_set_current_win(api.nvim_list_wins()[1]) -- make sure we are at the initial window first
                        self.win.id = api.nvim_get_current_win();
                        self.buf.id = vim.api.nvim_create_buf(false, true);
                        api.nvim_buf_set_name(self.buf.id, "Workspace")
                        api.nvim_win_set_buf(self.win.id, self.buf.id)
                        api.nvim_win_set_hl_ns(self.win.id, PICKER_NS)
                        api.nvim_buf_set_option(self.buf.id, "modifiable", false)
                        -- restrict keybindings so that the user doesn't get errors on accidental presses
                        vim.keymap.set("n", "a", "", { buffer = true })
                        vim.keymap.set("n", "i", "", { buffer = true })
                        vim.keymap.set("n", "I", "", { buffer = true })
                        vim.keymap.set("n", "A", "", { buffer = true })
                        vim.keymap.set("n", "o", "", { buffer = true })
                        vim.keymap.set("n", "O", "", { buffer = true })
                        self:hide_cursor()
                        self:fetch_items()
                        self:draw()

                        vim.keymap.set("n", "<enter>", function() self:open_cursor_entity() end, { buffer = true })
                        vim.keymap.set("n", "l", function() self:open_cursor_entity() end, { buffer = true })
                        vim.keymap.set("n", "h", function() self:pop() end, { buffer = true })
                        vim.keymap.set("n", "D", function() self:delete() end, { buffer = true })
                        vim.keymap.set("n", "n", function() require("modals.request"):show() end, { buffer = true })

                        api.nvim_create_autocmd({ "WinEnter" }, {
                                callback = function()
                                        vim.cmd.stopinsert()
                                        self:hide_cursor()
                                end,
                                buffer = self.buf.id
                        })
                        api.nvim_create_autocmd({ "WinLeave" }, {
                                callback = function()
                                        if self.win.id == api.nvim_get_current_win() then
                                                vim.o.guicursor = INITIAL_CURSOR_SHAPE;
                                        end
                                end
                        })

                        env_tab:rescan()
                        env_tab:set_defaults()
                        require("tabs.runner").status:update("")
                end
        end,
        items = {},
        create_item = function(self, type, name)
                local method
                if type == "file" then
                        local file = io.open(self:get_relative_path(name))
                        local line;
                        while true do
                                line = file:read("*l");
                                if line == nil then
                                        break
                                end
                                -- ignore comments and empty lines at the begining of the file
                                if line:match("#") == nil and line ~= "" then
                                        break
                                end
                        end
                        method = line and vim.split(line, " ")[1] or "Empty";
                end
                return {
                        type = type,
                        name = name,
                        method = method,
                        get_display = function()
                                return (type == "directory" and diricon or (" " .. method .. fileicon)) .. u.trunc_extension(name)
                        end
                }
        end,
        get_relative_path = function(self, item_name)
                local path = self:get_dir_string()
                return path .. (#self.dir_stack > 0 and "/" or "") .. item_name
        end,
        fetch_items = function(self)
                local dir_handle = vim.loop.fs_scandir(#self.dir_stack > 0 and self:get_dir_string() or "./")
                if dir_handle then
                        self.items = {}
                        while true do
                                local name, item_type = vim.loop.fs_scandir_next(dir_handle)
                                if not name then break end
                                if (item_type == "file" and string.find(name, ".hurl$")) or item_type == "directory" then -- no link handeling for now
                                        table.insert(self.items, self:create_item(item_type, name))
                                end
                        end
                end
        end,
        draw = function(self, focus_object)
                if not focus_object then
                        focus_object = vim.api.nvim_win_call(self.win.id, function() u.trunc_extension(vim.fn.expand('%:t')) end)
                end

                local parsed_file_titles = {};
                for _, item in ipairs(self.items) do
                        table.insert(parsed_file_titles, item:get_display())
                end

                api.nvim_buf_set_option(self.buf.id, "modifiable", true)
                api.nvim_buf_set_lines(self.buf.id, 0, -1, false, parsed_file_titles)
                api.nvim_buf_set_option(self.buf.id, "modifiable", false)
                for i, item in ipairs(self.items) do
                        if item.type == "file" then
                                api.nvim_buf_add_highlight(self.buf.id, PICKER_NS, "Error", i - 1, 0, #item.method + 1)
                        end
                        if focus_object and item.name == focus_object .. (item.type == "file" and ".hurl" or "") then
                                api.nvim_win_set_cursor(self.win.id, { i, 0 })
                        end
                end
        end,
        open_cursor_entity = function(self)
                local item = self.items[api.nvim_win_get_cursor(0)[1]] -- the entries align perfectly with the cursor hence we can do it like that
                if not item then return end

                if item.type == "file" then
                        require("panels.editor"):receive_editor(self:get_relative_path(item.name))
                else
                        table.insert(self.dir_stack, item.name);
                        self:fetch_items(item.name)
                        self:draw()
                end
        end,
        pop = function(self)
                local dir_to_focus = table.remove(self.dir_stack, #self.dir_stack)
                self:fetch_items("./" .. self:get_dir_string())
                self:draw(dir_to_focus)
        end,
        hide_cursor = function(self)
                if self.win.id == api.nvim_get_current_win() then
                        vim.o.guicursor = "a:Cursor/lCursor"
                end
        end,
        --- Adds dir relative to the picker's dir
        add_dir = function(self, name)
                local dir_string = self:get_dir_string()
                local new_dir_path = (dir_string ~= "" and (dir_string .. "/") or "") .. name
                vim.fn.system("mkdir -p '" .. new_dir_path .. "'")
                self:fetch_items()
                self.win:set_focus()
                self:draw(name)
        end,
        --- Adds dir relative to the picker's dir
        add_request = function(self, name)
                local dir_string = self:get_dir_string()
                local new_request_filepath = (dir_string ~= "" and (dir_string .. "/") or "") .. name .. ".hurl"
                local file, err = io.open(new_request_filepath, "w")
                if not file then
                        -- If there was an error opening the file, handle the error
                        print("Error creating the file: " .. err)
                else
                        file:close()
                        require("panels.editor"):receive_editor(new_request_filepath)
                        self:fetch_items()
                        self:draw()
                end
        end,
        delete = function(self)
                local item = self.items[api.nvim_win_get_cursor(0)[1]] -- the entries align perfectly with the cursor hence we can do it like that
                if vim.fn.input("Press D again and enter to delete: ") == "D" then
                        vim.fn.system("rm -rf '" .. item.name .. "'")
                end
                self:fetch_items()
                self:draw()
        end
}
