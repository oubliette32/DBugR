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

DBugR.Logger = {};

DBugR.Logger.Data = { };
DBugR.Logger.GData = { }; 

DBugR.Logger.FileStructure = {};

DBugR.Logger.FlushLimit = 30; // TODO: Change to global DBugR variable
DBugR.Logger.CurrentCycles = 0;

if ( SERVER ) then 

	util.AddNetworkString( DBugR.Prefix .. "OnLoggerDir" );
	util.AddNetworkString( DBugR.Prefix .. "OnLoggerFile" );

end

function DBugR.Logger.Purge()

	if ( !DBUGR_PURGE_ENABLED ) then return; end

	local purged = false;

	// Delete old clientside files
	for _, dir in pairs( DBugR.Util.IO.GetDirectories("data/" .. DBUGR_CL_LOGPATH .. "*") ) do 

		for _, f in pairs( DBugR.Util.IO.GetFiles( "data/" .. DBUGR_CL_LOGPATH .. dir .. "/*" ) ) do 

			if ( os.time() - file.Time( DBUGR_CL_LOGPATH .. dir .. "/" .. f, "DATA" ) > DBUGR_PURGE_TIME && ( CLIENT && !DBugR.ArchiveHandler.IsArchived( dir .. "/" .. f ) ) ) then 

				file.Delete( DBUGR_CL_LOGPATH .. dir .. "/" .. f, "DATA" );
				purged = true;

			end

		end

	end

	// Delete old serverside files
	for _, dir in pairs( DBugR.Util.IO.GetDirectories("data/" .. DBUGR_SV_LOGPATH .. "*") ) do 

		for _, f in pairs( DBugR.Util.IO.GetFiles( "data/" .. DBUGR_SV_LOGPATH .. dir .. "/*" ) ) do 

			if ( os.time() - file.Time( DBUGR_SV_LOGPATH .. dir .. "/" .. f, "DATA" ) > DBUGR_PURGE_TIME && ( CLIENT && !DBugR.ArchiveHandler.IsArchived( dir .. "/" .. f ) ) ) then 

				file.Delete( DBUGR_SV_LOGPATH .. dir .. "/" .. f, "DATA" );
				purged = true;

			end

		end

	end

	// Don't bother calling the purge hook unless files were actually deleted
	if ( purged ) then hook.Run( DBugR.Prefix .. "OnLoggerPurge" ); end

end 

function DBugR.Logger.Flush()

	local data = { data = DBugR.Logger.Data, gdata = DBugR.Logger.GData };

	// Delete old records
	DBugR.Logger.Purge();

	local fileName = 	os.date( "%H_%M_%S" .. ( SERVER and "S" or "C" ) .. ".txt" );
	local dirName = 	os.date( "%d_%m_%Y" );
	local path = 		CLIENT and DBUGR_CL_LOGPATH or DBUGR_SV_LOGPATH;

	// Write to file
	DBugR.Util.IO.Write( path .. dirName .. "/" .. fileName, "wb", data );

	// If the directory we're writing to doesn't exist, call DBugR.Logger.NewDir
	if ( !file.IsDir( path .. dirName, "DATA" ) ) then DBugR.Logger.NewDir( dirName ); end

	// Call the DBugR.Logger.NewFile because we're always writing to a new file here
	DBugR.Logger.NewFile( dirName, fileName, SERVER and file.Size( path .. dirName .. "/" .. fileName, "DATA" ) );

	// Empty tables
	DBugR.Logger.Data = { };
	DBugR.Logger.GData = { }; 

end 

// == CALLBACKS == //

// Called when a new directory is created by the logger
function DBugR.Logger.NewDir( dir )

	if ( CLIENT ) then 
		
		hook.Run( DBugR.Prefix .. "OnLoggerDir", dir );

	else 

		net.Start( DBugR.Prefix .. "OnLoggerDir" );

			net.WriteString( dir );

		net.Broadcast();

	end

end
net.Receive( DBugR.Prefix .. "OnLoggerDir", function( len ) DBugR.Logger.NewDir( net.ReadString() ) end );

// Called when the logger creates a new file
function DBugR.Logger.NewFile( dir, f, s )

	if ( CLIENT ) then 

		if ( !DBugR.Logger.FileStructure[ dir ] ) then DBugR.Logger.FileStructure[ dir ] = {}; end

		DBugR.Logger.FileStructure[ dir ][ f ] = s or false;
		hook.Run( DBugR.Prefix .. "OnLoggerFile", dir, f );

	else 

		net.Start( DBugR.Prefix .. "OnLoggerFile" );

			net.WriteString( dir );
			net.WriteString( f );
			net.WriteInt( s, 32 );

		net.Broadcast();

	end

end
net.Receive( DBugR.Prefix .. "OnLoggerFile", function( len ) DBugR.Logger.NewFile( net.ReadString(), net.ReadString(), net.ReadInt( 32 ) ) end );

// == HOOKS == //

hook.Add( DBugR.Prefix .. "OnDataRaw", "DataLog", function( typ, name, state, data ) 

	if ( !DBUGR_LOGGING_ENABLED ) then return; end

	for _name, sdata in pairs( data ) do 

		if ( isnumber( sdata ) ) then 

			DBugR.Logger.Data[ "net" ] = DBugR.Logger.Data[ "net" ] or {};
			table.insert( DBugR.Logger.Data[ "net" ], sdata );

		elseif ( istable( sdata ) ) then 

			DBugR.Logger.Data[ sdata.loc ] = DBugR.Logger.Data[ sdata.loc ] or {};

			local ndata = { name, _name, state, sdata.calls, sdata.total, sdata.last, sdata.start, sdata.finish };
			table.insert( DBugR.Logger.Data[ sdata.loc ], ndata );

		end

	end
	
	DBugR.Logger.CurrentCycles = DBugR.Logger.CurrentCycles + 1;
	if ( DBugR.Logger.CurrentCycles >= DBugR.Logger.FlushLimit * ( CLIENT and 4 or 2 ) ) then 

		DBugR.Logger.Flush( );
		DBugR.Logger.CurrentCycles = 0;

	end

end);

hook.Add( DBugR.Prefix .. "OnGDataRaw", "DataLog", function( state, row, size, name ) 

	if ( !DBUGR_LOGGING_ENABLED ) then return; end

	DBugR.Logger.GData[ name ] = DBugR.Logger.GData[ name ] or {};
	table.insert( DBugR.Logger.GData[ name ], { state = state, row = row, size = size } );

	if ( #DBugR.Logger.GData[ name ] >= DBugR.Logger.FlushLimit * ( CLIENT and 4 or 2 ) ) then 

		DBugR.Logger.Flush( );

	end

end);