/*
	$$$$$$$\  $$$$$$$\                      $$$$$$$\  
	$$  __$$\ $$  __$$\                     $$  __$$\ 
	$$ |  $$ |$$ |  $$ |$$\   $$\  $$$$$$\  $$ |  $$ |
	$$ |  $$ |$$$$$$$\ |$$ |  $$ |$$  __$$\ $$$$$$$  |
	$$ |  $$ |$$  __$$\ $$ |  $$ |$$ /  $$ |$$  __$$< 
	$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |
	$$$$$$$  |$$$$$$$  |\$$$$$$  |\$$$$$$$ |$$ |  $$ |
	\_______/ \_______/  \______/  \____$$ |\__|  \__|
	                              $$\   $$ |          
	                              \$$$$$$  |          
	                               \______/           

	* Copyright (C) 2013 - All Rights Reserved
	* Unauthorized copying of this file, via any medium is strictly prohibited
	* Written by Oubliette <oubliette32@gmail.com>, 2013

	* Version 2.0

*/

// ======================================================================
// ============================== DBUGR =================================
// ======================================================================

/*
	A short string that prefixes all of DBugR's custom hooks, hook names and net channels.
*/
DBUGR_PREFIX 			= "DBUGR-";

/*
	If moving the addon from the addon's folder is too much for you to handle, setting this to false will stop DBugR from loading entirely
*/
DBUGR_ENABLED 			= true;

/*	w
	A list of disabled servide providers (add a service providers' name to this list to disable it).
	Note: Use the namespace rather than the .Name value, for example to disable usermessage network logging, you'd add "Umsg" to this list rather than 
		  "Usermessages"
	Note: This list is case sensitive.
*/
DBUGR_DISABLED_SPS 		= { "example" };

// ======================================================================
// ========================= UTILITY LOGGING ============================
// ======================================================================


/* 
	This will enabled logging for the function library.  May cause moderate console spam.
*/
DBUGR_FUNC_LOGGING 		= false;

/*
	This will enabled logging for the io library.  May cause minor console spam.
*/
DBUGR_IO_LOGGING   		= false;

// ======================================================================
// ========================== ACTION LOGGING ============================
// ======================================================================

/*
	If this is enabled, request for serverside function code will be printed.  May cause minor to moderate console spam.
*/
DBUGR_FREQ_LOGGING 		= true;

// ======================================================================
// =========================== AUTHORIZATION ============================
// ======================================================================

/*
	If this is true, this will non-authorized players from running test scripts
*/
DBUGR_AUTH_TESTS 		= true;

/*
	A list of groups that can use DBugR
	Note 	: groups are case sensitive
	Example : { "operator", "manager", "Operator" ... } 
*/
DBUGR_AUTHED_GROUPS 	= { };

/*
	SteamIDs of users that can use DBugR (optional)
	Note  	: SteamID's are rendered, they are not 64 bit
	Example : { "STEAM_0:1:34029133" }
*/
DBUGR_AUTHED_USERS 		= { };

/*
	If this is true and players pass Player.IsAdmin then they can use DBugR
*/
DBUGR_ADMIN_AUTH 		= true;

/*
	If this is true and players pass Player.IsSuperAdmin then they can use DBugR
*/
DBUGR_SADMIN_AUTH 		= true;

// ======================================================================
// ============================= NETWORKING =============================
// ======================================================================

/*
	The amount of time between packets sent in file transfers
*/
DBUGR_PACKET_SPEED 		= 0.05;

/*
	Bytes sent at a time in file transfer packets
*/
DBUGR_PACKET_SIZE		= 512;

// ======================================================================
// ========================= PROFILE LOGGING ============================
// ======================================================================

/*
	Added 2014 - Feb 13.  If enabled, loggging will perform as it usually does, otherwise logging will be completely disabled.
*/
DBUGR_LOGGING_ENABLED   = false;

/*
	If enabled, files that are older than DBUGR_PURGE_TIME will be automatically deleted.
*/
DBUGR_PURGE_ENABLED     = true;

/*
	Seconds that it takes for log files to expire and automatically delete
*/
DBUGR_PURGE_TIME  		= 60 * 60 * 24 * 3; -- 3 days

/*
	The path, relative to DATA that serverside logs are saved into
*/
DBUGR_SV_LOGPATH 		= "dbugr/sv_logs/";

/*
	The path, relative to DATA that clientside logs are saved into
*/
DBUGR_CL_LOGPATH 		= "dbugr/cl_logs/";

/*
	A list of prefixes that are not profiled at all.  For ease of use DBugR is not profiled.
*/
DBUGR_BAD_PREFIXES = { DBUGR_PREFIX };

// ======================================================================
// ==================== GRAPHICAL USER INTERFACE ========================
// ======================================================================

/*
	Colours of certain graph data
*/
DBUGR_GRAPH_COLOR = {
	[ "Hooks" ] 		= Color( 200, 200, 0 ),
	[ "Timers" ]		= Color( 100, 100, 100 ),
	[ "Net" ]			= Color( 200, 0, 0 ),
	[ "Usermessages" ]  = Color( 0, 200, 0 ),
	[ "ConCommands" ]	=  Color( 0, 0, 200 )
};