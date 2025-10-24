--[[
24/10/2025
-new button
]]
local scripts = {}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = gethui and gethui() or game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
function scripts.new_connection(type, func, unsafe)
    unsafe = unsafe or false
    if unsafe then
        return type:Connect(func)
    else
        return type:Connect(function(...)
            pcall(func, ...)
        end)
    end
end
function scripts.createbutton(text, callback)
    local Frame = Instance.new("Frame")
    local TextButton = Instance.new("TextButton")
    local UICorner = Instance.new("UICorner")
    local UIGradient = Instance.new("UIGradient")
    local UICorner_2 = Instance.new("UICorner")
    local UIGradient_2 = Instance.new("UIGradient")
    local UIStroke = Instance.new("UIStroke")
    Frame.Parent = ScreenGui
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
    Frame.BackgroundTransparency = 0.900
    Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.Size = UDim2.new(0, 112, 0, 76)
    Frame.ZIndex = -1
    TextButton.Parent = Frame
    TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
    TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextButton.BackgroundTransparency = 0.760
    TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextButton.Size = UDim2.new(0, 113, 0, 76)
    TextButton.AutoButtonColor = false
    TextButton.Font = Enum.Font.SourceSans
    TextButton.Text = tostring(text)
    TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextButton.TextSize = 23.000
    TextButton.TextStrokeColor3 = Color3.fromRGB(176, 176, 176)
    TextButton.TextStrokeTransparency = 0.700
    TextButton.TextWrapped = true
    UICorner.Parent = TextButton
    UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(194, 194, 194)), ColorSequenceKeypoint.new(0.34, Color3.fromRGB(177, 177, 177)), ColorSequenceKeypoint.new(0.64, Color3.fromRGB(197, 197, 197)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(232, 232, 232))}
    UIGradient.Parent = TextButton
    UICorner_2.Parent = Frame
    UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(6, 6, 6)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(115, 115, 115))}
    UIGradient_2.Parent = Frame
    UIStroke.Parent = TextButton
    UIStroke.ApplyStrokeMode = "Border"
    UIStroke.Color = Color3.fromRGB(167,167,167)
    UIStroke.LineJoinMode = "Round"
    UIStroke.Thickness = 0.6
    UIStroke.Transparency = 0
    local function OKCDHB_fake_script()
	    local script = Instance.new('LocalScript', TextButton)
	    local b=script.Parent
	    local f=b.Parent
	    local u=game:GetService("UserInputService")
	    local ts=game:GetService("TweenService")
	    local d=false
	    local s
	    local p
	    local function up(i)
		    local e=i.Position-s
		    local np=UDim2.new(p.X.Scale,p.X.Offset+e.X,p.Y.Scale,p.Y.Offset+e.Y)
		    ts:Create(f,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=np}):Play()
	    end
	    local function bg(i)
		    d=true
		    s=i.Position
		    p=f.Position
		    i.Changed:Connect(function()
			    if i.UserInputState==Enum.UserInputState.End then d=false end
		    end)
	    end
	    b.InputBegan:Connect(function(i)
		    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			    bg(i)
		    end
	    end)
	    u.InputChanged:Connect(function(i)
		    if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			    up(i)
		    end
	    end)
      if callback then
        b.MouseButton1Down:Connect(callback)
      end
    end
    coroutine.wrap(OKCDHB_fake_script)()
    return TextButton
end
return scripts
