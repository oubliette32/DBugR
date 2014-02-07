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
	Slow, not needed
*/

DBugR.Util.Stream = {};

DBugR.Util.Stream.Name = "Virtual Stream";
DBugR.Util.Stream.Use  = "Virtualizing writing and reading into net streams or files";

DBugR.Util.Stream.Bytes = {};
DBugR.Util.Stream.Point = 0;

// Use this function to create an instance of the stream.
function DBugR.Util.Stream.New()

	return table.Copy( DBugR.Util.Stream );

end

// Returns an array of bytes inside 's'.
function DBugR.Util.Stream:GetStringBytes( s )

	local t = {};

	// Iterate through the string converting each char into a byte and storing it in t
	for i = 1, s:len() do 

		t[ i ] = string.byte( s[ i ] );

	end

	return t;

end

// Returns array of bytes that make up a number.
// For floats and doubles and things that contain floating points, the bytes that make up the numbers after the decimal
// point is placed after the bytes before it.  bytes . bytes 
function DBugR.Util.Stream:NumberToBytes( n )

	local t = {};
	local x = math.Round( n );

	while ( x > 0 ) do

		t[ #t + 1 ] = bit.band( x, 0xFF );
		x = bit.rshift( x, 8 );

	end

	return t;

end

// Attempts to convert an array of bytes to some form of number
// Decimal points have to be handled manually.
function DBugR.Util.Stream:BytesToNumber( t )
	
	local n = 0;
	for i = 1, #t do 

		if ( t[ i ] == 0 ) then continue; end
		n = n + bit.lshift( bit.band( t[ i ], 0xFF ), 8 * ( i - 1 ) );

	end

	return n;

end

/* == READ FUNCTIONS == */

// Reads 'n' characters from the stream
function DBugR.Util.Stream:ReadString( n )

	local s = {};

	for i = self.Point, self.Point + n do 

		if ( self:Get( i ) == nil ) then break; end

		s[ #s + 1 ] = string.char( self:Get( i ) );
		
	end

	self:Seek( self.Point + n );

	return table.concat( s );

end

// Reads 1 byte from the stream and returns it as a boolean
function DBugR.Util.Stream:ReadBool( )

	if ( self:Get( self.Point ) == nil ) then return; end

	if ( self:ReadByte() == 0 ) then return false; end
	return true;

end

// Reads and returns 1 byte
function DBugR.Util.Stream:ReadByte( )

	if ( self:Get( self.Point ) == nil ) then return; end

	local i = self.Point;
	self:Seek( self.Point + 1 );

	return self:Get( i );

end

// Reads x bytes and returns them as a byte array
function DBugR.Util.Stream:ReadBytes( n )

	local t = {};

	for i = 1, n do 

		local b = self:ReadByte();
		if ( b != nil ) then t[ i ] = b; end

	end 

	return t;

end

// TODO: FIX
function DBugR.Util.Stream:ReadDouble( n )

	return tonumber( self:ReadBytes( 4 ) .. "." .. self:ReadBytes( 4 ) );

end

// TODO: FIX
function DBugR.Util.Stream:ReadFloat( n )

	return tonumber( self:BytesToNumber( self:ReadBytes( 2 ) ) .. "." .. self:BytesToNumber( self:ReadBytes( 2 ) ) );

end

// Reads a long from the stream, 4 bytes
function DBugR.Util.Stream:ReadLong( n )

	return self:BytesToNumber( self:ReadBytes( 4 ) );

end

// Reads a short from the stream, 2 bytes
function DBugR.Util.Stream:ReadShort( n )

	return self:BytesToNumber( self:ReadBytes( 4 ) );

end

/* == WRITE FUNCTIONS == */

// Writes a string into the stream
function DBugR.Util.Stream:WriteString( s )

	for i = self.Point, self.Point + s:len() - 1 do

		self:Set( i, string.byte( s[ i - self.Point + 1 ] ) );

	end

	self:Seek( self.Point + s:len() );

end

// Writes 1 byte that represents a boolean into the stream
function DBugR.Util.Stream:WriteBool( b )

	self:WriteByte( b and 1 or 0 );

end

// Writes a single byte into the stream
function DBugR.Util.Stream:WriteByte( b )

	self:Set( self.Point, b );
	self:Seek( self.Point + 1 );

end

// Writes a table of bytes
function DBugR.Util.Stream:WriteBytes( t, d )

	for i = 1, d or #t do 

		self:WriteByte( t[ i ] or 0 );

	end 

end

// TODO: FIX
function DBugR.Util.Stream:WriteDouble( n )

	local x, xmod = math.modf( n );

	local tx 	= self:NumberToBytes( x );
	local txmod = self:NumberToBytes( xmod * ( 10 ^ ( tostring( xmod ):len() - 2 ) ) ); 

	self:WriteBytes( tx, 4 );
	self:WriteBytes( txmod, 4 );

end

// TODO: FIX
function DBugR.Util.Stream:WriteFloat( n )

	local x, xmod = math.modf( n );

	local tx 	= self:NumberToBytes( x );
	local txmod = self:NumberToBytes( xmod * ( 10 ^ ( tostring( xmod ):len() - 2 ) ) ); 

	self:WriteBytes( tx, 2 );
	self:WriteBytes( txmod, 2 );

end

// Writes a long into the stream, 4 bytes
function DBugR.Util.Stream:WriteLong( n )

	self:WriteBytes( self:NumberToBytes( math.Round( n ) ), 4 );

end

// Writes a short into the stream, 2 bytes
function DBugR.Util.Stream:WriteShort( n )

	self:WriteBytes( self:NumberToBytes( math.Round( n ) ), 2 );

end

/* == POINTER FUNCTIONS == */

// Sets the position of the pointer
function DBugR.Util.Stream:Seek( n )

	self.Point = math.max( 0, math.min( n, self:Size() + 1 ) );

	return self.Point;

end

// Returns the size of the stream
function DBugR.Util.Stream:Size( n )

	if ( #self.Bytes == 0 && self.Bytes[ 0 ] != nil ) then return 1; end 
	if ( #self.Bytes == 0 && self.Bytes[ 0 ] == nil ) then return 0; end

	return #self.Bytes + 1;

end

// Advances 'n' bytes into the stream
function DBugR.Util.Stream:Skip( n )
 
 	self:Seek( self.Point + ( n or 1 ) );

end

// Returns the position of the pointer
function DBugR.Util.Stream:Tell( )

	return self.Point;

end

// Sets a value in the byte buffer, accounts for c to lua array indices
function DBugR.Util.Stream:Set( i, v )

	self.Bytes[ i ] = v;

end 

// Returns a byte at a certain index, accounts for c to lua array indices
function DBugR.Util.Stream:Get( i )

	return self.Bytes[ i ];

end 

/* == MACRO FUNCTIONS == */

DBugR.Util.Stream.Read = DBugR.Util.Stream.ReadString;
DBugR.Util.Stream.Write = DBugR.Util.Stream.WriteString;

// Compatibility with file IO
DBugR.Util.Stream.Close = function() end