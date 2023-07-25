diricon = "  "
fileicon = "|"

local create_item = function(type, name)
    local method
    if type == "file" then
        local firstLine = io.open(Picker:get_relative_path(name)):read();
        method = firstLine and vim.split(firstLine, " ")[1] or "Empty";
    end
    return {
        type = type,
        name = name,
        method = method,
        get_display = function(self)
            return (self.type == "directory" and diricon or (" " .. self.method .. fileicon)) .. trunc_extension(self.name)
        end
    }
end

Picker = {
    win_id = nil,
    buf_id = nil,
    dir_stack = {}, -- if there are no elements, it means the Picker is at $PWD
    win_close = function(self)
        vim.api.nvim_win_close(self.win_id, true)
    end,
    win_set_focus = function(self)
        --vim.cmd.startinsert();
        vim.api.nvim_set_current_win(self.win_id)
    end,
    win_set_width = function(self, width)
        vim.api.nvim_win_set_width(self.win_id, math.floor(width))
    end,
    init = function(self)
        self.win_id = vim.api.nvim_get_current_win();
        self.buf_id = vim.api.nvim_create_buf(false, true);
        vim.api.nvim_buf_set_name(self.buf_id, "Workspace")
        vim.api.nvim_win_set_buf(self.win_id, self.buf_id)
        vim.api.nvim_win_set_hl_ns(self.win_id, PICKER_NS)
        self:hide_cursor()
        self:fetch_items("./")
        self:draw()

        vim.keymap.set("n", "<enter>", function() self:open_cursor_entity() end, { buffer = true })
        vim.keymap.set("n", "l", function() self:open_cursor_entity() end, { buffer = true })
        vim.keymap.set("n", "h", function() self:pop() end, { buffer = true })
        vim.keymap.set("n", "D", function() self:delete() end, { buffer = true })

        vim.api.nvim_create_autocmd({ "WinEnter" }, {
            callback = function()
                Picker.hide_cursor()
                vim.cmd.stopinsert()
            end,
            group = self.buf_id
        })
        vim.api.nvim_create_autocmd({ "WinLeave" }, {
            callback = function()
                if Picker.win_id == vim.api.nvim_get_current_win() then
                    vim.o.guicursor = initial_cursor_shape;
                end
            end
        })
        Tabs.runner.status:update("")
    end,
    items = {},
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
                    table.insert(self.items, create_item(item_type, name))
                end
            end
        end
    end,
    draw = function(self, focus_object)
        if not focus_object then
            focus_object = Editor.current_request_title
        end
        local parsed_file_titles = {};
        for _, item in ipairs(self.items) do
            table.insert(parsed_file_titles, item:get_display())
        end
        vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, false, parsed_file_titles)
        for i, item in ipairs(self.items) do
            if item.type == "file" then
                vim.api.nvim_buf_add_highlight(Picker.buf_id, PICKER_NS, "Error", i - 1, 0, #item.method + 1)
            end
            if focus_object and item.name == focus_object .. (item.type == "file" and ".hurl" or "") then
                vim.api.nvim_win_set_cursor(self.win_id, { i, 0 })
            end
        end
    end,
    open_cursor_entity = function(self)
        local item = self.items[vim.api.nvim_win_get_cursor(0)[1]] -- the entries align perfectly with the cursor hence we can do it like that
        if item.type == "file" then
            RECEIVE_EDITOR(self:get_relative_path(item.name))
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
    hide_cursor = function()
        if Picker.win_id == vim.api.nvim_get_current_win() then
            vim.o.guicursor = "a:Cursor/lCursor"
        end
    end,
    delete = function(self)
        local item = self.items[vim.api.nvim_win_get_cursor(0)[1]] -- the entries align perfectly with the cursor hence we can do it like that
        if vim.fn.input("Press D again and enter to delete: ") == "D" then
            vim.fn.system("rm -rf '" .. item.name .. "'")
        end
        self:fetch_items()
        self:draw()
    end

}
