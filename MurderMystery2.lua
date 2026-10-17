-- ==============================================================================
-- 🚀 DELTA HUB - MM2 ULTIMATE MASTER PRO GOD-TIER EDITION (FULL SCRIPT)
-- ==============================================================================

if not getgenv then
    print("Executor ของคุณไม่รองรับฟังก์ชัน getgenv")
    return
end

-- เคลียร์การเชื่อมต่อและ UI เก่าทั้งหมด
if getgenv().MM2_LoadedUI then
    pcall(function() getgenv().MM2_LoadedUI:Destroy() end)
end

if getgenv().MM2_Connection then getgenv().MM2_Connection:Disconnect() end
if getgenv().MM2_NoclipConnection then getgenv().MM2_NoclipConnection:Disconnect() end
if getgenv().MM2_CoinConnection then getgenv().MM2_CoinConnection:Disconnect() end
if getgenv().MM2_SpeedConnection then getgenv().MM2_SpeedConnection:Disconnect() end
if getgenv().MM2_AuraConnection then getgenv().MM2_AuraConnection:Disconnect() end
if getgenv().MM2_FlingConnection then getgenv().MM2_FlingConnection:Disconnect() end
if getgenv().MM2_AimConnection then getgenv().MM2_AimConnection:Disconnect() end
if getgenv().MM2_PlayerRemoving then getgenv().MM2_PlayerRemoving:Disconnect() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Noclip = false,
    AutoCoin = false,
    WalkSpeed = false,
    AuraKill = false,
    FlingMurderer = false,
    SheriffAimbot = false,
    SpeedValue = 27,
    CoinSpeed = 9,
    AuraRange = 200,
    AimRange = 100
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_GodTier_Gui"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end
getgenv().MM2_LoadedUI = ScreenGui

-- 🌟 Cyberpunk Floating Button (ปุ่มลอยเปิด/ปิดเมนู)
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 56, 0, 56)
FloatingBtn.Position = UDim2.new(0, 30, 0.4, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
FloatingBtn.Text = "⚡"
FloatingBtn.TextColor3 = Color3.fromRGB(0, 255, 204)
FloatingBtn.TextSize = 26
FloatingBtn.Font = Enum.Font.GothamBlack
FloatingBtn.Active = true
FloatingBtn.Draggable = true
FloatingBtn.Parent = ScreenGui

Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingBtn)
FloatStroke.Color = Color3.fromRGB(0, 255, 204)
FloatStroke.Thickness = 2.5

-- 🌟 Cyberpunk Main Window (หน้าต่างหลัก)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 470)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -235)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 255, 204)
MainStroke.Thickness = 1.5

local HeaderGlow = Instance.new("Frame")
HeaderGlow.Size = UDim2.new(1, 0, 0, 3)
HeaderGlow.Position = UDim2.new(0, 0, 0, 42)
HeaderGlow.BackgroundColor3 = Color3.fromRGB(0, 255, 204)
HeaderGlow.BorderSizePixel = 0
HeaderGlow.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 42)
Title.BackgroundTransparency = 1
Title.Text = "⚡ MM2 GOD-TIER HUB ⚡"
Title.TextColor3 = Color3.fromRGB(0, 255, 204)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBlack
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 38)
StatusLabel.Position = UDim2.new(0, 10, 0, 52)
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
StatusLabel.Text = "บทบาท: กำลังตรวจสอบ..."
StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Parent = MainFrame

Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 8)
local StatusStroke = Instance.new("UIStroke", StatusLabel)
StatusStroke.Color = Color3.fromRGB(50, 50, 80)
StatusStroke.Thickness = 1

local function CreateButton(text, posY, settingKey)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 40)
    Btn.Position = UDim2.new(0, 10, 0, posY)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Btn.Text = text .. " : [ OFF ]"
    Btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = MainFrame
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Color = Color3.fromRGB(50, 50, 80)
    BtnStroke.Thickness = 1

    Btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        if Settings[settingKey] then
            Btn.Text = text .. " : [ ON ]"
            Btn.TextColor3 = Color3.fromRGB(0, 255, 128)
            BtnStroke.Color = Color3.fromRGB(0, 255, 128)
        else
            Btn.Text = text .. " : [ OFF ]"
            Btn.TextColor3 = Color3.fromRGB(255, 80, 80)
            BtnStroke.Color = Color3.fromRGB(50, 50, 80)
        end
    end)
    return Btn
end

CreateButton("Noclip (Ultimate)", 100, "Noclip")
CreateButton("WalkSpeed (27)", 146, "WalkSpeed")
CreateButton("Auto Coin (Fixed Speed 9)", 192, "AutoCoin")
CreateButton("Aura Kill (200m)", 238, "AuraKill")
CreateButton("Sheriff Smooth Aimbot", 284, "SheriffAimbot")
CreateButton("God Fling Murderer", 330, "FlingMurderer")

local uiVisible = true
FloatingBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
end)

local RoleCache = {}
local HighlightCache = {}
local GunCache = {}

local function RemoveHighlight(player)
    if HighlightCache[player] then
        if HighlightCache[player].Highlight then HighlightCache[player].Highlight:Destroy() end
        if HighlightCache[player].NameText then HighlightCache[player].NameText:Remove() end
        HighlightCache[player] = nil
    end
    RoleCache[player] = nil
end

local function RemoveGunESP(gun)
    if GunCache[gun] then
        if GunCache[gun].Box then GunCache[gun].Box:Remove() end
        if GunCache[gun].Text then GunCache[gun].Text:Remove() end
        GunCache[gun] = nil
    end
end

local function UpdatePlayerRole(player)
    local char = player.Character
    if not char then return "Innocent" end
    
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("StringValue") or child:IsA("ObjectValue") then
            local val = tostring(child.Value):lower()
            if val:find("murder") then return "Murderer"
            elseif val:find("sheriff") then return "Sheriff" end
        end
    end

    local roleValue = player:FindFirstChild("Role") or char:FindFirstChild("Role")
    if roleValue and roleValue:IsA("StringValue") then
        local val = roleValue.Value:lower()
        if val:find("murder") then return "Murderer"
        elseif val:find("sheriff") then return "Sheriff" end
    end

    local function checkContainer(container)
        if not container then return nil end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") or name:find("blade") or name:find("murderer") then
                    return "Murderer"
                elseif name:find("gun") or name:find("revolver") or name:find("sheriff") then
                    return "Sheriff"
                end
            end
        end
        return nil
    end

    local role = checkContainer(char)
    if role then return role end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        role = checkContainer(backpack)
        if role then return role end
    end
    
    return "Innocent"
end

local function SetupPlayerTracking(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        RoleCache[player] = UpdatePlayerRole(player)
    end)
    if player.Character then
        RoleCache[player] = UpdatePlayerRole(player)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    SetupPlayerTracking(p)
end

Players.PlayerAdded:Connect(SetupPlayerTracking)
getgenv().MM2_PlayerRemoving = Players.PlayerRemoving:Connect(RemoveHighlight)

local OriginalCanCollide = {}
getgenv().MM2_NoclipConnection = RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end

    if Settings.Noclip or Settings.AutoCoin or Settings.FlingMurderer then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if OriginalCanCollide[part] == nil then
                    OriginalCanCollide[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    else
        for part, canCollide in pairs(OriginalCanCollide) do
            if part and part:IsDescendantOf(Workspace) then
                part.CanCollide = canCollide
            end
        end
        table.clear(OriginalCanCollide)
    end
end)

getgenv().MM2_SpeedConnection = RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health > 0 and Settings.WalkSpeed then
        humanoid.WalkSpeed = Settings.SpeedValue
    end
end)

getgenv().MM2_AuraConnection = RunService.Heartbeat:Connect(function()
    if not Settings.AuraKill then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    local myRole = RoleCache[LocalPlayer] or UpdatePlayerRole(LocalPlayer)
    local activeTool = char:FindFirstChildOfClass("Tool")
    local toolName = activeTool and activeTool.Name:lower() or ""
    local holdingKnife = (myRole == "Murderer") or (toolName:find("knife") or toolName:find("blade"))
    local holdingGun = (myRole == "Sheriff") or (toolName:find("gun") or toolName:find("revolver"))

    if holdingKnife then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local pChar = player.Character
                local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart")
                local pHumanoid = pChar and pChar:FindFirstChild("Humanoid")
                
                if pHrp and pHumanoid and pHumanoid.Health > 0 then
                    local dist = (hrp.Position - pHrp.Position).Magnitude
                    if dist <= Settings.AuraRange then
                        pcall(function()
                            if activeTool and activeTool:FindFirstChild("Handle") then
                                firetouchinterest(activeTool.Handle, pHrp, 0)
                                firetouchinterest(activeTool.Handle, pHrp, 1)
                            end
                        end)
                    end
                end
            end
        end
    elseif holdingGun then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local targetRole = RoleCache[player] or "Innocent"
                if targetRole == "Murderer" then
                    local pChar = player.Character
                    local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart")
                    local pHumanoid = pChar and pChar:FindFirstChild("Humanoid")
                    
                    if pHrp and pHumanoid and pHumanoid.Health > 0 then
                        local dist = (hrp.Position - pHrp.Position).Magnitude
                        if dist <= Settings.AuraRange then
                            pcall(function()
                                local shootEvent = activeTool and (activeTool:FindFirstChild("Shoot") or activeTool:FindFirstChild("Remote") or activeTool:FindFirstChild("GunEvent"))
                                if shootEvent and shootEvent:IsA("RemoteEvent") then
                                    shootEvent:FireServer(pHrp.Position, pHrp)
                                else
                                    for _, descendant in ipairs(activeTool:GetDescendants()) do
                                        if descendant:IsA("RemoteEvent") then
                                            descendant:FireServer(pHrp.Position, pHrp)
                                        end
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end)

getgenv().MM2_AimConnection = RunService.RenderStepped:Connect(function()
    if not Settings.SheriffAimbot then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local myRole = RoleCache[LocalPlayer] or UpdatePlayerRole(LocalPlayer)
    local activeTool = char:FindFirstChildOfClass("Tool")
    local toolName = activeTool and activeTool.Name:lower() or ""
    local isSheriff = (myRole == "Sheriff") or (toolName:find("gun") or toolName:find("revolver"))

    if not isSheriff or not activeTool then return end

    local isAimingOrShooting = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UserInputService.TouchEnabled

    if isAimingOrShooting then
        local targetHrp = nil
        local shortestDist = Settings.AimRange

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and RoleCache[player] == "Murderer" then
                local pChar = player.Character
                local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart")
                local pHumanoid = pChar and pChar:FindFirstChild("Humanoid")
                if pHrp and pHumanoid and pHumanoid.Health > 0 then
                    local dist = (hrp.Position - pHrp.Position).Magnitude
                    if dist <= shortestDist then
                        shortestDist = dist
                        targetHrp = pHrp
                    end
                end
            end
        end

        if targetHrp then
            pcall(function()
                local targetPos = targetHrp.Position + Vector3.new(0, 0.2, 0)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            end)
        end
    end
end)

local spinAngle = 0
getgenv().MM2_FlingConnection = RunService.Heartbeat:Connect(function()
    if not Settings.FlingMurderer then 
        spinAngle = 0
        return 
    end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    local murdererHrp = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and RoleCache[p] == "Murderer" then
            local pChar = p.Character
            if pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChild("Humanoid") and pChar.Humanoid.Health > 0 then
                murdererHrp = pChar.HumanoidRootPart
                break
            end
        end
    end

    if murdererHrp then
        spinAngle = spinAngle + 180
        local offset = Vector3.new(math.cos(math.rad(spinAngle)) * 1.2, 0.5, math.sin(math.rad(spinAngle)) * 1.2)
        hrp.CFrame = murdererHrp.CFrame + offset
        
        hrp.Velocity = Vector3.new(0, 50, 0)
        hrp.RotVelocity = Vector3.new(0, 999999, 0)
        
        pcall(function()
            murdererHrp.Velocity = Vector3.new(math.random(-9999999, 9999999), 9999999, math.random(-9999999, 9999999))
            murdererHrp.RotVelocity = Vector3.new(math.random(-9999999, 9999999), 9999999, math.random(-9999999, 9999999))
        end)
    end
end)

local processedCoins = {}
LocalPlayer.CharacterAdded:Connect(function(newChar)
    table.clear(processedCoins)
end)

getgenv().MM2_CoinConnection = RunService.Heartbeat:Connect(function()
    if not Settings.AutoCoin or Settings.FlingMurderer then return end

    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or humanoid.Health <= 0 or not hrp then return end

    local coinContainer = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("CoinContainer")
    if not coinContainer then
        for _, v in ipairs(Workspace:GetChildren()) do
            if v:FindFirstChild("CoinContainer") then
                coinContainer = v.CoinContainer
                break
            end
        end
    end

    if coinContainer then
        local coinChildren = coinContainer:GetChildren()
        if #coinChildren == 0 then table.clear(processedCoins) return end

        local closestCoin = nil
        local shortestDist = math.huge

        for _, coin in ipairs(coinChildren) do
            if (coin.Name == "Coin" or coin:FindFirstChild("CoinVisual")) and not processedCoins[coin] then
                local coinPart = coin:IsA("BasePart") and coin or coin:FindFirstChildWhichIsA("BasePart")
                if coinPart then
                    local dist = (hrp.Position - coinPart.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestCoin = coin
                    end
                end
            end
        end

        if closestCoin then
            local coinPart = closestCoin:IsA("BasePart") and closestCoin or closestCoin:FindFirstChildWhichIsA("BasePart")
            if coinPart then
                local targetPos = coinPart.Position - Vector3.new(0, 0.5, 0)
                local currentPos = hrp.Position
                local distance = (targetPos - currentPos).Magnitude

                if distance < 2.5 then
                    processedCoins[closestCoin] = true
                end

                if distance > 0.5 then
                    local moveDir = (targetPos - currentPos).Unit
                    humanoid.WalkSpeed = Settings.CoinSpeed
                    humanoid:Move(moveDir)
                    humanoid.AutoRotate = true
                    hrp.Velocity = Vector3.new(moveDir.X * Settings.CoinSpeed, hrp.Velocity.Y, moveDir.Z * Settings.CoinSpeed)
                else
                    humanoid:Move(Vector3.new(0, 0, 0))
                    hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
                end
            end
        end
    end
end)

local lastUpdate = 0
getgenv().MM2_Connection = RunService.RenderStepped:Connect(function()
    local tickTime = tick()
    
    if tickTime - lastUpdate >= 0.03 then
        lastUpdate = tickTime
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                RoleCache[player] = UpdatePlayerRole(player)
            end
        end
    end

    local myRole = RoleCache[LocalPlayer] or UpdatePlayerRole(LocalPlayer)
    StatusLabel.Text = "บทบาทของคุณ: " .. myRole

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pChar = player.Character
            if pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChild("Humanoid") and pChar.Humanoid.Health > 0 then
                
                local targetRole = RoleCache[player] or "Innocent"
                local showHighlight = false
                local highlightColor = Color3.fromRGB(231, 76, 60)

                if myRole == "Innocent" then
                    if targetRole == "Murderer" then showHighlight = true; highlightColor = Color3.fromRGB(255, 60, 60)
                    elseif targetRole == "Sheriff" then showHighlight = true; highlightColor = Color3.fromRGB(60, 150, 255) end
                elseif myRole == "Murderer" then
                    if targetRole == "Sheriff" then showHighlight = true; highlightColor = Color3.fromRGB(60, 150, 255)
                    elseif targetRole == "Innocent" then showHighlight = true; highlightColor = Color3.fromRGB(255, 255, 255) end
                elseif myRole == "Sheriff" then
                    if targetRole == "Murderer" then showHighlight = true; highlightColor = Color3.fromRGB(255, 60, 60) end
                end

                if not HighlightCache[player] then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = pChar
                    hl.Parent = pChar
                    hl.Enabled = false
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    
                    local nameText = Drawing.new("Text")
                    nameText.Visible = false; nameText.Size = 13; nameText.Center = true; nameText.Outline = true
                    HighlightCache[player] = {Highlight = hl, NameText = nameText}
                end

                local cache = HighlightCache[player]
                
                if cache.Highlight.Adornee ~= pChar then
                    cache.Highlight.Adornee = pChar
                    cache.Highlight.Parent = pChar
                end

                if showHighlight then
                    cache.Highlight.FillColor = highlightColor
                    cache.Highlight.OutlineColor = highlightColor
                    cache.Highlight.Enabled = true
                    cache.NameText.Color = highlightColor

                    local rootPart = pChar.HumanoidRootPart
                    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

                    if onScreen then
                        local head = pChar:FindFirstChild("Head")
                        local topPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or vector

                        local distStr = myHrp and (" [" .. math.floor((myHrp.Position - rootPart.Position).Magnitude) .. "m]") or ""
                        cache.NameText.Text = "[" .. targetRole .. "]" .. distStr
                        cache.NameText.Position = Vector2.new(vector.X, topPos.Y - 20)
                        cache.NameText.Visible = true
                    else
                        cache.NameText.Visible = false
                    end
                else
                    cache.Highlight.Enabled = false
                    cache.NameText.Visible = false
                end
            else
                RemoveHighlight(player)
            end
        end
    end

    local activeGuns = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("revolver") or obj.Name:lower():find("drop")) then
            local isEquipped = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and (obj:IsDescendantOf(p.Character) or obj:IsDescendantOf(p:FindFirstChild("Backpack"))) then
                    isEquipped = true
                    break
                end
            end

            if not isEquipped then
                activeGuns[obj] = true
                
                if not GunCache[obj] then
                    local box = Drawing.new("Square")
                    box.Visible = false; box.Color = Color3.fromRGB(255, 105, 180); box.Thickness = 1.5; box.Filled = false
                    local text = Drawing.new("Text")
                    text.Visible = false; text.Color = Color3.fromRGB(255, 105, 180); text.Size = 13; text.Center = true; text.Outline = true
                    GunCache[obj] = {Box = box, Text = text}
                end

                local targetPart = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                
                if targetPart and targetPart:IsA("BasePart") then
                    local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        GunCache[obj].Box.Size = Vector2.new(22, 22)
                        GunCache[obj].Box.Position = Vector2.new(vector.X - 11, vector.Y - 11)
                        GunCache[obj].Box.Visible = true

                        local gunDistStr = myHrp and (" [" .. math.floor((myHrp.Position - targetPart.Position).Magnitude) .. "m]") or ""
                        GunCache[obj].Text.Text = "[Dropped Gun]" .. gunDistStr
                        GunCache[obj].Text.Position = Vector2.new(vector.X, vector.Y - 26)
                        GunCache[obj].Text.Visible = true
                    else
                        GunCache[obj].Box.Visible = false
                        GunCache[obj].Text.Visible = false
                    end
                end
            end
        end
    end

    for gun, _ in pairs(GunCache) do
        if not activeGuns[gun] or not gun.Parent then
            RemoveGunESP(gun)
        end
    end
end)

print("⚡ MM2 God-Tier Master Pro Edition Loaded Successfully!")
