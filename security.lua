-- // KATANA HUB V5 - MÓDULO DE SEGURANÇA PRIVADO // --
local HttpService = game:GetService("HttpService")
local lp = game:GetService("Players").LocalPlayer

-- // 1. CONFIGURAÇÃO DO WEBHOOK OFUSCADO // --
local function EnviarLog(motivo)
    -- Teu Webhook decomposto para evitar deteção de bots
    local partA = "https://discord.com/api/webhooks/"
    local partB = "1474991855233011888"
    local partC = "/eJ_83XxPLkDAnK9Z8s60vy6fqzyzzZ6Xts2Qcrn8SEPI4_JtlWuydf5PAJuofJFpvKHN"
    local WH = partA .. partB .. partC

    local data = {
        ["username"] = "KATANA SHIELD",
        ["avatar_url"] = "https://i.imgur.com/8f8v9K4.png",
        ["embeds"] = {{
            ["title"] = "🚨 VIOLAÇÃO DE SEGURANÇA DETETADA",
            ["description"] = "O sistema de proteção interrompeu uma tentativa de fraude.",
            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "Utilizador:", ["value"] = "```" .. lp.Name .. "```", ["inline"] = true},
                {["name"] = "User ID:", ["value"] = "```" .. tostring(lp.UserId) .. "```", ["inline"] = true},
                {["name"] = "Motivo:", ["value"] = "**" .. motivo .. "**", ["inline"] = false},
                {["name"] = "Perfil:", ["value"] = "https://www.roblox.com/users/" .. lp.UserId .. "/profile"}
            },
            ["footer"] = {["text"] = "Katana Hub V5 - Anti-Tamper System"},
            ["timestamp"] = os.date("!Y-%m-%dT%H:%M:%SZ")
        }}
    }

    -- Suporte para vários executores (Solara, Delta, Wave, etc)
    local request = syn and syn.request or http_request or request or HttpService.request
    pcall(function()
        request({
            Url = WH,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- // 2. GERAÇÃO DA CHAVE DE SESSÃO (HANDSHAKE) // --
-- Esta chave é o que permite ao script principal funcionar.
-- Se esta variável não existir, o main.lua dá Kick no utilizador.
_G.KTN_SESSION_KEY = tostring(math.random(100000, 999999)) .. "-SECURE-KEY"

-- // 3. FUNÇÃO DE INTEGRIDADE GLOBAL // --
_G.CheckIntegrity = function(motivo)
    EnviarLog(motivo)
    task.wait(0.3)
    lp:Kick("\n[KATANA HUB]\nErro de Sincronização: Sessão Inválida.\nID reportado ao Servidor.")
end

-- // 4. PROTEÇÃO DE MEMÓRIA // --
-- Se alguém tentar apagar a chave durante o jogo, o sistema deteta.
task.spawn(function()
    while task.wait(5) do
        if not _G.KTN_SESSION_KEY or not _G.KTN_SESSION_KEY:find("-SECURE") then
            lp:Kick("Security Violation: Session Tampering.")
        end
    end
end)

warn("🛡️ KATANA SECURITY: Módulo Carregado com Sucesso.")
