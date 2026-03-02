-- // KATANA HUB V8.5 - TEAM SYNCED VERSION // --
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Links do GitHub
local cfg_url = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/users.json"
local teams_url = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/teams.json"
local sec_url = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/security.lua"

-- Variáveis de Dados
_G.KTN_RK = "Sincronizando..."
_G.KTN_TEAM_DATA = {Auto = true, Whitelist = {}}

-- // 1. SINCRONIZAÇÃO DE CONFIGURAÇÕES // --
local function SincronizarTudo()
    -- A. Carregar Users (Bans/Ranks)
    local s1, r1 = pcall(function() return game:HttpGet(cfg_url .. "?t=" .. math.random(1, 9999)) end)
    if s1 then
        local d = HttpService:JSONDecode(r1)
        if d.Config and d.Config.ScriptEnabled == false then
            lp:Kick("\n[KATANA]\n" .. (d.Config.MaintenanceMessage or "Manutenção."))
        end
        -- Definição de Rank
        local myID = lp.UserId
        local rank = "User"
        for _, o in pairs(d.Owner or {}) do if myID == o then rank = "OWNER" end end
        if rank == "User" then for _, a in pairs(d.Admins or {}) do if myID == a then rank = "ADMIN" end end end
        _G.KTN_RK = rank
    end

    -- B. Carregar Teams (Team Check Automático)
    local s2, r2 = pcall(function() return game:HttpGet(teams_url .. "?t=" .. math.random(1, 9999)) end)
    if s2 then
        local d = HttpService:JSONDecode(r2)
        _G.KTN_TEAM_DATA.Auto = d.Settings.AutoTeamCheck
        _G.KTN_TEAM_DATA.Whitelist = d.Exceções.AliadosManuais or {}
    end
end
SincronizarTudo()
task.spawn(function() while task.wait(60) do SincronizarTudo() end end)

-- // 2. FUNÇÃO MESTRA: É INIMIGO? // --
local function IsEnemy(p)
    if p == lp or not p.Character then return false end
    
    -- 1. Check de Whitelist Manual (IDs do teams.json)
    for _, id in pairs(_G.KTN_TEAM_DATA.Whitelist) do
        if p.UserId == id then return false end
    end

    -- 2. Team Check Automático (Roblox)
    if _G.KTN_TEAM_DATA.Auto then
        if p.Team ~= nil and p.Team == lp.Team then
            return false -- Mesma equipe = Não é inimigo
        end
    end

    return true -- Se passou, é alvo!
end

-- // 3. INTERFACE (UI SIMPLIFICADA) // --
local gui = Instance.new("ScreenGui", CoreGui)
local mainBtn = Instance.new("TextButton", gui)
mainBtn.Size = UDim2.new(0, 50, 0, 50); mainBtn.Position = UDim2.new(0, 15, 0.5, -25); mainBtn.Text = "K"
Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 300, 0, 200); mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100); mainFrame.Visible = false
Instance.new("UICorner", mainFrame)

local function CreateToggle(name, posY, globalVar)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.Position = UDim2.new(0.05, 0, 0, posY); btn.Text = name .. ": OFF"
    btn.Activated:Connect(function()
        _G[globalVar] = not _G[globalVar]
        btn.Text = name .. ": " .. (_G[globalVar] and "ON" or "OFF")
    end)
end

CreateToggle("Aimbot Master", 50, "KTN_MS")
CreateToggle("Box ESP", 90, "KTN_ESP_Box")
CreateToggle("Tracers", 130, "KTN_ESP_Tracers")

-- // 4. ESP COM TEAM CHECK // --
local function CreateESP(p)
    local L1 = Drawing.new("Line"); L1.Visible = false; L1.Color = Color3.new(1,0,0)
    local Tracer = Drawing.new("Line"); Tracer.Visible = false; Tracer.Color = Color3.new(1,0,0)

    RunService.RenderStepped:Connect(function()
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and IsEnemy(p) then
            local pos, onScreen = cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            
            if onScreen then
                Tracer.Visible = _G.KTN_ESP_Tracers
                Tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                Tracer.To = Vector2.new(pos.X, pos.Y)
                -- (Aqui você pode adicionar as outras 4 linhas da Box se quiser)
            else Tracer.Visible = false end
        else Tracer.Visible = false end
    end)
end

for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- // 5. AIMBOT COM TEAM CHECK // --
RunService.RenderStepped:Connect(function()
    if _G.KTN_MS then
        local target, dist = nil, 200
        for _, v in pairs(Players:GetPlayers()) do
            if IsEnemy(v) and v.Character and v.Character:FindFirstChild("Head") then
                local p, onS = cam:WorldToViewportPoint(v.Character.Head.Position)
                if onS then
                    local m = (Vector2.new(p.X, p.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                    if m < dist then target = v; dist = m end
                end
            end
        end
        if target then 
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Character.Head.Position), 0.1) 
        end
    end
end)

mainBtn.Activated:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
print("✅ Katana Hub V8.5: Team Check Automático Ativo!")
