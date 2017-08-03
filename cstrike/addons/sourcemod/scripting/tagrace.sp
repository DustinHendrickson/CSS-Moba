#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include "W3SIncs/War3Source_Interface"

public Plugin:myinfo = 
{
    name = "War3Source - Addon - TagRaceChat",
    author = "SenatoR",
    description = "",
    version = "1.0"
}

public OnPluginStart()
{
    RegConsoleCmd("say", Say_Hook);
    RegConsoleCmd("say_team", Say_Hook);
}

new String:ColorCode[][] = {"\x08", "\x06", "\x04", "\x03","\x0E", "\x0", "\x09", "\x01", "\x0C", "\x0B","\x04", "\x05", "\x01", "\x07"};
new String:ColorCodeClient[][] ={"","\x08","\x02","\x0B"};

public Action:Say_Hook(client, args)
{
    if(client>0)
    {
        decl String:sText[256];
        GetCmdArgString(sText, sizeof(sText));
        StripQuotes(sText);
        new String:racename[128];
        new String:level[10];
        Format(level, sizeof(level), "%i", War3_GetLevel(client, War3_GetRace(client)));
        War3_GetRaceName(War3_GetRace(client),racename,sizeof(racename));
        new i = GetRandomInt(0,14);
        PrintToChatAll(" \x01[%s][\x07%s%s\x01] \x07%s%N\x01: %s",level,ColorCode[i],racename,ColorCodeClient[GetClientTeam(client)],client, sText);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}