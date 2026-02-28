-- // KATANA HUB V5.2 - REVISADO E BLINDADO // --
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local cfg = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/users.json"
local sec = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/security.lua"

-- // 1. CARREGAR SEGURANÇA IMEDIATAMENTE // --
task.spawn(function()
    pcall(function() loadstring(game:HttpGet(sec .. "?t=" .. math.random(1, 9999)))() end)
end)

_G.KTN_MS = false 
_G.KTN_RK = "User" 

-- // 2. INTERFACE (CRIADA PRIMEIRO PARA NÃO TRAVAR) // --
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "KatanaV5"
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
rLabel.Text = "Aguardando..."
rLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
rLabel.BackgroundTransparency = 1

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8, 0, 0, 40)
toggle.Position = UDim2.new(0.1, 0, 0.6, 0)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", toggle)

-- // 3. LOGICA DE SINCRONIZAÇÃO // --
task.spawn(function()
    local s, r = pcall(function() return game:HttpGet(cfg .. "?t=" .. math.random(1, 9999)) end)
    if s then
        local d = HttpService:JSONDecode(r)
        for _, b in pairs(d.BannedUsers or {}) do if lp.UserId == b then lp:Kick("Banido.") end end
        local tr = "User"
        for _, o in pairs(d.Owner or {}) do if lp.UserId == o then tr = "OWNER" end end
        _G.KTN_RK = tr
        rLabel.Text = "Rank: " .. _G.KTN_RK
    end
end)

-- // 4. COMBATE (RODA APENAS SE VALIDADO) // --
RunService.RenderStepped:Connect(function()
    if _G.KTN_MS and _G.KTN_SESSION_KEY then
        -- Lógica de Aimbot/ESP aqui (como as anteriores)
    end
end)

-- // 5. EVENTOS DE CLIQUE // --
mainBtn.Activated:Connect(function()
    frame.Visible = not frame.Visible
end)

toggle.Activated:Connect(function()
    if not _G.KTN_SESSION_KEY then 
        rLabel.Text = "ERRO: CHAVE!" 
        return 
    end
    _G.KTN_MS = not _G.KTN_MS
    toggle.Text = _G.KTN_MS and "ON" or "OFF"
    toggle.BackgroundColor3 = _G.KTN_MS and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 30)
end)
