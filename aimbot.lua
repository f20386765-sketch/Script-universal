-- // KATANA HUB V5.2 - REVISÃO FINAL // --
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local cfg = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/users.json"
local sec = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/security.lua"

-- // 1. CARREGAR SEGURANÇA (EM SEGUNDO PLANO) // --
task.spawn(function()
    pcall(function() loadstring(game:HttpGet(sec .. "?t=" .. math.random(1, 9999)))() end)
end)

_G.KTN_MS = false 
_G.KTN_RK = "User" 
_G.KTN_ST = 0.8 

-- // 2. INTERFACE (CRIADA IMEDIATAMENTE) // --
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "KatanaV5_UI"
gui.DisplayOrder = 999

local mainBtn = Instance.new("TextButton", gui)
mainBtn.Size = UDim2.new(0, 50, 0, 50)
mainBtn.Position = UDim2.new(0, 15, 0.5, -25)
mainBtn.Text = "K"
mainBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
mainBtn.TextColor3 = Color3.new(1,1,1)
mainBtn.Font = Enum.Font.Black
mainBtn.TextSize = 25
Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 130)
frame.Position = UDim2.new(0.5, -90, 0.5, -65)
frame.Visible = false 
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.Active = true
frame.Draggable = true 
Instance.new("UICorner", frame)

local rLabel = Instance.new("TextLabel", frame)
rLabel.Size = UDim2.new(1, 0, 0, 30)
rLabel.Position = UDim2.new(0,0,0.3,0)
rLabel.Text = "Sincronizando..."
rLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
rLabel.BackgroundTransparency = 1

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8, 0, 0, 40)
toggle.Position = UDim2.new(0.1, 0, 0.6, 0)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.GothamBold
Instance.new("UICorner", toggle)

-- // 3. SINCRONIZAÇÃO DE RANKS // --
task.spawn(function()
    local s, r = pcall(function() return game:HttpGet(cfg .. "?t=" .. math.random(1, 9999)) end)
    if s then
        local d = HttpService:JSONDecode(r)
        for _, b in pairs(d.BannedUsers or {}) do if lp.UserId == b then lp:Kick("Você está banido.") end end
        local tr = "User"
        for _, o in pairs(d.Owner or {}) do if lp.UserId == o then tr = "OWNER" end end
        if tr ~= "OWNER" then
            for _, v in pairs(d.VipUsers or {}) do if lp.UserId == v then tr = "VIP" end end
        end
        _G.KTN_RK = tr
        rLabel.Text = "Rank: " .. _G.KTN_RK
    end
end)

-- // 4. SISTEMA DE COMBATE (BOX + AIM) // --
local FV = Drawing.new("Circle")
FV.Thickness = 1.5; FV.Radius = 150; FV.Filled = false; FV.Color = Color3.fromRGB(255, 0, 0); FV.Visible = false

local function CreateESP(p)
    local B = Drawing.new("Square")
    B.Visible = false; B.Color = Color3.fromRGB(255, 0, 0); B.Thickness = 1; B.Filled = false
    local N = Drawing.new("Text")
    N.Visible = false; N.Color = Color3.new(1, 1, 1); N.Size = 14; N.Center = true; N.Outline = true

    RunService.RenderStepped:Connect(function()
        if _G.KTN_MS and _G.KTN_SESSION_KEY and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= lp and p.Character.Humanoid.Health > 0 then
            local rP, oS = cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if oS then
                local sX, sY = 2000 / rP.Z, 3000 / rP.Z
                B.Size = Vector2.new(sX, sY); B.Position = Vector2.new(rP.X - sX/2, rP.Y - sY/2); B.Visible = true
                N.Text = p.Name; N.Position = Vector2.new(rP.X, rP.Y - (sY/2) - 15); N.Visible = true
            else B.Visible = false; N.Visible = false end
        else B.Visible = false; N.Visible = false end
    end)
end

RunService.RenderStepped:Connect(function()
    if _G.KTN_MS and _G.KTN_SESSION_KEY then
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

for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- // 5. EVENTOS // --
mainBtn.Activated:Connect(function()
    frame.Visible = not frame.Visible
end)

toggle.Activated:Connect(function()
    if not _G.KTN_SESSION_KEY then 
        rLabel.Text = "Erro: Sem Segurança!"
        return 
    end
    _G.KTN_MS = not _G.KTN_MS
    toggle.Text = _G.KTN_MS and "ON" or "OFF"
    toggle.BackgroundColor3 = _G.KTN_MS and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(35, 35, 35)
end)

print("✅ KATANA V5.2 CARREGADO.")
