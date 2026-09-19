if getgenv().loadedfirstxd then return end
getgenv().loadedfirstxd = true
repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character

game:GetService("Players").LocalPlayer:Kick("down for fixing something")
