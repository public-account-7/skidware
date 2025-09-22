--hello
local scripts = {}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = gethui and gethui() or game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
function scripts.new_connection(type, func)
    return type:Connect(func)
end
function scripts.createbutton(text, callback)
    local TextButton = Instance.new("TextButton")
    local UICorner = Instance.new("UICorner")
    local UIGradient = Instance.new("UIGradient")

    TextButton.Parent = ScreenGui
    TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton.BorderSizePixel = 0
    TextButton.Position = UDim2.new(0.447, 0, 0.466, 0)
    TextButton.Size = UDim2.new(0, 120, 0, 45)
    TextButton.AutoButtonColor = false
    TextButton.Font = Enum.Font.SourceSans
    TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextButton.TextSize = 20
    TextButton.TextWrapped = true
    TextButton.Text = text

    UICorner.Parent = TextButton

    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 137, 135))
    }
    UIGradient.Parent = TextButton

    local function makeDraggable()
        local button = TextButton
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")

        local dragging = false
        local dragInput, dragStart, startPos
        local tweenSpeed = 0.15

        local function update(input)
            local delta = input.Position - dragStart
            local goalPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            local tween = TweenService:Create(button, TweenInfo.new(tweenSpeed), {Position = goalPos})
            tween:Play()
        end

        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = button.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        button.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end

    coroutine.wrap(makeDraggable)()

    if callback then
        TextButton.MouseButton1Click:Connect(callback)
    end
    return TextButton
end
return scripts
