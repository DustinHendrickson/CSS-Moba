/**
* File: War3Source_Addon_Hud_Info.sp
* Description: Shows an RPG style HUD with a whole lot of useful information
* Author(s): Remy Lebeau (based on [RUS] SenatoR's concept)
* Current functions:     
*                   * Displays self or 1st person spec player
                    * Can be toggled on/off through either console sm_hud, or in chat "hud"
                    * Includes a native function to over-ride the HUD for custom game types
                            * INCLUDE DETAILS OF HOW TO USE IT HERE    
*/


#include <sourcemod>
#include "W3SIncs/War3Source_Interface"
#include <smlib>
#include <clientprefs>
#include "cssthrowingknives.inc"
#pragma semicolon 1

public Plugin:myinfo = 
{
    name = "War3Source - Engine - HUD Info",
    author = "Remy Lebeau (based on [RUS] SenatoR's concept)",
    description = "Show player information in Hud",
    version = "5.3",
    url = "war3source.com"
};

new Re_killtimer;
new g_bShowHUD[MAXPLAYERS];
new MoneyOffsetCS;
new Handle:g_hMyCookie;
new bool:bRankCached[MAXPLAYERSCUSTOM];
new iRank[MAXPLAYERSCUSTOM];
new iTotalPlayersDB[MAXPLAYERSCUSTOM];
new Handle:ShowOtherPlayerItemsCvar;
new String:HUD_Text_Buffer[MAXPLAYERS][500];
new String:HUD_Text_Add[MAXPLAYERS][500];
new bool:g_bCustomHUD = false;
new Float:g_fHUDDisplayTime = 0.5;
new Handle:g_hPlayerHUDMenu = INVALID_HANDLE;
new g_bTimedHUD[MAXPLAYERS];
new Handle:g_hTimedCookie;

public LoadCheck()
{
    if (GameTF())
    {
        return true;
    }
    if(GameCS())
    {
        return true;
    }
    PrintToServer("[HUD Info] ERROR ONLY TF2 & CSS ARE SUPPORTED.");
    return false;
}

public APLRes:AskPluginLoad2Custom(Handle:myself, bool:late, String:error[], err_max)
{
   CreateNative("HUD_Message", Native_HUD_Message);
   CreateNative("HUD_Override", Native_HUD_Override);
   CreateNative("HUD_Add", Native_HUD_Add);
   return APLRes_Success;
}


public Native_HUD_Message(Handle:plugin, numParams)
{
    new client = GetClientOfUserId(GetNativeCell(1));

    if(ValidPlayer(client))
    {
        GetNativeString(2, HUD_Text_Buffer[client], 500);
        return 1;   
    }
    return 0;
}

public Native_HUD_Add(Handle:plugin, numParams)
{
    new client = GetClientOfUserId(GetNativeCell(1));

    if(ValidPlayer(client))
    {
        GetNativeString(2, HUD_Text_Add[client], 500);
        return 1;   
    }
    return 0;
}

public Native_HUD_Override(Handle:plugin, numParams)
{
    g_bCustomHUD = GetNativeCell(1);
    return 0;   
}

public OnPluginStart()
{
    HookEvent("player_spawn", Event_PlayerSpawn);    
    HookEvent("round_start", Event_RoundStart);    
    HookEvent("round_end", Event_RoundEnd);    
    
    RegConsoleCmd("sm_hud", Command_ToggleHUD, "Toggles the HUD on/off");
    RegConsoleCmd("say hud", Command_ToggleHUD, "Toggles the HUD on/off");
    RegConsoleCmd("say_team hud", Command_ToggleHUD, "Toggles the HUD on/off");
    if(GameCS())
    {
        MoneyOffsetCS=FindSendPropInfo("CCSPlayer","m_iAccount");
    }
    g_hMyCookie = RegClientCookie("w3shud_toggle", "W3S HUD Visibility Toggle", CookieAccess_Protected);
    g_hTimedCookie = RegClientCookie("w3shud_timed", "W3S HUD Visibility Timer", CookieAccess_Protected);
}

public OnMapStart()
{
    ShowOtherPlayerItemsCvar = FindConVar("war3_show_playerinfo_other_player_items");
}

public OnClientPutInServer(client)
{
    g_bShowHUD[client] = 0;
    g_bTimedHUD[client] = 0;
    GetRank(client);
}

public Action:Command_ToggleHUD(client, args)
{
    if(ValidPlayer(client))
    {
    
        if (g_hPlayerHUDMenu != INVALID_HANDLE)
        {
            CloseHandle(g_hPlayerHUDMenu);
            g_hPlayerHUDMenu = INVALID_HANDLE;
        }
        g_hPlayerHUDMenu = CreateMenu(Menu_HUD);
        
        SetMenuTitle(g_hPlayerHUDMenu, "HUD Settings (persistent)");

        AddMenuItem(g_hPlayerHUDMenu, "off", "Disable HUD"); // 0 in prefs
        AddMenuItem(g_hPlayerHUDMenu, "minimal", "Minimal HUD (currently bugged - flashing)"); //1 in prefs
        AddMenuItem(g_hPlayerHUDMenu, "left", "Larger HUD on LEFT (non flashing)"); // 2 in prefs
        AddMenuItem(g_hPlayerHUDMenu, "right", "Larger HUD on RIGHT (non flashing)"); // 3 in prefs
        
        decl String:sCookieValue[11];
        GetClientCookie(client, g_hTimedCookie, sCookieValue, sizeof(sCookieValue));
        new cookieValue = StringToInt(sCookieValue);
        
        if (cookieValue == 0)
        {
            AddMenuItem(g_hPlayerHUDMenu, "timed", "Toggle -ON- display HUD for first 15 seconds after spawn (independent of other settings)");
        }
        if (cookieValue == 1)
        {
            AddMenuItem(g_hPlayerHUDMenu, "timed", "Toggle -OFF- display HUD for first 15 seconds after spawn (independent of other settings)");
        }
        

        DisplayMenu(g_hPlayerHUDMenu, client, 15);
    }
    return Plugin_Handled;
}


public Menu_HUD(Handle:menu, MenuAction:action, param1, param2)
{
    if (action == MenuAction_Select)
    {
        new String:info[16];
        new client = param1;
 
        /* Get item info */
        new bool:found = GetMenuItem(menu, param2, info, sizeof(info));
        
        if (found)
        {
            decl String:sCookieValue[11];
            if( StrEqual( info, "off" ) )
            {
                IntToString(0, sCookieValue, sizeof(sCookieValue));
                SetClientCookie(client, g_hMyCookie, sCookieValue);
                g_bShowHUD[client] = 0;
            }
            if( StrEqual( info, "minimal" ) )
            {
                IntToString(1, sCookieValue, sizeof(sCookieValue));
                SetClientCookie(client, g_hMyCookie, sCookieValue);
                g_bShowHUD[client] = 1;
            }
            if( StrEqual( info, "left" ) )
            {
                IntToString(2, sCookieValue, sizeof(sCookieValue));
                SetClientCookie(client, g_hMyCookie, sCookieValue);
                g_bShowHUD[client] = 2;
            }
        
            if( StrEqual( info, "right" ) )
            {
                IntToString(3, sCookieValue, sizeof(sCookieValue));
                SetClientCookie(client, g_hMyCookie, sCookieValue);
                g_bShowHUD[client] = 3;
            }
            if( StrEqual( info, "timed" ) )
            {
                GetClientCookie(client, g_hTimedCookie, sCookieValue, sizeof(sCookieValue));
                new cookieValue = StringToInt(sCookieValue);
                g_bTimedHUD[client] = cookieValue==1?0:1;
                
                IntToString(g_bTimedHUD[client], sCookieValue, sizeof(sCookieValue));
                SetClientCookie(client, g_hTimedCookie, sCookieValue);
            }
        }
    }

}


public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    Re_killtimer = 0;

}
public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    Re_killtimer = 1;
}
public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    CreateTimer(0.4, HudInfo_Timer, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    if (AreClientCookiesCached(client))
    {
        decl String:sCookieValue[11];
        GetClientCookie(client, g_hMyCookie, sCookieValue, sizeof(sCookieValue));
        new cookieValue = StringToInt(sCookieValue);
        g_bShowHUD[client] = cookieValue;
        
        GetClientCookie(client, g_hTimedCookie, sCookieValue, sizeof(sCookieValue));
        cookieValue = StringToInt(sCookieValue);
        g_bTimedHUD[client] = cookieValue;
    }
    if(g_bTimedHUD[client] == 1)
    {
        CreateTimer(15.0, StopHUD, client);
    }
}

public Action:StopHUD(Handle:timer, any:client)
{
    if(ValidPlayer(client))
    {
        g_bShowHUD[client] = 0;
    }
}

public Action:HudInfo_Timer(Handle:timer, any:client)
{
    if (ValidPlayer(client) && Re_killtimer == 0)
    {

        if(g_bShowHUD[client] != 0 || g_bTimedHUD[client] == 1)
        {
            new display = client; 
            new observed = -1;
            if(!g_bCustomHUD)
            {
                if(!IsPlayerAlive(display))
                {
                    if(OBS_MODE_IN_EYE == Client_GetObserverMode(display))
                        observed = Client_GetObserverTarget(display); 
                    if(ValidPlayer(observed, true))
                        client = observed;
                }   
                new race=War3_GetRace(client);
                if (race > 0)
                {                    
                    decl String:HUD_Text[255];
                    new String:racename[64];
                    War3_GetRaceName(race,racename,sizeof(racename));
                    new level=War3_GetLevel(client, race);
   
                    Format(HUD_Text, sizeof(HUD_Text), "Race: %s\nLevel: %i/%i - XP: %i/%i\nTotal Level: %d\nGold: %i", 
                        racename,
                        level,
                        W3GetRaceMaxLevel(race),
                        War3_GetXP(client, race),
                        W3GetReqXP(level+1),
                        GetClientTotalLevels(client),
                        War3_GetGold(client));
                        
                    if(GameCS())
                    {
                        Format(HUD_Text, sizeof(HUD_Text), "%s - Money: %i", 
                        HUD_Text,
                        GetMoney(client));
                    }
                    if(iRank[client]>0)
                    {
                        Format(HUD_Text, sizeof(HUD_Text), "%s\nWar3rank: %d",HUD_Text, iRank[client]);
                    }
                    new Float:speedmulti=1.0;
                                    
                    if(!W3GetBuffHasTrue(client,bBuffDenyAll)){
                        speedmulti=W3GetBuffMaxFloat(client,fMaxSpeed)+W3GetBuffMaxFloat(client,fMaxSpeed2)-1.0;
                    }
                    if(W3GetBuffHasTrue(client,bStunned)||W3GetBuffHasTrue(client,bBashed)){
                        speedmulti=0.0;
                    }
                    if(!W3GetBuffHasTrue(client,bSlowImmunity)){
                        speedmulti=FloatMul(speedmulti,W3GetBuffStackedFloat(client,fSlow)); 
                        speedmulti=FloatMul(speedmulti,W3GetBuffStackedFloat(client,fSlow2)); 
                    }
                    
                    if(speedmulti != 1.0)
                    {
                        Format(HUD_Text, sizeof(HUD_Text), "%s\nSpeed: %.2f",HUD_Text, speedmulti);
                    }
                    
                    if(W3GetBuffMinFloat(client,fLowGravitySkill) != 1.0)
                    {
                        Format(HUD_Text, sizeof(HUD_Text), "%s\nGravity: %.2f",HUD_Text, W3GetBuffMinFloat(client,fLowGravitySkill));
                    }
                    
                    new Float:falpha=1.0;
                    if(!W3GetBuffHasTrue(client,bInvisibilityDenySkill))
                    {
                        falpha=FloatMul(falpha,W3GetBuffMinFloat(client,fInvisibilitySkill));
                        
                    }
                    new Float:itemalpha=W3GetBuffMinFloat(client,fInvisibilityItem);
                    if(falpha!=1.0){
                        //PrintToChatAll("has skill invis");
                        //has skill, reduce stack
                        itemalpha=Pow(itemalpha,0.75);
                    }
                    falpha=FloatMul(falpha,itemalpha);
                    
                    if(falpha != 1.0  )
                    {
                        Format(HUD_Text, sizeof(HUD_Text), "%s\nInvis: %.2f",HUD_Text, falpha);
                    }
                    
                    if(W3GetBuffSumFloat(client, fDodgeChance) != 0.0)
                    {
                        Format(HUD_Text, sizeof(HUD_Text), "%s\nEvade: %.2f", HUD_Text,W3GetBuffSumFloat(client, fDodgeChance));
                    }       
                           
                    if(W3GetBuffStackedFloat(client,fAttackSpeed) != 1.0)
                    {
                        Format(HUD_Text, sizeof(HUD_Text), "%s\nAttk Spd: %.2f", HUD_Text,W3GetBuffStackedFloat(client,fAttackSpeed));
                    }  
                    
                    if(W3GetBuffSumFloat(client, fDamageModifier) != 0.0)
                    {
                        Format(HUD_Text, sizeof(HUD_Text), "%s\nBonus Damage: %.2f",HUD_Text, FloatMul(W3GetBuffSumFloat(client, fDamageModifier), 100.0));
                    }  
                    
                    if(W3GetBuffSumFloat(client, fHPRegen) != 0.0)
                    {
                        Format(HUD_Text, sizeof(HUD_Text), "%s\nRegen: %.2f",HUD_Text, W3GetBuffSumFloat(client, fHPRegen));
                    }    
                    
                    if(W3GetBuffSumFloat(client, fVampirePercent) != 0.0)
                    {
                        Format(HUD_Text, sizeof(HUD_Text), "%s\nVampire: %.2f",HUD_Text, W3GetBuffSumFloat(client, fVampirePercent));
                    }  
                    
                    
                    if(W3GetBuffHasTrue(client,bSlowImmunity) || W3GetBuffHasTrue(client,bImmunitySkills) || W3GetBuffHasTrue(client,bImmunityUltimates) || W3GetBuffHasTrue(client,bImmunityWards))
                    {
                        StrCat(HUD_Text, sizeof(HUD_Text), "\nImmune: ");
                        if(W3GetBuffHasTrue(client,bSlowImmunity))
                            StrCat(HUD_Text, sizeof(HUD_Text), "Sl|");
                        if(W3GetBuffHasTrue(client,bImmunitySkills))
                            StrCat(HUD_Text, sizeof(HUD_Text), "Sk|");
                        if(W3GetBuffHasTrue(client,bImmunityWards))
                            StrCat(HUD_Text, sizeof(HUD_Text), "W|");  
                        if(W3GetBuffHasTrue(client,bImmunityUltimates))
                            StrCat(HUD_Text, sizeof(HUD_Text), "U|");
    
                    }
                    
		    if(GetClientThrowingKnives(client) >= 1)
                    {
                        Format(HUD_Text, sizeof(HUD_Text), "%s\nKnives: %i", 
				HUD_Text, 
				GetClientThrowingKnives(client));

                    }
    
                    
                    if(GetConVarBool(ShowOtherPlayerItemsCvar)&&client!=display)
                    {
                        new bool:itemsonce = true;
                        new String:itemname[64];
                        new moleitemid=War3_GetItemIdByShortname("mole");
                        new ItemsLoaded = W3GetItemsLoaded();
                        for(new itemid=1;itemid<=ItemsLoaded;itemid++)
                        {
                            if(War3_GetOwnsItem(client,itemid)&&itemid!=moleitemid)
                            {
                                if(itemsonce)
                                {
                                    StrCat(HUD_Text, sizeof(HUD_Text), "\nItems: ");
                                    itemsonce = false;
                                }
                                W3GetItemShortname(itemid,itemname,sizeof(itemname));
                                Format(HUD_Text,sizeof(HUD_Text),"%s%s,",HUD_Text,itemname);
                            }
                        }
                    }
                    else if(client==display)
                    {
                        new bool:itemsonce = true;
                        
                        new String:itemname[64];
                        new ItemsLoaded = W3GetItemsLoaded();
                        for(new itemid=1;itemid<=ItemsLoaded;itemid++)
                        {
                            if(War3_GetOwnsItem(client,itemid))
                            {
                                if(itemsonce)
                                {
                                    StrCat(HUD_Text, sizeof(HUD_Text), "\nItems: ");
                                    itemsonce = false;
                                }
                                W3GetItemShortname(itemid,itemname,sizeof(itemname));
                                Format(HUD_Text,sizeof(HUD_Text),"%s%s,",HUD_Text,itemname);
                            }
                        }
                    }
    
                    if(!IsPlayerAlive(display) && observed == -1)
                    {
                        
                    }
                    else
                    {
                        if(g_bShowHUD[display] != 0 || (!IsPlayerAlive(display) && g_bTimedHUD[display] == 1))
                        {
                            StrCat(HUD_Text, sizeof(HUD_Text), HUD_Text_Add[display]);
                            //Client_PrintKeyHintText(display, "%s",HUD_Text);

                            
                            decl String:sCookieValue[11];
                            GetClientCookie(display, g_hMyCookie, sCookieValue, sizeof(sCookieValue));
                            new cookieValue = StringToInt(sCookieValue);
                            switch(cookieValue)
                            {
                                case 1:
                                {
                                    Client_PrintKeyHintText(display, "%s",HUD_Text);
                                }
                                case 2:
                                {
                                    new Handle:gH_HUD = INVALID_HANDLE;

                                    gH_HUD = CreateHudSynchronizer();                       
                                    SetHudTextParams(0.01, 0.25, g_fHUDDisplayTime, 255, 255, 255, 255, 0);
                                    ShowSyncHudText(display, gH_HUD, HUD_Text);
                                    CloseHandle(gH_HUD);
                                }
                                case 3:
                                {
                                    new Handle:gH_HUD = INVALID_HANDLE;

                                    gH_HUD = CreateHudSynchronizer();                       
                                    SetHudTextParams(0.7, 0.2, g_fHUDDisplayTime, 255, 255, 255, 255, 0);
                                    ShowSyncHudText(display, gH_HUD, HUD_Text);
                                    CloseHandle(gH_HUD);
                                }
                            
                            }
                        }   
                    }
                }
            }
            else
            {
                decl String:sCookieValue[11];
                GetClientCookie(client, g_hMyCookie, sCookieValue, sizeof(sCookieValue));
                new cookieValue = StringToInt(sCookieValue);
                switch(cookieValue)
                {
                
                    case 1:
                    {
                        Client_PrintKeyHintText(display, "%s",HUD_Text_Buffer[client]);
                    }
                    case 2:
                    {
                        new Handle:gH_HUD = INVALID_HANDLE;

                        gH_HUD = CreateHudSynchronizer();                       
                        SetHudTextParams(0.01, 0.25, g_fHUDDisplayTime, 255, 255, 255, 255, 0);
                        ShowSyncHudText(display, gH_HUD, HUD_Text_Buffer[client]);
                        CloseHandle(gH_HUD);
                    }
                    case 3:
                    {
                        new Handle:gH_HUD = INVALID_HANDLE;

                        gH_HUD = CreateHudSynchronizer();                       
                        SetHudTextParams(0.7, 0.2, g_fHUDDisplayTime, 255, 255, 255, 255, 0);
                        ShowSyncHudText(display, gH_HUD, HUD_Text_Buffer[client]);
                        CloseHandle(gH_HUD);
                    }
                
                }
            }
        }    
    }
    else
    {
        return Plugin_Stop;
    }
    return Plugin_Continue;
}


stock GetMoney(player)
{
    return GetEntData(player,MoneyOffsetCS);
}


GetRank(client)
{

    new Handle:hDB=W3GetVar(hDatabase);
    SQL_TQuery(hDB,T_RetrieveRankCache,"SELECT steamid FROM war3source ORDER BY total_level DESC,total_xp DESC",GetClientUserId(client));

}

public T_RetrieveRankCache(Handle:owner,Handle:query,const String:error[],any:userid)
{
    new client=GetClientOfUserId(userid);
    if(client<=0)
        return; 
    new String:client_steamid[64];
    if(!GetClientAuthId(client, AuthId_Steam2, client_steamid, sizeof(client_steamid)))
        return;
    if(IsFakeClient(client))
        return;
    if(query!=INVALID_HANDLE)
    {
        SQL_Rewind(query);
        new iCurRank=0;
        iTotalPlayersDB[client]=0;
        while(SQL_FetchRow(query))
        {
            ++iCurRank;
            new String:steamid[64];
            if(!W3SQLPlayerString(query,"steamid",steamid,sizeof(steamid)))
                continue;
            if(StrEqual(steamid,client_steamid,false))
            {
                iRank[client]=iCurRank;
            }
            ++iTotalPlayersDB[client];
        }
        CloseHandle(query);
        if(iRank[client]>0)
        {
            bRankCached[client]=true;
        }
    }
}



GetClientTotalLevels(client)
{
  new total_level=0;
  new RacesLoaded = War3_GetRacesLoaded();
  for(new r=1;r<=RacesLoaded;r++)
  {
    total_level+=War3_GetLevel(client,r);
  }
  return  total_level;
}



