local u = require('utils')
local editor_panel = require("panels.editor")
local picker_panel = require("panels.picker")

return {
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
            local title = self.blueprint.title .. picker_panel:get_relative_path("") .. ">";
            return vim.tbl_extend("force", self.blueprint, { col = u.get_centered_col(self.blueprint.width), row = u.get_centered_row(self.blueprint.height), title = title })
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
            return vim.tbl_extend("force", self.blueprint, { col = u.get_centered_col(self.blueprint.width), row = u.get_centered_row(self.blueprint.height) })
        end
    },
    show = function(self)
        if not self.name.buf_id then
            self.name.buf_id = api.nvim_create_buf(true, true)
            vim.keymap.set("i", "<enter>", function() self:create() end, { buffer = self.name.buf_id })
            vim.keymap.set({ "n", "i" }, "<c-c>", function() self:cancel() end, { buffer = self.name.buf_id })
        end
        self.name.win_id = api.nvim_open_win(self.name.buf_id, true, self.name:get_build())
        -- self.draw_window(self.boot, false)
    end,
    hide = function(self)
        api.nvim_win_hide(self.name.win_id)
        -- api.nvim_win_hide(self.boot.win_id)
    end,
    create = function(self)
        local new_request_path = api.nvim_get_current_line() .. ".hurl"
        api.nvim_del_current_line();
        local file, err = io.open(picker_panel:get_relative_path(new_request_path), "w")
        if not file then
            -- If there was an error opening the file, handle the error
            print("Error creating the file: " .. err)
        else
            file:close()
            self:hide();
            editor_panel:receiveEditor(new_request_path)
            picker_panel:fetch_items()
            picker_panel:draw()
        end
    end,
    cancel = function(self)
        api.nvim_del_current_line();
        self:hide();
    end
}
