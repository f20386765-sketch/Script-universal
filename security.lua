-- // KATANA HUB - PRIVATE SECURITY SHIELD // --
local HttpService = game:GetService("HttpService")
local lp = game:GetService("Players").LocalPlayer

-- Webhook Ofuscado (Link decomposto e codificado)
local function Get_SH()
    local p1 = "https://discord.com/api/webhooks/"
    local p2 = "1474991855233011888"
    local p3 = "/"
    local p4 = "eJ_83XxPLkDAnK9Z8s60vy6fqzyzzZ6Xts2Qcrn8SEPI4_JtlWuydf5PAJuofJFpvKHN"
    
    -- Reconstrói apenas na execução (RAM)
    return p1 .. p2 .. p3 .. p4
end

_G.CheckIntegrity = function(motivo)
    local URL = Get_SH()
    local data = {
        ["username"] = "KATANA ANTI-CHEAT",
        ["avatar_url"] = "https://i.imgur.com/8f8v9K4.png",
        ["embeds"] = {{
            ["title"] = "🚨 TENTATIVA DE FRAUDE DETETADA",
            ["description"] = "Um usuário tentou alterar o código ou rank localmente.",
            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "Jogador:", ["value"] = "```" .. lp.Name .. "```", ["inline"] = true},
                {["name"] = "User ID:", ["value"] = "```" .. tostring(lp.UserId) .. "```", ["inline"] = true},
                {["name"] = "Motivo da Expulsão:", ["value"] = "**" .. motivo .. "**", ["inline"] = false},
                {["name"] = "Perfil:", ["value"] = "https://www.roblox.com/users/" .. lp.UserId .. "/profile"}
            },
            ["footer"] = {["text"] = "Katana Hub V4 - Security System"},
            ["timestamp"] = os.date("!Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    local headers = {["Content-Type"] = "application/json"}
    local request = syn and syn.request or http_request or request or HttpService.request

    pcall(function()
        request({
            Url = URL,
            Method = "POST",
            Headers = headers,
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    task.wait(0.5)
    lp:Kick("\n[KATANA HUB]\nErro Crítico de Segurança (0x88).\nSua conta foi reportada ao Dono.")
end

warn("SEGURANÇA ATIVA.")
