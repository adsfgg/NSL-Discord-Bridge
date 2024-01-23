if not Server then return end

local discord_bridge_config = nil

local filepath = "config://NSL-Discord-Bridge.json"
local configFile = io.open(filepath, "r")
if configFile then
    discord_bridge_config = json.decode(configFile:read("*all"))
    io.close(configFile)
end

assert(discord_bridge_config)

local kURL = discord_bridge_config["discordWebhookUrl"]

local function PostMessage(msg)
    assert(msg)
    assert(string.len(msg) > 0)

    params = {
        content=string.format("%s|%s|%s", msg, Server.GetIpAddress(), Server.GetPort()),
        username="Match Reporter"
    }
    Shared.SendHTTPRequest(kURL, "POST", params,
        function(data)
            msg = string.UTF8Sub("Round data sent to Scrim bot", 1, kMaxChatLength)
            Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Discord Bridge",-1, kTeamReadyRoom, kNeutralTeamType, "Round recorded in Discord bot"), true)
        end
    )
end

oldSetGameState = NS2Gamerules.SetGameState
function NS2Gamerules:SetGameState(state)
    if state == kGameState.Team1Won then
        PostMessage("Marines won")
    elseif state == kGameState.Team2Won then
        PostMessage("Aliens won")
    elseif state == kGameState.Draw then
        PostMessage("Draw???")
    end

    oldSetGameState(self, state)
end
