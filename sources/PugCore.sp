#include <sourcemod>

#include <PugConst>
#include <PugForwards>
#include <PugStocks>

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

public OnPluginStart()
{
	g_hCoreWarmup 		= CreateGlobalForward("OnPugWarmup",ET_Event);
	g_hCoreStart 		= CreateGlobalForward("OnPugStart",ET_Event);
	g_hCoreMatch 		= CreateGlobalForward("OnPugMatch",ET_Event);
}

public OnConfigsExecuted()
{
	if(g_iStage == PUG_STAGE_DEAD)
	{
		// Auto Start for Pug, after this we can add a .set command
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