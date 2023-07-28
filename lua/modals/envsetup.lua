local call = function()
    vim.ui.input({ prompt = "New env:" }, function(env_name)
        local env_tab = require("tabs.env")
        -- get_relative_path(new_request_path)
        vim.fn.system("mkdir .envs")
        local picker_panel = require("panels.picker")
        local file, err = io.open("./.envs/" .. env_name, "w")
        if not file then
            -- If there was an error opening the file, handle the error
            print("Error creating the file: " .. err)
        else
            file:close()
            if picker_panel.win.id then
                picker_panel:fetch_items()
                picker_panel:draw()
            end
            picker_panel:init()
            env_tab:enter()
        end
    end)
    vim.cmd.startinsert()
end

vim.keymap.set({ "i", "n" }, "<c-s-e>", function()
    if require("panels.picker").win.id then
        call()
    end
end)
