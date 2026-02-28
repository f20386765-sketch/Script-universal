-- // KATANA HUB V2 - MOBILE FIXED // --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- // CONFIGS // --
_G.KatanaMaster = false
_G.FOVSize = 120

-- // FOV CIRCLE (SÓ A LINHA, SEM PREENCHIMENTO) // --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Radius = _G.FOVSize
FOVCircle.Filled = false -- AQUI: Deixa transparente no meio
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Visible = false

-- // ESP CLEAN (BOX + NOME) // --
local function CreateESP(plr)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 1
    Box.Filled = false

    local Name = Drawing.new("Text")
    Name.Visible = false
    Name.Color = Color3.new(1, 1, 1)
    Name.Size = 14
    Name.Center = true
    Name.Outline = true

    RunService.RenderStepped:Connect(function()
        if _G.KatanaMaster and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr ~= lp and plr.Character.Humanoid.Health > 0 then
            local rootPos, onScreen = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local sizeX = 2000 / rootPos.Z
                local sizeY = 3000 / rootPos.Z
                
                Box.Size = Vector2.new(sizeX, sizeY)
                Box.Position = Vector2.new(rootPos.X - sizeX / 2, rootPos.Y - sizeY / 2)
                Box.Visible = true
                
                Name.Text = plr.Name
                Name.Position = Vector2.new(rootPos.X, rootPos.Y - (sizeY / 2) - 15)
                Name.Visible = true
            else
                Box.Visible = false
                Name.Visible = false
            end
        else
            Box.Visible = false
            Name.Visible = false
        end
    end)
end

for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- // AIMBOT SMOOTH HEAD (MÉTODO SEGURO) // --
local function GetClosest()
    local target, dist = nil, _G.FOVSize
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            local pos, vis = cam:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < dist then target = v dist = mag end
            end
        end
    end
    return target
end

-- // LOOP PRINCIPAL // --
RunService.RenderStepped:Connect(function()
    if _G.KatanaMaster then
        FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        FOVCircle.Visible = true
        
        local t = GetClosest()
        if t then
            -- Mira suave na cabeça (0.15 é a velocidade, quanto menor, mais disfarçado)
            local targetCF = CFrame.new(cam.CFrame.Position, t.Character.Head.Position)
            cam.CFrame = cam.CFrame:Lerp(targetCF, 0.15)
        end
    else
        FOVCircle.Visible = false
    end
end)

-- // MENU MOBILE (BOTÃO FLUTUANTE) // --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.Text = "K"
OpenBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 180, 0, 90)
Main.Position = UDim2.new(0.5, -90, 0.5, -45)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Visible = false
Instance.new("UICorner", Main)

local MasterBtn = Instance.new("TextButton", Main)
MasterBtn.Size = UDim2.new(0.9, 0, 0, 45)
MasterBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
MasterBtn.Text = "OFF"
MasterBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MasterBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MasterBtn)

OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
MasterBtn.MouseButton1Click:Connect(function()
    _G.KatanaMaster = not _G.KatanaMaster
    MasterBtn.Text = _G.KatanaMaster and "KATANA ON" or "KATANA OFF"
    MasterBtn.BackgroundColor3 = _G.KatanaMaster and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
end)
