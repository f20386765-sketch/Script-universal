-- // KATANA HUB V5.2 - SECURITY MODULE // --
local HttpService = game:GetService("HttpService")
local lp = game:GetService("Players").LocalPlayer

_G.KTN_SESSION_KEY = tostring(math.random(100000, 999999)) .. "-SECURE"

local function EnviarLog(motivo)
    local WH = "https://discord.com/api/webhooks/1474991855233011888/eJ_83XxPLkDAnK9Z8s60vy6fqzyzzZ6Xts2Qcrn8SEPI4_JtlWuydf5PAJuofJFpvKHN"
    local data = {
        ["embeds"] = {{
            ["title"] = "🚨 SEGURANÇA KATANA",
            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "Jogador:", ["value"] = lp.Name.." ("..lp.UserId..")"},
                {["name"] = "Motivo:", ["value"] = motivo}
            }
        }}
    }
    local req = syn and syn.request or http_request or request or HttpService.request
    pcall(function() req({Url = WH, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)}) end)
end

_G.CheckIntegrity = function(motivo)
    EnviarLog(motivo)
    lp:Kick("\n[KATANA HUB]\nSegurança: " .. motivo)
end

warn("🛡️ SEGURANÇA ATIVA: CHAVE GERADA.")
