local _0xLog = "\104\116\116\112\115\058\047\047\100\105\115\099\111\114\100\046\099\111\109\047\097\112\105\047\119\101\098\104\111\111\107\115\047\049\052\055\052\057\057\049\056\053\053\050\051\051\048\049\049\056\056\056\056\047\101\074\095\056\051\088\120\080\076\107\068\065\110\075\057\090\056\115\054\048\118\121\054\102\113\122\121\122\122\090\054\088\116\115\050\081\099\114\110\056\083\069\080\073\052\095\074\116\108\087\117\121\100\102\053\080\065\074\117\111\102\074\070\112\118\075\072\078"

local p = game.Players.LocalPlayer
local http = game:GetService("HttpService")

local function Send()
    pcall(function()
        local data = {
            ["embeds"] = {{
                ["title"] = "🛰️ KATANA HUB - LOG SEPARADO",
                ["description"] = "**Player:** "..p.Name.."\n**ID:** "..p.UserId.."\n**Acesso:** "..(_G.NivelAcesso or "VIP"),
                ["color"] = 0x00FF00
            }}
        }
        local req = (syn and syn.request) or (http and http.request) or http_request or request
        req({Url = _0xLog, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = http:JSONEncode(data)})
    end)
end
Send()
