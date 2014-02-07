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

DBugR.Profilers.Net = table.Copy( DBugR.SP );

DBugR.Profilers.Net.CChan = "";
DBugR.Profilers.Net.Name = "Net";
DBugR.Profilers.Net.Type = SERVICE_PROVIDER_TYPE_NET;

net.Start = DBugR.Util.Func.AddDetour( net.Start, function( name ) 

	DBugR.Profilers.Net.CChan = name;

end);

net.Send = DBugR.Util.Func.AddDetour( net.Send, function( ) 

	DBugR.Profilers.Net:AddNetData( DBugR.Profilers.Net.CChan, net.BytesWritten() );

end);

if ( SERVER ) then 

	net.Broadcast = DBugR.Util.Func.AddDetour( net.Broadcast, function( str ) 

		DBugR.Profilers.Net:AddNetData( DBugR.Profilers.Net.CChan, net.BytesWritten() );

	end);

end