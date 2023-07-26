local u = require('utils')
local get_win_base = require("panels.get_win_base")
local env_tab = require("tabs.env")

local diricon = "  "
local fileicon = "|"

return {
    win = get_win_base(),
    dir_stack = {}, -- if there are no elements, it means the Picker is at $PWD
    buf = {
        id = nil
    },
    init = function(self)
        if not self.win.id then
            self.win.id = api.nvim_get_current_win();
            self.buf.id = api.nvim_create_buf(false, true);
            api.nvim_buf_set_name(self.buf.id, "Workspace")
            api.nvim_win_set_buf(self.win.id, self.buf.id)
            api.nvim_win_set_hl_ns(self.win.id, PICKER_NS)
            self:hide_cursor()
            self:fetch_items("./")
            self:draw()

            vim.keymap.set("n", "<enter>", function() self:open_cursor_entity() end, { buffer = true })
            vim.keymap.set("n", "l", function() self:open_cursor_entity() end, { buffer = true })
            vim.keymap.set("n", "h", function() self:pop() end, { buffer = true })
            vim.keymap.set("n", "D", function() self:delete() end, { buffer = true })

            api.nvim_create_autocmd({ "WinEnter" }, {
                callback = function()
                    self:hide_cursor()
                    vim.cmd.stopinsert()
                end,
                group = self.buf.id
            })
            api.nvim_create_autocmd({ "WinLeave" }, {
                callback = function()
                    if self.win.id == api.nvim_get_current_win() then
                        vim.o.guicursor = INITIAL_CURSOR_SHAPE;
                    end
                end
            })

            env_tab:rescan()
            env_tab:set_default_selected()
            require("tabs.runner").status:update("")
        end
    end,
    items = {},
    create_item = function(self, type, name)
        local method
        if type == "file" then
            local firstLine = io.open(self:get_relative_path(name)):read();
            method = firstLine and vim.split(firstLine, " ")[1] or "Empty";
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
        local path = table.concat(self.dir_stack, '/')
        return path .. (#self.dir_stack > 0 and "/" or "") .. item_name
    end,
    fetch_items = function(self, directory)
        local dir_handle = vim.loop.fs_scandir(directory and directory or "./")
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
            focus_object = require("panels.editor").current_request_title
        end
        local parsed_file_titles = {};
        for _, item in ipairs(self.items) do
            table.insert(parsed_file_titles, item:get_display())
        end
        api.nvim_buf_set_lines(self.buf.id, 0, -1, false, parsed_file_titles)
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
            require("panels.editor"):receiveEditor(self:get_relative_path(item.name))
        else
            table.insert(self.dir_stack, item.name);
            self:fetch_items(item.name)
            self:draw()
        end
    end,
    pop = function(self)
        table.remove(self.dir_stack, #self.dir_stack)
        self:fetch_items("./" .. table.concat(self.dir_stack, "/"))
        self:draw()
    end,
    hide_cursor = function(self)
        if self.win.id == api.nvim_get_current_win() then
            vim.o.guicursor = "a:Cursor/lCursor"
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
