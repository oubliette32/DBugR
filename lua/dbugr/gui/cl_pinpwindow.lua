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

	self.DomainTabs = vgui.Create( DBugR.Prefix .. "TabControl", self );
	self.DomainTabs:SetButtonParent( DBugR.Menu.Panel );

	self.DataHandlers = {};

	self:AddDataHandler( "Server-N", SERVICE_PROVIDER_TYPE_NET, STATE_SERVER );
	self:AddDataHandler( "Server-P", SERVICE_PROVIDER_TYPE_CPU, STATE_SERVER );
	self:AddDataHandler( "Client-N ", SERVICE_PROVIDER_TYPE_NET, STATE_CLIENT );
	self:AddDataHandler( "Client-P", SERVICE_PROVIDER_TYPE_CPU, STATE_CLIENT );

	// Will contain our function code, if any is requested
	self.CodeText = vgui.Create( DBugR.Prefix .. "LuaView", self );
	self.CodeText:SetPos( 4, 24 );

	// Will contain information about the function code we requested
	self.InfoLabel = vgui.Create( "DLabel", self );
	self.InfoLabel:SetPos( 4, 0 );

	self.InfoLabel:SetTextColor( Color( 0, 0, 0 ) );
	self.InfoLabel:SetText("");
	self.InfoLabel:SetContentAlignment( 5 );

	// Add a OnData hook for this panel to update the list
	hook.Add( DBugR.Prefix .. "OnData", tostring(self), function( ... ) 

		if (self.OnDataReceived) then 
		
			self:OnDataReceived( ... ) 

		end 

	end);

	// Hook FunctionCodeStream to this panel
	net.Receive( DBugR.Prefix .. "FunctionCodeStream", function( len ) 

		self.CodeText:AppendText( net.ReadString() .. '\n' );

	end);

end

function panel:AddDataHandler( name, typ, state )

	local p = vgui.Create( "DPanel", self.DomainTabs );

	p.List = vgui.Create( "DListView", p );
	p.List:SetMultiSelect( false );
	p.List.LineCache = {};

	// The column layout differs from data type, network service providers only tell us about the channel name and data sent
	if ( typ == SERVICE_PROVIDER_TYPE_NET ) then 

		p.List:AddColumn( "Type" );
		p.List:AddColumn( "Channel" );
		p.List:AddColumn( "Size" );
		p.List:AddColumn( "Time" );

	elseif ( typ == SERVICE_PROVIDER_TYPE_CPU ) then 

		p.List:AddColumn( "Type" );
		p.List:AddColumn( "Name" );
		p.List:AddColumn( "Value (Total)" );
		p.List:AddColumn( "Calls p/s" );
		p.List:AddColumn( "Time" );

		p.List.OnRowSelected = function( panel, line )

			local data = panel:GetLine( line ).data or false;

			if ( data && data.loc && data.start && data.finish ) then 

				self.CodeText:SetText( "" );
				self.InfoLabel:SetText( "Source : " .. data.loc .. "    Line : " .. data.start .. "    Size : " .. ( data.finish - data.start ) .. " (lines)" );

				net.Start( DBugR.Prefix .. "RequestFunctionCode" );

					net.WriteString( data.loc );
					net.WriteInt( data.start, 32 );
					net.WriteInt( data.finish, 32 );

				net.SendToServer();

			end

		end

	else 

		error( "LAYOUT ERROR! attempted to create list view layout for non-existant service provider type '" .. tostring( typ ) .. "'" );

	end

	p.PerformLayout = function( panel )

		panel.List:SetPos( 4, 4 );
		panel.List:SetSize( panel:GetWide() - 8, self:GetTall() - 8 );

	end

	self.DataHandlers[ typ ] = self.DataHandlers[ typ ] or {};
	self.DataHandlers[ typ ][ name ] = { panel = p, state = state } ;

	self.DomainTabs:AddTab( name, p );

end

function panel:PerformLayout()

	self.DomainTabs:SetPos( self:GetWide() * 0.50 + 4, 0 );
	self.DomainTabs:SetSize( self:GetWide() * 0.50 - 4, self:GetTall() );

	self.CodeText:SetSize( self:GetWide() * 0.50 - 12, self:GetTall() - 28 );
	self.InfoLabel:SetSize( self:GetWide() * 0.50 - 4, 24 );

end

function panel:Paint( w, h )

	draw.RoundedBox( 4, 0, 0, w * 0.50 - 4, h, Color( 240, 240, 240 ) );

end

// Adds a line to a DListView, if panel.LineCache exists this function will check there for the line name
// If the line name was found, it will edit that line rather than adding a new one.
function panel:AddLine( name, panel, ... )

	if ( !panel.LineCache || !panel.LineCache[ name ] ) then 

		panel.LineCache = panel.LineCache or {};
		panel.LineCache[ name ] = panel:AddLine( ... );

	else 

		for k, v in pairs( { ... } ) do 

			panel.LineCache[ name ]:SetColumnText( k, v ); 

		end  

	end

	return panel.LineCache[ name ];

end

function panel:OnDataReceived( typ, name, state, data )

	if ( !self.DataHandlers[ typ ] || !istable( self.DataHandlers[ typ ] ) ) then return; end 

	for _, _data in pairs( self.DataHandlers[ typ ] ) do 

		if ( !_data.panel ) then continue; end
		if ( _data.state != state ) then continue; end

		local panel = _data.panel;

		for _name, data in pairs( data ) do

			if ( typ == SERVICE_PROVIDER_TYPE_NET ) then 

				self:AddLine( _name, panel.List, name, _name, data, os.date() ).data = data;

			elseif ( typ == SERVICE_PROVIDER_TYPE_CPU ) then 

				self:AddLine( _name, panel.List, name, _name, math.Round( data.total, 4 ), data.calls, os.date() ).data = data;

			end

		end

	end

end

vgui.Register( DBugR.Prefix .. "PinpointingWindow", panel, "DPanel" );