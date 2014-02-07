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

function panel:Init(  )

	self.DownloadCache = {};

	// Log browser, contains all the log files and directories on both server and client
	self.LogBrowser = vgui.Create( DBugR.Prefix .. "LogView", self );
	self.LogBrowser:SetPos( 2, 2 );
	self.LogBrowser.FileBrowser:SetMultiSelect( false );
	self.LogBrowser.FileBrowser.OnRowSelected = function( panel, line, p_line )

		self.DownloadButton:SetDisabled( p_line:GetValue( 4 ) == "Yes" || self.DownloadCache[ p_line:GetValue( 1 ) ] );
		self.DeleteButton:SetDisabled( p_line:GetValue( 4 ) != "Yes" );
		self.ArchiveButton:SetDisabled( p_line:GetValue( 5 ) == "Yes" );
		self.UnArchiveButton:SetDisabled( p_line:GetValue( 5 ) != "Yes" );
		self.ViewLogButton:SetDisabled( p_line:GetValue( 4 ) != "Yes" )

		self.SelectedFolder = panel:GetParent().SelectedFolder;
		self.SelectedFile   = p_line:GetValue( 1 );
		self.SelectedPanel = p_line;

		self.Selected = self.SelectedFolder .. "/" .. self.SelectedFile;

	end

	// List of currently active downloads
	self.DownloadList = vgui.Create( "DListView", self );
	self.DownloadList:AddColumn( "Name" );
	self.DownloadList:AddColumn( "Size" );
	self.DownloadList:AddColumn( "Remaining" );
	self.DownloadList:AddColumn( "Downloaded" );
	self.DownloadList:AddColumn( "Speed" );

	// Contains buttons
	self.BContainer = vgui.Create( "Panel", self );

	// Downloads the selected file, if it doesn't exist on the client
	self.DownloadButton = self.BContainer:Add( vgui.Create( DBugR.Prefix .. "FlatButton", self ) );
	self.DownloadButton:SetText( "Download File" );
	self.DownloadButton.DoClick = function( panel )

		self:ResetButtons();

		// Send the file request to the server
		net.Start( DBugR.Prefix .. "RequestLog" );
			net.WriteString( self.Selected );
		net.SendToServer();

		// Strip the size from the DListView so we don't need to fetch it from the server
		local size = tonumber( self.SelectedPanel:GetValue( 3 ):sub( 1, self.SelectedPanel:GetValue( 3 ):len() - 2 ) );

		// Add a template line to the download list
		self.DownloadCache[ self.Selected ] = { size = size * 1024, 
												remaining = size * 1024, 
												downloaded = 0,
												speed = 0,
												lpacket = SysTime(),
												panel = self.DownloadList:AddLine( self.Selected, size .. "kb", size .. "kb", "0kb", "0kb/s" ) };

	end

	// Deletes the selected file, if it exists on the client
	self.DeleteButton = self.BContainer:Add( vgui.Create( DBugR.Prefix .. "FlatButton", self ) );
	self.DeleteButton:SetText( "Delete Log" );
	self.DeleteButton.DoClick = function( panel )

		file.Delete( "dbugr/" .. ( self.LogBrowser.SelectedDomain and "sv_" or "cl_" ) .. "logs/" .. self.Selected, "DATA" );

		// Remove the file from the loggers file cache so it's not attemptedly re-added when we call the LoggerPurge hook
		DBugR.Logger.FileStructure[ self.SelectedFolder ][ self.SelectedFile ] = nil;

		// Upate log views, make sure they know a file was just deleted.
		hook.Run( DBugR.Prefix .. "OnLoggerPurge" );

		self:ResetButtons();

	end

	// Pressing this will add the log to the archive (a list of files that aren't automatically deleted over time)
	self.ArchiveButton = self.BContainer:Add( vgui.Create( DBugR.Prefix .. "FlatButton", self ) );
	self.ArchiveButton:SetText( "Add to Archive" );
	self.ArchiveButton.DoClick = function( panel )

		self.LogBrowser.FileBrowser:GetLine( self.LogBrowser.FileBrowser:GetSelectedLine() ):SetValue( 5, "Yes" );
		self.ArchiveButton:SetDisabled( true );
		self.UnArchiveButton:SetDisabled( false );

		DBugR.ArchiveHandler.Archive( self.Selected );

	end

	// Pressing this will attempt to remove the archived file from the archive
	self.UnArchiveButton = self.BContainer:Add( vgui.Create( DBugR.Prefix .. "FlatButton", self ) );
	self.UnArchiveButton:SetText( "Remove from Archive" );
	self.UnArchiveButton.DoClick = function( panel )

		self.LogBrowser.FileBrowser:GetLine( self.LogBrowser.FileBrowser:GetSelectedLine() ):SetValue( 5, "No" );
		self.ArchiveButton:SetDisabled( false );
		self.UnArchiveButton:SetDisabled( true );

		DBugR.ArchiveHandler.Remove( self.Selected );

	end

	// Pressing this button will load the selected log from the LogBrowser, the LoadLog function in the LogProvider will not error if the log was not found and wil continue to do nothing
	self.ViewLogButton = self.BContainer:Add( vgui.Create( DBugR.Prefix .. "FlatButton", self ) );
	self.ViewLogButton:SetText( "View Log" );
	self.ViewLogButton.DoClick = function( panel )

		self.GoLiveButton:SetDisabled( !DBugR.LogProvider.LoadLog( self.Selected or "" ) );

	end

	// Pressing this button will stop viewing logs and go back to showing live data
	self.GoLiveButton = self.BContainer:Add( vgui.Create( DBugR.Prefix .. "FlatButton", self ) );
	self.GoLiveButton:SetText( "Go Live" );
	self.GoLiveButton.DoClick = function( panel )

		DBugR.LogProvider.GoLive();

		self.GoLiveButton:SetDisabled( true );

	end

	self:ResetButtons();

	// == HOOKS == //
	hook.Add( DBugR.Prefix .. "OnLogBuffered", self, self.OnFileBuffered );
	hook.Add( DBugR.Prefix .. "OnLogDownloaded", self, self.OnFileDownloaded );

end

function panel:ResetButtons()

	self.DownloadButton:SetDisabled( true );
	self.DeleteButton:SetDisabled( true );
	self.ArchiveButton:SetDisabled( true );
	self.UnArchiveButton:SetDisabled( true );
	self.ViewLogButton:SetDisabled( true );
	self.GoLiveButton:SetDisabled( !DBugR.LogProvider.IsLogProviding );

end

function panel:PerformLayout()

	self.LogBrowser:SetSize( ( self:GetWide() * 0.50 ) - 4, self:GetTall() - 4 );
	
	self.BContainer:SetPos( self:GetWide() * 0.50, ( self:GetTall() - ( #self.BContainer:GetChildren() + 2 ) * 30 ) );
	self.BContainer:SetSize( self:GetWide() * 0.50 - 4, ( #self.BContainer:GetChildren() + 2 ) * 30 );

	for k, panel in pairs( self.BContainer:GetChildren() ) do 

		panel:SetPos( 0, 32 * k );
		panel:SetSize( self:GetWide() * 0.50, 30 );

	end

	self.DownloadList:SetPos( ( self:GetWide() * 0.50 ), 26 );
	self.DownloadList:SetSize( ( self:GetWide() * 0.50 ) - 4, self:GetTall() - self.BContainer:GetTall() )

end

function panel:OnFileBuffered( name, buf )

	if ( self.DownloadCache[ name ] ) then 

		local c = self.DownloadCache[ name ];

		local speed = ( buf:len() / 1024 ) * ( 1 / ( SysTime() - c.lpacket ) );

		c.remaining  = c.remaining - buf:len();
		c.downloaded = c.downloaded + buf:len();
		c.lpacket 	 = SysTime();

		self.DownloadCache[ name ].panel:SetValue( 3, math.ceil( c.remaining / 1024 ) .. "kb" );
		self.DownloadCache[ name ].panel:SetValue( 4, math.ceil( c.downloaded / 1024 ) .. "kb" );
		self.DownloadCache[ name ].panel:SetValue( 5, math.ceil( speed ) .. "kb/s" );

	end

end

function panel:OnFileDownloaded( name, buf )

	if ( self.DownloadCache[ name ] ) then 

		print(name, " removed");
		file.Write( name, buf, "DATA" );

		// Remove the line
		self.DownloadList:RemoveLine( self.DownloadCache[ name ].panel:GetID() );
		self.DownloadCache[ name ] = nil;

		// Call the hook to refresh LogViews
		hook.Run( DBugR.Prefix .. "OnLoggerPurge" );

	end

end

function panel:Paint( w, h )

	draw.RoundedBox( 4, 0, 0, w, h, Color( 240, 240, 240 ) );

end

vgui.Register( DBugR.Prefix .. "VirtualizationWindow", panel, "DPanel" );