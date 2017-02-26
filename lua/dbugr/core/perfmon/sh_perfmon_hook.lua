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

DBugR.Profilers.Hook = table.Copy( DBugR.SP );

DBugR.Profilers.Hook.Name = "Hooks";
DBugR.Profilers.Hook.Type = SERVICE_PROVIDER_TYPE_CPU;
DBugR.Profilers.Hook.OldHA = nil;

function DBugR.Profilers.Hook.Start()

	// So that I can reload the scripts
	if ( !DBugR.Profilers.Hook.OldHA ) then 

		// QAC, ZeroTheFallen's AC detours hook.Add, we need the original
		// LeyAC also des tgis (dumgf fuckers)
		if ( CLIENT && ( QAC || LeyAC ) ) then 

			_, DBugR.Profilers.Hook.OldHA = debug.getupvalue( hook.Add, 2 ); 

		else 

			DBugR.Profilers.Hook.OldHA = hook.Add; 

		end
		
	end

	// Detour any hooks that currently exist
	for typ, hooks in pairs( hook.GetTable() ) do

		for name, _hook in pairs( hooks ) do 

			// Restore ULib priority, if ULib isn't loaded, the 4th argument will still be nil
			local priority;
			if ( ULib ) then 

				local _, oldHooks = debug.getupvalue(DBugR.Profilers.Hook.OldHA, 4);
				priority = 0;

				for i = 1, #(oldHooks[ typ ] or {}) do 

					if ( oldHooks[ typ ][ i ].name == name ) then 

						priority = oldHooks[ typ ][ i ].priority;
						break;

					end

				end

			end

			// Remove and re-add the hook
			hook.Remove( typ, name );
			DBugR.Profilers.Hook.OldHA( typ, name, DBugR.Util.Func.AttachProfiler( _hook, function( time ) 

				DBugR.Profilers.Hook:AddPerformanceData( tostring( typ ) .. "_" .. tostring( name ), time, _hook );

			end), priority);

		end

	end

	// Detour future hooks
	hook.Add = DBugR.Util.Func.AddDetourM( hook.Add, function( typ, name, func, ... ) 

		func = DBugR.Util.Func.AttachProfiler( func, function( time ) 

			DBugR.Profilers.Hook:AddPerformanceData( tostring( typ ) .. "_" .. tostring( name ), time, func );

		end);

		return typ, name, func, ...; -- other args could be things such as priority, if ulib is running

	end);

	local gm = GAMEMODE or ( GM or { } );

	// Detour all existing gamemode functions
	for name, func in pairs( gm ) do 

		if ( !isfunction( func ) ) then continue; end


		gm[ name ] = DBugR.Util.Func.AttachProfiler( func, function( time ) 

			DBugR.Profilers.Hook:AddPerformanceData( "GM:" .. tostring( name ), time, func );

		end);

	end


	// Detour future gamemode hooks
	debug.setmetatable( gm, {

		__newindex = function( t, k, v )

			if ( isfunction( v ) ) then 

				v = DBugR.Util.Func.AttachProfiler( v, function( time ) 

					DBugR.Profilers.Hook:AddPerformanceData( "GM:" .. tostring( k ), time, v );

				end);

			end

			rawset( t, k, v );

		end

	} );

end 

timer.Simple( 1, DBugR.Profilers.Hook.Start );
