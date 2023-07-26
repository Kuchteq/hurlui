local get_win_base = require("panels.get_win_base")

return function()
    return {
        win = get_win_base(),
        init = function (self)
            self.win.id = api.nvim_get_current_win();
            return self
        end
    }
end
