function get_buf_name_by_win_in(window)
    return vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(window))
end

function get_file_name(file)
      return file:match("^.+/(.+)$")
end

function contains_substring_in_table(tbl, substring)
    for _, str in ipairs(tbl) do
        if string.find(str, substring) then
            return str
        end
    end
end

function first_not_present(tbl, substring)
    for _, str in ipairs(tbl) do
        if not string.find(str, substring) then
            return str
        end
    end
end
