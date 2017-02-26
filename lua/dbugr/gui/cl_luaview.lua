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

surface.CreateFont( DBugR.Prefix .. "LuaViewFont", {
 	ont = "Courier New",
	size = 14,
	weight = 600
});

local keywords = {

	 // Loops
	["while"] 	= Color( 0, 0, 255 ),
	["for"] 	= Color( 0, 0, 255 ),
	["do"] 		= Color( 0, 0, 255 ),
	["until"] 	= Color( 0, 0, 255 ),
	["repeat"] 	= Color( 0, 0, 255 ),
	["in"]		= Color( 0, 0, 255 ),
	["continue"]= Color( 0, 0, 255 ),
	["break"] 	= Color( 0, 0, 255 ),

	// Params
	["end"] 	= Color( 0, 0, 255 ),
	["then"] 	= Color( 0, 0, 255 ),

	// Conditionals
	["if"] 		= Color( 0, 0, 255 ),
	["else"] 	= Color( 0, 0, 255 ),
	["elseif"] 	= Color( 0, 0, 255 ),
	["and"] 	= Color( 0, 0, 255 ),
	["or"]		= Color( 0, 0, 255 ),
	["not"]		= Color( 0, 0, 255 ),

	// Function
	["function"] = Color( 0, 0, 255 ),
	["return"]	= Color( 0, 0, 255 ),

	// Other
	["local"]	= Color( 0, 0, 255 ),
	["true"]	= Color( 0, 0, 255 ),
	["false"]	= Color( 0, 0, 255 ),

}

function panel:Init()

	self.RichText = vgui.Create( "RichText", self );
	self.RichText:SetPos( 0, 0 );

	self.RichText.Paint = function( panel )

	    panel.m_FontName = DBugR.Prefix .. "LuaViewFont"
	    panel:SetFontInternal( DBugR.Prefix .. "LuaViewFont" )	
	    panel:SetBGColor( Color( 0, 0, 0, 0 ) );
	    panel.Paint = nil

	end

	self.LuaBlockCommentOpen 	= false;
	self.CBlockCommentOpen 		= false;

end

function panel:SetText( t )

	self.RichText:SetText( t );

end

function panel:AppendText( t )

	local inserts = { [ 1 ] = self.LuaBlockCommentOpen or self.CBlockCommentOpen and Color( 0, 200, 0 ) or Color( 0, 0, 0 ) };

	for s, e in pairs( { ["%-%-"] = '\n', ["%/%/"] = '\n', ["%/%*"] = "%*%/", ["%-%-%[%["] = "%]%]" } ) do 

		local f = string.find( t, s );

		if ( f ) then 

			if ( s == "%/%*" ) then 

				self.CBlockCommentOpen = true;

			elseif ( s == "%-%-%[%[" ) then 

				self.LuaBlockCommentOpen = true;

			else 

				inserts[ f ] = Color( 0, 200, 0 );

			end

			local fin = string.find( t, e, f + 1 );

			if ( fin ) then 

				if ( e == "%*%/" ) then 

					self.CBlockCommentOpen = false;

				elseif ( e == "%]%]" ) then 

					self.LuaBlockCommentOpen = false;

				else 

					inserts[ fin ] = Color( 0, 0, 0 );

				end

			end

		end

	end

	if ( !self.LuaBlockCommentOpen && !self.CBlockCommentOpen ) then 

		// Keywords
		local l = 0;
		for word, pos in string.gfind( t, "%a+" ) do 

			if ( keywords[ word ] ) then 

				l = string.find( t, word, l );
				local t = true;

				for i = l, 0, -1 do 

					if ( inserts[ i ] and inserts[ i ].g == 200 ) then t = false; break; end

				end

				if ( t ) then 

					inserts[ l ] = keywords[ word ];
					inserts[ l + word:len() ] = Color( 0, 0, 0 );

				end

			end

		end

	end

	if ( !t ) then return; end

	// Build the text char by char, inserting color changes where possible
	for i = 1, t:len() do 

		if ( inserts[ i ] ) then 

			self.RichText:InsertColorChange( inserts[ i ].r, inserts[ i ].g, inserts[ i ].b, inserts[ i ].a );

		end

		self.RichText:AppendText( t[ i ] );

	end

	//self.RichText:AppendText( '\n' );

end

function panel:PerformLayout()
	
	self.RichText:SetSize( self:GetSize() );

end

function panel:OnMousePressed()

end 

function panel:OnMouseReleased()

end 

function panel:OnCursorEntered()

end 

function panel:OnCursorExited()

end 

function panel:OnCursorMoved()

end

vgui.Register( DBugR.Prefix .. "LuaView", panel, "DPanel" );
