local get_centered_row = function(window_width, offset)
    return math.floor((vim.go.lines - window_width) / 2) + (offset and offset or 0);
end
local get_centered_col = function(window_height, offset)
    return math.floor((vim.go.columns - window_height) / 2) + (offset and offset or 0);
end
local draw_window = function(element, enter)
        element.win_id = vim.api.nvim_open_win(element.buf_id, enter, element:get_build())
end

RequestCreator = {
    draw_window = function(element, enter)
        element.win_id = vim.api.nvim_open_win(element.buf_id, enter, element:get_build())
    end,
    name = {
        buf_id = nil,
        win_id = nil, -- This is volatile are usually really volatile
        blueprint = {
            relative = "editor",
            width = 40,
            height = 1,
            border = "rounded",
            style = "minimal",
            title = "< New request at ",
            title_pos = "center"
        },
        get_build = function(self)
            local title = self.blueprint.title .. Picker:get_relative_path("") .. ">";
            return vim.tbl_extend("force", self.blueprint, { col = get_centered_col(self.blueprint.width), row = get_centered_row(self.blueprint.height), title = title })
        end
    },
    boot = {
        buf_id = nil,
        win_id = nil,
        blueprint = {
            relative = "editor",
            width = 40,
            height = 1,
            border = "rounded",
            style = "minimal",
            title = "< Bootstrap options >",
            title_pos = "center"
        },
        get_build = function(self)
            return vim.tbl_extend("force", self.blueprint, { col = get_centered_col(self.blueprint.width), row = get_centered_row(self.blueprint.height) })
        end
    },
    show = function(self)
        if not self.name.buf_id then
            self.name.buf_id = vim.api.nvim_create_buf(true, true)
            vim.keymap.set("i", "<enter>", function() RequestCreator:create() end, { buffer = self.name.buf_id })
            vim.keymap.set({ "n", "i" }, "<c-c>", function() RequestCreator:cancel() end, {buffer= self.name.buf_id})
            self.boot.buf_id = vim.api.nvim_create_buf(false, true)
        end
        --        vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, true, { "You can add content here." })
        draw_window(self.name, true)
        -- self.draw_window(self.boot, false)
        vim.cmd.startinsert()
    end,
    hide = function(self)
        vim.api.nvim_win_hide(self.name.win_id)
        -- vim.api.nvim_win_hide(self.boot.win_id)
    end,
    create = function(self)
        local new_request_path = vim.api.nvim_get_current_line() .. ".hurl"
        vim.api.nvim_del_current_line();
        local file, err = io.open(Picker:get_relative_path(new_request_path), "w")
        if not file then
            -- If there was an error opening the file, handle the error
            print("Error creating the file: " .. err)
        else
            file:close()
            self:hide();
            Editor:receiveEditor(new_request_path)
            Picker:fetch_items()
            Picker:draw()
        end
    end,
    cancel = function(self)
        vim.api.nvim_del_current_line();
        self:hide();
    end
}

vim.keymap.set("n", "<c-n>", function() RequestCreator:show() end)


DirectoryCreator = {
    name = {
        buf_id = nil,
        win_id = nil, -- These values are usually really volatile
        blueprint = {
            relative = "editor",
            width = 40,
            height = 1,
            border = "rounded",
            style = "minimal",
            title = "< New subgroup at ",
            title_pos = "center"
        },
        get_build = function(self)
            local title = self.blueprint.title .. Picker:get_relative_path("") .. ">";
            return vim.tbl_extend("force", self.blueprint, { col = get_centered_col(self.blueprint.width), row = get_centered_row(self.blueprint.height), title = title })
        end
    },
    boot = {
        buf_id = nil,
        win_id = nil,
        blueprint = {
            relative = "editor",
            width = 40,
            height = 1,
            border = "rounded",
            style = "minimal",
            title = "< Subgroup bootstrap options >",
            title_pos = "center"
        },
        get_build = function(self)
            return vim.tbl_extend("force", self.blueprint, { col = get_centered_col(self.blueprint.width), row = get_centered_row(self.blueprint.height) })
        end
    },
    show = function(self)
        if not self.name.buf_id then
            self.name.buf_id = vim.api.nvim_create_buf(true, true)
            vim.keymap.set({"i", "n"}, "<enter>", function() DirectoryCreator:create() end, { buffer = self.name.buf_id })
            vim.keymap.set({ "n", "i" }, "<c-c>", function() DirectoryCreator:cancel() end, {buffer= self.name.buf_id})
            self.boot.buf_id = vim.api.nvim_create_buf(false, true)
        end
        --        vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, true, { "You can add content here." })
        draw_window(self.name, true)
        -- selfdraw_window(self.boot, false)
        vim.cmd.startinsert()
    end,
    hide = function(self)
        vim.api.nvim_win_hide(self.name.win_id)
        -- vim.api.nvim_win_hide(self.boot.win_id)
    end,
    create = function(self)
        local new_dir_path = vim.api.nvim_get_current_line()
        vim.api.nvim_del_current_line();
        vim.fn.system("mkdir '" .. new_dir_path .. "'")
            self:hide();
            Picker:fetch_items()
            Picker:draw(new_dir_path)
    end,
    cancel = function(self)
        vim.api.nvim_del_current_line();
        self:hide();
    end
}

vim.keymap.set("n", "<s-c-D>", function() DirectoryCreator:show() end)
