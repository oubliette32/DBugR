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

	self.Tabs = {};

	self.Built 	= true; 	-- If this is false, it will switch the first tab when PerformLayout is called
	self.ButtonParent = self;
end

function panel:AddTab( name, panel )

	self.Tabs[ #self.Tabs + 1 ] = { Name = name, Panel = panel, Button = nil };
	self.Built = false;

	panel:SetVisible( false );

end

function panel:SetButtonParent( p )

	self.ButtonParent = p;

end

function panel:AlertChildren( panel, ... )

	for _, p in pairs( panel:GetChildren() ) do 

		if ( p.OnAlert ) then p:OnAlert( ... ) end 
		if ( #p:GetChildren() != 0 ) then self:AlertChildren( p, ... ); end

	end

end

function panel:PerformLayout()

	for i = 1, #self.Tabs do 

		local tab = self.Tabs[ i ];

		local x, y = 0, 0;
		local p = self;

		while ( p && ValidPanel( p ) ) do

			if ( p == self.ButtonParent ) then break; end

			x = x + p.x;
			y = y + p.y;
			p = p.GetParent and p:GetParent();

		end

		if ( !tab.Button ) then 

			tab.Button = vgui.Create( DBugR.Prefix .. "FlatButton", self.ButtonParent );

		end

		local lastWidth = self.Tabs[ i - 1 ] and self.Tabs[ i - 1 ].Button:GetWide() or 0;
		local lastX = self.Tabs[ i - 1 ] and self.Tabs[ i - 1 ].Button.x - x or 30;

		tab.Button:SetPos( x + lastX + lastWidth, y - ( self.ButtonParent != self and 30 or 0 ) );
		tab.Button:SetSize( x, 30 );
		tab.Button:SizeToContentsX( 20 );
		
		tab.Button:SetText( tab.Name );

		tab.Button.DoClick = function()

			for _, tab in pairs( self.Tabs ) do 

				if ( tab.Panel ) then 

					tab.Panel:SetVisible( false );
					self:AlertChildren( tab.Panel, false );

					tab.Button:SetToggled( false );

				end

			end 

			tab.Panel:SetVisible( true );
			self:AlertChildren( tab.Panel, true );

			tab.Panel:SetPos( 0, self.ButtonParent == self and 30 or 0 );
			tab.Panel:SetSize( self:GetWide(), self:GetTall() - ( self.ButtonParent == self and 30 or 0 ) );
			tab.Button:SetToggled( true );

		end
	
	end

	if ( self.Tabs[ 1 ] && self.Tabs[ 1 ].Button && !self.Built ) then 

		self.Tabs[ 1 ].Button:DoClick( );
		self.Built = true;

	end

end

function panel:OnAlert( vis )

	for i = 1, #self.Tabs do 

		local tab = self.Tabs[ i ];
		if ( tab.Button ) then 

			tab.Button:SetVisible( vis );

		end

	end

end

function panel:Paint()

	// Override

end 

vgui.Register( DBugR.Prefix .. "TabControl", panel, "EditablePanel" );