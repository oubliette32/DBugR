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

concommand.Add( "dbugr_runtests_" .. ( CLIENT and "cl" or "sv" ), function( ply, cmd, args )

	if ( DBUGR_AUTH_TESTS && !hook.Run( DBugR.Prefix .. "PlayerAuth", ply ) ) then return; end

	if ( args[ 1 ] ) then 

		if ( file.Exists( "addons/dbugr/lua/test/" .. args[ 1 ], "GAME" ) ) then 

			local start = SysTime();

			DBugR.Print( "Running file " .. args[ 1 ] .. " .. " );

			RunString( file.Read( "addons/dbugr/lua/test/" .. args[ 1 ], "GAME" ) );

			DBugR.Print( "Ran in " .. ( SysTime() - start ) * 1000 .. "ms" );

		else 

			DBugR.Print( "'" .. args[ 1 ] .. "' doesn't exist." );

		end

	else 

		local t = DBugR.Util.IO.GetFiles( "addons/dbugr/lua/test/*.lua" );

		for i = 1, #t do 

			timer.Simple( i - 1, function()

				local start = SysTime();

				DBugR.Print( "[" .. tostring( i ) .. "] Running file " .. t[ i ] .. " .. " );

				RunString( file.Read( "addons/dbugr/lua/test/" .. t[ i ], "GAME" ) );

				DBugR.Print( "[" .. tostring( i ).. "] Ran in " .. ( SysTime() - start ) * 1000 .. "ms" );

			end);
			
		end

	end

end, 

function( cmd, args )

	local t = {};
	for k, f in pairs( DBugR.Util.IO.GetFiles( "addons/dbugr/lua/test/*.lua" ) ) do 

		t[ k ] = cmd .. " " .. f;

	end

	return t;

end );