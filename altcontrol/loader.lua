local plr = game:GetService("Players").LocalPlayer
local ownerxd = getgenv().owner
if plr.Name == ownerxd then
  loadstring(game:HttpGet("https://raw.githubusercontent.com/public-account-7/skidware/refs/heads/main/altcontrol/owner.lua"))()
else
  loadstring(game:HttpGet("https://raw.githubusercontent.com/public-account-7/skidware/refs/heads/main/altcontrol/bot.lua"))()
end
