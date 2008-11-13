function EGCDump_OnLoad()
	EGC_DumpFrame:RegisterForDrag("LeftButton");
	EGC_Title:SetText(ES_GuildCheck_Title);
end

function EGCDump_OnDragStart()
	EGC_DumpFrame:StartMoving();
end

function EGCDump_OnDragStop()
	EGC_DumpFrame:StopMovingOrSizing();
end

function EGC_Show()
	ES_GuildCheck_DumpChanges(ES_GuildCheck_Changes.offline);
	EGCOffline_Button:Disable();
	EGCOnline_Button:Enable();
	EGC_DumpFrame:Show();
end

function EGC_Hide()
	EGC_DumpFrame:Hide();
end

function EGCOffline_OnClick()
	ES_GuildCheck_DumpChanges(ES_GuildCheck_Changes.offline);
	EGCOffline_Button:Disable();
	EGCOnline_Button:Enable();
end

function EGCOnline_OnClick()
	ES_GuildCheck_UpdateDump();
	EGCOffline_Button:Enable();
	EGCOnline_Button:Disable();
end

function EGCExit_OnClick()
	EGC_Hide();
end

function ES_GuildCheck_DumpChanges( target )
	local EGC_Changes = "ES_GuildCheck (v"..ES_GuildCheck_Version.."):";
	
	for name,data in pairs(target.members) do
		EGC_Changes = EGC_Changes.."\n".."  " .. name;
		for ind,change in pairs(data) do
			EGC_Changes = EGC_Changes.."\n"..change;
		end
	end
	
	if( target.count > 1 ) then
		EGC_Changes = EGC_Changes.."\n"..ES_GUILDCHECK_TOTAL .. " " .. target.count .. " " .. ES_GUILDCHECK_CHANGES;
	elseif( target.count == 1 ) then
		EGC_Changes = EGC_Changes.."\n"..ES_GUILDCHECK_ONECHANGE;
	else
		EGC_Changes = EGC_Changes.."\n"..ES_GUILDCHECK_NOCHANGE;
	end
	EGC_EditBox:SetFocus();
	EGC_EditBox:SetText(EGC_Changes);
	EGC_EditBox:HighlightText();
end

function ES_GuildCheck_UpdateDump()
	local confString = ES_GuildCheck_GetConfigString();
	if( not confString or confString == "" ) then
		return;
	end
	
	local changes = 0;
	local target;
	if( ES_GuildCheck_FirstScan ) then
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
	
	ES_GuildCheck_DumpChanges(target);
end