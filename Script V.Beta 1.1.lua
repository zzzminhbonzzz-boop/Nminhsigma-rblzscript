-- [[ nminhsigma hub v2 | MAXED PERFORMANCE ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- // CONFIGURATION
getgenv().SETTINGS = {
    Aimbot = false, RageMode = false, WallCheck = true,
    SilentAim = false, HitboxSize = 25,
    ESP = false, Tracers = false, Skeletons = false,
    Fly = false, FlySpeed = 50,
    Speed = false, InfJump = false,
    RainbowUI = false, CustomCursor = false,
    FOVSize = 150, LockPart = "Head",
    AccentColor = Color3.fromRGB(0, 150, 255)
}

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "nminh_sigma_v2"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 500)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
MainFrame.Active = true

local Accent = Instance.new("Frame", MainFrame)
Accent.Size = UDim2.new(1, 0, 0, 2)
Accent.BackgroundColor3 = SETTINGS.AccentColor
Accent.BorderSizePixel = 0

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -10, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 2)
Title.Text = "nminhsigma v2 | DEV"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- // UI HELPER
local function addOption(name, key, y)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 25)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    btn.Text = name .. ": [OFF]"
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.RobotoMono
    btn.TextSize = 12
    
    btn.MouseButton1Click:Connect(function()
        SETTINGS[key] = not SETTINGS[key]
        btn.Text = name .. ": [" .. (SETTINGS[key] and "ON" or "OFF") .. "]"
        btn.TextColor3 = SETTINGS[key] and SETTINGS.AccentColor or Color3.fromRGB(180, 180, 180)
    end)
end

addOption("Aimbot Flick", "Aimbot", 50)
addOption("Wall Check", "WallCheck", 80)
addOption("Silent (Hitbox)", "SilentAim", 110)
addOption("Box ESP", "ESP", 140)
addOption("Tracer ESP", "Tracers", 170)
addOption("Skeleton ESP", "Skeletons", 200)
addOption("WalkSpeed (100)", "Speed", 230)
addOption("Fly Hack", "Fly", 260)
addOption("Rainbow Theme", "RainbowUI", 290)

-- // ESP ENGINE (The drawing part)
local ESP_Store = {}

local function CreateESP(plr)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Transparency = 1
    
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Transparency = 1
    
    ESP_Store[plr] = {Box = box, Tracer = line}
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

-- // MAIN ENGINE
RunService.RenderStepped:Connect(function()
    local hue = tick() % 5 / 5
    local color = SETTINGS.RainbowUI and Color3.fromHSV(hue, 1, 1) or SETTINGS.AccentColor
    Accent.BackgroundColor3 = color

    -- Movement & Speed
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = SETTINGS.Speed and 100 or 16
    end

    -- Hitbox Expand
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if SETTINGS.SilentAim then
                hrp.Size = Vector3.new(SETTINGS.HitboxSize, SETTINGS.HitboxSize, SETTINGS.HitboxSize)
                hrp.Transparency = 0.8
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
            end

            -- ESP Logic
            local esp = ESP_Store[p]
            if esp then
                local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
                if vis and (SETTINGS.ESP or SETTINGS.Tracers) then
                    if SETTINGS.ESP then
                        esp.Box.Visible = true
                        esp.Box.Size = Vector2.new(2500/pos.Z, 3500/pos.Z)
                        esp.Box.Position = Vector2.new(pos.X - esp.Box.Size.X/2, pos.Y - esp.Box.Size.Y/2)
                        esp.Box.Color = color
                    else esp.Box.Visible = false end
                    
                    if SETTINGS.Tracers then
                        esp.Tracer.Visible = true
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                        esp.Tracer.Color = color
                    else esp.Tracer.Visible = false end
                else
                    esp.Box.Visible = false
                    esp.Tracer.Visible = false
                end
            end
        end
    end

    -- Aimbot Flick
    if SETTINGS.Aimbot then
        local target, closest = nil, SETTINGS.FOVSize
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                local pos, vis = Camera:WorldToViewportPoint(head.Position)
                if vis then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < closest then
                        local canSee = true
                        if SETTINGS.WallCheck then
                            local ray = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position), RaycastParams.new())
                            if ray and not ray.Instance:IsDescendantOf(p.Character) then canSee = false end
                        end
                        if canSee then target = head closest = dist end
                    end
                end
            end
        end
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
    end
end)
