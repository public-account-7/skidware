local scripts = {}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = gethui and gethui() or game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

function scripts.new_connection(signal, func, unsafe)
    unsafe = unsafe or false
    if unsafe then
        return signal:Connect(func)
    else
        return signal:Connect(function(...)
            pcall(func, ...)
        end)
    end
end

function scripts.createbutton(text, callback)
    local TextButton = Instance.new("TextButton")
    local UICorner = Instance.new("UICorner")
    local UIGradient = Instance.new("UIGradient")
    local UIStroke = Instance.new("UIStroke")

    TextButton.Parent = ScreenGui
    TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
    TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextButton.BackgroundTransparency = 0.76
    TextButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextButton.Size = UDim2.new(0, 113 / 1.3, 0, 76 / 1.3)
    TextButton.AutoButtonColor = false
    TextButton.Font = Enum.Font.SourceSans
    TextButton.Text = tostring(text)
    TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextButton.TextSize = 23
    TextButton.TextStrokeColor3 = Color3.fromRGB(176, 176, 176)
    TextButton.TextStrokeTransparency = 0.7
    TextButton.TextWrapped = true

    UICorner.Parent = TextButton

    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(194, 194, 194)),
        ColorSequenceKeypoint.new(0.34, Color3.fromRGB(177, 177, 177)),
        ColorSequenceKeypoint.new(0.64, Color3.fromRGB(197, 197, 197)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(232, 232, 232))
    }
    UIGradient.Parent = TextButton

    UIStroke.Parent = TextButton
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Color = Color3.fromRGB(167, 167, 167)
    UIStroke.LineJoinMode = Enum.LineJoinMode.Round
    UIStroke.Thickness = 0.6
    UIStroke.Transparency = 0

    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local dragging, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        TweenService:Create(TextButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = newPos}):Play()
    end

    TextButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = TextButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    TextButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)

    if callback then
        TextButton.MouseButton1Down:Connect(callback)
    end

    return TextButton
end

return scripts
