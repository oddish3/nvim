local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

-- Function to get directory listing for paths
local function get_directories()
    -- Static paths to always include
    local static_paths = {
        "/Users/user/repos/quartz/content/",
        "/Users/user/repos/quartz",
    }
    
    -- Parent directories to search within
    local search_parents = {
        "/Users/user/repos/private",
        "/Users/user/repos/public",
        "/Users/user/.config"
    }
    
    -- Initialize results with static paths
    local results = {}
    for _, path in ipairs(static_paths) do
        table.insert(results, path)
    end
    
    -- Add subdirectories from parent directories
    for _, parent in ipairs(search_parents) do
        local handle = io.popen('find "' .. parent .. '" -mindepth 1 -maxdepth 1 -type d 2>/dev/null')
        if handle then
            for dir in handle:lines() do
                table.insert(results, dir)
            end
            handle:close()
        end
    end
    
    return results
end

-- Create the telescope picker
local function smart_cd(opts)
    opts = opts or {}
    
    pickers.new(opts, {
        prompt_title = "Smart Directory Navigation",
        finder = finders.new_table {
            results = get_directories(),
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                -- Change directory to selection
                vim.cmd('cd ' .. selection[1])
            end)
            return true
        end,
    }):find()
end

-- Return the function for use in your config
return {
    smart_cd = smart_cd
}
