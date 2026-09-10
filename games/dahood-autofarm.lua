script_key="n";
if getgenv().loadedfirstxd then return end
getgenv().loadedfirstxd = true
repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character
loadstring(game:HttpGet("https://api.polsec.sh/loader/1f8874e11f2a7581/90f99e972ad2b478"))()
