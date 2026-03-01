-- // KATANA HUB V7.7 - FINAL VERSION (ADMIN + HWID + REMOTE) // --
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Identificador Único do Aparelho (Simulação de IP)
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()

-- Links do GitHub
local cfg = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/users.json"
local sec = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/security.lua"

-- // 1. CARREGAR SEGURANÇA // --
pcall(function() loadstring(game:HttpGet(sec .. "?t=" .. math.random(1, 9999)))() end)
task.wait(1.5)

-- // 2. VARIÁVEIS GLOBAIS // --
_G.KTN_MS = false
_G.KTN_RK = "Sincronizando..."
_G.KTN_ST = 0.8
_G.KTN_ESP_Box = false
_G.KTN_ESP_Tracers = false
_G.KTN_ESP_Health = false
_G.KTN_ESP_Distance = false

-- // 3. SINCRONIZAÇÃO E CONTROLO REMOTO // --
local function Sincronizar()
    local s, r = pcall(function() return game:HttpGet(cfg .. "?t=" .. math.random(1, 9999)) end)
    if s then
        local d = HttpService:JSONDecode(r)
        
        -- A. BAN POR APARELHO (IP/HWID)
        for _, bIP in pairs(d.BannedIPs or {}) do
            if hwid == bIP then
                lp:Kick("\n[KATANA]\nO teu APARELHO está banido deste script.\nID: "..hwid)
                return false
            end
        end

        -- B. KILL-SWITCH (Botão de Pânico)
        if d.Config and d.Config.ScriptEnabled == false then
            lp:Kick("\n[KATANA]\n" .. (d.Config.MaintenanceMessage or "Script Desativado."))
            return false
        end

        -- C. BLACKLIST DE JOGOS
        for _, gameID in pairs(d.Config.BlacklistedGames or {}) do
            if game.PlaceId == gameID then
                lp:Kick("\n[KATANA]\nEste jogo foi bloqueado por segurança.")
                return false
            end
        end

        -- D. HIERARQUIA DE RANKS
        local myID = lp.UserId
        local rF = "User"

        for _, o in pairs(d.Owner or {}) do if myID == o then rF = "OWNER" end end
        if rF == "User" then
            for _, a in pairs(d.Admins or {}) do if myID == a then rF = "ADMIN" end end
        end
        if rF == "User" then
            for _, v in pairs(d.VipUsers or {}) do if myID == v then rF = "VIP" end end
        end

        -- E. BAN POR CONTA
        for _, b in pairs(d.BannedUsers or {}) do
            if myID == b then 
                lp:Kick("\n[KATANA]\nSua conta foi banida.\nHWID para registro: "..hwid) 
                return false 
            end
        end

        _G.KTN_RK = rF
        return true
    end
    _G.KTN_RK = "Offline/Local"
    return true
end

if not Sincronizar() then return end

-- // 4. INTERFACE GRÁFICA (UI) // --
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "KatanaV7_Final"

local mainBtn = Instance.new("TextButton", gui)
mainBtn.Size = UDim2.new(0, 50, 0, 50); mainBtn.Position = UDim2.new(0, 15, 0.5, -25)
mainBtn.Text = "K"; mainBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); mainBtn.TextColor3 = Color3.new(1,1,1)
mainBtn.Font = Enum.Font.SourceSansBold; mainBtn.TextSize = 25
Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 350, 0, 220); mainFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12); mainFrame.Visible = false; mainFrame.Active = true; mainFrame.Draggable = true
Instance.new("UICorner", mainFrame)

local sidebar = Instance.new("Frame", mainFrame); sidebar.Size = UDim2.new(0, 80, 1, 0); sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 8); Instance.new("UICorner", sidebar)
local rLabel = Instance.new("TextLabel", mainFrame); rLabel.Size = UDim2.new(0, 270, 0, 20); rLabel.Position = UDim2.new(0, 80, 0, 25); rLabel.TextColor3 = Color3.new(0.6,0.6,0.6); rLabel.BackgroundTransparency = 1; rLabel.Font = Enum.Font.SourceSans
task.spawn(function() while task.wait(2) do rLabel.Text = "Rank: " .. _G.KTN_RK end end)

local combatTab = Instance.new("ScrollingFrame", mainFrame); combatTab.Size = UDim2.new(0, 260, 0, 160); combatTab.Position = UDim2.new(0, 85, 0, 50); combatTab.BackgroundTransparency = 1; combatTab.Visible = true; combatTab.ScrollBarThickness = 2
local visualTab = Instance.new("ScrollingFrame", mainFrame); visualTab.Size = UDim2.new(0, 260, 0, 160); visualTab.Position = UDim2.new(0, 85, 0, 50); visualTab.BackgroundTransparency = 1; visualTab.Visible = false; visualTab.ScrollBarThickness = 2

local function CreateToggle(name, parent, posY, globalVar)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 35); btn.Position = UDim2.new(0, 0, 0, posY)
    btn.Text = name .. ": OFF"; btn.BackgroundColor3 = Color3.fromRGB(25,25,25); btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn)
    btn.Activated:Connect(function()
        _G[globalVar] = not _G[globalVar]
        btn.Text = name .. ": " .. (_G[globalVar] and "ON" or "OFF")
        btn.BackgroundColor3 = _G[globalVar] and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(25, 25, 25)
    end)
end

CreateToggle("Aimbot Master", combatTab, 0, "KTN_MS")
CreateToggle("Box ESP", visualTab, 0, "KTN_ESP_Box")
CreateToggle("Tracers", visualTab, 45, "KTN_ESP_Tracers")
CreateToggle("Health Bar", visualTab, 90, "KTN_ESP_Health")
CreateToggle("Distance", visualTab, 135, "KTN_ESP_Distance")

local b1 = Instance.new("TextButton", sidebar); b1.Size = UDim2.new(1, -10, 0, 35); b1.Position = UDim2.new(0, 5, 0, 10); b1.Text = "COMBAT"; b1.BackgroundColor3 = Color3.fromRGB(20,20,20); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1); b1.Font = Enum.Font.SourceSansBold; b1.TextSize = 12
local b2 = Instance.new("TextButton", sidebar); b2.Size = UDim2.new(1, -10, 0, 35); b2.Position = UDim2.new(0, 5, 0, 50); b2.Text = "VISUAL"; b2.BackgroundColor3 = Color3.fromRGB(20,20,20); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2); b2.Font = Enum.Font.SourceSansBold; b2.TextSize = 12

b1.Activated:Connect(function() combatTab.Visible = true; visualTab.Visible = false end)
b2.Activated:Connect(function() combatTab.Visible = false; visualTab.Visible = true end)

-- // 5. ESP DE LINHAS (FIX UNIVERSAL) // --
local function CreateESP(p)
    local L1 = Drawing.new("Line"); L1.Visible = false; L1.Color = Color3.new(1,0,0); L1.Thickness = 1
    local L2 = Drawing.new("Line"); L2.Visible = false; L2.Color = Color3.new(1,0,0); L2.Thickness = 1
    local L3 = Drawing.new("Line"); L3.Visible = false; L3.Color = Color3.new(1,0,0); L3.Thickness = 1
    local L4 = Drawing.new("Line"); L4.Visible = false; L4.Color = Color3.new(1,0,0); L4.Thickness = 1
    local Tracer = Drawing.new("Line"); Tracer.Visible = false; Tracer.Color = Color3.new(1,0,0)
    local HealthBar = Drawing.new("Square"); HealthBar.Visible = false; HealthBar.Filled = true
    local DistText = Drawing.new("Text"); DistText.Visible = false; DistText.Color = Color3.new(1,1,1); DistText.Size = 14; DistText.Outline = true

    RunService.RenderStepped:Connect(function()
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= lp and p.Character.Humanoid.Health > 0 then
            local root = p.Character.HumanoidRootPart
            local hum = p.Character.Humanoid
            local pos, onScreen = cam:WorldToViewportPoint(root.Position)

            if onScreen then
                local sizeX, sizeY = 2000 / pos.Z, 3000 / pos.Z
                local topL = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                local topR = Vector2.new(pos.X + sizeX/2, pos.Y - sizeY/2)
                local botL = Vector2.new(pos.X - sizeX/2, pos.Y + sizeY/2)
                local botR = Vector2.new(pos.X + sizeX/2, pos.Y + sizeY/2)

                if _G.KTN_ESP_Box then
                    L1.From = topL; L1.To = topR; L1.Visible = true
                    L2.From = topR; L2.To = botR; L2.Visible = true
                    L3.From = botR; L3.To = botL; L3.Visible = true
                    L4.From = botL; L4.To = topL; L4.Visible = true
                else
                    L1.Visible = false; L2.Visible = false; L3.Visible = false; L4.Visible = false
                end
                
                Tracer.Visible = _G.KTN_ESP_Tracers; Tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y); Tracer.To = Vector2.new(pos.X, pos.Y + sizeY/2)
                HealthBar.Visible = _G.KTN_ESP_Health
                local hH = (hum.Health / hum.MaxHealth) * sizeY
                HealthBar.Size = Vector2.new(2, hH); HealthBar.Position = Vector2.new(topL.X - 5, botL.Y - hH)
                HealthBar.Color = Color3.fromHSV(hum.Health/hum.MaxHealth * 0.3, 1, 1)

                DistText.Visible = _G.KTN_ESP_Distance
                local d = math.floor((root.Position - lp.Character.HumanoidRootPart.Position).Magnitude)
                DistText.Text = "[" .. d .. "m]"; DistText.Position = Vector2.new(pos.X, botL.Y + 5); DistText.Center = true
            else
                L1.Visible = false; L2.Visible = false; L3.Visible = false; L4.Visible = false
                Tracer.Visible = false; HealthBar.Visible = false; DistText.Visible = false
            end
        else
            L1.Visible = false; L2.Visible = false; L3.Visible = false; L4.Visible = false
            Tracer.Visible = false; HealthBar.Visible = false; DistText.Visible = false
        end
    end)
end

for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- // 6. AIMBOT // --
RunService.RenderStepped:Connect(function()
    if _G.KTN_MS and _G.KTN_SESSION_KEY then
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
end)

mainBtn.Activated:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
print("✅ Katana Hub V7.7: Sistema de Ranks e HWID Ativo.")
