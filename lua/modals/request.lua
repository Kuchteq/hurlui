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
            local title = self.blueprint.title .. picker_panel:get_relative_path("") .. " >";
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
        vim.cmd.startinsert()
    end,
    hide = function(self)
        api.nvim_win_hide(self.name.win_id)
        -- api.nvim_win_hide(self.boot.win_id)
    end,
    create = function(self)
        local name = api.nvim_get_current_line()
        api.nvim_del_current_line();
        self:hide();
        require("panels.picker"):add_request(name)

    end,
    cancel = function(self)
        api.nvim_del_current_line();
        self:hide();
    end
}
