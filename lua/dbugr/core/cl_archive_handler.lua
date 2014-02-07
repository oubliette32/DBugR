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

/*

	Simply saves a list of strings.  Those strings are names of files, that won't be deleted automatically in the logger.

*/

DBugR.ArchiveHandler = {};

function DBugR.ArchiveHandler.Archive( str )

	local t = DBugR.ArchiveHandler.Get();
	t[ str ] = true;

	DBugR.Util.IO.Write( "dbugr/archive.txt", "w", t );

end 

function DBugR.ArchiveHandler.Remove( str )

	local t = DBugR.ArchiveHandler.Get();
	t[ str ] = nil;

	DBugR.Util.IO.Write( "dbugr/archive.txt", "w", t );

end 

function DBugR.ArchiveHandler.IsArchived( str )

	return DBugR.ArchiveHandler.Get()[ str ];

end

function DBugR.ArchiveHandler.Get( )

	return file.Exists( "dbugr/archive.txt", "DATA" ) and DBugR.Util.IO.Read( "dbugr/archive.txt" ) or {};

end
