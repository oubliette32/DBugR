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

/*

	This got confusing so I decided not to use it.

*/

DBugR.Util.Net = {};

DBugR.Util.Net.Listener = {}; // Contains callbacks that are called when messages have finished being buffered
DBugR.Util.Net.Buffer 	= {}; // Contains parts of messages being sent
DBugR.Util.Net.Incoming = {}; // Contains information about incoming messages
DBugR.Util.Net.Sending 	= {}; // Contains information about outgoing messages 

// Enums
NET_PTYPE_AUTHED 	= 0x0;
NET_PTYPE_NAUTHED 	= 0x1;
NET_PTYPE_ALL 		= 0x2;
NET_PTYPE_SERVER	= 0x3;

// Network channels
if ( SERVER ) then

	util.AddNetworkString( DBugR.Prefix .. "IncomingMessage" );
	util.AddNetworkString( DBugR.Prefix .. "BufferMessage" );

end

// Adds a listener that will be called with all the date 
function DBugR.Util.Net.AddListener( name, func )

	DBugR.Util.Net.Listener[ name ] = func;

end

// Send a message
function DBugR.Util.Net.Send( name, ply, ... )

	local data = util.Base64Encode( util.Compress( util.TableToJSON( { ... } ) ) );

	// Tell the receiever they're going to recieve a message
	net.Start( DBugR.Prefix .. "IncomingMessage" );

		net.WriteString( name );
		net.WriteInt( data:len(), 32 );

	net.Broadcast();

	// Send the message data
	local d = DBugR.Util.Net.Split( data, 1024 );

	// Send each part in different frames
	local function send( t, i  )

		DBugR.Print( "sent part " .. i );
		DBugR.Util.Net.SendChunk( ply, t[ i ], name );
		i = i + 1;

		if ( t[ i ] ) then timer.Simple( 0, function( ) send( t, i ); end ); end

	end

	send( d, 1 );

end

function DBugR.Util.Net.SendChunk( cbase, chunk, name )

	if ( isnumber( cbase ) ) then 

		if ( cbase == NET_PTYPE_AUTHED ) then 

			for _, ply in pairs( player.GetAll() ) do 

				if ( !hook.Run( DBugR.Prefix .. "PlayerAuth" ) ) then continue; end

				net.Start( DBugR.Prefix .. "BufferMessage" );

					net.WriteString( name );
					net.WriteString( chunk );

				net.Send( ply )
				DBugR.Print( "sent " .. name .. " to " .. ply:Nick() );

			end

		elseif ( cbase == NET_PTYPE_NAUTHED ) then 

			for _, ply in pairs( player.GetAll() ) do 

				if ( hook.Run( DBugR.Prefix .. "PlayerAuth" ) ) then continue; end

				net.Start( DBugR.Prefix .. "BufferMessage" );

					net.WriteString( name );
					net.WriteString( chunk );

				net.Send( ply )
				DBugR.Print( "sent " .. name .. " to " .. ply:Nick() );

			end

		elseif ( cbase == NET_PTYPE_ALL ) then 

			net.Start( DBugR.Prefix .. "BufferMessage" );

				net.WriteString( name );
				net.WriteString( chunk );

			net.Broadcast( );
			DBugR.Print( "sent " .. name .. " to everyone" );

		elseif ( cbase == NET_PTYPE_SERVER ) then 

			net.Start( DBugR.Prefix .. "BufferMessage" );

				net.WriteString( name );
				net.WriteString( chunk );

			net.SendToServer( );
			DBugR.Print( "sent " .. name .. " to the server" );

		end

	elseif ( isentity( cbase ) && cbase:IsPlayer() ) then 

		net.Start( DBugR.Prefix .. "BufferMessage" );

			net.WriteString( name );
			net.WriteString( chunk );

		net.Send( cbase );
		DBugR.Print( "sent " .. name .. " to " .. cbase:Nick() );

	end

end

// Splits a string into strings of size.
// Last entry may not be equal to size if str does not divide by size equally
function DBugR.Util.Net.Split( str, size )

	local t = {};
	for i = 1, str:len(), size do 

		local r = str:len() >= size and size or size - str:len();
		t[ #t + 1 ] = str:sub( i, i + r );

	end

	lolcache = t;

	return t;

end

function DBugR.Util.Net.IncomingM( ply, len )

	if ( !len ) then len = ply; end

	local name = net.ReadString();
	local size = net.ReadInt( 32 );

	DBugR.Print( "incoming message, name = " .. name .. " size = " .. size );

	DBugR.Util.Net.Incoming[ name ] = size; 

end
net.Receive( DBugR.Prefix .. "IncomingMessage", DBugR.Util.Net.IncomingM );

function DBugR.Util.Net.BufferM( ply, len )

	if ( !len ) then len = ply; end
	local name = net.ReadString();
	local str = net.ReadString();

	DBugR.Util.Net.Buffer[ name ] = ( DBugR.Util.Net.Buffer[ name ] or "" ) .. str;
	DBugR.Print( "buffered " .. str .. " in incoming message " .. name );

	DBugR.Print( name .. " size = " .. DBugR.Util.Net.Buffer[ name ]:len() .. " max size = " .. DBugR.Util.Net.Incoming[ name ] );
	if ( DBugR.Util.Net.Buffer[ name ]:len() >= DBugR.Util.Net.Incoming[ name ] ) then 

		if ( DBugR.Util.Net.Listener[ name ] ) then 

			data = util.JSONToTable( dec64( DBugR.Util.Net.Buffer[ name ] ) );

			DBugR.Util.Net.Listener[ name ]( data, len, ply );
			DBugR.Print( "called " .. name .. "callback" );

			DBugR.Util.Net.Buffer[ name ] = nil;
			DBugR.Util.Net.Incoming[ name ] = nil;

		end

	end

end
net.Receive( DBugR.Prefix .. "BufferMessage", DBugR.Util.Net.BufferM );



