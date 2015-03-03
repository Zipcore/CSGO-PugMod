#if defined _PugConst_included
	#endinput
#endif
#define _PugConst_included

#include <sourcemod>

#define PUG_MOD_AUTHOR 			"SmileY"
#define PUG_MOD_VERSION 		"0.0.1"
#define PUG_MOD_DESC 			"Pick Up Game for CS:GO and SourceMod"
#define PUG_MOD_WEBURL 			"PUG.MaxiGames.com.br"

stock const String:g_sHead[] = " \x01\x0B\x04[PUG]\x01";

enum PugStage
{
	PUG_STAGE_DEAD = 0,
	PUG_STAGE_WARMUP,
	PUG_STAGE_START,
	PUG_STAGE_MATCH
};

stock const String:g_sStage[PugStage][] =
{
	"Dead",
	"Warmup",
	"Staring",
	"Live"
};