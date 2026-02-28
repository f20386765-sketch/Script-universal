-- // KATANA HUB - EXCLUSIVE OWNER PANEL // --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- // CONFIGS EXCLUSIVAS DO DONO // --
_G.OwnerAimbot = true
_G.RainbowESP = true
_G.Tracers = true

-- // 1. MIRA SUPREMA (INSTA-LOCK 1.0) // --
-- Sobrescreve a mira comum com a força máxima
RunService.RenderStepped:Connect(function()
    if _G.KatanaMaster and _G.OwnerAimbot then
        local target = nil
        local dist = 500 -- FOV Gigante para o Dono
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                local p, vis = cam:WorldToViewportPoint(v.Character.Head.Position)
                if vis then
                    local m = (Vector2.new(p.X, p.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                    if m < dist then target = v; dist = m end
                end
            end
        end
        if target then
            -- Sem suavidade, trava direta
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- // 2. RAINBOW ESP & TRACERS // --
local function AdminVisuals(plr)
    local Line = Drawing.new("Line")
    Line.Visible = false
    Line.Thickness = 1
    Line.Transparency = 1

    RunService.RenderStepped:Connect(function()
        if _G.KatanaMaster and _G.Tracers and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr ~= lp and plr.Character.Humanoid.Health > 0 then
            local pos, vis = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if vis then
                -- Cor Arco-íris (Rainbow)
                local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                
                Line.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y) -- Linha sai de baixo
                Line.To = Vector2.new(pos.X, pos.Y)
                Line.Color = color
                Line.Visible = true
            else Line.Visible = false end
        else Line.Visible = false end
    end)
end
for _, v in pairs(Players:GetPlayers()) do AdminVisuals(v) end
Players.PlayerAdded:Connect(AdminVisuals)

-- // 3. INTERFACE EXCLUSIVA (PAINEL DO DONO) // --
local sg = Instance.new("ScreenGui", CoreGui)
local ownerFrame = Instance.new("Frame", sg)
ownerFrame.Size = UDim2.new(0, 150, 0, 150)
ownerFrame.Position = UDim2.new(0, 10, 0.7, 0)
ownerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ownerFrame.BorderSizePixel = 2
ownerFrame.BorderColor3 = Color3.fromRGB(255, 215, 0) -- Borda Dourada
Instance.new("UICorner", ownerFrame)

local title = Instance.new("TextLabel", ownerFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "OWNER TOOLS"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold

local tglTracers = Instance.new("TextButton", ownerFrame)
tglTracers.Size = UDim2.new(0.9, 0, 0, 35)
tglTracers.Position = UDim2.new(0.05, 0, 0.3, 0)
tglTracers.Text = "TRACERS: ON"
tglTracers.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tglTracers.TextColor3 = Color3.new(1, 1, 1)

local tglAimbot = Instance.new("TextButton", ownerFrame)
tglAimbot.Size = UDim2.new(0.9, 0, 0, 35)
tglAimbot.Position = UDim2.new(0.05, 0, 0.6, 0)
tglAimbot.Text = "INSTA-LOCK: ON"
tglAimbot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tglAimbot.TextColor3 = Color3.new(1, 1, 1)

-- Eventos dos Botões
tglTracers.MouseButton1Click:Connect(function()
    _G.Tracers = not _G.Tracers
    tglTracers.Text = _G.Tracers and "TRACERS: ON" or "TRACERS: OFF"
end)

tglAimbot.MouseButton1Click:Connect(function()
    _G.OwnerAimbot = not _G.OwnerAimbot
    tglAimbot.Text = _G.OwnerAimbot and "INSTA-LOCK: ON" or "INSTA-LOCK: OFF"
end)

warn("PAINEL SUPREMO DO DONO CARREGADO COM SUCESSO!")
