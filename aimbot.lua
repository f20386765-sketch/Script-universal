-- // KATANA HUB NEXT GEN - v1.0 // --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- // CONFIGURAÇÕES GLOBAIS // --
_G.KatanaConfig = {
    -- Combat
    Aimbot = false,
    Smoothness = 0.1, -- Suavidade da mira
    
    -- Visuals (Os 4 Tipos de ESP)
    ESP_Box = false,
    ESP_Tracers = false,
    ESP_Health = false,
    ESP_Names = false,
    
    -- Settings
    TeamCheck = true
}

-- // MOTOR DE FILTRAGEM (TEAM CHECK) // --
local function GetTarget(p)
    if p == lp or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return false end
    local hum = p.Character:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    -- Team Check Automático
    if _G.KatanaConfig.TeamCheck and p.Team == lp.Team and p.Team ~= nil then
        return false
    end
    return true
end

-- // INTERFACE PREMUM // --
local gui = Instance.new("ScreenGui", CoreGui)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 420, 0, 300); main.Position = UDim2.new(0.5, -210, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BorderSizePixel = 0; main.Visible = false; main.Active = true; main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 110, 1, 0); sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10); sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar)

local container = Instance.new("Frame", main)
container.Size = UDim2.new(0, 290, 0, 240); container.Position = UDim2.new(0, 120, 0, 50); container.BackgroundTransparency = 1

local tabs = { Combat = Instance.new("Frame", container), Visuals = Instance.new("Frame", container) }
for _, t in pairs(tabs) do t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.Visible = false end
tabs.Combat.Visible = true

-- Funções de UI (Toggle e Abas)
local function NewToggle(name, parent, y, config_key)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.95, 0, 0, 35); b.Position = UDim2.new(0, 0, 0, y); b.Text = "  " .. name; b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = "Left"; b.Font = "GothamSemibold"
    Instance.new("UICorner", b)
    local status = Instance.new("Frame", b); status.Size = UDim2.new(0, 8, 1, 0); status.Position = UDim2.new(1, -8, 0, 0); status.BackgroundColor3 = Color3.fromRGB(40,40,40); Instance.new("UICorner", status)
    
    b.Activated:Connect(function()
        _G.KatanaConfig[config_key] = not _G.KatanaConfig[config_key]
        status.BackgroundColor3 = _G.KatanaConfig[config_key] and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(40, 40, 40)
    end)
end

-- Configurar Abas
NewToggle("Aimbot Full Head", tabs.Combat, 0, "Aimbot")
NewToggle("Team Check", tabs.Combat, 40, "TeamCheck")

NewToggle("Box ESP", tabs.Visuals, 0, "ESP_Box")
NewToggle("Tracers", tabs.Visuals, 40, "ESP_Tracers")
NewToggle("Health Bar", tabs.Visuals, 80, "ESP_Health")
NewToggle("Names", tabs.Visuals, 120, "ESP_Names")

-- // MOTOR DE ESP (4 TIPOS) // --
local function CreateESP(p)
    local Box = Drawing.new("Square"); Box.Visible = false; Box.Color = Color3.new(1,0,0); Box.Thickness = 1
    local Tracer = Drawing.new("Line"); Tracer.Visible = false; Tracer.Color = Color3.new(1,1,1)
    local NameTag = Drawing.new("Text"); NameTag.Visible = false; NameTag.Size = 14; NameTag.Center = true; NameTag.Outline = true; NameTag.Color = Color3.new(1,1,1)
    local Health = Drawing.new("Line"); Health.Visible = false; Health.Thickness = 2

    RunService.RenderStepped:Connect(function()
        if GetTarget(p) then
            local root = p.Character.HumanoidRootPart
            local pos, onScreen = cam:WorldToViewportPoint(root.Position)
            if onScreen then
                local sX, sY = 2200/pos.Z, 3500/pos.Z
                
                -- Box
                Box.Visible = _G.KatanaConfig.ESP_Box
                Box.Size = Vector2.new(sX, sY); Box.Position = Vector2.new(pos.X - sX/2, pos.Y - sY/2)
                
                -- Tracer
                Tracer.Visible = _G.KatanaConfig.ESP_Tracers
                Tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y); Tracer.To = Vector2.new(pos.X, pos.Y + sY/2)
                
                -- Name
                NameTag.Visible = _G.KatanaConfig.ESP_Names
                NameTag.Text = p.Name; NameTag.Position = Vector2.new(pos.X, pos.Y - sY/2 - 15)
                
                -- Health
                Health.Visible = _G.KatanaConfig.ESP_Health
                local hp = p.Character.Humanoid.Health / p.Character.Humanoid.MaxHealth
                Health.From = Vector2.new(pos.X - sX/2 - 5, pos.Y + sY/2)
                Health.To = Vector2.new(pos.X - sX/2 - 5, pos.Y + sY/2 - (sY * hp))
                Health.Color = Color3.fromHSV(hp * 0.3, 1, 1)
            else Box.Visible = false; Tracer.Visible = false; NameTag.Visible = false; Health.Visible = false end
        else Box.Visible = false; Tracer.Visible = false; NameTag.Visible = false; Health.Visible = false end
    end)
end

-- Inicializar Jogadores
for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- // AIMBOT FULL HEAD // --
RunService.RenderStepped:Connect(function()
    if _G.KatanaConfig.Aimbot then
        local target, dist = nil, 250
        for _, v in pairs(Players:GetPlayers()) do
            if GetTarget(v) then
                local head = v.Character:FindFirstChild("Head")
                local p, onS = cam:WorldToViewportPoint(head.Position)
                if onS then
                    local m = (Vector2.new(p.X, p.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                    if m < dist then target = head; dist = m end
                end
            end
        end
        if target then
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Position), _G.KatanaConfig.Smoothness)
        end
    end
end)

-- Botão Abrir
local btn = Instance.new("TextButton", gui); btn.Size = UDim2.new(0,40,0,40); btn.Position = UDim2.new(0,10,0.5,0); btn.Text = "K"; btn.Activated:Connect(function() main.Visible = not main.Visible end)

print("✅ Novo Katana Hub Iniciado!")
