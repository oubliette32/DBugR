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

if ( CLIENT ) then return; end

DBugR.Profilers.Umsg = table.Copy( DBugR.SP );

DBugR.Profilers.Umsg.CChan = "";
DBugR.Profilers.Umsg.Name = "Usermessages";
DBugR.Profilers.Umsg.Type = SERVICE_PROVIDER_TYPE_NET;

umsg.Start = DBugR.Util.Func.AddDetour( umsg.Start, function( str ) 

	DBugR.Profilers.Umsg.CChan = str;

end);

// ==  == == == == == == //

umsg.Angle = DBugR.Util.Func.AddDetour( umsg.Angle, function() 

	// float = 4 bytes, angle = 3 floats : 12 bytes
	DBugR.Profilers.Umsg:AddNetData( DBugR.Profilers.Umsg.CChan, 12 );

end);

umsg.Bool = DBugR.Util.Func.AddDetour( umsg.Bool, function() 

	// bool : 1 byte
	DBugR.Profilers.Umsg:AddNetData( DBugR.Profilers.Umsg.CChan, 1 );

end);

umsg.Char = DBugR.Util.Func.AddDetour( umsg.Char, function() 

	// char : 1 byte
	DBugR.Profilers.Umsg:AddNetData( DBugR.Profilers.Umsg.CChan, 1 );

end);

umsg.Entity = DBugR.Util.Func.AddDetour( umsg.Entity, function() 

	// Entities are actually just indicies, which are ints. int : 4 bytes
	DBugR.Profilers.Umsg:AddNetData( DBugR.Profilers.Umsg.CChan, 4 );

end);

umsg.Float = DBugR.Util.Func.AddDetour( umsg.Float, function() 

	// float : 4 bytes
	DBugR.Profilers.Umsg:AddNetData( DBugR.Profilers.Umsg.CChan, 4 );

end);

umsg.Long = DBugR.Util.Func.AddDetour( umsg.Long, function() 

	// long : 4 bytes
	DBugR.Profilers.Umsg:AddNetData( DBugR.Profilers.Umsg.CChan, 4 );

end);

umsg.PoolString = DBugR.Util.Func.AddDetour( umsg.PoolString, function( str ) 

	// Pool string apparently has some "indentifying number" sent as the string,
	// It could be compressed, but since as whatever said on the wiki sounds like 
	// Bullshit, I'm going to assume this is the same as umsg.String 
	DBugR.Profilers.Umsg:AddNetData( DBugR.Profilers.Umsg.CChan, str:len() );

end);

umsg.Short = DBugR.Util.Func.AddDetour( umsg.Short, function() 

	// short : 2 bytes
	DBugR.Profilers.Umsg:AddNetData( DBugR.Profilers.Umsg.CChan, 2 );

end);

umsg.String = DBugR.Util.Func.AddDetour( umsg.String, function( str ) 

	str = tostring( str );

	// string : str:len()
	DBugR.Profilers.Umsg:AddNetData( DBugR.Profilers.Umsg.CChan, str:len() );

end);

umsg.Vector = DBugR.Util.Func.AddDetour( umsg.Vector, function() 

	// float = 4 bytes, vector = 3 floats : 12 bytes
	DBugR.Profilers.Umsg:AddNetData( DBugR.Profilers.Umsg.CChan, 12 );

end);

umsg.VectorNormal = DBugR.Util.Func.AddDetour( umsg.VectorNormal, function() 

	// Same as umsg.Vector
	DBugR.Profilers.Umsg:AddNetData( DBugR.Profilers.Umsg.CChan, 12 );

end);

