-- // OWNER PANEL - APENAS FUNÇÕES DE DONO // --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

_G.OwnerAimbot = true
_G.Tracers = true

-- MIRA INSTA-LOCK 1.0 (SÓ PARA O DONO)
RunService.RenderStepped:Connect(function()
    if _G.KatanaMaster and _G.OwnerAimbot then
        local target, dist = nil, 1000
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                local p, vis = cam:WorldToViewportPoint(v.Character.Head.Position)
                if vis then
                    local m = (Vector2.new(p.X, p.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                    if m < dist then target = v; dist = m end
                end
            end
        end
        if target then cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character.Head.Position) end
    end
end)

-- INTERFACE EXTRA DO DONO
local sg = Instance.new("ScreenGui", CoreGui)
local f = Instance.new("Frame", sg)
f.Size = UDim2.new(0, 150, 0, 120); f.Position = UDim2.new(0, 10, 0.7, 0); f.BackgroundColor3 = Color3.fromRGB(20, 20, 20); f.BorderColor3 = Color3.fromRGB(255, 215, 0)
Instance.new("UICorner", f)

local b1 = Instance.new("TextButton", f)
b1.Size = UDim2.new(0.9, 0, 0, 35); b1.Position = UDim2.new(0.05, 0, 0.1, 0); b1.Text = "KILL OTHERS"; b1.BackgroundColor3 = Color3.fromRGB(150, 0, 0); b1.TextColor3 = Color3.new(1,1,1)

b1.MouseButton1Click:Connect(function()
    local s = Instance.new("StringValue", game.ReplicatedStorage)
    s.Name = "KatanaKillSwitch"
    b1.Text = "EXECUTADO"
    task.wait(1)
    s:Destroy()
    b1.Text = "KILL OTHERS"
end)

print("PAINEL DO DONO ATIVADO.")
