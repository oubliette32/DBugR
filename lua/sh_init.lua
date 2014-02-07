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

// Is it just me or is garrysmod loading addons twice?
if ( DBugR || !DBUGR_ENABLED ) then return; end

DBugR = {};

// Do not edit
DBugR.Author  	= "Oubliette";
DBugR.Version 	= 2.0;
DBugR.Prefix  	= DBUGR_PREFIX;

/*

	!!!!CONFIGURABLE VARIABLES HAVE BEEN MOVED TO DBUGR/LUA/SH_SETTINGS.LUA!!!!

*/

// -- AUTOMATIC FILE INCLUSION -- //

function DBugR.Include( folder, files, dirs )

	for k,v in pairs( files ) do 

		local p = string.Left( v, 2 );

		if ( p == "sh" ) then 

			if ( SERVER ) then AddCSLuaFile( folder .. "/" .. v );end

			include( folder .. "/" .. v );
			DBugR.Print(folder .. "/" .. v .. " loaded!");

		elseif ( p == "sv" ) then 

			if ( SERVER ) then 

				include( folder .. "/" .. v );
				DBugR.Print(folder .. "/" .. v .. " loaded!");

			end

		elseif ( p == "cl" ) then 

			if ( SERVER ) then 

				AddCSLuaFile( folder .. "/" .. v );

			else 

				include( folder .. "/" .. v );
				DBugR.Print(folder .. "/" .. v .. " loaded!");

			end

		else 

			ErrorNoHalt( "Unknown prefix '" .. tostring( p ) .. "'\n" );
			
		end

	end

	// Folders must load AFTER the files in the core directory
	for _, dir in pairs( dirs ) do 

		DBugR.Include( folder .. "/" .. dir, file.Find( folder .. "/" .. dir .. "/*", "LUA" ) )

	end

end

// -- SEXY PRINT FUNCTION -- //

function DBugR.Print( ... )

	MsgC( Color( 200, 200, 200, 255 ), "[" );
	MsgC( Color( 0, 200, 0, 255 ), "D" );
	MsgC( Color( 40, 40, 40, 255 ), "Bug" );
	MsgC( Color( 0, 200, 0, 255 ), "R" );
	MsgC( Color( 200, 200, 200, 255 ), "] " );
	MsgC( Color( 127, 127, 127, 255 ), ... );
	MsgC( Color( 255, 255, 255, 255 ), "\n" );

end

function DBugR.Start()

	DBugR.Include( "dbugr/util", file.Find( "dbugr/util/*", "LUA" ) );
	DBugR.Include( "dbugr/core", file.Find( "dbugr/core/*", "LUA" ) );
	DBugR.Include( "dbugr/gui", file.Find( "dbugr/gui/*", "LUA" ) );

end

DBugR.Start();

