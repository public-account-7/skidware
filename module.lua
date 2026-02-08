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
	local a,b,c,d,e=Instance.new'TextButton',Instance.new'UICorner',Instance.new'Frame',Instance.new'UIGradient',Instance.new'UITextSizeConstraint'a.Parent=ScreenGui a.AnchorPoint=Vector2.new(0.5,0.5)a.BackgroundColor3=Color3.fromRGB(255,255,255)a.BackgroundTransparency=0.858 a.BorderColor3=Color3.fromRGB(0,0,0)a.BorderSizePixel=0 a.Position=UDim2.new(0.5,0,0.5,0)a.Size=UDim2.new(0,100,0,100)a.Font=Enum.Font.SourceSans a.Text=tostring(text)a.TextColor3=Color3.fromRGB(0,0,0)a.TextScaled=true a.TextSize=25 a.TextWrapped=true b.CornerRadius=UDim.new(0,10)b.Parent=a c.Parent=a c.AnchorPoint=Vector2.new(1,1)c.BackgroundColor3=Color3.fromRGB(255,255,255)c.BackgroundTransparency=1 c.BorderColor3=Color3.fromRGB(0,0,0)c.BorderSizePixel=0 c.Position=UDim2.new(1,0,1,0)c.Size=UDim2.new(0,15,0,15)d.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(218,218,218)),ColorSequenceKeypoint.new(1,Color3.fromRGB(161,161,161))}d.Parent=a e.Parent=a e.MaxTextSize=35 local function ETHC_fake_script()local f=Instance.new('LocalScript',a)local g=f.Parent local h,i,j,k,l,m=g.Frame,game:GetService'UserInputService',game:GetService'TweenService',false,false local n,o,p,q,r,s=(TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out))g.InputBegan:Connect(function(t)if l then return end if t.UserInputType==Enum.UserInputType.MouseButton1 or t.UserInputType==Enum.UserInputType.Touch then k=true o=t.Position p=g.Position t.Changed:Connect(function()if t.UserInputState==Enum.UserInputState.End then k=false end end)end end)g.InputChanged:Connect(function(t)if t.UserInputType==Enum.UserInputType.MouseMovement or t.UserInputType==Enum.UserInputType.Touch then s=t end end)h.InputBegan:Connect(function(t)if t.UserInputType==Enum.UserInputType.MouseButton1 or t.UserInputType==Enum.UserInputType.Touch then l=true k=false t.Changed:Connect(function()if t.UserInputState==Enum.UserInputState.End then l=false end end)end end)h.InputChanged:Connect(function(t)if t.UserInputType==Enum.UserInputType.MouseMovement or t.UserInputType==Enum.UserInputType.Touch then m=t end end)i.InputChanged:Connect(function(t)if t.UserInputType~=Enum.UserInputType.MouseMovement and t.UserInputType~=Enum.UserInputType.Touch then return end if l and t==m then if r then r:Cancel()end r=j:Create(g,n,{Size=UDim2.fromOffset(t.Position.X-g.AbsolutePosition.X,t.Position.Y-g.AbsolutePosition.Y)})r:Play()elseif k and t==s then if q then q:Cancel()end local u=t.Position-o q=j:Create(g,n,{Position=UDim2.new(p.X.Scale,p.X.Offset+u.X,p.Y.Scale,p.Y.Offset+u.Y)})q:Play()end end)end coroutine.wrap(ETHC_fake_script)()
	
	if callback then
        a.MouseButton1Down:Connect(callback)
    end

    return TextButton
end

return scripts
