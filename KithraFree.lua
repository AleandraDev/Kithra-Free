-- // SERVICES
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // GLOBAL SETTINGS
local KithraSettings = {
    MasterESP = false,
    HealthESP = false,
    RainbowESP = false,
    MenuColor = Color3.fromRGB(160, 110, 255),
    ESPColor = Color3.fromRGB(160, 110, 255),
    FOVColor = Color3.fromRGB(255, 255, 255),
    Aimbot = false,
    AimMode = "MouseButton2", 
    CustomKey = Enum.KeyCode.E, 
    MenuKey = Enum.KeyCode.RightShift,
    Smoothness = 0.1,
    TargetPart = "Head",
    FOV = 150,
    ShowFOV = false,
    Unloaded = false
}

-- // FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Transparency = 0.7
FOVCircle.Visible = false

-- // RAINBOW LOGIC
local hue = 0
RunService.RenderStepped:Connect(function() hue = hue + 0.005; if hue > 1 then hue = 0 end end)

-- // GUI SETUP
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Kithra_Free_Official"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 520, 0, 420)
Main.Position = UDim2.new(0.5, -260, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 2

-- // ANIMATION
local MenuVisible = true
local function ToggleMenu()
    MenuVisible = not MenuVisible
    if MenuVisible then
        Main.Visible = true
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 520, 0, 420), BackgroundTransparency = 0}):Play()
    else
        local T = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 520, 0, 0), BackgroundTransparency = 1})
        T:Play()
        T.Completed:Connect(function() if not MenuVisible then Main.Visible = false end end)
    end
end

-- Layouts
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -20, 0, 50); Title.Position = UDim2.new(0, 20, 0, 0)
Title.Text = "Kithra Free"; Title.Font = Enum.Font.FredokaOne; Title.TextSize = 22; Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left

local SideBar = Instance.new("Frame", Main)
SideBar.Size = UDim2.new(0, 130, 1, -70); SideBar.Position = UDim2.new(0, 15, 0, 65); SideBar.BackgroundTransparency = 1
Instance.new("UIListLayout", SideBar).Padding = UDim.new(0, 8)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -170, 1, -75); Container.Position = UDim2.new(0, 155, 0, 65); Container.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 0
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)
    Pages[name] = Page; return Page
end

-- // COMPONENTS
local function AddToggle(parent, text, key)
    local B = Instance.new("TextButton", parent); B.Size = UDim2.new(1, -5, 0, 35); B.BackgroundColor3 = Color3.fromRGB(20, 20, 20); B.Text = "  " .. text; B.TextColor3 = Color3.fromRGB(220, 220, 220); B.Font = Enum.Font.FredokaOne; B.TextSize = 15; B.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", B)
    local S = Instance.new("Frame", B); S.Size = UDim2.new(0, 14, 0, 14); S.Position = UDim2.new(1, -25, 0.5, -7); S.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Instance.new("UICorner", S)
    B.MouseButton1Click:Connect(function() KithraSettings[key] = not KithraSettings[key] end)
    RunService.RenderStepped:Connect(function() S.BackgroundColor3 = KithraSettings[key] and KithraSettings.MenuColor or Color3.fromRGB(45, 45, 45) end)
end

local function AddSlider(parent, text, min, max, key)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, -5, 0, 45); F.BackgroundTransparency = 1
    local L = Instance.new("TextLabel", F); L.Size = UDim2.new(1, 0, 0, 20); L.TextColor3 = Color3.fromRGB(200, 200, 200); L.Font = Enum.Font.FredokaOne; L.TextSize = 14; L.BackgroundTransparency = 1
    local B = Instance.new("TextButton", F); B.Size = UDim2.new(1, 0, 0, 6); B.Position = UDim2.new(0, 0, 0, 28); B.BackgroundColor3 = Color3.fromRGB(30, 30, 30); B.Text = ""
    local Fill = Instance.new("Frame", B); Instance.new("UICorner", Fill)
    B.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then local p = math.clamp((input.Position.X - B.AbsolutePosition.X) / B.AbsoluteSize.X, 0, 1); KithraSettings[key] = math.round((min + (max-min)*p)*100)/100 end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
    end)
    RunService.RenderStepped:Connect(function()
        local p = (KithraSettings[key]-min)/(max-min); Fill.Size = UDim2.new(p, 0, 1, 0); Fill.BackgroundColor3 = KithraSettings.MenuColor; L.Text = text .. ": " .. KithraSettings[key]
    end)
end

local function AddKeyConfig(parent)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, -5, 0, 80); F.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", F)
    local function CreateBtn(name, pos)
        local B = Instance.new("TextButton", F); B.Size = UDim2.new(0.46, 0, 0, 25); B.Position = pos; B.Text = name; B.Font = Enum.Font.FredokaOne; B.TextSize = 12; B.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", B)
        B.MouseButton1Click:Connect(function()
            if name == "KEYBOARD" then B.Text = "PRESS..."; local c; c = UIS.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Keyboard then KithraSettings.CustomKey = i.KeyCode; KithraSettings.AimMode = "KEYBOARD"; B.Text = i.KeyCode.Name; c:Disconnect() end end)
            else KithraSettings.AimMode = name end
        end)
        RunService.RenderStepped:Connect(function() B.BackgroundColor3 = (KithraSettings.AimMode == name or (name=="KEYBOARD" and KithraSettings.AimMode=="KEYBOARD")) and KithraSettings.MenuColor or Color3.fromRGB(35,35,35) end)
    end
    CreateBtn("MouseButton1", UDim2.new(0.02,0,0.15,0)); CreateBtn("MouseButton2", UDim2.new(0.52,0,0.15,0))
    CreateBtn("MouseButton3", UDim2.new(0.02,0,0.6,0)); CreateBtn("KEYBOARD", UDim2.new(0.52,0,0.6,0))
end

local function AddTargetPartConfig(parent)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, -5, 0, 75); F.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", F)
    local function CreateBtn(name, pos)
        local B = Instance.new("TextButton", F); B.Size = UDim2.new(0.3, 0, 0, 25); B.Position = pos; B.Text = name; B.Font = Enum.Font.FredokaOne; B.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", B)
        B.MouseButton1Click:Connect(function() KithraSettings.TargetPart = name end)
        RunService.RenderStepped:Connect(function() B.BackgroundColor3 = KithraSettings.TargetPart == name and KithraSettings.MenuColor or Color3.fromRGB(35,35,35) end)
    end
    CreateBtn("Head", UDim2.new(0.02,0,0.4,0)); CreateBtn("HumanoidRootPart", UDim2.new(0.34,0,0.4,0)); CreateBtn("Nearest", UDim2.new(0.66,0,0.4,0))
end

local function AddColorConfig(parent, label, key)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, -5, 0, 100); F.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", F)
    local L = Instance.new("TextLabel", F); L.Size = UDim2.new(1, 0, 0, 25); L.Text = label; L.TextColor3 = Color3.fromRGB(150, 150, 150); L.Font = Enum.Font.FredokaOne; L.BackgroundTransparency = 1; L.TextSize = 14
    local function CreateSlider(colorName, offset)
        local B = Instance.new("TextButton", F); B.Size = UDim2.new(0.9, 0, 0, 4); B.Position = UDim2.new(0.05, 0, offset, 0); B.BackgroundColor3 = Color3.fromRGB(40,40,40); B.Text = ""
        local Fill = Instance.new("Frame", B); Fill.Size = UDim2.new(0.5, 0, 1, 0); Fill.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", Fill)
        B.MouseButton1Down:Connect(function()
            local move; move = UIS.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local p = math.clamp((input.Position.X - B.AbsolutePosition.X) / B.AbsoluteSize.X, 0, 1); Fill.Size = UDim2.new(p, 0, 1, 0)
                    local r, g, b = KithraSettings[key].R, KithraSettings[key].G, KithraSettings[key].B
                    if colorName == "R" then r = p elseif colorName == "G" then g = p else b = p end
                    KithraSettings[key] = Color3.new(r, g, b)
                end
            end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
        end)
    end
    CreateSlider("R", 0.4); CreateSlider("G", 0.65); CreateSlider("B", 0.9)
end

-- Pages Initialization
local AimP = CreatePage("Aim"); local VisP = CreatePage("Visuals"); local SetP = CreatePage("Settings"); local CredP = CreatePage("Credits")

-- // AIMBOT PAGE CONTENT
AddToggle(AimP, "Aimbot Master", "Aimbot"); AddTargetPartConfig(AimP); AddKeyConfig(AimP); AddSlider(AimP, "Smoothness", 0.01, 1, "Smoothness"); AddSlider(AimP, "FOV Size", 30, 600, "FOV"); AddToggle(AimP, "Show FOV", "ShowFOV")

-- // VISUALS PAGE CONTENT
AddToggle(VisP, "Chams Master", "MasterESP"); AddToggle(VisP, "Health Bar", "HealthESP"); AddToggle(VisP, "Rainbow Mode", "RainbowESP"); AddColorConfig(VisP, "ESP COLOR", "ESPColor")

-- // SETTINGS PAGE CONTENT
AddColorConfig(SetP, "MENU COLOR", "MenuColor"); AddColorConfig(SetP, "FOV COLOR", "FOVColor")
local function AddBind(parent, text, key)
    local B = Instance.new("TextButton", parent); B.Size = UDim2.new(1, -5, 0, 35); B.BackgroundColor3 = Color3.fromRGB(20, 20, 20); B.Text = "  " .. text .. ": " .. KithraSettings[key].Name; B.TextColor3 = Color3.fromRGB(220, 220, 220); B.Font = Enum.Font.FredokaOne; B.TextSize = 15; B.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", B)
    B.MouseButton1Click:Connect(function()
        B.Text = "  PRESS ANY KEY..."; local c; c = UIS.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                KithraSettings[key] = i.KeyCode; B.Text = "  " .. text .. ": " .. i.KeyCode.Name; c:Disconnect()
            end
        end)
    end)
end
AddBind(SetP, "Menu Toggle Key", "MenuKey")

-- // UNLOAD BUTTON (Added to Settings)
local UnloadBtn = Instance.new("TextButton", SetP)
UnloadBtn.Size = UDim2.new(1, -5, 0, 35)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
UnloadBtn.Text = "  Unload Script"
UnloadBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
UnloadBtn.Font = Enum.Font.FredokaOne
UnloadBtn.TextSize = 15
UnloadBtn.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", UnloadBtn)

UnloadBtn.MouseButton1Click:Connect(function()
    KithraSettings.Unloaded = true
    ScreenGui:Destroy()
    FOVCircle:Remove()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character then
            local hl = v.Character:FindFirstChild("KithraHighlight")
            if hl then hl:Destroy() end
            local bar = v.Character:FindFirstChild("KithraHealthBar")
            if bar then bar:Destroy() end
        end
    end
end)

-- // CREDITS PAGE CONTENT (Dynamic Color Header)
local function AddCredit(parent, role, names)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, -5, 0, 70); F.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", F)
    local R = Instance.new("TextLabel", F); R.Size = UDim2.new(1, 0, 0, 25); R.Text = role; R.TextColor3 = KithraSettings.MenuColor; R.Font = Enum.Font.FredokaOne; R.BackgroundTransparency = 1; R.TextSize = 14
    local N = Instance.new("TextLabel", F); N.Size = UDim2.new(1, 0, 0, 25); N.Position = UDim2.new(0, 0, 0, 30); N.Text = names; N.TextColor3 = Color3.new(1, 1, 1); N.Font = Enum.Font.FredokaOne; N.BackgroundTransparency = 1; N.TextSize = 16
    
    -- Sync Role Color with Menu Color
    RunService.RenderStepped:Connect(function() R.TextColor3 = KithraSettings.MenuColor end)
end
AddCredit(CredP, "Developers", "Aleandra\nKeyrex.dev")

-- Tabs Logic
local function AddTab(name, page)
    local T = Instance.new("TextButton", SideBar); T.Size = UDim2.new(1, 0, 0, 35); T.Text = name; T.BackgroundColor3 = Color3.fromRGB(20, 20, 20); T.TextColor3 = Color3.fromRGB(200, 200, 200); T.Font = Enum.Font.FredokaOne; Instance.new("UICorner", T)
    T.MouseButton1Click:Connect(function() for _, p in pairs(Pages) do p.Visible = false end; page.Visible = true end)
end
AddTab("Aimbot", AimP); AddTab("Visuals", VisP); AddTab("Settings", SetP); AddTab("Credits", CredP); AimP.Visible = true

-- // AIMBOT ENGINE
local function GetNearestPart(char)
    local closest = nil; local dist = math.huge
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            local p, os = Camera:WorldToViewportPoint(part.Position)
            if os then local m = (Vector2.new(p.X, p.Y) - UIS:GetMouseLocation()).Magnitude; if m < dist then dist = m; closest = part end end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if KithraSettings.Unloaded then return end
    Stroke.Color = KithraSettings.MenuColor; Title.TextColor3 = KithraSettings.MenuColor
    FOVCircle.Visible = KithraSettings.ShowFOV; FOVCircle.Radius = KithraSettings.FOV; FOVCircle.Position = UIS:GetMouseLocation(); FOVCircle.Color = KithraSettings.FOVColor

    local isAiming = (KithraSettings.AimMode == "KEYBOARD" and UIS:IsKeyDown(KithraSettings.CustomKey)) or (KithraSettings.AimMode ~= "KEYBOARD" and UIS:IsMouseButtonPressed(Enum.UserInputType[KithraSettings.AimMode]))
    if KithraSettings.Aimbot and isAiming then
        local target = nil; local maxDist = KithraSettings.FOV
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local part = (KithraSettings.TargetPart == "Nearest" and GetNearestPart(v.Character)) or v.Character:FindFirstChild(KithraSettings.TargetPart)
                if part then
                    local p, os = Camera:WorldToViewportPoint(part.Position)
                    if os then local m = (Vector2.new(p.X, p.Y) - UIS:GetMouseLocation()).Magnitude; if m < maxDist then maxDist = m; target = part end end
                end
            end
        end
        if target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), KithraSettings.Smoothness) end
    end

    local curESP = KithraSettings.RainbowESP and Color3.fromHSV(hue, 1, 1) or KithraSettings.ESPColor
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
            local hl = v.Character:FindFirstChild("KithraHighlight")
            if KithraSettings.MasterESP and v.Character.Humanoid.Health > 0 then
                if not hl then hl = Instance.new("Highlight", v.Character); hl.Name = "KithraHighlight" end
                hl.FillColor = curESP; hl.Enabled = true
            elseif hl then hl:Destroy() end

            local bar = v.Character:FindFirstChild("KithraHealthBar")
            if KithraSettings.HealthESP and v.Character.Humanoid.Health > 0 then
                if not bar then
                    bar = Instance.new("BillboardGui", v.Character); bar.Name = "KithraHealthBar"; bar.Size = UDim2.new(0.2, 0, 4.5, 0); bar.AlwaysOnTop = true; bar.Adornee = v.Character:FindFirstChild("HumanoidRootPart"); bar.ExtentsOffset = Vector3.new(-2.2, 0, 0)
                    local bg = Instance.new("Frame", bar); bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Color3.new(0,0,0); bg.BorderSizePixel = 0
                    local fill = Instance.new("Frame", bg); fill.Name = "Fill"; fill.Size = UDim2.new(1, 0, 1, 0); fill.BorderSizePixel = 0
                end
                local hp = v.Character.Humanoid.Health / v.Character.Humanoid.MaxHealth
                bar.Frame.Fill.Size = UDim2.new(1, 0, hp, 0); bar.Frame.Fill.Position = UDim2.new(0,0,1-hp,0); bar.Frame.Fill.BackgroundColor3 = KithraSettings.RainbowESP and curESP or Color3.fromHSV(hp * 0.3, 1, 1)
            elseif bar then bar:Destroy() end
        end
    end
end)

-- Draggable Logic
local d, ds, sp
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = Main.Position end end)
UIS.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - ds; Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

-- Menu Toggle
UIS.InputBegan:Connect(function(i) if i.KeyCode == KithraSettings.MenuKey then ToggleMenu() end end)