------------------------------------- VARIABLES ---------------------------------------
CHATKEYSNAME = "ChatKeys";
CHATKEYSVERS = "3.0";
CKSETTINGS = GetCVar("realmName")..UnitName("player");
------- valeurs par defaut
local defBuddyName = "";
local defChannelName1 = "";
local defChannelName2 = "";
local defChannelName3 = "";
local defSound = 1;
local defPartyNum = 1;
-------
ChatKeysSaved = {};
ChatKeysSaved[CKSETTINGS] = {};
ChatKeysDatas = {};
-------
local interlocuteur = "";
local ck_enTest = false;

---------------------------------------------------------------------------------------
-------------------------- CHARGEMENT / COMMANDES /BINDINGS ---------------------------
function chargementChatKeys()
	------------- slash commandes
	SlashCmdList["CK_SHOWUI"] = ChatKeysOptions;
		SLASH_CK_SHOWUI1 = "/chatkeys";
	SlashCmdList["CK_HELP"] = ckHelp;
		SLASH_CK_HELP1 = "/chatkeyshelp";
	SlashCmdList["CK_DEBUG"] = ckDebug;
		SLASH_CK_DEBUG1 = "/ckx";
	SlashCmdList["BLOTEST"] = ckTest;
		SLASH_CK_TEST1 = "/cktest";

	-------------- bindings
	BINDING_HEADER_CHATKEYS = CHATKEYSNAME
	
	BINDING_NAME_SAYMESSAGE = BIND_NAME_SAY
	BINDING_NAME_YELLMESSAGE = BIND_NAME_YELL
	BINDING_NAME_PARTYMESSAGE = BIND_NAME_PARTY
	BINDING_NAME_RAIDMESSAGE = BIND_NAME_RAID
	BINDING_NAME_BGDEFMESSAGE = BIND_NAME_DEFBG
	BINDING_NAME_RWRAIDMESSAGE = BIND_NAME_RWRAID
	BINDING_NAME_GUILDMESSAGE = BIND_NAME_GUILD
	BINDING_NAME_GUILDOFFMESSAGE = BIND_NAME_GUILDOFFICER
	
	BINDING_NAME_GENERALMESSAGE = GENERALCHANNELNAME
	BINDING_NAME_TRADEMESSAGE = TRADECHANNELNAME
	--BINDING_NAME_DEFENSEMESSAGE = DEFENSECHANNELNAME
	BINDING_NAME_GROUPMESSAGE = GROUPCHANNELNAME

	BINDING_NAME_SHOWCHATUI = BIND_NAME_CHATUI
	BINDING_NAME_CUSTOMMESSAGE = BIND_NAME_CUSTOM
	BINDING_NAME_CUSTOMCHANNEL1 = BIND_NAME_CHANNEL1
	BINDING_NAME_CUSTOMCHANNEL2 = BIND_NAME_CHANNEL2
	BINDING_NAME_CUSTOMCHANNEL3 = BIND_NAME_CHANNEL3
	BINDING_NAME_EMOTE = BIND_NAME_EMOTE
	BINDING_NAME_WHISPER = BIND_NAME_WHISPER
	
	-------------- suite
	ChatKeysDatas = ChatKeysSaved[CKSETTINGS];
	if (ChatKeysDatas == nil or ChatKeysDatas["channelName3"] == nil) then CKinitDatas(); end;
	echo(CHATKEYSNAME.." v"..CHATKEYSVERS..". Type /chatkeys to display settings UI.","blue");
end

---------------------------------------------------------------------------------------
----------------------------- MISE A JOUR DES MURMURES --------------------------------
function majMurmureRecuChatKeys(arg1,arg2)
	interlocuteur = arg2;
	if (ChatKeysDatas["sndNotification"] == 1) then PlaySound("TellMessage"); end;
end

function majMurmureEnvoiChatKeys(arg1,arg2,arg3)
	if (interlocuteur == "") then interlocuteur = arg2; end;
end

---------------------------------------------------------------------------------------
-------------------------- NUMERO GROUPE AFFICHE EN RAID ------------------------------
function blablaRaidChatKeys(arg1,arg2,arg3)
	-- si raidParleur = raid leader : utiliser "CHAT_MSG_RAID_LEADER" ??? (meme syntaxe)
	if (ChatKeysDatas["displayPartyNumber"] == 1) then
		local raidParleur = arg2;
		local nom,rank,subgroup;
		for i = 1,GetNumRaidMembers(),1 do
			nom,rank,subgroup = GetRaidRosterInfo(i);
			if (nom == raidParleur) then
				CHAT_RAID_GET = "["..subgroup.."]%s:\32"; -- Raid message from player %s
				if (ck_enTest) then echo(CHATKEYSNAME..": "..nom.." ("..subgroup..") sends a message on raid channel.","grey"); end;
				return;
			end;
		end;
	end;
	CHAT_RAID_GET = "%s:\32"; -- Raid message from player %s
end

---------------------------------------------------------------------------------------
---------------------------------- CHANNEL CHANGE -------------------------------------
function ckTapeMessage(prefixe)
	-- tape le debut du message dans la Chat Box pour ouvrir un canal
	if (not ChatFrameEditBox:IsVisible()) then
		ChatFrame_OpenChat(prefixe);
	else
		ChatFrameEditBox:SetText(prefixe);
	end;
	ChatEdit_ParseText(ChatFrame1.editBox,0);
end

function ckMessageCanal(nomCanalVoulu)
	-- commence un msg sur le canal voulu
	local numCanal = ckChercheCanal(nomCanalVoulu);
	if (ck_enTest) then echo(CHATKEYSNAME.." ===Requested channel="..nomCanalVoulu.."="..numCanal.."===","gray"); end;
	if (numCanal > 0) then
		ckTapeMessage("/"..numCanal.." ");
	else
		echo(CHATKEYSNAME..": "..NOCHANNEL..nomCanalVoulu,"orange");
	end;
end

function ckChercheCanal(nomCanalVoulu)
	-- scanne les canaux de 1 a 10 pour trouver le nom du canal voulu
	-- renvoit le numero du canal trouve ou 0
	local i;
	local idCanal = 0;
	local nomCanal = "";
	for i = 1,10,1 do
		idCanal,nomCanal = GetChannelName(i);
		if (ck_enTest) then echo(CHATKEYSNAME.."---searching="..nilSiNul(nomCanalVoulu).."---ID="..nilSiNul(idCanal).."---NAME="..nilSiNul(nomCanal).."---"); end;
		if (idCanal > 0 and nomCanal ~= nil and string.find(nomCanal,nomCanalVoulu,1,true) ~= nil) then	
			if (ck_enTest) then echo(CHATKEYSNAME.."---FOUND-ID="..idCanal.."---index="..i.."---"); end;
			return idCanal;-- return i ???
		end;
	end;
	return 0; -- introuvable
end

function ckMessageParty()
	-- commence un msg sur le canal Party
	if (GetNumPartyMembers() > 0) then
		ckTapeMessage("/p ");
	else
		echo(CHATKEYSNAME..": "..ERRORPARTY,"orange");
	end;
end

function ckMessageRaid()
	-- commence un msg sur le canal Raid ou Party
	if (GetNumRaidMembers() > 0) then -- raid
		ckTapeMessage("/ra ");
	else
		ckMessageParty();
	end;
end

function ckWarningRaid()
	-- commence un msg sur le canal Avertissement Raid
	if (GetNumRaidMembers() > 0) then
		ckTapeMessage("/rw ");
	else
		echo(CHATKEYSNAME..": "..ERRORRAID,"orange");
	end;
end

function ckBattleDef()
	-- commence un msg sur le canal BG ou DefenseLocale
	local nomJoueur = GetBattlefieldScore(1);
	if (nomJoueur ~= nil) then
		ckTapeMessage("/bg ");
	else
		ckMessageCanal(DEFENSECHANNELNAME);
	end;
end

function ckMessageGuilde()
	-- commence un msg sur le canal Guilde
	if (GetGuildInfo("player") ~= nil) then
		ckTapeMessage("/g ");
	else
		echo(CHATKEYSNAME..": "..ERRORGUILD,"orange");
	end;
end

function ckMessageGuildeOfficier()
	-- commence un msg sur le canal Guilde en tant qu'officier
	local guildName,guildRankName,guildRankIndex = GetGuildInfo("player");
	if (guildName ~= nil) then
		ckTapeMessage("/o ");
	else
		echo(CHATKEYSNAME..": "..ERRORGUILD,"orange");
	end;
end

function ckMessagePerso()
	-- commence un murmure au joueur dont le nom est defini dans l'UI d'options
	if (ChatKeysDatas == nil or ChatKeysDatas["buddyName"] == nil or ChatKeysDatas["buddyName"] == "") then
		echo(CHATKEYSNAME..": "..ERRORBUDDY,"orange");
	else
		ckTapeMessage("/w "..ChatKeysDatas["buddyName"].." ");
	end;
end

function ckMessageCanalPerso(numPerso)
	-- commence un message dans le canal perso dont le nom est definit dans l'UI d'options
	local numChanPerso = strToNumber(numPerso);
	if (numChanPerso < 1 or numChanPerso > 3) then
		echo(CHATKEYSNAME..": #"..videSiNul(numChanPerso).." "..ERRORCHANNEL,"orange");
	else
		if (numChanPerso == 2) then
			if (ChatKeysDatas["channelName2"] == nil or ChatKeysDatas["channelName2"] == "") then
				echo(CHATKEYSNAME..": #2 "..ERRORCHANNEL,"orange");
			else
				ckMessageCanal(ChatKeysDatas["channelName2"]);
			end;
		elseif (numChanPerso == 3) then
			if (ChatKeysDatas["channelName3"] == nil or ChatKeysDatas["channelName3"] == "") then
				echo(CHATKEYSNAME..": #3 "..ERRORCHANNEL,"orange");
			else
				ckMessageCanal(ChatKeysDatas["channelName3"]);
			end;
		else
			if (ChatKeysDatas["channelName1"] == nil or ChatKeysDatas["channelName1"] == "") then
				echo(CHATKEYSNAME..": #1 "..ERRORCHANNEL,"orange");
			else
				ckMessageCanal(ChatKeysDatas["channelName1"]);
			end;
		end;
	end;
end

function ckMessageCible()
	-- commence un murmure au joueur ami selectionne
	if ((UnitName("target") ~= nil) and (UnitIsPlayer("target")) and (UnitIsFriend("player","target"))) then
		ckTapeMessage("/w "..UnitName("target").." ");
	else
		echo(CHATKEYSNAME..": "..ERRORTARGET,"orange");
	end;
end

function ckMessageEmote()
	-- commence un emote
	ckTapeMessage("/em ");
end

---------------------------------------------------------------------------------------
------------------------------------------ UI -----------------------------------------
function ChatKeysOptions()
	if (ChatKeysOptionsFrame:IsVisible()) then
		ChatKeysOptionsFrame:Hide();
	else
		ChatKeysOptionsFrame:Show();
	end;
end

function ChatKeysOptionsDlogApply()
	ChatKeysDatas["buddyName"] = string.gsub(ChatKeysOptName:GetText()," ","");
	ChatKeysDatas["channelName1"] = string.gsub(ChatKeysOptChanName1:GetText()," ","");
	ChatKeysDatas["channelName2"] = string.gsub(ChatKeysOptChanName2:GetText()," ","");
	ChatKeysDatas["channelName3"] = string.gsub(ChatKeysOptChanName3:GetText()," ","");
	ChatKeysDatas["sndNotification"] = attribueBinaire(ChatKeysOptCheckSound:GetChecked());
	ChatKeysDatas["displayPartyNumber"] = attribueBinaire(ChatKeysOptCheckPartyNum:GetChecked());
	ChatKeysOptionsFrame:Hide();
	ChatKeysSaved[CKSETTINGS] = ChatKeysDatas;
end

function CKinitDatas()
	if (enTest) then echo(CHATKEYSNAME..": INIT DATA !!!!!!!!!!!!!!!","orange"); end;
	ChatKeysDatas = {};
	ChatKeysDatas["buddyName"] = defBuddyName;
	ChatKeysDatas["channelName1"] = defChannelName1;
	ChatKeysDatas["channelName2"] = defChannelName2;
	ChatKeysDatas["channelName3"] = defChannelName3;
	ChatKeysDatas["sndNotification"] = defSound;
	ChatKeysDatas["displayPartyNumber"] = defPartyNum;
	ChatKeysSaved[CKSETTINGS] = ChatKeysDatas;
end

function remplissageListeChannels()
	-- affichage sur 2 colonnes de 5 lignes la liste des canaux connectes
	local i,idCanal;
	local nomCanal = "";
	local colG = "";
	local colD = "";
	local cpt = 1
	for i = 1,10,1 do
		idCanal,nomCanal = GetChannelName(i);
		if (nomCanal ~= nil) then
			if (strfind(nomCanal," ",1,true) ~= nil) then nomCanal = strsub(nomCanal,1,strfind(nomCanal," ",1,true) - 1); end;
			if (cpt <= 5) then
				colG = colG..nomCanal.."\n";
			else
				colD = colD..nomCanal.."\n";
			end;
			cpt = cpt + 1;
		end;
	end;
	ChatKeysOptConnChannels_G_Text:SetText(colG);
	ChatKeysOptConnChannels_D_Text:SetText(colD);
end
---------------------------------------------------------------------------------------
--------------------------------------- HOOK ------------------------------------------
---- Changing current global strings ----
--CHAT_FLAG_AFK = "[AFK] ";
--CHAT_FLAG_DND = "[DND] ";
--CHAT_FLAG_GM = "[GM] ";

CHAT_GUILD_GET = "%s:\32"; -- Guild message from player %s
CHAT_OFFICER_GET = "[OFF] %s:\32"; -- Officers guild message from officer %s
CHAT_RAID_LEADER_GET = "[LEAD] %s:\32"; -- Raid leader message from raid officer %s
CHAT_RAID_WARNING_GET = "[ATT] %s:\32"; -- Raid alert message from raid officer %s
--CHAT_RAID_GET = "%s:\32"; -- Raid message from player %s
CHAT_PARTY_GET = "%s:\32"; -- Party message from player %s
CHAT_WHISPER_GET = MSGFROM.." %s:\32"; -- Whisper from player %s
CHAT_WHISPER_INFORM_GET = MSGTO.." %s:\32"; -- A whisper already sent to player %s

---------------------------------------------------------------------------------------
---------------------------------------- DVLPT ----------------------------------------
function ckDebug()
	ck_enTest = not ck_enTest;
	if (ck_enTest) then
		echo(CHATKEYSNAME..": debugg ON.","green");
	else
		echo(CHATKEYSNAME..": debugg OFF.","gray");
	end;
end

function ckTest()
	echo("---------");
end

---------------------------------------------------------------------------------------
------------------------------------ FCNS INTERNES ------------------------------------
function echo(chaine,nomCouleur)
	local coulr,coulg,coulb = 1,1,1 ; -- couleurs
	if (nomCouleur == "red") then
		coulr,coulg,coulb = 1,0,0;
	elseif (nomCouleur == "green") then
		coulr,coulg,coulb = 0,1,0;
	elseif (nomCouleur == "blue") then
		coulr,coulg,coulb = 0.5,0.5,0.8;
	elseif (nomCouleur == "orange") then
		coulr,coulg,coulb = 0.8,0.3,0.1;
	elseif (nomCouleur == "yellow") then
		coulr,coulg,coulb = 0.9,0.9,0.1;
	elseif (nomCouleur == "grey" or nomCouleur == "gray") then
		coulr,coulg,coulb = 0.6,0.6,0.6;
	end;
	if (DEFAULT_CHAT_FRAME) then DEFAULT_CHAT_FRAME:AddMessage(chaine,coulr,coulg,coulb); end;
end

function strToNumber(chaine)
	local valeur = tonumber(string.gsub(string.gsub(chaine,"\"",""),"\'",""),10);
	if (valeur == nil) then valeur = 0; end;
	return valeur;
end

function videSiNul(valeur)
	if (valeur == nil) then return ""; else return valeur; end;
end

function nilSiNul(valeur)
	if (valeur == nil) then return "NIL"; else return valeur; end;
end

function inversionValeur(valeur)
	return(abs(valeur - 1));
end

function attribueBinaire(valeur)
	if (valeur == 1) then return (1); else return (0); end;
end

---------------------------------------------------------------------------------------
------------------------------------- AIDE ONLINE -------------------------------------
function ckHelp()
	local i;
	local aideOnline =  {};
	aideOnline[1] = "/chatkeys to display settings (UI)";
	aideOnline[2] = "/chatkeysthelp to display this online help";
	
	echo(CHATKEYSNAME.." v"..CHATKEYSVERS.." available slash-cmds:","blue");
	echo("------------------------","grey");
	for i = 1,getn(aideOnline),1 do
		echo("   "..aideOnline[i],"grey");
	end;
	echo("------------------------","grey");
end

---------------------------------------------------------------------------------------
