-- // KATANA HUB V4 - PROTEÇÃO MÁXIMA & FOV FIX // --
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local cfg = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/users.json"
local sec = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/security.lua"
local pnl = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/owner_panel.lua"

-- // 1. CARREGAR SEGURANÇA (WEBHOOK OCULTO) // --
pcall(function() loadstring(game:HttpGet(sec .. "?t=" .. math.random(1, 9999)))() end)

-- Variáveis Ofuscadas para evitar Console Hack
_G.KTN_MS = false -- Master Switch (ON/OFF)
_G.KTN_RK = "User" -- Rank Real
_G.KTN_ST = 0.8 -- Aimbot Smooth

-- // 2. SINCRONIZAÇÃO E VALIDAÇÃO // --
local function Sincronizar()
    local s, r = pcall(function() return game:HttpGet(cfg .. "?t=" .. math.random(1, 9999)) end)
    if s then
        local d = HttpService:JSONDecode(r)
        local id = lp.UserId
        
        -- Check de Ban imediato
        for _, b in pairs(d.BannedUsers or {}) do if id == b then lp:Kick("Você está banido do Katana Hub.") end end
        
        -- Define Rank com base no GitHub
        local tr = "User"
        for _, o in pairs(d.Owner or {}) do if id == o then tr = "OWNER" end end
        if tr ~= "OWNER" then
            for _, v in pairs(d.VipUsers or {}) do if id == v then tr = "VIP" end end
            for _, a in pairs(d.Admins or {}) do if id == a then tr = "ADM" end end
        end

        _G.KTN_RK = tr
        if _G.KTN_RK == "OWNER" then task.spawn(function() loadstring(game:HttpGet(pnl))() end) end
    end
end
Sincronizar()

-- // 3. ANTI-TAMPER (CHECK DE INTEGRIDADE) // --
task.spawn(function()
    while task.wait(15) do
        local s, r = pcall(function() return game:HttpGet(cfg .. "?t=" .. math.random(1, 9999)) end)
        if s then
            local d = HttpService:JSONDecode(r)
            local id = lp.UserId
            local real = "User"
            for _, o in pairs(d.Owner or {}) do if id == o then real = "OWNER" end end
            for _, v in pairs(d.VipUsers or {}) do if id == v and real ~= "OWNER" then real = "VIP" end end

            -- Se o rank no script for alterado sem estar no GitHub
            if _G.KTN_RK ~= real then
                if _G.CheckIntegrity then
                    _G.CheckIntegrity("Tentativa de Fake Rank (Console Edit)")
                else
                    lp:Kick("Security Breach 0x88")
                end
                break
            end
        end
    end
end)

-- // 4. SISTEMA DE ESP (BOX + NAME) // --
local function CreateESP(p)
    local B = Drawing.new("Square")
    B.Visible = false; B.Color = Color3.fromRGB(255, 0, 0); B.Thickness = 1; B.Filled = false
    local N = Drawing.new("Text")
    N.Visible = false; N.Color = Color3.new(1, 1, 1); N.Size = 14; N.Center = true; N.Outline = true

    RunService.RenderStepped:Connect(function()
        if _G.KTN_MS and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= lp and p.Character.Humanoid.Health > 0 then
            local rP, oS = cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if oS then
                local sX, sY = 2000 / rP.Z, 3000 / rP.Z
                B.Size = Vector2.new(sX, sY); B.Position = Vector2.new(rP.X - sX/2, rP.Y - sY/2); B.Visible = true
                N.Text = p.Name; N.Position = Vector2.new(rP.X, rP.Y - (sY/2) - 15); N.Visible = true
            else B.Visible = false; N.Visible = false end
        else B.Visible = false; N.Visible = false end
    end)
end
for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- // 5. AIMBOT & FOV CORRIGIDO // --
local FV = Drawing.new("Circle")
FV.Thickness = 1.5; FV.Radius = 150; FV.Filled = false; FV.Color = Color3.fromRGB(255, 0, 0); FV.Visible = false

RunService.RenderStepped:Connect(function()
    if _G.KTN_MS then
        FV.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2); FV.Visible = true
        if _G.KTN_RK ~= "OWNER" then
            local t, d = nil, 150
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                    local p, vS = cam:WorldToViewportPoint(v.Character.Head.Position)
                    if vS then
                        local m = (Vector2.new(p.X, p.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                        if m < d then t = v; d = m end
                    end
                end
            end
            if t then cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, t.Character.Head.Position), _G.KTN_ST) end
        end
    else FV.Visible = false end
end)

-- // 6. INTERFACE // --
local g = Instance.new("ScreenGui", CoreGui)
local b = Instance.new("TextButton", g)
b.Size = UDim2.new(0, 45, 0, 45); b.Position = UDim2.new(0, 10, 0.5, 0); b.Text = "K"; b.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

local f = Instance.new("Frame", g)
f.Size = UDim2.new(0, 160, 0, 110); f.Position = UDim2.new(0.5, -80, 0.5, -55); f.Visible = false; f.BackgroundColor3 = Color3.fromRGB(15,15,15)
Instance.new("UICorner", f)

local rL = Instance.new("TextLabel", f)
rL.Size = UDim2.new(1, 0, 0, 30); rL.Text = "Rank: " .. _G.KTN_RK; rL.TextColor3 = Color3.new(1,1,1); rL.BackgroundTransparency = 1

local mB = Instance.new("TextButton", f)
mB.Size = UDim2.new(0.9, 0, 0, 40); mB.Position = UDim2.new(0.05, 0, 0.45, 0); mB.Text = "OFF"; mB.BackgroundColor3 = Color3.fromRGB(30, 30, 30); mB.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", mB)

b.MouseButton1Click:Connect(function() f.Visible = not f.Visible rL.Text = "Rank: " .. _G.KTN_RK end)
mB.MouseButton1Click:Connect(function()
    _G.KTN_MS = not _G.KTN_MS
    mB.Text = _G.KTN_MS and "ON" or "OFF"
    mB.BackgroundColor3 = _G.KTN_MS and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
end)
