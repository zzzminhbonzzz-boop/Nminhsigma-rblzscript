local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- // Configuration
local SETTINGS = {
    Aimbot = false,
    SilentAim = false, 
    ESP = false,
    Noclip = false,
    Fly = false,
    Speed = false,      -- New
    Jump = false,       -- New
    InfJump = false,    -- New
    WallCheck = true,
    LockPart = "Head",
    HitboxSize = 15
}

-- // UI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "nminhsigma_hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 420) -- Increased height for more buttons
MainFrame.Position = UDim2.new(0.5, -110, 0.4, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true -- Ensure it starts visible

-- Accent Border (Top)
local Accent = Instance.new("Frame", MainFrame)
Accent.Size = UDim2.new(1, 0, 0, 2)
Accent.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Accent.BorderSizePixel = 0

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -10, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 2)
Title.Text = "nminhsigma hub"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Master Toggle Button
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 80, 0, 35)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.05, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleBtn.Text = "TOGGLE"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
ToggleBtn.Font = Enum.Font.RobotoMono
ToggleBtn.BorderSizePixel = 1
ToggleBtn.BorderColor3 = Color3.fromRGB(0, 150, 255)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Fixed Helper for Tech-Style Checkboxes
local function addOption(name, key, y)
    local box = Instance.new("TextButton")
    box.Name = name.."_Box"
    box.Parent = MainFrame -- Explicit Parent
    box.Size = UDim2.new(0, 16, 0, 16)
    box.Position = UDim2.new(0, 15, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    box.BorderColor3 = Color3.fromRGB(40, 40, 40)
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(0, 150, 255)
    box.Font = Enum.Font.RobotoMono

    local label = Instance.new("TextButton")
    label.Name = name.."_Label"
    label.Parent = MainFrame -- Explicit Parent
    label.Size = UDim2.new(0, 160, 0, 16)
    label.Position = UDim2.new(0, 40, 0, y)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.RobotoMono
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local function toggle()
        SETTINGS[key] = not SETTINGS[key]
        box.Text = SETTINGS[key] and "X" or ""
        label.TextColor3 = SETTINGS[key] and Color3.new(1, 1, 1) or Color3.fromRGB(180, 180, 180)
    end
    box.MouseButton1Click:Connect(toggle)
    label.MouseButton1Click:Connect(toggle)
end

-- // EXPANDED LIST (Adjusted Y spacing)
addOption("Aimbot Snap", "Aimbot", 50)
addOption("Silent Hitbox", "SilentAim", 85)
addOption("Visual ESP", "ESP", 120)
addOption("Wall Check", "WallCheck", 155)
addOption("Noclip Mode", "Noclip", 190)
addOption("Fly Hack", "Fly", 225)
addOption("Infinite Jump", "InfJump", 260)
addOption("WalkSpeed (100)", "Speed", 295)
addOption("JumpPower (150)", "Jump", 330)

-- // COMBAT LOGIC
local function getTarget()
    local target, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local part = p.Character:FindFirstChild(SETTINGS.LockPart)
            if part then
                local pos, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local canSee = true
                    if SETTINGS.WallCheck then
                        local ray = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), RaycastParams.new())
                        if ray and not ray.Instance:IsDescendantOf(p.Character) then canSee = false end
                    end
                    if canSee then
                        local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if mDist < dist then target = p.Character dist = mDist end
                    end
                end
            end
        end
    end
    return target
end

-- Physics Objects
local bv = Instance.new("BodyVelocity")
local bg = Instance.new("BodyGyro")

-- Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
    if SETTINGS.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    -- Movement Mods
    if hum then
        hum.WalkSpeed = SETTINGS.Speed and 100 or 16
        hum.JumpPower = SETTINGS.Jump and 150 or 50
    end

    -- Combat
    if SETTINGS.Aimbot then
        local t = getTarget()
        if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t[SETTINGS.LockPart].Position) end
    end

    if SETTINGS.Fly and root then
        bv.Parent, bg.Parent = root, root
        bv.MaxForce, bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9), Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Camera.CFrame.LookVector * 50
        bg.CFrame = Camera.CFrame
    else
        bv.MaxForce, bg.MaxTorque = Vector3.new(0,0,0), Vector3.new(0,0,0)
    end

    if SETTINGS.Noclip and char then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end

    -- Silent Aim / Hitbox
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local eRoot = p.Character.HumanoidRootPart
            if SETTINGS.SilentAim and p.Character.Humanoid.Health > 0 then
                eRoot.Size = Vector3.new(SETTINGS.HitboxSize, SETTINGS.HitboxSize, SETTINGS.HitboxSize)
                eRoot.Transparency = 0.8
            else
                eRoot.Size = Vector3.new(2, 2, 1)
                eRoot.Transparency = 1
            end
        end
    end
end)
