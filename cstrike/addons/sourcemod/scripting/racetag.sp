#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include "W3SIncs/War3Source_Interface"

public Plugin:myinfo =
{
    name = "AdminTag",
    description = "Private plugin",
    author = "KeepCalm",
    version = "2.0",
    url = ""
};


public OnPluginStart()
{
    HookEvent("player_team", Event, EventHookMode:1);
    HookEvent("player_spawn", Event, EventHookMode:1);
    return 0;
}

public OnClientPutInServer(client)
{
    HandleTag(client);
    return 0;
}

public Action:Event(Handle:event, String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (0 < client)
    {
        HandleTag(client);
    }
    return Action:0;
}

HandleTag(client)

{ 
    if(client>0)
    {
        new String:fullracename[128];
        new String:racename[128];
        new String:level[10];

        Format(level, sizeof(level), "%i", War3_GetLevel(client, War3_GetRace(client)));
        War3_GetRaceName(War3_GetRace(client),racename,sizeof(racename));

        Format(fullracename, sizeof(fullracename), "[%s-%s]", level,racename);

        CS_SetClientClanTag(client, fullracename); 
    }
}