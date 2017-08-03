/**
* File: War3Source_ShopItem_CoatofDeception.sp
* Description: Shopmenu Item for war3source - change the player's appearance to the opposite team.
* Author(s): Remy Lebeau
*/

#pragma semicolon 1

#include <sourcemod>
#include "W3SIncs/War3Source_Interface"

new thisItem;

public Plugin:myinfo= {
	name="War3Source Shopitem - Coat of Deception",
	author="Remy Lebeau",
	description="War3Source",
	version="1.0.1",
	url="sevensinsgaming.com"
};

public OnWar3LoadRaceOrItemOrdered2(num)
{
	if(num==111)
	{
		thisItem=War3_CreateShopItem("Coat of Deception", "coat", "Deceive your enemies - appear like one of them",5,5000);
	}	
}

public OnItemPurchase(client,item)
{
	if(item==thisItem&&ValidPlayer(client))
	{
		War3_SetOwnsItem(client,item,true);
	
		if (ValidPlayer(client, true))
		{
			War3_ChangeModel(client, true);
			PrintHintText( client, "You have transformed in to the enemy." );
		}
	}
}

public OnWar3EventSpawn(client)
{
	if(War3_GetOwnsItem(client,thisItem))
	{
		if (ValidPlayer(client, true))
		{
			War3_ChangeModel(client, true);
			PrintHintText( client, "You have transformed in to the enemy." );
		}
	}
}




public OnWar3EventDeath(victim){
	if(War3_GetOwnsItem(victim,thisItem))
	{
		War3_SetOwnsItem(victim,thisItem,false);
		War3_ChangeModel(victim);
	}
}

/**
 * Swaps the player to a random model
 *
 * @param type	      		client ID
 * @param swap_team 		Change to a model of the opposite team? Default = change to a model from player's team
 * @return			  		no return
 */

stock War3_ChangeModel( client, bool:swap_team=false)
{
	new tempint = GetRandomInt(1,4);
	new client_team = GetClientTeam( client );
	if (swap_team && client_team == TEAM_T)
	{
		client_team = TEAM_CT;
	}
	else if (swap_team && client_team == TEAM_CT)
	{	
		client_team = TEAM_T;
	}
	
	
	if(client_team == TEAM_T)
	{
		switch(tempint)
		{
			case 1:
			{
				SetEntityModel( client, "models/player/t_arctic.mdl" );
			}
			case 2:
			{
				SetEntityModel( client, "models/player/t_guerilla.mdl" );
			}
			case 3:
			{
				SetEntityModel( client, "models/player/t_leet.mdl" );
			}
			case 4:
			{
				SetEntityModel( client, "models/player/t_phoenix.mdl" );
				
			}
		}
	}
	else if( client_team == TEAM_CT )
	{
		switch(tempint)
		{
			case 1:
			{
				SetEntityModel( client, "models/player/ct_gign.mdl" );
			}
			case 2:
			{
				SetEntityModel( client, "models/player/ct_gsg9.mdl" );
			}
			case 3:
			{
				SetEntityModel( client, "models/player/ct_sas.mdl" );
			}
			case 4:
			{
				SetEntityModel( client, "models/player/ct_urban.mdl" );
				
			}
		}
	}
}