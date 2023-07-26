return {
    get_buf_name_by_win_in = function(window)
        return api.nvim_buf_get_name(api.nvim_win_get_buf(window))
    end,
    get_file_name = function(file)
        return file:match("^.+/(.+)$")
    end,
    trunc_extension = function(file)
        local without = file:match("(.+)%..+$")
        if without then return without else return file end
        ;
    end,
    contains_substring_in_table = function(tbl, substring)
        for _, str in ipairs(tbl) do
            if string.find(str, substring) then
                return str
            end
        end
    end,
    first_not_present = function(tbl, substring)
        for _, str in ipairs(tbl) do
            if not string.find(str, substring) then
                return str
            end
        end
    end,
    get_centered_row = function(window_width, offset)
        return math.floor((vim.go.lines - window_width) / 2) + (offset and offset or 0);
    end,
    get_centered_col = function(window_height, offset)
        return math.floor((vim.go.columns - window_height) / 2) + (offset and offset or 0);
    end,
    draw_window = function(element, enter)
        element.win_id = api.nvim_open_win(element.buf_id, enter, element:get_build())
    end
}
