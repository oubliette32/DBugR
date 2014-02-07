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
	                              \$$$$$$  |          how do
	                               \______/           

	* Copyright (C) 2013 - All Rights Reserved
	* Unauthorized copying of this file, via any medium is strictly prohibited
	* Written by Oubliette <oubliette32@gmail.com>, 2013

	* Version 2.0

*/

local panel = {};

function panel:Init()

	self.SelectedFolder = "";
	self.SelectedDomain = false;

	self.DirIndices = {};

	// == LAYOUT == //

	self.DirBrowser = vgui.Create( "DComboBox", self );
	self.DirBrowser:SetPos( 2, 2 );
	self.DirBrowser:SetSize( 100, 20 );

	self.DomBrowser = vgui.Create( "DComboBox", self );
	self.DomBrowser:SetPos( 102, 2 );
	self.DomBrowser:SetSize( 100, 20 );
	self.DomBrowser:SetValue( "Client" );

	self.FileBrowser = vgui.Create( "DListView", self );
	self.FileBrowser:SetPos( 2, 24 );

	self.FileBrowser:AddColumn( "Filename" );
	self.FileBrowser:AddColumn( "Domain" );
	self.FileBrowser:AddColumn( "Size" );
	self.FileBrowser:AddColumn( "Downloaded" );
	self.FileBrowser:AddColumn( "Archived" );
	
	self.DomBrowser:AddChoice( "Server" );
	self.DomBrowser:AddChoice( "Client" );

	// == CALLBACKS == //

	self.DomBrowser.OnSelect = function( panel, index, value, data )

		if ( index == 1 ) then 

			self.SelectedDomain = true;

		elseif ( index == 2 ) then 

			self.SelectedDomain = false;

		end

		if ( self.SelectedFolder && self.SelectedFolder != "" ) then 

			self:RePopulate( false );

		end

	end

	self.DirBrowser.OnSelect = function( panel, index, value, data )

		self.SelectedFolder = self.DirIndices[ index ];
		self:RePopulate( false );

	end

	self:RePopulate( true );

	// == HOOKS == //

	hook.Add( DBugR.Prefix .. "OnLoggerFile", self, function( panel, dir, f ) 

		self:OnNewFile( dir, f );

	end);

	hook.Add( DBugR.Prefix .. "OnLoggerPurge", self, function( panel, dir, f ) 

		self:RePopulate( false )

	end);


end

function panel:RePopulate( doDir )

	self.FileBrowser:Clear();
	for f, s in pairs( DBugR.Logger.FileStructure[ self.SelectedFolder ] or {} ) do 

		if ( s and !self.SelectedDomain ) then continue; end
		if ( !s and self.SelectedDomain ) then continue; end

		local size 		= s or file.Size( DBUGR_CL_LOGPATH .. self.SelectedFolder .. "/" .. f, "DATA" );
		local domain 	= self.SelectedDomain and "Server" or "Client";
		local exists 	= file.Exists( DBUGR_CL_LOGPATH .. self.SelectedFolder .. "/" .. f, "DATA" ) or file.Exists( DBUGR_SV_LOGPATH .. self.SelectedFolder .. "/" .. f, "DATA" );
		local archived 	= DBugR.ArchiveHandler.IsArchived( self.SelectedFolder .. "/" .. f );

		size = math.Round( size / 1024 );

		self.FileBrowser:AddLine( f, domain, size .. "kb", exists and "Yes" or "No", archived and "Yes" or "No" );

	end

	if ( doDir ) then 

	 	self.DirBrowser:Clear();
		for dir, t in pairs( DBugR.Logger.FileStructure ) do 

			self.DirIndices[ self.DirBrowser:AddChoice( dir ) ] = dir;

		end

	end

end

function panel:PerformLayout()

	self.FileBrowser:SetSize( self:GetWide() - 4, self:GetTall() - 28 );

end

function panel:OnNewFile( dir, f )

	if ( self.SelectedFolder == dir ) then 

		local s = DBugR.Logger.FileStructure[ dir ][ f ];

		if ( s and !self.SelectedDomain ) then return; end
		if ( !s and self.SelectedDomain ) then return; end

		local size = s and s or file.Size( DBUGR_CL_LOGPATH .. dir .. "/" .. f, "DATA" );
		local exists 	= file.Exists( DBUGR_CL_LOGPATH .. self.SelectedFolder .. "/" .. f, "DATA" ) or file.Exists( DBUGR_SV_LOGPATH .. self.SelectedFolder .. "/" .. f, "DATA" );
		local archived 	= DBugR.ArchiveHandler.IsArchived( self.SelectedFolder .. "/" .. f );

		size = math.Round( size / 1024 );

		self.FileBrowser:AddLine( f, s and "Server" or "Client", size .. "kb", exists and "Yes" or "No", archived and "Yes" or "No" );

	end

end


function panel:Paint()

	// Override

end

vgui.Register( DBugR.Prefix .. "LogView", panel, "DPanel" );