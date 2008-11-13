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
	PROFILEDB	= "2.0.0";
	FRAME		= "rpgoCPframe";
	TOOLTIP		= "rpgoCPtooltip";
}
RPGOCP.PREFS={
	enabled=true,tooltip=true,tooltipshtml=true,fixtooltip=true,fixquantity=true,fixicon=true,fixcolor=true,reagentfull=true,talentsfull=true,questsfull=false,lite=true,button=true,debug=false,ver=020000,
	scan={inventory=true,talents=true,honor=true,reputation=true,spells=true,pet=true,equipment=true,mail=true,professions=true,skills=true,quests=true,bank=true},
};
RPGOCP.events={"PLAYER_LEVEL_UP","TIME_PLAYED_MSG",
	"CRAFT_SHOW","CRAFT_UPDATE","TRADE_SKILL_SHOW","TRADE_SKILL_UPDATE",
	"CHARACTER_POINTS_CHANGED",
	"BANKFRAME_OPENED","BANKFRAME_CLOSED","MAIL_SHOW","MAIL_CLOSED",
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
	{"/cp purge [all|server|char]","-- purge info"},
};
--[[## Events
--######################################################--]]
RPGOCP.event1={
	VARIABLES_LOADED =
		function()
			RPGOCP:InitPref();
			RPGOCP:InitState();
			RPGOCP:RegisterEvents();
			RPGOCP.frame:UnregisterEvent("VARIABLES_LOADED");
			return true;
		end,
};
RPGOCP.event2={
	CRAFT_UPDATE =
		function(a1,a2)
			RPGOCP:TradeTimer(a1,a2);
			return true;
		end,
	TRADE_SKILL_UPDATE =
		function(a1,a2)
			RPGOCP:TradeTimer(a1,a2);
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
RPGOCP.event3={
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
		end,
	MAIL_CLOSED =
		function()
			RPGOCP:GetMail();
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
		function()
			RPGOCP:GetSkills();
			RPGOCP:GetTradeSkill('trade');
		end,
	CRAFT_SHOW =
		function()
			RPGOCP:GetSkills();
			RPGOCP:GetTradeSkill('craft');
		end,
	PLAYER_LEVEL_UP =
		function()
			RPGOCP:UpdateProfile();
		end,
	QUEST_FINISHED =
		function()
			RPGOCP:GetQuests(force);
		end,
	UNIT_QUEST_LOG_CHANGED =
		function()
			RPGOCP:GetQuests(force);
		end,
	CHARACTER_POINTS_CHANGED =
		function()
			RPGOCP:GetTalents();
		end,
	PET_STABLE_CLOSED =
		function()
			RPGOCP:ScanPetStable();
		end,
};
RPGOCP.funcs={
	fixicon =
		function(a1)
			if(a1) then
				rpgo.scanIcon = function(str)
					if(not str) then return str; end
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
					if(not str) then return str; end
					local c;
					_,_,c = string.find(str,"%x%x(%x%x%x%x%x%x)");
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
local timePlayed=-1;
local timeLevelPlayed=-1;
local TradeSkillCode={optimal=4,medium=3,easy=2,trivial=1,header=0};
local UnitPower={"Rage","Focus","Energy","Happiness"};UnitPower[0]="Mana";
local UnitSlots={"Head","Neck","Shoulder","Shirt","Chest","Waist","Legs","Feet","Wrist","Hands","Finger0","Finger1","Trinket0","Trinket1","Back","MainHand","SecondaryHand","Ranged","Tabard"};UnitSlots[0]="Ammo";
local UnitStatName={"Strength","Agility","Stamina","Intellect","Spirit"};
local UnitSchoolName={"Physical","Holy","Fire","Nature","Frost","Shadow","Arcane"};
local UnitResistanceName={"Holy","Fire","Nature","Frost","Shadow","Arcane"};
--[[########################################################
--## rpgoCP Core Functions
--######################################################--]]
--[OnLoad]
function RPGOCP:Init()
	SLASH_RPGOCP1="/cp";
	SLASH_RPGOCP2="/rpgocp";
	SLASH_RPGOCP3="/profiler";
	SlashCmdList["RPGOCP"] = function(a1) return self:ChatCommand(a1) end;

	self.frame = CreateFrame("Frame",self.FRAME,CharacterNameFrame);
	self.frame:RegisterEvent("VARIABLES_LOADED");
	self.frame:SetScript("OnEvent", function() return self:EventHandler(event,arg1,arg2) end );
	self.frame:SetScript("OnHide" , function() return self:EventHandler('RPGOCP_SCAN') end );

	self.tooltip = CreateFrame("GameTooltip",self.TOOLTIP,UIParent,"GameTooltipTemplate");
	self.tooltip:SetOwner(UIParent,"ANCHOR_NONE");

	self:PrintTitle("loaded.",true,true);
end

--[EventHandler]
function RPGOCP:EventHandler(event,arg1,arg2)
	if(not event) then return end
	--if(rpgoDebugArg) then
	--	rpgoDebugArg(self.ABBR,event,arg1,arg2);
	--end

	if(RPGOCP.event1[event]) then
		local retVal=RPGOCP.event1[event](arg1,arg2);
		if(retVal~=nil) then return retVal; end
	end

	if( not self.prefs or not self.prefs.enabled ) then return; end
	if( self:LiteScan(event) ) then return; end
	if( RPGOCP.event2[event] ) then
		if( self:State("_loaded") ) then
			local retVal=RPGOCP.event2[event](arg1,arg2);
			if(retVal~=nil) then return retVal; end
		else return false; end
	end

	--debugprofilestart();
	--local mem=gcinfo();
	if( ( not self:State("_lock") ) ) then
		self:State("_lock",true);
		if(not self:State("_loaded")) then
			self:InitProfile();
		end
		if(RPGOCP.event3[event]) then
			RPGOCP.event3[event](arg1,arg2);
		end
		self:State("_lock",nil);
	end
	--self:PrintDebug("time",debugprofilestop().."ms",gcinfo()-mem.."kb");
end
rpgoCP_EventHandler = function(event,arg1,arg2) return RPGOCP:EventHandler(event,arg1,arg2) end ;

--[ChatCommand]
function RPGOCP:ChatCommand(argline)
--self:PrintDebug("ChatCommand ("..argline..") ");
	local argv=rpgo.Str2Ary(argline);
	if(argv and argv[1]) then
		local argcase = string.lower(argv[1]);
		table.remove(argv,1);
		if(self.command[argcase]) then
			return self.command[argcase](argv);
		elseif(self.PREFS[argcase]~=nil) then
			return self:TogglePref(argcase,argv[1]);
		end
	end
	self:PrintUsage();
	self:TogglePref("enabled");
end
--[InitState]
function RPGOCP:InitState()
--self:PrintDebug("InitState");
	local _,tmpClass=UnitClass("player");
	self.state = {
		_loaded=nil,_lock=nil,_bag=nil,_bank=nil,_mail=nil,
		_server=GetRealmName(),_player=UnitName("player"),_class=tmpClass,
		_skills={},
		Equipment=0,
		Guild=nil, GuildNum=nil,
		Skills=0,
		Talents=0,TalentPts=0,
		Reputation=0,
		Quests=0, QuestsLog=0,
		Mail=nil,
		Honor=0,
		Bag={},Inventory={},Bank={},
		Professions={}, SpellBook={},
		Pets={}, Stable={}, PetSpell={},
	};
end
--[InitPref]
function RPGOCP:InitPref()
	if(not self.PREFS) then return; end
	if(not rpgoCPpref) then rpgoCPpref={}; end
	self.prefs = rpgoCPpref;
--self:PrintDebug("InitPref");
	self:PrefTidy();
	self:PrefInit();

	self:ButtonHandle();
	self:FrameHookCreate();
	self.funcs["fixcolor"](self.prefs["fixcolor"]);
	self.funcs["fixicon"](self.prefs["fixicon"]);
	self:PrintDebug("running in DEBUG MODE");
end
--[Toggle]
function RPGOCP:Toggle(val)
	if( self.prefs["enabled"]~=val ) then
		self:TogglePref("enabled",val);
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
		self:TogglePref("enabled",val);
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
		local button = rpgoCPUISaveButton
		button:Hide();
	end
end
--[FrameHookCreate]
function RPGOCP:FrameHookCreate()
	rpgoCPSpellBook = CreateFrame("Frame","rpgoCPSpellBook",SpellBookFrame);
	rpgoCPSpellBook:SetScript("OnShow", function() return self:EventHandler('SPELLBOOK') end );

	function rpgoCPTradeSkillFrame_OnUpdate()
		if(TradeSkillFrame and TradeSkillFrame:IsVisible()) then
			self:EventHandler('TRADE_SKILL_UPDATE','TRADE_SKILL_UPDATE',arg1);
		end
	end
	rpgoCPTradeSkillFrame = CreateFrame("Frame","rpgoCPTradeSkillFrame",TradeSkillFrame);
	rpgoCPTradeSkillFrame:SetScript("OnUpdate", rpgoCPTradeSkillFrame_OnUpdate );

	function rpgoCPCraftFrame_OnUpdate()
		if(CraftFrame and CraftFrame:IsVisible()) then
			self:EventHandler('CRAFT_UPDATE','CRAFT_UPDATE',arg1);
		end
	end
	rpgoCPCraftFrame = CreateFrame("Frame","rpgoCPCraftFrame",CraftFrame);
	rpgoCPCraftFrame:SetScript("OnUpdate", rpgoCPCraftFrame_OnUpdate );
end
--[InitProfile]
function RPGOCP:InitProfile()
--self:PrintDebug("InitProfile");
	if( not myProfile ) then
		myProfile={}; end
	if( not myProfile[self.state["_server"]] ) then
		myProfile[self.state["_server"]]={}; end
	if( not myProfile[self.state["_server"]]["Character"] ) then
		myProfile[self.state["_server"]]["Character"]={}; end
	if( not myProfile[self.state["_server"]]["Character"][self.state["_player"]] ) then
		myProfile[self.state["_server"]]["Character"][self.state["_player"]]={}; end
	if( myProfile[self.state["_server"]][self.state["_player"]] ) then
		myProfile[self.state["_server"]][self.state["_player"]]=nil; end
	if( not self.db ) then
		self.db = myProfile[self.state["_server"]]["Character"][self.state["_player"]];
	end
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
		self.db["HasRelicSlot"]	=UnitHasRelicSlot("player")==1 or false;
		self:UpdateDate();
		self:State("_loaded",true);
	end
	return self:State("_loaded");
end
--[UpdateProfile]
function RPGOCP:UpdateProfile()
--self:PrintDebug("UpdateProfile");
	if( self:State("_bank") ) then
		self:GetBank();
	end
	if( self:State("_mail") ) then
		self:GetMail();
	end
	self:GetGuild(force);
	self:GetBuffs(self.db);
	self:GetInventory();
	self:GetEquipment();
	self:GetTalents();
	self:GetSkills();
	self:GetSpellBook();
	self:GetReputation();
	self:GetQuests();
	self:GetHonor();
	self:ScanPetInfo();
	self:UpdateZone();
	self:UpdatePlayed();
	self:UpdateDate();
end
--[ForceExport]
function RPGOCP:ForceExport()
	local tmpState=self.state;
	self:InitState();
	self.state["Bank"]=tmpState["Bank"];
	self.state["Mail"]=tmpState["Mail"];
	self.state["Professions"]=tmpState["Professions"];
	self.state["Pets"]=tmpState["Pets"];
	self.state["Stable"]=tmpState["Stable"];
	self.state["PetSpell"]=tmpState["PetSpell"];
	self.state["_litemsg"]=tmpState["_litemsg"];
	self.state["_bank"]=tmpState["_bank"];
	self.state["_mail"]=tmpState["_mail"];
	self:InitProfile();
	self:UpdateProfile();
	self:ScanPetInfo();
	self:Show();
end
--[Purge]
function RPGOCP:Purge(argv)
	local tmpPurged,msg;
	if(argv and argv[1]) then
		msg = " ["..argv[1].."]";
		if(myProfile) then
			if(argv[1]=="all") then
				myProfile=nil;
				tmpPurged=true;
			elseif(argv[1]=="char") then
				local charProfile=self:State("_player");
				if(argv[2]) then
					charProfile=argv[2]; end
				msg = msg.." '"..charProfile.."'";
				if(myProfile[self:State("_server")] and myProfile[self:State("_server")]["Character"] and myProfile[self:State("_server")]["Character"][charProfile]) then
					myProfile[self:State("_server")]["Character"][charProfile]=nil;
					tmpPurged=true;
				end
			elseif(argv[1]=="server") then
				local serverProfile=self:State("_server");
				if(argv[2]) then
					serverProfile=argv[2]; end
				msg = msg.." '"..serverProfile.."'";
				if(myProfile[serverProfile] and myProfile[serverProfile]["Character"]) then
					myProfile[serverProfile]["Character"]=nil;
					tmpPurged=true;
				end
			elseif(argv[1] and argv[2]) then
				msg = " '"..argv[2].."@"..argv[1].."'";
				if(myProfile[argv[1]] and myProfile[argv[1]]["Character"] and myProfile[argv[1]]["Character"][argv[2]]) then
					myProfile[argv[1]]["Character"][argv[2]]=nil;
					tmpPurged=true;
				elseif(myProfile[argv[2]] and myProfile[argv[2]]["Character"] and myProfile[argv[2]]["Character"][argv[1]]) then
					msg = " '"..argv[1].."@"..argv[2].."'";
					myProfile[argv[2]]["Character"][argv[1]]=nil;
					tmpPurged=true;
				end
			end
		end
	end
	if(not tmpPurged and not msg) then
		self:PrintTitle("Usage:  /cp purge [all|server|char]");
	else
		if(tmpPurged) then
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
	local server,guild,char;
	if(myProfile) then
		self:PrintTitle("stored character profiles");
		for _,server in pairs( self.GetServers() ) do
			rpgo.PrintMsg("  Server: "..server);
			for _,guild in pairs( self.GetGuilds(server) ) do
				rpgo.PrintMsg("    Guild: "..guild);
			end
			for _,char in pairs( self.GetCharacters(server) ) do
				rpgo.PrintMsg("    Char: "..char.." (L:" .. self.GetParam("Level",char,server) .. ")  "..self:GetProfileDate(server,char));
			end
		end
	else
		self:PrintTitle("no stored character profiles");
	end
end
--[Show]
function RPGOCP:Show()
	if(self.prefs["enabled"]) then
		if(self:State("_player") and self:State("_loaded")) then
			local msg="";
			local item;
			local tsort={};
				msg="Profile for: " .. self:State("_player") .. " @" .. self:State("_server");
				if(self.db["Level"]) then
					msg=msg.." (lvl "..self.db["Level"]..")"
				end
			self:PrintTitle(msg);

				if(self:State("Guild")==0) then
				elseif(self:State("Guild")) then
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
				if(self:State("Mail")) then
					msg=msg .. " Mail:" ..self:State("Mail");
				end
				if(self:State("Honor")~=0 and self.db["Honor"]["RankName"]) then
					msg=msg .. " Honor:" ..self.db["Honor"]["RankName"];
				else
					msg=msg .. " Honor:"..NONE;
				end
			rpgo.PrintMsg("  " .. msg);

				msg="Professions:";
				tsort={};
				table.foreach(self.state["Professions"], function (k,v) table.insert(tsort,k) end );
				table.sort(tsort);
				if(table.getn(tsort)==0) then
					msg=msg..rpgo.StringColorize(rpgo.colorRed," not scanned")..".   to scan: open each profession";
				else
					for _,item in pairs(tsort) do
						msg=msg .. " " .. item..":"..self.state["Professions"][item];
					end
				end
			rpgo.PrintMsg("  " .. msg);

				msg="Spells:";
				tsort={};
				table.foreach(self.state["SpellBook"], function(k,v) table.insert(tsort,k) end );
				table.sort(tsort);
				if(table.getn(tsort)==0) then
					msg=msg..rpgo.StringColorize(rpgo.colorRed," not scanned")..".   to scan: open your spellbook";
				else
					for _,item in pairs(tsort) do
						msg=msg .. " " .. item..":"..self.state["SpellBook"][item];
					end
				end
			rpgo.PrintMsg("  " .. msg);

				msg="Inventory:";
				tsort={};
				table.foreach(self.state["Inventory"], function(k,v) table.insert(tsort,k) end );
				table.sort(tsort);
				if(table.getn(tsort)==0) then
					msg=msg..rpgo.StringColorize(rpgo.colorRed," not scanned")..".   to scan: open your bank or 'character info'";
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
					msg=msg..rpgo.StringColorize(rpgo.colorRed," not scanned")..".   to scan: open your bank";
				else
					for _,item in pairs(tsort) do
						msg=msg .. " " .. item.."]"..self.state["Bank"][item]["inv"].."/"..self.state["Bank"][item]["slot"];
					end
				end
			rpgo.PrintMsg("  " .. msg);
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
		self:TogglePref("enabled");
	end
end

--[[########################################################
--## rpgoCP data functions
--######################################################--]]
function RPGOCP.GetVersion()
	local _,_,vVersion,vMajor,vMinor=string.find(RPGOCP.VERSION,"^(%d+).(%d+).(%d+)");
	return tonumber(vVersion) + tonumber(vMajor)/100 + tonumber(vMinor)/10000;
end
function RPGOCP.GetServers()
	local tbl={};
	for server in pairs(myProfile) do
		table.insert(tbl,server);
	end
	table.sort(tbl);
	return tbl
end
function RPGOCP.GetCharacters(server)
	if(not server) then
		server = GetRealmName() end
	local tbl={};
	for char in pairs(myProfile[server]["Character"]) do
		table.insert(tbl,char);
	end
	table.sort(tbl);
	return tbl;
end
function RPGOCP.GetGuilds(server)
	if(not server) then
		server = RPGOCP.state["_server"] end
	local tbl={};
	for guild in pairs(myProfile[server]["Guild"]) do
		table.insert(tbl,guild);
	end
	table.sort(tbl);
	return tbl;
end
function RPGOCP.GetParam(param,char,server)
	if(not server) then
		server = RPGOCP.state["_server"] end
	if(not char) then
		char = RPGOCP.state["_player"] end
	if ( not param ) then
		return nil; -- param
	elseif( not myProfile or not myProfile[server] or not myProfile[server]["Character"][char] ) then
		return nil; -- data
	end
	local val;
	local db = myProfile[server]["Character"][char];
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
rpgo_Quit_old=Quit;
function Quit()
	if(RPGOCP.prefs and RPGOCP.prefs["enabled"] and RPGOCP:State("_loaded")) then
		RPGOCP:EventHandler('RPGOCP_SCAN');
		RequestTimePlayed();
	end
	return rpgo_Quit_old();
end

--[Logout]
rpgo_Logout_old=Logout;
function Logout()
	if(RPGOCP.prefs and RPGOCP.prefs["enabled"] and RPGOCP:State("_loaded")) then
		RPGOCP:EventHandler('RPGOCP_SCAN');
		RequestTimePlayed();
	end
	return rpgo_Logout_old();
end

--[PetAbandon]
rpgo_PetAbandon_old=PetAbandon;
function PetAbandon()
	local state = RPGOCP.state;
	local db = myProfile[state["_server"]]["Character"][state["_player"]];
	if(RPGOCP.prefs and RPGOCP.prefs["enabled"]) then
		petName=UnitName("pet");
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
rpgo_PetRename_old=PetRename;
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
--self:PrintDebug("GetGuild");
	if( not IsInGuild() ) then
		self:State("Guild",0);
		self.db["Guild"]=nil;
		return;
	end
	local numGuildMembers=GetNumGuildMembers();
	if(force or not self:State("Guild") or self:State("GuildNum")~=numGuildMembers) then
--self:PrintDebug(" ==> scan");
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
--self:PrintDebug("GetSkills");
	if(not self.prefs["scan"]["skills"]) then
		self.db["Skills"]=nil;
		return;
	end
	local TRADE_SKILLS2;
	self.db["Skills"]={};
	self:State("Skills",0);self:State("_skills",{});
	local toCollapse={};
	for idx=GetNumSkillLines(),1,-1 do
		local skillName,isHeader,isExpanded,_,_,_,_,_,_,_,_,_=GetSkillLineInfo(idx);
		if(isHeader and not isExpanded) then
			table.insert(toCollapse,idx);
			ExpandSkillHeader(idx);
		end
	end

	local skillheader,order,structSkill = nil,1,self.db["Skills"];
	for idx=1,GetNumSkillLines() do
		local skillName,isHeader,isExpanded,skillRank,numTempPoints,skillModifier,skillMaxRank,isAbandonable,stepCost,rankCost,minLevel,skillCostType=GetSkillLineInfo(idx);
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

	table.sort(toCollapse)
	for _,idx in pairs(toCollapse) do
		CollapseSkillHeader(idx);
	end
end

--[GetReputation]
function RPGOCP:GetReputation()
--self:PrintDebug("GetReputation");
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

	local thisHeader,numFactions=NONE,GetNumFactions();
	local structRep=self.db["Reputation"];
	structRep["Count"]=numFactions;
	for idx=1,numFactions do
		local name,description,standingID,barMin,barMax,barValue,atWar,canToggle,isHeader,isCollapsed=GetFactionInfo(idx);
		if(not atWar) then atWar=0; end
		if(isHeader) then
			thisHeader=name;
			structRep[thisHeader]={};
		elseif(standingID) then
			structRep[thisHeader][name]={
				Standing = getglobal("FACTION_STANDING_LABEL"..standingID),
				AtWar = atWar,
				Value = barValue-barMin..":"..barMax-barMin};
		end
		self:State("Reputation",'++');
	end

	table.sort(toCollapse)
	for _,idx in pairs(toCollapse) do
		CollapseFactionHeader(idx);
	end
end

--[GetHonor]
function RPGOCP:GetHonor()
--self:PrintDebug("GetHonor");
	if(not self.prefs["scan"]["honor"]) then
		self.db["Honor"]=nil;
		return;
	end
	local lifetimeHK,lifetimeRank=GetPVPLifetimeStats();
	local sessionHK,sessionCP=GetPVPSessionStats();
	if(self:State("Honor")~=lifetimeHK+sessionCP) then
--self:PrintDebug(" ==> scan");
		self.db["Honor"]={};
		local currRankIcon,currRankProgress,structHonor="",0,self.db["Honor"];
		local rankName,rankNumber=GetPVPRankInfo(lifetimeRank);
		if ( not rankName ) then rankName=NONE; end
		structHonor["Lifetime"]={
			Rank=rankNumber,
			Name=rankName,
			HK=lifetimeHK};
		rankName,rankNumber=GetPVPRankInfo(UnitPVPRank("player"));
		if ( not rankName ) then rankName=NONE; end
		if ( rankNumber > 0 ) then
			currRankIcon=format("%s%02d","PvPRank",rankNumber);
			if(not self.prefs["fixicon"]) then
				texture="Interface\\PvPRankBadges\\"..currRankIcon; end
		end
		currRankProgress=rpgo.round(GetPVPRankProgress()*100,2);
		structHonor["Current"]={
			Rank=rankNumber,
			Name=rankName,
			Icon=currRankIcon,
			Progress=currRankProgress,
			HonorPoints=GetHonorCurrency(),
			ArenaPoints=GetArenaCurrency()
			};
		structHonor["Session"]={HK=sessionHK,CP=sessionCP};
		structHonor["Yesterday"]=rpgo.Arg2Tab("HK","CP",GetPVPYesterdayStats());
		self:State("Honor",lifetimeHK+sessionCP);
	end
end

--[GetTalents]
function RPGOCP:GetTalents()
--self:PrintDebug("GetTalents");
	if(not self.prefs["scan"]["talents"] or UnitLevel("player") < 10 ) then
		self.db["Talents"]=nil;
		return;
	end
	local numTabs,numPts=GetNumTalentTabs(),UnitCharacterPoints("player");
	if( (self:State("Talents")~=numTabs+numPts) ) then
--self:PrintDebug(" ==> scan");
		self.db["TalentPoints"]=numPts;
		self.db["Talents"]={};
		self:State("Talents",numPts);
		local structTalent=self.db["Talents"];
		for tabIndex=1,numTabs do
			local tabName,texture,points,fileName=GetTalentTabInfo(tabIndex);
			if(not self.prefs["fixicon"]) then
				fileName="Interface\\TalentFrame\\"..fileName; end
			structTalent[tabName]={
				Background=fileName,
				PointsSpent=points,
				Order=tabIndex
				};
			for talentIndex=1,GetNumTalents(tabIndex) do
				local nameTalent,iconTexture,iconX,iconY,currentRank,maxRank=GetTalentInfo(tabIndex,talentIndex);
				if(currentRank > 0 or self.prefs["talentsfull"]) then
					self.tooltip:SetTalent(tabIndex,talentIndex)
					structTalent[tabName][nameTalent]={
						Rank=strjoin(":", currentRank,maxRank),
						Location=strjoin(":", iconX,iconY),
						Icon=rpgo.scanIcon(iconTexture),
						Tooltip=self:ScanTooltip()
						};
				end
			end
			self:State("Talents",'++');
		end
	end
end

--[GetQuests]
function RPGOCP:GetQuests(force)
--self:PrintDebug("GetQuests");
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
	if( force or (self:State("QuestsLog")~=numEntries) ) then
--self:PrintDebug(" ==> scan");
		self.db["Quests"]={};
		self:State("Quests",0);self:State("QuestsLog",0);
		local structQuest=self.db["Quests"];
		local slot,num,header = 1,nil,UNKNOWN;
		for idx=1,numEntries do
			local questDescription,questObjective;
			local questTitleText,level,questTag,suggestedGroup,isHeader,isCollapsed,isComplete = GetQuestLogTitle(idx);

			if(questTitleText) then
				if(isHeader) then
					header=questTitleText;
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
						Title=questTitleText,
						Level=level,
						Complete=isComplete,
						Tag=questTag,
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

	table.sort(toCollapse)
	for _,idx in pairs(toCollapse) do
		CollapseQuestHeader(idx);
	end
	SelectQuestLogEntry(selected);
end

--[GetStats]
function RPGOCP:GetStats(structStats,unit)
--self:PrintDebug("GetStats");
	if(not unit) then unit="player"; end
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
	base,posBuff,negBuff = GetCombatRating(CR_DEFENSE_SKILL),GetCombatRatingBonus(CR_DEFENSE_SKILL),0;
	structStats["Attributes"]["Defense"]["DefenseRating"]=strjoin(":", base,posBuff,negBuff);
	structStats["Attributes"]["Defense"]["DefensePercent"]=GetDodgeBlockParryChanceFromDefense();
	base,posBuff,negBuff = GetCombatRating(CR_DODGE),GetCombatRatingBonus(CR_DODGE),0;
	structStats["Attributes"]["Defense"]["DodgeRating"]=strjoin(":", base,posBuff,negBuff);
	structStats["Attributes"]["Defense"]["DodgeChance"]=rpgo.round(GetDodgeChance(),2);
	base,posBuff,negBuff = GetCombatRating(CR_BLOCK),GetCombatRatingBonus(CR_BLOCK),0;
	structStats["Attributes"]["Defense"]["BlockRating"]=strjoin(":", base,posBuff,negBuff);
	structStats["Attributes"]["Defense"]["BlockChance"]=rpgo.round(GetBlockChance(),2);
	base,posBuff,negBuff = GetCombatRating(CR_PARRY),GetCombatRatingBonus(CR_PARRY),0;
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
		structStats["Money"]=rpgo.Arg2Tab("Gold","Silver","Copper",rpgo.GetMoney());
		structStats["IsResting"]=IsResting() == 1 or false;
		local XPrest=GetXPExhaustion();
		if(not XPrest) then XPrest=0; end
		structStats["Experience"]=strjoin(":", UnitXP("player"),UnitXPMax("player"),XPrest);
		self.db["timestamp"]["Attributes"]=time();
	end
	self:GetAttackRating(structStats["Attributes"],unit);
end

function RPGOCP:CharacterDamageFrame(unit,prefix)
	if(not unit) then unit="player"; end
	if(not prefix) then prefix="PlayerStatFrameLeft"; end
	local damageFrame = getglobal(prefix.."2");
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

function RPGOCP:CharacterRangedDamageFrame(unit,prefix)
	if(not unit) then unit="player"; end
	if(not prefix) then prefix="PlayerStatFrameLeft"; end
	local damageFrame = getglobal(prefix.."2");
	if (not damageFrame.damage) then return; end
	self.tooltip:ClearLines();
	self.tooltip:SetText(INVTYPE_RANGED, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	self.tooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2f", damageFrame.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	self.tooltip:AddDoubleLine(DAMAGE_COLON, damageFrame.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	self.tooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1f", damageFrame.dps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
end

function RPGOCP:GetAttackRating(structAttack,unit,prefix)
	if(not unit) then unit="player"; end
	if(not prefix) then prefix="PlayerStatFrameLeft"; end
	UpdatePaperdollStats(prefix, "PLAYERSTAT_MELEE_COMBAT");
	local stat2 = getglobal(prefix.."2");
	local stat2Text = getglobal(prefix.."2".."StatText");
	local mainHandAttackBase,mainHandAttackMod,offHandAttackBase,offHandAttackMod = UnitAttackBothHands(unit);
	local speed,offhandSpeed = UnitAttackSpeed(unit);
	structAttack["Melee"]={};
	structAttack["Melee"]["MainHand"]={};
	structAttack["Melee"]["MainHand"]["AttackSpeed"]=rpgo.round(speed,2);
	structAttack["Melee"]["MainHand"]["AttackDPS"]=rpgo.round(stat2.dps,1);
	structAttack["Melee"]["MainHand"]["AttackSkill"]=mainHandAttackBase+mainHandAttackMod;
	structAttack["Melee"]["MainHand"]["AttackRating"]=strjoin(":", mainHandAttackBase,mainHandAttackMod,0);

	local tt=stat2Text:GetText();
	tt=rpgo.StripColor(tt);
	structAttack["Melee"]["MainHand"]["DamageRange"]=string.gsub(tt,"^(%d+)%s?-%s?(%d+)$","%1:%2");
	self:CharacterDamageFrame();
	local tt=self:ScanTooltip();
	structAttack["Melee"]["DamageRangeTooltip"]=rpgo.StripColor(tt);

	if ( offhandSpeed ) then
		structAttack["Melee"]["OffHand"]={};
		structAttack["Melee"]["OffHand"]["AttackSpeed"]=rpgo.round(offhandSpeed,2);
		structAttack["Melee"]["OffHand"]["AttackDPS"]=rpgo.round(stat2.offhandDps,1);
		structAttack["Melee"]["OffHand"]["AttackSkill"]=offHandAttackBase+offHandAttackMod;
		structAttack["Melee"]["OffHand"]["AttackRating"]=strjoin(":", offHandAttackBase,offHandAttackMod,0);

		tt=stat2.offhandDamage;
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

	base,posBuff,negBuff = GetCombatRating(CR_HIT_MELEE),GetCombatRatingBonus(CR_HIT_MELEE),0;
	structAttack["Melee"]["HitRating"]=strjoin(":", base,posBuff,negBuff);
	base,posBuff,negBuff = GetCombatRating(CR_CRIT_MELEE),GetCombatRatingBonus(CR_CRIT_MELEE),0;
	structAttack["Melee"]["CritRating"]=strjoin(":", base,posBuff,negBuff);
	base,posBuff,negBuff = GetCombatRating(CR_HASTE_MELEE),GetCombatRatingBonus(CR_HASTE_MELEE),0;
	structAttack["Melee"]["HasteRating"]=strjoin(":", base,posBuff,negBuff);

	structAttack["Melee"]["CritChance"]=rpgo.round(GetCritChance(),2);

	if(unit=="player") then
		local rangedTexture = GetInventoryItemTexture("player",18);
		if ( not rangedTexture ) then
			structAttack["Ranged"]=nil;
		else
			UpdatePaperdollStats(prefix, "PLAYERSTAT_RANGED_COMBAT");
			local damageFrame = getglobal(prefix.."2");
			local damageFrameText = getglobal(prefix.."2".."StatText");
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

				base,posBuff,negBuff = GetCombatRating(CR_HIT_RANGED),GetCombatRatingBonus(CR_HIT_RANGED),0;
				structAttack["Ranged"]["HitRating"]=strjoin(":", base,posBuff,negBuff);
				base,posBuff,negBuff = GetCombatRating(CR_CRIT_RANGED),GetCombatRatingBonus(CR_CRIT_RANGED),0;
				structAttack["Ranged"]["CritRating"]=strjoin(":", base,posBuff,negBuff);
				base,posBuff,negBuff = GetCombatRating(CR_HASTE_RANGED),GetCombatRatingBonus(CR_HASTE_RANGED),0;
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
		base,posBuff,negBuff = GetCombatRating(CR_HIT_SPELL),GetCombatRatingBonus(CR_HIT_SPELL),0;
		structAttack["Spell"]["HitRating"]=strjoin(":", base,posBuff,negBuff);
		base,posBuff,negBuff = GetCombatRating(CR_CRIT_SPELL),GetCombatRatingBonus(CR_CRIT_SPELL),0;
		structAttack["Spell"]["CritRating"]=strjoin(":", base,posBuff,negBuff);
		base,posBuff,negBuff = GetCombatRating(CR_HASTE_SPELL),GetCombatRatingBonus(CR_HASTE_SPELL),0;
		structAttack["Spell"]["HasteRating"]=strjoin(":", base,posBuff,negBuff);
		structAttack["Spell"]["Penetration"] = GetSpellPenetration();
		local base,casting = GetManaRegen();
		base = floor( (base * 5.0) + 0.5);
		casting = floor( (casting * 5.0) + 0.5);
		structAttack["Spell"]["ManaRegen"] = strjoin(":", base,casting);
	end
	PaperDollFrame_UpdateStats();
end

--[GetBuffs]
function RPGOCP:GetBuffs(structBuffs,unit)
--self:PrintDebug("GetBuffs");
	if(not unit) then unit="player"; end
	local idx=1;
	if(not structBuffs["Attributes"]) then structBuffs["Attributes"]={}; end
	if(UnitBuff(unit,idx)) then
		structBuffs["Attributes"]["Buffs"]={};
		while(UnitBuff(unit,idx)) do
			local name,rank,icon,count=UnitBuff(unit,idx);
			self.tooltip:SetUnitBuff(unit,idx);
			if(rank and rank=="") then
				rank=nil;
			end
			if(count and count<=1) then
				count=nil;
			end
			structBuffs["Attributes"]["Buffs"][idx]={
				Name=name,
				Rank=rank,
				Count=count,
				Icon=rpgo.scanIcon(icon),
				Tooltip=self:ScanTooltip()};
			idx=idx+1
		end
	else
		structBuffs["Attributes"]["Buffs"]=nil;
	end
	idx=1;
	if(UnitDebuff(unit,idx)) then
		structBuffs["Attributes"]["Debuffs"]={};
		while(UnitDebuff(unit,idx)) do
			local name,rank,icon,count=UnitDebuff(unit,idx);
			self.tooltip:SetUnitDebuff(unit,idx);
			if(rank and rank=="") then
				rank=nil;
			end
			if(count and count<=1) then
				count=nil;
			end
			structBuffs["Attributes"]["Debuffs"][idx]={
				Name=name,
				Rank=rank,
				Count=count,
				Icon=rpgo.scanIcon(icon),
				Tooltip=self:ScanTooltip()};
			idx=idx+1
		end
	else
		structBuffs["Attributes"]["Debuffs"]=nil;
	end
end

function RPGOCP:GetEquipment(force)
--self:PrintDebug("GetEquipment");
	if(not self.prefs["scan"]["equipment"]) then
		self.db["Equipment"]=nil;
		return;
	end
	if( force or self:State("Equipment")==0 or not self:State("_eq") ) then
--self:PrintDebug(" ==> scan");
		local index,slot;
		self.db["Equipment"]={};
		self:State("Equipment",0)
		local structEquip=self.db["Equipment"];
		for index,slot in pairs(UnitSlots) do
			local curItemLink,itemCount;
			local curItemTexture=GetInventoryItemTexture("player",index);
			self.tooltip:SetInventoryItem("player",index);
			if(index==0) then
				if(curItemTexture) then
					local curItemName,_=rpgo.GetItemInfoTT(self.tooltip);
					_,curItemLink,_,_=rpgo.GetItemInfo(curItemName);
				end
			else
				curItemLink=GetInventoryItemLink("player",index);
			end
			if(curItemLink) then
				itemCount=GetInventoryItemCount("player",index);
				if(itemCount == 1) then itemCount=nil; end
				structEquip[slot]=self:ScanItemInfo(curItemLink,curItemTexture,itemCount);
				self.state["Equipment"]=self.state["Equipment"]+1;
				curItemLink=nil;
			end
		end
		self.db["timestamp"]["Equipment"]=time();
		self:State("_eq",true);
		self.frame:RegisterEvent("UNIT_INVENTORY_CHANGED");
	end
	self:GetStats(self.db);
end

function RPGOCP:GetMail()
--self:PrintDebug("GetMail");
	if(not self.prefs["scan"]["mail"]) then
		self.db["MailBox"]=nil;
		return;
	end
	if(self:State("_mail")) then
--self:PrintDebug(" ==> scan");
		local numMessages=GetInboxNumItems();
		if( not self:State("Mail") or self:State("Mail")~=numMessages ) then
			self.db["MailBox"]={};
			self:State("Mail",0);
			local itemstr,structMail=nil,self.db["MailBox"];
			for idx=1,numMessages do
				local _,_,mailSender,mailSubject,mailCoin,_,mailDays=GetInboxHeaderInfo(idx);
				local itemstr,itemIcon,itemQty,itemQuality,_=GetInboxItem(idx);
				if(not mailSender) then mailSender=UNKNOWN; end
				structMail[idx]={
					Sender	= mailSender,
					Subject	= mailSubject,
					Coin	= mailCoin,
					CoinIcon= rpgo.scanIcon(GetCoinIcon(mailCoin)),
					Days	= mailDays};
				if(itemstr) then
					itemstr=GetInboxItemLink(idx);
					self.tooltip:SetHyperlink(itemstr);
					structMail[idx]["Item"]=self:ScanItemInfo(itemstr,itemIcon,itemQty);
				end
				self:State("Mail",'++');
			end
			self.db["timestamp"]["MailBox"]=time();
		end
	end
end

function RPGOCP:GetInventory()
--self:PrintDebug("GetInventory");
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
--self:PrintDebug("GetBank");
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
--self:PrintDebug(" ==> scan",invgrp,bagidx,bagid);
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
		self.tooltip:AddLine(format(CONTAINER_SLOTS,rpgo.GetContainerNumSlots(bagid),itemName));
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
		Name=itemName,
		Color=rpgo.scanColor(itemColor),
		Slots=rpgo.GetContainerNumSlots(bagid),
		Item=itemID,
		Icon=rpgo.scanIcon(itemIcon),
		Tooltip=self:ScanTooltip(),
		Contents={}};
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

function RPGOCP:GetTradeSkill(tradeskill)
--self:PrintDebug("GetTradeSkill");
	if(not self.prefs["scan"]["professions"]) then
		self.db["Professions"]=nil;
		return;
	end
	local getTradeSkillLine,expandTradeSkills,getNumTradeSkills,getTradeSkillInfo,getTradeSkillIcon,getTradeSkillItem,getTradeSkillCool,getTradeSkillDesc,tradeSkillFrame;
	local getTradeSkillNumReagents,getTradeSkillReagentInfo,getTradeSkillReagentItem;
	if(tradeskill=='trade') then
		getTradeSkillLine = GetTradeSkillLine;
		expandTradeSkills = ExpandTradeSkillSubClass;
		getNumTradeSkills = GetNumTradeSkills;
		getTradeSkillInfo = GetTradeSkillInfo;
		getTradeSkillIcon = GetTradeSkillIcon;
		getTradeSkillItem = GetTradeSkillItemLink;
		getTradeSkillCool = GetTradeSkillCooldown;
		tradeSkillFrame = rpgoCPTradeSkillFrame;

		getTradeSkillNumReagents = GetTradeSkillNumReagents;
		getTradeSkillReagentInfo = GetTradeSkillReagentInfo;
		getTradeSkillReagentItem = GetTradeSkillReagentItemLink;
	elseif(tradeskill=='craft') then
		getTradeSkillLine = GetCraftDisplaySkillLine
		expandTradeSkills = CollapseCraftSkillLine
		getNumTradeSkills = GetNumCrafts
		getTradeSkillInfo = function(idx)
			local skillName,craftSubSpellName,skillType,numAvailable,isExpanded=GetCraftInfo(idx)
			return skillName,skillType,numAvailable,isExpanded end
		getTradeSkillIcon = GetCraftIcon
		getTradeSkillItem = GetCraftItemLink
		getTradeSkillDesc = GetCraftDescription
		tradeSkillFrame = rpgoCPCraftFrame

		getTradeSkillNumReagents = GetCraftNumReagents;
		getTradeSkillReagentInfo = GetCraftReagentInfo;
		getTradeSkillReagentItem = GetCraftReagentItemLink;
	else
		return;
	end

	local skillLineName,skillLineRank,skillLineMaxRank=getTradeSkillLine();
	if(not skillLineName or skillLineName=="" or skillLineName==UNKNOWN) then
		return;
	end
	expandTradeSkills(0);
	if ( not self.db["Professions"] ) then
		self.db["Professions"]={};
	end
	if ( not self.db["timestamp"]["Professions"] ) then
		self.db["timestamp"]["Professions"]={};
	end
	local structProf=self.db["Professions"];
	self:State("_reagentError",nil);
	local skillHeader=nil;
	local numTradeSkills=getNumTradeSkills();
	if(numTradeSkills>0 and (not self.state["Professions"][skillLineName] or numTradeSkills~=self.state["Professions"][skillLineName]) ) then
		local TradeSkillTemp=nil;
		if(not structProf[skillLineName]) then
			structProf[skillLineName]={};
		elseif(structProf[skillLineName]) then
			TradeSkillTemp=structProf[skillLineName];
			structProf[skillLineName]={};
		end
		self.state["Professions"][skillLineName]=0;
		if(tradeskill=='craft') then
			skillHeader=skillLineName;
			if(not structProf[skillLineName][skillHeader]) then
				structProf[skillLineName][skillHeader]={};
			end
		end
		for idx=1,numTradeSkills do
			local skillName,skillType,numAvailable,isExpanded=getTradeSkillInfo(idx);
			if( skillType=="header" and skillName~="" ) then
				skillHeader=skillName;
				structProf[skillLineName][skillHeader]={};
				self.state["Professions"][skillLineName]=self.state["Professions"][skillLineName]+1;
			elseif( skillHeader and skillName and skillName~="" ) then
				local cooldown,reagents=nil,{};
				local skillIcon=getTradeSkillIcon(idx);
				if(not skillIcon) then skillIcon=""; end
				local itemColor,_,itemLink,_=rpgo.GetItemInfo(getTradeSkillItem(idx));

				if(getTradeSkillDesc) then
					local tt = getTradeSkillDesc(idx)
					if(tt) then
						self.tooltip:SetText(getTradeSkillDesc(idx));
					end
				elseif(not MarsProfessionOrganizer_SetTradeSkillItem) then
					self.tooltip:SetTradeSkillItem(idx);
				end
				if(getTradeSkillCool) then
					cooldown = getTradeSkillCool(idx);
					if(cooldown) then
						self.tooltip:AddLine(COOLDOWN_REMAINING.." "..SecondsToTime(cooldown));
					end
				end
				reagents={};
				for ridx=1,getTradeSkillNumReagents(idx) do
					local reagentName,reagentTexture,reagentCount,_=getTradeSkillReagentInfo(idx,ridx);
					if(not reagentName) then reagentName=UNKNOWN; self:State("_reagentError",true); end
					if(not reagentTexture) then reagentTexture=""; end
					if(self.prefs["reagentfull"]) then
						local _,itemID,_ = rpgo.GetItemID(getTradeSkillReagentItem(idx,ridx));
						table.insert(reagents, {
							Name=reagentName,
							Count=reagentCount,
							itemID=itemID
							});
					else
						table.insert(reagents, reagentName .. " x" .. reagentCount);
					end
				end
				if(not self.prefs["reagentfull"]) then
					reagents = table.concat(reagents,"<br>");
				end
				structProf[skillLineName][skillHeader][skillName]={
					Icon=rpgo.scanIcon(skillIcon),
					Difficulty=TradeSkillCode[skillType],
					Color=rpgo.scanColor(itemColor),
					Item=itemLink,
					Tooltip=self:ScanTooltip(),
					Reagents=reagents};
				if(cooldown and cooldown ~= 0) then
					structProf[skillLineName][skillHeader][skillName]["Cooldown"]=cooldown;
					structProf[skillLineName][skillHeader][skillName]["DateUTC"]=date("!%Y-%m-%d %H:%M:%S");
					structProf[skillLineName][skillHeader][skillName]["timestamp"]=time();
				end

				self.state["Professions"][skillLineName]=self.state["Professions"][skillLineName]+1;
			end
		end
		if( (self.state["Professions"][skillLineName]==0) or (self.state["_reagentError"]) ) then
			self:State("_skillError",true);
			self.state["Professions"][skillLineName]=0;
			structProf[skillLineName]=TradeSkillTemp;
			if(self.state["_reagentError"]) then
				self:PrintTitle(skillLineName..rpgo.StringColorize(rpgo.colorRed," reagents not scanned; CP will rescan"));
			else
				self:PrintTitle(skillLineName..rpgo.StringColorize(rpgo.colorRed," not scanned; CP will rescan"));
			end
			tradeSkillFrame:Show();
		else
			if(self.state["_skillError"]) then
				self:PrintTitle(skillLineName.." rescanned successfully");
				self:State("_skillError",nil);
				self:State("_reagentError",nil);
			end
			tradeSkillFrame:Hide();
			self:TidyProfessions();
			self.db["timestamp"]["Professions"][skillLineName]=time();
		end
		TradeSkillTemp=nil;
	end
end

function RPGOCP:TidyProfessions()
	if(self:State("_loaded")) then
		for skillName in pairs(self.db["Professions"]) do
			if(not self.state["_skills"][skillName]) then
				self.db["Professions"][skillName]=nil;
			end
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
	for spelltab=1,GetNumSpellTabs() do
		local spelltabname,spelltabtexture,offset,numSpells=GetSpellTabInfo(spelltab);
		local idx=0;
		if(not self.state["SpellBook"][spelltabname] or self.state["SpellBook"][spelltabname]~=numSpells) then
			structSpell[spelltabname]={Icon=rpgo.scanIcon(spelltabtexture)};
			structSpell[spelltabname]["Spells"]={};
			self.state["SpellBook"][spelltabname]=0;
			idx=0;
			for spellId=1+offset,numSpells+offset do
				spellName,spellRank=GetSpellName( spellId,BOOKTYPE_SPELL );
				spellTexture=GetSpellTexture( spellId,spelltab );
				self.tooltip:SetSpell(spellId,BOOKTYPE_SPELL);
				structSpell[spelltabname]["Spells"][spellName]={
					Rank=spellRank,
					Icon=rpgo.scanIcon(spellTexture),
					Tooltip=self:ScanTooltip()};
				idx=idx+1;
			end
			self.state["SpellBook"][spelltabname]=idx;
			structSpell[spelltabname]["Count"]=numSpells;
		end
		self.db["timestamp"]["SpellBook"]=time();
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
--self:PrintDebug("ScanPetStable");
	if(self.prefs["scan"]["pet"] and (self.state["_class"]=="HUNTER" and UnitLevel("player")>9)) then
		local structPets;
		local stablePets={};
		for petIndex=0,GetNumStableSlots() do
			local petIcon,petName,petLevel,petType,petLoyalty=GetStablePetInfo(petIndex);
			if(petName and petName~=UNKNOWN) then
				self:ScanPetInit(petName);
				structPets=self.db["Pets"];
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
		for petName,_ in pairs( structPets ) do
			if( not stablePets[petName] ) then
				structPets[petName]=nil;
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
			petName=UnitName("pet");
			if( petName and petName~=UNKNOWN ) then
				self:ScanPetInit(petName);
				local structPet=self.db["Pets"][petName];
				structPet["Name"]=petName;
				structPet["Type"]=UnitCreatureFamily("pet");
				structPet["TalentPoints"],structPet["TalentPointsUsed"]=GetPetTrainingPoints();
				local currXP,nextXP=GetPetExperience();
				structPet["Experience"]=strjoin(":", currXP,nextXP);

				self:GetStats(structPet,"pet");
				self:GetBuffs(structPet,"pet");
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
		petName=UnitName("pet");
		if( petName and petName~=UNKNOWN ) then
			numSpells,_=HasPetSpells();
			if( numSpells ) then
				self:ScanPetInit(petName);
				if (not self.db["Pets"][petName]["SpellBook"]) then
					self.db["Pets"][petName]["SpellBook"]={};
				end
				local structPetSpell=self.db["Pets"][petName]["SpellBook"];
				for petSpellId=1,numSpells do
					local spellName,spellRank=GetSpellName(petSpellId,BOOKTYPE_PET);
					local spellTexture=GetSpellTexture(petSpellId,BOOKTYPE_PET);
					if (spellName==nil) then break; end
					if (not structPetSpell["Spells"]) then
						structPetSpell["Spells"]={};
					end
					structPetSpell["Spells"][spellName]={};
					structPetSpell["Spells"][spellName]["Rank"]=spellRank;
					structPetSpell["Spells"][spellName]["Icon"]=rpgo.scanIcon(spellTexture);
					structPetSpell["Count"]=petSpellId;
				end
				self.state["PetSpell"][petName]=numSpells;
			end
		end
	end
end

function RPGOCP:TradeTimer(event,arg1)
	local skill;
	if(not self.state["ProfTimer"]) then self.state["ProfTimer"]={}; end
	if(event=="CRAFT_UPDATE") then
		skill=GetCraftDisplaySkillLine();
	elseif(event=="TRADE_SKILL_UPDATE") then
		skill=GetTradeSkillLine();
	end
	if(skill and skill~=UNKNOWN) then
		if( (not arg1) or (not self.state["ProfTimer"][skill]) ) then
			self.state["ProfTimer"][skill]=0;
		elseif(tonumber(arg1)) then
			self.state["ProfTimer"][skill]=self.state["ProfTimer"][skill]+arg1;
		end
		if(self.state["ProfTimer"][skill] > 1.5) then
			self.state["ProfTimer"][skill]=nil;
			self:EventHandler(string.gsub(event,'_UPDATE','_SHOW'),arg1);
		end
	else
		if(event=="CRAFT_UPDATE") then
			rpgoCPCraftFrame:Hide();
		elseif(event=="TRADE_SKILL_UPDATE") then
			rpgoCPTradeSkillFrame:Hide();
		end
	end
end

function RPGOCP:UpdatePlayed(arg1,arg2)
	if(arg1 and arg2) then timePlayed=arg1; timeLevelPlayed=arg2; end
	if(self.state["_loaded"] and self.db) then
		self.db["TimePlayed"]=timePlayed;
		self.db["TimeLevelPlayed"]=timeLevelPlayed;
	end
end

function RPGOCP:UpdateZone()
	self.db["Zone"]=GetZoneText();
	self.db["SubZone"]=GetSubZoneText();
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

--[[## general rpgo functions: item
--######################################################--]]
--[function] itemlink,itemtexture,itemcount
function RPGOCP:ScanItemInfo(itemstr,itemtexture,itemcount)
	local itemColor,itemLink,itemID,itemName,itemTexture
	if(itemstr) then
		itemColor,itemLink,itemID,itemName,itemTexture=rpgo.GetItemInfo(itemstr);
		local itemBlock={};
		if(self.prefs["fixquantity"] and itemcount and itemcount<=1) then itemcount=nil end
		if(not itemName or not itemColor) then
			itemName,itemColor=rpgo.GetItemInfoTT(self.tooltip);
		end
		if(not itemtexture) then
			itemtexture=itemTexture;
		end
		itemBlock["Name"]=itemName;
		itemBlock["Item"]=itemID;
		itemBlock["Color"]=rpgo.scanColor(itemColor);
		itemBlock["Quantity"]=itemcount;
		itemBlock["Icon"]=rpgo.scanIcon(itemtexture);
		itemBlock["Tooltip"]=self:ScanTooltip();
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

--[[########################################################
--## object functions
--######################################################--]]
function RPGOCP:State(...)
	return rpgo.State(self,...);
end
function RPGOCP:LiteScan(event)
	if(event=="RPGOCP_EXPORT") then return false; end
	if(not self.state["_loaded"]) then return false; end
	return rpgo.LiteScan(self);
end
function RPGOCP:PrintTitle(...)
	return rpgo.PrintTitle(self,...);
end
function RPGOCP:ScanTooltip(...)
	return rpgo.ScanTooltipOO(self,...);
end
function RPGOCP:PrintUsage()
	return rpgo.PrintUsage(self);
end
function RPGOCP:PrintDebug(...)
	return rpgo.PrintDebug(self,...);
end

function RPGOCP:PrefInit(...)
	return rpgo.PrefInit(self,...);
end
function RPGOCP:PrefTidy(...)
	return rpgo.PrefTidy(self,...);
end
function RPGOCP:TogglePref(...)
	return rpgo.TogglePrefOO(self,...);
end
function RPGOCP:RegisterEvents(flagMode)
	if(not flagMode) then flagMode = (self.prefs.enabled); end
	self:PrintDebug("RegisterEvents ("..rpgo.PrefColorize(flagMode)..") ");
	return rpgo.RegisterEvents(self,flagMode);
end

function RPGOCP:UpdateDate(...)
	return rpgo.UpdateDate(self,...);
end

RPGOCP:Init();
