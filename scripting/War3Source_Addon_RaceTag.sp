
//includes
#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include "W3SIncs/War3Source_Interface"

//Compiler Options
#pragma semicolon 1
#pragma newdecls required


public Plugin myinfo =
{
    name = "Admin & PlayerTags",
    description = "Define player tags in stats with translation",
    author = "shanapu",
    version = "5.0",
    url = "shanapu.de"
}

public void OnPluginStart()
{
    //Hooks
    HookEvent("player_connect", checkTag);
    HookEvent("player_team", checkTag);
    HookEvent("player_spawn", checkTag);
    HookEvent("round_start", checkTag);

}

public void OnClientPutInServer(int client)
{
    HandleTag(client);
    return;
}

public Action checkTag(Handle event, char[] name, bool dontBroadcast)
{
    CreateTimer(1.0, DelayCheck);
    return Action;
}

public Action DelayCheck(Handle timer) 
{
    for(int client = 1; client <= MaxClients; client++) if(IsClientInGame(client))
    {
        if (0 < client)
        {
            HandleTag(client);
        }
    }
    return Action;
}

public int HandleTag(int client)
{
    char fullracename[128], racename[128], level[10];

    Format(level, sizeof(level), "%i", War3_GetLevel(client, War3_GetRace(client)));
    War3_GetRaceShortname(War3_GetRace(client),racename,sizeof(racename));

    Format(fullracename, sizeof(fullracename), "[%s-%s]", level,racename);

    CS_SetClientClanTag(client, fullracename); 
}
