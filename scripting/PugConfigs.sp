#include <sourcemod>

#include <PugConst>
#include <PugForwards>
#include <PugNatives>

#pragma semicolon 1

public Plugin:myinfo = 
{
	name 			= "Pug Mod (Configs)",
	author 			= PUG_MOD_AUTHOR,
	description 	= PUG_MOD_DESC,
	version 		= PUG_MOD_VERSION,
	url 			= PUG_MOD_WEBURL
};

new Handle:g_hPugMod;
new Handle:g_hWarmup;
new Handle:g_hStart;
new Handle:g_hMatch;

new Handle:g_hMpRestartGame = INVALID_HANDLE;
new Handle:g_hMpWarmupPause = INVALID_HANDLE;

public OnPluginStart()
{
	HookEvent("server_cvar",PugServerCvarCallBack,EventHookMode_Pre);
	
	g_hPugMod 	= CreateConVar("pug_config_pugmod","pugmod.cfg","PugMod Main Configuration file");
	g_hWarmup 	= CreateConVar("pug_config_warmup","warmup.cfg","PugMod Warmup Configuration file");
	g_hStart 	= CreateConVar("pug_config_start","start.cfg","PugMod Vote Configuration file");
	g_hMatch 	= CreateConVar("pug_config_match","match.cfg","PugMod Live Configuration file");
	
	g_hMpRestartGame = FindConVar("mp_restartgame");
	g_hMpWarmupPause = FindConVar("mp_warmup_pausetimer");
}

public Action:PugServerCvarCallBack(Handle:hEvent,const String:sConVar[],bool:bDontBroadCast)
{
	if(GetPugStage() != PUG_STAGE_DEAD)
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public OnConfigsExecuted()
{
	PugExecConfig(g_hPugMod);
}

public OnPugWarmup()
{
	PugExecConfig(g_hWarmup);
	
	ServerCommand("mp_warmup_start");
	SetConVarInt(g_hMpWarmupPause,1);
}

public OnPugStart()
{
	PugExecConfig(g_hStart);
}

public OnPugMatch()
{
	PugExecConfig(g_hMatch,5);
	
	SetConVarInt(g_hMpWarmupPause,0);
	ServerCommand("mp_warmup_end");
}

PugExecConfig(Handle:hConvar,iRestart = 0)
{
	new String:sFile[64];
	GetConVarString(hConvar,sFile,sizeof(sFile));
	
	if(sFile[0])
	{
		ServerCommand("exec \"sourcemod/pug/%s\"\n",sFile);
	}
	
	if(iRestart > 0)
	{
		SetConVarInt(g_hMpRestartGame,iRestart);
	}
}