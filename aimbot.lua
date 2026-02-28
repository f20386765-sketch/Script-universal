-- // KATANA HUB V2 - MAIN SCRIPT (COM ESP) // --
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

-- // 1. SINCRONIZAÇÃO E CARGOS // --
local function SyncRemote()
    local success, response = pcall(function() return game:HttpGet(ConfigURL .. "?t=" .. math.random(1, 9999)) end)
    if success then
        local data = HttpService:JSONDecode(response)
        for _, id in pairs(data.BannedUsers or {}) do if lp.UserId == id then lp:Kick("\n[KATANA HUB]\nBanido.") end end
        
        _G.UserRank = "User"
        for _, id in pairs(data.VipUsers or {}) do if lp.UserId == id then _G.UserRank = "VIP" end end
        for _, id in pairs(data.Admins or {}) do if lp.UserId == id then _G.UserRank = "ADM" end end
        for _, id in pairs(data.Owner or {}) do if lp.UserId == id then _G.UserRank = "OWNER" end end

        if _G.UserRank == "OWNER" then
            task.spawn(function() loadstring(game:HttpGet(OwnerRaw))() end)
        end
    end
end
SyncRemote()

-- // 2. SISTEMA DE ESP (BOX + NAME) // --
local function CreateESP(plr)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 1
    Box.Filled = false

    local Name = Drawing.new("Text")
    Name.Visible = false
    Name.Color = Color3.new(1, 1, 1)
    Name.Size = 14
    Name.Center = true
    Name.Outline = true

    RunService.RenderStepped:Connect(function()
        if _G.KatanaMaster and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr ~= lp and plr.Character.Humanoid.Health > 0 then
            local rootPos, onScreen = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local sizeX = 2000 / rootPos.Z
                local sizeY = 3000 / rootPos.Z
                Box.Size = Vector2.new(sizeX, sizeY)
                Box.Position = Vector2.new(rootPos.X - sizeX / 2, rootPos.Y - sizeY / 2)
                Box.Visible = true
                
                Name.Text = plr.Name
                Name.Position = Vector2.new(rootPos.X, rootPos.Y - (sizeY / 2) - 15)
                Name.Visible = true
            else Box.Visible = false; Name.Visible = false end
        else Box.Visible = false; Name.Visible = false end
    end)
end

for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- // 3. KILL SWITCH // --
game:GetService("ReplicatedStorage").ChildAdded:Connect(function(c)
    if c.Name == "KatanaKillSwitch" and _G.UserRank ~= "OWNER" then _G.KatanaMaster = false end
end)

-- // 4. AIMBOT 0.8 // --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Radius = 130
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Visible = false

RunService.RenderStepped:Connect(function()
    if _G.KatanaMaster then
        FOVCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        FOVCircle.Visible = true
        
        -- Dono não usa esta mira aqui (ele usa a do Owner Panel)
        if _G.UserRank ~= "OWNER" then
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
            if target then cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Character.Head.Position), _G.AimbotStrength) end
        end
    else
        FOVCircle.Visible = false
    end
end)

-- // 5. INTERFACE // --
local sg = Instance.new("ScreenGui", CoreGui)
local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 45, 0, 45); btn.Position = UDim2.new(0, 10, 0.5, 0); btn.Text = "K"; btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 160, 0, 100); frame.Position = UDim2.new(0.5, -80, 0.5, -50); frame.Visible = false; frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
Instance.new("UICorner", frame)

local rankLabel = Instance.new("TextLabel", frame)
rankLabel.Size = UDim2.new(1, 0, 0, 30); rankLabel.Text = "Rank: " .. _G.UserRank; rankLabel.TextColor3 = Color3.new(1,1,1); rankLabel.BackgroundTransparency = 1

local mBtn = Instance.new("TextButton", frame)
mBtn.Size = UDim2.new(0.9, 0, 0, 40); mBtn.Position = UDim2.new(0.05, 0, 0.45, 0); mBtn.Text = "OFF"; mBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); mBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", mBtn)

btn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible rankLabel.Text = "Rank: " .. _G.UserRank end)
mBtn.MouseButton1Click:Connect(function()
    _G.KatanaMaster = not _G.KatanaMaster
    mBtn.Text = _G.KatanaMaster and "ON" or "OFF"
    mBtn.BackgroundColor3 = _G.KatanaMaster and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
end)
