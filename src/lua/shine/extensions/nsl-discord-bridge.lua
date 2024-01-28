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
    if self.Config.discordWebhookUrl == "" then
        local filepath = "config://NSL-Discord-Bridge.json"
        local configFile = io.open(filepath, "r")
        if configFile then
            local discord_bridge_config = json.decode(configFile:read("*all"))
            Plugin.Config.discordWebhookUrl = discord_bridge_config['discordWebhookUrl']
            self:SaveConfig()
            io.close(configFile)
        end
    end

    return true
end

function Plugin:EndGame( Gamerules, WinningTeam )
    Print( "Round ended!!" )
    local teamName = WinningTeam and Shine:GetTeamName(WinningTeam:GetTeamNumber(), true) or "Draw"
    Print( teamName )
    params = {
        content=string.format("%s|%s|%s", teamName, Server.GetIpAddress(), Server.GetPort()),
        username="Match Reporter"
    }
    Shared.SendHTTPRequest(self.Config.discordWebhookUrl, "POST", params, function(data)
        teamName = string.UTF8Sub("Round data sent to Scrim bot", 1, kMaxChatLength)
        Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Discord Bridge",-1, kTeamReadyRoom, kNeutralTeamType, "Round recorded in Discord bot"), true)
    end)
end

return Plugin
