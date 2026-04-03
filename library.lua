--[[
get skidware now
1.4.4
]]
local InputService, TextService, CoreGui, Teams, Players, RunService, TweenService = game:GetService'UserInputService', game:GetService'TextService', game:GetService'CoreGui', game:GetService'Teams', game:GetService'Players', game:GetService'RunService', game:GetService'TweenService'
local RenderStepped, LocalPlayer = RunService.RenderStepped, Players.LocalPlayer
local Mouse, ProtectGui, ScreenGui = LocalPlayer:GetMouse(), protectgui or (syn and syn.protect_gui) or (function() end), Instance.new'ScreenGui'

ProtectGui(ScreenGui)

ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = gethui and gethui() or CoreGui
ScreenGui.DisplayOrder = 20

local Toggles, Options = {}, {}

getgenv().Toggles = Toggles
getgenv().Options = Options

local Library, RainbowStep, Hue = {
    Registry = {},
    RegistryMap = {},
    HudRegistry = {},
    FontColor = Color3.fromRGB(255, 255, 255),
    MainColor = Color3.fromRGB(28, 28, 28),
    BackgroundColor = Color3.fromRGB(20, 20, 20),
    AccentColor = Color3.fromRGB(0, 85, 255),
    OutlineColor = Color3.fromRGB(50, 50, 50),
    RiskColor = Color3.fromRGB(255, 50, 50),
    Black = Color3.new(0, 0, 0),
    Font = Enum.Font.SourceSansBold,
    OpenedFrames = {},
    DependencyBoxes = {},
    Notifications = {},
    ShowCustomCursor = false,
    Signals = {},
    SignalCache = {},
    ScreenGui = ScreenGui,
}, 0, 0

local function GetPlayersString()
    local PlayerList = Players:GetPlayers()

    for i = 1, #PlayerList do
        PlayerList[i] = PlayerList[i].Name
    end

    table.sort(PlayerList, function(str1, str2)
        return str1 < str2
    end)

    return PlayerList
end
local function GetTeamsString()
    local TeamList = Teams:GetTeams()

    for i = 1, #TeamList do
        TeamList[i] = TeamList[i].Name
    end

    table.sort(TeamList, function(str1, str2)
        return str1 < str2
    end)

    return TeamList
end

function Library.SafeCallback(self, f, ...)
    if (not f) then
        return
    end
    if not Library.NotifyOnError then
        return f(...)
    end

    local success, event = pcall(f, ...)

    if not success then
        local _, i = event:find':%d+: '

        if not i then
            return Library:Notify(event)
        end

        return Library:Notify(event:sub(i + 1), 3)
    end
end
function Library.AttemptSave(self)
    if Library.SaveManager then
        Library.SaveManager:Save()
    end
end
function Library.Create(self, Class, Properties)
    local _Instance = Class

    if type(Class) == 'string' then
        _Instance = Instance.new(Class)
    end

    for Property, Value in next, Properties do
        _Instance[Property] = Value
    end

    return _Instance
end
function Library.ApplyTextStroke(self, Inst)
    Inst.TextStrokeTransparency = 1

    Library:Create('UIStroke', {
        Color = Color3.new(0, 0, 0),
        Thickness = 1,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = Inst,
    })
end

local function GetTableSize(t)
    local n = 0

    for _, _ in pairs(t)do
        n = n + 1
    end

    return n
end

function Library.CreateLabel(self, Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1,
        Font = Library.Font,
        TextColor3 = Library.FontColor,
        TextSize = 16,
        TextStrokeTransparency = 0,
    })

    Library:ApplyTextStroke(_Instance)
    Library:AddToRegistry(_Instance, {
        TextColor3 = 'FontColor',
    }, IsHud)

    return Library:Create(_Instance, Properties)
end
function Library.MakeDraggable(self, Instance, Cutoff)
    local dragging, mousePos, framePos, dragInput = false, Vector2.new(), (Instance.Position)

    local function update(input)
        local delta = input.Position - mousePos

        Instance.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end

    Instance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local objPos = Vector2.new(input.Position.X - Instance.AbsolutePosition.X, input.Position.Y - Instance.AbsolutePosition.Y)

            if objPos.Y > (Cutoff or 40) then
                return
            end

            dragging = true
            mousePos = input.Position
            framePos = Instance.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    Instance.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    InputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end
function Library.MakeDraggableOutline(self, Instance, Cutoff)
    Instance.Active = true

    local dragging, dragInput, startPos, objPos = false

    Instance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position

            objPos = Vector2.new(pos.X - Instance.AbsolutePosition.X, pos.Y - Instance.AbsolutePosition.Y)

            if objPos.Y > (Cutoff or 40) then
                return
            end

            dragging = true
            dragInput = input

            local frame = Library:Create('Frame', {
                Parent = ScreenGui,
                AnchorPoint = Instance.AnchorPoint,
                BackgroundTransparency = 1,
                Size = Instance.Size,
                Position = Instance.Position,
            })
            local uistroke = Library:Create('UIStroke', {
                Parent = frame,
                Color = Library.AccentColor or Color3.new(0, 0, 0),
            })

            startPos = Instance.Position

            local connection

            connection = InputService.InputChanged:Connect(function(
                inputChanged
            )
                if dragging and (inputChanged.UserInputType == Enum.UserInputType.MouseMovement or inputChanged.UserInputType == Enum.UserInputType.Touch) then
                    local pos = inputChanged.Position

                    frame.Position = UDim2.new(0, pos.X - objPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X), 0, pos.Y - objPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y))
                    uistroke.Color = Library.AccentColor or Color3.new(0, 0, 0)
                end
            end)

            local endConnection

            endConnection = InputService.InputEnded:Connect(function(
                inputEnded
            )
                if inputEnded == dragInput then
                    dragging = false

                    local pos = inputEnded.Position

                    Instance.Position = UDim2.new(0, pos.X - objPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X), 0, pos.Y - objPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y))

                    frame:Destroy()
                    connection:Disconnect()
                    endConnection:Disconnect()
                end
            end)
        end
    end)
end
function Library.AddToolTip(self, InfoStr, HoverInstance)
    local X, Y = Library:GetTextBounds(InfoStr, Library.Font, 14)
    local Tooltip = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        Size = UDim2.fromOffset(X + 5, Y + 4),
        ZIndex = 100,
        Parent = Library.ScreenGui,
        Visible = false,
    })
    local Label = Library:CreateLabel{
        Position = UDim2.fromOffset(3, 1),
        Size = UDim2.fromOffset(X, Y),
        TextSize = 14,
        Text = InfoStr,
        TextColor3 = Library.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Tooltip.ZIndex + 1,
        Parent = Tooltip,
    }

    Library:AddToRegistry(Tooltip, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'OutlineColor',
    })
    Library:AddToRegistry(Label, {
        TextColor3 = 'FontColor',
    })

    local IsHovering = false

    HoverInstance.MouseEnter:Connect(function()
        if Library:MouseIsOverOpenedFrame() then
            return
        end

        IsHovering = true
        Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        Tooltip.Visible = true

        while IsHovering do
            RunService.Heartbeat:Wait()

            Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        end
    end)
    HoverInstance.MouseLeave:Connect(function()
        IsHovering = false
        Tooltip.Visible = false
    end)
end
function Library.OnHighlight(
    self,
    HighlightInstance,
    Instance,
    Properties,
    PropertiesDefault
)
    local TweenInfo, CurrentTween = (TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

    local function PlayTween(TargetProps)
        if CurrentTween then
            CurrentTween:Cancel()
        end

        local Goal = {}

        for Property, ColorIdx in next, TargetProps do
            Goal[Property] = Library[ColorIdx] or ColorIdx
        end

        CurrentTween = TweenService:Create(Instance, TweenInfo, Goal)

        CurrentTween:Play()

        local Reg = Library.RegistryMap[Instance]

        if Reg then
            for Property, ColorIdx in next, TargetProps do
                if Reg.Properties[Property] then
                    Reg.Properties[Property] = ColorIdx
                end
            end
        end
    end

    HighlightInstance.MouseEnter:Connect(function()
        PlayTween(Properties)
    end)
    HighlightInstance.MouseLeave:Connect(function()
        PlayTween(PropertiesDefault)
    end)
end
function Library.MouseIsOverOpenedFrame(self)
    for Frame, _ in next, Library.OpenedFrames do
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize

        if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
            return true
        end
    end
end
function Library.IsMouseOverFrame(self, Frame)
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize

    if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
        return true
    end
end
function Library.UpdateDependencyBoxes(self)
    for _, Depbox in next, Library.DependencyBoxes do
        Depbox:Update()
    end
end
function Library.MapValue(self, Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB
end
function Library.GetTextBounds(self, Text, Font, Size, Resolution)
    local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))

    return Bounds.X, Bounds.Y
end
function Library.GetDarkerColor(self, Color)
    local H, S, V = Color3.toHSV(Color)

    return Color3.fromHSV(H, S, V / 1.5)
end

Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)

function Library.AddToRegistry(self, Instance, Properties, IsHud)
    local Idx = #Library.Registry + 1
    local Data = {
        Instance = Instance,
        Properties = Properties,
        Idx = Idx,
    }

    table.insert(Library.Registry, Data)

    Library.RegistryMap[Instance] = Data

    if IsHud then
        table.insert(Library.HudRegistry, Data)
    end
end
function Library.RemoveFromRegistry(self, Instance)
    local Data = Library.RegistryMap[Instance]

    if Data then
        for Idx = #Library.Registry, 1, -1 do
            if Library.Registry[Idx] == Data then
                table.remove(Library.Registry, Idx)
            end
        end
        for Idx = #Library.HudRegistry, 1, -1 do
            if Library.HudRegistry[Idx] == Data then
                table.remove(Library.HudRegistry, Idx)
            end
        end

        Library.RegistryMap[Instance] = nil
    end
end
function Library.UpdateColorsUsingRegistry(self)
    for Idx, Object in next, Library.Registry do
        for Property, ColorIdx in next, Object.Properties do
            if type(ColorIdx) == 'string' then
                Object.Instance[Property] = Library[ColorIdx]
            elseif type(ColorIdx) == 'function' then
                Object.Instance[Property] = ColorIdx()
            end
        end
    end
    for _, Toggle in next, Toggles do
        Toggle:Display(true)
    end
end
function Library.GiveSignal(self, Signal, Callback)
    local Key = tostring(Signal)
    local Data = Library.SignalCache[Key]

    if not Data then
        Data = {Callbacks = {}}
        Data.Connection = Signal:Connect(function(...)
            for i = 1, #Data.Callbacks do
                Data.Callbacks[i](...)
            end
        end)

        table.insert(Library.Signals, Data.Connection)

        Library.SignalCache[Key] = Data
    end

    table.insert(Data.Callbacks, Callback)
end

Library:GiveSignal(RenderStepped, function(Delta)
    RainbowStep = RainbowStep + Delta

    if RainbowStep >= (1.6666666666666665E-2) then
        RainbowStep = 0
        Hue = Hue + (2.5E-3)

        if Hue > 1 then
            Hue = 0
        end

        Library.CurrentRainbowHue = Hue
        Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1)
    end
end)

function Library.Unload(self)
    for Idx = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Idx)

        Connection:Disconnect()
    end

    Library.SignalCache = {}

    if Library.OnUnload then
        Library.OnUnload()
    end

    ScreenGui:Destroy()
end

local _callbacks = {}

function Library.BindToInput(self, key, callback)
    _callbacks[key] = _callbacks[key] or {}

    table.insert(_callbacks[key], callback)
end

Library:GiveSignal(game:GetService'UserInputService'.InputBegan, function(
    input,
    ...
)
    local callbacks = _callbacks[input.KeyCode] or _callbacks[input.UserInputType]

    if callbacks then
        for _, callback in pairs(callbacks)do
            task.spawn(callback, input, ...)
        end
    end
end)

function Library.OnUnload(self, Callback)
    Library.OnUnload = Callback
end
function Library.AddContextMenu(self, DisplayFrame, hitbox)
    local ContextMenu = {Visible = false}

    ContextMenu.Options = {}
    ContextMenu.Container = Library:Create('Frame', {
        BorderColor3 = Color3.new(),
        ZIndex = 14,
        Visible = false,
        ClipsDescendants = true,
        Parent = ScreenGui,
    })
    ContextMenu.Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Library.OutlineColor,
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 15,
        Parent = ContextMenu.Container,
    })

    Library:Create('UIListLayout', {
        Name = 'Layout',
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ContextMenu.Inner,
    })

    local function updateMenuPosition()
        ContextMenu.Container.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X + 4, DisplayFrame.AbsolutePosition.Y + 1)
    end
    local function updateMenuSize()
        local width = 60

        for _, v in next, ContextMenu.Inner:GetChildren()do
            if v:IsA'TextLabel' then
                width = math.max(width, v.TextBounds.X)
            end
        end

        ContextMenu.Container.Size = UDim2.fromOffset(width + 8, ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4)
    end

    (hitbox or DisplayFrame).InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            ContextMenu:Show()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            ContextMenu:Hide()
        end
    end)
    Library:BindToInput(Enum.UserInputType.MouseButton1, function()
        if ContextMenu.Visible and not Library:IsMouseOverFrame(ContextMenu.Container) then
            ContextMenu:Hide()
        end
    end)
    Library:AddToRegistry(ContextMenu.Inner, {
        BackgroundColor3 = 'BackgroundColor',
        BorderColor3 = 'OutlineColor',
    })

    function ContextMenu.Show(self)
        updateMenuPosition()
        updateMenuSize()

        self.Visible = true
        self.Container.Visible = true
        Library.OpenedFrames[self.Container] = true
    end
    function ContextMenu.Hide(self)
        self.Visible = false
        self.Container.Visible = false
        Library.OpenedFrames[self.Container] = nil
    end
    function ContextMenu.AddOption(self, Str, Callback)
        Callback = type(Callback) == 'function' and Callback or function() end

        local Button = Library:CreateLabel{
            Size = UDim2.new(1, 0, 0, 15),
            TextSize = 13,
            Text = Str,
            ZIndex = 16,
            Parent = self.Inner,
            TextXAlignment = Enum.TextXAlignment.Center,
        }

        Library:OnHighlight(Button, Button, {
            TextColor3 = 'AccentColor',
        }, {
            TextColor3 = 'FontColor',
        })
        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Callback()
            end
        end)

        return Button
    end

    return ContextMenu
end

Library:GiveSignal(ScreenGui.DescendantRemoving, function(Instance)
    if Library.RegistryMap[Instance] then
        Library:RemoveFromRegistry(Instance)
    end
end)

local BaseAddons = {}

do
    local Funcs = {}

    function Funcs.AddColorPicker(self, Idx, Info)
        local ToggleLabel = self.TextLabel

        assert(Info.Default, 'AddColorPicker: Missing default value.')

        local ColorPicker = {
            Value = Info.Default,
            Transparency = Info.Transparency or 0,
            Type = 'ColorPicker',
            Title = typeof(Info.Title) == 'string' and Info.Title or 'Color picker',
            Callback = Info.Callback or function(Color) end,
            Idx = Idx,
        }

        function ColorPicker.SetHSVFromRGB(self, Color)
            local H, S, V = Color3.toHSV(Color)

            ColorPicker.Hue = H
            ColorPicker.Sat = S
            ColorPicker.Vib = V
        end

        ColorPicker:SetHSVFromRGB(ColorPicker.Value)

        local DisplayFrame = Library:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value,
            BorderColor3 = Library:GetDarkerColor(ColorPicker.Value),
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(0, 28, 0, 14),
            ZIndex = 6,
            Parent = ToggleLabel,
        })

        Library:Create('ImageLabel', {
            BorderSizePixel = 0,
            Size = UDim2.new(0, 27, 0, 13),
            ZIndex = 5,
            Image = 'http://www.roblox.com/asset/?id=12977615774',
            Visible = not not Info.Transparency,
            Parent = DisplayFrame,
        })

        local PickerFrameOuter = Library:Create('Frame', {
            Name = 'Color',
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
            Size = UDim2.fromOffset(230, Info.Transparency and 271 or 253),
            Visible = false,
            ZIndex = 15,
            Parent = ScreenGui,
        })

        DisplayFrame:GetPropertyChangedSignal'AbsolutePosition':Connect(function(
        )
            PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18)
        end)

        local PickerFrameInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 16,
            Parent = PickerFrameOuter,
        })
        local Highlight, SatVibMapOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 2),
            ZIndex = 17,
            Parent = PickerFrameInner,
        }), Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0),
            Position = UDim2.new(0, 4, 0, 25),
            Size = UDim2.new(0, 200, 0, 200),
            ZIndex = 17,
            Parent = PickerFrameInner,
        })
        local SatVibMapInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 18,
            Parent = SatVibMapOuter,
        })
        local SatVibMap = Library:Create('ImageLabel', {
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 18,
            Image = 'rbxassetid://4155801252',
            Parent = SatVibMapInner,
        })
        local CursorOuter = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 6, 0, 6),
            BackgroundTransparency = 1,
            Image = 'http://www.roblox.com/asset/?id=9619665977',
            ImageColor3 = Color3.new(0, 0, 0),
            ZIndex = 19,
            Parent = SatVibMap,
        })

        Library:Create('ImageLabel', {
            Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2),
            Position = UDim2.new(0, 1, 0, 1),
            BackgroundTransparency = 1,
            Image = 'http://www.roblox.com/asset/?id=9619665977',
            ZIndex = 20,
            Parent = CursorOuter,
        })

        local HueSelectorOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0),
            Position = UDim2.new(0, 208, 0, 25),
            Size = UDim2.new(0, 15, 0, 200),
            ZIndex = 17,
            Parent = PickerFrameInner,
        })
        local HueSelectorInner = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 18,
            Parent = HueSelectorOuter,
        })
        local HueCursor, HueBoxOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1),
            AnchorPoint = Vector2.new(0, 0.5),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 18,
            Parent = HueSelectorInner,
        }), Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0),
            Position = UDim2.fromOffset(4, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameInner,
        })
        local HueBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 18,
            Parent = HueBoxOuter,
        })

        Library:Create('UIGradient', {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
            },
            Rotation = 90,
            Parent = HueBoxInner,
        })

        local HueBox = Library:Create('TextBox', {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 5, 0, 0),
            Size = UDim2.new(1, -5, 1, 0),
            Font = Library.Font,
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190),
            PlaceholderText = 'Hex color',
            Text = '#FFFFFF',
            TextColor3 = Library.FontColor,
            TextSize = 14,
            TextStrokeTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 20,
            Parent = HueBoxInner,
        })

        Library:ApplyTextStroke(HueBox)

        local RgbBoxBase = Library:Create(HueBoxOuter:Clone(), {
            Position = UDim2.new(0.5, 2, 0, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            Parent = PickerFrameInner,
        })
        local RgbBox, TransparencyBoxOuter, TransparencyBoxInner, TransparencyCursor = (Library:Create(RgbBoxBase.Frame:FindFirstChild'TextBox', {
            Text = '255, 255, 255',
            PlaceholderText = 'RGB color',
            TextColor3 = Library.FontColor,
        }))

        if Info.Transparency then
            TransparencyBoxOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0),
                Position = UDim2.fromOffset(4, 251),
                Size = UDim2.new(1, -8, 0, 15),
                ZIndex = 19,
                Parent = PickerFrameInner,
            })
            TransparencyBoxInner = Library:Create('Frame', {
                BackgroundColor3 = ColorPicker.Value,
                BorderColor3 = Library.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 19,
                Parent = TransparencyBoxOuter,
            })

            Library:AddToRegistry(TransparencyBoxInner, {
                BorderColor3 = 'OutlineColor',
            })
            Library:Create('ImageLabel', {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Image = 'http://www.roblox.com/asset/?id=12978095818',
                ZIndex = 20,
                Parent = TransparencyBoxInner,
            })

            TransparencyCursor = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(1, 1, 1),
                AnchorPoint = Vector2.new(0.5, 0),
                BorderColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(0, 1, 1, 0),
                ZIndex = 21,
                Parent = TransparencyBoxInner,
            })
        end

        Library:CreateLabel{
            Size = UDim2.new(1, 0, 0, 14),
            Position = UDim2.fromOffset(5, 5),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 14,
            Text = ColorPicker.Title,
            TextWrapped = false,
            ZIndex = 16,
            Parent = PickerFrameInner,
        }

        local ContextMenu = Library:AddContextMenu(DisplayFrame)

        ContextMenu:AddOption('Copy color', function()
            Library.ColorClipboard = ColorPicker.Value

            Library:Notify('Copied color!', 2)
            ContextMenu:Hide()
        end)
        ContextMenu:AddOption('Paste color', function()
            if not Library.ColorClipboard then
                return Library:Notify('You have not copied a color!', 2)
            end

            ColorPicker:SetValueRGB(Library.ColorClipboard)
            Library:Notify('Pasted Color!', 2)
            ContextMenu:Hide()
        end)
        ContextMenu:AddOption('Copy Flag', function()
            pcall(setclipboard, ColorPicker.Idx)
            task.wait()
            Library:Notify('Copied flag to clipboard!', 2)
            ContextMenu:Hide()
        end)
        Library:AddToRegistry(PickerFrameInner, {
            BackgroundColor3 = 'BackgroundColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:AddToRegistry(Highlight, {
            BackgroundColor3 = 'AccentColor',
        })
        Library:AddToRegistry(SatVibMapInner, {
            BackgroundColor3 = 'BackgroundColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:AddToRegistry(HueBoxInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:AddToRegistry(RgbBoxBase.Frame, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:AddToRegistry(RgbBox, {
            TextColor3 = 'FontColor',
        })
        Library:AddToRegistry(HueBox, {
            TextColor3 = 'FontColor',
        })

        local SequenceTable = {}

        for Hue = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
        end

        Library:Create('UIGradient', {
            Color = ColorSequence.new(SequenceTable),
            Rotation = 90,
            Parent = HueSelectorInner,
        })
        HueBox.FocusLost:Connect(function(enter)
            if enter then
                local success, result = pcall(Color3.fromHex, HueBox.Text)

                if success and typeof(result) == 'Color3' then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
            end

            ColorPicker:Display()
        end)
        RgbBox.FocusLost:Connect(function(enter)
            if enter then
                local r, g, b = RgbBox.Text:match'(%d+),%s*(%d+),%s*(%d+)'

                if r and g and b then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                end
            end

            ColorPicker:Display()
        end)

        function ColorPicker.Display(self)
            if not ColorPicker._Tween then
                ColorPicker._Tween = {}
            end

            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

            if ColorPicker._Tween.Sat then
                ColorPicker._Tween.Sat:Cancel()
            end

            ColorPicker._Tween.Sat = TweenService:Create(SatVibMap, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1),
            })

            ColorPicker._Tween.Sat:Play()

            if ColorPicker._Tween.Display then
                ColorPicker._Tween.Display:Cancel()
            end

            ColorPicker._Tween.Display = TweenService:Create(DisplayFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = ColorPicker.Value,
                BackgroundTransparency = ColorPicker.Transparency,
                BorderColor3 = Library:GetDarkerColor(ColorPicker.Value),
            })

            ColorPicker._Tween.Display:Play()

            if ColorPicker._Tween.Cursor then
                ColorPicker._Tween.Cursor:Cancel()
            end

            ColorPicker._Tween.Cursor = TweenService:Create(CursorOuter, TweenInfo.new(0.1), {
                Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0),
            })

            ColorPicker._Tween.Cursor:Play()

            if ColorPicker._Tween.Hue then
                ColorPicker._Tween.Hue:Cancel()
            end

            ColorPicker._Tween.Hue = TweenService:Create(HueCursor, TweenInfo.new(0.1), {
                Position = UDim2.new(0, 0, ColorPicker.Hue, 0),
            })

            ColorPicker._Tween.Hue:Play()

            if TransparencyBoxInner then
                TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0)
            end

            HueBox.Text = '#' .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255),
            }, ', ')

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
        end
        function ColorPicker.OnChanged(self, Func)
            ColorPicker.Changed = Func

            Func(ColorPicker.Value)
        end
        function ColorPicker.Show(self)
            for Frame, Val in next, Library.OpenedFrames do
                if Frame.Name == 'Color' then
                    Frame.Visible = false
                    Library.OpenedFrames[Frame] = nil
                end
            end

            PickerFrameOuter.Visible = true
            Library.OpenedFrames[PickerFrameOuter] = true
        end
        function ColorPicker.Hide(self)
            PickerFrameOuter.Visible = false
            Library.OpenedFrames[PickerFrameOuter] = nil
        end
        function ColorPicker.SetValue(self, HSV, Transparency)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])

            ColorPicker.Transparency = Transparency or 0

            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Display()
        end
        function ColorPicker.SetValueRGB(self, Color, Transparency)
            ColorPicker.Transparency = Transparency or 0

            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Display()
        end

        SatVibMap.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                    local MinX = SatVibMap.AbsolutePosition.X
                    local MaxX = MinX + SatVibMap.AbsoluteSize.X
                    local MouseX, MinY = math.clamp(Mouse.X, MinX, MaxX), SatVibMap.AbsolutePosition.Y
                    local MaxY = MinY + SatVibMap.AbsoluteSize.Y
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                    ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX)
                    ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY))

                    ColorPicker:Display()
                    RenderStepped:Wait()
                end

                Library:AttemptSave()
            end
        end)
        HueSelectorInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                    local MinY = HueSelectorInner.AbsolutePosition.Y
                    local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                    ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY))

                    ColorPicker:Display()
                    RenderStepped:Wait()
                end

                Library:AttemptSave()
            end
        end)
        DisplayFrame.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Library:MouseIsOverOpenedFrame() then
                if PickerFrameOuter.Visible then
                    ColorPicker:Hide()
                else
                    ContextMenu:Hide()
                    ColorPicker:Show()
                end
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                ContextMenu:Show()
                ColorPicker:Hide()
            end
        end)

        if TransparencyBoxInner then
            TransparencyBoxInner.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                        local MinX = TransparencyBoxInner.AbsolutePosition.X
                        local MaxX = MinX + TransparencyBoxInner.AbsoluteSize.X
                        local MouseX = math.clamp(Mouse.X, MinX, MaxX)

                        ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX))

                        ColorPicker:Display()
                        RenderStepped:Wait()
                    end

                    Library:AttemptSave()
                end
            end)
        end

        Library:BindToInput(Enum.UserInputType.MouseButton1, function(Input)
            local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize

            if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then
                ColorPicker:Hide()
            end
            if not Library:IsMouseOverFrame(ContextMenu.Container) then
                ContextMenu:Hide()
            end
        end)
        Library:BindToInput(Enum.UserInputType.Touch, function(Input)
            local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize

            if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then
                ColorPicker:Hide()
            end
            if not Library:IsMouseOverFrame(ContextMenu.Container) then
                ContextMenu:Hide()
            end
        end)
        Library:BindToInput(Enum.UserInputType.MouseButton2, function(Input)
            if ContextMenu.Container.Visible then
                if not Library:IsMouseOverFrame(ContextMenu.Container) and not Library:IsMouseOverFrame(DisplayFrame) then
                    ContextMenu:Hide()
                end
            end
        end)
        ColorPicker:Display()

        ColorPicker.DisplayFrame = DisplayFrame
        Options[Idx] = ColorPicker

        return self
    end
    function Funcs.AddKeyPicker(self, Idx, Info)
        local ParentObj, ToggleLabel, _ = self, self.TextLabel, self.Container

        assert(Info.Default, 'AddKeyPicker: Missing default value.')

        local KeyPicker = {
            Value = Info.Default,
            Toggled = false,
            Mode = Info.Mode or 'Toggle',
            Type = 'KeyPicker',
            Callback = Info.Callback or function(Value) end,
            ChangedCallback = Info.ChangedCallback or function(New) end,
            SyncToggleState = Info.SyncToggleState or false,
            Idx = Idx,
        }

        if KeyPicker.SyncToggleState then
            Info.Modes = {
                'Toggle',
                'Hold',
            }

            if Info.Mode == nil then
                KeyPicker.Mode = 'Toggle'
            end
        end

        local PickOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(0, 28, 0, 15),
            ZIndex = 6,
            Parent = ToggleLabel,
        })
        local PickInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 7,
            Parent = PickOuter,
        })

        Library:AddToRegistry(PickInner, {
            BackgroundColor3 = 'BackgroundColor',
            BorderColor3 = 'OutlineColor',
        })

        local DisplayLabel, ContainerLabel, Modes, contextmenu = Library:CreateLabel{
            Size = UDim2.new(1, 0, 1, 0),
            TextSize = 13,
            Text = Info.Default,
            TextWrapped = true,
            ZIndex = 8,
            Parent = PickInner,
        }, Library:CreateLabel({
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 18),
            TextSize = 13,
            Visible = false,
            ZIndex = 110,
            Parent = Library.KeybindContainer,
        }, true), Info.Modes or {
            'Always',
            'Toggle',
            'Hold',
        }, Library:AddContextMenu(PickOuter)

        for _, Mode in next, Modes do
            contextmenu:AddOption(Mode, function()
                KeyPicker.Mode = Mode

                Library:AttemptSave()
                Library:Notify('Set keybind mode to ' .. Mode, 2)
                contextmenu:Hide()
            end)
        end

        contextmenu:AddOption('Copy Flag', function()
            pcall(setclipboard, KeyPicker.Idx)
            task.wait()
            Library:Notify('Copied flag to clipboard!', 2)
            contextmenu:Hide()
        end)

        function KeyPicker.Update(self)
            if Info.NoUI then
                return
            end

            local State = KeyPicker:GetState()

            ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, Info.Text, KeyPicker.Mode)
            ContainerLabel.Visible = true
            ContainerLabel.TextColor3 = State and Library.AccentColor or Library.FontColor
            Library.RegistryMap[ContainerLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor'

            local YSize, XSize = 0, 0

            for _, Label in next, Library.KeybindContainer:GetChildren()do
                if Label:IsA'TextLabel' and Label.Visible then
                    YSize = YSize + 18

                    if Label.TextBounds.X > XSize then
                        XSize = Label.TextBounds.X
                    end
                end
            end

            Library.KeybindFrame.Size = UDim2.new(0, math.max(XSize + 10, 210), 0, YSize + 23)
        end
        function KeyPicker.GetState(self)
            if KeyPicker.Mode == 'Always' then
                return true
            elseif KeyPicker.Mode == 'Hold' then
                if KeyPicker.Value == 'None' then
                    return false
                end

                local Key = KeyPicker.Value

                if Key == 'MB1' then
                    return InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                elseif Key == 'MB2' then
                    return InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                else
                    local keyCode = Enum.KeyCode[KeyPicker.Value]

                    if keyCode then
                        return InputService:IsKeyDown(keyCode)
                    end
                end
            else
                return KeyPicker.Toggled
            end
        end
        function KeyPicker.SetValue(self, Data)
            local Key, Mode = Data[1], Data[2]

            DisplayLabel.Text = Key
            KeyPicker.Value = Key

            KeyPicker:Update()
        end
        function KeyPicker.OnClick(self, Callback)
            KeyPicker.Clicked = Callback
        end
        function KeyPicker.OnChanged(self, Callback)
            KeyPicker.Changed = Callback

            Callback(KeyPicker.Value)
        end

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker)
        end

        function KeyPicker.DoClick(self, State)
            if ParentObj.Type == 'Toggle' and KeyPicker.SyncToggleState then
                if KeyPicker.Mode == 'Hold' then
                    ParentObj:SetValue(State)
                else
                    ParentObj:SetValue(not ParentObj.Value)
                end
            end

            Library:SafeCallback(KeyPicker.Callback, State)
            Library:SafeCallback(KeyPicker.Clicked, State)
        end

        local Picking = false

        PickOuter.InputBegan:Connect(function(Input)
            if InputService:GetFocusedTextBox() then
                return
            end
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Library:MouseIsOverOpenedFrame() then
                Picking = true
                DisplayLabel.Text = ''

                local Text, Break = ''

                task.spawn(function()
                    while not Break do
                        if Text == '...' then
                            Text = ''
                        end

                        Text = Text .. '.'
                        DisplayLabel.Text = Text

                        wait(0.4)
                    end
                end)
                wait(0.2)

                local Event

                Event = InputService.InputBegan:Connect(function(Input)
                    local Key

                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        Key = Input.KeyCode.Name
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Key = 'MB1'
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                        Key = 'MB2'
                    elseif Input.UserInputType == Enum.UserInputType.Gamepad1 then
                        Key = Input.KeyCode.Name
                    end

                    Break = true
                    Picking = false
                    DisplayLabel.Text = Key
                    KeyPicker.Value = Key

                    Library:SafeCallback(KeyPicker.ChangedCallback, Input.KeyCode or Input.UserInputType)
                    Library:SafeCallback(KeyPicker.Changed, Input.KeyCode or Input.UserInputType)
                    Library:AttemptSave()
                    Event:Disconnect()
                end)
            end
        end)
        Library:GiveSignal(InputService.InputBegan, function(Input)
            if InputService:GetFocusedTextBox() then
                return
            end
            if not Picking then
                if KeyPicker.Mode == 'Toggle' or KeyPicker.Mode == 'Hold' then
                    local Key = KeyPicker.Value

                    if (Key == 'MB1' and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch)) or (Key == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2) or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key) or (Input.UserInputType == Enum.UserInputType.Gamepad1 and Input.KeyCode.Name == Key) then
                        if KeyPicker.Mode == 'Toggle' then
                            KeyPicker.Toggled = not KeyPicker.Toggled

                            KeyPicker:DoClick(KeyPicker.Toggled)
                        elseif KeyPicker.Mode == 'Hold' then
                            KeyPicker:DoClick(true)
                        end
                    end
                end

                KeyPicker:Update()
            end
        end)
        Library:GiveSignal(InputService.InputEnded, function(Input)
            if InputService:GetFocusedTextBox() then
                return
            end
            if not Picking then
                local Key = KeyPicker.Value

                if KeyPicker.Mode == 'Hold' then
                    if (Key == 'MB1' and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch)) or (Key == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2) or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key) or (Input.UserInputType == Enum.UserInputType.Gamepad1 and Input.KeyCode.Name == Key) then
                        KeyPicker:DoClick(false)
                    end
                end

                KeyPicker:Update()
            end
        end)
        KeyPicker:Update()

        Options[Idx] = KeyPicker

        return self
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(Table, Key, ...)
        return Funcs[Key](...)
    end
end

local BaseGroupbox = {}

do
    local Funcs = {}

    function Funcs.AddBlank(self, Size)
        local Groupbox = self
        local Container = Groupbox.Container

        Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Size),
            ZIndex = 1,
            Parent = Container,
        })
    end
    function Funcs.AddLabel(self, Text, DoesWrap)
        local Label, Groupbox = {}, self
        local Container = Groupbox.Container
        local TextLabel = Library:CreateLabel{
            Size = UDim2.new(1, -4, 0, 15),
            TextSize = 14,
            Text = Text,
            TextWrapped = DoesWrap or false,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = Container,
        }

        if DoesWrap then
            local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))

            TextLabel.Size = UDim2.new(1, -4, 0, Y)
        else
            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = TextLabel,
            })
        end

        Label.TextLabel = TextLabel
        Label.Container = Container

        function Label.SetText(self, Text)
            TextLabel.Text = Text

            if DoesWrap then
                local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))

                TextLabel.Size = UDim2.new(1, -4, 0, Y)
            end

            Groupbox:Resize()
        end

        if (not DoesWrap) then
            setmetatable(Label, BaseAddons)
        end

        Groupbox:AddBlank(5)
        Groupbox:Resize()

        return Label
    end
    function Funcs.AddButton(self, Text, Func)
        local Button, Groupbox = {}, self
        local Container = Groupbox.Container
        local ButtonOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, -4, 0, 20),
            ZIndex = 5,
            Parent = Container,
        })

        Library:AddToRegistry(ButtonOuter, {
            BorderColor3 = 'Black',
        })

        local ButtonInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = ButtonOuter,
        })

        Library:AddToRegistry(ButtonInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:Create('UIGradient', {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
            },
            Rotation = 90,
            Parent = ButtonInner,
        })
        Library:CreateLabel{
            Size = UDim2.new(1, 0, 1, 0),
            TextSize = 14,
            Text = Text,
            ZIndex = 6,
            Parent = ButtonInner,
        }
        Library:OnHighlight(ButtonOuter, ButtonOuter, {
            BorderColor3 = 'AccentColor',
        }, {
            BorderColor3 = 'Black',
        })
        ButtonOuter.InputBegan:Connect(function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not Library:MouseIsOverOpenedFrame() then
                Func()
            end
        end)

        function Button.AddTooltip(self, tip)
            if type(tip) == 'string' then
                Library:AddToolTip(tip, ButtonOuter)
            end

            return Button
        end
        function Button.AddButton(self, Text, Func)
            local SubButton = {}

            ButtonOuter.Size = UDim2.new(0.5, -2, 0, 20)

            local Outer = ButtonOuter:Clone()
            local Inner = Outer.Frame
            local Label = Inner:FindFirstChildWhichIsA'TextLabel'

            Outer.Position = UDim2.new(1, 2, 0, 0)
            Outer.Size = UDim2.fromOffset(ButtonOuter.AbsoluteSize.X - 2, ButtonOuter.AbsoluteSize.Y)
            Outer.Parent = ButtonOuter
            Label.Text = Text

            Library:AddToRegistry(Inner, {
                BackgroundColor3 = 'MainColor',
                BorderColor3 = 'OutlineColor',
            })
            Library:OnHighlight(Outer, Outer, {
                BorderColor3 = 'AccentColor',
            }, {
                BorderColor3 = 'Black',
            })
            Library:Create('UIGradient', {
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
                },
                Rotation = 90,
                Parent = Inner,
            })
            Outer.InputBegan:Connect(function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not Library:MouseIsOverOpenedFrame() then
                    Func()
                end
            end)

            function SubButton.AddTooltip(self, tip)
                if type(tip) == 'string' then
                    Library:AddToolTip(tip, Outer)
                end

                return SubButton
            end

            return SubButton
        end

        Groupbox:AddBlank(5)
        Groupbox:Resize()

        return Button
    end
    function Funcs.AddDivider(self)
        local Groupbox, Container = self, self.Container

        Groupbox:AddBlank(2)

        local DividerOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, -4, 0, 5),
            ZIndex = 5,
            Parent = Container,
        })
        local DividerInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = DividerOuter,
        })

        Library:AddToRegistry(DividerOuter, {
            BorderColor3 = 'Black',
        })
        Library:AddToRegistry(DividerInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })
        Groupbox:AddBlank(9)
        Groupbox:Resize()
    end
    function Funcs.AddInput(self, Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')

        local Textbox, Groupbox = {
            Value = Info.Default or '',
            Numeric = Info.Numeric or false,
            Finished = Info.Finished or false,
            Type = 'Input',
            ClearOnFocus = Info.ClearOnFocus or false,
            Callback = Info.Callback or function(Value) end,
            Idx = Idx,
        }, self
        local Container = Groupbox.Container

        Library:CreateLabel{
            Size = UDim2.new(1, 0, 0, 15),
            TextSize = 14,
            Text = Info.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = Container,
        }
        Groupbox:AddBlank(1)

        local TextBoxOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, -4, 0, 20),
            ZIndex = 5,
            Parent = Container,
        })
        local TextBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = TextBoxOuter,
        })

        Library:AddToRegistry(TextBoxInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:OnHighlight(TextBoxOuter, TextBoxOuter, {
            BorderColor3 = 'AccentColor',
        }, {
            BorderColor3 = 'Black',
        })

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, TextBoxOuter)
        end

        Library:Create('UIGradient', {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
            },
            Rotation = 90,
            Parent = TextBoxInner,
        })

        local Container = Library:Create('Frame', {
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Position = UDim2.new(0, 5, 0, 0),
            Size = UDim2.new(1, -5, 1, 0),
            ZIndex = 7,
            Parent = TextBoxInner,
        })
        local Box = Library:Create('TextBox', {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(5, 1),
            Font = Library.Font,
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190),
            PlaceholderText = Info.Placeholder or '',
            Text = Info.Default or '',
            TextColor3 = Library.FontColor,
            TextSize = 14,
            TextStrokeTransparency = 0,
            ClearTextOnFocus = Info.ClearOnFocus or false,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 7,
            Parent = Container,
        })

        Library:ApplyTextStroke(Box)

        function Textbox.SetValue(self, Text)
            if Textbox.Value == Text then
                return
            end
            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end
            if Textbox.Numeric then
                if (not tonumber(Text)) and Text:len() > 0 then
                    Text = Textbox.Value
                end
            end

            Textbox.Value = Text
            Box.Text = Text

            Library:SafeCallback(Textbox.Callback, Textbox.Value)
            Library:SafeCallback(Textbox.Changed, Textbox.Value)
        end

        if Textbox.Finished then
            Box.FocusLost:Connect(function(enter)
                if not enter then
                    return
                end

                Textbox:SetValue(Box.Text)
                Library:AttemptSave()
            end)
        else
            Box:GetPropertyChangedSignal'Text':Connect(function()
                Textbox:SetValue(Box.Text)
                Library:AttemptSave()
            end)
        end

        local function Update()
            local PADDING, reveal = 2, Container.AbsoluteSize.X

            if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then
                Box.Position = UDim2.new(0, PADDING, 0, 0)
            else
                local cursor = Box.CursorPosition

                if cursor ~= -1 then
                    local subtext = string.sub(Box.Text, 1, cursor - 1)
                    local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X
                    local currentCursorPos = Box.Position.X.Offset + width

                    if currentCursorPos < PADDING then
                        Box.Position = UDim2.fromOffset(PADDING - width, 0)
                    elseif currentCursorPos > reveal - PADDING - 1 then
                        Box.Position = UDim2.fromOffset(reveal - width - PADDING - 1, 0)
                    end
                end
            end
        end

        local contextmenu = Library:AddContextMenu(TextBoxOuter)

        contextmenu:AddOption('Copy Flag', function()
            pcall(setclipboard, Textbox.Idx)
            task.wait()
            Library:Notify('Copied flag to clipboard!', 2)
            contextmenu:Hide()
        end)
        task.spawn(Update)
        Box:GetPropertyChangedSignal'Text':Connect(Update)
        Box:GetPropertyChangedSignal'CursorPosition':Connect(Update)
        Box.FocusLost:Connect(Update)
        Box.Focused:Connect(Update)
        Library:AddToRegistry(Box, {
            TextColor3 = 'FontColor',
        })

        function Textbox.OnChanged(self, Func)
            Textbox.Changed = Func

            Func(Textbox.Value)
        end

        Groupbox:AddBlank(5)
        Groupbox:Resize()

        Options[Idx] = Textbox

        return Textbox
    end
    function Funcs.AddToggle(self, Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')

        local Toggle, Groupbox = {
            Value = Info.Default or false,
            Type = 'Toggle',
            Callback = Info.Callback or function(Value) end,
            Addons = {},
            Risky = Info.Risky,
            Idx = Idx,
        }, self
        local Container = Groupbox.Container
        local ToggleOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(0, 13, 0, 13),
            ZIndex = 5,
            Parent = Container,
        })

        Library:AddToRegistry(ToggleOuter, {
            BorderColor3 = 'Black',
        })

        local ToggleInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = ToggleOuter,
        })

        Library:AddToRegistry(ToggleInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })

        local ToggleLabel = Library:CreateLabel{
            Size = UDim2.new(0, 216, 1, 0),
            Position = UDim2.new(1, 6, 0, 0),
            TextSize = 14,
            Text = Info.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6,
            Parent = ToggleInner,
        }

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 4),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ToggleLabel,
        })

        local ToggleRegion = Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 170, 1, 0),
            ZIndex = 8,
            Parent = ToggleOuter,
        })

        Library:OnHighlight(ToggleRegion, ToggleOuter, {
            BorderColor3 = 'AccentColor',
        }, {
            BorderColor3 = 'Black',
        })

        function Toggle.UpdateColors(self)
            Toggle:Display()
        end

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, ToggleRegion)
        end

        function Toggle.Display(self, instant)
            if Toggle._tween then
                Toggle._tween:Cancel()
            end

            local bg, border = Toggle.Value and Library.AccentColor or Library.MainColor, Toggle.Value and Library.AccentColorDark or Library.OutlineColor

            if instant then
                ToggleInner.BackgroundColor3 = bg
                ToggleInner.BorderColor3 = border
            else
                Toggle._tween = TweenService:Create(ToggleInner, TweenInfo.new(0.165, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    BackgroundColor3 = bg,
                    BorderColor3 = border,
                })

                Toggle._tween:Play()
            end

            Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor'
            Library.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor'
        end
        function Toggle.OnChanged(self, Func)
            Toggle.Changed = Func

            Func(Toggle.Value)
        end
        function Toggle.SetValue(self, Bool)
            Bool = (not not Bool)
            Toggle.Value = Bool

            Toggle:Display()

            for _, Addon in next, Toggle.Addons do
                if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
                    Addon.Toggled = Bool

                    Addon:Update()
                end
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
            Library:UpdateDependencyBoxes()
        end

        ToggleRegion.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Library:MouseIsOverOpenedFrame() then
                Toggle:SetValue(not Toggle.Value)
                Library:AttemptSave()
            end
        end)

        local contextmenu = Library:AddContextMenu(ToggleOuter, ToggleRegion)

        contextmenu:AddOption('Copy Flag', function()
            pcall(setclipboard, Toggle.Idx)
            task.wait()
            Library:Notify('Copied flag to clipboard!', 2)
            contextmenu:Hide()
        end)

        if Toggle.Risky then
            Library:RemoveFromRegistry(ToggleLabel)

            ToggleLabel.TextColor3 = Library.RiskColor

            Library:AddToRegistry(ToggleLabel, {
                TextColor3 = 'RiskColor',
            })
        end

        Toggle:Display(true)
        Groupbox:AddBlank(Info.BlankSize or 7)
        Groupbox:Resize()

        Toggle.TextLabel = ToggleLabel
        Toggle.Container = Container

        setmetatable(Toggle, BaseAddons)

        Toggles[Idx] = Toggle

        Library:UpdateDependencyBoxes()

        return Toggle
    end
    function Funcs.AddSlider(self, Idx, Info)
        assert(Info.Default, 'AddSlider: Missing default value.')
        assert(Info.Text, 'AddSlider: Missing slider text.')
        assert(Info.Min, 'AddSlider: Missing minimum value.')
        assert(Info.Max, 'AddSlider: Missing maximum value.')
        assert(Info.Rounding, 'AddSlider: Missing rounding value.')

        local Slider, Groupbox = {
            Value = Info.Default,
            Min = Info.Min,
            Max = Info.Max,
            Rounding = Info.Rounding,
            MaxSize = 232,
            Type = 'Slider',
            Callback = Info.Callback or function(Value) end,
        }, self
        local Container = Groupbox.Container

        if not Info.Compact then
            Library:CreateLabel{
                Size = UDim2.new(1, 0, 0, 10),
                TextSize = 14,
                Text = Info.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Bottom,
                ZIndex = 5,
                Parent = Container,
            }
            Groupbox:AddBlank(3)
        end

        local SliderOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, -4, 0, 13),
            ZIndex = 5,
            Parent = Container,
        })

        Library:AddToRegistry(SliderOuter, {
            BorderColor3 = 'Black',
        })

        local SliderInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = SliderOuter,
        })

        Library:AddToRegistry(SliderInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })

        local Fill = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor,
            BorderColor3 = Library.AccentColorDark,
            Size = UDim2.new(0, 0, 1, 0),
            ZIndex = 7,
            Parent = SliderInner,
        })

        Library:AddToRegistry(Fill, {
            BackgroundColor3 = 'AccentColor',
            BorderColor3 = 'AccentColorDark',
        })

        local HideBorderRight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor,
            BorderSizePixel = 0,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 1, 1, 0),
            ZIndex = 8,
            Parent = Fill,
        })

        Library:AddToRegistry(HideBorderRight, {
            BackgroundColor3 = 'AccentColor',
        })

        local DisplayLabel = Library:CreateLabel{
            Size = UDim2.new(1, 0, 1, 0),
            TextSize = 14,
            Text = 'Infinite',
            ZIndex = 9,
            Parent = SliderInner,
        }

        Library:OnHighlight(SliderOuter, SliderOuter, {
            BorderColor3 = 'AccentColor',
        }, {
            BorderColor3 = 'Black',
        })

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, SliderOuter)
        end

        function Slider.UpdateColors(self)
            Fill.BackgroundColor3 = Library.AccentColor
            Fill.BorderColor3 = Library.AccentColorDark
        end
        function Slider.Display(self, instant)
            local Suffix = Info.Suffix or ''

            if Info.Compact then
                DisplayLabel.Text = Info.Text .. ': ' .. Slider.Value .. Suffix
            elseif Info.HideMax then
                DisplayLabel.Text = string.format('%s', Slider.Value .. Suffix)
            else
                DisplayLabel.Text = string.format('%s/%s', Slider.Value .. Suffix, Slider.Max .. Suffix)
            end

            local totalRange, relativeValue = Slider.Max - Slider.Min, Slider.Value - Slider.Min
            local X = math.ceil((relativeValue / totalRange) * Slider.MaxSize)

            if Slider._tween then
                Slider._tween:Cancel()
            end
            if instant then
                Fill.Size = UDim2.new(0, X, 1, 0)
            else
                Slider._tween = TweenService:Create(Fill, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, X, 1, 0),
                })

                Slider._tween:Play()
            end

            HideBorderRight.Visible = not (X == Slider.MaxSize or X == 0)
        end
        function Slider.OnChanged(self, Func)
            Slider.Changed = Func

            Func(Slider.Value)
        end

        local function Round(Value)
            if Slider.Rounding == 0 then
                return math.floor(Value)
            end

            return tonumber(string.format('%.' .. Slider.Rounding .. 'f', Value))
        end

        function Slider.GetValueFromXOffset(self, X)
            local totalRange = Slider.Max - Slider.Min
            local value = ((X / Slider.MaxSize) * totalRange) + Slider.Min

            return Round(value)
        end
        function Slider.SetValue(self, Str)
            local Num = tonumber(Str)

            if (not Num) then
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)
            Slider.Value = Num

            Slider:Display()
            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end

        SliderInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Library:MouseIsOverOpenedFrame() then
                local mPos, gPos = Mouse.X, Fill.Size.X.Offset
                local Diff = mPos - (Fill.AbsolutePosition.X + gPos)

                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                    local nMPos = Mouse.X
                    local nX = math.clamp(gPos + (nMPos - mPos) + Diff, 0, Slider.MaxSize)
                    local nValue, OldValue = Slider:GetValueFromXOffset(nX), Slider.Value

                    Slider.Value = nValue

                    Slider:Display()

                    if nValue ~= OldValue then
                        Library:SafeCallback(Slider.Callback, Slider.Value)
                        Library:SafeCallback(Slider.Changed, Slider.Value)
                    end

                    RenderStepped:Wait()
                end

                Library:AttemptSave()
            end
        end)
        Slider:Display(true)
        Groupbox:AddBlank(Info.BlankSize or 6)
        Groupbox:Resize()

        Options[Idx] = Slider

        return Slider
    end
    function Funcs.AddDropdown(self, Idx, Info)
        if Info.SpecialType == 'Player' then
            Info.Values = GetPlayersString()
            Info.AllowNull = true
        elseif Info.SpecialType == 'Team' then
            Info.Values = GetTeamsString()
            Info.AllowNull = true
        end

        assert(Info.Values, 'AddDropdown: Missing dropdown value list.')
        assert(Info.AllowNull or Info.Default, 'AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.')

        if (not Info.Text) then
            Info.Compact = true
        end

        local Dropdown, Groupbox, DropdownLabel, CompactBlank = {
            Values = Info.Values,
            Value = Info.Multi and {},
            Multi = Info.Multi,
            Type = 'Dropdown',
            SpecialType = Info.SpecialType,
            Visible = typeof(Info.Visible) ~= 'boolean' and true or Info.Visible,
            Callback = Info.Callback or function(Value) end,
            OriginalText = Info.Text,
            Text = Info.Text,
            Idx = Idx,
        }, self
        local Container, RelativeOffset = Groupbox.Container, 0

        if not Info.Compact then
            DropdownLabel = Library:CreateLabel{
                Size = UDim2.new(1, 0, 0, 10),
                TextSize = 14,
                Text = Info.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Bottom,
                Visible = Dropdown.Visible,
                ZIndex = 5,
                Parent = Container,
            }
            CompactBlank = Groupbox:AddBlank(3, Dropdown.Visible)
        end

        for _, Element in next, Container:GetChildren()do
            if not Element:IsA'UIListLayout' then
                RelativeOffset = RelativeOffset + Element.Size.Y.Offset
            end
        end

        local DropdownOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, -4, 0, 20),
            Visible = Dropdown.Visible,
            ZIndex = 5,
            Parent = Container,
        })

        Library:AddToRegistry(DropdownOuter, {
            BorderColor3 = 'Black',
        })

        local DropdownInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = DropdownOuter,
        })

        Library:AddToRegistry(DropdownInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:Create('UIGradient', {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
            },
            Rotation = 90,
            Parent = DropdownInner,
        })

        local DropdownArrow, ItemList = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -16, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            Image = 'http://www.roblox.com/asset/?id=6282522798',
            ZIndex = 8,
            Parent = DropdownInner,
        }), Library:CreateLabel{
            Position = UDim2.new(0, 5, 0, 0),
            Size = UDim2.new(1, -5, 1, 0),
            TextSize = 14,
            Text = '--',
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 7,
            Parent = DropdownInner,
        }

        Library:OnHighlight(DropdownOuter, DropdownOuter, {
            BorderColor3 = 'AccentColor',
        }, {
            BorderColor3 = 'Black',
        })

        if typeof(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, DropdownOuter)
        end

        local MAX_DROPDOWN_ITEMS, ListOuter = 8, Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            ZIndex = 20,
            Visible = false,
            ClipsDescendants = true,
            Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X + 0.5, 0),
            Parent = ScreenGui,
        })

        local function RecalculateListPosition()
            ListOuter.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 1)
        end
        local function RecalculateListSize(YSize)
            local Y = YSize or math.clamp(GetTableSize(Dropdown.Values) * 20, 0, MAX_DROPDOWN_ITEMS * 20) + 1

            ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X + 0.5, Y)
        end

        RecalculateListPosition()
        RecalculateListSize()
        DropdownOuter:GetPropertyChangedSignal'AbsolutePosition':Connect(RecalculateListPosition)

        local ListInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 21,
            Parent = ListOuter,
        })

        Library:AddToRegistry(ListInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })

        local Scrolling = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 21,
            Parent = ListInner,
            TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
            BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.AccentColor,
        })

        Library:AddToRegistry(Scrolling, {
            ScrollBarImageColor3 = 'AccentColor',
        })
        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 0),
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Scrolling,
        })

        function Dropdown.Display(self)
            local Values, Str = Dropdown.Values, ''

            if Info.Multi then
                for Idx, Value in next, Values do
                    if Dropdown.Value[Value] then
                        Str = Str .. Value .. ', '
                    end
                end

                Str = Str:sub(1, #Str - 2)
            else
                Str = Dropdown.Value or ''
            end

            ItemList.Text = (Str == '' and '--' or Str)
        end
        function Dropdown.GetActiveValues(self)
            if Info.Multi then
                local T = {}

                for Value, Bool in next, Dropdown.Value do
                    table.insert(T, Value)
                end

                return T
            else
                return Dropdown.Value and 1 or 0
            end
        end
        function Dropdown.BuildDropdownList(self)
            local Values, Buttons = Dropdown.Values, {}

            for _, Element in next, Scrolling:GetChildren()do
                if not Element:IsA'UIListLayout' then
                    Element:Destroy()
                end
            end

            local Count = 0

            for Idx, Value in next, Values do
                local Table = {}

                Count = Count + 1

                local Button = Library:Create('TextButton', {
                    AutoButtonColor = false,
                    BackgroundColor3 = Library.MainColor,
                    BorderColor3 = Library.OutlineColor,
                    BorderMode = Enum.BorderMode.Middle,
                    Size = UDim2.new(1, -1, 0, 20),
                    Text = '',
                    ZIndex = 23,
                    Parent = Scrolling,
                })

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor',
                    BorderColor3 = 'OutlineColor',
                })

                local ButtonLabel = Library:CreateLabel{
                    Active = false,
                    Size = UDim2.new(1, -6, 1, 0),
                    Position = UDim2.new(0, 6, 0, 0),
                    TextSize = 14,
                    Text = Value,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 25,
                    Parent = Button,
                }

                Library:OnHighlight(Button, Button, {
                    BorderColor3 = 'AccentColor',
                    ZIndex = 24,
                }, {
                    BorderColor3 = 'OutlineColor',
                    ZIndex = 23,
                })

                local Selected

                if Info.Multi then
                    Selected = Dropdown.Value[Value]
                else
                    Selected = Dropdown.Value == Value
                end

                function Table.UpdateButton(self)
                    if Info.Multi then
                        Selected = Dropdown.Value[Value]
                    else
                        Selected = Dropdown.Value == Value
                    end

                    ButtonLabel.TextColor3 = Selected and Library.AccentColor or Library.FontColor
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or 'FontColor'
                end

                Button.MouseButton1Click:Connect(function(Input)
                    local Try = not Selected

                    if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                    else
                        if Info.Multi then
                            Selected = Try

                            if Selected then
                                Dropdown.Value[Value] = true
                            else
                                Dropdown.Value[Value] = nil
                            end
                        else
                            Selected = Try

                            if Selected then
                                Dropdown.Value = Value
                            else
                                Dropdown.Value = nil
                            end

                            for _, OtherButton in next, Buttons do
                                OtherButton:UpdateButton()
                            end
                        end

                        Table:UpdateButton()
                        Dropdown:Display()
                        Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
                        Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
                        Library:UpdateDependencyBoxes()
                        Library:AttemptSave()
                    end
                end)
                Table:UpdateButton()
                Dropdown:Display()

                Buttons[Button] = Table
            end

            Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * 20) + 1)
            Scrolling.Visible = false
            Scrolling.Visible = true

            local Y = math.clamp(Count * 20, 0, MAX_DROPDOWN_ITEMS * 20) + 1

            RecalculateListSize(Y)
        end
        function Dropdown.SetValues(self, NewValues)
            if NewValues then
                Dropdown.Values = NewValues
            end

            Dropdown:BuildDropdownList()
        end
        function Dropdown.Refresh(self, NewValues)
            if NewValues then
                Dropdown.Values = NewValues
            elseif Dropdown.SpecialType == 'Player' then
                Dropdown.Values = GetPlayersString()
            elseif Dropdown.SpecialType == 'Team' then
                Dropdown.Values = GetTeamsString()
            end
            if Dropdown.Multi then
                for Value in next, Dropdown.Value do
                    if not table.find(Dropdown.Values, Value) then
                        Dropdown.Value[Value] = nil
                    end
                end
            else
                if Dropdown.Value and not table.find(Dropdown.Values, Dropdown.Value) then
                    Dropdown.Value = nil
                end
            end

            Dropdown:BuildDropdownList()
            Dropdown:Display()
        end
        function Dropdown.OpenDropdown(self)
            ListOuter.Visible = true
            Library.OpenedFrames[ListOuter] = true

            local targetY = math.clamp(GetTableSize(Dropdown.Values) * 20, 0, MAX_DROPDOWN_ITEMS * 20) + 1

            if Dropdown._tween then
                Dropdown._tween:Cancel()
            end

            Dropdown._tween = TweenService:Create(ListOuter, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X + 0.5, targetY),
            })

            Dropdown._tween:Play()
            TweenService:Create(DropdownArrow, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Rotation = 180}):Play()
        end
        function Dropdown.CloseDropdown(self)
            Library.OpenedFrames[ListOuter] = nil

            if Dropdown._tween then
                Dropdown._tween:Cancel()
            end

            Dropdown._tween = TweenService:Create(ListOuter, TweenInfo.new(0.14, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X + 0.5, 0),
            })

            Dropdown._tween:Play()
            TweenService:Create(DropdownArrow, TweenInfo.new(0.14, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Rotation = 0}):Play()
            task.delay(0.14, function()
                if ListOuter then
                    ListOuter.Visible = false
                end
            end)
        end
        function Dropdown.OnChanged(self, Func)
            Dropdown.Changed = Func

            Func(Dropdown.Value)
        end
        function Dropdown.SetValue(self, Val)
            if Dropdown.Multi then
                local nTable = {}

                for Value, Bool in next, Val do
                    if table.find(Dropdown.Values, Value) then
                        nTable[Value] = true
                    end
                end

                Dropdown.Value = nTable
            else
                if (not Val) then
                    Dropdown.Value = nil
                elseif table.find(Dropdown.Values, Val) then
                    Dropdown.Value = Val
                end
            end

            Dropdown:BuildDropdownList()
            Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
        end

        DropdownOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Library:MouseIsOverOpenedFrame() then
                if ListOuter.Visible then
                    Dropdown:CloseDropdown()
                else
                    Dropdown:OpenDropdown()
                end
            end
        end)
        Library:BindToInput(Enum.UserInputType.MouseButton1, function(Input)
            local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize

            if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then
                Dropdown:CloseDropdown()
            end
        end)
        Library:BindToInput(Enum.UserInputType.Touch, function(Input)
            local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize

            if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then
                Dropdown:CloseDropdown()
            end
        end)
        Dropdown:BuildDropdownList()
        Dropdown:Display()

        local Defaults = {}

        if type(Info.Default) == 'string' then
            local Idx = table.find(Dropdown.Values, Info.Default)

            if Idx then
                table.insert(Defaults, Idx)
            end
        elseif type(Info.Default) == 'table' then
            for _, Value in next, Info.Default do
                local Idx = table.find(Dropdown.Values, Value)

                if Idx then
                    table.insert(Defaults, Idx)
                end
            end
        elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default)
        end
        if next(Defaults) then
            for i = 1, #Defaults do
                local Index = Defaults[i]

                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index] ] = true
                else
                    Dropdown.Value = Dropdown.Values[Index]
                end
                if (not Info.Multi) then
                    break
                end
            end

            Dropdown:BuildDropdownList()
            Dropdown:Display()
        end

        local contextmenu = Library:AddContextMenu(DropdownOuter)

        contextmenu:AddOption('Copy Flag', function()
            pcall(setclipboard, Dropdown.Idx)
            task.wait()
            Library:Notify('Copied flag to clipboard!', 2)
            contextmenu:Hide()
        end)
        Groupbox:AddBlank(Info.BlankSize or 5)
        Groupbox:Resize()

        Options[Idx] = Dropdown

        return Dropdown
    end
    function Funcs.AddDependencyBox(self)
        local Depbox, Groupbox = {Dependencies = {}}, self
        local Container = Groupbox.Container
        local Holder = Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = false,
            Parent = Container,
        })
        local Frame = Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = true,
            Parent = Holder,
        })
        local Layout = Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Frame,
        })

        function Depbox.Resize(self)
            Holder.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)

            Groupbox:Resize()
        end

        Layout:GetPropertyChangedSignal'AbsoluteContentSize':Connect(function()
            Depbox:Resize()
        end)
        Holder:GetPropertyChangedSignal'Visible':Connect(function()
            Depbox:Resize()
        end)

        function Depbox.Update(self)
            for _, Dependency in next, Depbox.Dependencies do
                local Elem, Value = Dependency[1], Dependency[2]

                if typeof(Elem) == 'table' then
                    if Elem.Type == 'Toggle' and Elem.Value ~= Value then
                        Holder.Visible = false

                        Depbox:Resize()

                        return
                    end
                elseif typeof(Elem) == 'function' then
                    local result = Elem()

                    if result ~= Value then
                        Holder.Visible = false

                        Depbox:Resize()

                        return
                    end
                elseif type(Elem) == 'boolean' then
                    if Elem ~= Value then
                        Holder.Visible = false

                        Depbox:Resize()

                        return
                    end
                end
            end

            Holder.Visible = true

            Depbox:Resize()
        end
        function Depbox.SetupDependencies(self, Dependencies)
            for _, Dependency in next, Dependencies do
                assert(type(Dependency) == 'table', 'SetupDependencies: Dependency is not of type `table`.')
                assert(Dependency[1] ~= nil, 'SetupDependencies: Dependency is missing element or condition argument.')
                assert(Dependency[2] ~= nil, 'SetupDependencies: Dependency is missing value argument.')
            end

            Depbox.Dependencies = Dependencies

            Depbox:Update()
        end

        Depbox.Container = Frame

        setmetatable(Depbox, BaseGroupbox)
        table.insert(Library.DependencyBoxes, Depbox)

        return Depbox
    end

    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(Table, Key, ...)
        return Funcs[Key](...)
    end
end
do
    local WatermarkOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0),
        Position = UDim2.new(0, 100, 0, -25),
        Size = UDim2.new(0, 213, 0, 20),
        ZIndex = 200,
        Visible = false,
        ClipsDescendants = false,
        Parent = ScreenGui,
    })
    local WatermarkInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.AccentColor,
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 201,
        Parent = WatermarkOuter,
    })

    Library:AddToRegistry(WatermarkInner, {
        BorderColor3 = 'AccentColor',
    })

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 202,
        Parent = WatermarkInner,
    })
    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        },
        Rotation = -90,
        Parent = InnerFrame,
    })

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new{
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            }
        end,
    })

    local WatermarkLabel = Library:CreateLabel{
        Position = UDim2.new(0, 5, 0, 0),
        Size = UDim2.new(1, -4, 1, 0),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 203,
        Parent = InnerFrame,
    }

    Library.Watermark = WatermarkOuter
    Library.WatermarkText = WatermarkLabel

    Library:MakeDraggable(Library.Watermark)

    local KeybindOuter = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 0.5),
        BorderColor3 = Color3.new(0, 0, 0),
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(0, 210, 0, 20),
        Visible = false,
        ZIndex = 100,
        Parent = ScreenGui,
    })
    local KeybindInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 101,
        Parent = KeybindOuter,
    })

    Library:AddToRegistry(KeybindInner, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'OutlineColor',
    }, true)

    local ColorFrame = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = 102,
        Parent = KeybindInner,
    })

    Library:AddToRegistry(ColorFrame, {
        BackgroundColor3 = 'AccentColor',
    }, true)
    Library:CreateLabel{
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.fromOffset(5, 2),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = 'Keybinds',
        ZIndex = 104,
        Parent = KeybindInner,
    }

    local KeybindContainer = Library:Create('Frame', {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -20),
        Position = UDim2.new(0, 0, 0, 20),
        ZIndex = 1,
        Parent = KeybindInner,
    })

    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = KeybindContainer,
    })
    Library:Create('UIPadding', {
        PaddingLeft = UDim.new(0, 5),
        Parent = KeybindContainer,
    })

    Library.KeybindFrame = KeybindOuter
    Library.KeybindContainer = KeybindContainer

    Library:MakeDraggable(KeybindOuter)
end

function Library.SetWatermarkVisibility(self, Bool)
    Library.Watermark.Visible = Bool
end
function Library.SetWatermark(self, Text)
    local X, Y = Library:GetTextBounds(Text, Library.Font, 14)

    Library.Watermark.Size = UDim2.new(0, X + 15, 0, (Y * 1.5) + 3)
    Library.WatermarkText.Text = Text
end
function Library.Notify(self, Text, Time)
    local Camera = workspace.CurrentCamera
    local Viewport, XSize, YSize = Camera.ViewportSize, Library:GetTextBounds(Text, Library.Font, 14)

    YSize = YSize + 7

    local NotifyOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0),
        Size = UDim2.fromOffset(0, YSize),
        ClipsDescendants = true,
        ZIndex = 100,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromOffset(Viewport.X / 2, Viewport.Y),
        Parent = ScreenGui,
    })

    if #Library.Notifications >= 10 then
        local oldest = table.remove(Library.Notifications, 1)

        if oldest then
            oldest:Destroy()
        end
    end

    table.insert(Library.Notifications, NotifyOuter)

    local NotifyInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 101,
        Parent = NotifyOuter,
    })
    local InnerFrame, grad = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 102,
        Parent = NotifyInner,
    }), Instance.new'UIGradient'

    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
        ColorSequenceKeypoint.new(1, Library.MainColor),
    }
    grad.Rotation = -90
    grad.Parent = InnerFrame

    Library:CreateLabel{
        Position = UDim2.fromOffset(4, 0),
        Size = UDim2.new(1, -4, 1, 0),
        Text = Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 14,
        ZIndex = 103,
        Parent = InnerFrame,
    }
    NotifyOuter:TweenSize(UDim2.fromOffset(XSize + 12, YSize), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)

    for i = 1, #Library.Notifications do
        local v = Library.Notifications[i]

        if v and v ~= NotifyOuter then
            local offset = (#Library.Notifications - i) * 26

            v:TweenPosition(UDim2.fromOffset(Viewport.X / 2, Viewport.Y * 0.77 - offset), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
        end
    end

    task.delay(Time or 5, function()
        if not NotifyOuter then
            return
        end

        NotifyOuter:TweenSize(UDim2.fromOffset(0, YSize), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
        task.delay(0.25, function()
            for i = 1, #Library.Notifications do
                if Library.Notifications[i] == NotifyOuter then
                    table.remove(Library.Notifications, i)

                    break
                end
            end

            NotifyOuter:Destroy()

            for i = 1, #Library.Notifications do
                local v = Library.Notifications[i]

                if v then
                    local offset = (#Library.Notifications - i) * 26

                    v:TweenPosition(UDim2.fromOffset(Viewport.X / 2, Viewport.Y * 0.77 - offset), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
                end
            end
        end)
    end)
end
function Library.CreateWindow(self, ...)
    local Arguments, Config = {...}, {
        AnchorPoint = Vector2.zero,
    }

    if type(...) == 'table' then
        Config = ...
    else
        Config.Title = Arguments[1]
        Config.AutoShow = Arguments[2] or false
    end
    if type(Config.Title) ~= 'string' then
        Config.Title = 'No title'
    end
    if type(Config.TabPadding) ~= 'number' then
        Config.TabPadding = 0
    end
    if type(Config.MenuFadeTime) ~= 'number' then
        Config.MenuFadeTime = 0.2
    end
    if typeof(Config.Position) ~= 'UDim2' then
        Config.Position = UDim2.fromOffset(175, 50)
    end
    if typeof(Config.Size) ~= 'UDim2' then
        Config.Size = UDim2.fromOffset(550, 420)
    end
    if Config.Center then
        Config.AnchorPoint = Vector2.new(0.5, 0.5)
        Config.Position = UDim2.fromScale(0.5, 0.5)
    end

    Library.UISize = Config.Size

    local Window, Outer = {
        Tabs = {},
        TabButtons = {},
    }, Library:Create('Frame', {
        AnchorPoint = Config.AnchorPoint,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Position = Config.Position,
        Size = Config.Size,
        Visible = false,
        ZIndex = 1,
        Parent = ScreenGui,
    })

    Library:MakeDraggableOutline(Outer, 25)

    local Inner, GlowImage = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.AccentColor,
        BorderMode = Enum.BorderMode.Inset,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 1,
        Parent = Outer,
    }), Library:Create('ImageLabel', {
        BackgroundTransparency = 1,
        Image = 'rbxassetid://5028857084',
        ImageColor3 = Library.AccentColor,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 252, 252),
        Size = UDim2.new(1, 31, 1, 31),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        ZIndex = 0,
        Parent = Outer,
    })

    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'AccentColor',
    })
    Library:AddToRegistry(GlowImage, {
        ImageColor3 = 'AccentColor',
    })

    local WindowLabel, MainSectionOuter = Library:CreateLabel{
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 25),
        Text = Config.Title or '',
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 1,
        Parent = Inner,
    }, Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Library.OutlineColor,
        Position = UDim2.new(0, 8, 0, 25),
        Size = UDim2.new(1, -16, 1, -33),
        ZIndex = 1,
        Parent = Inner,
    })

    Library:AddToRegistry(MainSectionOuter, {
        BackgroundColor3 = 'BackgroundColor',
        BorderColor3 = 'OutlineColor',
    })

    local MainSectionInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Color3.new(0, 0, 0),
        BorderMode = Enum.BorderMode.Inset,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1,
        Parent = MainSectionOuter,
    })

    Library:AddToRegistry(MainSectionInner, {
        BackgroundColor3 = 'BackgroundColor',
    })

    local TabArea = Library:Create('Frame', {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 0, 21),
        ZIndex = 1,
        Parent = MainSectionInner,
    })
    local TabListLayout, TabContainer = Library:Create('UIListLayout', {
        Padding = UDim.new(0, Config.TabPadding),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabArea,
    }), Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        Position = UDim2.new(0, 8, 0, 30),
        Size = UDim2.new(1, -16, 1, -38),
        ZIndex = 2,
        Parent = MainSectionInner,
    })

    Library:AddToRegistry(TabContainer, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'OutlineColor',
    })

    function Window.SetWindowTitle(self, Title)
        WindowLabel.Text = Title
    end
    function Window.UpdateTabSizes(self)
        if TabArea.AbsoluteSize.X <= 0 then
            return
        end

        local totalWidth = 0

        for _, btn in ipairs(self.TabButtons)do
            local text = btn:FindFirstChildOfClass'TextLabel'.Text
            local textSize = Library:GetTextBounds(text, Library.Font, 16)
            local width = textSize + 16

            btn.Size = UDim2.new(0, width, 1, 0)
            totalWidth = totalWidth + (width + Config.TabPadding)
        end

        if totalWidth > TabArea.AbsoluteSize.X then
            local scale = TabArea.AbsoluteSize.X / totalWidth

            for _, btn in ipairs(self.TabButtons)do
                btn.Size = UDim2.new(0, btn.Size.X.Offset * scale, 1, 0)
            end
        end
    end
    function Window.AddTab(self, Name)
        local Tab = {
            Groupboxes = {},
            Tabboxes = {},
        }

        Library:GetTextBounds(Name, Library.Font, 16)

        local TabButton = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor,
            BorderColor3 = Library.OutlineColor,
            Size = UDim2.new(0, 0, 1, 0),
            ZIndex = 1,
            Parent = TabArea,
        })

        table.insert(Window.TabButtons, TabButton)
        Library:AddToRegistry(TabButton, {
            BackgroundColor3 = 'BackgroundColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:CreateLabel{
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, -1),
            Text = Name,
            ZIndex = 1,
            Parent = TabButton,
        }

        local Blocker = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundTransparency = 1,
            ZIndex = 3,
            Parent = TabButton,
        })

        Library:AddToRegistry(Blocker, {
            BackgroundColor3 = 'MainColor',
        })

        local TabFrame = Library:Create('Frame', {
            Name = 'TabFrame',
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ZIndex = 2,
            Parent = TabContainer,
        })
        local LeftSide, RightSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 7, 0, 7),
            Size = UDim2.new(0.5, -10, 0, Library.UISize.Height.Offset - 91),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BottomImage = '',
            TopImage = '',
            ScrollBarThickness = 0,
            ZIndex = 2,
            Parent = TabFrame,
        }), Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 5, 0, 7),
            Size = UDim2.new(0.5, -10, 0, Library.UISize.Height.Offset - 91),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BottomImage = '',
            TopImage = '',
            ScrollBarThickness = 0,
            ZIndex = 2,
            Parent = TabFrame,
        })

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Parent = LeftSide,
        })
        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Parent = RightSide,
        })

        for _, Side in next, {LeftSide, RightSide}do
            Side:WaitForChild'UIListLayout':GetPropertyChangedSignal'AbsoluteContentSize':Connect(function(
            )
                Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y)
            end)
        end

        function Tab.ShowTab(self)
            for _, Tab in next, Window.Tabs do
                Tab:HideTab()
            end

            Blocker.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = Library.MainColor
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor'
            TabFrame.Visible = true
        end
        function Tab.HideTab(self)
            Blocker.BackgroundTransparency = 1
            TabButton.BackgroundColor3 = Library.BackgroundColor
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor'
            TabFrame.Visible = false
        end
        function Tab.SetLayoutOrder(self, Position)
            TabButton.LayoutOrder = Position

            TabListLayout:ApplyLayout()
        end

        Window:UpdateTabSizes()

        function Tab.AddGroupbox(self, Info)
            local Groupbox, BoxOuter = {}, Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Library.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.new(1, 0, 0, 329),
                ZIndex = 2,
                Parent = Info.Side == 1 and LeftSide or RightSide,
            })

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor',
                BorderColor3 = 'OutlineColor',
            })

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                ZIndex = 4,
                Parent = BoxOuter,
            })

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor',
            })

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 2),
                ZIndex = 5,
                Parent = BoxInner,
            })

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor',
            })
            Library:CreateLabel{
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.new(0, 4, 0, 2),
                TextSize = 14,
                Text = Info.Name,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = BoxInner,
            }

            local Container = Library:Create('Frame', {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 4, 0, 20),
                Size = UDim2.new(1, -4, 1, -20),
                ZIndex = 1,
                Parent = BoxInner,
            })

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = Container,
            })

            function Groupbox.Resize(self)
                local Size = 0

                for _, Element in next, Groupbox.Container:GetChildren()do
                    if (not Element:IsA'UIListLayout') and Element.Visible then
                        Size = Size + Element.Size.Y.Offset
                    end
                end

                BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2)
            end

            Groupbox.Container = Container

            setmetatable(Groupbox, BaseGroupbox)
            Groupbox:AddBlank(3)
            Groupbox:Resize()

            Tab.Groupboxes[Info.Name] = Groupbox

            return Groupbox
        end
        function Tab.AddLeftGroupbox(self, Name)
            return Tab:AddGroupbox{
                Side = 1,
                Name = Name,
            }
        end
        function Tab.AddRightGroupbox(self, Name)
            return Tab:AddGroupbox{
                Side = 2,
                Name = Name,
            }
        end
        function Tab.AddTabbox(self, Info)
            local Tabbox, BoxOuter = {Tabs = {}}, Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Library.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.new(1, 0, 0, 0),
                ZIndex = 2,
                Parent = Info.Side == 1 and LeftSide or RightSide,
            })

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor',
                BorderColor3 = 'OutlineColor',
            })

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                ZIndex = 4,
                Parent = BoxOuter,
            })

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor',
            })

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 2),
                ZIndex = 10,
                Parent = BoxInner,
            })

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor',
            })

            local TabboxButtons = Library:Create('Frame', {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 1),
                Size = UDim2.new(1, 0, 0, 18),
                ZIndex = 5,
                Parent = BoxInner,
            })

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = TabboxButtons,
            })

            function Tabbox.AddTab(self, Name)
                local Tab, Button = {}, Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor,
                    BorderColor3 = Color3.new(0, 0, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    ZIndex = 6,
                    Parent = TabboxButtons,
                })

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor',
                })
                Library:CreateLabel{
                    Size = UDim2.new(1, 0, 1, 0),
                    TextSize = 14,
                    Text = Name,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 7,
                    Parent = Button,
                }

                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, 0),
                    Size = UDim2.new(1, 0, 0, 1),
                    Visible = false,
                    ZIndex = 9,
                    Parent = Button,
                })

                Library:AddToRegistry(Block, {
                    BackgroundColor3 = 'BackgroundColor',
                })

                local Container = Library:Create('Frame', {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 4, 0, 20),
                    Size = UDim2.new(1, -4, 1, -20),
                    ZIndex = 1,
                    Visible = false,
                    Parent = BoxInner,
                })

                Library:Create('UIListLayout', {
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Container,
                })

                function Tab.Show(self)
                    for _, Tab in next, Tabbox.Tabs do
                        Tab:Hide()
                    end

                    Container.Visible = true
                    Block.Visible = true
                    Button.BackgroundColor3 = Library.BackgroundColor
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor'

                    Tab:Resize()
                end
                function Tab.Hide(self)
                    Container.Visible = false
                    Block.Visible = false
                    Button.BackgroundColor3 = Library.MainColor
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor'
                end
                function Tab.Resize(self)
                    local TabCount = 0

                    for _, Tab in next, Tabbox.Tabs do
                        TabCount = TabCount + 1
                    end
                    for _, Button in next, TabboxButtons:GetChildren()do
                        if not Button:IsA'UIListLayout' then
                            Button.Size = UDim2.new(1 / TabCount, 0, 1, 0)
                        end
                    end

                    if (not Container.Visible) then
                        return
                    end

                    local Size = 0

                    for _, Element in next, Tab.Container:GetChildren()do
                        if (not Element:IsA'UIListLayout') and Element.Visible then
                            Size = Size + Element.Size.Y.Offset
                        end
                    end

                    BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2)
                end

                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Library:MouseIsOverOpenedFrame() then
                        Tab:Show()
                        Tab:Resize()
                    end
                end)

                Tab.Container = Container
                Tabbox.Tabs[Name] = Tab

                setmetatable(Tab, BaseGroupbox)
                Tab:AddBlank(3)
                Tab:Resize()

                if #TabboxButtons:GetChildren() == 2 then
                    Tab:Show()
                end

                return Tab
            end

            Tab.Tabboxes[Info.Name or ''] = Tabbox

            return Tabbox
        end
        function Tab.AddLeftTabbox(self, Name)
            return Tab:AddTabbox{
                Name = Name,
                Side = 1,
            }
        end
        function Tab.AddRightTabbox(self, Name)
            return Tab:AddTabbox{
                Name = Name,
                Side = 2,
            }
        end

        TabButton.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Tab:ShowTab()
            end
        end)

        if #TabContainer:GetChildren() == 1 then
            Tab:ShowTab()
        end

        Window.Tabs[Name] = Tab

        return Tab
    end

    local ModalElement, TransparencyCache, Toggled, Fading = Library:Create('TextButton', {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0),
        Visible = true,
        Text = '',
        Modal = false,
        Parent = ScreenGui,
    }), {}, false, false

    function Library.Toggle(self)
        if Fading then
            return
        end

        local FadeTime = Config.MenuFadeTime

        Fading = true
        Toggled = (not Toggled)
        ModalElement.Modal = Toggled

        if Toggled then
            Outer.Visible = true

            task.spawn(function()
                local State, Cursor = InputService.MouseIconEnabled, Drawing.new'Triangle'

                Cursor.Thickness = 1
                Cursor.Filled = true
                Cursor.Visible = Library.ShowCustomCursor

                local CursorOutline = Drawing.new'Triangle'

                CursorOutline.Thickness = 1
                CursorOutline.Filled = false
                CursorOutline.Color = Color3.new(0, 0, 0)
                CursorOutline.Visible = true

                while Toggled and ScreenGui.Parent do
                    InputService.MouseIconEnabled = not Library.ShowCustomCursor

                    local mPos = InputService:GetMouseLocation()

                    Cursor.Color = Library.AccentColor
                    Cursor.Visible = Library.ShowCustomCursor
                    Cursor.PointA = Vector2.new(mPos.X, mPos.Y)
                    Cursor.PointB = Vector2.new(mPos.X + 16, mPos.Y + 6)
                    Cursor.PointC = Vector2.new(mPos.X + 6, mPos.Y + 16)
                    CursorOutline.PointA = Cursor.PointA
                    CursorOutline.PointB = Cursor.PointB
                    CursorOutline.PointC = Cursor.PointC
                    CursorOutline.Visible = Library.ShowCustomCursor

                    RenderStepped:Wait()
                end

                InputService.MouseIconEnabled = State

                Cursor:Remove()
                CursorOutline:Remove()
            end)
        end

        for _, Desc in next, Outer:GetDescendants()do
            local Properties = {}

            if Desc:IsA'ImageLabel' then
                table.insert(Properties, 'ImageTransparency')
                table.insert(Properties, 'BackgroundTransparency')
            elseif Desc:IsA'TextLabel' or Desc:IsA'TextBox' then
                table.insert(Properties, 'TextTransparency')
            elseif Desc:IsA'Frame' or Desc:IsA'ScrollingFrame' then
                table.insert(Properties, 'BackgroundTransparency')
            elseif Desc:IsA'UIStroke' then
                table.insert(Properties, 'Transparency')
            end

            local Cache = TransparencyCache[Desc]

            if (not Cache) then
                Cache = {}
                TransparencyCache[Desc] = Cache
            end

            for _, Prop in next, Properties do
                if not Cache[Prop] then
                    Cache[Prop] = Desc[Prop]
                end
                if Cache[Prop] == 1 then
                    continue
                end

                TweenService:Create(Desc, TweenInfo.new(FadeTime, Enum.EasingStyle.Linear), {
                    [Prop] = Toggled and Cache[Prop] or 1,
                }):Play()
            end
        end

        task.wait(FadeTime)

        Outer.Visible = Toggled
        Fading = false
    end

    Library:GiveSignal(InputService.InputBegan, function(Input, Processed)
        if type(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
                task.spawn(Library.Toggle)
            elseif Input.UserInputType == Enum.UserInputType.Gamepad1 and Input.KeyCode.Name == Library.ToggleKeybind.Value then
                task.spawn(Library.Toggle)
            end
        elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and (not Processed)) then
            task.spawn(Library.Toggle)
        end
    end)

    if Config.AutoShow then
        task.spawn(Library.Toggle)
    end

    Window.Holder = Outer

    return Window
end

local function OnPlayerChange()
    local PlayerList = GetPlayersString()

    for _, Value in next, Options do
        if Value.Type == 'Dropdown' and Value.SpecialType == 'Player' then
            Value:SetValues(PlayerList)
        end
    end
end

Players.PlayerAdded:Connect(OnPlayerChange)
Players.PlayerRemoving:Connect(OnPlayerChange)

getgenv().Library = Library

return Library
