#pragma semicolon 1

#include <sourcemod>
#include "W3SIncs/War3Source_Interface"
#include <sdkhooks>

new thisItem;

public Plugin:myinfo = 
{
    name = "War3Source Shopitem - Gum Boots",
    author = "SenatoR",
    description = "Adds the Gum Boots wich no fall damage you to the War3Source shopmenu",
    version = "1.0",
	url = "another-source.ru"
};

public OnPluginStart()
{
	LoadTranslations("w3s.item.gboots.phrases");
}

public OnWar3LoadRaceOrItemOrdered2(num)
{
	if(num==11)
	{
		thisItem = War3_CreateShopItemT("gboots",4,true);
	}
}

public OnClientPutInServer(client) 
{
    if(!client) 
        return; 
    SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage); 
} 

public Action:Hook_OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype) 
{
	if(War3_GetOwnsItem(victim,thisItem) &&damagetype & DMG_FALL)
    {
        damage = FloatDiv(damage, 5.0);
        return Plugin_Changed;
    }
	return Plugin_Continue; 
} 

public OnWar3EventDeath(victim)
{
	if(War3_GetOwnsItem(victim,thisItem))
	{
		War3_SetOwnsItem(victim,thisItem,false);
	}
}
