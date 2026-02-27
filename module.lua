local scripts = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

local fired = false

LocalPlayer.CharacterAdded:Connect(function()
	fired = false
end)

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
	local Frame = Instance.new("Frame")
	local UIGradient = Instance.new("UIGradient")
	local UITextSizeConstraint = Instance.new("UITextSizeConstraint")

	TextButton.Parent = ScreenGui
	TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
	TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextButton.BackgroundTransparency = 0.858
	TextButton.BorderSizePixel = 0
	TextButton.Position = UDim2.new(0.5, 0, 0.5, 0)
	TextButton.Size = UDim2.new(0, 70, 0, 70)
	TextButton.Font = Enum.Font.SourceSans
	TextButton.Text = tostring(text)
	TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.TextScaled = true
	TextButton.TextSize = 25
	TextButton.TextWrapped = true

	UICorner.CornerRadius = UDim.new(0, 10)
	UICorner.Parent = TextButton

	Frame.Parent = TextButton
	Frame.AnchorPoint = Vector2.new(1, 1)
	Frame.BackgroundTransparency = 1
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(1, 0, 1, 0)
	Frame.Size = UDim2.new(0, 15, 0, 15)

	UIGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(218, 218, 218)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(161, 161, 161))
	}
	UIGradient.Parent = TextButton

	UITextSizeConstraint.Parent = TextButton
	UITextSizeConstraint.MaxTextSize = 35

	do
		local b = TextButton
		local f = Frame
		local UIS = game:GetService("UserInputService")
		local TS = game:GetService("TweenService")

		local drag = false
		local resize = false
		local ds, sp, di, ri
		local mt, st
		local ti = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		b.InputBegan:Connect(function(i)
			if resize then return end
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				drag = true
				ds = i.Position
				sp = b.Position
				i.Changed:Connect(function()
					if i.UserInputState == Enum.UserInputState.End then
						drag = false
					end
				end)
			end
		end)

		b.InputChanged:Connect(function(i)
			if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				di = i
			end
		end)

		f.InputBegan:Connect(function(i)
			if drag then return end
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				resize = true
				i.Changed:Connect(function()
					if i.UserInputState == Enum.UserInputState.End then
						resize = false
					end
				end)
			end
		end)

		f.InputChanged:Connect(function(i)
			if resize and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				ri = i
			end
		end)

		UIS.InputChanged:Connect(function(i)
			if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end

			if resize and i == ri then
				if st then st:Cancel() end
				st = TS:Create(b, ti, {
					Size = UDim2.fromOffset(
						math.max(50, i.Position.X - b.AbsolutePosition.X),
						math.max(50, i.Position.Y - b.AbsolutePosition.Y)
					)
				})
				st:Play()
			elseif drag and i == di then
				if mt then mt:Cancel() end
				local d = i.Position - ds
				mt = TS:Create(b, ti, {
					Position = UDim2.new(
						sp.X.Scale,
						sp.X.Offset + d.X,
						sp.Y.Scale,
						sp.Y.Offset + d.Y
					)
				})
				mt:Play()
			end
		end)
	end

	if callback then
		TextButton.MouseButton1Down:Connect(callback)
	end

	return TextButton
end

function scripts.fireclick(object)
	local clickDetector = object:FindFirstChildOfClass("ClickDetector") or object
	if not clickDetector or not clickDetector:IsA("ClickDetector") then
		return
	end
	if not fired then
		fired = true
		pcall(function()
			VirtualInputManager:SendKeyEvent(true, 101, false, game)
		end)
	end

	local oldParent = clickDetector.Parent

	local stubPart = Instance.new("Part")
	stubPart.Transparency = 1
	stubPart.Size = Vector3.new(30, 30, 30)
	stubPart.Anchored = true
	stubPart.CanCollide = false
	stubPart.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -20)
	stubPart.Parent = workspace

	clickDetector.Parent = stubPart
	clickDetector.MaxActivationDistance = math.huge

	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not stubPart.Parent then
			connection:Disconnect()
			return
		end
		stubPart.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -20)
		pcall(function()
			VirtualUser:ClickButton1(Vector2.new(20, 20), workspace.CurrentCamera.CFrame)
		end)
	end)

	clickDetector.MouseClick:Once(function()
		if connection then connection:Disconnect() end
		clickDetector.Parent = oldParent
		stubPart:Destroy()
	end)

	task.delay(3, function()
		if connection then connection:Disconnect() end
		if clickDetector.Parent ~= oldParent then
			clickDetector.Parent = oldParent
		end
		if stubPart then
			stubPart:Destroy()
		end
	end)
end

return scripts
