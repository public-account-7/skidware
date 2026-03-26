````md
```lua
local skidware = getgenv().skidware

if not skidware then
    return
end
````

---

## API Reference

### Target Info

```lua
local target, position, hitpart, airhitpart = skidware:GetInfo()
```

Returns:

* `target` (Instance) – current target
* `position` (Vector3) – aim position
* `hitpart` (string) – selected hit part
* `airhitpart` (string) – air hit part

---

### Buy Items

```lua
skidware:BuyItem("brownbag", 0.4)
```

* `item` (string or table) – item name(s)
* `delay` (number) – optional delay between purchases

---

### Reload Check

```lua
local reloading = skidware:Is_Reloading()
```

Returns:

* `boolean`

---

### Player Checks

```lua
skidware:Is_Death(player)
skidware:Is_KO(player)
```

Example:

```lua
skidware:Is_Death(game.Players.LocalPlayer)
```

Returns:

* `boolean`

---

### Desync

```lua
skidware:set_desync_cframe(CFrame.new(0,0,0))
```

---

### Notification

```lua
skidware:Notify("Hello", 5)
```

---

## UI System

Create a plugin UI inside the Plugins tab:

```lua
local Plugin = skidware:AddLeftGroupbox("Example")
```

---

## UI Components

### Toggle

```lua
Plugin:AddToggle("Toggle1", {
    Text = "Toggle 1",
    Default = false,
    Callback = function(v)
        print(v)
    end
})
```

---

### Toggle + Color Picker

```lua
Plugin:AddToggle("Toggle2", {
    Text = "Toggle 2",
    Default = false,
    Callback = function(v)
        print(v)
    end
}):AddColorPicker("Color", {
    Default = Color3.fromRGB(255,0,0),
    Title = "Pick a color",
    Callback = function(c)
        print(c)
    end
})
```

---

### Dropdown

```lua
Plugin:AddDropdown("Mode", {
    Values = {"A","B","C"},
    Default = 1,
    Multi = false,
    Text = "Select Mode",
    Callback = function(v)
        print(v)
    end
})
```

---

### Label + Color Picker

```lua
Plugin:AddLabel("Color"):AddColorPicker("ColorPicker", {
    Default = Color3.fromRGB(255,0,0),
    Title = "Pick a color",
    Callback = function(c)
        print(c)
    end
})
```

---

### Keybind Picker

```lua
Plugin:AddLabel("Keybind"):AddKeyPicker("Key", {
    Default = "F",
    SyncToggleState = false,
    Mode = "Toggle",
    Text = "Select Keybind",
    Callback = function(v)
        print(v)
    end
})
```

---

### Slider

```lua
Plugin:AddSlider("Slider", {
    Text = "Slider",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(v)
        print(v)
    end
})
```

---

### Button

```lua
Plugin:AddButton("Button", function()
    print("hello")
end)
```

---

## Full Example Plugin

```lua
if not skidware then return end

local Plugin = skidware:AddLeftGroupbox("Example")

Plugin:AddToggle("Toggle 1", {
    Text = "Toggle 1",
    Default = false,
    Callback = function(v)
        print("Toggle:", v)
    end
})

Plugin:AddButton("Print Info", function()
    local target, pos, hit, air = skidware:GetInfo()
    print(target, pos, hit, air)
end)

Plugin:AddButton("Notify", function()
    skidware:Notify("hi", 5)
end)
```

---

## Notes

* Some features depend on executor support
* Always check if `skidware` exists before using
* Avoid spamming `BuyItem` to prevent issues
* UI elements return objects that can be chained

---

## Tips

* Use clear names for UI elements
* Cache values if used frequently
* Keep plugins lightweight for performance

```
```
