-- // KATANA HUB V26.0 - O SISTEMA COMPLETO // --
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- URL DO TEU CONTROLE (GITHUB)
local URL_JSON = "https://raw.githubusercontent.com/f20386765-sketch/Script-universal/refs/heads/main/users.json"

-- Configurações Globais
_G.KTN_RANK = "USER"
_G.KTN_ACCESS = 1
_G.KTN_MS = false
_G.KTN_ESP_Box = false
_G.KTN_ESP_Tracers = false
_G.KTN_ESP_Names = false
_G.KTN_ESP_Health = false
_G.KTN_LERP = 0.8 -- Insta-Snap

-- // 1. O CÉREBRO (CONTROLE VIA JSON) // --
local function LoadSecurity()
    local s, content = pcall(function() return game:HttpGet(URL_JSON.."?t="..math.random(1,9999)) end)
    if not s then return end
    local db = HttpService:JSONDecode(content)
    
    if db.Config.ScriptEnabled == false then lp:Kick(db.Config.MaintenanceMessage) return end
    for _, b in pairs(db.BannedUsers) do if b == lp.UserId then lp:Kick("Banido.") return end end

    for _, o in pairs(db.Owner) do if o == lp.UserId then _G.KTN_RANK = "OWNER"; _G.KTN_ACCESS = 4 end end
    if _G.KTN_RANK == "USER" then
        for _, v in pairs(db.VipUsers) do if v == lp.UserId then _G.KTN_RANK = "VIP"; _G.KTN_ACCESS = 2 end end
    end
end
LoadSecurity()

-- // 2. INTERFACE (ESTILO V7.9 COM ABAS) // --
local gui = Instance.new("ScreenGui", CoreGui)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 420, 0, 320); main.Position = UDim2.new(0.5, -210, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); main.Active = true; main.Draggable = true; Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30); title.Text = "KATANA HUB | " .. _G.KTN_RANK; title.TextColor3 = Color3.new(1,1,1); title.Font = "GothamBold"; title.BackgroundTransparency = 1

local side = Instance.new("Frame", main); side.Size = UDim2.new(0, 100, 1, -30); side.Position = UDim2.new(0,0,0,30); side.BackgroundColor3 = Color3.fromRGB(7, 7, 7); Instance.new("UICorner", side)
local container = Instance.new("Frame", main); container.Size = UDim2.new(0, 300, 0, 260); container.Position = UDim2.new(0, 110, 0, 45); container.BackgroundTransparency = 1

local tabs = { Combat = Instance.new("Frame", container), Visuals = Instance.new("Frame", container) }
for _, t in pairs(tabs) do t.Size = UDim2.new(1,1,1,1); t.Visible = false end
tabs.Combat.Visible = true

local function AddTab(n, y, target, acc)
    local b = Instance.new("TextButton", side); b.Size = UDim2.new(1,0,0,40); b.Position = UDim2.new(0,0,0,y); b.Font = "GothamBold"
    if _G.KTN_ACCESS < acc then b.Text = "🔒 "..n; b.TextColor3 = Color3.new(0.4,0.4,0.4) else
        b.Text = n; b.TextColor3 = Color3.new(1,1,1); b.Activated:Connect(function() for _, t in pairs(tabs) do t.Visible = false end target.Visible = true end)
    end
    b.BackgroundColor3 = Color3.fromRGB(15,15,15); b.BorderSizePixel = 0
end
AddTab("COMBAT", 0, tabs.Combat, 2)
AddTab("VISUALS", 45, tabs.Visuals, 1)

local function NewToggle(n, tab, var, y)
    local b = Instance.new("TextButton", tab); b.Size = UDim2.new(0.95, 0, 0, 35); b.Position = UDim2.new(0,0,0,y); b.Text = n..": OFF"; b.BackgroundColor3 = Color3.fromRGB(20,20,20); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.Activated:Connect(function() _G[var] = not _G[var] b.Text = n..": "..(_G[var] and "ON" or "OFF") b.BackgroundColor3 = _G[var] and Color3.fromRGB(200,0,0) or Color3.fromRGB(20,20,20) end)
end

NewToggle("Aimbot Master", tabs.Combat, "KTN_MS", 0)
NewToggle("Box ESP", tabs.Visuals, "KTN_ESP_Box", 0)
NewToggle("Tracers", tabs.Visuals, "KTN_ESP_Tracers", 40)
NewToggle("Names", tabs.Visuals, "KTN_ESP_Names", 80)
NewToggle("Health Bar", tabs.Visuals, "KTN_ESP_Health", 120)

-- // 3. MOTOR DE ESP (OS 4 TIPOS) // --
local function CreateESP(p)
    local Box = Drawing.new("Square"); Box.Thickness = 1.5; Box.Filled = false; Box.Color = Color3.new(1,0,0)
    local Line = Drawing.new("Line"); Line.Thickness = 1; Line.Color = Color3.new(1,1,1)
    local Name = Drawing.new("Text"); Name.Size = 14; Name.Center = true; Name.Outline = true; Name.Color = Color3.new(1,1,1)
    local Health = Drawing.new("Line"); Health.Thickness = 2

    RunService.RenderStepped:Connect(function()
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= lp and p.Character.Humanoid.Health > 0 then
            local root = p.Character.HumanoidRootPart
            local pos, onS = cam:WorldToViewportPoint(root.Position)
            if onS then
                local sX, sY = 2200/pos.Z, 3500/pos.Z
                Box.Visible = _G.KTN_ESP_Box; Box.Size = Vector2.new(sX, sY); Box.Position = Vector2.new(pos.X-sX/2, pos.Y-sY/2)
                Line.Visible = _G.KTN_ESP_Tracers; Line.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y); Line.To = Vector2.new(pos.X, pos.Y+sY/2)
                Name.Visible = _G.KTN_ESP_Names; Name.Text = p.Name; Name.Position = Vector2.new(pos.X, pos.Y - sY/2 - 15)
                Health.Visible = _G.KTN_ESP_Health
                local h = p.Character.Humanoid.Health / p.Character.Humanoid.MaxHealth
                Health.From = Vector2.new(pos.X - sX/2 - 5, pos.Y + sY/2); Health.To = Vector2.new(pos.X - sX/2 - 5, pos.Y + sY/2 - (sY*h)); Health.Color = Color3.fromHSV(h*0.3, 1, 1)
            else Box.Visible=false; Line.Visible=false; Name.Visible=false; Health.Visible=false end
        else Box.Visible=false; Line.Visible=false; Name.Visible=false; Health.Visible=false end
    end)
end
for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- // 4. AIMBOT (LERP 0.8) // --
RunService.RenderStepped:Connect(function()
    if _G.KTN_MS and _G.KTN_ACCESS >= 2 then
        local target, dist = nil, 400
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                local p, onS = cam:WorldToViewportPoint(v.Character.Head.Position)
                if onS then
                    local m = (Vector2.new(p.X, p.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                    if m < dist then target = v.Character.Head; dist = m end
                end
            end
        end
        if target then cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Position), _G.KTN_LERP) end
    end
end)

local open = Instance.new("TextButton", gui); open.Size = UDim2.new(0,40,0,40); open.Position = UDim2.new(0,10,0.5,0); open.Text = "K"; open.Activated:Connect(function() main.Visible = not main.Visible end)
