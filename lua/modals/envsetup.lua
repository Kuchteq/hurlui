return {
    show = function()
        vim.ui.input({ prompt = "New env:" }, function(env_name)
            if env_name then
                local env_tab = require("tabs.env")
                -- get_relative_path(new_request_path)
                vim.fn.system("mkdir .envs")
                env_tab:add(env_name)
            end
        end)
    end

}
