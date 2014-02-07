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
 
	WARNING: THIS FILE IS QUITE MESSY

*/

local panel = {};

STAT_ERR = 0;
STAT_SUC = 1;
STAT_MSG = 2;

surface.CreateFont( DBugR.Prefix .. "LogMarkFont", {
	font = "Comic Sans",
 	size = 95,
 	weight = 700,
 	blursize = 0,
 	antialias = true,
 	underline = false,
 	italic = false
} );

function panel:Init()

	self.LogsA = {};
	self.LogsB = {};

	// == LOG BROWSERS == //
	self.LogBrowser1 = vgui.Create( DBugR.Prefix .. "LogView", self );
	self.LogBrowser1.FileBrowser.OnRowSelected = function( panel, line, p_line )

		self.LogsA = panel:GetSelected();

		if ( self.LogsA && #self.LogsA > 0 && self.LogsB && #self.LogsB > 0 ) then 

			self:SetCompileButtonStatus( STAT_MSG, "compile logs" );

		else 

			self:SetCompileButtonStatus( STAT_ERR, "select logs" );

		end

	end
	self.LogBrowser2 = vgui.Create( DBugR.Prefix .. "LogView", self );
	self.LogBrowser2.FileBrowser.OnRowSelected = function( panel, line, p_line )

		self.LogsB = panel:GetSelected();

		if ( self.LogsA && #self.LogsA > 0 && self.LogsB && #self.LogsB > 0 ) then 

			self:SetCompileButtonStatus( STAT_MSG, "compile logs" );

		else 

			self:SetCompileButtonStatus( STAT_ERR, "select logs" );

		end

	end

	// == COMPILE BUTTON == //

	self.CompileButton = vgui.Create( DBugR.Prefix .. "FlatButton", self );
	self.CompileButton:SetSize( 300, 75 );
	self.CompileButton.DoClick = function() self:DoCompile(); end

	// == LOG MARKERS == //
	self.LogMarkA = vgui.Create( "DLabel", self );
	self.LogMarkA:SetFont( DBugR.Prefix .. "LogMarkFont" );
	self.LogMarkA:SetText( "A" );
	self.LogMarkA:SetContentAlignment( 5 );
	self.LogMarkA:SetTextColor( Color( 0, 200, 0 ) );

	self.LogMarkB = vgui.Create( "DLabel", self );
	self.LogMarkB:SetFont( DBugR.Prefix .. "LogMarkFont" );
	self.LogMarkB:SetText( "B" );
	self.LogMarkB:SetContentAlignment( 5 );
	self.LogMarkB:SetTextColor( Color( 200, 0, 0 ) );

	// == GRAPHS == //
	self.GraphNet = vgui.Create( DBugR.Prefix .. "LineGraph", self );
	self.GraphNet:SetXRange( 30, 1, -1 );
	self.GraphNet:SetYRange( 0, 1024, 256 );

	self.GraphNet:SetTitle( "Networking Graph" );
	self.GraphNet:SetLinePrefixX( "time" );
	self.GraphNet:SetLinePrefixY( "b/s" );

	self.GraphNet:SetupGroup( "A", Color( 0, 200, 0 ) );
	self.GraphNet:SetupGroup( "B", Color( 200, 0, 0 ) );

	self.GraphCPU = vgui.Create( DBugR.Prefix .. "LineGraph", self );
	self.GraphCPU:SetXRange( 30, 1, -1 );
	self.GraphCPU:SetYRange( 0, 16, 4 );

	self.GraphCPU:SetTitle( "Performance Graph" );
	self.GraphCPU:SetLinePrefixX( "time" );
	self.GraphCPU:SetLinePrefixY( "ms/s" );

	self.GraphCPU:SetupGroup( "A", Color( 0, 200, 0 ) );
	self.GraphCPU:SetupGroup( "B", Color( 200, 0, 0 ) );

	self:SetCompileButtonStatus( STAT_ERR, "select logs" );

end

function panel:SetCompileButtonStatus( stat, msg )

	msg = msg:upper();

	if ( stat == STAT_ERR ) then 

		self.CompileButton:SetTextColor( Color( 200, 0, 0 ) );
		self.CompileButton:SetDisabled( true );
		self.CompileButton:SetText( msg );

	elseif ( stat == STAT_SUC ) then 

		self.CompileButton:SetTextColor( Color( 0, 200, 0 ) );
		self.CompileButton:SetDisabled( true );
		self.CompileButton:SetText( msg );

	elseif ( stat == STAT_MSG ) then 

		self.CompileButton:SetTextColor( Color( 0, 0, 0 ) );
		self.CompileButton:SetDisabled( false );
		self.CompileButton:SetText( msg );

	end

end


function panel:PerformLayout()

	self.LogBrowser1:SetSize( ( self:GetWide() * 0.50 ) - ( self.CompileButton:GetWide() * 0.50 ) - 4, self:GetTall() * 0.50 );
	self.LogBrowser1:SetPos( 0, self:GetTall() * 0.50 );

	self.CompileButton:SetPos( ( self:GetWide() * 0.50 ) - ( self.CompileButton:GetWide() * 0.50 ), self:GetTall() - self.CompileButton:GetTall() - 8 );

	self.LogBrowser2:SetPos( self.CompileButton.x + self.CompileButton:GetWide() + 4, self:GetTall() * 0.50 );
	self.LogBrowser2:SetSize( ( self:GetWide() * 0.50 ) - ( self.CompileButton:GetWide() * 0.50 ) - 4, self:GetTall() * 0.50 );

	self.LogMarkA:SizeToContentsX( 5 );
	self.LogMarkA:SetTall( self:GetTall() * 0.50 - 4 )
	self.LogMarkA:SetPos( 0, 0 );
	
	self.LogMarkB:SizeToContentsX( 5 );
	self.LogMarkB:SetTall( self:GetTall() * 0.50 - 4 )
	self.LogMarkB:SetPos( self:GetWide() - self.LogMarkB:GetWide(), 0 );

	self.GraphNet:SetPos( self.LogMarkA:GetWide() + 4, 4 );
	self.GraphNet:SetSize( self:GetWide() - self.LogMarkB:GetWide() - self.LogMarkA:GetWide() - 16, ( self:GetTall() * 0.50 ) * 0.50 - 4 );

	self.GraphCPU:SetPos( self.LogMarkA:GetWide() + 4, self.GraphNet:GetTall() + 4 );
	self.GraphCPU:SetSize( self:GetWide() - self.LogMarkB:GetWide() - self.LogMarkA:GetWide() - 16, ( self:GetTall() * 0.50 ) * 0.50 - 4 );

end

function panel:CompileSingle( path, results, i )

	print(path);
	local data = DBugR.Util.IO.Read( path, "rb" );

	local results = results or { 
		{ },  // Performance
		{ }   // Networking
	};

	local x = 1;
	for name, _d in pairs( data.gdata ) do

		for i, d in pairs( _d ) do 

			results[ d.row ][ x ] = results[ d.row ][ x ] or {}

			if ( d.size != 0 ) then 

				table.insert( results[ d.row ][ x ], d.size );

			end

			// Each 30 should go in their own sub table for easier averaging later
			if ( #results[ d.row ][ x ] == 30 ) then x = x + 1; end

		end
		
	end

	return results;

end

function panel:PercentageDiff( a, b )

	local max, min = math.max( a, b ), math.min( a, b );

	return ( ( max - min ) / max ) * 100; 

end

function panel:DoCompile()

	local a = {};
	local b = {};

	local results = { nil, nil };

	// Get the names of files from the selected panels
	for k, panel in pairs( self.LogsA ) do a[ k ] = panel:GetValue( 1 ); end
	for k, panel in pairs( self.LogsB ) do b[ k ] = panel:GetValue( 1 ); end

	// Merge tables
	local t = { a, b };
	local delay = 0.0;

	// Compile all logs
	for tk, _t in pairs( t ) do 

		for k, log in pairs( _t ) do 

			local i = 1;
			timer.Simple( delay, function()

				local domain = self[ "LogBrowser" .. tk ].SelectedDomain and DBUGR_SV_LOGPATH or DBUGR_CL_LOGPATH;
				results[ tk ] = self:CompileSingle( domain .. self[ "LogBrowser" .. tk ].DirBrowser:GetValue() .. "/" .. log, results[ tk ], i );

				i = i + 1;
				self:SetCompileButtonStatus( STAT_SUC, "log " .. ( tk == 1 and "a" or "b" ) .. " " .. k .. "/" .. #_t .. " parsed" );

			end);
			delay = delay + 0.3;

		end

	end

	timer.Simple( delay + 0.3, function()

		local avgs = { { {}, {} }, { {}, {} } };

		// Reset graph ranges
		self.GraphNet:SetXRange( 30, 1, -1 );
		self.GraphNet:SetYRange( 0, 1024, 256 );

		self.GraphCPU:SetXRange( 30, 1, -1 );
		self.GraphCPU:SetYRange( 0, 16, 4 );

		// Populate graphs
		for ab = 1, 2 do 

			for typ = 1, 2 do 

				for i = 1, 30 do 

					// Get data to calculate average
					local t = 0;
					local a = 0;
					for _, v in pairs( results[ ab ][ typ ] ) do 

						v = (v[ i ] or 0);

						if ( v > 0 ) then 

							t = t + v;
							a = a + 1;

						end 

					end

					// Calculate average
					local avg = math.Round( math.max( t, 1 ) / math.max( a, 1 ), 2 );
					local p = self[ "Graph" .. ( typ == 1 and "CPU" or "Net" ) ];

					avgs[ ab ][ typ ][ i ] = avg;

					// If the average we just calculated is bigger than the graph we're going to put it in, increase that graph's size
					if ( p.YMax < avg ) then 

						p:SetYRange( 0, avg, avg / 4 );

					end

					// Add the point
					p:AddPointAndPushback( ab == 1 and "A" or "B", t / #results[ ab ][ typ ] );

				end

			end

		end

		// Get the difference in percent between log a and b's performance (not networking)
		local a = { 0, 0 };
		local b = { 0, 0 };

		for i = 1, 30 do 

			for typ = 1, 2 do

				a[ typ ] = a[ typ ] + avgs[ 1 ][ typ ][ i ];
				b[ typ ] = b[ typ ] + avgs[ 2 ][ typ ][ i ];

			end

		end

		local percent = self:PercentageDiff( a[ 1 ], b[ 1 ] ) + self:PercentageDiff( a[ 2 ], b[ 2 ] );

	end);

end

function panel:Paint( w, h )

	draw.RoundedBox( 4, 0, 0, w, h, Color( 240, 240, 240 ) );

end

vgui.Register( DBugR.Prefix .. "ComparisonWindow", panel, "DPanel" );