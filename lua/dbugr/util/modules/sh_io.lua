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

DBugR.Util.IO = {};

DBugR.Util.IO.Name = "I/O";
DBugR.Util.IO.Use  = "File I/O utilities";

DBugR.Util.IO.Codec = {

	[ TYPE_NIL ] = function( t_type, f )

		// Nothing

	end,

	[ TYPE_STRING ] = function( t_type, f, val )

		local val = DBugR.Util.IO.ReadWrite( t_type, f, "Float" )( val and val.len and val:len() or 0 ) or val;
		return DBugR.Util.IO.ReadWrite( t_type, f, "" )( val );

	end,

	[ TYPE_NUMBER ] = function( t_type, f, val )

		return DBugR.Util.IO.ReadWrite( t_type, f, "Float" )( val );

	end,

	[ TYPE_TABLE ] = function( t_type, f, val )

		if ( t_type == "Write" ) then 

			f:WriteLong( table.Count( val ) );

			for key, _val in pairs( val ) do 

				DBugR.Util.IO.RawWrite( f, key );
				DBugR.Util.IO.RawWrite( f, _val );

			end

		elseif ( t_type == "Read" ) then 

			local n = f:ReadLong( );
			local t = {};

			for i = 1, n do 

				t[ DBugR.Util.IO.RawRead( f ) ] = DBugR.Util.IO.RawRead( f );

			end

			return t;

		end

	end,

	[ TYPE_BOOL ] = function( t_type, f, val )

		return DBugR.Util.IO.ReadWrite( t_type, f, "Bool" )( val );

	end,

	[ TYPE_VECTOR ] = function( t_type, f, val )

		local x = DBugR.Util.IO.ReadWrite( t_type, f, "Float" )( val.x or 0 );
		local y = DBugR.Util.IO.ReadWrite( t_type, f, "Float" )( val.y or 0 );
		local z = DBugR.Util.IO.ReadWrite( t_type, f, "Float" )( val.z or 0 );

		return Vector( x or 0, y or 0, z or 0 );

	end,

	[ TYPE_ANGLE ] = function( t_type, f, val )

		local p = DBugR.Util.IO.ReadWrite( t_type, f, "Float" )( val.p or 0 );
		local y = DBugR.Util.IO.ReadWrite( t_type, f, "Float" )( val.y or 0 );
		local r = DBugR.Util.IO.ReadWrite( t_type, f, "Float" )( val.r or 0 );

		return Angle( p or 0, y or 0, r or 0 );

	end

};

function DBugR.Util.IO.ReadWrite( t_type, f, typ )

	return function( ... ) return f[ t_type .. typ ]( f, ... ); end

end

function DBugR.Util.IO.StripPath( path )

	path = path:Replace( "\\", "/" );

	local parts = string.Explode( "/", path );
	local cur = "";

	for i = 1, #parts - 1 do 

		cur = cur .. parts[ i ] .. "/";

	end

	return cur;

end

function DBugR.Util.IO.CreateDir( path )

	if ( file.Exists( path, "DATA" ) ) then return; end

	if ( DBUGR_IO_LOGGING ) then 

		DBugR.Print( "CreateDir: " .. path );

	end

	local parts = string.Explode( "/", path );
	local cur = "";

	for i = 1, #parts do 

		cur = cur .. parts[ i ] .. "/";
		file.CreateDir( cur );

	end

end 

function DBugR.Util.IO.RawRead( f )

	if ( f:Tell() >= f:Size() ) then return; end

	local b = f:ReadByte();

	if ( b == nil ) then return; end

	if ( DBugR.Util.IO.Codec[ b ] ) then 

		return DBugR.Util.IO.Codec[ b ]( "Read", f );

	end

end

function DBugR.Util.IO.Read( path, mode )

	local f = file.Open( path, mode or "r", "DATA" );

	if ( !f ) then return; end 

	local r = DBugR.Util.IO.RawRead( f );
	local ret = {};

	while ( r ) do 

		table.insert( ret, r );
		r = DBugR.Util.IO.RawRead( f );

	end

	if ( DBUGR_IO_LOGGING ) then 

		DBugR.Print( "IO.Read: PATH = " .. path .. " CYCLES = " .. #ret .. " SIZE = " .. file.Size( path, "DATA" ) );

	end

	f:Close();

	return unpack( ret );

end

function DBugR.Util.IO.RawWrite( f, data )

	local id = TypeID( data );

	if ( DBugR.Util.IO.Codec[ id ] ) then 

		f:WriteByte( id );
		DBugR.Util.IO.Codec[ id ]( "Write", f, data );

	end

end

function DBugR.Util.IO.Write( path, mode, ... )

	DBugR.Util.IO.CreateDir( DBugR.Util.IO.StripPath( path ) );

	local f = file.Open( path, mode or "w", "DATA" );

	if ( !f ) then return; end 

	local arg = { ... };
	for i = 1, #arg do 

		DBugR.Util.IO.RawWrite( f, arg[ i ] );

	end

	f:Close();

	if ( DBUGR_IO_LOGGING ) then 

		DBugR.Print( "IO.Write: PATH = " .. path .. " CYCLES = " .. #arg .. " SIZE = " .. file.Size( path, "DATA" ) );

	end

end

function DBugR.Util.IO.GetDirectories( path )

	local files, dirs = file.Find( path, "GAME" );
	return dirs;

end

function DBugR.Util.IO.GetFiles( path )

	local files, dirs = file.Find( path, "GAME" );
	return files;

end