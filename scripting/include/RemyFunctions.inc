/** Double-include prevention */
#if defined _mynatives_included_
  #endinput
#endif
#define _mynatives_included_
 


/**
 *
 * @param userid  The user id that this particular HUD string is for
 * @param msg     A formatted string to display in the HUD
 * @return        Succesful Operation
 */
native HUD_Message(userid,String:msg[]);

/**
 * Returns the damage the player has dealt to rambo.
 *
 * @param override  Set to true to have the HUD display a custom message, use HUD_Message
 * @return        Succesful Operation
 */
native HUD_Override(bool:override=true);



/**
 *
 * @return        The bool value of the rambo toggle variable.
 */
native bool:My_CheckRamboToggle();


/**
 * Returns the damage the player has dealt to rambo.
 *
 * @param num1    An integer.
 * @return        The int value of damage dealt to rambo.
 */
native bool:My_RamboDamage(num1);


/**
 * Returns the client ID of the rambo player
 *
 * @return        The client ID of the rambo player.
 */
native int:My_GetRamboID();


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

