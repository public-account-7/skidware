if not skidware then
    return error("skidware not found")
end
local fp = skidware.AddLeftGroupbox("Fake Pos")
local fpenabled = false
antistompgb:AddToggle("Antistomp", {
    Text = "Fake pos",
    Default = false,
    Callback = function(v)
      fpenabled = v
        while fpenabled do
            setfflag("WorldStepMax","2147483648")
            task.wait(120)
            setfflag("WorldStepMax","30")
        end
    end
})
