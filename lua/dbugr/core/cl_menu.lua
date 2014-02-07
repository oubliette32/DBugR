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

DBugR.Menu = {};
DBugR.Menu.Panel = nil;

function DBugR.Menu.Create()

	DBugR.Menu.Panel = vgui.Create( "DPanel" );
	DBugR.Menu.Panel:SetSize( ScrW() / 1.2, ScrH() / 1.2 );
	DBugR.Menu.Panel.Paint = function( panel, w, h ) 

		if ( DBugR.LogProvider && DBugR.LogProvider.IsLogProviding ) then 

			draw.SimpleText( "LOG : " .. DBugR.LogProvider.Log .. "\tFRAME : " .. DBugR.LogProvider.Frame, "default", w - 50, 10, Color( 200, 0, 0 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

		end

	end

	DBugR.Menu.DMainTabs = vgui.Create( DBugR.Prefix .. "TabControl", DBugR.Menu.Panel );
	DBugR.Menu.DMainTabs:SetPos( 5, 30 );
	DBugR.Menu.DMainTabs:SetSize( DBugR.Menu.Panel:GetWide() - 10, DBugR.Menu.Panel:GetTall() - 40 );

	DBugR.Menu.CloseButton = vgui.Create( DBugR.Prefix .. "FlatButton", DBugR.Menu.Panel );
	DBugR.Menu.CloseButton:SetPos( DBugR.Menu.Panel:GetWide() - 25, 40 );
	DBugR.Menu.CloseButton:SetSize( 20, 20 );
	DBugR.Menu.CloseButton:SetText( "X" );
	DBugR.Menu.CloseButton.DoClick = DBugR.Menu.Close;

	// -- ANALYTICS TAB -- //
	DBugR.Menu.ProfilerWindow = vgui.Create( DBugR.Prefix .. "AnalyticsWindow", DBugR.Menu.DMainTabs );
	DBugR.Menu.ProfilerWindow:SetPos( 0, 0 );

	DBugR.Menu.ProfilerWindow:AddRow( STATE_CLIENT );
	DBugR.Menu.ProfilerWindow:AddGraph( "Client - Performance", STATE_CLIENT, 0, 1024, 64, "ms/s", "time" );
	DBugR.Menu.ProfilerWindow:AddGraph( "Client - Networking (Outgoing)", STATE_CLIENT, 0, 1024, 64, "B/s", "time" );

	DBugR.Menu.ProfilerWindow:AddRow( STATE_SERVER );
	DBugR.Menu.ProfilerWindow:AddGraph( "Server - Performance", STATE_SERVER, 0, 1024, 64, "ms/s", "time" );
	DBugR.Menu.ProfilerWindow:AddGraph( "Server - Networking (Outgoing)", STATE_SERVER, 0, 1024, 64, "B/s", "time" );

	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_CLIENT, 1, "Hooks", 		DBUGR_GRAPH_COLOR[ "Hooks" ] or Color( 200, 200, 0 ) );
	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_CLIENT, 1, "Timers", 		DBUGR_GRAPH_COLOR[ "Timers" ] or Color( 100, 100, 100 ) );
	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_CLIENT, 1, "Net", 			DBUGR_GRAPH_COLOR[ "Net" ] or Color( 200, 0, 0 ) );
	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_CLIENT, 1, "Usermessages", 	DBUGR_GRAPH_COLOR[ "Usermessages" ] or Color( 0, 200, 0 ) );
	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_CLIENT, 1, "ConCommands", 	DBUGR_GRAPH_COLOR[ "ConCommands" ] or Color( 0, 0, 200 ) );

	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_SERVER, 1, "Hooks", 		DBUGR_GRAPH_COLOR[ "Hooks" ] or Color( 200, 200, 0 ) );
	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_SERVER, 1, "Timers", 		DBUGR_GRAPH_COLOR[ "Timers" ] or Color( 100, 100, 100 ) );
	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_SERVER, 1, "Net", 			DBUGR_GRAPH_COLOR[ "Net" ] or Color( 200, 0, 0 ) );
	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_SERVER, 1, "ConCommands", 	DBUGR_GRAPH_COLOR[ "ConCommands" ] or Color( 0, 0, 200 ) );

	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_CLIENT, 2, "Net", 			DBUGR_GRAPH_COLOR[ "Net" ] or Color( 200, 0, 0 ) );
	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_CLIENT, 2, "ConCommands", 	DBUGR_GRAPH_COLOR[ "ConCommands" ] or Color( 0, 0, 200 ) );

	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_SERVER, 2, "Net", 			DBUGR_GRAPH_COLOR[ "Net" ] or Color( 200, 0, 0 ) );
	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_SERVER, 2, "Usermessages",	DBUGR_GRAPH_COLOR[ "Usermessages" ] or Color( 0, 200, 0 ) );
	DBugR.Menu.ProfilerWindow:SetupGroup( STATE_SERVER, 2, "ConCommands", 	DBUGR_GRAPH_COLOR[ "ConCommands" ] or Color( 0, 0, 200 ) );

	// -- PINPOINTING TAB -- //
	DBugR.Menu.PinpWindow = vgui.Create( DBugR.Prefix .. "PinpointingWindow", DBugR.Menu.DMainTabs );
	DBugR.Menu.PinpWindow:SetPos( 0, 0 );

	// -- SETTINGS TAB -- //
	DBugR.Menu.VirtualizationWindow = vgui.Create( DBugR.Prefix .. "VirtualizationWindow", DBugR.Menu.DMainTabs );
	DBugR.Menu.VirtualizationWindow:SetPos( 0, 0 );
	
	
	// -- COMPARISON TAB -- //
	DBugR.Menu.ComparisonWindow = vgui.Create( DBugR.Prefix .. "ComparisonWindow", DBugR.Menu.DMainTabs );
	DBugR.Menu.ComparisonWindow:SetPos( 0, 0 );

	// --            -- //

	// Add the tabs 
	DBugR.Menu.DMainTabs:AddTab( "Analytics", DBugR.Menu.ProfilerWindow );
	DBugR.Menu.DMainTabs:AddTab( "Pinpointing", DBugR.Menu.PinpWindow );
	DBugR.Menu.DMainTabs:AddTab( "Virtualization", DBugR.Menu.VirtualizationWindow );
	DBugR.Menu.DMainTabs:AddTab( "Comparisons", DBugR.Menu.ComparisonWindow );

end

function DBugR.Menu.Open()

	if ( !hook.Run( DBugR.Prefix .. "PlayerAuth", LocalPlayer() ) ) then 

		DBugR.Print( "Auth failure - You're not authorized to do this." );
		return;
		
	end

	if ( !DBugR.Menu.Panel || !IsValid( DBugR.Menu.Panel ) ) then

		DBugR.Menu.Create();

	end

	DBugR.Menu.Panel:SetVisible( true );
	DBugR.Menu.Panel:MakePopup();
	DBugR.Menu.Panel:Center();

end

function DBugR.Menu.Close()

	if ( !hook.Run( DBugR.Prefix .. "PlayerAuth", LocalPlayer() ) ) then 

		DBugR.Print( "Auth failure - You're not authorized to do this." );
		return;
		
	end

	if ( DBugR.Menu.Panel ) then

		DBugR.Menu.Panel:SetVisible( false );

	end

end

function DBugR.Menu.Dispose()

	if ( DBugR.Menu.Panel ) then

		DBugR.Menu.Panel:Remove( );

	end

end

function DBugR.Menu.Toggle()

	if ( !hook.Run( DBugR.Prefix .. "PlayerAuth", LocalPlayer() ) ) then 

		DBugR.Print( "Auth failure - You're not authorized to do this." );
		return;

	end

	if ( !DBugR.Menu.Panel || IsValid( DBugR.Menu.Panel ) || !DBugR.Menu.Panel:IsVisible() ) then 

		DBugR.Menu.Open(); 

	else

		DBugR.Menu.Close();

	end

end

concommand.Add( "dbugr_menu_toggle", DBugR.Menu.Toggle );
concommand.Add( "dbugr_menu_open", DBugR.Menu.Open );
concommand.Add( "dbugr_menu_close", DBugR.Menu.Close );