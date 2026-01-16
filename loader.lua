local bindable = Instance.new("BindableFunction")
function bindable.OnInvoke(choice)
    if choice == "Yes" then
        (setclipboard or toclipboard)("https://discord.gg/rZjm4267nJ")
    end
end
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "skidware.lua",
    Text = "wanna join our discord ? click yes to copy discord url",
    Duration = 8,
    Button1 = "Yes",
    Button2 = "No Thanks",
    Callback = bindable
})
local execname = string.lower((identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Unknown")
local badexec = {"solara", "xeno"}
for _, bad in ipairs(badexec) do
    if execname:find(bad) then
        game:GetService("Players").LocalPlayer:Kick("executor not support")
        break
    end
end
pcall(function()
    setreadonly(math, false)
end)
local oldm = math
local mymath = {}
for k,v in pairs(oldm) do
    mymath[k] = v
end
math = mymath
math.random = newcclosure(function(min, max)
    if max == 0 or max > 99999999 then
        return oldm.random()
    end
    return oldm.random(min, max)
end)
local baseurl = "https://raw.githubusercontent.com/public-account-7/skidware/refs/heads/main/games/"
local gamesp = {["6765805766"] = "blockspin.lua", ["4777817887"] = "bladeball.lua", ["universal"] = "universal.lua", ["73885730"] = "prisonlife.lua", ["4914269443"] = "unamedshooter.lua"}
local ahsdkabhdkjbhaw = gamesp[tostring(game.GameId)] or gamesp["universal"]
loadstring(game:HttpGet(baseurl .. ahsdkabhdkjbhaw))()
