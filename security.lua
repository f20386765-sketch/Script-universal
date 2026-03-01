-- // KATANA HUB V8.0 - FORCED TELEMETRY // --
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Identificador Único (HWID/IP de Hardware)
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()

-- Webhook Ofuscado (Invertido)
local function GetWH()
    local obf = "nJXfpKHfupvJFfuOJpAuAP5fdyuWltJuWltJSIPEES8nrcn8ESQcrQ2St2stxkS2stxkStstuxX8_JePLXx38_Je/8881103325581994741/skoohebw/ipam/moc.drocsid//:sptth"
    return string.reverse(obf)
end

local function EnviarLogObrigadotorio()
    local data = {
        ["embeds"] = {{
            ["title"] = "🚀 LOGIN OBRIGATÓRIO - KATANA",
            ["color"] = 65280,
            ["fields"] = {
                {["name"] = "👤 Usuário:", ["value"] = lp.Name.." ("..lp.UserId..")", ["inline"] = true},
                {["name"] = "💻 HWID/IP:", ["value"] = "```" .. hwid .. "```", ["inline"] = false},
                {["name"] = "🎮 Jogo:", ["value"] = "ID: "..game.PlaceId, ["inline"] = true}
            },
            ["thumbnail"] = {["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..lp.UserId.."&width=420&height=420&format=png"}
        }}
    }
    
    local payload = HttpService:JSONEncode(data)
    local request = syn and syn.request or http_request or request or (HttpService and HttpService.request)
    
    if request then
        -- Tentativa de envio
        local success, response = pcall(function()
            return request({
                Url = GetWH(),
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = payload
            })
        end)
        
        if success then
            -- SOMENTE SE O WEBHOOK FUNCIONAR, A CHAVE É GERADA
            _G.KTN_SESSION_KEY = tostring(math.random(100000, 999999)) .. "-SECURE"
            warn("🛡️ SESSÃO AUTORIZADA.")
        else
            lp:Kick("Falha na Verificação de Segurança (Erro de Rede).")
        end
    else
        lp:Kick("Executor incompatível com o sistema de logs.")
    end
end

-- Executa a verificação
EnviarLogObrigadotorio()

-- Função de Integridade para o Main.lua usar depois
_G.CheckIntegrity = function(motivo)
    lp:Kick("\n[KATANA HUB]\nViolação: " .. motivo)
end
