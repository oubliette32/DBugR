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

surface.CreateFont( "FlatButtonFont", { font = "Arial", size = 14, weight = 600 } );

function panel:Init()

	self.IdleColour = Color( 200, 200, 200 );
	self.HoverColour = Color( 0, 150, 150 );
	self.ToggledColour = Color( 241, 241, 241 );

	self.IsToggled = false;

	self:SetFont( "FlatButtonFont" );

end

function panel:SetToggled( state )

	self.IsToggled = state;

end

function panel:Paint( w, h )

	local col = self.IdleColour
	if ( self.Hovered ) then 

		col = self.HoverColour

	elseif ( self.IsToggled ) then 

		col = self.ToggledColour;

	end

	if ( self:GetDisabled() ) then col = Color( 99, 99, 99 ); end
 
	surface.SetDrawColor( col );
	surface.DrawRect( 0, 0, w, h ); 

end

vgui.Register( DBugR.Prefix .. "FlatButton", panel, "DButton" );