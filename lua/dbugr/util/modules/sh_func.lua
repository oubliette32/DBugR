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

DBugR.Util.Func = {};
DBugR.Util.Func.Origins = {};

// Calls stub when func is called, returning anything will do nothing
function DBugR.Util.Func.AddDetour( func, stub )

	local oldFunc = func;
	local f = function( ... )

		stub( ... );
		return oldFunc( ... );

	end
	
	if ( DBUGR_FUNC_LOGGING ) then 

		DBugR.Print( "Func.AddDetour: " .. tostring( func ) .. " => " .. tostring( stub ) );

	end

	DBugR.Util.Func.Origins[ f ] = func;

	return f;

end

// Calls stub when func is called, stub must return the args for oldFunc
function DBugR.Util.Func.AddDetourM( func, stub )

	local oldFunc = func;
	local f = function( ... )

		return oldFunc( stub( ... ) );

	end

	if ( DBUGR_FUNC_LOGGING ) then 

		DBugR.Print( "Func.AddDetourM: " .. tostring( func ) .. " => " .. tostring( stub ) );

	end
	
	DBugR.Util.Func.Origins[ f ] = func;

	return f;

end

// Calls callback when func is called, passing the time it took for func to be called.
// Don't use this to detour anything that returns more than 5 things, as any other returned
// variables will be lost
function DBugR.Util.Func.AttachProfiler( func, callback )

	local oldFunc = func;
	local f = function( ... )

		local start = SysTime();

		local r1, r2, r3, r4, r5, r6, r7, r8, r9 = oldFunc( ... );

		// We want the time in milliseconds, mul by 1000
		callback( ( SysTime() - start ) * 1000 );

		return r1, r2, r3, r4, r5, r6, r7, r8, r9;

	end

	if ( DBUGR_FUNC_LOGGING ) then 

		DBugR.Print( "Func.AttachProfiler: " .. tostring( func ) .. " => " .. tostring( callback ) );

	end

	DBugR.Util.Func.Origins[ f ] = func;

	return f;

end

// Returns the "original function", which is the function passed if the function passed was not detoured.
function DBugR.Util.Func.GetOriginal( func )

	return DBugR.Util.Func.Origins[ func ] or func;

end