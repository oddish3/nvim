-- lua/config/quartz_terminals.lua
local M = {}
local Terminal = require("toggleterm.terminal").Terminal

-- Path to the optimize build script
local script_path = "/Users/user/repos/scripts/optimize-build.sh"

-- Track if commands are running
M.preview_running = false
M.build_running = false

-- Base configuration for all terminals
local base_config = {
  dir = "git_dir",
  close_on_exit = true,
  hidden = true,
  direction = "horizontal",
  size = 15,
  auto_scroll = true,
  persist_size = true,
}

-- Create terminal instances with specific configurations
local preview_term = Terminal:new(vim.tbl_extend("force", base_config, {
  display_name = "Quartz Preview",
}))

local build_term = Terminal:new(vim.tbl_extend("force", base_config, {
  display_name = "Quartz Build",
}))

-- Function to toggle terminal and manage command state
function M.toggle_quartz_terminal(term, cmd, state_var)
  return function()
    local is_running = M[state_var]
    
    -- If terminal isn't open yet, or we need to start a command
    if not term:is_open() or not is_running then
      term:toggle()
      
      -- Only start the command if not already running
      if not is_running then
        vim.defer_fn(function()
          term:send(cmd)
          M[state_var] = true
        end, 100) -- Small delay to ensure terminal is ready
      end
      
      vim.cmd("startinsert!")
    -- If terminal is already open, just toggle it closed
    else
      term:toggle()
    end
  end
end

-- Function to kill the running command and reset state
function M.kill_quartz_command(term, state_var)
  return function()
    if term:is_open() and M[state_var] then
      term:send("\x03") -- Send Ctrl+C
      M[state_var] = false
      vim.notify("Quartz command stopped", vim.log.levels.INFO)
    end
  end
end

-- Set keymaps
vim.keymap.set({"n", "t"}, "<leader>qp", 
  M.toggle_quartz_terminal(preview_term, "QUARTZ_MODE=preview " .. script_path, "preview_running"), 
  { desc = "Toggle Quartz Preview" })

vim.keymap.set({"n", "t"}, "<leader>qb", 
  M.toggle_quartz_terminal(build_term, script_path, "build_running"), 
  { desc = "Toggle Quartz Build" })

-- Add keymaps to kill commands
vim.keymap.set({"n", "t"}, "<leader>qkp", 
  M.kill_quartz_command(preview_term, "preview_running"), 
  { desc = "Kill Quartz Preview" })

vim.keymap.set({"n", "t"}, "<leader>qkb", 
  M.kill_quartz_command(build_term, "build_running"), 
  { desc = "Kill Quartz Build" })

return M
