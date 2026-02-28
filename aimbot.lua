-- // KATANA HUB - MODULO AIMBOT FULL HEAD // --
local p = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = p:GetMouse()
local RunService = game:GetService("RunService")

_G.AimbotLock = false
_G.SilentAim = false
_G.FOVVisible = false
_G.FOVSize = 150

-- Desenho do FOV (Círculo Vermelho no Mouse)
local FOV = Drawing.new("Circle")
FOV.Color = Color3.fromRGB(255, 0, 0)
FOV.Thickness = 1
FOV.NumSides = 60
FOV.Radius = _G.FOVSize
FOV.Visible = false
FOV.Filled = false

local function GetClosestHead()
    local target = nil
    local dist = _G.FOVSize
    for _, v in pairs(game.Players:GetPlayers()) do
        -- Verifica se o player existe, se não é você, se tem cabeça e se está vivo
        if v ~= p and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if magnitude < dist then
                    target = v
                    dist = magnitude
                end
            end
        end
    end
    return target
end

-- // HOOK DE SILENT AIM (FORCE HEAD) // --
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if _G.SilentAim and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local t = GetClosestHead()
        if t then
            -- Redireciona o tiro exatamente para a cabeça
            local headPos = t.Character.Head.Position
            if method == "Raycast" then
                args[2] = (headPos - args[1]).Unit * 1000
            else
                args[1] = Ray.new(Camera.CFrame.Position, (headPos - Camera.CFrame.Position).Unit * 1000)
            end
            return old(self, unpack(args))
        end
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- // LOOP DE ATUALIZAÇÃO // --
RunService.RenderStepped:Connect(function()
    -- Atualiza o FOV visual
    FOV.Visible = _G.FOVVisible
    FOV.Radius = _G.FOVSize
    FOV.Position = Vector2.new(Mouse.X, Mouse.Y + 36)

    -- Aimbot Lock (Trava a mira na cabeça)
    if _G.AimbotLock then
        local t = GetClosestHead()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
        end
    end
end)
