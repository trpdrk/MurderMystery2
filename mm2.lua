-- ==============================================================================
--    MURDER MYSTERY 2 - ULTIMATE SCRIPT (Updated Target Fling)
--    Features:
--    - Fling Murderer / Sheriff / Innocent out of map (cosmic force)
--    - Aura Kill (200 studs) when murderer holding knife
--    - ESP: Innocent=Green, Sheriff=Blue, Murderer=Red (role-aware)
--    - Noclip
--    - Speed Boost (25)
--    - Target Select + Fling selected player (เท่ากับปลิวฆาตกร)
--    - Draggable icon toggle, draggable UI, X button kills everything
-- ==============================================================================

--// SERVICES
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

--// STATE
local State = {
    Noclip         = false,
    Speed          = false,
    Aura           = false,
    ESP            = false,
    FlingMurderer  = false,
    FlingSheriff   = false,
    FlingInnocent  = false,
    AuraRange      = 200,
    SelectedTarget = nil,
    SpeedValue     = 25,
}

local Connections = {}  -- holds every connection for full cleanup
local Highlights  = {}  -- player -> Highlight instance
local IsDead      = false -- true after X button pressed

local function addConnection(conn)
    table.insert(Connections, conn)
    return conn
end

--// UTILITY: detect role of a player
local function getRole(plr)
    if not plr then return "Innocent" end
    -- 1) Team-based
    local team = plr.Team
    if team then
        local n = team.Name:lower()
        if n:find("murder") then return "Murderer" end
        if n:find("sheriff") or n:find("hero") or n:find("deputy") then return "Sheriff" end
        if n:find("innocent") or n:find("survivor") or n:find("civilian") then return "Innocent" end
    end
    -- 2) Weapon-based (MM2 standard)
    local char = plr.Character
    local bp   = plr:FindFirstChildOfClass("Backpack")
    local function hasTool(container, match)
        if not container then return false end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find(match) then return true end
        end
        return false
    end
    if hasTool(char, "knife") or hasTool(bp, "knife") then return "Murderer" end
    if hasTool(char, "gun") or hasTool(bp, "gun") or hasTool(char, "revolver") or hasTool(bp, "revolver") then return "Sheriff" end
    return "Innocent"
end

local function getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end
local function getHum(char)
    return char and char:FindFirstChildOfClass("Humanoid")
end
local function alive(plr)
    local char = plr.Character
    local hum  = getHum(char)
    return char and hum and hum.Health > 0
end

--// FLING: cosmic force - launch character into orbit / out of world (เท่ากับการปลิวฆาตกร)
local function flingCharacter(char)
    if not char then return end
    local hrp = getHRP(char)
    if not hrp then return end
    pcall(function()
        -- random direction for chaotic flight
        local rx, rz = math.random(-1,1), math.random(-1,1)
        if rx == 0 then rx = 1 end
        if rz == 0 then rz = 1 end
        -- teleport high into the sky
        hrp.CFrame = CFrame.new(hrp.Position.X, 100000, hrp.Position.Z)
        -- massive velocity
        hrp.AssemblyLinearVelocity = Vector3.new(rx * 999999, 99999999, rz * 999999)
        -- impulse
        pcall(function() hrp:ApplyImpulse(Vector3.new(rx * 9e7, 9e9, rz * 9e7)) end)
        -- scatter every limb
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.CanCollide = false
                    part.Velocity = Vector3.new(
                        math.random(-9e6, 9e6),
                        math.random(5e6, 9e7),
                        math.random(-9e6, 9e6)
                    )
                end)
            end
        end
        -- break joints so body parts fly apart
        for _, joint in ipairs(char:GetDescendants()) do
            if joint:IsA("Motor6D") or joint:IsA("Weld") then
                pcall(function() joint:Destroy() end)
            end
        end
    end)
end

local function flingPlayer(plr)
    if plr == LocalPlayer then return end
    if alive(plr) then
        flingCharacter(plr.Character)
    end
end

--// KILL: aura kill - try multiple methods
local function killTarget(targetChar)
    if not targetChar then return end
    local hum = getHum(targetChar)
    if not hum or hum.Health <= 0 then return end
    local targetHRP = getHRP(targetChar)
    if not targetHRP then return end

    local myChar = LocalPlayer.Character
    if not myChar then return end

    -- find knife
    local knife = nil
    local function findKnifeIn(container)
        if not container then return nil end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("knife") then
                return tool
            end
        end
        return nil
    end
    knife = findKnifeIn(myChar)
    if not knife then
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        knife = findKnifeIn(bp)
        -- equip it
        if knife then
            pcall(function()
                local hum2 = getHum(myChar)
                if hum2 then hum2:EquipTool(knife) end
            end)
            task.wait(0.1)
        end
    end

    -- Method 1: firetouchinterest with knife handle
    if knife and knife:FindFirstChild("Handle") then
        pcall(function()
            local handle = knife.Handle
            local oldCF  = handle.CFrame
            handle.CFrame = targetHRP.CFrame
            if firetouchinterest then
                firetouchinterest(handle, targetHRP, 0)
                task.wait(0.03)
                firetouchinterest(handle, targetHRP, 1)
            end
            handle.CFrame = oldCF
        end)
    end

    -- Method 2: fire any knife/hit/damage remote
    pcall(function()
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local rn = remote.Name:lower()
                if rn:find("knife") or rn:find("hit") or rn:find("damage") or rn:find("stab") then
                    pcall(function() remote:FireServer(targetChar) end)
                    pcall(function() remote:FireServer(targetHRP) end)
                end
            end
        end
    end)

    -- Method 3: teleport knife repeatedly into target
    if knife and knife:FindFirstChild("Handle") then
        pcall(function()
            for i = 1, 3 do
                knife.Handle.CFrame = targetHRP.CFrame * CFrame.new(0, i, 0)
                task.wait(0.02)
            end
        end)
    end
end

--// ESP SYSTEM (uses Highlight instances - clean & performant)
local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 40, 40),
    Sheriff  = Color3.fromRGB(40, 120, 255),
    Innocent = Color3.fromRGB(40, 255, 80),
}

local function shouldShowESP(targetRole, myRole)
    if myRole == "Murderer" then return true end
    if myRole == "Sheriff" then return targetRole == "Murderer" end
    if myRole == "Innocent" then return targetRole == "Murderer" or targetRole == "Sheriff" end
    return false
end

local function clearHighlights()
    for plr, hl in pairs(Highlights) do
        pcall(function() hl:Destroy() end)
        Highlights[plr] = nil
    end
end

local function updateESP()
    if not State.ESP then
        clearHighlights()
        return
    end
    local myRole = getRole(LocalPlayer)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and alive(plr) then
            local role = getRole(plr)
            local show = shouldShowESP(role, myRole)
            local char = plr.Character
            if show and char then
                local hl = Highlights[plr]
                if not hl or not hl.Parent then
                    hl = Instance.new("Highlight")
                    hl.Name = "ESP_" .. plr.Name
                    hl.FillTransparency = 0.45
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = char
                    Highlights[plr] = hl
                end
                hl.FillColor = ROLE_COLORS[role] or Color3.new(1,1,1)
                hl.OutlineColor = ROLE_COLORS[role] or Color3.new(1,1,1)
                hl.Enabled = true
            else
                local hl = Highlights[plr]
                if hl then
                    pcall(function() hl:Destroy() end)
                    Highlights[plr] = nil
                end
            end
        else
            local hl = Highlights[plr]
            if hl then
                pcall(function() hl:Destroy() end)
                Highlights[plr] = nil
            end
        end
    end
end

--// LOOPS
-- Noclip
addConnection(RunService.Stepped:Connect(function()
    if IsDead then return end
    if State.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end
end))

-- Speed
addConnection(RunService.Heartbeat:Connect(function()
    if IsDead then return end
    if State.Speed then
        local char = LocalPlayer.Character
        local hum  = getHum(char)
        if hum then
            pcall(function() hum.WalkSpeed = State.SpeedValue end)
        end
    end
end))

-- ESP update (every 0.2s)
addConnection(RunService.RenderStepped:Connect(function()
    if IsDead then return end
    if not _G._espTick then _G._espTick = 0 end
    _G._espTick = _G._espTick + 1
    if _G._espTick % 12 == 0 then
        updateESP()
    end
end))

-- Aura + Fling loops (every 0.15s)
addConnection(RunService.Heartbeat:Connect(function()
    if IsDead then return end
    if not _G._loopTick then _G._loopTick = 0 end
    _G._loopTick = _G._loopTick + 1
    if _G._loopTick % 9 ~= 0 then return end

    local myChar = LocalPlayer.Character
    local myRole = getRole(LocalPlayer)

    -- AURA KILL
    if State.Aura and myRole == "Murderer" and myChar then
        local myHRP = getHRP(myChar)
        if myHRP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and alive(plr) then
                    local tHRP = getHRP(plr.Character)
                    if tHRP then
                        local dist = (myHRP.Position - tHRP.Position).Magnitude
                        if dist <= State.AuraRange then
                            killTarget(plr.Character)
                        end
                    end
                end
            end
        end
    end

    -- FLING BY ROLE
    if State.FlingMurderer or State.FlingSheriff or State.FlingInnocent then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and alive(plr) then
                local role = getRole(plr)
                if (role == "Murderer" and State.FlingMurderer)
                or (role == "Sheriff"  and State.FlingSheriff)
                or (role == "Innocent" and State.FlingInnocent) then
                    flingPlayer(plr)
                end
            end
        end
    end
end))

-- cleanup highlights when player leaves
addConnection(Players.PlayerRemoving:Connect(function(plr)
    local hl = Highlights[plr]
    if hl then pcall(function() hl:Destroy() end) Highlights[plr] = nil end
end))

--// ============================================================
--// UI CREATION
--// ============================================================
local function makeDraggable(frame, dragArea)
    local dragging, dragInput, dragStart, startPos
    addConnection(dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end))
    addConnection(dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))
    addConnection(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))
end

-- destroy old gui + cleanup old script if re-executed
pcall(function()
    if _G.MM2_Cleanup then _G.MM2_Cleanup() end
end)
pcall(function()
    if _G.MM2_GUI then _G.MM2_GUI:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_Ultimate_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
end)
_G.MM2_GUI = ScreenGui

--// TOGGLE ICON
local Icon = Instance.new("TextButton")
Icon.Name = "ToggleIcon"
Icon.Size = UDim2.new(0, 54, 0, 54)
Icon.Position = UDim2.new(1, -70, 1, -70)
Icon.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Icon.BorderSizePixel = 0
Icon.Text = "M"
Icon.Font = Enum.Font.GothamBold
Icon.TextSize = 24
Icon.TextColor3 = Color3.fromRGB(255, 60, 60)
Icon.AutoButtonColor = false
Icon.Parent = ScreenGui
local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 14)
IconCorner.Parent = Icon
local IconStroke = Instance.new("UIStroke")
IconStroke.Color = Color3.fromRGB(255, 60, 60)
IconStroke.Thickness = 1.5
IconStroke.Parent = Icon
local IconGrad = Instance.new("UIGradient")
IconGrad.Color = ColorSequence.new(Color3.fromRGB(35, 35, 50), Color3.fromRGB(15, 15, 22))
IconGrad.Rotation = 90
IconGrad.Parent = Icon

makeDraggable(Icon, Icon)

--// MAIN FRAME
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 520, 0, 460)
Main.Position = UDim2.new(0.5, -260, 0.5, -230)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 80, 120)
MainStroke.Thickness = 1
MainStroke.Parent = Main
local MainGrad = Instance.new("UIGradient")
MainGrad.Color = ColorSequence.new(Color3.fromRGB(24, 24, 36), Color3.fromRGB(14, 14, 20))
MainGrad.Rotation = 90
MainGrad.Parent = Main

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleBarCover = Instance.new("Frame")
TitleBarCover.Size = UDim2.new(1, 0, 0.5, 0)
TitleBarCover.Position = UDim2.new(0, 0, 0.5, 0)
TitleBarCover.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
TitleBarCover.BorderSizePixel = 0
TitleBarCover.Parent = TitleBar

makeDraggable(Main, TitleBar)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MM2 ULTIMATE"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 70, 70)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -60, 0, 14)
SubTitle.Position = UDim2.new(0, 16, 0, 26)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "by Delta Script Hub"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 11
SubTitle.TextColor3 = Color3.fromRGB(140, 140, 170)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TitleBar

--// CLOSE BUTTON (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}):Play()
end)

--// CONTENT SCROLLER
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 52)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main
local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = Content
local ContentPad = Instance.new("UIPadding")
ContentPad.PaddingBottom = UDim.new(0, 10)
ContentPad.Parent = Content

--// UI HELPERS
local yIndex = 0
local function sectionLabel(text)
    yIndex = yIndex + 1
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(255, 90, 90)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = yIndex
    lbl.Parent = Content
    return lbl
end

local function createToggle(name, stateKey, color)
    yIndex = yIndex + 1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
    row.BorderSizePixel = 0
    row.LayoutOrder = yIndex
    row.Parent = Content
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 8)
    rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(220, 220, 235)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 46, 0, 24)
    toggle.Position = UDim2.new(1, -56, 0.5, -12)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = row
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = toggle

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local onColor = color or Color3.fromRGB(60, 200, 90)
    local function updateVisual()
        if State[stateKey] then
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = onColor}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -21, 0.5, -9)}):Play()
        else
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
        end
    end
    toggle.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        updateVisual()
        if stateKey == "ESP" and not State.ESP then
            clearHighlights()
        end
    end)
    updateVisual()
    return row
end

local function createSlider(name, stateKey, minVal, maxVal, suffix)
    yIndex = yIndex + 1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 56)
    row.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
    row.BorderSizePixel = 0
    row.LayoutOrder = yIndex
    row.Parent = Content
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 8)
    rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 0, 20)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(220, 220, 235)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 60, 0, 20)
    valLbl.Position = UDim2.new(1, -70, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(State[stateKey]) .. (suffix or "")
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.TextColor3 = Color3.fromRGB(255, 120, 60)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 6)
    track.Position = UDim2.new(0, 14, 0, 38)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    track.BorderSizePixel = 0
    track.Parent = row
    local trc = Instance.new("UICorner")
    trc.CornerRadius = UDim.new(1, 0)
    trc.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 120, 60)
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, -4, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.Parent = track
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local function setFromX(absX)
        local tPos = track.AbsolutePosition.X
        local tSize = track.AbsoluteSize.X
        local p = math.clamp((absX - tPos) / tSize, 0, 1)
        local val = minVal + (maxVal - minVal) * p
        val = math.floor(val + 0.5)
        State[stateKey] = val
        valLbl.Text = tostring(val) .. (suffix or "")
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, -8, 0.5, -8)
    end

    local dragging = false
    addConnection(knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end))
    addConnection(track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromX(input.Position.X)
        end
    end))
    addConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    addConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end))

    local p0 = (State[stateKey] - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(p0, 0, 1, 0)
    knob.Position = UDim2.new(p0, -8, 0.5, -8)

    return row
end

--// TARGET SELECTOR
yIndex = yIndex + 1
local TargetRow = Instance.new("Frame")
TargetRow.Size = UDim2.new(1, 0, 0, 46)
TargetRow.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
TargetRow.BorderSizePixel = 0
TargetRow.LayoutOrder = yIndex
TargetRow.Parent = Content
local trc2 = Instance.new("UICorner")
trc2.CornerRadius = UDim.new(0, 8)
trc2.Parent = TargetRow

local TargetLbl = Instance.new("TextLabel")
TargetLbl.Size = UDim2.new(0, 100, 1, 0)
TargetLbl.Position = UDim2.new(0, 14, 0, 0)
TargetLbl.BackgroundTransparency = 1
TargetLbl.Text = "Target:"
TargetLbl.Font = Enum.Font.GothamSemibold
TargetLbl.TextSize = 14
TargetLbl.TextColor3 = Color3.fromRGB(220, 220, 235)
TargetLbl.TextXAlignment = Enum.TextXAlignment.Left
TargetLbl.Parent = TargetRow

local DropBtn = Instance.new("TextButton")
DropBtn.Size = UDim2.new(1, -180, 0, 30)
DropBtn.Position = UDim2.new(0, 90, 0.5, -15)
DropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
DropBtn.BorderSizePixel = 0
DropBtn.Text = "Select player..."
DropBtn.Font = Enum.Font.Gotham
DropBtn.TextSize = 13
DropBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
DropBtn.AutoButtonColor = false
DropBtn.Parent = TargetRow
local drc = Instance.new("UICorner")
drc.CornerRadius = UDim.new(0, 6)
drc.Parent = DropBtn

local FlingSelectedBtn = Instance.new("TextButton")
FlingSelectedBtn.Size = UDim2.new(0, 70, 0, 30)
FlingSelectedBtn.Position = UDim2.new(1, -78, 0.5, -15)
FlingSelectedBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 200)
FlingSelectedBtn.BorderSizePixel = 0
FlingSelectedBtn.Text = "FLING"
FlingSelectedBtn.Font = Enum.Font.GothamBold
FlingSelectedBtn.TextSize = 12
FlingSelectedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingSelectedBtn.AutoButtonColor = false
FlingSelectedBtn.Parent = TargetRow
local fsc = Instance.new("UICorner")
fsc.CornerRadius = UDim.new(0, 6)
fsc.Parent = FlingSelectedBtn

-- เชื่อมปุ่ม FLING ของรายชื่อคนให้ใช้ฟังก์ชัน flingPlayer (ปลิวแบบเดียวกับฆาตกร)
FlingSelectedBtn.MouseButton1Click:Connect(function()
    if State.SelectedTarget then
        local plr = Players:FindFirstChild(State.SelectedTarget)
        if plr then
            flingPlayer(plr)
        end
    end
end)

-- dropdown list
local DropList = Instance.new("Frame")
DropList.Name = "DropList"
DropList.Size = UDim2.new(0, 250, 0, 120)
DropList.Position = UDim2.new(0, 90, 0, 200)
DropList.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
DropList.BorderSizePixel = 0
DropList.Visible = false
DropList.ZIndex = 50
DropList.Parent = Main
local dlc = Instance.new("UICorner")
dlc.CornerRadius = UDim.new(0, 6)
dlc.Parent = DropList
local DropScroll = Instance.new("ScrollingFrame")
DropScroll.Size = UDim2.new(1, -8, 1, -8)
DropScroll.Position = UDim2.new(0, 4, 0, 4)
DropScroll.BackgroundTransparency = 1
DropScroll.BorderSizePixel = 0
DropScroll.ScrollBarThickness = 3
DropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
DropScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
DropScroll.ZIndex = 51
DropScroll.Parent = DropList
local DropLayout = Instance.new("UIListLayout")
DropLayout.Padding = UDim.new(0, 2)
DropLayout.Parent = DropScroll

local function positionDropList()
    local absPos  = DropBtn.AbsolutePosition
    local mainAbs = Main.AbsolutePosition
    DropList.Position = UDim2.new(
        0, absPos.X - mainAbs.X,
        0, absPos.Y - mainAbs.Y + DropBtn.AbsoluteSize.Y + 4
    )
    DropList.Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, 120)
end

local function refreshDropList()
    for _, child in ipairs(DropScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 24)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 72)
            btn.BorderSizePixel = 0
            btn.Text = "  " .. plr.Name .. "  [" .. getRole(plr) .. "]"
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.TextColor3 = Color3.fromRGB(220, 220, 235)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.AutoButtonColor = false
            btn.ZIndex = 52
            btn.Parent = DropScroll
            btn.MouseButton1Click:Connect(function()
                State.SelectedTarget = plr.Name
                DropBtn.Text = plr.Name
                DropList.Visible = false
            end)
        end
    end
end

DropBtn.MouseButton1Click:Connect(function()
    DropList.Visible = not DropList.Visible
    if DropList.Visible then
        positionDropList()
        refreshDropList()
    end
end)

addConnection(Players.PlayerAdded:Connect(function() task.wait(1) if DropList.Visible then refreshDropList() end end))
addConnection(Players.PlayerRemoving:Connect(function() task.wait(0.5) if DropList.Visible then refreshDropList() end end))

--// BUILD UI SECTIONS
sectionLabel("⚔  COMBAT")
createToggle("Aura Kill (Murderer + Knife)", "Aura", Color3.fromRGB(255, 80, 80))
createSlider("Aura Range", "AuraRange", 10, 500, " studs")

sectionLabel("🌪  FLING (Cosmic Force)")
createToggle("Fling Murderer", "FlingMurderer", Color3.fromRGB(255, 60, 60))
createToggle("Fling Sheriff", "FlingSheriff", Color3.fromRGB(60, 140, 255))
createToggle("Fling Innocent", "FlingInnocent", Color3.fromRGB(60, 220, 100))

sectionLabel("👁  VISUALS")
createToggle("ESP (Role-Aware)", "ESP", Color3.fromRGB(160, 80, 255))

sectionLabel("🏃  PLAYER MODS")
createToggle("Noclip", "Noclip", Color3.fromRGB(255, 180, 40))
createToggle("Speed Boost", "Speed", Color3.fromRGB(80, 220, 200))
createSlider("Speed Value", "SpeedValue", 16, 200, "")

sectionLabel("🎯  TARGET")
yIndex = yIndex + 1
TargetRow.LayoutOrder = yIndex

--// ICON CLICK
local uiOpen = false
local iconPressTime = nil
local iconPressPos  = nil
addConnection(Icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        iconPressTime = tick()
        iconPressPos  = input.Position
    end
end))
addConnection(Icon.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if iconPressTime and iconPressPos then
            local duration = tick() - iconPressTime
            local moved    = (input.Position - iconPressPos).Magnitude
            if duration < 0.35 and moved < 6 then
                uiOpen = not uiOpen
                Main.Visible = uiOpen
            end
            iconPressTime = nil
            iconPressPos  = nil
        end
    end
end))

addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        uiOpen = not uiOpen
        Main.Visible = uiOpen
    end
end))

Icon.MouseEnter:Connect(function()
    TweenService:Create(Icon, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
end)
Icon.MouseLeave:Connect(function()
    TweenService:Create(Icon, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 28)}):Play()
end)

--// FULL CLEANUP
local function fullCleanup()
    IsDead = true
    for k in pairs(State) do
        if type(State[k]) == "boolean" then State[k] = false end
    end
    clearHighlights()
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}
    pcall(function()
        local hum = getHum(LocalPlayer.Character)
        if hum then hum.WalkSpeed = 16 end
    end)
    task.wait(0.05)
    pcall(function() ScreenGui:Destroy() end)
    _G.MM2_GUI = nil
    _G.MM2_Cleanup = nil
end

CloseBtn.MouseButton1Click:Connect(fullCleanup)

_G.MM2_Cleanup = fullCleanup
print("[MM2 Ultimate] Loaded successfully. Click the M icon to open.")
