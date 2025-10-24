local scripts={},ScreenGui=Instance.new("ScreenGui")ScreenGui.Parent=gethui and gethui()or game.CoreGui ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
function scripts.new_connection(s,f,u)u=u or false if u then return s:Connect(f)else return s:Connect(function(...)pcall(f,...)end)end end
function scripts.createbutton(t,c)local F=Instance.new("Frame")local B=Instance.new("TextButton")local UC1=Instance.new("UICorner")local G1=Instance.new("UIGradient")local UC2=Instance.new("UICorner")local G2=Instance.new("UIGradient")local S=Instance.new("UIStroke")
F.Parent=ScreenGui F.AnchorPoint=Vector2.new(0.5,0.5)F.BackgroundColor3=Color3.fromRGB(11,11,11)F.BackgroundTransparency=0.9 F.BorderSizePixel=0 F.Position=UDim2.new(0.5,0,0.5,0)F.Size=UDim2.new(0,112,0,76)/1.3 F.ZIndex=-1
B.Parent=F B.AnchorPoint=Vector2.new(0.5,0.5)B.BackgroundColor3=Color3.fromRGB(255,255,255)B.BackgroundTransparency=0.76 B.Position=UDim2.new(0.5,0,0.5,0)B.Size=UDim2.new(0,113,0,76)/1.3 B.AutoButtonColor=false B.Font=Enum.Font.SourceSans B.Text=tostring(t)B.TextColor3=Color3.fromRGB(0,0,0)B.TextSize=23 B.TextStrokeColor3=Color3.fromRGB(176,176,176)B.TextStrokeTransparency=0.7 B.TextWrapped=true
UC1.Parent=B G1.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(194,194,194)),ColorSequenceKeypoint.new(0.34,Color3.fromRGB(177,177,177)),ColorSequenceKeypoint.new(0.64,Color3.fromRGB(197,197,197)),ColorSequenceKeypoint.new(1,Color3.fromRGB(232,232,232))}G1.Parent=B UC2.Parent=F G2.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(6,6,6)),ColorSequenceKeypoint.new(1,Color3.fromRGB(115,115,115))}G2.Parent=F S.Parent=B S.ApplyStrokeMode=Enum.ApplyStrokeMode.Border S.Color=Color3.fromRGB(167,167,167)S.LineJoinMode=Enum.LineJoinMode.Round S.Thickness=0.6 S.Transparency=0
local U=game:GetService("UserInputService")local T=game:GetService("TweenService")local d,s,p
local function up(i)local e=i.Position-s local np=UDim2.new(p.X.Scale,p.X.Offset+e.X,p.Y.Scale,p.Y.Offset+e.Y)T:Create(F,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=np}):Play()end
B.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true s=i.Position p=F.Position i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then d=false end end)end end)
U.InputChanged:Connect(function(i)if d and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then up(i)end end)
if c then B.MouseButton1Down:Connect(c)end
return B end
return scripts
