#include <sourcemod>

#include <PugConst>
#include <PugForwards>
#include <PugStocks>

#pragma semicolon 1

public Plugin:myinfo = 
{
	name 			= "Pug Mod (Core)",
	author 			= PUG_MOD_AUTHOR,
	description 	= PUG_MOD_DESC,
	version 		= PUG_MOD_VERSION,
	url 			= PUG_MOD_WEBURL
};

new PugStage:g_iStage;

new Handle:g_hCoreWarmup;
new Handle:g_hCoreStart;
new Handle:g_hCoreMatch;

/*
* Creating natives :D
*/
new Handle:g_hPlayersMin = INVALID_HANDLE;
new Handle:g_hPlayersMax = INVALID_HANDLE;

new Handle:g_hPlayersMinDefault = INVALID_HANDLE;
new Handle:g_hPlayersMaxDefault = INVALID_HANDLE;

public OnPluginStart()
{
	g_hPlayersMin = CreateConVar("pug_players_min","10","Mininum of players to start the match.");
	g_hPlayersMax = CreateConVar("pug_players_max","10","Maximum of players in server.");.
	
	g_hPlayersMinDefault = CreateConVar("pug_players_min_default","10","Default maximum of players in server.");
	g_hPlayersMaxDefault = CreateConVar("pug_players_max_default","10","Default maximum of players in server.");
	
	g_hCoreWarmup 	= CreateGlobalForward("OnPugWarmup",ET_Event);
	g_hCoreStart 	= CreateGlobalForward("OnPugStart",ET_Event);
	g_hCoreMatch 	= CreateGlobalForward("OnPugMatch",ET_Event);
}

public OnConfigsExecuted()
{
	if(g_iStage == PUG_STAGE_DEAD)
	{
		// Auto Start for Pug, after this we can add a .setup command
		CreateTimer(8.0,CoreWarmup);
	}
}

public OnMapEnd()
{
	if(g_iStage != PUG_STAGE_DEAD)
	{
		g_iStage = PUG_STAGE_DEAD;
	}
}

public Action:CoreWarmup(Handle:hTimer)
{
	if(g_iStage == PUG_STAGE_DEAD)
	{
		g_iStage = PUG_STAGE_WARMUP;
		
		decl Action:hResult;
		
		Call_StartForward(g_hCoreWarmup);
		Call_Finish(hResult);
		
		return hResult;
	}
	
	return Plugin_Continue;
}

public OnPugWarmup()
{
	PrintToChatAll("%s %T",g_sHead,LANG_SERVER,"Starting Pug Mod.");
}

public Action:CoreStart()
{
	if(g_iStage == PUG_STAGE_WARMUP)
	{
		g_iStage = PUG_STAGE_START;
		
		decl Action:hResult;
		
		Call_StartForward(g_hCoreStart);
		Call_Finish(hResult);
		
		return hResult;
	}
	
	return Plugin_Continue;
}

public Action:CoreMatch()
{
	if(g_iStage == PUG_STAGE_WARMUP)
	{
		g_iStage = PUG_STAGE_START;
		
		decl Action:hResult;
		
		Call_StartForward(g_hCoreMatch);
		Call_Finish(hResult);
		
		return hResult;
	}
	
	return Plugin_Continue;
}

public OnPugMatch()
{
	PrintToChatAll("%s %T",g_sHead,LANG_SERVER,"Starting Match.",g_sStage[g_iStage]);
}