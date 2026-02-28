
local p = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = p:GetMouse()
local RunService = game:GetService("RunService")

_G.SilentAim = false; _G.AimbotLock = false; _G.ESP = false; _G.VipSpeed = false; _G.UseFOV = false
_G.FOVRadius = 150

-- // FUNÇÃO ALVO // --
local function GetTarget()
    local target, dist = nil, (_G.UseFOV and _G.FOVRadius or 2000)
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= p and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mDist < dist then target = v dist = mDist end
            end
        end
    end
    return target
end

-- // METATABLE SILENT AIM // --
local mt = getrawmetatable(game); setreadonly(mt, false); local old = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if _G.SilentAim and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local t = GetTarget()
        if t then
            if method == "Raycast" then args[2] = (t.Character.Head.Position - args[1]).Unit * 1000
            else args[1] = Ray.new(Camera.CFrame.Position, (t.Character.Head.Position - Camera.CFrame.Position).Unit * 1000) end
            return old(self, unpack(args))
        end
    end
    return old(self, ...)
end); setreadonly(mt, true)

-- // MENU VIP // --
local UI = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", UI); Main.Size = UDim2.new(0, 200, 0, 320); Main.Position = UDim2.new(0.5, -100, 0.4, 0); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Draggable = true; Main.Active = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main); Title.Size = UDim2.new(1, 0, 0, 35); Title.Text = "KATANA HUB"; Title.BackgroundColor3 = Color3.fromRGB(180, 0, 0); Title.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Title)

local function CriarBotao(txt, pos, var)
    local b = Instance.new("TextButton", Main); b.Size = UDim2.new(0.9, 0, 0, 40); b.Position = UDim2.new(0.05, 0, 0, pos); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() _G[var] = not _G[var]; b.BackgroundColor3 = _G[var] and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30) end)
end

CriarBotao("SILENT AIM", 45, "SilentAim")
CriarBotao("AIMBOT LOCK", 95, "AimbotLock")
CriarBotao("ESP NOMES", 145, "ESP")
CriarBotao("SPEED GHOST", 195, "VipSpeed")

-- // LOOP // --
RunService.RenderStepped:Connect(function()
    local t = GetTarget()
    if _G.AimbotLock and t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position) end
    if _G.VipSpeed and p.Character then p.Character.HumanoidRootPart.CFrame += p.Character.Humanoid.MoveDirection * 0.45 end
end)
