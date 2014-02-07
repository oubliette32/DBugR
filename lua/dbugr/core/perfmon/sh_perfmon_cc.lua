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

DBugR.Profilers.ConComPerf = table.Copy( DBugR.SP );

DBugR.Profilers.ConComPerf.Name = "ConCommands";
DBugR.Profilers.ConComPerf.Type = SERVICE_PROVIDER_TYPE_CPU;

local oldCA = concommand.Add;

// Detour any concommands that currently exist
for name, func in pairs( concommand.GetTable() ) do

	concommand.Remove( name );
	oldCA( name, DBugR.Util.Func.AttachProfiler( func, function( time ) 

		DBugR.Profilers.ConComPerf:AddPerformanceData( tostring( name ), time, func );

	end));

end

// Detour future console commands
concommand.Add = DBugR.Util.Func.AddDetourM( concommand.Add, function( name, func, ... ) 

	func = DBugR.Util.Func.AttachProfiler( func, function( time ) 

		DBugR.Profilers.ConComPerf:AddPerformanceData( tostring( name ), time, func );

	end);

	return name, func, unpack( {...} );

end);