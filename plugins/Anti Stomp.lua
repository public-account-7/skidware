if not skidware then
    return error("skidware not found")
end
local antistomp = false
local hpbase = 20
local rs = game:GetService("RunService")
local lp = game:GetService("Players").LocalPlayer

local antistompgb = skidware.AddLeftGroupbox("Anti Stomp")

antistompgb:AddToggle("Antistomp", {
    Text = "Anti Stomp",
    Default = false,
    Callback = function(v)
        antistomp = v
    end
})

antistompgb:AddSlider("HP", {
    Text = "HP",
    Default = hpbase,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(v)
        hpbase = v
    end
})

task.spawn(function()
    while task.wait() do
        pcall(function()
            if antistomp then
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    if lp.Character.Humanoid.Health < hpbase then
                        if replicatesignal then
                            replicatesignal(lp.Kill)
                        elseif lp.Character.Humanoid then
                            lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
                        else
                            lp.Character:BreakJoints()
                        end
                        repeat task.wait() until lp.Character.Humanoid.Health > hpbase or not antistomp
                    end
                end 
            end
        end)
    end
end)
