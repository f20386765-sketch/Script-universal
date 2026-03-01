-- // KATANA HUB V7.2 - FIX ESP BOX FILLED // --
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Links do Teu GitHub
local cfg = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/users.json"
local sec = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/security.lua"

-- // 1. CARREGAMENTO DE SEGURANÇA // --
pcall(function() loadstring(game:HttpGet(sec .. "?t=" .. math.random(1, 9999)))() end)
task.wait(1.5)
if not _G.KTN_SESSION_KEY then lp:Kick("Segurança Ausente") return end

-- // 2. VARIÁVEIS GLOBAIS // --
_G.KTN_MS = false
_G.KTN_RK = "Sincronizando..."
_G.KTN_ST = 0.8
-- Toggles do ESP Avançado (Iniciam desligados para o usuário escolher)
_G.KTN_ESP_Box = false
_G.KTN_ESP_Tracers = false
_G.KTN_ESP_Health = false
_G.KTN_ESP_Distance = false

-- // 3. FUNÇÃO DE SINCRONIZAÇÃO DE RANKS // --
local function Sincronizar()
    local success, response = pcall(function() 
        return game:HttpGet(cfg .. "?t=" .. math.random(1, 9999)) 
    end)
    
    if success then
        local data = HttpService:JSONDecode(response)
        local myID = lp.UserId
        
        -- Verificar Ban
        for _, bID in pairs(data.BannedUsers or {}) do 
            if myID == bID then lp:Kick("\n[KATANA]\nTu estás banido deste script.") end 
        end
        
        -- Verificar Ranks (Dono > VIP > User)
        local rankFinal = "User"
        for _, oID in pairs(data.Owner or {}) do if myID == oID then rankFinal = "OWNER" end end
        if rankFinal == "User" then
            for _, vID in pairs(data.VipUsers or {}) do if myID == vID then rankFinal = "VIP" end end
        end
        
        _G.KTN_RK = rankFinal
    else
        _G.KTN_RK = "Erro na Rede"
    end
end
task.spawn(Sincronizar)

-- // 4. INTERFACE GRÁFICA (TABS SYSTEM) // --
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "KatanaV7_FixedESP"

local mainBtn = Instance.new("TextButton", gui)
mainBtn.Size = UDim2.new(0, 50, 0, 50); mainBtn.Position = UDim2.new(0, 15, 0.5, -25)
mainBtn.Text = "K"; mainBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); mainBtn.TextColor3 = Color3.new(1,1,1)
mainBtn.Font = Enum.Font.SourceSansBold; mainBtn.TextSize = 25
Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 350, 0, 220); mainFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12); mainFrame.Visible = false; mainFrame.Active = true; mainFrame.Draggable = true
Instance.new("UICorner", mainFrame)

local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 80, 1, 0); sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Instance.new("UICorner", sidebar)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(0, 270, 0, 30); title.Position = UDim2.new(0, 80, 0, 5)
title.Text = "KATANA HUB V7"; title.TextColor3 = Color3.fromRGB(255, 0, 0); title.BackgroundTransparency = 1; title.Font = Enum.Font.SourceSansBold

local rLabel = Instance.new("TextLabel", mainFrame)
rLabel.Size = UDim2.new(0, 270, 0, 20); rLabel.Position = UDim2.new(0, 80, 0, 25)
rLabel.Text = "Aguardando Rank..."; rLabel.TextColor3 = Color3.new(0.6,0.6,0.6); rLabel.BackgroundTransparency = 1; rLabel.Font = Enum.Font.SourceSans

-- Atualizar o texto do Rank na Interface periodicamente
task.spawn(function()
    while task.wait(2) do rLabel.Text = "Rank: " .. _G.KTN_RK end
end)

-- Abas (ScrollingFrames)
local combatTab = Instance.new("ScrollingFrame", mainFrame); combatTab.Size = UDim2.new(0, 260, 0, 160); combatTab.Position = UDim2.new(0, 85, 0, 50); combatTab.BackgroundTransparency = 1; combatTab.ScrollBarThickness = 2; combatTab.Visible = true
local visualTab = Instance.new("ScrollingFrame", mainFrame); visualTab.Size = UDim2.new(0, 260, 0, 160); visualTab.Position = UDim2.new(0, 85, 0, 50); visualTab.BackgroundTransparency = 1; visualTab.ScrollBarThickness = 2; visualTab.Visible = false

local function CreateToggle(name, parent, posY, globalVar)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 35); btn.Position = UDim2.new(0, 0, 0, posY)
    btn.Text = name .. ": OFF"; btn.BackgroundColor3 = Color3.fromRGB(25,25,25); btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn)
    btn.Activated:Connect(function()
        if not _G.KTN_SESSION_KEY then return end
        _G[globalVar] = not _G[globalVar]
        btn.Text = name .. ": " .. (_G[globalVar] and "ON" or "OFF")
        btn.BackgroundColor3 = _G[globalVar] and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(25, 25, 25)
    end)
end

-- Botões Aba Combat
CreateToggle("Aimbot Master", combatTab, 0, "KTN_MS")
-- Botões Aba Visual
CreateToggle("Box ESP (Linhas)", visualTab, 0, "KTN_ESP_Box") -- Texto atualizado para clareza
CreateToggle("Tracers (Linhas de Mira)", visualTab, 45, "KTN_ESP_Tracers")
CreateToggle("Health Bar", visualTab, 90, "KTN_ESP_Health")
CreateToggle("Distance", visualTab, 135, "KTN_ESP_Distance")

-- Troca de Abas na Sidebar
local b1 = Instance.new("TextButton", sidebar); b1.Size = UDim2.new(1, -10, 0, 35); b1.Position = UDim2.new(0, 5, 0, 10); b1.Text = "COMBAT"; b1.BackgroundColor3 = Color3.fromRGB(20,20,20); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
local b2 = Instance.new("TextButton", sidebar); b2.Size = UDim2.new(1, -10, 0, 35); b2.Position = UDim2.new(0, 5, 0, 50); b2.Text = "VISUAL"; b2.BackgroundColor3 = Color3.fromRGB(20,20,20); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)

b1.Activated:Connect(function() combatTab.Visible = true; visualTab.Visible = false end)
b2.Activated:Connect(function() combatTab.Visible = false; visualTab.Visible = true end)

-- // 5. LÓGICA DO ESP AVANÇADO E COMBATE // --
local function CreateESP(p)
    -- Inicialização dos elementos gráficos com Drawing API
    
    -- --- A CORREÇÃO ESTÁ AQUI ---
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.new(1,0,0)
    Box.Thickness = 1
    Box.Filled = false -- <<--- LINHA ADICIONADA: Isso garante que o quadrado não seja preenchido
    
    local Tracer = Drawing.new("Line"); Tracer.Visible = false; Tracer.Color = Color3.new(1,0,0); Tracer.Thickness = 1
    local HealthBar = Drawing.new("Square"); HealthBar.Visible = false; HealthBar.Filled = true -- Barra de vida precisa ser preenchida
    local DistText = Drawing.new("Text"); DistText.Visible = false; DistText.Color = Color3.new(1,1,1); DistText.Size = 14; DistText.Outline = true

    -- Loop de Renderização (RenderStepped roda a cada frame do jogo)
    RunService.RenderStepped:Connect(function()
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= lp and p.Character.Humanoid.Health > 0 then
            local root = p.Character.HumanoidRootPart
            local hum = p.Character.Humanoid
            local pos, onScreen = cam:WorldToViewportPoint(root.Position)

            if onScreen then
                -- Cálculos de tamanho baseados na distância (Z)
                local sizeX, sizeY = 2000 / pos.Z, 3000 / pos.Z
                local screenPos = Vector2.new(pos.X, pos.Y)
                local topCorner = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)

                -- 1. BOX ESP (Atualizado para mostrar apenas o contorno)
                Box.Visible = _G.KTN_ESP_Box
                Box.Size = Vector2.new(sizeX, sizeY)
                Box.Position = topCorner
                
                -- 2. TRACERS (Linha vinda de baixo da tela)
                Tracer.Visible = _G.KTN_ESP_Tracers
                Tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                Tracer.To = Vector2.new(screenPos.X, screenPos.Y + sizeY/2)
                
                -- 3. HEALTH BAR (Barra lateral dinâmica)
                HealthBar.Visible = _G.KTN_ESP_Health
                local hHeight = (hum.Health / hum.MaxHealth) * sizeY -- Altura proporcional à vida
                HealthBar.Size = Vector2.new(2, hHeight)
                -- Posição fixa à esquerda da Box
                HealthBar.Position = Vector2.new(topCorner.X - 5, topCorner.Y + (sizeY - hHeight))
                -- Cor muda dinamicamente (Verde -> Amarelo -> Vermelho)
                HealthBar.Color = Color3.fromHSV(hum.Health/hum.MaxHealth * 0.3, 1, 1)

                -- 4. DISTANCE (Texto com a distância em Studs)
                DistText.Visible = _G.KTN_ESP_Distance
                local d = math.floor((root.Position - lp.Character.HumanoidRootPart.Position).Magnitude)
                DistText.Text = "[" .. d .. "m]"
                DistText.Position = Vector2.new(screenPos.X, screenPos.Y + sizeY/2 + 5)
                DistText.Center = true
            else
                -- Esconder tudo se o jogador estiver fora da tela
                Box.Visible = false; Tracer.Visible = false; HealthBar.Visible = false; DistText.Visible = false
            }
        else
            -- Esconder tudo se o jogador morrer ou deslogar
            Box.Visible = false; Tracer.Visible = false; HealthBar.Visible = false; DistText.Visible = false
        end
    end)
end

-- Monitorar jogadores atuais e novos
for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- Lógica simples de Aimbot (Corre no loop principal)
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
print("✅ KATANA V7.2: FIX ESP BOX & SINCRONIZADO.")
