local Plugin = Shine.Plugin( ... )

Plugin.Version = "1.0"

Plugin.HasConfig = true
Plugin.ConfigName = "NSLDiscordBridge.json"
Plugin.DefaultConfig = {
    discordWebhookUrl = ""
}
Plugin.CheckConfig = true
Plugin.CheckConfigTypes = true
Plugin.CheckConfigRecursively = false

Plugin.DefaultState = true

function Plugin:Initialise()
    local filepath = "config://NSL-Discord-Bridge.json"
    local configFile = io.open(filepath, "r")
    if configFile then
        local discord_bridge_config = json.decode(configFile:read("*all"))
        Plugin.Config.discordWebhookUrl = discord_bridge_config['discordWebhookUrl']
        self:SaveConfig()
        io.close(configFile)

        os.remove(filepath)
    end

    return true
end

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

function Plugin:EndGame( Gamerules, WinningTeam )
    if WinningTeam == kGameState.Team1Won then
        PostMessage("Marines won")
    elseif WinningTeam == kGameState.Team2Won then
        PostMessage("Aliens won")
    elseif WinningTeam == kGameState.Draw then
        PostMessage("Draw???")
    end
end

return Plugin
