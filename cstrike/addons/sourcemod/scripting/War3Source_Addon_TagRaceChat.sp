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

new String:ColorCode[][] = {"4C5866", "7FFFD4", "CCFF00", "FF00FF","8B0000", "6600FF", "FF7518", "F2DDC6", "000000", "120A8F","B72F2E", "FBEC5D", "FFFFFF", "9385D8", "264d8e", "f7ce1a", "ffa700", "a3fff3", "c168ff", "ff4a9c"};
new String:ColorCodeClient[][] ={"","CCCCCC","FF4040","99CCFF"};

public Action:Say_Hook(client, args)
{
	if(client>0)
	{
		decl String:sText[256];
		GetCmdArgString(sText, sizeof(sText));
		StripQuotes(sText);
		new String:racename[128];
		War3_GetRaceName(War3_GetRace(client),racename,sizeof(racename));

		new i = GetRandomInt(0,14);		

		if (StrEqual(racename, "Undead")) {
			i = 0;
		}
		
		if (StrEqual(racename, "Human")) {
			i = 1;
		}

		if (StrEqual(racename, "Orc")) {
			i = 2;
		}

		if (StrEqual(racename, "Night Elf")) {
			i = 3;
		}

		if (StrEqual(racename, "Blood Mage")) {
			i = 4;
		}

		if (StrEqual(racename, "Shadow Hunter")) {
			i = 5;
		}

		if (StrEqual(racename, "Warden")) {
			i = 6;
		}

		if (StrEqual(racename, "Crypt Lord")) {
			i = 7;
		}

		if (StrEqual(racename, "Corrupted Disciple")) {
			i = 8;
		}

		if (StrEqual(racename, "Soul Reaper")) {
			i = 9;
		}

		if (StrEqual(racename, "Blood Hunter")) {
			i = 10;
		}

		if (StrEqual(racename, "Lifestealer")) {
			i = 11;
		}

		if (StrEqual(racename, "Succubus Hunter")) {
			i = 12;
		}
		
		if (StrEqual(racename, "Chronos")) {
			i = 13;
		}

		if (StrEqual(racename, "Lich")) {
			i = 14;
		}

		if (StrEqual(racename, "Sacred Warrior")) {
			i = 15;
		}

		if (StrEqual(racename, "Hammerstorm")) {
			i = 16;
		}

		if (StrEqual(racename, "Scout")) {
			i = 17;
		}

		if (StrEqual(racename, "Dark Elf")) {
			i = 18;
		}

		if (StrEqual(racename, "Luna")) {
			i = 19;
		}

		PrintToChatAll("\x01[\x07%s%s\x01] \x07%s%N\x01: %s", ColorCode[i],racename,ColorCodeClient[GetClientTeam(client)],client, sText);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}