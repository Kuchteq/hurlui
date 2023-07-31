return {
    get_buf_name_by_win_id = function(window)
        return api.nvim_buf_get_name(api.nvim_win_get_buf(window))
    end,
    get_file_name = function(file)
        if file then
            return file:match("^.+/(.+)$")
        end
    end,
    trunc_extension = function(file)
        local without = file:match("(.+)%..+$")
        if without then return without else return file end
        ;
    end,
    tbl_first_string_with_substring = function(tbl, substring)
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
    end,
    tabpage_get_bufs_names = function(tabpage)
        return vim.tbl_map(function(val) return api.nvim_buf_get_name(api.nvim_win_get_buf(val)) end, api.nvim_tabpage_list_wins(tabpage))
    end,
    set_win_focus_by_buf_name = function(name)
        for _, win_id in ipairs(api.nvim_list_wins()) do
            if require("utils").get_buf_name_by_win_id(win_id) == name then
                api.nvim_set_current_win(win_id)
            end
        end
    end

}
