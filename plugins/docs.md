## Target

### Get Target
```lua
local target = skidware:get_target()
````

Returns:

* `target` (Instance | nil) – current target player

---

### Set Target

```lua
skidware:set_target(player)
```

Parameters:

* `player` (Instance) – player to set as target

---

## CFrame

### Get Server CFrame

```lua
local cf = skidware:get_server_cframe()
```

Returns:

* `cf` (CFrame)

---

### Get Client CFrame

```lua
local cf = skidware:get_client_cframe()
```

Returns:

* `cf` (CFrame | nil)

---

### Set Desync CFrame

```lua
skidware:set_desync_cframe(CFrame.new(0,0,0))
```

Parameters:

* `cf` (CFrame)

---

## Target Strafe

### Get Target Strafe Status

```lua
local status = skidware:get_targetstrafe_status()
```

Returns:

* `"idle"` | `"shooting"` | `"stomping"` | `"unknown"`

---

## Player Checks

### Death Check

```lua
local dead = skidware:is_death(player)
```

Returns:

* `boolean`

---

### KO Check

```lua
local ko = skidware:is_ko(player)
```

Returns:

* `boolean`

---

### Reload Check

```lua
local reloading = skidware:is_reloading()
```

Returns:

* `boolean`

---

## Desync State

### Can Desync

```lua
local can = skidware:can_desync()
```

Returns:

* `boolean`

---

## Shop

### Buy Item

```lua
skidware:buy_item("brownbag", 0.4)
```

Parameters:

* `selected` (string | table)
* `delay` (number, optional)

---

## UI / Notifications

### Notify

```lua
skidware:notify("Hello", 5)
```

Parameters:

* `text` (string)
* `duration` (number, optional)

---

## UI

### Add New Tab

```lua
local tab = skidware:AddTab("Title")
```

## Example

```lua
if not skidware then return end

local tab = skidware:AddTab("Title")
local Plugin = tab:AddLeftGroupbox("Example")

Plugin:AddToggle("Toggle 1", {
    Text = "Toggle 1",
    Default = false,
    Callback = function(v)
        print("Toggle:", v)
    end
})

Plugin:AddButton("Print Target", function()
    print(skidware:get_target())
end)

Plugin:AddButton("Check Reload", function()
    print("Reloading:", skidware:is_reloading())
end)

Plugin:AddButton("Notify", function()
    skidware:notify("hi", 5)
end)
--//other thing like dropdown etc based on linoria example
```
