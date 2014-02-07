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

local panel = {};

// Fonts
surface.CreateFont( "LineGraphFont", { font = "Arial", size = 12, weight = 400 } );
surface.CreateFont( "LineGraphKeyFont", { font = "Arial", size = 14, weight = 600 } );

// For added speed, not 420 blaze it everyday no lag speed - but it helps
local math, surface, draw = math, surface, draw;

function panel:Init()

	// Colours
	self.BackgroundColour 	= Color( 240, 240, 240 );
	self.LineColour  		= Color( 69, 69, 69, 120 ); -- lol 69
	self.TextColour 		= Color( 49, 49, 49 );
	self.PausedColour 		= Color( 27, 27, 27, 150 );

	// Drawing options
	self:SetDecimals( 2 );
	self:SetDrawLineIntersections( true );
	self:SetDrawLineValues( true );

	// Title
	self:SetTitle( "<NOTITLE>" );

	// Line / group / data tables
	self.Groups 			= { }; -- self.Groups[ groupname ] = Color( 0, 0, 0 )

	self.HorizontalLines 	= { }; -- self.HorizontalLines[ 1 ] = 10, self.HorizontalLines[ 2 ] = 20, ...
	self.VerticalLines 		= { }; -- self.VerticalLines[ 1 ] = 10, self.VerticalLines[ 2 ] = 20, ...

	self.Data 				= { }; -- self.Data[ groupname ] = { [ 1 ] = { value = value, button = nil } }
	self.HiddenGroups 		= { }; -- self.HiddenGroups[ groupname ] = true

	self.KeyButtons = {};

	// Variables for the paused state
	self.Paused = false;
	self.PauseCache = {};

	// Other
	self.YMax, self.YMin = 0, 0;
	self.XMax, self.XMin = 0, 0;

	self.XIncrement = 0;
	self.YIncrement = 0;

	self.KeyWidth 	= 0;

	self.LineTexture = surface.GetTextureID( "trails/smoke" ); -- This seems to have a nice smoothing effect on the lines

	self:SetLinePrefixX( "time" );
	self:SetLinePrefixY( "millis" );

end

// == ACCESSOR FUNCTIONS == // 
function panel:SetBackgroundColour( col ) 	self.BackgroundColour = col; 	end
function panel:SetLineColour( col ) 		self.LineColour = col; 			end
function panel:SetTextColour( col ) 		self.TextColour = col; 			end

AccessorFunc( panel, "_decimals", "Decimals", FORCE_NUMBER );
AccessorFunc( panel, "_lineinters", "DrawLineIntersections", FORCE_BOOL );
AccessorFunc( panel, "_linevalues", "DrawLineValues", FORCE_BOOL );
AccessorFunc( panel, "_title", "Title", FORCE_STRING );
AccessorFunc( panel, "_lineprefx", "LinePrefixX", FORCE_STRING );
AccessorFunc( panel, "_lineprefy", "LinePrefixY", FORCE_STRING );

// == CONVIENICE FUNCTIONS == //

// Thanks CapsAdmin for this function
function panel:DrawLine( x1, y1, x2, y2, w )

	local dx, dy = x1 -x2, y1 -y2
	local rotation = math.deg(math.atan2(dx, dy))
	local distance = math.Distance(x1, y1, x2, y2)
	
	x1 = x1 -dx *0.5
	y1 = y1 -dy *0.5
	
	surface.SetTexture( self.LineTexture );
	surface.DrawTexturedRectRotated(x1, y1, w, distance, rotation)

end

// == PAINT FUNCTIONS == //
function panel:PaintBackground( w, h )

	// Simple mostly white rounded box for the background
	draw.RoundedBox( 4, 0, 0, w, h, self.BackgroundColour );

end 

function panel:PaintVerticalLines( w, h )

	// Draws vertical lines, the lines are actually draw horizontally but the positions increase vertically.
	surface.SetDrawColor( self.LineColour );

	for i = 1, #self.VerticalLines do

		local y = ( h - self.bY ) - self.linePaddingX * ( i - 1 );

		draw.SimpleText( isnumber( self.VerticalLines[ i ] ) and math.Round( self.VerticalLines[ i ] ) or self.VerticalLines[ i ], "LineGraphFont", self.bX - (self.bX / 2), y, self.TextColour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
		
		surface.DrawLine( self.bX - 6, y, w - self.bX, y );

	end

	// Draw the prefix, b/s, kb/s, ms etc
	draw.SimpleText( self:GetLinePrefixY(), "LineGraphFont", self.bX - (self.bX / 2) + 1, ( h - self.bY ) - self.linePaddingX * ( #self.VerticalLines - 1 ) - 10, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ); 

end

function panel:PaintHorizontalLines( w, h )

	local x = self.bX;

	// Same s above but for horizontal lines
	for i = 1, #self.HorizontalLines do 

		draw.SimpleText( isnumber( self.HorizontalLines[ i ] ) and math.Round( self.HorizontalLines[ i ] ) or self.HorizontalLines[ i ] , "LineGraphFont", x, h - ( self.bY / 2 ), self.TextColour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ); 

		surface.SetDrawColor( Color( 69, 69, 69, 120 ) );
		surface.DrawLine( x, self.bY, x, h - self.bY + 8 );

		x = x + self.linePaddingY;

	end

	// Draw the prefix, b/s, kb/s, ms etc
	draw.SimpleText( self:GetLinePrefixX(), "LineGraphFont", x, h - ( self.bY / 2 ), Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ); 

end 

function panel:PaintData( w, h )

	for group, data in pairs( self.Data ) do 

		local x = self.bX;

		for i = 1, #data do

			// Get the value and colour of the line
			local value = data[ i ].value;
			local col = self.Groups[ group ] or Color( 0, 0, 0 );

			// Calculate where it should be drawn
			local valNext = data[ i + 1 ] and data[ i + 1 ].value or value;
			local startY = (h - self.bY) - ( ( self.linePaddingX / self.YIncrement ) * ( value - self.YMin ) );

			local endX = i == #data and x or x + self.linePaddingY;
			local endY = i == #data and startY or ( h - self.bY ) - ( ( self.linePaddingX / self.YIncrement ) * ( valNext - self.YMin ) );
			
			// Set the draw colour for this line
			surface.SetDrawColor( self.HiddenGroups[ group ] and self.PausedColour or col );

			if ( self:GetDrawLineIntersections() && !self.HiddenGroups[ group ] ) then 
				
				// If we don't already have a button created, create one					
				if ( !self.Data[ group ][ i ].button ) then 

					self.Data[ group ][ i ].button = vgui.Create( DBugR.Prefix .. "KeyButton", self );
					self.Data[ group ][ i ].button:SetColour( col );
					self.Data[ group ][ i ].button.DoClick = function( panel )

						if ( DBugR.LogProvider.IsLogProviding ) then

							DBugR.LogProvider.SelectFrame( panel.index );

						end

					end
					self.Data[ group ][ i ].button.index = 30 - i + 1;

				end

				// Update the button's position, visibility and tooltip
				self.Data[ group ][ i ].button:SetPos( x - 2, startY - 2 );
				self.Data[ group ][ i ].button:SetSize( 4, 4 );
				self.Data[ group ][ i ].button:SetVisible( true );
				self.Data[ group ][ i ].button:SetTooltip( "Value : " .. value );

			elseif ( self.Data[ group ][ i ].button && self.Data[ group ][ i ].button:IsValid() ) then

				// If we're not drawing line intersections and a button exists, make it invisible
				self.Data[ group ][ i ].button:SetVisible( false );

			end
			
			if ( self:GetDrawLineValues() && !self.HiddenGroups[ group ] ) then 

				// Draw the value aside the intersection
				draw.SimpleText( isnumber( value ) and math.Round( value, self:GetDecimals() ) or value, "LineGraphFont", x + 6, startY + 6, self.TextColour, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER );

			end 

			// Draw the line that intersects or connects with the previous and next lines
			self:DrawLine( x, startY, endX, endY, 3 );
			
			// Increase 'x' for the next line
			x = x + self.linePaddingY;

		end

	end


end

function panel:PaintInfo( w, h )

	local keySpace = 0;
	for group, _ in pairs( self.Groups ) do 

		surface.SetFont( "LineGraphKeyFont" );

		// Set the font for the colour key
		local col = self.HiddenGroups[ group ] and Color( 27, 27, 27, 50 ) or ( self.Groups[ group ] or Color( 255, 100, 100 ) );

		// Set the colour for the key text
		surface.SetTextColor( col );

		// Set the position of the key text (aside the button that hides the group)
		surface.SetTextPos( ( w * 0.50 ) - ( self.KeyWidth * 0.50 ) + keySpace, 18 );

		// Create a button for this group if one does not exist
		if ( !self.KeyButtons[ group ] ) then 

			self.KeyButtons[ group ] = vgui.Create( DBugR.Prefix .. "KeyButton", self );
			self.KeyButtons[ group ]:SetColour( col );

			// When the button is left clicked we want to hide the respective group
			self.KeyButtons[ group ].DoClick = function( panel )

				if ( self.HiddenGroups[ group ] ) then 

					self.HiddenGroups[ group ] = nil;
					panel:SetColour( col );

				else 

					self.HiddenGroups[ group ] = true;
					panel:SetColour( Color( 27, 27, 27, 50 ) );

				end

			end

			// When the button is right clicked we want to hide all other groups
			self.KeyButtons[ group ].DoRightClick = function( panel )

				// Check if other buttons besides this one are enabled
				for _group, _ in pairs( self.Groups ) do 

					// Other groups are enabled, disable all but this group
					if ( !self.HiddenGroups[ _group ] && _group != group ) then 

						for __group, _ in pairs( self.Groups ) do 

							if ( __group != group ) then 

								self.HiddenGroups[ __group ] = true;

								if ( self.KeyButtons[ __group ] ) then 

									self.KeyButtons[ __group ]:SetColour( Color( 27, 27, 27, 50 ) );

								end

							end

						end
						return;

					end

				end

				// All other buttons are hidden, in that case we want to unhide all of the buttons
				for group, col in pairs( self.Groups ) do 

					if ( self.KeyButtons[ group ] ) then 

						self.KeyButtons[ group ]:SetColour( col );

					end

				end

				self.HiddenGroups = {};

			end

		end

		// Draw the name of the group in the group's colour alongside the button to hide it
		local _w, _h = surface.GetTextSize( tostring( group ) );

		self.KeyButtons[ group ]:SetPos( ( w * 0.50 ) - ( self.KeyWidth * 0.50 ) + keySpace - ( _h * 0.50 ) - 2, 19 + ( _h * 0.25 ) );
		self.KeyButtons[ group ]:SetSize( ( _h * 0.50 ), ( _h * 0.50 ) );

		surface.DrawText( tostring( group ) );

		keySpace = keySpace + _w + 10 + ( _h * 0.50 ); 

	end

	// Colour for the title seperator (line between the group key and title)
	surface.SetDrawColor( 0, 0, 0, 255 );
	surface.SetTextColor( 0, 0, 0, 255 );

	// Title seperator
	surface.DrawRect( ( w * 0.50 ) - ( self.KeyWidth * 0.50 ) + 10, 17, self.KeyWidth - 20, 1 );

	// Draw the title text
	draw.SimpleText( self:GetTitle(), "LineGraphKeyFont", ( w * 0.50 ), 9, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );

	// Draw the paused text if the panel's paused currently
	if ( self.Paused ) then 

		// Draw the title text
		draw.SimpleText( "Right click to un-pause (-" .. self:GetMissedFrames() .. ")", "LineGraphKeyFont", self.bX + ( ( w - self.bX ) * 0.50 ), self.bY + ( ( h - self.bY ) * 0.40 ), Color( 120, 120, 120 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );

	end

end

function panel:Paint( w, h )

	self.bX, self.bY = 35, 35

	self.linePaddingX = ( h - self.bY * 2 ) / ( #self.VerticalLines - 1 );
	self.linePaddingY = ( w - self.bX * 2 ) / ( #self.HorizontalLines - 1 )

	self:PaintBackground( w, h );

	self:PaintVerticalLines( w, h );
	self:PaintHorizontalLines( w, h );

	self:PaintData( w, h );

	self:PaintInfo( w, h );

end


function panel:SetYRange( min, max, increment )
	
	self.VerticalLines = {};

	for i = min, max, increment do

		table.insert( self.VerticalLines, i );

	end
	
	self.YMin = math.min( max, min );
	self.YMax = math.max( max, min );
	self.YIncrement = increment;

end

function panel:SetXRange( min, max, increment )

	self.HorizontalLines = {};

	for i = min, max, increment do

		table.insert( self.HorizontalLines, i );

	end
	
	self.XMin = math.min( max, min );
	self.XMax = math.max( max, min );
	self.XIncrement = increment;

end

function panel:AddPoint( group, value, ispc )

	if ( !self.Paused ) then 

		// If the point wasn't added from the unpause timer and points are being added
		// By that timer, add the point after the timer has finished

		self.Data[ group ] = self.Data[ group ] or {};
		table.insert( self.Data[ group ], { value = value, button = nil } );

	else 

		self.PauseCache[ group ] = self.PauseCache[ group ] or {};
		table.insert( self.PauseCache[ group ], value );

	end

end

function panel:AddPointAndPushback( group, value, ispc )

	if ( ( self.Data[ group ] && #self.Data[ group ] >= self.XMax && self.XMax != 0 ) && !self.Paused ) then 

		if ( self.Data[ group ][ 1 ].button ) then self.Data[ group ][ 1 ].button:Remove(); end

		table.remove( self.Data[ group ], 1 );

	end

	self:AddPoint( group, value, ispc );

end

function panel:SetupGroup( name, col )

	// Check the width of the group so we don't need to do looping in the Paint hook later on
	surface.SetFont( "LineGraphKeyFont" );							
	self.KeyWidth = self.KeyWidth + surface.GetTextSize( tostring( name ) ) + 10;

	self.Groups[ name ] = col;

end

// Returns the amount of frames missed because it's paused
function panel:GetMissedFrames()

	for group, data in pairs( self.PauseCache ) do 

		return #data;

	end

	return 0;

end

function panel:OnMousePressed( x, y )

	if ( !input.IsMouseDown( MOUSE_RIGHT ) ) then return; end

	if ( self.Paused ) then 

		self.Paused = false;
		self.PausedColour = Color( 27, 27, 27, 150 );

		for group, data in pairs( self.PauseCache ) do 

			local i = 0;
			for key, value in pairs( data ) do 

				timer.Simple( 0.1 * i, function()

					self:AddPointAndPushback( group, value, true ); 

				end);
				i = i + 1;

			end

			self.PauseCache[ group ] = nil

		end

	else 

		self.Paused = true;
		self.PausedColour = Color( 0, 0, 0, 0 );

	end

end

vgui.Register( DBugR.Prefix .. "LineGraph", panel, "DPanel" );
