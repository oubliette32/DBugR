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

DBugR.Profilers = {};

SERVICE_PROVIDER_TYPE_NET = 2;
SERVICE_PROVIDER_TYPE_CPU = 1;

STATE_CLIENT = 0;
STATE_SERVER = 1;
STATE_MENU   = 2; // We're never going to be here delete this line pl0x

// Network and performance server providers will copy this table into theres as a base.  This also assures certain functions always appear.
DBugR.SP = {};

// Name used in graphs to represent the data that this provides
DBugR.SP.Name = "";

// Stores all the data collected by this service before it's flushed.
// With network service providers the format is Data[ channel ] = numBytes
// With performance service providers the format is : 
// data[ hook name, timer name, etc ] = 
//	 { 
//		calls = how many times it was called, 
// 		loc = location of the function, 
//		total = total amount of seconds worth of lag caused this second,
//		last = amount of seconds worth of lag caused last time this was called,
// 	 }
DBugR.SP.Data = {};

// With NSP's this is the total amount of bytes written by this nsp since it was last flushed
// With PSP's this is the total amount of lag caused by this psp since it was last flushed
DBugR.SP.Cache = 0;

// SERVICE_PROVIDER_TYPE_NET for NSP's, SERVICE_PROVIDER_TYPE_CPU for PSP's
DBugR.SP.Type = -1;

DBugR.SP.BlacklistCache = {};

// Flushes all of the collected data
function DBugR.SP:Flush( )

	// Server hooks should relay this data to the client and call the exact same hook there

	// All the datagrams need is the total size, which we should've cached for added speed
	hook.Run( DBugR.Prefix .. "OnGDataRaw", CLIENT and STATE_CLIENT or STATE_SERVER, self.Type, self.Cache, self.Name );

	// OnData passes every piece of collected info, with net service providers that's only the name and b/s
	// With performane providers there's the function source, calls p/s total lag caused in a second and speed of 
	// The last call.
	hook.Run( DBugR.Prefix .. "OnDataRaw", self.Type, self.Name, CLIENT and STATE_CLIENT or STATE_SERVER, self.Data );

	// We're done with this set of data now
	self.Data = {};
	self.Cache = 0;

end

// Checks whether or not a name is blacklisted.
// Iterating over DBUGR_BAD_PREFIXES and doing string operations is not something we want to do
// thousands of times a second, so first check a cache of already known bad names before iterating our list
function DBugR.SP:CheckName( name )

	// Check the cache first
	if ( self.BlacklistCache[ name ] == false ) then

		return false; 

	else

		// If the name's not in the cache, compare name against everything in DBUGR_BAD_PREFIXES
		for _, pref in pairs( DBUGR_BAD_PREFIXES ) do 

			if ( name:sub( 1, pref:len() ) == pref ) then 

				self.BlacklistCache[ name ] = false;
				return false;

			end

		end

		// If it got this far we checked everything in DBUGR_BAD_PREFIXES and there were no matches
		self.BlacklistCache[ name ] = true;

	end

	return true;

end

// Simply adds data the the data table and caches the size
function DBugR.SP:AddNetData( channel, size )

	if ( !self:CheckName( channel ) ) then return; end

	size = size or 0;

	self.Data[ channel ] = self.Data[ channel ] and self.Data[ channel ] + size or size;

	self.Cache = self.Cache + size;

end

// Simply adds data the the data table and caches the size
function DBugR.SP:AddPerformanceData( name, lag, func )

	if ( !self:CheckName( name ) ) then return; end

	if ( !self.Data[ name ] ) then 

		local dbg = debug.getinfo( DBugR.Util.Func.GetOriginal( func ) );

		if ( !dbg ) then return; end

		self.Data[ name ] = { loc = dbg.short_src, calls = 0, total = 0, last = 0, start = dbg.linedefined, finish = dbg.lastlinedefined };

	end

	self.Data[ name ].calls = self.Data[ name ].calls + 1;
	self.Data[ name ].total = self.Data[ name ].total + lag;
	self.Data[ name ].last = lag;

	self.Cache = self.Cache + lag;

end

// Automatically flushes service providers every second
timer.Create( DBugR.Prefix .. "SPFlusher", 1, 0, function() 

	for name, instance in pairs( DBugR.Profilers ) do 

		if ( instance.Flush && !DBUGR_DISABLED_SPS[ name ] ) then 

			instance:Flush();

		end

	end

end);