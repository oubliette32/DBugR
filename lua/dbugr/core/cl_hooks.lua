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

// Same thing as InitialPlayerSpawn in sv_hooks.lua but for the client
net.Receive( DBugR.Prefix .. "OnClientLoad", function( len ) 

	if ( !hook.Run( DBugR.Prefix .. "PlayerAuth", LocalPlayer() ) ) then return; end

	// Get all the logs in the clientside log directory
	for _, dir in pairs( DBugR.Util.IO.GetDirectories("data/dbugr/cl_logs/*") ) do 

		// Use the loggers function to call the new dir hook
		DBugR.Logger.NewDir( dir );

		for _, f in pairs( DBugR.Util.IO.GetFiles( "data/dbugr/cl_logs/" .. dir .. "/*" ) ) do 

			// Use the logger's new file function like we did above
			DBugR.Logger.NewFile( dir, f );

		end

	end

end);