-- lua/oddish3/utils/caps_lock_status.lua
local M = {}

-- Function to check Caps Lock status
function M.GetCapsLockStatus()
  local handle = io.popen("xset q | grep 'Caps Lock:' | awk '{print $4}'")
  local result = handle:read("*a")
  handle:close()

  if result:find("on") then
    return "CAPS"
  else
    return ""
  end
end

return M

