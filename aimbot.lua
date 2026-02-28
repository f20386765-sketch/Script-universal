-- // KATANA HUB V2 - REMOTE CONTROL EDITION // --
-- // LINK: https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/users.json // --

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- // LINK DO SEU CONTROLE // --
local ConfigURL = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/users.json"

-- // CONFIGS PADRÃO // --
_G.KatanaMaster = false
_G.FOVSize = 130
_G.AimbotStrength = 0.8 

-- // SISTEMA DE ANTENA (CONTROLE REMOTO) // --
local function SyncRemote()
    local success, response = pcall(function()
        return game:HttpGet(ConfigURL .. "?t=" .. math.random(1, 9999))
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        
        -- Verificar Banimento
        if data.BannedUsers then
            for _, id in pairs(data.BannedUsers) do
                if lp.UserId == id then
                    lp:Kick("\n[KATANA HUB]\nVocê foi banido pelo desenvolvedor.")
                    return
                end
            end
        end

        -- Kill Switch (Desligar tudo remotamente)
        if data.ForceOff == true then
            _G.KatanaMaster = false
            print("KATANA: Desativado remotamente por segurança.")
        end

        print("KATANA: " .. (data.GlobalMessage or "Conectado!"))
    end
end

-- Sincroniza ao abrir e a cada 2 minutos
task.spawn(function()
    while true do
        SyncRemote()
        task.wait(120)
    end
end)
SyncRemote()

-- // DESENHO DO FOV // --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Radius = _G.FOVSize
FOVCircle.Filled = false 
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Visible = false

-- // ESP (BOX + NAME) // --
local function CreateESP(plr)
    local Box = Drawing.new("Square")
    Box.Visible = false; Box.Color = Color3.fromRGB(255, 0, 0); Box.Thickness = 1
    local Name = Drawing.new("Text")
    Name.Visible = false; Name.Color = Color3.new(1, 1, 1); Name.Size = 14; Name.Outline = true; Name.Center = true

    RunService.RenderStepped:Connect(function()
        if _G.KatanaMaster and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr ~= lp and plr.Character.Humanoid.Health > 0 then
            local pos, vis = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if vis then
                local sX, sY = 2000/pos.Z, 3000/pos.Z
                Box.Size = Vector2.new(sX, sY)
                Box.Position = Vector2.new(pos.X - sX/2, pos.Y - sY/2)
                Box.Visible = true
                Name.Text = plr.Name; Name.Position = Vector2.new(pos.X, pos.Y - sY/2 - 15); Name.Visible = true
            else Box.Visible = false; Name.Visible = false end
        else Box.Visible = false; Name.Visible = false end
    end)
end
for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- // MIRA E TRAVA (0.8) // --
RunService.RenderStepped:Connect(function()
    if _G.KatanaMaster then
        FOVCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        FOVCircle.Visible = true
        
        local target, dist = nil, _G.FOVSize
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                local p, vis = cam:WorldToViewportPoint(v.Character.Head.Position)
                if vis then
                    local m = (Vector2.new(p.X, p.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                    if m < dist then 
                        -- Checar Visibilidade
                        local ray = workspace:Raycast(cam.CFrame.Position, (v.Character.Head.Position - cam.CFrame.Position), RaycastParams.new())
                        if not ray or ray.Instance:IsDescendantOf(v.Character) then
                            target = v; dist = m 
                        end
                    end
                end
            end
        end
        
        if target then
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Character.Head.Position), _G.AimbotStrength)
        end
    else FOVCircle.Visible = false end
end)

-- // MENU MOBILE // --
local sg = Instance.new("ScreenGui", CoreGui)
local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 45, 0, 45); btn.Position = UDim2.new(0, 10, 0.5, 0); btn.Text = "K"
btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 160, 0, 80); frame.Position = UDim2.new(0.5, -80, 0.5, -40); frame.Visible = false; frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
Instance.new("UICorner", frame)

local mBtn = Instance.new("TextButton", frame)
mBtn.Size = UDim2.new(0.9, 0, 0, 40); mBtn.Position = UDim2.new(0.05, 0, 0.25, 0); mBtn.Text = "OFF"
mBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); mBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", mBtn)

btn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)
mBtn.MouseButton1Click:Connect(function()
    _G.KatanaMaster = not _G.KatanaMaster
    mBtn.Text = _G.KatanaMaster and "ON" or "OFF"
    mBtn.BackgroundColor3 = _G.KatanaMaster and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
end)
