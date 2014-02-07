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

	// The font we'll be drawing in
	self.Font = "default";

	// The text we'll be drawing
	self.Text = "";

	// Pixels between letters
	self.Padding = 5;

end

function panel:SetFont( font )

	self.Font = tostring( font ) or "default";

end

function panel:SetText( text )

	self.Text = tostring( text ) or "";

end

function panel:SetPadding( padding )

	self.Padding = padding;

end

function panel:Paint( w, h )

	surface.SetFont( self.Font );
	surface.SetTextColor( 0, 0, 0 );

	local y = 0;

	for i = 1, self.Text:len() do 

		local tw, th = surface.GetTextSize( self.Text[ i ] );

		if ( y == 0 ) then y = ( th * 0.50 ) + 3; end

		surface.SetTextPos( 2, y );
		surface.DrawText( self.Text[ i ] );

		y = y + th + self.Padding;

	end

end

vgui.Register( DBugR.Prefix .. "VerticalText", panel, "EditablePanel" );
