ES_GuildCheck_Data = { };
ES_GuildCheck_DefaultOptions = {
	["OnLogin"] = "chat",
	["Timer"] = 1
};
ES_GuildCheck_Changes = {
	["offline"] = {
		["count"] = 0,
		["members"] = {}
	},
	["online"] = {
		["count"] = 0,
		["members"] = {}
	}
};
ES_GuildCheck_ConfigString = "";
ES_GuildCheck_Output = true;
ES_GuildCheck_FirstScan = true;
ES_GuildCheck_Version = "1.61";
ES_GuildCheck_Title = "ES_GuildCheck v"..ES_GuildCheck_Version;
ES_GuildCheck_Timer = -1;
ES_GuildCheck_Scan = false;
ES_GuildCheck_IsGUILoadable = (not IsAddOnLoaded("ES_GuildCheckGUI") and IsAddOnLoadOnDemand("ES_GuildCheckGUI"));

function ES_GuildCheck_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("GUILD_ROSTER_UPDATE");
	
	SLASH_GUILDCHECK1 = "/egc";
	SlashCmdList["GUILDCHECK"] = ES_GuildCheck_SlashHandler;
end

function ES_GuildCheck_SlashHandler(msg)
	if( msg == "offline" ) then
		ES_GuildCheck_PrintChanges(ES_GuildCheck_Changes.offline);
	elseif( msg == "online" ) then
		ES_GuildCheck_Output = true;
		ES_GuildCheck_UpdateData();
	elseif( msg == "show" ) then
		ES_GuildCheck_ShowGUI();
	elseif( msg == "login gui" and ES_GuildCheck_IsGUILoadable ) then
		ES_GuildCheck_Options.OnLogin = "gui";
	elseif( msg == "login chat" ) then
		ES_GuildCheck_Options.OnLogin = "chat";
	else
		local iStart, iEnd, iTimer = string.find(msg, "wait (%d+)");
		if( iTimer and tonumber(iTimer) > 0 ) then
			ES_GuildCheck_Options.Timer = tonumber(iTimer);
		else
			ES_GuildCheck_PrintHelp();
		end
	end
end

function ES_GuildCheck_OnEvent(event)
	if ( event == "VARIABLES_LOADED" ) then
		if( not ES_GuildCheck_Data.version or tonumber(ES_GuildCheck_Data.version) < tonumber(ES_GuildCheck_Version) ) then
			ES_GuildCheck_ConvertData();
		end
		if( not ES_GuildCheck_Options ) then
			ES_GuildCheck_Options = ES_GuildCheck_DefaultOptions;
		end
		for option, value in pairs(ES_GuildCheck_DefaultOptions) do
			if( not ES_GuildCheck_Options[option] ) then
				ES_GuildCheck_Options[option] = value;
			end
		end
		
		if( not IsAddOnLoaded("ES_GuildCheckGUI") and ES_GuildCheck_Options.OnLogin == "gui" ) then
			LoadAddOn("ES_GuildCheckGUI");
			if( not IsAddOnLoaded("ES_GuildCheckGUI") ) then
				ES_GuildCheck_Options.OnLogin = "chat";
				ES_GuildCheck_IsGUILoadable = false;
			end
		end
		
		ES_GuildCheck_Timer = 0;
		ES_GuildCheck_Print(string.format(ES_GUILDCHECK_LOADED, ES_GuildCheck_Title, ES_GuildCheck_Options.Timer));
		
	elseif( event == "GUILD_ROSTER_UPDATE" ) then
		if( IsInGuild() and ES_GuildCheck_Timer == -1 and not ES_GuildCheck_Scan ) then
			ES_GuildCheck_Scan = true;
			if( not ES_GuildCheck_ConfigString or ES_GuildCheck_ConfigString == "" ) then
				ES_GuildCheck_GetConfigString();
			end
			
			if( ES_GuildCheck_Data[ES_GuildCheck_ConfigString] ) then
				if( ES_GuildCheck_Data[ES_GuildCheck_ConfigString].count == 0 ) then
					ES_GuildCheck_ReadData();
				elseif( GetNumGuildMembers(true) > 0 ) then
					ES_GuildCheck_UpdateData();
				end
			end
			ES_GuildCheck_Scan = false;
		end
	end
end

function ES_GuildCheck_GetConfigString()
	local oldString;
	if( not ES_GuildCheck_ConfigString or ES_GuildCheck_ConfigString == "" ) then
		if( GetCVar("realmName") and GetGuildInfo("player") and UnitFactionGroup("player") ) then
			ES_GuildCheck_ConfigString = GetCVar("realmName") .. ":" .. UnitFactionGroup("player") .. ":" .. GetGuildInfo("player");
			oldString = GetCVar("realmName") .. "::" .. GetGuildInfo("player");
		end
	end
	
	if( IsInGuild() ) then
		if(  ES_GuildCheck_ConfigString and ES_GuildCheck_ConfigString ~= "" ) then
			if( not ES_GuildCheck_Data[ES_GuildCheck_ConfigString] ) then
				if( ES_GuildCheck_Data[oldString] ) then
					ES_GuildCheck_Data[ES_GuildCheck_ConfigString] = ES_GuildCheck_Data[oldString];
					ES_GuildCheck_Data[oldString] = nil;
				else
					ES_GuildCheck_Data[ES_GuildCheck_ConfigString] = { };
					ES_GuildCheck_Data[ES_GuildCheck_ConfigString].count = 0;
					ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members = { };
				end
			end
		end
	end
	
	return ES_GuildCheck_ConfigString;
end

function ES_GuildCheck_ReadData()
	for i=1,GetNumGuildMembers(true) do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
		ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name] = {
			["rank"] = rank,
			["level"] = level,
			["class"] = class,
			["note"] = note
		};
		if( CanViewOfficerNote() ) then
			ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].onote = officernote;
		end
		ES_GuildCheck_Data[ES_GuildCheck_ConfigString].count = ES_GuildCheck_Data[ES_GuildCheck_ConfigString].count + 1;
	end
end

function ES_GuildCheck_UpdateData()
	local confString = ES_GuildCheck_GetConfigString();
	if( not confString or confString == "" ) then
		return;
	end
	
	local changes = 0;
	local target, out;
	if( ES_GuildCheck_FirstScan ) then
		if( ES_GuildCheck_Options.OnLogin == "gui" ) then
			out = true;
		else
			out = false;
		end
		target = ES_GuildCheck_Changes.offline;
		ES_GuildCheck_FirstScan = false;
	else
		target = ES_GuildCheck_Changes.online;
	end
	
	for n,d in pairs(ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members) do
		local found = false;
		for i=1,GetNumGuildMembers(true) do
			local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
			if( name == n ) then
				found = true;
			end
		end
		if( not found ) then
			target.members[n] = {
				[1] = "    " .. ES_GUILDCHECK_GUILDLEFT,
				[2] = "    " .. ES_GUILDCHECK_RANK .. ": " .. ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[n].rank,
				[3] = "    " .. ES_GUILDCHECK_LEVEL .. ": " .. ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[n].level,
				[4] = "    " .. ES_GUILDCHECK_CLASS .. ": " .. ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[n].class
			};
			if( ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[n].note ) then
				table.insert(target.members[n], "    " .. ES_GUILDCHECK_NOTE .. ": " .. ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[n].note);
			end
			if( CanViewOfficerNote() and ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[n].onote ) then
				table.insert(target.members[n], "    " .. ES_GUILDCHECK_ONOTE .. ": " .. ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[n].onote);
			end
			target.count = target.count + 1;
			ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[n] = nil;
			ES_GuildCheck_Data[ES_GuildCheck_ConfigString].count = ES_GuildCheck_Data[ES_GuildCheck_ConfigString].count - 1;
		end
	end
	
	for i=1,GetNumGuildMembers(true) do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
		if( not ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name] ) then
			target.members[name] = {
				[1] = "    " .. ES_GUILDCHECK_GUILDJOIN,
				[2] = "    " .. ES_GUILDCHECK_RANK .. ": " .. rank,
				[3] = "    " .. ES_GUILDCHECK_LEVEL .. ": " .. level,
				[4] = "    " .. ES_GUILDCHECK_CLASS .. ": " .. class
			};
			if( note ) then
				table.insert(target.members[name], "    " .. ES_GUILDCHECK_NOTE .. ": " .. note);
			end
			if( CanViewOfficerNote() ) then
				table.insert(target.members[name], "    " .. ES_GUILDCHECK_ONOTE .. ": " .. officernote);
			end
			target.count = target.count + 1;
			ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name] = {
				["rank"] = rank,
				["level"] = level,
				["class"] = class,
				["note"] = note,
				["onote"] = officernote
			};
			ES_GuildCheck_Data[ES_GuildCheck_ConfigString].count = ES_GuildCheck_Data[ES_GuildCheck_ConfigString].count + 1;
		else
			if( ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].rank ~= rank ) then
				if( not target.members[name] ) then
					target.members[name] = {};
				end
				table.insert(target.members[name], "    " .. ES_GUILDCHECK_RANK .. ": " .. ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].rank.." => "..rank);
				target.count = target.count + 1;
				ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].rank = rank;
			end
			if( ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].level ~= level ) then
				if( not target.members[name] ) then
					target.members[name] = {};
				end
				table.insert(target.members[name], "    " .. ES_GUILDCHECK_LEVEL .. ": " .. ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].level.." => "..level);
				target.count = target.count + 1;
				ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].level = level;
			end
			if( ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].class ~= class ) then
				if( not target.members[name] ) then
					target.members[name] = {};
				end
				table.insert(target.members[name], "    " .. ES_GUILDCHECK_CLASS .. ": " .. ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].class.." => "..class);
				target.count = target.count + 1;
				ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].class = class;
			end
			if( ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].note ~= note ) then
				if( not target.members[name] ) then
					target.members[name] = {};
				end
				table.insert(target.members[name], "    " .. ES_GUILDCHECK_NOTE .. ": " .. ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].note.." => "..note);
				target.count = target.count + 1;
				ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].note = note;
			end
			if( CanViewOfficerNote() and ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].onote ~= officernote ) then
				if( not target.members[name] ) then
					target.members[name] = {};
				end
				if( not ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].onote ) then
					ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].onote = " ";
				end
				table.insert(target.members[name], "    " .. ES_GUILDCHECK_ONOTE .. ": " .. ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].onote.." => "..officernote);
				target.count = target.count + 1;
				ES_GuildCheck_Data[ES_GuildCheck_ConfigString].members[name].onote = officernote;
			end
		end
	end
	
	if( ES_GuildCheck_Output ) then
		if( out ) then
			ES_GuildCheck_ShowGUI();
		else
			ES_GuildCheck_PrintChanges(target);
		end
		ES_GuildCheck_Output = false;
	end
end

function ES_GuildCheck_PrintHelp()
	ES_GuildCheck_Print("ES_GuildCheck (v"..ES_GuildCheck_Version.."):");
	ES_GuildCheck_Print(ES_GUILDCHECK_HELP1);
	ES_GuildCheck_Print(ES_GUILDCHECK_HELP2);
	ES_GuildCheck_Print(ES_GUILDCHECK_HELP3);
	if( IsAddOnLoaded("ES_GuildCheckGUI") or IsAddOnLoadOnDemand("ES_GuildCheckGUI") ) then
		ES_GuildCheck_Print(ES_GUILDCHECK_HELP4);
		ES_GuildCheck_Print(string.format(ES_GUILDCHECK_HELP5, ES_GuildCheck_Options.OnLogin));
	end
	ES_GuildCheck_Print(string.format(ES_GUILDCHECK_HELP6, tostring(ES_GuildCheck_Options.Timer)));
end

function ES_GuildCheck_PrintChanges( target )
	ES_GuildCheck_Print("ES_GuildCheck (v"..ES_GuildCheck_Version.."):");
		
	for name,data in pairs(target.members) do
		ES_GuildCheck_Print("  " .. name);
		for ind,change in pairs(data) do
			ES_GuildCheck_Print(change);
		end
	end
	
	if( target.count > 1 ) then
		ES_GuildCheck_Print(ES_GUILDCHECK_TOTAL .. " " .. target.count .. " " .. ES_GUILDCHECK_CHANGES);
	elseif( target.count == 1 ) then
		ES_GuildCheck_Print(ES_GUILDCHECK_ONECHANGE);
	else
		ES_GuildCheck_Print(ES_GUILDCHECK_NOCHANGE);
	end
end

function ES_GuildCheck_Print(str)
	DEFAULT_CHAT_FRAME:AddMessage(str, 0, 1, 0);
end

function ES_GuildCheck_ShowGUI()
	if( not IsAddOnLoaded("ES_GuildCheckGUI") ) then
		if( IsAddOnLoadOnDemand("ES_GuildCheckGUI") ) then
			LoadAddOn("ES_GuildCheckGUI");
		else
			return;
		end
	end
	
	if( IsAddOnLoaded("ES_GuildCheckGUI") ) then
		EGC_Show();
	else
		ES_GuildCheck_IsGUILoadable = false;
	end
end

function ES_GuildCheck_OnUpdate(elapsed)
	if( ES_GuildCheck_Timer >= ES_GuildCheck_Options.Timer and ES_GuildCheck_Timer ~= -1 ) then
		ES_GuildCheck_Timer = -1;
		GuildRoster();
	elseif( ES_GuildCheck_Timer >= 0 ) then
		ES_GuildCheck_Timer = ES_GuildCheck_Timer + elapsed;
	end
end

function ES_GuildCheck_ConvertData()
	if( not ES_GuildCheck_Data.version ) then
		for oldString, data in pairs(ES_GuildCheck_Data) do
			local iStart, iEnd, sRealm, sGuild = string.find(oldString, "(.+)-(.+)");
			if( sRealm and sGuild) then
				for name, pData in pairs(data.members) do
					pData.rank = pData.Rang;
					pData.Rang = nil;
					pData.note = pData.Notiz;
					pData.Notiz = nil;
					pData.class = pData.Klasse;
					pData.Klasse = nil;
					if( pData.Offiziersnotiz ) then
						pData.onote = pData.Offiziersnotiz;
						pData.Offiziersnotiz = nil;
					end
					pData.level = pData.Level;
					pData.Level = nil;
				end
				local newString = sRealm .. "::" .. sGuild;
				ES_GuildCheck_Data[newString] = data;
				ES_GuildCheck_Data[oldString] = nil;
			end
		end
	elseif( tonumber(ES_GuildCheck_Data.version) < 1.61 ) then
		for confString, data in pairs(ES_GuildCheck_Data) do
			if( string.find(confString, ":") ) then
				for name, pData in pairs(data.members) do
					if( pData.Rang ) then
						pData.rank = pData.Rang;
						pData.Rang = nil;
					end
					if( pData.Notiz ) then
						pData.note = pData.Notiz;
						pData.Notiz = nil;
					end
					if( pData.Klasse ) then
						pData.class = pData.Klasse;
						pData.Klasse = nil;
					end
					if( pData.Offiziersnotiz ) then
						pData.onote = pData.Offiziersnotiz;
						pData.Offiziersnotiz = nil;
					end
					if( pData.Level ) then
						pData.level = pData.Level;
						pData.Level = nil;
					end
				end
			end
		end
	end
	ES_GuildCheck_Data.version = ES_GuildCheck_Version;
end