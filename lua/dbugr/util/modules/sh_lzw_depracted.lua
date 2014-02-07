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

	This utility proved slower and gave a lower compression ratio then util.Compress.

*/

DBugR.Util.LZW = {};

DBugR.Util.LZW.Name = "LZW";
DBugR.Util.LZW.Use  = "Decompress / compress strings using LZW";

// Local functions we will be using
local type 				= type;
local table_concat 		= table.concat;
local string_char 		= string.char;
local string_byte 		= string.byte;
local unpack 			= unpack;
local pairs 			= pairs;
local math_modf 		= math.modf;


// Encodes a number into a string, string is shorter than tostring( num )
// Decode with decode( x )

local bytes = {}
local function encode( x )

	bytes = {};

	local x, xmod = math_modf( x / 255 );
	xmod = xmod * 255;
	bytes[ 1 ]  = xmod;

	while ( x > 0 ) do

		x, xmod = math_modf( x / 255 );
		xmod = xmod * 255;
		bytes[ #bytes + 1 ] = xmod;

	end

	if ( #bytes == 1 and bytes[ 1 ] > 0 and bytes[ 1 ] < 250 ) then

		return string_char( bytes[ 1 ] );

	else

		for i = 1, #bytes do bytes[ i ] = bytes[ i ] + 1; end
		return string_char( 256 - #bytes, unpack( bytes ) );

	end

end

// Decodes an encoded number, encoded number has to be a string.  second argument is offset
// Returns decoded number and the amount of characters that the encoded text was equal to

local function decode( str, i )

	i = i or 1;
	local a = string_byte( str, i, i ); 

	if ( a > 249 ) then

		local r = 0;
		a = 256 - a;

		for n = i + a, i + 1, -1 do

			r = r * 255 + string_byte( str, n, n ) - 1;

		end

		return r, a + 1;

	else

		return a, 1;

	end

end

// Compresses a string using a LZW encryption algorithim

local dict = {};
function DBugR.Util.LZW.Compress( str )

	dict = {};

	local res = { "\002" };
	local w = "";
	local size, ressize = 256, 1;

	for i = 0, 255 do

		dict[ string_char( i ) ] = i;

	end

	for i = 1, str:len() do 

		local char = str[ i ];
		local wc = w .. char;

		if ( dict[ wc ] ) then 

			w = wc;

		else 

			dict[ wc ] = size;

			local r = encode( dict[ w ] );

			size = size + 1;
			ressize = ressize + 1;
			res[ #res + 1 ] = r;

			w = char;

		end

	end

	if ( w ) then 

		local r = encode( dict[ w ] ); 
		ressize = ressize + #r;
		res[ #res + 1 ] = r;

	end 

	if ( str:len() >= ressize ) then 

		return table_concat( res );

	else 

		return string_char( 1 ) .. str;

	end

end

// Decompresses an LZW string

local dict = {};
function DBugR.Util.LZW.Decompress( str )

	if ( str[ 1 ] != "\002" ) then return str; end

	dict = {};

	for i = 0, 255 do

		dict[ i ] = string_char( i );

	end

	str = str:sub( 2 );

	local size = 256;
	local res = {};

	local t = 1;
	local k, delta = decode( str, t );
	t = t + delta;

	res[ 1 ] = dict[ k ];

	local w = dict[ k ];
	local entry; 

	while ( t <= str:len() )  do

		k, delta = decode( str, t );
		t = t + delta;

		entry = dict[ k ] or ( w .. w[ 1 ] );
		res[ #res + 1 ] = entry;

		dict[ size ] = w .. entry[ 1 ];
		size = size + 1;

		w = entry;

	end

	return table_concat( res );

end