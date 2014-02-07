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

DBugR.Profilers.UmsgPerf = table.Copy( DBugR.SP );

DBugR.Profilers.UmsgPerf.Name = "Usermessages";
DBugR.Profilers.UmsgPerf.Type = SERVICE_PROVIDER_TYPE_CPU;

local oldUH = usermessage.Hook;

// Detour any usermessage hooks that currently exist
for name, data in pairs( usermessage.GetTable() ) do

	usermessage.GetTable()[ name ] = nil;
	oldUH( name, DBugR.Util.Func.AttachProfiler( data.Function, function( time ) 

		DBugR.Profilers.ConComPerf:AddPerformanceData( tostring( name ), time, data.Function );

	end));

end

// Detour future usermessage hooks
usermessage.Hook = DBugR.Util.Func.AddDetourM( usermessage.Hook, function( name, func, ... ) 

	func = DBugR.Util.Func.AttachProfiler( func, function( time ) 

		DBugR.Profilers.ConComPerf:AddPerformanceData( tostring( name ), time, func );

	end);

	return name, func, unpack( {...} );

end);