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

DBugR.Profilers.Timer = table.Copy( DBugR.SP );

DBugR.Profilers.Timer.Name = "Timers";
DBugR.Profilers.Timer.Type = SERVICE_PROVIDER_TYPE_CPU;

// It would be useful if there was a timer.GetTable function, but since
// the timer switchover (lua > c++) there appears to be no way to get a list
// of timers that exist.  For now all we can do is detour .Simple and .Create
// and hope we load first.

timer.Simple = DBugR.Util.Func.AddDetourM( timer.Simple, function( name, func, ... ) 

	func = DBugR.Util.Func.AttachProfiler( func, function( time ) 

		DBugR.Profilers.Timer:AddPerformanceData( "simpletimer", time, func );

	end);

	return name, func, unpack( {...} );

end);

timer.Create = DBugR.Util.Func.AddDetourM( timer.Create, function( name, del, rep, func ) 

	func = DBugR.Util.Func.AttachProfiler( func, function( time ) 

		DBugR.Profilers.Timer:AddPerformanceData( tostring( name ), time, func );

	end);

	return name, del, rep, func;

end);