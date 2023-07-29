local u = require('utils')
local get_sample_modal = function(title, height, yoffset, zindex)
    local buf_id = api.nvim_create_buf(true, true)
    local blueprint = {
        relative = "editor",
        width = 40,
        height = height,
        border = "rounded",
        style = "minimal",
        title = title,
        title_pos = "center",
        zindex = zindex
    }
    return {
        buf_id = buf_id,
        blueprint = blueprint,
        get_build = function()
            return vim.tbl_extend("force", blueprint, { col = u.get_centered_col(blueprint.width), row = u.get_centered_row(blueprint.height) + yoffset, title = title })
        end
    }
end

local generate_popup = function()
    return {
        sections = {
            first = {
                title = "First"
            },
            second = {
                title = "Second"
            }
        },
        section_win_ids = nil,
        _add_callbacks = function(self, buf_id, enter_message)
            vim.keymap.set({ "i", "n" }, "<enter>", function() self:action() end, { buffer = buf_id })
            vim.keymap.set({ "i", "n" }, "<c-c>", function() api.nvim_set_current_win(1000) end, { buffer = buf_id })
            vim.keymap.set({ "i", "n" }, "<tab>", function() self:cycle() end, { buffer = buf_id })
            if enter_message then
                vim.api.nvim_create_autocmd({ "WinEnter" }, {
                    callback = function()
                        local statuscontrol = require("tabs.controller")
                        statuscontrol.urgent_status = enter_message
                        statuscontrol.redraw_line()
                    end,
                    buffer = buf_id
                })
            end
            vim.api.nvim_create_autocmd({ "WinEnter" }, {
                callback = function()
                    if not vim.tbl_contains(self.section_win_ids, api.nvim_get_current_win()) then
                        self:hide()
                        return true
                    end
                end,
                buffer = buf_id
            })
        end,
        show = function(self)
            if not self.sections.win_id then
                self.sections.first = get_sample_modal(self.sections.first.title, 1, 0, 51)
                self.sections.second = get_sample_modal(self.sections.second.title, 1, 2, 52)
            end
            self.sections.first.win_id = api.nvim_open_win(self.sections.first.buf_id, true, self.sections.first:get_build())
            self.sections.second.win_id = api.nvim_open_win(self.sections.second.buf_id, false, self.sections.second:get_build())
            vim.api.nvim_buf_set_lines(self.sections.second.buf_id, 0, 1, true, { vim.fn.getcwd() })
            self.section_win_ids = { self.sections.first.win_id, self.sections.second.win_id }
            self:_add_callbacks()
        end,
        cycle = function(self)
            local currently_on = api.nvim_get_current_win()
            for i = 1, #self.section_win_ids do
                if currently_on == self.section_win_ids[i] and i < #self.section_win_ids then
                    vim.api.nvim_set_current_win(self.section_win_ids[i + 1])
                    return true
                elseif currently_on == self.section_win_ids[i] then
                    vim.api.nvim_set_current_win(self.section_win_ids[1])
                    return true
                end
            end
        end,
        hide = function(self)
            api.nvim_win_hide(self.sections.first.win_id)
            api.nvim_win_hide(self.sections.second.win_id)
        end,
        action = function(self)
            local name = vim.api.nvim_buf_get_lines(self.sections.first.buf_id, 0, 1, true)[1]
            local second_section = vim.api.nvim_buf_get_lines(self.sections.second.buf_id, 0, 1, true)[1]
            require("workspaces").add(name, second_section)
            require("workspaces").open(name)
        end,
        cancel = function(self)
            api.nvim_del_current_line();
            self:hide();
        end
    }
end

return vim.tbl_extend("keep",{
    sections = {
        first = {
            title = "New env"
        },
        second = {
            title = "Options"
        }
    }
},generate_popup())
