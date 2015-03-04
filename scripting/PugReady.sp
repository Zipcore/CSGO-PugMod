#include <sourcemod>
#include <cstrike>

#include <PugConst>
#include <PugForwards>
#include <PugNatives>

#pragma semicolon 1

public Plugin:myinfo = 
{
	name 			= "Pug Mod (Ready System)",
	author 			= PUG_MOD_AUTHOR,
	description 	= PUG_MOD_DESC,
	version 		= PUG_MOD_VERSION,
	url 			= PUG_MOD_WEBURL
};

new bool:g_bReady[MAXPLAYERS] = false;

#define PUG_KEYS_GENERIC (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)

new Handle:g_hPlayersMin;

new String:g_sTags[33][32];

public OnPluginStart()
{
	LoadTranslations("PugReady.phrases");
	
	RegConsoleCmd(".ready",PugOnReadyUp,"Tells the server the player is ready.");
	RegConsoleCmd(".notready",PugOnReadyDown,"Tells the server the player is not ready");
}

public OnConfigsExecuted()
{
	g_hPlayersMin = FindConVar("pug_players_min");
}

public OnClientPutInServer(iClient)
{
	CreateTimer(5.0,PugWelcomeMessage,iClient);
}

public Action:PugWelcomeMessage(Handle:hTimer,any:iClient)
{
	if(GetPugStage() == PUG_STAGE_WARMUP)
	{
		g_bReady[iClient] = false;
		
		if(IsClientInGame(iClient) && PugIsTeam(iClient))
		{
			PugPanelReadyList(iClient);
			
			CS_GetClientClanTag(iClient,g_sTags[iClient],sizeof(g_sTags[]));
			CS_SetClientClanTag(iClient,"Not Ready");
			
			PrintToChatAll(PUG_MOD_PREFIX,"Say .ready to continue.");
		}
		else
		{
			CreateTimer(5.0,PugWelcomeMessage,iClient);
		}
	}
}

public Action:PugOnReadyUp(iClient,iArgs)
{
	if(iClient && PugIsTeam(iClient))
	{
		if(GetPugStage() == PUG_STAGE_WARMUP)
		{
			if(g_bReady[iClient])
			{
				PrintCenterText(iClient,"%t","You are already ready!");
			}
			else
			{
				g_bReady[iClient] = true;
				
				new String:sName[MAX_NAME_LENGTH];
				GetClientName(iClient,sName,sizeof(sName));
				
				PrintToChatAll
				(
					PUG_MOD_PREFIX,
					"is now ready!",
					sName
				);
				
				CS_SetClientClanTag(iClient,"Ready");
				
				PugPanelReadyList(iClient);
				PugCheckPlayers();
			}
		}
		else
		{
			PrintCenterText(iClient,"%t","You can't do that right now.");
		}
	}
	
	return Plugin_Handled;
}

public Action:PugOnReadyDown(iClient,iArgs)
{
	if(iClient && PugIsTeam(iClient))
	{
		if(GetPugStage() == PUG_STAGE_WARMUP)
		{
			if(!g_bReady[iClient])
			{
				PrintCenterText(iClient,"%t","You were never ready!");
			}
			else
			{
				g_bReady[iClient] = false;
				
				new String:sName[MAX_NAME_LENGTH];
				GetClientName(iClient,sName,sizeof(sName));
				
				PrintToChatAll
				(
					PUG_MOD_PREFIX,
					"is no longer ready!",
					sName
				);
				
				CS_SetClientClanTag(iClient,"Not Ready");
				
				PugPanelReadyList(iClient);
				PugCheckPlayers();
			}
		}
		else
		{
			PrintCenterText(iClient,"%t","You can't do that right now.");
		}
	}
	
	return Plugin_Handled;
}

public PugPanelReadyList(iClient)
{
		new Handle:hReadyPanel = CreatePanel();
		
		new String:sName[MAX_NAME_LENGTH];
		new String:sReady[258],String:sUnReady[258];
		
		for(new i = 1;i <= MaxClients;i++)
		{
			if(IsClientInGame(i) && PugIsTeam(i))
			{
				GetClientName(i,sName,sizeof(sName));
				
				if(g_bReady[i])
				{
					Format(sReady,sizeof(sReady),"%s%s\n",sReady,sName);
				}
				else
				{
					Format(sUnReady,sizeof(sUnReady),"%s%s\n",sUnReady,sName);
				}
			}
		}
		
		new String:sList[1536];
		
		new iPlayersMin = GetConVarInt(g_hPlayersMin);

		Format
		(
			sList,
			sizeof(sList),
			"%t",
			"Ready List Panel",
			GetPugPlayers() - PugGetReadyNum(),
			iPlayersMin,
			sUnReady,
			PugGetReadyNum(),
			iPlayersMin,
			sReady
		);

		SetPanelTitle(hReadyPanel,sList);
		SetPanelKeys(hReadyPanel,PUG_KEYS_GENERIC);

		if(IsClientInGame(iClient) && !IsFakeClient(iClient))
		{
			SendPanelToClient(hReadyPanel,iClient,PugHandlerNothing,0);
		}

		CloseHandle(hReadyPanel);
}

public PugHandlerNothing(Handle:hMenu,MenuAction:iAction,iClient,iKey) { /* DO NOTHING  :| */}

public PugCheckPlayers()
{
	new iReady = PugGetReadyNum();

	if(iReady >= GetConVarInt(g_hPlayersMin))
	{
		switch(GetPugStage())
		{
			case PUG_STAGE_WARMUP:
			{
				for(new i = 1;i <= MaxClients;i++)
				{
					if(IsClientInGame(i) && PugIsTeam(i))
					{
						CS_SetClientClanTag(i,g_sTags[i]);
					}
				}
				
				CreateTimer(2.0,PugContinue);
				PrintToChatAll(PUG_MOD_PREFIX,"All Players are ready! Starting Pug Mod.");
			}
		}
	}
}

public Action:PugContinue(Handle:hTimer)
{
	/*
	* Continue the Pug Mod
	*/
	PugStart();
}

PugGetReadyNum()
{
	new iNum;
	
	for(new i;i < sizeof(g_bReady);i++)
	{
		if(g_bReady[i])
		{
			iNum++;
		}
	}
	
	return iNum;
}