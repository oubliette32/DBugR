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

if ( SERVER ) then 

	util.AddNetworkString( DBugR.Prefix .. "OnDataTransfer" );
	util.AddNetworkString( DBugR.Prefix .. "OnDataGTransfer" );

	hook.Add( DBugR.Prefix .. "OnData", "DataTransfer", function( typ, name, state, data ) 

		for _, ply in pairs( player.GetAll() ) do 

			if ( hook.Run( DBugR.Prefix .. "PlayerAuth", ply ) ) then
				
				net.Start( DBugR.Prefix .. "OnDataTransfer" );

					net.WriteInt( typ, 4 );
					net.WriteString( name );
					net.WriteInt( state, 4 );
					net.WriteTable( data );

				net.Send( ply );

			end

		end

	end);

	hook.Add( DBugR.Prefix .. "OnDatagramUpdate", "DataTransfer", function( state, row, size, name ) 
		
		for _, ply in pairs( player.GetAll() ) do 

			if ( hook.Run( DBugR.Prefix .. "PlayerAuth", ply ) ) then 

				net.Start( DBugR.Prefix .. "OnDataGTransfer" );

					net.WriteInt( state, 4 );
					net.WriteInt( row, 4 );
					net.WriteDouble( size );
					net.WriteString( name );

				net.Send( ply );

			end

		end

	end);

else 

	net.Receive( DBugR.Prefix .. "OnDataGTransfer", function( len ) 

		hook.Call( DBugR.Prefix .. "OnGDataRaw", GM or GAMEMODE, net.ReadInt( 4 ), net.ReadInt( 4 ), net.ReadDouble( ), net.ReadString( ) );

	end);

	net.Receive( DBugR.Prefix .. "OnDataTransfer", function( len ) 

		hook.Call( DBugR.Prefix .. "OnDataRaw", GM or GAMEMODE, net.ReadInt( 4 ), net.ReadString( ), net.ReadInt( 4 ), net.ReadTable() );

	end);

end