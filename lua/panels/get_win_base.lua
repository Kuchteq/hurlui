--- Base function for obtaining a base panel window.
return function()
    return {
        id = nil,
        close = function(self)
            api.nvim_win_close(self.id, true)
        end,
        set_width = function(self, width)
            api.nvim_win_set_width(self.id, math.floor(width))
        end,
        set_focus = function(self)
            api.nvim_set_current_win(self.id)
        end,
        set_buf = function(self, buffer_id)
            api.nvim_win_set_buf(self.id, buffer_id);
        end,
        get_buf = function(self) -- get the buffer id that that window holds
            return api.nvim_win_get_buf(self.id)
        end,
        get_file_path = function(self)
            return api.nvim_buf_get_name(api.nvim_win_get_buf(self.id))
        end,
        set_status = function(self, text)
            api.nvim_win_set_option(self.id, "statusline", text)
        end
    }
end
