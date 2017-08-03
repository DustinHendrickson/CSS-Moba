



//	SayText2(id,id,"\x01oneAlwaysStartWhite\x02two\x03threeTEAM\x04fourGreen\x05fiveLightGreen");

stock SayText2( client_index , author_index , const String:message[],any:... ) {
	decl String:buf[512];
	VFormat(buf, 512, message, 4); 
	new Handle:buffer = StartMessageOne("SayText2", client_index);
	if (buffer != INVALID_HANDLE) {
		BfWriteByte(buffer, author_index);
		BfWriteByte(buffer, true);	
		BfWriteString(buffer, buf);	
		EndMessage();
	}
}  



//Admin Access?
stock bool:HasAdminAccess(client,AdminFlag:flag){

	static 	AdminId:AdminID;
	AdminID = GetUserAdmin(client);
	if (AdminID!=INVALID_ADMIN_ID && GetAdminFlag( AdminID, flag ) ){
		return true;
	}
	return false;
}

//Connected and InGame
stock bool:ValidPlayer(client){
	return (client>0&&IsClientConnected(client)&&IsClientInGame(client))?true:false;
}