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

DBugR.Profilers.CCmd = table.Copy( DBugR.SP );

DBugR.Profilers.CCmd.Name = "ConCommands";
DBugR.Profilers.CCmd.Type = SERVICE_PROVIDER_TYPE_NET;

if ( CLIENT ) then 

	RunConsoleCommand = DBugR.Util.Func.AddDetour( RunConsoleCommand, function( cmd, ... )

		// If the command exists on the client in this function, nothing is sent to the server
		if ( concommand.GetTable()[ cmd ] ) then return; end

		local len = cmd:len();
		for _, str in pairs( { ... } ) do 

			len = len + tostring( str ):len() + 1;

		end

		DBugR.Profilers.CCmd:AddNetData( cmd, len - 1 ); 

	end);

end

local meta = FindMetaTable( "Player" );

meta.ConCommand = DBugR.Util.Func.AddDetour( meta.ConCommand, function( str )

	str = tostring( str );

	local cmd = string.Explode( " ", str )[ 1 ];

	// If the command exists on the client and we're calling it from the client, nothing is sent to the server
	if ( CLIENT && concommand.GetTable()[ cmd ] ) then return; end

	DBugR.Profilers.CCmd:AddNetData( cmd, str:len() ); 

end);