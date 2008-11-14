--[[########################################################
--## Name: CharacterProfiler
--## Author: calvin
--## Addon Details & License can be found in 'readme.txt'
--######################################################--]]

--[[########################################################
--## RPGOCP object data
--######################################################--]]
RPGOCP = {
	TITLE		= "CharacterProfiler";
	ABBR		= "CP";
	PROVIDER	= "rpgo";
	VERSION		= GetAddOnMetadata("CharacterProfiler", "Version");
	AUTHOR		= GetAddOnMetadata("CharacterProfiler", "Author");
	EMAIL		= GetAddOnMetadata("CharacterProfiler", "X-Email");
	URL			= GetAddOnMetadata("CharacterProfiler", "X-Website");
	DATE		= GetAddOnMetadata("CharacterProfiler", "X-Date");
	PROFILEDB	= "3.0.0";
	FRAME		= "rpgoCPframe";
	TOOLTIP		= "rpgoCPtooltip";
}
RPGOCP.PREFS={
	enabled=true,verbose=false,tooltip=true,tooltipshtml=true,fixtooltip=true,fixquantity=true,fixicon=true,fixcolor=true,reagentfull=true,talentsfull=true,questsfull=false,lite=true,button=true,debug=false,ver=030000,
	scan={inventory=true,currency=true,talents=true,honor=true,reputation=true,spells=true,pet=true,companions=true,equipment=true,mail=true,professions=true,skills=true,quests=true,bank=true,glyphs=true},
};
RPGOCP.events={"PLAYER_LEVEL_UP","TIME_PLAYED_MSG",
	"TRADE_SKILL_SHOW","TRADE_SKILL_CLOSE","TRADE_SKILL_UPDATE",
	"GLYPH_ADDED","GLYPH_REMOVED","GLYPH_UPDATED",
	"CHARACTER_POINTS_CHANGED","COMPANION_LEARNED","COMPANION_UPDATE",
	"BANKFRAME_OPENED","BANKFRAME_CLOSED","MAIL_SHOW","MAIL_CLOSED","MAIL_INBOX_UPDATE",
	"MERCHANT_CLOSED","UNIT_QUEST_LOG_CHANGED","QUEST_FINISHED","PET_STABLE_CLOSED",
	"ZONE_CHANGED","ZONE_CHANGED_INDOORS","PLAYER_CONTROL_LOST","PLAYER_CONTROL_GAINED",
};

RPGOCP.usage={
	{"/cp","-- usage/help"},
	{"/cp [on|off]","-- turns on|off"},
	{"/cp export","-- force export"},
	{"/cp show","-- show current session scan"},
	{"/cp lite [on|off]","-- turns on|off lite scanning"},
	{"/cp list","-- list current profiles"},
	{"/cp purge [all|server|guild|char]","-- purge profile"},
};
--[[## Events
--######################################################--]]
RPGOCP.event1={
	VARIABLES_LOADED =
		function()
			RPGOCP:InitPref();
			RPGOCP:RegisterEvents();
			RPGOCP:InitState();
			RPGOCP:InitProfile();
			RPGOCP.frame:UnregisterEvent("VARIABLES_LOADED");
			return true;
		end,
	UNIT_INVENTORY_CHANGED =
		function(a1)
			RPGOCP:UpdateEqScan(a1);
			return true;
		end,
	BAG_UPDATE =
		function(a1)
			RPGOCP:UpdateBagScan(a1);
			return true;
		end,
	PLAYERBANKSLOTS_CHANGED =
		function()
			RPGOCP:UpdateBagScan(BANK_CONTAINER);
			return true;
		end,
	TIME_PLAYED_MSG =
		function(a1,a2)
			RPGOCP:UpdatePlayed(a1,a2);
			return true;
		end,
	ZONE_CHANGED =
		function()
			RPGOCP:UpdateZone();
			return true;
		end,
	ZONE_CHANGED_INDOORS =
		function()
			RPGOCP:UpdateZone();
			return true;
		end,
	PLAYER_CONTROL_LOST =
		function()
			RPGOCP.frame:UnregisterEvent("ZONE_CHANGED");
			RPGOCP.frame:UnregisterEvent("ZONE_CHANGED_INDOORS");
			return true;
		end,
	PLAYER_CONTROL_GAINED =
		function()
			RPGOCP.frame:RegisterEvent("ZONE_CHANGED");
			RPGOCP.frame:RegisterEvent("ZONE_CHANGED_INDOORS");
			RPGOCP:UpdateZone();
			return true;
		end,
};
RPGOCP.event2={
	RPGOCP_SCAN =
		function()
			RPGOCP:UpdateProfile();
		end,
	RPGOCP_EXPORT =
		function()
			RPGOCP:ForceExport();
		end,
	SPELLBOOK =
		function()
			RPGOCP:GetSpellBook();
			RPGOCP:GetPetSpellBook();
		end,
	BANKFRAME_OPENED =
		function()
			RPGOCP:State("_bank",true);
			RPGOCP:GetBank();
		end,
	BANKFRAME_CLOSED =
		function()
			RPGOCP:GetBank();
			RPGOCP:GetInventory();
			RPGOCP:GetEquipment();
			RPGOCP:State("_bank",nil);
		end,
	MAIL_SHOW =
		function()
			RPGOCP:State("_mail",true);
			RPGOCP.GetMail();
		end,
	MAIL_CLOSED =
		function()
			RPGOCP.GetMail();
			RPGOCP:GetInventory();
			RPGOCP:GetEquipment();
			RPGOCP:State("_mail",nil);
		end,
	MERCHANT_CLOSED =
		function()
			RPGOCP:GetInventory();
			RPGOCP:GetEquipment();
		end,
	TRADE_SKILL_SHOW =
		function(a1)
			if(strsub(a1,1,5) ~= "trade") then
				RPGOCP:PrintDebug( strsub(a1,1,5),	
						strsub(a1,1,5) ~= "trade",
						a1 );
			RPGOCP:GetSkills();
			RPGOCP.GetTradeSkill();
			end
		end,
	PLAYER_LEVEL_UP =
		function()
			RPGOCP:UpdateProfile();
		end,
	QUEST_FINISHED =
		function()
			RPGOCP:GetQuests(true);
		end,
	UNIT_QUEST_LOG_CHANGED =
		function()
			RPGOCP:GetQuests(true);
		end,
	CHARACTER_POINTS_CHANGED =
		function()
			RPGOCP:GetTalents();
		end,
	PET_STABLE_CLOSED =
		function()
			RPGOCP:ScanPetStable();
		end,
	COMPANION_LEARNED =
		function()
		RPGOCP:ScanCompanions();
		end,
	GLYPH_UPDATED =
		function()
			RPGOCP:ScanGlyphs();
		end,
	GLYPH_ADDED =
		function(a1)
			RPGOCP:ScanGlyphs(a1);
		end,
	GLYPH_REMOVED =
		function(a1)
			RPGOCP:ScanGlyphs(a1);
		end,
	CURRENCY_DISPLAY_UPDATE =
		function()
			RPGOCP:ScanCurrency(true);
		end,
};
RPGOCP.funcs={
	fixicon =
		function(a1)
			if(a1) then
				rpgo.scanIcon = function(str)
					if(not str) then return nil; end
					return table.remove({ strsplit("\\", str) });
				end
			else
				rpgo.scanIcon = function(str) return str end ;
			end
		end,
	fixcolor =
		function(a1)
			if(a1) then
				rpgo.scanColor = function(str)
					if(not str) then return nil; end
					local _,_,c = string.find(str,"%x%x(%x%x%x%x%x%x)");
					return c
				end
			else
				rpgo.scanColor = function(str) return str end ;
			end
		end,
	button =
		function()
			RPGOCP:ButtonHandle();
		end
};
--[ChatCommand]
RPGOCP.command={
	off =
		function()
			RPGOCP:Toggle(false);
		end,
	on =
		function()
			RPGOCP:Toggle(true);
		end,
	show =
		function()
			RPGOCP:Show();
		end,
	item =
		function(argv)
			RPGOCP:ItemSearch(argv);
		end,
	list =
		function()
			RPGOCP:ProfileList();
		end,
	export =
		function()
			RPGOCP:EventHandler('RPGOCP_EXPORT');
		end,
	purge =
		function(argv)
			RPGOCP:Purge(argv);
		end,
};

--##########################################################
local TradeSkillCode={optimal=4,medium=3,easy=2,trivial=1,header=0};
local UnitPower={"Rage","Focus","Energy","Happiness"};UnitPower[0]="Mana";
local UnitSlots={"Head","Neck","Shoulder","Shirt","Chest","Waist","Legs","Feet","Wrist","Hands","Finger0","Finger1","Trinket0","Trinket1","Back","MainHand","SecondaryHand","Ranged","Tabard"};UnitSlots[0]="Ammo";
local UnitStatName={"Strength","Agility","Stamina","Intellect","Spirit"};
local UnitSchoolName={"Physical","Holy","Fire","Nature","Frost","Shadow","Arcane"};
local UnitResistanceName={"Holy","Fire","Nature","Frost","Shadow","Arcane"};
--[[########################################################
--## rpgoCP Core Functions
--######################################################--]]
--[Init]
function RPGOCP:Init()
	SLASH_RPGOCP1="/cp";
	SLASH_RPGOCP2="/rpgocp";
	SLASH_RPGOCP3="/profiler";
	SlashCmdList["RPGOCP"] = function(...) return self:ChatCommand(...) end;

	--[frame & tooltip]
	self.frame = CreateFrame("Frame",self.FRAME,CharacterNameFrame);
	self.frame:RegisterEvent("VARIABLES_LOADED");
	self.frame:SetScript("OnEvent", function() return self:EventHandler(event,arg1,arg2) end );
	self.frame:SetScript("OnHide" , function() return self:EventHandler('RPGOCP_SCAN') end );

	self.tooltip = CreateFrame("GameTooltip",self.TOOLTIP,UIParent,"GameTooltipTemplate");
	self.tooltip:SetOwner(UIParent,"ANCHOR_NONE");

	--[object functions]
	self.PrintTitle = rpgo.PrintTitle;
	self.PrintUsage = rpgo.PrintUsage;
	self.PrintDebug = rpgo.PrintDebug;

	self.PrefInit = rpgo.PrefInit;
	self.PrefTidy = rpgo.PrefTidy;
	self.PrefToggle = rpgo.PrefToggle;

	self.LiteScan = function(self,event)
		if(event=="RPGOCP_EXPORT") then return false; end
		if(self.state and not self.state["_loaded"]) then return false; end
		return rpgo.LiteScan(self);
	end

	self.RegisterEvents = function(self,flagMode)
		flagMode = flagMode or (self.prefs.enabled);
		self:PrintDebug("RegisterEvents ("..rpgo.PrefColorize(flagMode)..") ");
		return rpgo.RegisterEvents(self,flagMode);
	end

	-- tmp prefs
	self.prefs = {enabled=true};

	self.State = rpgo.State;
	self.UpdateDate = rpgo.UpdateDate;
	self.ScanTooltip = rpgo.ScanTooltipOO;
end

--[EventHandler]
function RPGOCP:EventHandler(event,arg1,arg2,arg3)
	if(not event) then return end
	if(not self.prefs or not self.prefs.enabled) then return; end

	if(rpgoDebugArg) then
		rpgoDebugArg(self.ABBR,event,arg1,arg2,arg3);
	end

	--debugprofilestart();
	--local mem=gcinfo();
	local retVal;

	retVal = rpgo.qProcess(RPGOCP.queue,event);
		if(retVal~=nil) then return retVal; end

	if(RPGOCP.event1[event]) then
		retVal=RPGOCP.event1[event](arg1,arg2);
		if(retVal~=nil) then return retVal; end
	end

	if( self:LiteScan(event) ) then return; end
	if( ( not self:State("_lock") ) ) then
		if(RPGOCP.event2[event]) then
			self:State("_lock",true);
			RPGOCP.event2[event](arg1,arg2);
			self:State("_lock",nil);
		end
	end
	--self:PrintDebug("time",debugprofilestop().."ms",gcinfo()-mem.."kb");
end
rpgoCP_EventHandler = function(event,arg1,arg2) return RPGOCP:EventHandler(event,arg1,arg2) end ;

--[ChatCommand]
function RPGOCP:ChatCommand(argline)
	local argv=rpgo.Str2Ary(argline);
	if(argv and argv[1]) then
		local argcase = string.lower(argv[1]);
		table.remove(argv,1);
		if(self.command[argcase]) then
			return self.command[argcase](argv);
		elseif(self.PREFS[argcase]~=nil) then
			return self:PrefToggle(argcase,argv[1]);
		end
	end
	self:PrintUsage();
	self:PrefToggle("enabled");
end
--[InitState]
function RPGOCP:InitState()
	local _,class=UnitClass("player");
	self.state = {
		_loaded=nil,_lock=nil,_bag=nil,_bank=nil,_mail=nil,
		_server=GetRealmName(),_player=UnitName("player"),_class=class,
		_skills={},
		Equipment=0,
		Guild=nil, GuildNum=nil,
		Skills=0, Glyphs=0,
		Talents=0,TalentPts=0,
		Reputation=0,
		Quests=0, QuestsLog=0,
		Mail=nil,
		Honor=nil,
		Bag={},Inventory={},Bank={},
		Professions={}, SpellBook={},
		Pets={}, Stable={}, PetSpell={}, PetTalent={},
		Companions={},
	};
	self.queue={};
end
--[InitPref]
function RPGOCP:InitPref()
	if(not self.PREFS) then return; end
	if(not rpgoCPpref) then rpgoCPpref={}; end
	self.prefs = rpgoCPpref;
	self:PrefTidy();
	self:PrefInit();

	self:ButtonHandle();
	self:FrameHookCreate();
	self.funcs["fixcolor"](self.prefs["fixcolor"]);
	self.funcs["fixicon"](self.prefs["fixicon"]);

	if( self.prefs.verbose ) then
		self:PrintTitle("loaded.",true,true);
	end
	self:PrintDebug("running in DEBUG MODE");
end
--[Toggle]
function RPGOCP:Toggle(val)
	if( self.prefs["enabled"]~=val ) then
		self:PrefToggle("enabled",val);
		self:RegisterEvents();
		if(val) then
			self:InitState();
			if(not self:State("_loaded")) then
				self:InitProfile();
			end
		else
			self:State("_loaded",nil);
		end
	else
		self:PrefToggle("enabled",val);
	end
end
--[ButtonHandle]
function RPGOCP:ButtonHandle()
	if(self.prefs.button) then
		local button = CreateFrame("Button","rpgoCPUISaveButton",PaperDollFrame,"UIPanelButtonTemplate");
		button:SetPoint("TOPLEFT",PaperDollFrame,"TOPLEFT",73,-35);
		button:SetHeight(20);
		button:SetWidth(40);
		button:SetToplevel(true);
		button:SetText(RPGOCP_SAVE_TEXT);
		button:Show();
		button:SetScript("OnClick", function() return self:EventHandler('RPGOCP_EXPORT') end );
		button:SetScript("OnEnter", function() return rpgo.SetTooltip(RPGOCP_SAVE_TOOLTIP) end );
		button:SetScript("OnLeave", function() return GameTooltip:Hide() end );
	elseif(rpgoCPUISaveButton) then
		local button = rpgoCPUISaveButton;
		button:Hide();
	end
end
--[FrameHookCreate]
function RPGOCP:FrameHookCreate()
	rpgoCPSpellBook = CreateFrame("Frame","rpgoCPSpellBook",SpellBookFrame);
	rpgoCPSpellBook:SetScript("OnShow", function() return self:EventHandler('SPELLBOOK') end );
end

--[InitProfile]
function RPGOCP:InitProfile()
	if( not myProfile ) then
		myProfile={}; end
	if( not myProfile[self.state["_server"]] ) then
		myProfile[self.state["_server"]]={}; end
	if( not myProfile[self.state["_server"]]["Character"] ) then
		myProfile[self.state["_server"]]["Character"]={}; end
	if( not myProfile[self.state["_server"]]["Character"][self.state["_player"]] ) then
		myProfile[self.state["_server"]]["Character"][self.state["_player"]]={}; end

	self.db = myProfile[self.state["_server"]]["Character"][self.state["_player"]];
	if( self.db ) then
		self.db["CPversion"]	= self.VERSION;
		self.db["CPprovider"]	= self.PROVIDER;
		self.db["DBversion"]	= self.PROFILEDB;
		self.db["Name"]			= self.state["_player"];
		self.db["Server"]		= self.state["_server"];
		self.db["Locale"]		= GetLocale();
		self.db["Race"],self.db["RaceEn"],self.db["RaceId"]=rpgo.UnitRace("player")
		self.db["Class"],self.db["ClassEn"],self.db["ClassId"]=rpgo.UnitClass("player");
		self.db["Sex"],self.db["SexId"]=rpgo.UnitSex("player");
		self.db["FactionEn"],self.db["Faction"]=UnitFactionGroup("player");
		self.db["HasRelicSlot"]	= UnitHasRelicSlot("player")==1 or false;
		self:UpdateDate();
		self:State("_loaded",true);
	end
	return self:State("_loaded");
end
--[UpdateProfile]
function RPGOCP:UpdateProfile()
	if( self:State("_bank") ) then
		self:GetBank();
	end
	if( self:State("_mail") ) then
		self.GetMail();
	end
	self:GetGuild(force);
	self:GetBuffs(self.db);
	self:GetInventory();
	self:GetEquipment();
	self:ScanCurrency();
	self:GetTalents();
	self:GetSkills();
	self:GetSpellBook();
	self:ScanGlyphs();
	self:GetReputation();
	self:GetQuests();
	self:GetHonor();
	self:GetArena();
	self:ScanPetInfo();
	self:ScanCompanions();
	self:UpdateZone();
	self:UpdatePlayed();
	self:UpdateDate();
	self:PrintDebug( "time",time() );
end
--[ForceExport]
function RPGOCP:ForceExport()
	local state=self.state;
	self:InitState();
		self.state["Bank"]=state["Bank"];
		self.state["Mail"]=state["Mail"];
		self.state["Professions"]=state["Professions"];
		self.state["Pets"]=state["Pets"];
		self.state["Stable"]=state["Stable"];
		self.state["PetSpell"]=state["PetSpell"];
		self.state["_litemsg"]=state["_litemsg"];
		self.state["_bank"]=state["_bank"];
		self.state["_mail"]=state["_mail"];
	self:InitProfile();
	self:UpdateProfile();
	self:ScanPetInfo();
	self:Show();
end
--[Purge]
function RPGOCP:Purge(argv)
	local isPurged,msg;
	if(argv and argv[1]) then
		msg = " ["..argv[1].."]";
		if(myProfile) then
			local server,type,profile;
			if(argv[1]=="all") then
				myProfile=nil;
				isPurged=true;
			elseif(argv[1]=="server") then
				server=argv[2] or self:State("_server");
				msg = msg.." '"..server.."'";
				if(myProfile[server] and myProfile[server]["Character"]) then
					myProfile[server]["Character"]=nil;
					isPurged=true;
				end
			else
				if(argv[1]=="char") then
					server=self:State("_server");
					profile=argv[2] or self:State("_player");
					msg = msg.." '"..profile.."'";
					if(myProfile[server] and myProfile[server]["Character"] and myProfile[server]["Character"][profile]) then
						type = "Character";
					end
				elseif(argv[1]=="guild") then
					server=self:State("_server");
					profile=argv[2] or GetGuildInfo("player") or "";
					msg = msg.." '"..profile.."'";
					if(myProfile[server] and myProfile[server]["Guild"] and myProfile[server]["Guild"][profile]) then
						type = "Guild";
					end
				elseif(argv[1] and argv[2]) then
					if(myProfile[argv[1]]) then
						server = argv[1];
						if( myProfile[server]["Character"] and myProfile[server]["Character"][argv[2]] ) then
							type="Character";
							profile=argv[2];
						elseif( myProfile[server]["Guild"] and myProfile[server]["Guild"][argv[2]] ) then
							type="Guild";
							profile=argv[2];
						end
					elseif(myProfile[argv[2]]) then
						server = argv[2];
						if( myProfile[server]["Character"] and myProfile[server]["Character"][argv[1]] ) then
							type="Character";
							profile=argv[1];
						elseif( myProfile[server]["Guild"] and myProfile[server]["Guild"][argv[1]] ) then
							type="Guild";
							profile=argv[1];
						end
					end
				end
				if(server and type and profile) then
					msg = " '"..profile.."@"..server.."'";
					myProfile[server][type][profile]=nil;
					isPurged=true;
				end
			end
		end
	end
	if(not isPurged and not msg) then
		self:PrintTitle("Usage:  /cp purge [all|server|guild|char]");
	else
		if(isPurged) then
			self:InitState();
			msg = msg.." was "..rpgo.StringColorize(rpgo.colorGreen,"purged|r");
		else
			msg = msg.." was "..rpgo.StringColorize(rpgo.colorRed,"not purged|r");
		end
		self:PrintTitle(msg);
	end
end
--[ProfileList]
function RPGOCP:ProfileList()
	if(myProfile) then
		self:PrintTitle("stored profiles");
		for _,server in pairs( self.GetServers() ) do
			rpgo.PrintMsg("  Server: "..server);
			for _,guild in pairs( self.GetGuilds(server) ) do
				rpgo.PrintMsg("    Guild: "..guild.." (M:" .. self.GetParam("NumMembers",guild,server) .. ")");
			end
			for _,char in pairs( self.GetCharacters(server) ) do
				rpgo.PrintMsg("    Char: "..char.." (L:" .. self.GetParam("Level",char,server) .. ")  "..self:GetProfileDate(server,char));
			end
		end
	else
		self:PrintTitle("no stored profiles");
	end
end

--[ItemSearch]
function RPGOCP:ItemSearch(search)
	local server = self.state._server;

	if( type(search) == "table" ) then
		search = table.concat(search," ");
	end
	self:PrintTitle("Item Search for:" .. search);
	local itemID = rpgo.GetItemID(search);
	if( itemID ) then
		search = itemID;
	end
	local type = "Name";
	if( tonumber(search) ) then
		type = "Item";
		search = "^" .. search .. ":";
	else
		search = string.gsub(search,"([%^%%%(%)%.%[%]%*%+%-%?])","%%%1");
		search = string.lower(search);
	end

	local result = {};
	local function searchItems(block,searchStruct)
		for _,item in pairs( searchStruct ) do
			if( string.find(string.lower(item[type]), search) ) then
				if( not result[item.Name] ) then
					result[item.Name] = {};
					result[item.Name]["id"] = item.Item;
					result[item.Name]["loc"] = {};
				end
				if( not result[item.Name]["loc"][block] ) then
					result[item.Name]["loc"][block] = item.Quantity or 1;
				else
					result[item.Name]["loc"][block] = result[item.Name]["loc"][block] + (item.Quantity or 1);
				end
			end
		end
	end
	if( myProfile and myProfile[server] and myProfile[server]["Character"] ) then
		for char,_ in pairs(myProfile[server]["Character"]) do
			result = {};
			local db = myProfile[server]["Character"][char];
			for _,block in pairs({"Equipment"}) do
				if( db[block] ) then
							searchItems( block,db[block] );
				end
			end
			for _,block in pairs({"Inventory","Bank","MailBox"}) do
				if( db[block] ) then
					for _,container in pairs(db[block]) do
						if( container["Contents"] ) then
							searchItems( block,container["Contents"] );
						end
					end
				end
			end
			if( table.count(result) ~= 0 ) then
				rpgo.PrintMsg("  " .. char);
				for itemname,block in pairs(result) do
					local _,itemLink = GetItemInfo("item:"..block["id"]);
					local msg = "";
					if(itemLink) then
						msg = itemLink .. "  ";
					else
						msg = itemname .. "  ";
					end
					for item,qty in pairs(block["loc"]) do
						msg = msg .. item ..":" .. qty .. "; "
					end
					rpgo.PrintMsg( "      " .. msg );
				end
			end
		end
	end
end

--[Show]
function RPGOCP:Show()
	if(self.prefs["enabled"]) then
		if(self:State("_player") and self:State("_loaded")) then
			local msg="";
			local tsort={};
				msg="Profile: " .. self:State("_player") .. " @" .. self:State("_server");
				if(self.db["Level"]) then
					msg=msg.." (lvl "..self.db["Level"]..")"
				end
			self:PrintTitle(msg);

				if(self:State("Guild")==0) then
				else
					if(self:State("Guild")) then
						msg="Guild: ";
						if(self.db["Guild"]["Name"] and self.db["Guild"]["Title"]) then
							msg=msg.."Name:"..self.db["Guild"]["Name"].."  Title:"..self.db["Guild"]["Title"];
						else
							msg=msg..rpgo.StringColorize(rpgo.colorRed," not scanned");
						end
					else
						msg=msg..rpgo.StringColorize(rpgo.colorRed," not scanned");
					end
					rpgo.PrintMsg("  "..msg);
				end

				msg="Zone: ";
				if(self.db["Zone"]) then
					msg=msg..self.db["Zone"];
					if(self.db["SubZone"] and self.db["SubZone"]~="") then
						msg=msg.."/"..self.db["SubZone"];
					end
				else
					msg=msg..rpgo.StringColorize(rpgo.colorRed," not scanned");
				end
			rpgo.PrintMsg("  "..msg);

				msg="";
				msg=msg .. "Equip:"..self:State("Equipment").."/"..table.getn(UnitSlots);
				msg=msg .. " Skill:" ..self:State("Skills");
				msg=msg .. " Talent:" ..self:State("Talents");
				msg=msg .. " Rep:" ..self:State("Reputation");
				msg=msg .. " Quest:" ..self:State("Quests");
--WotLK
			if( GetNumGlyphSockets) then 
				msg=msg .. " Glyphs:";
				if( self.state["Glyphs"]==0 ) then
					msg=msg..rpgo.StringColorize(rpgo.colorRed,NONE);
				else
					msg=msg..self:State("Glyphs");
				end
			end
				if(self:State("Mail")) then
					msg=msg .. " Mail:" ..self:State("Mail");
				end
				if(self:State("Honor")) then
					msg=msg .. " Honor:" ..self:State("Honor");
					if(self.db["Honor"]["RankName"]) then
						msg=msg .. " (" ..self.db["Honor"]["RankName"]..")";
					end
				else
					msg=msg .. " Honor:"..rpgo.StringColorize(rpgo.colorRed,NONE);
				end
			rpgo.PrintMsg("  " .. msg);

				msg="Spells:";
				tsort={};
				table.foreach(self.state["SpellBook"], function(k,v) table.insert(tsort,k) end );
				table.sort(tsort);
				if(table.getn(tsort)==0) then
					msg=msg..rpgo.StringColorize(rpgo.colorRed," not scanned")..".  - open your spellbook to scan";
				else
					for _,item in pairs(tsort) do
						msg=msg .. " " .. item..":"..self.state["SpellBook"][item];
					end
				end
			rpgo.PrintMsg("  " .. msg);

				msg="Professions:";
				tsort={};
				table.foreach(self.state["Professions"], function (k,v) table.insert(tsort,k) end );
				table.sort(tsort);
				if(table.getn(tsort)==0) then
					msg=msg..rpgo.StringColorize(rpgo.colorRed," not scanned")..".  - open each profession to scan";
				else
					for _,item in pairs(tsort) do
						msg=msg .. " " .. item..":"..self.state["Professions"][item];
					end
				end
			rpgo.PrintMsg("  " .. msg);

				msg="Inventory:";
				tsort={};
				table.foreach(self.state["Inventory"], function(k,v) table.insert(tsort,k) end );
				table.sort(tsort);
				if(table.getn(tsort)==0) then
					msg=msg..rpgo.StringColorize(rpgo.colorRed," not scanned")..".  - open your bank or 'character info' to scan";
				else
					for _,item in pairs(tsort) do
						msg=msg .. " " .. item.."]"..self.state["Inventory"][item]["inv"].."/"..self.state["Inventory"][item]["slot"];
					end
				end
			rpgo.PrintMsg("  " .. msg);

				msg="Bank:";
				tsort={};
				table.foreach(self.state["Bank"], function(k,v) table.insert(tsort,k) end );
				table.sort(tsort);
				if(table.getn(tsort)==0) then
					msg=msg..rpgo.StringColorize(rpgo.colorRed," not scanned")..".  - open your bank to scan";
				else
					for _,item in pairs(tsort) do
						msg=msg .. " " .. item.."]"..self.state["Bank"][item]["inv"].."/"..self.state["Bank"][item]["slot"];
					end
				end
			rpgo.PrintMsg("  " .. msg);

--WotLK
			if( GetNumCompanions ) then 
				msg="Companions:";
				tsort={};
				table.foreach(self.state["Companions"], function(k,v) table.insert(tsort,k) end );
				table.sort(tsort);
				if(table.getn(tsort)==0) then
					msg=msg..rpgo.StringColorize(rpgo.colorRed," not scanned");
				else
					for _,item in pairs(tsort) do
						msg=msg .. " " .. item..":"..self.state["Companions"][item];
					end
				end
			rpgo.PrintMsg("  " .. msg);
			end

			if( (self:State("_class")=="HUNTER" and UnitLevel("player")>9) or self:State("_class")=="WARLOCK") then
				msg="Pets: ";
				tsort={};
				table.foreach(self.state["Pets"], function(k,v) table.insert(tsort,k) end );
				table.sort(tsort);
				if(table.getn(tsort)==0) then
					msg=msg..rpgo.StringColorize(rpgo.colorRed," not scanned");
				else
					for _,item in pairs(tsort) do
						msg=msg..item.." ";
						if(self.state["PetSpell"][item]) then
							msg=msg.."(spells:"..self.state["PetSpell"][item]..") ";
						end
					end
				end
				rpgo.PrintMsg("  " .. msg);
			end
		else
			self:PrintTitle(rpgo.StringColorize(rpgo.colorRed,"no character scanned"));
			rpgo.PrintMsg("    to scan open your character frame ('C')");
			rpgo.PrintMsg("    or force the export with '/cp export'");
		end
	else
		self:PrefToggle("enabled");
	end
end

--[[########################################################
--## rpgoCP data functions
--######################################################--]]
function RPGOCP.GetVersion()
	local _,_,version,major,minor=string.find(RPGOCP.VERSION,"^(%d+).(%d+).(%d+)");
	return tonumber(version) + tonumber(major)/100 + tonumber(minor)/10000;
end
function RPGOCP.GetServers()
	local tbl={};
	for server in pairs(myProfile) do
		table.insert(tbl,server);
	end
	table.sort(tbl);
	return tbl;
end
function RPGOCP.GetCharacters(server)
	local tbl={};
	server = server or RPGOCP.state["_server"];
	if( myProfile[server]["Character"] ) then
		for char in pairs(myProfile[server]["Character"]) do
			table.insert(tbl,char);
		end
	end
	table.sort(tbl);
	return tbl;
end
function RPGOCP.GetGuilds(server)
	local tbl={};
	server = server or RPGOCP.state["_server"];
	if( myProfile[server]["Guild"] ) then
		for guild in pairs(myProfile[server]["Guild"]) do
			table.insert(tbl,guild);
		end
	end
	table.sort(tbl);
	return tbl;
end
function RPGOCP.GetParam(param,profile,server)
	server = server or RPGOCP.state["_server"];
	profile = profile or RPGOCP.state["_player"];
	if ( not param ) then
		return nil;
	elseif( not myProfile or not myProfile[server] ) then
		return nil;
	end

	local db;
	if( myProfile[server]["Character"][profile] ) then
		db = myProfile[server]["Character"][profile];
	elseif( myProfile[server]["Guild"][profile] ) then
		db = myProfile[server]["Guild"][profile];
	else
		return nil;
	end

	if( db[param] ) then
		return db[param];
	else
		param = string.lower(param);
		for k,v in pairs(db) do
			if(param == string.lower(k)) then
				return db[k];
			end
		end
	end
	return "none";
end
--[[########################################################
--## rpgoCP CPapi functions
--######################################################--]]
CPapi={};
CPapi.GetVersion	= RPGOCP.GetVersion;
CPapi.GetServers	= RPGOCP.GetServers;
CPapi.GetCharacters	= RPGOCP.GetCharacters;
CPapi.GetParam		= RPGOCP.GetParam;

--[[########################################################
--## OverLoaded functions
--######################################################--]]
--[Quit]
local rpgo_Quit_old=Quit;
function Quit()
	if(RPGOCP.prefs and RPGOCP.prefs["enabled"] and RPGOCP:State("_loaded")) then
		RPGOCP:EventHandler('RPGOCP_SCAN');
		RequestTimePlayed();
	end
	return rpgo_Quit_old();
end
--[ForceQuit]
local rpgo_ForceQuit_old=ForceQuit;
function ForceQuit()
	if(RPGOCP.prefs and RPGOCP.prefs["enabled"] and RPGOCP:State("_loaded")) then
		RPGOCP:EventHandler('RPGOCP_SCAN');
		RequestTimePlayed();
	end
	return rpgo_ForceQuit_old();
end
--[Logout]
local rpgo_Logout_old=Logout;
function Logout()
	if(RPGOCP.prefs and RPGOCP.prefs["enabled"] and RPGOCP:State("_loaded")) then
		RPGOCP:EventHandler('RPGOCP_SCAN');
		RequestTimePlayed();
	end
	return rpgo_Logout_old();
end
--[PetAbandon]
local rpgo_PetAbandon_old=PetAbandon;
function PetAbandon()
	local state = RPGOCP.state;
	local db = myProfile[state["_server"]]["Character"][state["_player"]];
	if(RPGOCP.prefs and RPGOCP.prefs["enabled"]) then
		local petName=UnitName("pet");
		if( petName and petName~=UNKNOWN ) then
			if (state["Stable"][petName]) then
				state["Stable"][petName]=nil; end
			if (state["Pets"][petName]) then
				state["Pets"][petName]=nil; end
			if (state["PetSpell"][petName]) then
				state["PetSpell"][petName]=nil; end
			if (db["Pets"] and db["Pets"][petName]) then
				db["Pets"][petName]=nil;
				if( db["timestamp"]["Pets"][petName] ) then
					db["timestamp"]["Pets"][petName]=nil;
				end
			end
		end
	end
	return rpgo_PetAbandon_old();
end
--[PetRename]
local rpgo_PetRename_old=PetRename;
function PetRename(petNameNew)
	local state = RPGOCP.state;
	local db = myProfile[state["_server"]]["Character"][state["_player"]];
	if(RPGOCP.prefs and RPGOCP.prefs["enabled"]) then
		petNameOld=UnitName("pet");
		if( petNameOld and petNameOld~=UNKNOWN ) then
			if (state["Stable"][petNameOld]) then
				state["Stable"][petNameNew]={};
				rpgo.tablecopy(state["Stable"][petNameNew], state["Stable"][petNameOld]);
				state["Stable"][petNameOld]=nil;
			end
			if (state["Pets"][petNameOld]) then
				state["Pets"][petNameNew] = state["Pets"][petNameOld];
				state["Pets"][petNameOld]=nil;
			end
			if (state["PetSpell"][petNameOld]) then
				state["PetSpell"][petNameNew] = state["PetSpell"][petNameOld];
				state["PetSpell"][petNameOld]=nil;
			end
			if (db["Pets"] and db["Pets"][petNameOld]) then
				db["Pets"][petNameNew]={};
				rpgo.tablecopy(db["Pets"][petNameNew], db["Pets"][petNameOld]);
				db["Pets"][petNameOld]=nil;
				if( db["timestamp"]["Pets"][petNameOld] ) then
					db["timestamp"]["Pets"][petNameNew]=db["timestamp"]["Pets"][petNameOld];
					db["timestamp"]["Pets"][petNameOld]=nil;
				end
			end
		end
	end
	return rpgo_PetRename_old(petNameNew);
end

--[[########################################################
--## rpgoCP Extract functions
--######################################################--]]
--[GetGuild]
function RPGOCP:GetGuild(force)
	if( not IsInGuild() ) then
		self:State("Guild",0);
		self.db["Guild"]=nil;
		return;
	end
	local numGuildMembers=GetNumGuildMembers();
	if(force or not self:State("Guild") or self:State("GuildNum")~=numGuildMembers) then
		local guildName,guildRankName,guildRankIndex=GetGuildInfo("player");
		if(guildName) then
			self.db["Guild"]={
				Name=guildName,
				Title=guildRankName,
				Rank=guildRankIndex};
			self:State("Guild",1);
			self:State("GuildNum",numGuildMembers);
		end
	end
end

--[GetSkills]
function RPGOCP:GetSkills()
	if(not self.prefs["scan"]["skills"]) then
		self.db["Skills"]=nil;
		return;
	end
	local TRADE_SKILLS2;
	self.db["Skills"]={};
	self:State("Skills",0);self:State("_skills",{});
	local toCollapse={};
	for idx=GetNumSkillLines(),1,-1 do
		local _,isHeader,isExpanded,_,_,_,_,_,_,_,_,_=GetSkillLineInfo(idx);
		if(isHeader and not isExpanded) then
			table.insert(toCollapse,idx);
			ExpandSkillHeader(idx);
		end
	end

	local skillheader,order,structSkill = nil,1,self.db["Skills"];
	for idx=1,GetNumSkillLines() do
		local skillName,isHeader,isExpanded,skillRank,numTempPoints,skillModifier,skillMaxRank,isAbandonable,stepCost,rankCost,minLevel,skillCostType,skillDescription = GetSkillLineInfo(idx);
		if(isHeader==1) then
			skillheader=skillName;
			structSkill[skillheader]={Order=order};
			TRADE_SKILLS2 = strsub(SECONDARY_SKILLS,1,strlen(skillheader));
			order=order+1;
		elseif(skillheader) then
			structSkill[skillheader][skillName]=strjoin(":", skillRank,skillMaxRank);
			if(skillheader==TRADE_SKILLS or skillheader==TRADE_SKILLS2) then
				self.state["_skills"][skillName]=skillRank;
			end
		end
		self:State("Skills",'++');
	end

	table.sort(toCollapse);
	for _,idx in pairs(toCollapse) do
		CollapseSkillHeader(idx);
	end
end

--[GetReputation]
function RPGOCP:GetReputation()
	if(not self.prefs["scan"]["reputation"]) then
		self.db["Reputation"]=nil;
		return;
	end
	self.db["Reputation"]={};
	self:State("Reputation",0);
	local toCollapse={};
	for idx=GetNumFactions(),1,-1 do
		local _,_,_,_,_,_,_,_,isHeader,isCollapsed=GetFactionInfo(idx);
		if(isHeader and isCollapsed) then
			table.insert(toCollapse,idx);
			ExpandFactionHeader(idx);
		end
	end

	local thisHeader,numFactions,structRep = NONE,GetNumFactions(),self.db["Reputation"];
	structRep["Count"]=numFactions;
	for idx=1,numFactions do
		local name,description,standingId,bottomValue,topValue,earnedValue,atWarWith,canToggleAtWar,isHeader,isCollapsed,isWatched,isSubGroup = GetFactionInfo(idx);
		if(isHeader) then
			thisHeader=name;
			structRep[thisHeader]={};
		elseif(standingId) then
			structRep[thisHeader][name]={
				Standing = getglobal("FACTION_STANDING_LABEL"..standingId),
				AtWar = atWarWith or 0,
				Value = earnedValue-bottomValue..":"..topValue-bottomValue};
		end
		self:State("Reputation",'++');
	end

	table.sort(toCollapse);
	for _,idx in pairs(toCollapse) do
		CollapseFactionHeader(idx);
	end
end

--[GetHonor]
function RPGOCP:GetHonor()
	if(not self.prefs["scan"]["honor"]) then
		self.db["Honor"]=nil;
		return;
	end
	local lifetimeHK,lifetimeRank=GetPVPLifetimeStats();
	if(self:State("Honor")~=lifetimeHK) then
		if (not self.db["Honor"]) then
			self.db["Honor"]={}; end
		local structHonor=self.db["Honor"];
		local rankName,rankNumber=GetPVPRankInfo(lifetimeRank);
		local sessionHK,sessionCP=GetPVPSessionStats();
		if ( not rankName ) then rankName=NONE; end
		structHonor["Lifetime"]={
			Rank=rankNumber,
			Name=rankName,
			HK=lifetimeHK};
		structHonor["Current"]={
			Rank=0,
			Name=NONE,
			Icon="",
			Progress=0,
			HonorPoints=GetHonorCurrency(),
			ArenaPoints=GetArenaCurrency()
			};
		structHonor["Session"]={HK=sessionHK,CP=sessionCP};
		structHonor["Yesterday"]=rpgo.Arg2Tab("HK","CP",GetPVPYesterdayStats());

		self:State("Honor",lifetimeHK);
	end
end

function RPGOCP:ScanCurrency(force)
	if( not GetCurrencyListSize ) then return end;
	if(not self.prefs["scan"]["currency"]) then
		self.db["Currency"]=nil;
		return;
	end

	local toCollapse={};
	for idx=GetCurrencyListSize(),1,-1 do
		local _,isHeader,isExpanded=GetCurrencyListInfo(idx);
		if(isHeader and not isExpanded) then
			table.insert(toCollapse,idx);
			ExpandCurrencyList(idx,1);
		end
	end

	if( force or (self:State("Currency")~=GetCurrencyListSize()) ) then
		if (not self.db["Currency"]) then
			self.db["Currency"]={}; end
		local structCurrency = self.db["Currency"];
		local thisHeader;
		local cnt = 0;
		local name,isHeader,isExpanded,isUnused,isWatched,count,extraCurrencyType,icon;
		for idx=1,GetCurrencyListSize() do
			name,isHeader,isExpanded,isUnused,isWatched,count,extraCurrencyType,icon = GetCurrencyListInfo(idx);
			if ( name and name ~= "" ) then
				if ( isHeader ) then
					thisHeader=name;
					structCurrency[thisHeader]={};
				else
					if ( extraCurrencyType ~= 0 ) then
						icon = TokenFrameContainer.buttons[idx].icon:GetTexture();
					end
					self.tooltip:SetCurrencyToken(idx)
					if( not isWatched ) then
						isWatched=nil;
					end
					
					structCurrency[thisHeader][name] = {
						Name	= name,
						Watched	= isWatched,
						Count	= count,
						Type	= extraCurrencyType,
						Icon	= rpgo.scanIcon(icon),
						Tooltip	= self:ScanTooltip()
					};
				end
				cnt=cnt+1;
			end
		end
		self:State("Currency",cnt);
	end

	table.sort(toCollapse);
	for _,idx in pairs(toCollapse) do
		ExpandCurrencyList(idx,0);
	end
	RPGOCP.frame:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE");
	RPGOCP.frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
end

function RPGOCP:GetArena()
	if(not self.prefs["scan"]["honor"]) then
		self.db["Honor"]=nil;
		return;
	end
	PVPFrame_Update();
	local arenaGames = 0;
	local ARENA_TEAMS = {};
	ARENA_TEAMS[1] = {size = 2};
	ARENA_TEAMS[2] = {size = 3};
	ARENA_TEAMS[3] = {size = 5};
	for index,value in pairs(ARENA_TEAMS) do
		for i=1, MAX_ARENA_TEAMS do
			ArenaTeamRoster(i);
			local _, teamSize, _, _, _, seasonTeamPlayed = GetArenaTeam(i);
			if ( value.size == teamSize ) then
				value.index = i;
				arenaGames = arenaGames + seasonTeamPlayed;
			end
		end
	end
	if (not self.db["Honor"]) then
		self.db["Honor"]={}; end
	structHonor = self.db["Honor"];
	if(self:State("Arena")~=arenaGames) then
		arenaGames = 0;
		for index,value in pairs(ARENA_TEAMS) do
			local key = value.size..'v'..value.size;
			if ( value.index ) then
				if(not structHonor[key]) then
					structHonor[key] = {}; end
				local teamName, teamSize, teamRating, teamPlayed, teamWins, seasonTeamPlayed, seasonTeamWins, playerPlayed, seasonPlayerPlayed, teamRank, playerRating = GetArenaTeam(value.index);
				structHonor[key]['Name'] = teamName;
				structHonor[key]['Size'] = teamSize;
				structHonor[key]['Rating'] = teamRating;
				structHonor[key]['Rank'] = teamRank;
				structHonor[key]['PlayerRating'] = playerRating;
				structHonor[key]['Week'] = {Games=teamPlayed,Wins=teamWins,Played=playerPlayed};
				structHonor[key]['Season'] = {Games=seasonTeamPlayed,Wins=seasonTeamWins,Played=seasonPlayerPlayed};

				local teamNumMembers = GetNumArenaTeamMembers(value.index,true);
				if( teamNumMembers ~= 0 ) then
					structHonor[key]['NumMembers'] = teamNumMembers;
					arenaGames = arenaGames + seasonTeamPlayed;
				elseif( not structHonor[key]['NumMembers'] ) then
					structHonor[key]['NumMembers'] = '';
				end
			else
				structHonor[key]=nil;
			end
		end
		self:State("Arena",arenaGames);
	end
end

--[GetTalents]
function RPGOCP:GetTalents(unit)
	if(not self.prefs["scan"]["talents"] or UnitLevel("player") < 10 ) then
		self.db["Talents"]=nil; return;
	end
	unit = unit or "player";

	local numTabs,numPts,state,petName;
	local structTalent={};
	if ( unit == "pet" ) then
		petName = UnitName("pet");
		numPts = GetPetTalentPoints();
		numTabs = 1;
		--to remove
		self.db["Pets"][petName]["TalentPointsUsed"]=nil;
		self.db["Pets"][petName]["TalentPoints"]=numPts;
		--self.db["Pets"][petName]["Talents"]={};
		--structTalent=self.db["Pets"][petName]["Talents"];
		state = "PetTalents";
	else
		numPts = UnitCharacterPoints("player");
		numTabs=GetNumTalentTabs();
		self.db["TalentPoints"]=numPts;
		--self.db["Talents"]={};
		--structTalent=self.db["Talents"];
		state = "Talents";
	end

	if( (self:State(state)~=numTabs+numPts) ) then
		local tabName,iconTexture,pointsSpent,background;
		local nameTalent,iconTexture,tier,column,currentRank,maxRank,isExceptional,meetsPrereq;
		for tabIndex=1,numTabs do
			tabName,iconTexture,pointsSpent,background = GetTalentTabInfo(tabIndex,nil,unit=="pet");
			if(not self.prefs["fixicon"]) then
				background="Interface\\TalentFrame\\"..background; end
			structTalent[tabName]={
				Background=background,
				PointsSpent=pointsSpent,
				Order=tabIndex
				};
			for talentIndex=1,GetNumTalents(tabIndex,nil,unit=="pet") do
				nameTalent,iconTexture,tier,column,currentRank,maxRank,isExceptional,meetsPrereq = GetTalentInfo(tabIndex,talentIndex,nil,unit=="pet");
				if(nameTalent and (currentRank > 0 or self.prefs["talentsfull"]) ) then
					self.tooltip:SetTalent(tabIndex,talentIndex)
					structTalent[tabName][nameTalent]={
						TalentId= rpgo.GetTalentID( GetTalentLink(tabIndex,talentIndex) ),
						Rank	= strjoin(":", currentRank,maxRank),
						Location= strjoin(":", tier,column),
						Icon	= rpgo.scanIcon(iconTexture),
						Tooltip	= self:ScanTooltip()
						};
				end
			end
			self:State(state,'++');
		end
		if ( unit == "pet" ) then
			self.db["Pets"][petName]["Talents"]=structTalent;
		else
			self.db["Talents"]=structTalent;
		end
	end
end

--[GetQuests]
function RPGOCP:GetQuests(force)
	if(not self.prefs["scan"]["quests"]) then
		self.db["Quests"]=nil;
		return;
	end

	local selected=GetQuestLogSelection();
	local toCollapse={};
	for idx=GetNumQuestLogEntries(),1,-1 do
		_,_,_,_,isHeader,isCollapsed,_ = GetQuestLogTitle(idx);
		if(isHeader and isCollapsed) then
			table.insert(toCollapse,idx);
			ExpandQuestHeader(idx);
		end
	end

	local numEntries,numQuests=GetNumQuestLogEntries();
	--QuestLogFrame\GetDifficultyColor(level)
	local function GetDifficultyValue(level)
		local levelDiff = level - UnitLevel("player");
		local color
		if ( levelDiff >= 5 ) then
			color = 4;
		elseif ( levelDiff >= 3 ) then
			color = 3;
		elseif ( levelDiff >= -2 ) then
			color = 2;
		elseif ( -levelDiff <= GetQuestGreenRange() ) then
			color = 1;
		else
			color = 0;
		end
		return color;
	end

	if( force or (self:State("QuestsLog")~=numEntries) ) then
		self.db["Quests"]={};
		self:State("Quests",0);self:State("QuestsLog",0);
		local slot,num,header,structQuest = 1,nil,UNKNOWN,self.db["Quests"];
		for idx=1,numEntries do
			local questDescription,questObjective;
			local questId = rpgo.GetQuestID( GetQuestLink(idx) );
			local questTitle,questLevel,questTag,suggestedGroup,isHeader,isCollapsed,isComplete,isDaily = GetQuestLogTitle(idx);
			if(questTitle) then
				if(isHeader) then
					header=questTitle;
					if(not structQuest[header]) then
						structQuest[header]={}
					end
				else
					SelectQuestLogEntry(idx);
					if(suggestedGroup and tonumber(suggestedGroup) and suggestedGroup<=1) then
						suggestedGroup=nil;
					end
					if(self.prefs["questsfull"]) then
						questDescription,questObjective = GetQuestLogQuestText(idx);
					end
					structQuest[header][slot]={
						QuestId	=questId,
						Title	=questTitle,
						Level	=questLevel,
						Complete=isComplete,
						Daily	=isDaily,
						Tag		=questTag,
						Difficulty=GetDifficultyValue(questLevel),
						Group=suggestedGroup,
						Description=questDescription,
						Objective=questObjective};

					num=GetNumQuestLeaderBoards(idx);
					if(num and num > 0) then
						structQuest[header][slot]["Tasks"]={};
						for idx2=1,num do
							structQuest[header][slot]["Tasks"][idx2]=rpgo.Arg2Tab("Note","Type","Done",GetQuestLogLeaderBoard(idx2,idx));
						end
					end
					num=GetQuestLogRewardMoney(idx);
					if(num and num > 0) then
						structQuest[header][slot]["RewardMoney"]=num;
					end
					num=GetNumQuestLogRewards(idx);
					if(num and num > 0) then
						structQuest[header][slot]["Rewards"]={};
						for idx2=1,num do
							_,curItemTexture,itemCount,_,_=GetQuestLogRewardInfo(idx2);
							self.tooltip:SetQuestLogItem("reward",idx2);
							table.insert(structQuest[header][slot]["Rewards"],self:ScanItemInfo(GetQuestLogItemLink("reward",idx2),curItemTexture,itemCount));
						end
					end
					num=GetNumQuestLogChoices(idx);
					if(num and num > 0) then
						structQuest[header][slot]["Choice"]={};
						for idx2=1,num do
							_,curItemTexture,itemCount,_,_=GetQuestLogChoiceInfo(idx2);
							self.tooltip:SetQuestLogItem("choice",idx2);
							table.insert(structQuest[header][slot]["Choice"],self:ScanItemInfo(GetQuestLogItemLink("choice",idx2),curItemTexture,itemCount));
						end
					end
					slot=slot+1;
					self:State("Quests",'++');
				end
			end
			self:State("QuestsLog",'++');
		end
	end

	table.sort(toCollapse);
	for _,idx in pairs(toCollapse) do
		CollapseQuestHeader(idx);
	end
	SelectQuestLogEntry(selected);
end

	--[GetStats]
	function RPGOCP:GetStats(structStats,unit)
		unit = unit or "player";
		if( unit=="player" and (UnitIsDeadOrGhost("player") or rpgo.UnitHasResSickness("player")) ) then
			return
		end
		if(not structStats["Attributes"]) then structStats["Attributes"]={}; end
		structStats["Level"]=UnitLevel(unit);
		structStats["Health"]=UnitHealthMax(unit);
		structStats["Mana"]=UnitManaMax(unit);
		structStats["Power"]=UnitPower[UnitPowerType(unit)];
		structStats["Attributes"]["Stats"]={};
		for i=1,table.getn(UnitStatName) do
			local stat,effectiveStat,posBuff,negBuff=UnitStat(unit,i);
			structStats["Attributes"]["Stats"][UnitStatName[i]] = strjoin(":", (stat - posBuff - negBuff),posBuff,negBuff);
		end
		local base,posBuff,negBuff,modBuff,effBuff,stat;
		base,modBuff = UnitDefense(unit);
		posBuff,negBuff = 0,0;
		if ( modBuff > 0 ) then
			posBuff = modBuff;
		elseif ( modBuff < 0 ) then
			negBuff = modBuff;
		end
		structStats["Attributes"]["Defense"] = {};
		structStats["Attributes"]["Defense"]["Defense"] = strjoin(":", base,posBuff,negBuff);
		base,effBuff,stat,posBuff,negBuff=UnitArmor(unit);
		structStats["Attributes"]["Defense"]["Armor"] = strjoin(":", base,posBuff,negBuff);
		structStats["Attributes"]["Defense"]["ArmorReduction"] = PaperDollFrame_GetArmorReduction(effBuff, UnitLevel("player"));
		base,posBuff,negBuff = GetCombatRating(CR_DEFENSE_SKILL),rpgo.round(GetCombatRatingBonus(CR_DEFENSE_SKILL),2),0;
		structStats["Attributes"]["Defense"]["DefenseRating"]=strjoin(":", base,posBuff,negBuff);
		structStats["Attributes"]["Defense"]["DefensePercent"]=GetDodgeBlockParryChanceFromDefense();
		base,posBuff,negBuff = GetCombatRating(CR_DODGE),rpgo.round(GetCombatRatingBonus(CR_DODGE),2),0;
		structStats["Attributes"]["Defense"]["DodgeRating"]=strjoin(":", base,posBuff,negBuff);
		structStats["Attributes"]["Defense"]["DodgeChance"]=rpgo.round(GetDodgeChance(),2);
		base,posBuff,negBuff = GetCombatRating(CR_BLOCK),rpgo.round(GetCombatRatingBonus(CR_BLOCK),2),0;
		structStats["Attributes"]["Defense"]["BlockRating"]=strjoin(":", base,posBuff,negBuff);
		structStats["Attributes"]["Defense"]["BlockChance"]=rpgo.round(GetBlockChance(),2);
		base,posBuff,negBuff = GetCombatRating(CR_PARRY),rpgo.round(GetCombatRatingBonus(CR_PARRY),2),0;
		structStats["Attributes"]["Defense"]["ParryRating"]=strjoin(":", base,posBuff,negBuff);
		structStats["Attributes"]["Defense"]["ParryChance"]=rpgo.round(GetParryChance(),2);
		structStats["Attributes"]["Defense"]["Resilience"]={};
		structStats["Attributes"]["Defense"]["Resilience"]["Melee"]=GetCombatRating(CR_CRIT_TAKEN_MELEE);
		structStats["Attributes"]["Defense"]["Resilience"]["Ranged"]=GetCombatRating(CR_CRIT_TAKEN_RANGED);
		structStats["Attributes"]["Defense"]["Resilience"]["Spell"]=GetCombatRating(CR_CRIT_TAKEN_SPELL);

		structStats["Attributes"]["Resists"]={};
		for i=1,table.getn(UnitResistanceName) do
			local base,resistance,positive,negative=UnitResistance(unit,i);
			structStats["Attributes"]["Resists"][UnitResistanceName[i]] = strjoin(":", base,positive,negative);
		end
		if(unit=="player") then
			structStats["Hearth"]=GetBindLocation();
			structStats["Money"]=rpgo.Arg2Tab("Gold","Silver","Copper",rpgo.parseMoney(GetMoney()));
			structStats["IsResting"]=IsResting() == 1 or false;
			structStats["Experience"]=strjoin(":", UnitXP("player"),UnitXPMax("player"),GetXPExhaustion() or 0);
			self:GetAttackRating(structStats["Attributes"],unit);
			self.db["timestamp"]["Attributes"]=time();
		else
			self:GetAttackRatingOld(structStats["Attributes"],unit,"Pet");
		end
	end

	function RPGOCP:CharacterDamageFrame(damageFrame)
		damageFrame = damageFrame or getglobal("PlayerStatFrameLeft1");
		if (not damageFrame.damage) then return; end
		self.tooltip:ClearLines();
		-- Main hand weapon
		self.tooltip:SetText(INVTYPE_WEAPONMAINHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		self.tooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2f", damageFrame.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		self.tooltip:AddDoubleLine(DAMAGE_COLON, damageFrame.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		self.tooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1f", damageFrame.dps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		-- Check for offhand weapon
		if ( damageFrame.offhandAttackSpeed ) then
			self.tooltip:AddLine("\n");
			self.tooltip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			self.tooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2f", damageFrame.offhandAttackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			self.tooltip:AddDoubleLine(DAMAGE_COLON, damageFrame.offhandDamage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			self.tooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1f", damageFrame.offhandDps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
	end

	function RPGOCP:CharacterRangedDamageFrame(damageFrame)
		damageFrame = damageFrame or getglobal("PlayerStatFrameLeft1");
		if (not damageFrame.damage) then return; end
		self.tooltip:ClearLines();
		self.tooltip:SetText(INVTYPE_RANGED, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		self.tooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2f", damageFrame.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		self.tooltip:AddDoubleLine(DAMAGE_COLON, damageFrame.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		self.tooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1f", damageFrame.dps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	function RPGOCP:GetAttackRating(structAttack,unit,prefix)
		unit = unit or "player";
		prefix = prefix or "PlayerStatFrameLeft";
		UpdatePaperdollStats(prefix, "PLAYERSTAT_MELEE_COMBAT");

		local stat = getglobal(prefix.."1");
		local statText = getglobal(prefix.."1".."StatText");

		local mainHandAttackBase,mainHandAttackMod,offHandAttackBase,offHandAttackMod = UnitAttackBothHands(unit);
		local speed,offhandSpeed = UnitAttackSpeed(unit);
		structAttack["Melee"]={};
		structAttack["Melee"]["MainHand"]={};
		structAttack["Melee"]["MainHand"]["AttackSpeed"]=rpgo.round(speed,2);
		structAttack["Melee"]["MainHand"]["AttackDPS"]=rpgo.round(stat.dps,1);
		structAttack["Melee"]["MainHand"]["AttackSkill"]=mainHandAttackBase+mainHandAttackMod;
		structAttack["Melee"]["MainHand"]["AttackRating"]=strjoin(":", mainHandAttackBase,mainHandAttackMod,0);

		local tt=statText:GetText();
		tt=rpgo.StripColor(tt);
		structAttack["Melee"]["MainHand"]["DamageRange"]=string.gsub(tt,"^(%d+)%s?-%s?(%d+)$","%1:%2");

		local _,_,dmgMin,dmgMax,dmgBonus = string.find(stat.damage,"^(%d+)%s?%-%s?(%d+)(.*)$");
		structAttack["Melee"]["MainHand"]["DamageRangeBase"]=strjoin(":", dmgMin,dmgMax);
		structAttack["Melee"]["MainHand"]["DamageRangeBonus"]=dmgBonus;

		self:CharacterDamageFrame();
		local tt=self:ScanTooltip();
		structAttack["Melee"]["DamageRangeTooltip"]=rpgo.StripColor(tt);

		if ( offhandSpeed ) then
			structAttack["Melee"]["OffHand"]={};
			structAttack["Melee"]["OffHand"]["AttackSpeed"]=rpgo.round(offhandSpeed,2);
			structAttack["Melee"]["OffHand"]["AttackDPS"]=rpgo.round(stat.offhandDps,1);
			structAttack["Melee"]["OffHand"]["AttackSkill"]=offHandAttackBase+offHandAttackMod;
			structAttack["Melee"]["OffHand"]["AttackRating"]=strjoin(":", offHandAttackBase,offHandAttackMod,0);

			tt=stat.offhandDamage;
			tt=rpgo.StripColor(tt);
			structAttack["Melee"]["OffHand"]["DamageRange"]=string.gsub(tt,"^(%d+)%s?-%s?(%d+)","%1:%2");
		else
			structAttack["Melee"]["OffHand"]=nil;
		end
		local stat4 = getglobal(prefix.."4");
		local base,posBuff,negBuff;
		base,posBuff,negBuff = UnitAttackPower(unit);
		structAttack["Melee"]["AttackPower"] = strjoin(":", base,posBuff,negBuff);
		structAttack["Melee"]["AttackPowerDPS"]=rpgo.round(max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER,1);
		structAttack["Melee"]["AttackPowerTooltip"]=stat4.tooltip2;
		base,posBuff,negBuff = GetCombatRating(CR_EXPERTISE),rpgo.round(GetCombatRatingBonus(CR_EXPERTISE),2),0;
		structAttack["Melee"]["Expertise"]=strjoin(":", base,posBuff,negBuff);
		base,posBuff,negBuff = GetCombatRating(CR_HIT_MELEE),rpgo.round(GetCombatRatingBonus(CR_HIT_MELEE),2),0;
		structAttack["Melee"]["HitRating"]=strjoin(":", base,posBuff,negBuff);
		base,posBuff,negBuff = GetCombatRating(CR_CRIT_MELEE),rpgo.round(GetCombatRatingBonus(CR_CRIT_MELEE),2),0;
		structAttack["Melee"]["CritRating"]=strjoin(":", base,posBuff,negBuff);
		base,posBuff,negBuff = GetCombatRating(CR_HASTE_MELEE),rpgo.round(GetCombatRatingBonus(CR_HASTE_MELEE),2),0;
		structAttack["Melee"]["HasteRating"]=strjoin(":", base,posBuff,negBuff);

		structAttack["Melee"]["CritChance"]=rpgo.round(GetCritChance(),2);

		if(unit=="player") then
			if ( not GetInventoryItemTexture(unit,18) and not UnitHasRelicSlot(unit)) then
				structAttack["Ranged"]=nil;
			else
				UpdatePaperdollStats(prefix, "PLAYERSTAT_RANGED_COMBAT");
				local damageFrame = getglobal(prefix.."1");
				local damageFrameText = getglobal(prefix.."1".."StatText");

				if(PaperDollFrame.noRanged) then
					structAttack["Ranged"]=nil;
				else
					local rangedAttackSpeed,minDamage,maxDamage,physicalBonusPos,physicalBonusNeg,percent = UnitRangedDamage(unit);
					structAttack["Ranged"]={};
					structAttack["Ranged"]["AttackSpeed"]=rpgo.round(rangedAttackSpeed,2);
					structAttack["Ranged"]["AttackDPS"]=rpgo.round(damageFrame.dps,1);
					structAttack["Ranged"]["AttackSkill"]=UnitRangedAttack(unit);
					local rangedAttackBase,rangedAttackMod = UnitRangedAttack(unit);
					structAttack["Ranged"]["AttackRating"]=strjoin(":", rangedAttackBase,rangedAttackMod,0);

					tt=damageFrameText:GetText();
					tt=rpgo.StripColor(tt);
					structAttack["Ranged"]["DamageRange"]=string.gsub(tt,"^(%d+)%s?-%s?(%d+)","%1:%2");
					local _,_,dmgMin,dmgMax,dmgBonus = string.find(stat.damage,"^(%d+)%s?%-%s?(%d+)(.*)$");
					structAttack["Ranged"]["DamageRangeBase"]=strjoin(":", dmgMin,dmgMax);
					structAttack["Ranged"]["DamageRangeBonus"]=dmgBonus;

					base,posBuff,negBuff = GetCombatRating(CR_HIT_RANGED),rpgo.round(GetCombatRatingBonus(CR_HIT_RANGED),2),0;
					structAttack["Ranged"]["HitRating"]=strjoin(":", base,posBuff,negBuff);
					base,posBuff,negBuff = GetCombatRating(CR_CRIT_RANGED),rpgo.round(GetCombatRatingBonus(CR_CRIT_RANGED),2),0;
					structAttack["Ranged"]["CritRating"]=strjoin(":", base,posBuff,negBuff);
					base,posBuff,negBuff = GetCombatRating(CR_HASTE_RANGED),rpgo.round(GetCombatRatingBonus(CR_HASTE_RANGED),2),0;
					structAttack["Ranged"]["HasteRating"]=strjoin(":", base,posBuff,negBuff);
					structAttack["Ranged"]["CritChance"]=rpgo.round(GetRangedCritChance(),2);

					self:CharacterRangedDamageFrame();
					local tt=self:ScanTooltip();
					tt=rpgo.StripColor(tt);
					structAttack["Ranged"]["DamageRangeTooltip"]=tt;
					local base,posBuff,negBuff=UnitRangedAttackPower(unit);
					apDPS=base/ATTACK_POWER_MAGIC_NUMBER;
					structAttack["Ranged"]["AttackPower"] = strjoin(":", base,posBuff,negBuff);
					structAttack["Ranged"]["AttackPowerDPS"]=rpgo.round(apDPS,1);
					structAttack["Ranged"]["AttackPowerTooltip"]=format(RANGED_ATTACK_POWER_TOOLTIP,apDPS);
					structAttack["Ranged"]["HasWandEquipped"]=false;
				end
			end
			structAttack["Spell"] = {};
			structAttack["Spell"]["BonusHealing"] = GetSpellBonusHealing();
			local holySchool = 2;
			local minCrit = GetSpellCritChance(holySchool);
			structAttack["Spell"]["School"]={};
			structAttack["Spell"]["SchoolCrit"]={};
			for i=holySchool,MAX_SPELL_SCHOOLS do
				bonusDamage = GetSpellBonusDamage(i);
				spellCrit = GetSpellCritChance(i);
				minCrit = min(minCrit,spellCrit);
				structAttack["Spell"]["School"][UnitSchoolName[i]] = bonusDamage;
				structAttack["Spell"]["SchoolCrit"][UnitSchoolName[i]] = rpgo.round(spellCrit,2);
			end
			structAttack["Spell"]["CritChance"] = rpgo.round(minCrit,2);

			structAttack["Spell"]["BonusDamage"]=GetSpellBonusDamage(holySchool);
			base,posBuff,negBuff = GetCombatRating(CR_HIT_SPELL),rpgo.round(GetCombatRatingBonus(CR_HIT_SPELL),2),0;
			structAttack["Spell"]["HitRating"]=strjoin(":", base,posBuff,negBuff);
			base,posBuff,negBuff = GetCombatRating(CR_CRIT_SPELL),rpgo.round(GetCombatRatingBonus(CR_CRIT_SPELL),2),0;
			structAttack["Spell"]["CritRating"]=strjoin(":", base,posBuff,negBuff);
			base,posBuff,negBuff = GetCombatRating(CR_HASTE_SPELL),rpgo.round(GetCombatRatingBonus(CR_HASTE_SPELL),2),0;
			structAttack["Spell"]["HasteRating"]=strjoin(":", base,posBuff,negBuff);
			structAttack["Spell"]["Penetration"] = GetSpellPenetration();
			local base,casting = GetManaRegen();
			base = floor( (base * 5.0) + 0.5);
			casting = floor( (casting * 5.0) + 0.5);
			structAttack["Spell"]["ManaRegen"] = strjoin(":", base,casting);
		end
		PaperDollFrame_UpdateStats();
	end

	function RPGOCP:GetAttackRatingOld(structAttack,unit,prefix)
		if(not unit) then unit="pet"; end
		if(not prefix) then prefix="Pet"; end

		PaperDollFrame_SetDamage(PetDamageFrame, "Pet");
		PaperDollFrame_SetArmor(PetArmorFrame, "Pet");
		PaperDollFrame_SetAttackPower(PetAttackPowerFrame, "Pet");

		local damageFrame = getglobal(prefix.."DamageFrame");
		local damageText = getglobal(prefix.."DamageFrameStatText");
		local mainHandAttackBase,mainHandAttackMod = UnitAttackBothHands(unit);

		structAttack["Melee"]={};
		structAttack["Melee"]["MainHand"]={};
		structAttack["Melee"]["MainHand"]["AttackSpeed"]=rpgo.round(damageFrame.attackSpeed,2);
		structAttack["Melee"]["MainHand"]["AttackDPS"]=rpgo.round(damageFrame.dps,1);
		structAttack["Melee"]["MainHand"]["AttackRating"]=mainHandAttackBase+mainHandAttackMod;

		local tt=damageText:GetText();
		tt=rpgo.StripColor(tt);
		structAttack["Melee"]["MainHand"]["DamageRange"]=string.gsub(tt,"^(%d+)%s?-%s?(%d+)$","%1:%2");

		self:CharacterDamageFrame();
		local tt=self:ScanTooltip();
		tt=rpgo.StripColor(tt);
		structAttack["Melee"]["DamageRangeTooltip"]=tt;
		local base,posBuff,negBuff = UnitAttackPower(unit);
		apDPS=max((base+posBuff+negBuff),0)/ATTACK_POWER_MAGIC_NUMBER;
		structAttack["Melee"]["AttackPower"] = strjoin(":", base,posBuff,negBuff);
		structAttack["Melee"]["AttackPowerDPS"]=rpgo.round(apDPS,1);
		structAttack["Melee"]["AttackPowerTooltip"]=format(MELEE_ATTACK_POWER_TOOLTIP,apDPS);
	end

--[GetBuffs]
function RPGOCP:GetBuffs(structBuffs,unit)
	unit = unit or "player";
	local idx=1;
	if(not structBuffs["Attributes"]) then structBuffs["Attributes"]={}; end
	local function strNil(str)
		if(str and str=="") then return nil
		else return str
		end
	end
	local function numNil(num)
		if(num and num<=1) then return nil
		else return num
		end
	end
	if(UnitBuff(unit,idx)) then
		structBuffs["Attributes"]["Buffs"]={};
		while(UnitBuff(unit,idx)) do
			local name,rank,iconTexture,count,duration,timeLeft = UnitBuff(unit,idx);
			self.tooltip:SetUnitBuff(unit,idx);
			structBuffs["Attributes"]["Buffs"][idx]={
				Name	= name,
				Rank	= strNil(rank),
				Count	= numNil(count),
				Icon	= rpgo.scanIcon(iconTexture),
				Tooltip	= self:ScanTooltip()};
			idx=idx+1
		end
	else
		structBuffs["Attributes"]["Buffs"]=nil;
	end
	idx=1;
	if(UnitDebuff(unit,idx)) then
		structBuffs["Attributes"]["Debuffs"]={};
		while(UnitDebuff(unit,idx)) do
			local name,rank,iconTexture,count,debuffType,duration,timeLeft = UnitDebuff(unit,idx);
			self.tooltip:SetUnitDebuff(unit,idx);
			structBuffs["Attributes"]["Debuffs"][idx]={
				Name	= name,
				Rank	= strNil(rank),
				Count	= numNil(count),
				Icon	= rpgo.scanIcon(iconTexture),
				Tooltip	= self:ScanTooltip()};
			idx=idx+1
		end
	else
		structBuffs["Attributes"]["Debuffs"]=nil;
	end
end

function RPGOCP:GetEquipment(force)
	if(not self.prefs["scan"]["equipment"]) then
		self.db["Equipment"]=nil;
		return;
	end
	if( force or self:State("Equipment")==0 or not self:State("_eq") ) then
		self.db["Equipment"]={};
		self:State("Equipment",0)
		local structEquip=self.db["Equipment"];
		for index,slot in pairs(UnitSlots) do
			local itemLink,itemCount;
			local itemTexture = GetInventoryItemTexture("player",index);
			self.tooltip:SetInventoryItem("player",index);
			itemLink = GetInventoryItemLink("player",index);
			if(itemLink) then
				itemCount=GetInventoryItemCount("player",index);
				if(itemCount == 1) then itemCount=nil; end
				structEquip[slot]=self:ScanItemInfo(itemLink,itemTexture,itemCount);
				self.state["Equipment"]=self.state["Equipment"]+1;
				itemLink=nil;
			end
		end
		self.db["timestamp"]["Equipment"]=time();
		self:State("_eq",true);
		self.frame:RegisterEvent("UNIT_INVENTORY_CHANGED");
	end
	self:GetStats(self.db);
end

function RPGOCP:GetInventory()
	if(not self.prefs["scan"]["inventory"]) then
		self.db["Inventory"]=nil;
		return;
	elseif(not self.db["Inventory"]) then
		self.db["Inventory"]={};
		self:State("Inventory",{});
	end
	local structInventory=self.db["Inventory"];
	local containers={};
	for bagid=0,NUM_BAG_FRAMES do
		table.insert(containers,bagid);
	end
	if(HasKey and HasKey()) then
		table.insert(containers,KEYRING_CONTAINER);
	end
	for bagidx,bagid in pairs(containers) do
		bagidx=bagidx-1;
		if(not self.state["Inventory"][bagidx] or not self.state["Bag"][bagid]) then
			structInventory["Bag"..bagidx]=self:ScanContainer("Inventory",bagidx,bagid);
		end
	end
	self.db["timestamp"]["Inventory"]=time();
end

function RPGOCP:GetBank()
	if(not self.prefs["scan"]["bank"]) then
		self.db["Bank"]=nil;
		return;
	elseif(not self:State("_bank")) then
		return;
	elseif(not self.db["Bank"]) then
		self.db["Bank"]={};
		self:State("Bank",{});
	end
	local structBank=self.db["Bank"];
	local containers={};
	table.insert(containers,BANK_CONTAINER);
	for bagid=1,NUM_BANKBAGSLOTS do
		table.insert(containers,bagid+NUM_BAG_SLOTS);
	end

	for bagidx,bagid in pairs(containers) do
		bagidx=bagidx-1;
		if(not self.state["Bank"][bagidx] or not self.state["Bag"][bagid]) then
			structBank["Bag"..bagidx]=self:ScanContainer("Bank",bagidx,bagid);
		end
	end
	self.db["timestamp"]["Bank"]=time();
end

function RPGOCP:ScanContainer(invgrp,bagidx,bagid)
	local itemColor,itemID,itemName,itemIcon,itemLink;
	if(bagid==0) then
		itemName=GetBagName(bagid);
		itemIcon="Button-Backpack-Up";
		if(not self.prefs["fixicon"]) then
			itemIcon="Interface\\Buttons\\"..itemIcon; end
		self.tooltip:SetText(itemName);
		self.tooltip:AddLine(format(CONTAINER_SLOTS,rpgo.GetContainerNumSlots(bagid),BAGSLOT));
	elseif(bagid==BANK_CONTAINER) then
		itemName = "Bank Contents";
		self.tooltip:ClearLines();
	elseif(bagid==KEYRING_CONTAINER) then
		itemName = KEYRING;
		itemIcon="UI-Button-KeyRing";
		if(not self.prefs["fixicon"]) then
			itemIcon="Interface\\Buttons\\"..itemIcon; end
		self.tooltip:SetText(itemName);
	else
		itemColor,_,itemID,itemName=rpgo.GetItemInfo( GetInventoryItemLink("player",ContainerIDToInventoryID(bagid)) );
		itemIcon=GetInventoryItemTexture("player",ContainerIDToInventoryID(bagid));
		self.tooltip:SetInventoryItem("player",ContainerIDToInventoryID(bagid))
	end


	local bagInv,bagSlot=0,rpgo.GetContainerNumSlots(bagid);
	if(bagSlot==nil or bagSlot==0) then
		self.state[invgrp][bagidx]=nil
		return nil;
	end
	local container={
		Name	= itemName,
		Color	= rpgo.scanColor(itemColor),
		Slots	= rpgo.GetContainerNumSlots(bagid),
		Item	= itemID,
		Icon	= rpgo.scanIcon(itemIcon),
		Tooltip	= self:ScanTooltip(),
		Contents= {}
		};
	for slot=1,bagSlot do
		local itemLink=GetContainerItemLink(bagid,slot);
		if(itemLink) then
			local itemIcon,itemCount,_,_=GetContainerItemInfo(bagid,slot);
			if(bagid==BANK_CONTAINER) then
				self.tooltip:SetInventoryItem("player",BankButtonIDToInvSlotID(slot));
			elseif(bagid==KEYRING_CONTAINER) then
				self.tooltip:SetInventoryItem("player",KeyRingButtonIDToInvSlotID(slot));
			else
				self.tooltip:SetBagItem(bagid,slot);
			end
			container["Contents"][slot]=self:ScanItemInfo(itemLink,itemIcon,itemCount);
			bagInv=bagInv+1;
		end
	end
	if(not self:State("_bag")) then
		self.frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
		self.frame:RegisterEvent("BAG_UPDATE");
		self:State("_bag",true);
	end
	self.state["Bag"][bagid]=true;
	self.state[invgrp][bagidx]={slot=bagSlot,inv=bagInv};
	return container
end

function RPGOCP.GetMail(idxStart)
	if(not RPGOCP.prefs["scan"]["mail"]) then
		RPGOCP.db["MailBox"]=nil;
		return;
	end
	if(RPGOCP:State("_mail")) then
		local numMessages=GetInboxNumItems();
		if( not RPGOCP:State("Mail") and not idxStart and numMessages==0 ) then
			rpgo.qInsert(RPGOCP.queue, {"MAIL_INBOX_UPDATE",RPGOCP.GetMail,1} );
		end
		if( not RPGOCP:State("Mail") or RPGOCP:State("Mail")~=numMessages ) then
			idxStart = idxStart or 1;
			if( not RPGOCP:State("Mail") or idxStart==1) then
				RPGOCP.db["MailBox"]={};
				RPGOCP:State("Mail",0);
			end
			local structMail=RPGOCP.db["MailBox"];
			for idx=idxStart,numMessages do
				local packageIcon,stationeryIcon,mailSender,mailSubject,mailCoin,_,daysLeft,itemCount,wasRead=GetInboxHeaderInfo(idx);
				structMail[idx]={
					Sender	= mailSender or UNKNOWN,
					Subject	= mailSubject,
					MailIcon= rpgo.scanIcon(packageIcon or stationeryIcon),
					Days	= daysLeft,
					Read	= wasRead,
				};
				if( mailCoin ~= 0 ) then
					structMail[idx]["Coin"] = mailCoin;
					structMail[idx]["CoinIcon"] = rpgo.scanIcon(GetCoinIcon(mailCoin));
				end

				if( itemCount ) then
					structMail[idx]["Attachments"] = itemCount;
					structMail[idx]["Contents"] = {};
					for i=1, ATTACHMENTS_MAX_RECEIVE do
						local itemstr,itemIcon,itemQty,_,_ = GetInboxItem(idx,i);
						if ( itemstr ) then
							itemstr=GetInboxItemLink(idx,i);
							RPGOCP.tooltip:SetHyperlink(itemstr);
							structMail[idx]["Contents"][i]=RPGOCP:ScanItemInfo(itemstr,itemIcon,itemQty);
						end
					end
					if ( itemCount ~= table.count(structMail[idx]["Contents"]) ) then
						rpgo.qInsert(RPGOCP.queue, {"MAIL_INBOX_UPDATE",RPGOCP.GetMail,idx} );
						return;
					end
				end
				if( mailSender ) then
					RPGOCP:State("Mail",'++');
				end
			end
			RPGOCP.db["timestamp"]["MailBox"]=time();
		end
	end
end

function RPGOCP:GetSpellBook()
	if(not self.prefs["scan"]["spells"]) then
		self.db["SpellBook"]=nil;
		return;
	end
	if ( not self.db["SpellBook"] ) then
		self.db["SpellBook"]={};
	end
	local structSpell=self.db["SpellBook"];
	for spellTab=1,GetNumSpellTabs() do
		local spellTabname,spellTabtexture,offset,numSpells=GetSpellTabInfo(spellTab);
		local cnt=0;
		if(not self.state["SpellBook"][spellTabname] or self.state["SpellBook"][spellTabname]~=numSpells) then
			structSpell[spellTabname]={
					Icon	= rpgo.scanIcon(spellTabtexture),
					Spells	= {},
					};
			self.state["SpellBook"][spellTabname]=0;
			cnt=0;
			for spellId=1+offset,numSpells+offset do
				local spellName=GetSpellName(spellId,BOOKTYPE_SPELL);
				if ( spellName ) then
					structSpell[spellTabname]["Spells"][spellName] = self:ScanSpellInfo(spellId,BOOKTYPE_SPELL);
					cnt=cnt+1;
				end
			end
			self.state["SpellBook"][spellTabname]=cnt;
			structSpell[spellTabname]["Count"]=numSpells;
		end
		self.db["timestamp"]["SpellBook"]=time();
	end
end

function RPGOCP:ScanCompanions()
--WotLK
	if( not GetNumCompanions) then return; end

	if(self.prefs["scan"]["companions"]) then
		local crittertypes={"Critter","Mount"};

		if(not self.db["Companions"]) then
			self.db["Companions"]={};
		end
		if(not self.db["timestamp"]["Companions"]) then
			self.db["timestamp"]["Companions"]={};
		end
		local structCompanion=self.db["Companions"];

		for index,companionType in pairs(crittertypes) do
			local numCompanions = GetNumCompanions(companionType);
			if(not self.db["Companions"][companionType]) then
				self.db["Companions"][companionType]={};
			end

			if( self.state["Companions"][companionType] ~= numCompanions ) then
				self.state["Companions"][companionType] = 0;
				for companionIndex=1,numCompanions do
					local creatureID,creatureName,spellID,icon,active = GetCompanionInfo(companionType,companionIndex);
					if(creatureName and creatureName~=UNKNOWN) then
						self.tooltip:SetHyperlink("spell:" ..spellID,BOOKTYPE_SPELL)
						structCompanion[companionType][companionIndex] = {
							Name		= creatureName,
							CreatureID	= creatureID,
							SpellId		= spellID,
							Active		= active,
							Icon		= rpgo.scanIcon(icon),
							Tooltip		= self:ScanTooltip(),
						};
					end
					self.state["Companions"][companionType] = self.state["Companions"][companionType]+1;
				end
				self.db["timestamp"]["Companions"][companionType] = time();
			end
		end
	elseif(self.db) then
		self.db["Companions"]=nil;
		self.state["Companions"]={};
	end
end

function RPGOCP:ScanGlyphs(startGlyph)
--WotLK
	if( not GetNumGlyphSockets) then return; end

	if(self.prefs["scan"]["glyphs"]) then
		if(not self.db["Glyphs"]) then
			self.db["Glyphs"]={};
		end
		local numGlyphs;
		if( not startGlyph ) then
			startGlyph = 1;
			numGlyphs=GetNumGlyphSockets();
		else
			numGlyphs=startGlyph;
			self.state["Glyphs"] = self.state["Glyphs"]-1;
		end
		
		if( startGlyph==numGlyphs or self.state["Glyphs"]==0 ) then
			local structGlyph=self.db["Glyphs"];
			for index=startGlyph,numGlyphs do
				local enabled, glyphType, glyphSpell, icon = GetGlyphSocketInfo(index);
				if(enabled == 1 and glyphSpell) then
					self.tooltip:SetGlyph(index);
					structGlyph[index] = {
						Name	= GetSpellInfo(glyphSpell),
						Type	= glyphType,
						Icon	= rpgo.scanIcon(icon),
						Tooltip	= self:ScanTooltip(),
					};
					self.state["Glyphs"] = self.state["Glyphs"]+1;
				else
					structGlyph[index] = nil;
				end
			end
			self.db["timestamp"]["Glyphs"]=time();
		end
	elseif(self.db) then
		self.db["Glyphs"] = nil;
		self.state["Glyphs"] = 0;
	end
end

function RPGOCP.GetTradeSkill(idxStart,idxHeader,txtHeader)
	if(not RPGOCP.prefs["scan"]["professions"]) then
		RPGOCP.db["Professions"]=nil;
		return;
	end
	local skillLineName,skillLineRank,skillLineMaxRank=GetTradeSkillLine();
	if(not skillLineName or skillLineName=="" or skillLineName==UNKNOWN) then
		return;
	end

	local setHaveMaterials = getglobal("TradeSkillFrameAvailableFilterCheckButton"):GetChecked();
	TradeSkillOnlyShowMakeable(nil);
	getglobal("TradeSkillFrameEditBox"):SetText(SEARCH);
	SetTradeSkillItemNameFilter(nil);
	TradeSkillFrame_Update();

	--view
	local selected=GetTradeSkillSelectionIndex();
	local toCollapse={};
	for idx=GetNumTradeSkills(),1,-1 do
		_,skillType,_,isExpanded=GetTradeSkillInfo(idx);
		if( skillType=="header" and not isExpanded ) then
			table.insert(toCollapse,idx);
			ExpandTradeSkillSubClass(idx);
		end
	end

	if ( not RPGOCP.db["Professions"] ) then
		RPGOCP.db["Professions"]={};
	end
	if ( not RPGOCP.db["timestamp"]["Professions"] ) then
		RPGOCP.db["timestamp"]["Professions"]={};
	end

	local structProf=RPGOCP.db["Professions"];
	local stateProf=RPGOCP.state["Professions"];
	local numTradeSkills = GetNumTradeSkills();

	if(numTradeSkills>0 and (not stateProf[skillLineName] or numTradeSkills~=stateProf[skillLineName]) ) then
		if(not structProf[skillLineName] or not stateProf[skillLineName]) then
			structProf[skillLineName]={};
		end

		local skillHeader,skillName,skillType;
		local cooldown;
		local reagents={};
		local skillIcon;
		local itemColor,itemLink;
		local tt;
		local reagentName,reagentCount;
		local itemID;
		local lastHeaderIdx;
		local db;

		if( idxStart and idxHeader and txtHeader ) then
			skillName,skillType=GetTradeSkillInfo(idxHeader);
			if( skillType=="header" and skillName~="" and skillName==txtHeader ) then
				lastHeaderIdx = idxHeader;
				skillHeader=skillName;
				db = structProf[skillLineName][skillHeader];
			end
		else
			idxStart = 1;
			structProf[skillLineName]={};
		end

		stateProf[skillLineName] = idxStart-1;

		for idx=idxStart,numTradeSkills do
			skillName,skillType=GetTradeSkillInfo(idx);
			if( skillName and skillName~="" ) then
				if( skillType=="header" ) then
					lastHeaderIdx = idx;
					skillHeader=skillName;
					if( not structProf[skillLineName][skillHeader] ) then
						structProf[skillLineName][skillHeader]={};
					end
					db = structProf[skillLineName][skillHeader];
				elseif( skillHeader ) then
					cooldown,numMade=nil,nil;
					reagents={};
					itemColor,_,itemLink,_ = rpgo.GetItemInfo(GetTradeSkillItemLink(idx));

					for ridx=1,GetTradeSkillNumReagents(idx) do
						reagentName,_,reagentCount,_=GetTradeSkillReagentInfo(idx,ridx);
						if(not reagentName) then
							rpgo.qInsert(RPGOCP.queue, {"TRADE_SKILL_UPDATE",RPGOCP.GetTradeSkill,idx,lastHeaderIdx,skillHeader} );
							return;
						end

						if(RPGOCP.prefs["reagentfull"]) then
							itemID = rpgo.GetItemID(GetTradeSkillReagentItemLink(idx,ridx));
							table.insert(reagents, {
								Name=reagentName,
								Count=reagentCount,
								itemID=itemID
								});
						else
							table.insert(reagents, reagentName .. " x" .. reagentCount);
						end
					end

					if(not RPGOCP.prefs["reagentfull"]) then
						reagents = table.concat(reagents,"<br>");
					end
					if(not MarsProfessionOrganizer_SetTradeSkillItem) then
						RPGOCP.tooltip:SetTradeSkillItem(idx);
					end
					if(GetTradeSkillCooldown) then
						cooldown = GetTradeSkillCooldown(idx);
						if(cooldown) then
							RPGOCP.tooltip:AddLine(COOLDOWN_REMAINING.." "..SecondsToTime(cooldown));
						end
					end

					skillIcon=GetTradeSkillIcon(idx) or "";
					numMade = GetTradeSkillNumMade(idx);
					if( numMade==1 ) then numMade=nil; end

					db[skillName]={
						RecipeID= rpgo.GetRecipeId( GetTradeSkillRecipeLink(idx) ),
						Icon	= rpgo.scanIcon(skillIcon),
						Difficulty= TradeSkillCode[skillType],
						Item	= itemLink,
						Count	= numMade,
						Color	= rpgo.scanColor(itemColor),
						Tooltip	= RPGOCP:ScanTooltip(),
						Reagents= reagents,
						};

					if(cooldown and cooldown ~= 0) then
						db[skillName]["Cooldown"]=cooldown;
						db[skillName]["DateUTC"]=date("!%Y-%m-%d %H:%M:%S");
						db[skillName]["timestamp"]=time();
					end
				else
						rpgo.qInsert(RPGOCP.queue, {"TRADE_SKILL_UPDATE",RPGOCP.GetTradeSkill,idx,lastHeaderIdx,skillHeader} );
						return;
				end
				stateProf[skillLineName]=stateProf[skillLineName]+1;
			else
						return;
			end
		end
		RPGOCP:TidyProfessions();
		RPGOCP.db["timestamp"]["Professions"][skillLineName]=time();
	end

	--view
	table.sort(toCollapse);
	for _,idx in pairs(toCollapse) do
		CollapseTradeSkillSubClass(idx);
	end
	SelectTradeSkill(selected);
	TradeSkillOnlyShowMakeable(setHaveMaterials);
end

function RPGOCP:TidyProfessions()
	for skillName in pairs(self.db["Professions"]) do
		if(not self.state["_skills"][skillName]) then
			self.db["Professions"][skillName]=nil;
		end
	end
end

function RPGOCP:ScanPetInit(name)
	if(name) then
		if(not self.db["Pets"]) then
			self.db["Pets"]={};
		end
		if(not self.db["Pets"][name]) then
			self.db["Pets"][name]={};
		end
		if(not self.db["timestamp"]["Pets"]) then
			self.db["timestamp"]["Pets"]={};
		end
	end
end

function RPGOCP:ScanPetStable()
	if(self.prefs["scan"]["pet"] and (self:State("_class")=="HUNTER" and UnitLevel("player")>9)) then
		local stablePets={};
		for petIndex=0,GetNumStableSlots() do
			local petIcon,petName,petLevel,petType,petLoyalty=GetStablePetInfo(petIndex);
			if(petName and petName~=UNKNOWN) then
				self:ScanPetInit(petName);
				local structPets=self.db["Pets"];
				structPets[petName]["Slot"]=petIndex;
				structPets[petName]["Icon"]=rpgo.scanIcon(petIcon);
				structPets[petName]["Name"]=petName;
				structPets[petName]["Level"]=petLevel;
				structPets[petName]["Type"]=petType;
				structPets[petName]["Loyalty"]=petLoyalty;
				stablePets[petName]=petIndex;
				self.db["timestamp"]["Pets"][petName]=time();
			end
			self.state["Stable"][petIndex]=petName;
		end
		for petName,_ in pairs( self.db["Pets"] ) do
			if( not stablePets[petName] ) then
				self.db["Pets"][petName]=nil;
			end
		end
		for petName,_ in pairs( self.db["timestamp"]["Pets"] ) do
			if( not stablePets[petName] ) then
				self.db["timestamp"]["Pets"][petName]=nil;
			end
		end
		self:ScanPetInfo();
	elseif(self.db) then
		self.db["Pets"]=nil;
		self.state["Pets"]={};
	end
end

function RPGOCP:ScanPetInfo()
	if(self.prefs["scan"]["pet"]) then
		if(HasPetUI()) then
			local petName=UnitName("pet");
			if( petName and petName~=UNKNOWN ) then
				self:ScanPetInit(petName);
				local structPet=self.db["Pets"][petName];
				structPet["Name"]=petName;
				structPet["Type"]=UnitCreatureFamily("pet");
				structPet["Experience"]=strjoin(":", GetPetExperience());
				self:GetStats(structPet,"pet");
				self:GetBuffs(structPet,"pet");
				
--WotLK
			if( GetPetTalentPoints and (self:State("_class")=="HUNTER" and UnitLevel("player")>9) ) then
				self:GetTalents("pet");
			end
				self:GetPetSpellBook();
				self.state["Pets"][petName]=1;
				self.db["timestamp"]["Pets"][petName]=time();
			end
		end
	elseif(self.db) then
		self.db["Pets"]=nil;
		self.state["Pets"]={};
	end
end

function RPGOCP:GetPetSpellBook()
	if(self.prefs["scan"]["spells"]) then
		local petName=UnitName("pet");
		if( petName and petName~=UNKNOWN ) then
			numSpells,_=HasPetSpells();
			if( numSpells ) then
				self:ScanPetInit(petName);
				if (not self.db["Pets"][petName]["SpellBook"]) then
					self.db["Pets"][petName]["SpellBook"]={};
				end
				local structPetSpell=self.db["Pets"][petName]["SpellBook"];
				if (not structPetSpell["Spells"]) then
					structPetSpell["Spells"]={};
				end

				local cnt=0;
				for petSpellId=1,numSpells do
					local spellName=GetSpellName(petSpellId,BOOKTYPE_PET);
					if ( spellName ) then
						structPetSpell["Spells"][spellName] = self:ScanSpellInfo(petSpellId,BOOKTYPE_PET);
						cnt=cnt+1;
					end
				end
				structPetSpell["Count"]=cnt;
				self.state["PetSpell"][petName]=cnt;
			end
		end
	end
end

function RPGOCP:UpdatePlayed(arg1,arg2)
	if(self.state["_loaded"] and self.db) then
		self.db["TimePlayed"] = arg1 or -1;
		self.db["TimeLevelPlayed"] = arg2 or -1;
	end
end

function RPGOCP:UpdateZone()
	if(self.state["_loaded"] and self.db) then
		self.db["Zone"]=GetZoneText();
		self.db["SubZone"]=GetSubZoneText();
	end
end

function RPGOCP:UpdateBagScan(bagid)
	if(bagid~=nil and self.state["Bag"][bagid]) then
		self.state["Bag"][bagid]=nil;
		if(bagid==BANK_CONTAINER) then
			self.frame:UnregisterEvent("PLAYERBANKSLOTS_CHANGED");
		elseif(table.maxn(self.state["Bag"])==0) then
			self:State("_bag",nil);
			self.frame:UnregisterEvent("BAG_UPDATE");
		end
	end
end

function RPGOCP:UpdateEqScan(unit)
	if(unit=="player" and self:State("_eq") ) then
		self:State("_eq",nil);
		self.frame:UnregisterEvent("UNIT_INVENTORY_CHANGED");
	end
end

function RPGOCP:GetProfileDate(server,char)
	local thisProfile,thisEpoch;
	if(myProfile and myProfile[server] and myProfile[server]["Character"] and myProfile[server]["Character"][char]) then
		thisProfile=myProfile[server]["Character"][char];
		if(thisProfile["timestamp"] and thisProfile["timestamp"]["init"] and thisProfile["timestamp"]["init"]["TimeStamp"]) then
			thisEpoch=thisProfile["timestamp"]["init"]["TimeStamp"];
		end
		if(thisEpoch) then
			return date("%Y-%m-%d",thisEpoch);
		end
	end
	return "";
end

--[[## general rpgo functions
--######################################################--]]
--[function] idx,bookType
function RPGOCP:ScanSpellInfo(idx,bookType)
	if(not idx or not bookType ) then return end
	
	local spellName,spellRank=GetSpellName(idx,bookType);
	local spellTexture=GetSpellTexture(idx,bookType);
	self.tooltip:SetSpell(idx,bookType);
	if( spellRank and spellRank == "" ) then
		spellRank = nil;
	end
	local structSpellInfo={
		SpellId	= rpgo.GetSpellID( GetSpellLink( spellName,spellRank ) ),
		Icon	= rpgo.scanIcon(spellTexture),
		Rank	= spellRank,
		Tooltip	= self:ScanTooltip()
	};
	return structSpellInfo;
end

--[function] itemlink,itemtexture,itemcount
function RPGOCP:ScanItemInfo(itemstr,itemtexture,itemcount)
	local function numNil(num)
		if(self.prefs["fixquantity"] and num and num<=1) then return nil
		else return num
		end
	end
	if(itemstr) then
		local itemColor,itemLink,itemID,itemName,itemTexture=rpgo.GetItemInfo(itemstr);
		if(not itemName or not itemColor) then
			itemName,itemColor=rpgo.GetItemInfoTT(self.tooltip);
		end
		local itemBlock={
			Name	= itemName,
			Item	= itemID,
			Color	= rpgo.scanColor(itemColor),
			Quantity= numNil(itemcount),
			Icon	= rpgo.scanIcon(itemtexture or itemTexture),
			Tooltip	= self:ScanTooltip(),
			};
		if( rpgo.ItemHasGem(itemLink) ) then
			itemBlock["Gem"] = {};
			for gemID=1,3 do
				local _,gemItemLink = GetItemGem(itemLink,gemID);
				if(gemItemLink) then
					self.tooltip:SetHyperlink(gemItemLink);
					itemBlock["Gem"][gemID]=self:ScanItemInfo(gemItemLink,nil,1);
				end
			end
		end
		if(self.prefs["fixtooltip"] and itemBlock["Name"]==itemBlock["Tooltip"]) then
			itemBlock["Tooltip"]=nil end
		return itemBlock;
	end
	return nil;
end

RPGOCP:Init();
