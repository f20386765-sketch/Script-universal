-- // KATANA HUB V5.2 - MÓDULO DE SEGURANÇA // --
local HttpService = game:GetService("HttpService")
local lp = game:GetService("Players").LocalPlayer

-- // WEBHOOK CONFIG // --
local function EnviarLog(motivo)
    local partA = "https://discord.com/api/webhooks/"
    local partB = "1474991855233011888"
    local partC = "/eJ_83XxPLkDAnK9Z8s60vy6fqzyzzZ6Xts2Qcrn8SEPI4_JtlWuydf5PAJuofJFpvKHN"
    local WH = partA .. partB .. partC

    local data = {
        ["embeds"] = {{
            ["title"] = "🚨 SEGURANÇA KATANA",
            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "Jogador:", ["value"] = lp.Name.." ("..lp.UserId..")"},
                {["name"] = "Motivo:", ["value"] = motivo}
            },
            ["timestamp"] = os.date("!Y-%m-%dT%H:%M:%SZ")
        }}
    }
    local req = syn and syn.request or http_request or request or HttpService.request
    pcall(function() req({Url = WH, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)}) end)
end

-- // GERAÇÃO DA CHAVE DE SESSÃO // --
_G.KTN_SESSION_KEY = tostring(math.random(1000, 9999)) .. "-SECURE"

-- // FUNÇÃO DE CHECAGEM // --
_G.CheckIntegrity = function(motivo)
    EnviarLog(motivo)
    task.wait(0.5)
    lp:Kick("\n[KATANA HUB]\nViolação de Segurança Detetada.")
end

warn("🛡️ SEGURANÇA ATIVA E CHAVE GERADA.")
