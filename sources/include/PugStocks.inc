#if defined _PugStocks_included
	#endinput
#endif
#define _PugStocks_included

#include <sourcemod>

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
		PrintToServer("* %T",LANG_SERVER,sLang);
	}
	
	PrintToChat(iClient,"%s %T",g_sHead,LANG_SERVER,sLang);
	
	return Plugin_Handled;
}