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

util.AddNetworkString( DBugR.Prefix .. "RequestFunctionCode" );
util.AddNetworkString( DBugR.Prefix .. "FunctionCodeStream" );

net.Receive( DBugR.Prefix .. "RequestFunctionCode", function( len, ply ) 

	if ( !hook.Run( DBugR.Prefix .. "PlayerAuth", ply ) ) then return; end

	local path = net.ReadString();

	local start = net.ReadInt( 32 );
	local finish = net.ReadInt( 32 );

	local f = file.Open( path, "r", "MOD" );

	if ( !f ) then 

		DBugR.Print( ply:Nick() .. " requested non existant function (script path not found)" );
		return;

	elseif ( DBUGR_FREQ_LOGGING ) then

		DBugR.Print( ply:Nick() .. " requested function on line " .. start .. " in " .. path );

	end

	local str = f:Read( f:Size() );
	local parts = string.Explode( '\n', str );
	local padding = 1;

	// Count the tabs and spaces in the first line
	if ( parts[ start ] ) then 

		local str = parts[ start ];
		for i = 1, str:len() do 

			if ( str[ i ] == ' ' || str[ i ] == '\t' ) then 

				padding = padding + 1;

			else 

				// If we found another character, break the loop and stop counting
				break;

			end

		end

	end 

	local n = 0;
	for i = start, finish do 

		if ( !parts[ i ] ) then continue; end

		timer.Simple( 0.01 * n, function()

			net.Start( DBugR.Prefix .. "FunctionCodeStream" )

				local str = parts[ i ];

				if ( str != "" && str != '\n' && str != ' ' && padding != 0 ) then 

					str = str:sub( padding, str:len() );

				end

				net.WriteString( str );

			net.Send( ply );

		end);

		n = n + 1;

	end

end);