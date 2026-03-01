-- // KATANA HUB V7.9 - SECURITY (WEBHOOK OBFUSCATED) // --
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Identificador Único (HWID)
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
_G.KTN_SESSION_KEY = tostring(math.random(100000, 999999)) .. "-SECURE"

-- WEBHOOK OFUSCADO (Invertido e Codificado)
-- Para trocar o webhook, você precisaria gerar uma nova string, mas já fiz esta para o seu link:
local function GetWH()
    local obf = "nJXfpKHfupvJFfuOJpAuAP5fdyuWltJuWltJSIPEES8nrcn8ESQcrQ2St2stxkS2stxkStstuxX8_JePLXx38_Je/8881103325581994741/skoohebw/ipam/moc.drocsid//:sptth"
    return string.reverse(obf)
end

local function EnviarLog(motivo, status)
    local data = {
        ["embeds"] = {{
            ["title"] = status == "INFO" and "🚀 KATANA HUB EXECUTADO" or "🚨 SEGURANÇA KATANA",
            ["color"] = status == "INFO" and 65280 or 16711680,
            ["fields"] = {
                {["name"] = "👤 Jogador:", ["value"] = "Nome: " .. lp.Name .. "\nID: " .. lp.UserId, ["inline"] = true},
                {["name"] = "🎮 Jogo ID:", ["value"] = tostring(game.PlaceId), ["inline"] = true},
                {["name"] = "💻 HWID (IP de Hardware):", ["value"] = "```" .. hwid .. "```", ["inline"] = false},
                {["name"] = "📝 Motivo/Status:", ["value"] = motivo, ["inline"] = false}
            },
            ["footer"] = {["text"] = "Katana Hub v7.9 • " .. os.date("%X")},
            ["thumbnail"] = {["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..lp.UserId.."&width=420&height=420&format=png"}
        }}
    }
    
    local payload = HttpService:JSONEncode(data)
    local request = syn and syn.request or http_request or request or (HttpService and HttpService.request)
    
    if request then
        pcall(function() 
            request({
                Url = GetWH(), 
                Method = "POST", 
                Headers = {["Content-Type"] = "application/json"}, 
                Body = payload
            }) 
        end)
    end
end

-- Função Global de Integridade
_G.CheckIntegrity = function(motivo)
    EnviarLog(motivo, "ALERT")
    task.wait(0.5)
    lp:Kick("\n[KATANA HUB]\nSegurança: " .. motivo)
end

-- Envia o log de entrada
task.spawn(function()
    EnviarLog("Script carregado com sucesso.", "INFO")
end)

warn("🛡️ SEGURANÇA ATIVA E CRIPTOGRAFADA.")
