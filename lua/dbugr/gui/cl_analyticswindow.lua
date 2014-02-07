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

function panel:Init()

	self.Graphs = { };
	self.Rows = { };

	hook.Add( DBugR.Prefix .. "OnDatagramUpdate", tostring(self), function( ... ) 

		if (self.OnDataReceieved) then 
		
			self:OnDataReceieved( ... ) 

		end 

	end);

end

function panel:AddGraph( name, row, min, max, inc, ypref, xpref )

	min = min or 0;
	max = max or 1;
	inc = inc or 0.5;

	local graph = vgui.Create( DBugR.Prefix .. "LineGraph", self );

	graph:SetXRange( 30, 1, -1 );
	graph:SetYRange( min, max, inc );

	graph:SetTitle( name );

	graph:SetLinePrefixX( xpref );
	graph:SetLinePrefixY( ypref );

	self.Graphs[ row ][ #self.Graphs[ row ] + 1 ] = graph;

	// We can only support two graphs on the X axis, since as we'll be using horizontal splitters.  We don't need any more than that anyway
	if ( #self.Graphs[ row ] == 2 ) then 

		self.Rows[ row ].Div:SetRight( graph );

	else

		self.Rows[ row ].Div:SetLeft( graph );

	end

end

function panel:GetGraph( row, index )

	return self.Graphs[ row ][ index ];

end

function panel:SetupGroup( row, index, name, col )

	if ( self.Graphs[ row ] && self.Graphs[ row ][ index ] ) then 

		self.Graphs[ row ][ index ]:SetupGroup( name, col );

	end

end

function panel:AddRow( name )

	self.Graphs[ name ] = {};
	self.Rows[ name ] = {};

	local panel = vgui.Create( "DPanel", self );

	local div = vgui.Create( "DHorizontalDivider", panel ); 
	div:Dock( FILL );
	div:SetDividerWidth( 6 );
	div:SetLeftMin( 40 );
	div:SetRightMin( 40 );

	self.Rows[ name ].Panel = panel;
	self.Rows[ name ].Div = div;

	self:PerformLayout();

end

function panel:PerformLayout()

	local rowH = self:GetTall() / table.Count( self.Rows );

	local y = 0;
	for name, row in pairs( self.Rows ) do 

		row.Panel:SetPos( 0, y );
		row.Panel:SetSize( self:GetWide(), rowH - 5 );
		row.Div:SetLeftWidth( self:GetWide() * 0.50 );

		y = y + (rowH - 5) + 10;

	end

end

function panel:OnDataReceieved( row, graph, data, group )

	if ( self.Graphs[ row ][ graph ] ) then 

		if ( self.Graphs[ row ][ graph ].YMax < data ) then 

			self.Graphs[ row ][ graph ]:SetYRange( 0, data, data / 16 );

		end

		self.Graphs[ row ][ graph ]:AddPointAndPushback( group, data );

	end

end 

function panel:Paint( w, h )

	draw.RoundedBox( 4, 0, 0, w, h, Color( 240, 240, 240 ) );

end

vgui.Register( DBugR.Prefix .. "AnalyticsWindow", panel, "DPanel" );