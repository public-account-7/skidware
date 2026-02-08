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
	local Frame = Instance.new("Frame")
	local UIGradient = Instance.new("UIGradient")
	local UITextSizeConstraint = Instance.new("UITextSizeConstraint")

	TextButton.Parent = ScreenGui
	TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
	TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextButton.BackgroundTransparency = 0.858
	TextButton.BorderSizePixel = 0
	TextButton.Position = UDim2.new(0.5, 0, 0.5, 0)
	TextButton.Size = UDim2.new(0, 50, 0, 50)
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

return scripts
