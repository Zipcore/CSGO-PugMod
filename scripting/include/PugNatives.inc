#if defined _PugNatives_included
	#endinput
#endif
#define _PugNatives_included

#include <sourcemod>
#include <PugConst>

/**
 * @brief Call a Pug Warmup
 * 
 */
 native PugWarmup();
 
 /**
 * @brief Call a Pug Start
 * 
 */
 native PugStart();
 
 /**
 * @brief Call a Pug Match
 * 
 */
 native PugMatch();
 
  /**
 * @brief Get a Pug Stage
 * 
 */
native PugStage:GetPugStage();

 /**
 * @brief Get Total Pug Players
 * 
 */
native GetPugPlayers();

 /**
 * @brief Get Pug Total Rounds
 * 
 */
native GetPugRound();

 /**
 * @brief Check if the player is in a registred team
 * 
 */
 native bool:PugIsTeam(iClient);