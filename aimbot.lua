-- // KATANA HUB V2 - RANK SYSTEM // --
-- // LINK: https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/users.json // --

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local ConfigURL = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/users.json"

-- // ESTADOS DO SCRIPT // --
_G.KatanaMaster = false
_G.AimbotStrength = 0.8
_G.UserRank = "User" -- Rank padrão

-- // SINCRONIZAÇÃO REMOTA E CARGOS // --
local function SyncRemote()
    local success, response = pcall(function()
        return game:HttpGet(ConfigURL .. "?t=" .. math.random(1, 9999))
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        
        -- Verificar Banimento
        for _, id in pairs(data.BannedUsers or {}) do
            if lp.UserId == id then
                lp:Kick("\n[KATANA HUB]\nFoste banido pelo Dono.")
                return
            end
        end

        -- Definir Rank do Usuário
        _G.UserRank = "User"
        
        for _, id in pairs(data.VipUsers or {}) do
            if lp.UserId == id then _G.UserRank = "VIP" end
        end
        
        for _, id in pairs(data.Admins or {}) do
            if lp.UserId == id then _G.UserRank = "ADM" end
        end
        
        for _, id in pairs(data.Owner or {}) do
            if lp.UserId == id then _G.UserRank = "OWNER" end
        end

        print("KATANA HUB: Olá, " .. lp.Name .. "! Cargo: [" .. _G.UserRank .. "]")
        
        if data.ForceOff then _G.KatanaMaster = false end
    end
end

SyncRemote()
task.spawn(function() while task.wait(120) do SyncRemote() end end)

-- // [O RESTO DO SCRIPT - FOV, ESP E AIMBOT 0.8] // --

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Radius = 130
FOVCircle.Filled = false 
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Visible = false

-- Aimbot 0.8
RunService.RenderStepped:Connect(function()
    if _G.KatanaMaster then
        FOVCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        FOVCircle.Visible = true
        
        local target, dist = nil, 130
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
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Character.Head.Position), _G.AimbotStrength)
        end
    else FOVCircle.Visible = false end
end)

-- // INTERFACE COM NOME DO CARGO // --
local sg = Instance.new("ScreenGui", CoreGui)
local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 45, 0, 45); btn.Position = UDim2.new(0, 10, 0.5, 0); btn.Text = "K"
btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 160, 0, 100); frame.Position = UDim2.new(0.5, -80, 0.5, -50); frame.Visible = false; frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
Instance.new("UICorner", frame)

local rankLabel = Instance.new("TextLabel", frame)
rankLabel.Size = UDim2.new(1, 0, 0, 30); rankLabel.Text = "Rank: " .. _G.UserRank; rankLabel.TextColor3 = Color3.new(1,1,1); rankLabel.BackgroundTransparency = 1

local mBtn = Instance.new("TextButton", frame)
mBtn.Size = UDim2.new(0.9, 0, 0, 40); mBtn.Position = UDim2.new(0.05, 0, 0.45, 0); mBtn.Text = "OFF"
mBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); mBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", mBtn)

btn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)
mBtn.MouseButton1Click:Connect(function()
    _G.KatanaMaster = not _G.KatanaMaster
    mBtn.Text = _G.KatanaMaster and "ON" or "OFF"
    mBtn.BackgroundColor3 = _G.KatanaMaster and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
end)
