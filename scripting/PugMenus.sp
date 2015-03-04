#include <sourcemod>

#include <PugConst>
#include <PugForwards>
#include <PugNatives>

#pragma semicolon 1

public Plugin:myinfo = 
{
	name 			= "Pug Mod (Menus System)",
	author 			= PUG_MOD_AUTHOR,
	description 	= PUG_MOD_DESC,
	version 		= PUG_MOD_VERSION,
	url 			= PUG_MOD_WEBURL
};

new Handle:g_hVoteDelay = INVALID_HANDLE;
new Handle:g_hTeamsType = INVALID_HANDLE;

enum TeamsMethod
{
	PUG_TEAMS_RANDOM = 0,
	PUG_TEAMS_CAPTAINS,
	PUG_TEAMS_UNSORTED
};

public OnPluginStart()
{
	LoadTranslations("PugMenus.phrases");
	
	g_hVoteDelay = CreateConVar("pug_vote_delay","15.0","Delay in the vote session");
	g_hTeamsType = CreateConVar("pug_teams_type","0","Team Enforcement method",0,true,-1.0,true,2.0); // 0 = Vote Teams, 1 = Captains, 2 = Automatic, 3 = Not Sorted
}

public OnPugStart()
{
	switch(GetConVarInt(g_hTeamsType))
	{
		case 1: 
		{
			PugChangeTeams(PUG_TEAMS_CAPTAINS);
		}
		case 2:
		{
			PugChangeTeams(PUG_TEAMS_RANDOM);
		}
		case 3:
		{
			PugChangeTeams(PUG_TEAMS_UNSORTED);
		}
		default:
		{
			new Handle:hMenuTeams = CreateMenu(PugMenuHandleTeams);
			
			SetMenuTitle(hMenuTeams,"Teams Enforcement \n ");
			AddMenuItem(hMenuTeams,"0","Random");
			AddMenuItem(hMenuTeams,"1","Captains");
			AddMenuItem(hMenuTeams,"2","Not Sorted");

			SetMenuExitButton(hMenuTeams,false);
			VoteMenuToAll(hMenuTeams,GetConVarInt(g_hVoteDelay),VOTEFLAG_NO_REVOTES);
			
			PrintToChatAll(PUG_MOD_PREFIX,"Starting team vote.");
		}
	}
}

public PugMenuHandleTeams(Handle:hMenu,MenuAction:iAction,iClient,iKey)
{	
	switch(iAction)
	{
		case MenuAction_Select:
		{
			new String:sName[32];
			GetClientName(iClient,sName,sizeof(sName));
			
			new String:sInfo[2],iStyle,String:sText[16];
			GetMenuItem(hMenu,iKey,sInfo,sizeof(sInfo),iStyle,sText,sizeof(sText));
			
			PrintToChatAll(PUG_MOD_PREFIX,"choosed",sName,sText);
		}
		case MenuAction_VoteEnd,MenuAction_VoteCancel:
		{
			SetConVarInt(g_hTeamsType,0);
			
			new String:sInfo[2],iStyle,String:sText[16];
			GetMenuItem(hMenu,iClient,sInfo,sizeof(sInfo),iStyle,sText,sizeof(sText));
			
			if((iClient == VoteCancel_NoVotes) || (iClient == VoteCancel_Generic))
			{
				PugChangeTeams(PUG_TEAMS_UNSORTED);
			}
			else
			{
				PugChangeTeams(TeamsMethod:StringToInt(sInfo));
			}
		}
		case MenuAction_End:
		{
			CloseHandle(hMenu);
		}
	}
}

public PugChangeTeams(TeamsMethod:iMethod)
{
	switch(iMethod)
	{
		case PUG_TEAMS_RANDOM:
		{
			ServerCommand("mp_scrambleteams");
			PrintToChatAll(PUG_MOD_PREFIX,"Teams will be randomly sorted.");
			CreateTimer(2.0,PugContinue);
		}
		case PUG_TEAMS_CAPTAINS:
		{
			PugChangeTeams(PUG_TEAMS_UNSORTED);
		}
		case PUG_TEAMS_UNSORTED:
		{
			PrintToChatAll(PUG_MOD_PREFIX,"Teams will not be changed.");
			CreateTimer(2.0,PugContinue);
		}
	}
}

public Action:PugContinue(Handle:hTimer)
{
	PugMatch();
}