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

DBugR.Profilers.NetPerf = table.Copy( DBugR.SP );

DBugR.Profilers.NetPerf.Name = "Net";
DBugR.Profilers.NetPerf.Type = SERVICE_PROVIDER_TYPE_CPU;

local oldNR = net.Receive;

// Detour any net listeners that currently exist
for name, func in pairs( net.Receivers ) do

	net.Receivers[ name ] = nil;
	oldNR( name, DBugR.Util.Func.AttachProfiler( func, function( time ) 

		DBugR.Profilers.NetPerf:AddPerformanceData( tostring( name ), time, func );

	end));

end

// Detour future net listeners
net.Receive = DBugR.Util.Func.AddDetourM( net.Receive, function( name, func, ... ) 

	func = DBugR.Util.Func.AttachProfiler( func, function( time ) 

		DBugR.Profilers.NetPerf:AddPerformanceData( tostring( name ), time, func );

	end);

	return name, func, ...;

end);