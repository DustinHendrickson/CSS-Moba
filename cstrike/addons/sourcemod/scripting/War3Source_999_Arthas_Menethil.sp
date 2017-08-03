/**
* File: War3Source_Arthas_Menethil.sp
* Description: The Arthas Menethil race for SourceCraft. Race from Warcraft III Collection(http://www.fpsbanana.com/scripts/5804)
* Author(s): xDr.HaaaaaaaXx 
*/

#pragma semicolon 1
#include <sourcemod>
#include <sdktools_tempents>
#include <sdktools_functions>
#include <sdktools_tempents_stocks>
#include <sdktools_entinput>
#include <sdktools_sound>

#include "W3SIncs/War3Source_Interface"

// War3Source stuff
new thisRaceID, SKILL_IMMUNE, SKILL_DMG, SKILL_SPEED, ULT_ZOOM;

// Chance/Data Arrays
// skill 1
new Float:ImmuneChace[5] = { 0.0, 0.5, 0.55, 0.6, 0.99 };

// skill 2
new String:attack[] = "npc/barnacle/barnacle_bark1.wav";
new MinDmg[5] = { 0, 1, 3, 5, 9 };
new MaxDmg[5] = { 0, 3, 5, 9, 15 };

// skill 3
new Float:ArthasSpeed[5] = { 1.0, 1.075, 1.15, 1.225, 1.3 };

// skill 4
new String:zoom[] = "weapons/zoom.wav";
new String:on[] = "items/nvg_on.wav";
new String:off[] = "items/nvg_off.wav";
new Zoom[5] = { 0, 44, 33, 22, 11 };
new bool:Zoomed[64];

// Other
new AttackSprite1, AttackSprite2, SpawnSprite;
new FOV;

public Plugin:myinfo = 
{
	name = "War3Source Race - Arthas Menethil",
	author = "xDr.HaaaaaaaXx",
	description = "The Arthas Menethil race for War3Source. Race from Warcraft III Collection(http://www.fpsbanana.com/scripts/5804)",
	version = "1.0.0.2",
	url = ""
};

public OnPluginStart()
{
	FOV = FindSendPropInfo( "CBasePlayer", "m_iFOV" );
}

public OnMapStart()
{
	War3_PrecacheSound( zoom );
	War3_PrecacheSound( on );
	War3_PrecacheSound( off );
	War3_PrecacheSound( attack );
	SpawnSprite = PrecacheModel( "sprites/physring1.vmt" );
	AttackSprite1 = PrecacheModel( "sprites/scanner.vmt" );
	AttackSprite2 = PrecacheModel( "sprites/lgtning.vmt" );
}

public OnWar3PluginReady()
{
	thisRaceID = War3_CreateNewRace( "Arthas Menethil", "arthas" );
	
	SKILL_IMMUNE = War3_AddRaceSkill( thisRaceID, "Knowledge of Uther Lightbringer", "50/55/60/99 percent chance of resisting ultimates.", false, 4 );
	SKILL_DMG = War3_AddRaceSkill( thisRaceID, "Cult of the Damned", "Gives Arthas 25 percent chance to do extra damage per hit. 1-3/3-5/5-9/9-15", false, 4 );
	SKILL_SPEED = War3_AddRaceSkill( thisRaceID, "Travel to Northrend", "Arthas mounts up, increasing move speed base to 1.075/1.15/1.225/1.3", false, 4 );
	ULT_ZOOM = War3_AddRaceSkill( thisRaceID, "Under Lich King Command", "Zoom with any weapon.", true, 4 );
	
	War3_CreateRaceEnd( thisRaceID );
}

public InitPassiveSkills( client )
{
	if( War3_GetRace( client ) == thisRaceID )
	{
		if( GetRandomFloat( 0.0, 1.0 ) < ImmuneChace[War3_GetSkillLevel( client, thisRaceID, SKILL_IMMUNE )] )
		{
			War3_SetBuff( client, bImmunityUltimates, thisRaceID, true );
			PrintToChat( client, "Ultimate immunity activated!" );
		}
		if( War3_GetSkillLevel( client, thisRaceID, SKILL_SPEED ) > 0 )
		{
			War3_SetBuff( client, fMaxSpeed, thisRaceID, ArthasSpeed[War3_GetSkillLevel( client, thisRaceID, SKILL_SPEED )] );
			
			new Float:pos[3];
			
			GetClientAbsOrigin( client, pos );
			
			pos[2] += 15;
			
			TE_SetupGlowSprite( pos, SpawnSprite, 3.0, 5.0, 255 );
			TE_SendToAll();
		}
	}
}

public OnRaceChanged ( client,oldrace,newrace )
{
	if( newrace != thisRaceID )
	{
		War3_SetBuff( client, fMaxSpeed, thisRaceID, 1.0 );
		War3_SetBuff( client, bImmunityUltimates, thisRaceID, false );
		W3ResetAllBuffRace( client, thisRaceID );
	}
	else
	{	
		if( IsPlayerAlive( client ) )
		{
			InitPassiveSkills( client );
		}
	}
}

public OnSkillLevelChanged( client, race, skill, newskilllevel )
{
	InitPassiveSkills( client );
}

public OnWar3EventSpawn( client )
{
	new race = War3_GetRace( client );
	if( race == thisRaceID )
	{
		InitPassiveSkills( client );
	}
}

public OnWar3EventDeath( client )
{
	new race = War3_GetRace( client );
	if( race == thisRaceID )
	{
		War3_SetBuff( client, bImmunityUltimates, thisRaceID, false );
		W3ResetAllBuffRace( client, thisRaceID );
	}
}

public OnWar3EventPostHurt(victim, attacker, Float:damage, const String:weapon[32], bool:isWarcraft)
{
	if( W3GetDamageIsBullet() && ValidPlayer( victim, true ) && ValidPlayer( attacker, true ) && GetClientTeam( victim ) != GetClientTeam( attacker ) )
	{
		if( War3_GetRace( attacker ) == thisRaceID )
		{
			new skill_level = War3_GetSkillLevel( attacker, thisRaceID, SKILL_DMG );
			if( !Hexed( attacker, false ) && GetRandomFloat( 0.0, 1.0 ) <= 0.2 )
			{
				new Float:pos[3];
				
				GetClientAbsOrigin( victim, pos );
				
				TE_SetupBeamRingPoint( pos, 50.0, 350.0, AttackSprite1, AttackSprite1, 0, 0, 1.0, 90.0, 0.0, { 155, 155, 155, 155 }, 20, FBEAM_ISACTIVE );
				TE_SendToAll();
				
				TE_SetupExplosion( pos, AttackSprite2, 990.0, 10, TE_EXPLFLAG_DRAWALPHA, 50, 100 );
				TE_SendToAll();
				
				EmitSoundToAll( attack, attacker );
				EmitSoundToAll( attack, victim );
				
				War3_DealDamage( victim, GetRandomInt( MinDmg[skill_level], MaxDmg[skill_level] ), attacker, DMG_BULLET, "arthas_crit" );
				W3PrintSkillDmgHintConsole( victim, attacker, War3_GetWar3DamageDealt(), SKILL_DMG );
			}
		}
	}
}

public OnUltimateCommand( client, race, bool:pressed )
{
	if( ValidPlayer( client, true ) )
	{
		if( race == thisRaceID && pressed && IsPlayerAlive( client ) && !Silenced( client ) )
		{
			new ult_level = War3_GetSkillLevel( client, race, ULT_ZOOM );
			if( ult_level > 0 )
			{
				if( War3_SkillNotInCooldown( client, thisRaceID, ULT_ZOOM, true ) )
				{
					ToggleZoom( client );
				}
			}
			else
			{
				W3MsgUltNotLeveled( client );
			}
		}
	}
}

stock ToggleZoom( client )
{
	if( Zoomed[client] )
	{
		StopZoom( client );
	}
	else
	{
		StartZoom( client );
	}
	EmitSoundToAll( zoom, client );
}

stock StopZoom( client )
{
	if( Zoomed[client] )
	{
		SetEntData( client, FOV, 0 );
		EmitSoundToAll( off, client );
		Zoomed[client] = false;
	}
}

stock StartZoom( client )
{
	if ( !Zoomed[client] )
	{
		new zoom_level = War3_GetSkillLevel( client, thisRaceID, ULT_ZOOM );
		SetEntData( client, FOV, Zoom[zoom_level] );
		EmitSoundToAll( on, client );
		Zoomed[client] = true;
	}
}