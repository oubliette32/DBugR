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

// Default hook, return true if you want clients to be able to use DBugR.
// Obviously for whatever reason clients "could" override this hook, but it will not effect
// serverside functions of DBugR - though clientside profiling will still take place.

hook.Add( DBugR.Prefix .. "PlayerAuth", "Default", function( ply ) 

	if ( !ply || !IsValid( ply ) ) then return; end

	for _, group in pairs( DBUGR_AUTHED_GROUPS ) do if ( ply:IsUserGroup( group ) ) then return true; end end
	for _, user  in pairs( DBUGR_AUTHED_USERS  ) do if ( ply:SteamID() == user ) then return true; end end

	if ( DBUGR_ADMIN_AUTH && ply:IsAdmin() ) then return true; end
	if ( DBUGR_SADMIN_AUTH && ply:IsSuperAdmin() ) then return true; end

	return false;

end);