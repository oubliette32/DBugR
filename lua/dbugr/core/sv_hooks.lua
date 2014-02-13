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

util.AddNetworkString( DBugR.Prefix .. "OnClientLoad" );

// This is where we'll send data (such as log dirs and log files, serverside settings, etc) that is usually
// sent to connected players as the data is made available.
hook.Add( "PlayerInitialSpawn", DBugR.Prefix .. "InitialData", function( ply ) 

	// This is an expensive un-needed action if logging isn't enabled
	if ( !DBUGR_LOGGING_ENABLED ) then return; end

	if ( !hook.Run( DBugR.Prefix .. "PlayerAuth", ply ) ) then return; end

	// Get all directories in the serverside log directory and send them to the client
	for _, dir in pairs( DBugR.Util.IO.GetDirectories("data/" .. DBUGR_SV_LOGPATH .. "*") ) do 

		// Use the loggers function to send the directory to the client and have the client call the corresponding hook
		DBugR.Logger.NewDir( dir );

		for _, f in pairs( DBugR.Util.IO.GetFiles( "data/" .. DBUGR_SV_LOGPATH .. dir .. "/*" ) ) do 

			// Use the logger's new file function like we did above
			DBugR.Logger.NewFile( dir, f, file.Size( DBUGR_SV_LOGPATH .. dir .. "/" .. f, "DATA" ) );

		end

	end

	// Send settings

	// Call the load function on the client in 1s
	timer.Simple( 1, function() net.Start( DBugR.Prefix .. "OnClientLoad" ); net.Send( ply ); end );

end);