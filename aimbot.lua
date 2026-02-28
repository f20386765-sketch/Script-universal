-- // KATANA HUB V2 - MOBILE EDITION // --
-- // AIMBOT HEAD + ESP BOX | SEM LOGIN // --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- // CONFIGURAÇÕES // --
_G.KatanaMaster = false
_G.FOVSize = 100 -- Tamanho do círculo de mira no telemóvel

-- // SISTEMA DE DESENHO (FOV) // --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 50
FOVCircle.Radius = _G.FOVSize
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Visible = false

-- // FUNÇÃO PARA ENCONTRAR A CABEÇA MAIS PRÓXIMA // --
local function GetClosestPlayer()
    local target = nil
    local dist = _G.FOVSize
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, vis = cam:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if magnitude < dist then
                    target = v
                    dist = magnitude
                end
            end
        end
    end
    return target
end

-- // SILENT AIM (METATABLE MOBILE) // --
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if _G.KatanaMaster and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local t = GetClosestPlayer()
        if t then
            if method == "Raycast" then
                args[2] = (t.Character.Head.Position - args[1]).Unit * 1000
            else
                args[1] = Ray.new(cam.CFrame.Position, (t.Character.Head.Position - cam.CFrame.Position).Unit * 1000)
            end
            return old(self, unpack(args))
        end
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- // SISTEMA DE ESP (BOX + NAME) // --
local function CreateESP(plr)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 1
    Box.Filled = false

    local Name = Drawing.new("Text")
    Name.Visible = false
    Name.Color = Color3.fromRGB(255, 255, 255)
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

-- // INTERFACE MOBILE // --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "KatanaMobile"

-- Botão Flutuante (Para abrir/fechar o menu no Touch)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
OpenBtn.Text = "K"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextSize = 25
local CornerBtn = Instance.new("UICorner", OpenBtn)
CornerBtn.CornerRadius = UDim.new(1, 0)

-- Menu Principal
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 150)
Main.Position = UDim2.new(0.5, -100, 0.5, -75)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Visible = false
local MainCorner = Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "KATANA HUB MOBILE"
Title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", Title)

local MasterBtn = Instance.new("TextButton", Main)
MasterBtn.Size = UDim2.new(0.9, 0, 0, 50)
MasterBtn.Position = UDim2.new(0.05, 0, 0, 60)
MasterBtn.Text = "ATIVAR KATANA (OFF)"
MasterBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MasterBtn.TextColor3 = Color3.new(1, 1, 1)
MasterBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", MasterBtn)

-- Arrastar o botão flutuante (Importante para Mobile)
local dragging, dragInput, dragStart, startPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = OpenBtn.Position
    end
end)
OpenBtn.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        OpenBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
OpenBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Abrir/Fechar Menu
OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Lógica do Botão Mestre
MasterBtn.MouseButton1Click:Connect(function()
    _G.KatanaMaster = not _G.KatanaMaster
    MasterBtn.BackgroundColor3 = _G.KatanaMaster and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
    MasterBtn.Text = _G.KatanaMaster and "KATANA ON" or "KATANA OFF"
    FOVCircle.Visible = _G.KatanaMaster
end)

-- Loop de Aimbot (Lock na Cabeça)
RunService.RenderStepped:Connect(function()
    if _G.KatanaMaster then
        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        FOVCircle.Position = center
        
        local target = GetClosestPlayer()
        if target then
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character.Head.Position)
        end
    end
end)
