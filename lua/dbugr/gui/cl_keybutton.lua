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

	self.Colour = Color( 0, 0, 0 );

end

function panel:SetColour( col )

	self.Colour = col;

end

function panel:OnCursorEntered()

	self:SetCursor( "hand" );

end

function panel:OnCursorExited()

	self:SetCursor( "default" );

end

function panel:OnMousePressed()

	if ( self.DoClick && isfunction( self.DoClick ) && input.IsMouseDown( MOUSE_LEFT ) ) then
	
		self.DoClick( self );	

	end

	if ( self.DoRightClick && isfunction( self.DoRightClick ) && input.IsMouseDown( MOUSE_RIGHT ) ) then
	
		self.DoRightClick( self );	

	end

end

function panel:Paint( w, h )

	surface.SetDrawColor( self.Colour );
	surface.DrawRect( 0, 0, w, h ); 

end

vgui.Register( DBugR.Prefix .. "KeyButton", panel, "DPanel" );