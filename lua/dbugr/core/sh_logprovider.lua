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

// == HOOKS == //
hook.Add( DBugR.Prefix .. "OnDataRaw", "LogProvider", function( ... ) 

	if ( SERVER || !DBugR.LogProvider.IsLogProviding ) then 
	
		hook.Run( DBugR.Prefix .. "OnData", ... );

	end

end);

hook.Add( DBugR.Prefix .. "OnGDataRaw", "LogProvider", function( ... ) 

	if ( SERVER || !DBugR.LogProvider.IsLogProviding ) then 
	
		hook.Run( DBugR.Prefix .. "OnDatagramUpdate", ... );

	end

end);

// == SERVERSIDE STUFF == //

if ( SERVER ) then 

	util.AddNetworkString( DBugR.Prefix .. "RequestLog" );
	util.AddNetworkString( DBugR.Prefix .. "SendLog" );

	net.Receive( DBugR.Prefix .. "RequestLog", function( len, ply ) 

		if ( !hook.Run( DBugR.Prefix .. "PlayerAuth", ply ) ) then return; end

		local path = net.ReadString();

		// Only authed players can use this anyway, but we still don't want them touching files they shouldn't.
		if ( path:find( "%.%.%/" ) ) then 

			DBugR.Print( ply:Nick() .. " requested file '" .. DBUGR_SV_LOGPATH .. path .. "' that was rejected for character violations!" );
			return; 

		end

		if ( !file.Exists( DBUGR_SV_LOGPATH .. path, "DATA" ) ) then 

			DBugR.Print( ply:Nick() .. " requested non-existant file 'dbugr/sv_logs/" .. path .. "'!" );
			return; 

		end

		// Read the file they want
		local str = file.Read( DBUGR_SV_LOGPATH .. path, "DATA" );

		DBugR.Print( ply:Nick() .. " requested file '" .. DBUGR_SV_LOGPATH .. path .. "':" .. str:len() );

		// Send the file they want in parts
		local j = 1;
		for i = 1, str:len(), DBUGR_PACKET_SIZE do 

			timer.Simple( DBUGR_PACKET_SPEED * j, function()

				local r = ( str:len() - i ) >= DBUGR_PACKET_SIZE and DBUGR_PACKET_SIZE or ( str:len() - i );
				local _str = str:sub( i, i + r - 1 );

				local t = {};
				for i = 1, _str:len() do 

					t[ i ] = string.byte( _str[ i ] );

				end

				net.Start( DBugR.Prefix .. "SendLog" );

					net.WriteBit( i + r == str:len() );
					net.WriteString( path );
					net.WriteTable( t );

				net.Send( ply );

			end );

			j = j + 1;

		end

	end)

end

// Everything else is client only
if ( !CLIENT ) then return; end

DBugR.LogProvider = {};
DBugR.LogProvider.Buffer = {};

DBugR.LogProvider.IsLogProviding 	= false;
DBugR.LogProvider.Log 				= "";
DBugR.LogProvider.Frame 			= 30;
DBugR.LogProvider.LogData			= {};

// == CLIENTSIDE NET CALLBACKS == //

// Buffer incoming logs
net.Receive( DBugR.Prefix .. "SendLog", function( len ) 

	local isLast 	= tobool( net.ReadBit() );
	local name 		= net.ReadString();
	local buf 		= net.ReadTable();

	// Decode from a byte table
	for i = 1, #buf do buf[ i ] = string.char( buf[ i ] ); end
	buf = table.concat( buf );

	DBugR.LogProvider.Buffer[ name ] = ( DBugR.LogProvider.Buffer[ name ] or "" ) .. buf;
	if ( isLast ) then 

		hook.Run( DBugR.Prefix .. "OnLogDownloaded", name, DBugR.LogProvider.Buffer[ name ] );
		DBugR.LogProvider.Buffer[ name ] = nil;

	end

	hook.Run( DBugR.Prefix .. "OnLogBuffered", name, buf );

end);

// == LOG PROVIDER STUFF == //

function DBugR.LogProvider.LoadLog( path )

	if ( file.Exists( "dbugr/cl_logs/" .. path, "DATA" ) ) then 

		DBugR.LogProvider.Log = path;

		return DBugR.LogProvider.LoadRaw( DBugR.LogProvider.LogFileToTable( "dbugr/cl_logs/" .. path ) );

	elseif ( file.Exists( "dbugr/sv_logs/" .. path, "DATA" ) ) then

		DBugR.LogProvider.Log = path;

		return DBugR.LogProvider.LoadRaw( DBugR.LogProvider.LogFileToTable( "dbugr/sv_logs/" .. path ) );

	end

	return false;

end

function DBugR.LogProvider.LoadRaw( data )

	if ( !data || !istable( data ) ) then return false; end

	DBugR.LogProvider.IsLogProviding = true;
	DBugR.LogProvider.LogData = data;

	if ( data.data ) then 

		for name, _d in pairs( data.data ) do

			for i, d in pairs( _d ) do 

				hook.Call( DBugR.Prefix .. "OnData", GM or GAMEMODE, d.typ, name, d.state, d.data );

			end

		end

	end

	if ( data.gdata ) then 

		for name, _d in pairs( data.gdata ) do

			for i, d in pairs( _d ) do 

				hook.Call( DBugR.Prefix .. "OnDatagramUpdate", GM or GAMEMODE, d.state, d.row, d.size, name );

			end
			
		end

	end

	return true;

end

function DBugR.LogProvider.GoLive( )

	DBugR.LogProvider.IsLogProviding = false;
	DBugR.LogProvider.Frame = 30;

end

function DBugR.LogProvider.SelectFrame( i )

	i = math.min( math.max( 0, i ), 30 );
	DBugR.LogProvider.Frame = i;

	for name, d in pairs( DBugR.LogProvider.LogData.data ) do

		hook.Call( DBugR.Prefix .. "OnData", GM or GAMEMODE, d[ i ].typ, name, d[ i ].state, d[ i ].data );

	end

end

function DBugR.LogProvider.LogFileToTable( path )

	return DBugR.Util.IO.Read( path, "rb" );

end