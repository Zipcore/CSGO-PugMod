#if defined _PugStocks_included
	#endinput
#endif
#define _PugStocks_included

#include <sourcemod>
#include <PugConst>

/**
 * @brief Called when a clients movement buttons are being processed
 * 
 * @param iClient Index of the client.
 * @param sLang Lang phrase to translation.
 * 
 * @note If the param iClient is 0, the message will be sent to server console.
 */
stock PugMessage(iClient,String:sLang[])
{
	if(!iClient)
	{
		PrintToServer(PUG_MOD_PREFIX,sLang);
	}
	
	PrintToChat(iClient,PUG_MOD_PREFIX,sLang);
	
	return Plugin_Handled;
}