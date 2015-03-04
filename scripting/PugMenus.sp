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

public OnPluginStart()
{
	LoadTranslations("PugMenus.phrases");
}