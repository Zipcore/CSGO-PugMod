#include <sourcemod>
#include <cstrike>
#include <sdktools>

#include <PugConst>
#include <PugForwards>
#include <PugNatives>
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

public PugStage:g_iStage;

new Handle:g_hCoreWarmup;
new Handle:g_hCoreStart;
new Handle:g_hCoreMatch;

new Handle:g_hPlayersMin = INVALID_HANDLE;
new Handle:g_hPlayersMax = INVALID_HANDLE;

//new Handle:g_hPlayersMinDefault = INVALID_HANDLE;
//new Handle:g_hPlayersMaxDefault = INVALID_HANDLE;

new String:g_sTeams[4][MAX_NAME_LENGTH];

new Handle:g_hMpTeam1Name = INVALID_HANDLE;
new Handle:g_hMpTeam2Name = INVALID_HANDLE;

#define isTeam(%0) (CS_TEAM_T <= GetClientTeam(%0) <= CS_TEAM_CT)

public OnPluginStart()
{
	LoadTranslations("PugCore.phrases");
	LoadTranslations("common.phrases");
	
	g_hPlayersMin = CreateConVar("pug_players_min","10","Mininum of players to start the match.");
	g_hPlayersMax = CreateConVar("pug_players_max","10","Maximum of players in server.");
	
	//g_hPlayersMinDefault = CreateConVar("pug_players_min_default","10","Default maximum of players in server.");
	//g_hPlayersMaxDefault = CreateConVar("pug_players_max_default","10","Default maximum of players in server.");
	
	g_hMpTeam1Name = FindConVar("mp_teamname_1");
	g_hMpTeam2Name = FindConVar("mp_teamname_2");
	
	RegConsoleCmd(".status",CoreCommandStatus,"Show the PUG Status");
}

public APLRes:AskPluginLoad2(Handle:MySelf, bool:bLate, String:sError[], iErrorMax)
{
	CreateNative("PugWarmup",CoreNativeWarmup);
	CreateNative("PugStart",CoreNativeStart);
	CreateNative("PugMatch",CoreNativeMatch);
	
	CreateNative("GetPugStage",CoreGetPugStage);
	CreateNative("GetPugPlayers",CoreGetPlayersNum);
	CreateNative("GetPugRound",CoreGetRound);
	CreateNative("PugIsTeam",CoreIsTeam);
	
	return APLRes_Success;
}

public OnConfigsExecuted()
{
	g_iStage = PUG_STAGE_DEAD;
	
	g_hCoreWarmup 	= CreateGlobalForward("OnPugWarmup",ET_Event);
	g_hCoreStart 	= CreateGlobalForward("OnPugStart",ET_Event);
	g_hCoreMatch 	= CreateGlobalForward("OnPugMatch",ET_Event);
	
	CreateTimer(8.0,CoreMain);
}

public Action:CoreMain(Handle:hTimer)
{
	CoreWarmup();
}

public CoreNativeWarmup(Handle:hPlugin,iParams)
{
	if(g_iStage == PUG_STAGE_DEAD)
	{
		CoreWarmup();
		
		return true;
	}
	
	return false;
}

public Action:CoreWarmup()
{
	if(g_iStage == PUG_STAGE_DEAD)
	{
		g_iStage = PUG_STAGE_WARMUP;
		
		decl Action:hResult;
		
		Call_StartForward(g_hCoreWarmup);
		Call_Finish(_:hResult);
		
		return hResult;
	}
	
	return Plugin_Continue;
}

public OnPugWarmup()
{
	PrintToChatAll(PUG_MOD_PREFIX,"Starting Pug Mod.");
}

public CoreNativeStart(Handle:hPlugin,iParams)
{
	if(g_iStage == PUG_STAGE_WARMUP)
	{
		CoreStart();
		
		return true;
	}
	
	return false;
}

public Action:CoreStart()
{
	if(g_iStage == PUG_STAGE_WARMUP)
	{
		g_iStage = PUG_STAGE_START;
		
		decl Action:hResult;
		
		Call_StartForward(g_hCoreStart);
		Call_Finish(_:hResult);
		
		return hResult;
	}
	
	return Plugin_Continue;
}

public OnPugStart()
{
	GetConVarString(g_hMpTeam1Name,g_sTeams[CS_TEAM_T],sizeof(g_sTeams[]));
	GetConVarString(g_hMpTeam2Name,g_sTeams[CS_TEAM_CT],sizeof(g_sTeams[]));
	
	if(!g_sTeams[CS_TEAM_T][0] || !g_sTeams[CS_TEAM_CT][0])
	{
		strcopy(g_sTeams[CS_TEAM_T],sizeof(g_sTeams[]),"Terrorists");
		strcopy(g_sTeams[CS_TEAM_CT],sizeof(g_sTeams[]),"Counter-Terrorists");
		
		SetConVarString(g_hMpTeam1Name,g_sTeams[CS_TEAM_T]);
		SetConVarString(g_hMpTeam2Name,g_sTeams[CS_TEAM_CT]);
	}
}

public CoreNativeMatch(Handle:hPlugin,iParams)
{
	if(g_iStage == PUG_STAGE_WARMUP)
	{
		CoreMatch();
		
		return true;
	}
	
	return false;
}

public Action:CoreMatch()
{
	if(g_iStage == PUG_STAGE_WARMUP)
	{
		g_iStage = PUG_STAGE_START;
		
		decl Action:hResult;
		
		Call_StartForward(g_hCoreMatch);
		Call_Finish(_:hResult);
		
		return hResult;
	}
	
	return Plugin_Continue;
}

public OnPugMatch()
{
	PrintToChatAll(PUG_MOD_PREFIX,"Starting Match.",g_sStage[g_iStage]);
}

public Action:OnClientSayCommand(iClient,const String:sCommand[],const String:sArgs[])
{
	if(iClient)
	{
		if(sArgs[0] == '.')
		{
			FakeClientCommandEx(iClient,sArgs);
			
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

public Action:CoreCommandStatus(iClient,iArgs)
{
	if(iClient)
	{
		PrintToChat
		(
			iClient,
			PUG_MOD_PREFIX,
			"Pug Status Information.",
			GetPugPlayers(),
			GetConVarInt(g_hPlayersMin),
			GetConVarInt(g_hPlayersMax),
			g_sStage[g_iStage]
		);
		
		if(g_iStage == PUG_STAGE_MATCH)
		{
			PrintToChat
			(
				iClient,
				PUG_MOD_PREFIX,
				"Pug Scores Information.",
				GetPugRound(),
				g_sTeams[CS_TEAM_T],
				CS_GetTeamScore(CS_TEAM_T),
				g_sTeams[CS_TEAM_CT],
				CS_GetTeamScore(CS_TEAM_CT)
			);
		}
	}
	
	return Plugin_Handled;
}

public CoreGetPugStage(Handle:hPlugin,iParams)
{
   return _:g_iStage;
}

public CoreGetPlayersNum(Handle:hPlugin, iParams)
{
	new iPlayers;
	
	for(new i = 1;i <= MaxClients;i++)
	{
		if(IsClientInGame(i))
		{
			switch(GetClientTeam(i))
			{
				case CS_TEAM_T:
				{
					iPlayers++;
				}
				case CS_TEAM_CT:
				{
					iPlayers++;
				}
			}
		}
	}
	
	return iPlayers;
}

public CoreGetRound(Handle:hPlugin, iParams)
{
	return (CS_GetTeamScore(CS_TEAM_T) + CS_GetTeamScore(CS_TEAM_CT));
}

public CoreIsTeam(Handle:hPlugin, iParams)
{
	return isTeam(GetNativeCell(1));
}