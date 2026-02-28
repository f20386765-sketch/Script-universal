-- // KATANA HUB V2 - MAIN SCRIPT (SISTEMA BLINDADO) // --
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local ConfigURL = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/users.json"
local OwnerRaw = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/owner_panel.lua"

_G.KatanaMaster = false
_G.AimbotStrength = 0.8
_G.UserRank = "User"

-- // 1. SINCRONIZAÇÃO BLINDADA (ANT-FAKE RANK) // --
local function BlindagemSync()
    local s, res = pcall(function() return game:HttpGet(ConfigURL .. "?t=" .. math.random(1, 9999)) end)
    if s then
        local data = HttpService:JSONDecode(res)
        local myID = lp.UserId
        
        -- Reset de Segurança
        _G.UserRank = "User"
        
        -- Checagem de Banimento
        for _, id in pairs(data.BannedUsers or {}) do if myID == id then lp:Kick("Banido.") end end
        
        -- Verificação Real de Cargos
        local isOwner = false
        for _, id in pairs(data.Owner or {}) do if myID == id then isOwner = true end end
        
        if isOwner then
            _G.UserRank = "OWNER"
            -- O Script só baixa o painel secreto se o ID bater com o GitHub
            task.spawn(function() 
                loadstring(game:HttpGet(OwnerRaw))() 
            end)
        else
            -- Se não for Owner, checa se é VIP ou ADM
            for _, id in pairs(data.VipUsers or {}) do if myID == id then _G.UserRank = "VIP" end end
            for _, id in pairs(data.Admins or {}) do if myID == id then _G.UserRank = "ADM" end end
        end
    end
end
BlindagemSync()

-- // 2. SISTEMA DE ESP (BOX + NAME) // --
local function CreateESP(plr)
    local Box = Drawing.new("Square")
    Box.Visible = false; Box.Color = Color3.fromRGB(255, 0, 0); Box.Thickness = 1; Box.Filled = false
    local Name = Drawing.new("Text")
    Name.Visible = false; Name.Color = Color3.new(1, 1, 1); Name.Size = 14; Name.Center = true; Name.Outline = true

    RunService.RenderStepped:Connect(function()
        if _G.KatanaMaster and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr ~= lp and plr.Character.Humanoid.Health > 0 then
            local rPos, onS = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onS then
                local sX, sY = 2000 / rPos.Z, 3000 / rPos.Z
                Box.Size = Vector2.new(sX, sY); Box.Position = Vector2.new(rPos.X - sX / 2, rPos.Y - sY / 2); Box.Visible = true
                Name.Text = plr.Name; Name.Position = Vector2.new(rPos.X, rPos.Y - (sY / 2) - 15); Name.Visible = true
            else Box.Visible = false; Name.Visible = false end
        else Box.Visible = false; Name.Visible = false end
    end)
end
for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- // 3. KILL SWITCH (PROTEGIDO) // --
game:GetService("ReplicatedStorage").ChildAdded:Connect(function(c)
    -- Só aceita o sinal se o usuário NÃO for o Dono Real
    if c.Name == "KatanaKillSwitch" and _G.UserRank ~= "OWNER" then 
        _G.KatanaMaster = false 
    end
end)

-- // 4. FOV E AIMBOT // --
local FOV = Drawing.new("Circle")
FOV.Thickness = 1.5; FOV.Radius = 150; FOV.Filled = false; FOV.Color = Color3.fromRGB(255, 0, 0); FOV.Visible = false

RunService.RenderStepped:Connect(function()
    if _G.KatanaMaster then
        FOV.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2); FOV.Visible = true
        if _G.UserRank ~= "OWNER" then
            local t, d = nil, 150
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                    local p, vis = cam:WorldToViewportPoint(v.Character.Head.Position)
                    if vis then
                        local m = (Vector2.new(p.X, p.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                        if m < d then t = v; d = m end
                    end
                end
            end
            if t then cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, t.Character.Head.Position), _G.AimbotStrength) end
        end
    else FOV.Visible = false end
end)

-- // 5. INTERFACE // --
local sg = Instance.new("ScreenGui", CoreGui)
local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 45, 0, 45); btn.Position = UDim2.new(0, 10, 0.5, 0); btn.Text = "K"; btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

local f = Instance.new("Frame", sg)
f.Size = UDim2.new(0, 160, 0, 100); f.Position = UDim2.new(0.5, -80, 0.5, -50); f.Visible = false; f.BackgroundColor3 = Color3.fromRGB(15,15,15)
Instance.new("UICorner", f)

local rL = Instance.new("TextLabel", f)
rL.Size = UDim2.new(1, 0, 0, 30); rL.Text = "Rank: " .. _G.UserRank; rL.TextColor3 = Color3.new(1,1,1); rL.BackgroundTransparency = 1

local mB = Instance.new("TextButton", f)
mB.Size = UDim2.new(0.9, 0, 0, 40); mB.Position = UDim2.new(0.05, 0, 0.45, 0); mB.Text = "OFF"; mB.BackgroundColor3 = Color3.fromRGB(30, 30, 30); mB.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", mB)

btn.MouseButton1Click:Connect(function() f.Visible = not f.Visible rL.Text = "Rank: " .. _G.UserRank end)
mB.MouseButton1Click:Connect(function()
    _G.KatanaMaster = not _G.KatanaMaster
    mB.Text = _G.KatanaMaster and "ON" or "OFF"
    mB.BackgroundColor3 = _G.KatanaMaster and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
end)
