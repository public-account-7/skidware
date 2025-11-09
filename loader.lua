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
local gamesp = {["6765805766"] = "https://doitenroi.vercel.app/loader/blockspin.lua", ["universal"] = "https://doitenroi.vercel.app/loader/universal.lua"}
local urll = gamesp[tostring(game.GameId)] or gamesp["universal"]
loadstring(game:HttpGet(urll))()
