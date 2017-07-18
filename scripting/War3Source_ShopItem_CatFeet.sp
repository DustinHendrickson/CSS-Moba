/**
* File: War3Source_ShopItem_CatFeet.sp
* Description: Shopmenu Item for war3source - silence player's footsteps.
* Author(s): Remy Lebeau
*/

#pragma semicolon 1

#include <sourcemod>
#include "W3SIncs/War3Source_Interface"

new thisItem;

public Plugin:myinfo= {
	name="War3Source Shopitem - Cat's Feet",
	author="Remy Lebeau",
	description="War3Source",
	version="1.2.1",
	url="sevensinsgaming.com"
};


public OnWar3LoadRaceOrItemOrdered2(num)
{
	if(num==110)
	{
		thisItem=War3_CreateShopItem("Cat's Feet", "feet", "Walk on cat's feet (silent footsteps)",5,true);
	}	
}

public OnItemPurchase(client,item)
{
	if(item==thisItem&&ValidPlayer(client))
	{
		War3_SetOwnsItem(client,item,true);
	}
}


public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
    if(ValidPlayer (client, true))
    {
        if(buttons & (IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT | IN_JUMP) && War3_GetOwnsItem(client, thisItem))
        {
            SetEntProp(client, Prop_Send, "m_fFlags", 4);
        }
    }
    return Plugin_Continue;
}  


public OnWar3EventDeath(victim){
	if(War3_GetOwnsItem(victim,thisItem)){
		War3_SetOwnsItem(victim,thisItem,false);
	}
}