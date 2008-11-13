TradeskillInfo = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDB-2.0", "AceConsole-2.0", "AceHook-2.1", "FuBarPlugin-2.0")
TradeskillInfo.version = "1.0." .. string.sub("$Revision: 55205 $", 12, -3);
TradeskillInfo.date = string.sub("$Date: 2007-11-17 18:57:37 -0500 (Sat, 17 Nov 2007) $", 8, 17);
TradeskillInfo:RegisterDB("TradeskillInfoDB")
TradeskillInfo:RegisterDefaults('profile', {
	ShowSkillLevel = true,
	ShowSkillProfit = true,
	MoneyFormat = 3,
	TooltipSource = true,
	TooltipRecipeSource = true,
	TooltipRecipePrice = true,
	TooltipUsedIn = true,
	TooltipUsableBy = true,
	TooltipKnownBy = true,
	TooltipLearnableBy = true,
	TooltipAvailableTo = true,
	TooltipBankedAmount = true,
	TooltipAltAmount = true,
	TooltipID = false,
	TooltipStack = false,
	TrainerReagents = true,
	ColorSource = { r=0.75, g=0.75, b=0.25 },
	ColorRecipeSource = { r=0.75, g=0.75, b=0.25 },
	ColorRecipePrice = { r=1.0, g=1.0, b=1.0 },
	ColorUsedIn = { r=1.0, g=1.0, b=1.0 },
	ColorUsableBy = { r=1.0, g=1.0, b=1.0 },
	ColorKnownBy = { r=1.0, g=0.0, b=0.0 },
	ColorLearnableBy = { r=0.25, g=0.75, b=0.25 },
	ColorAvailableTo = { r=1.0, g=0.50, b=0.25 },
	ColorBankedAmount = { r=0.5, g=0.6, b=0.7 },
	ColorAltAmount = { r=0.5, g=0.6, b=0.7 },
	ColorTrainerReagents = { r=1.0, g=1.0, b=1.0 },
	ColorID = { r=0.75, g=0.5, b=0.5 },
	ColorStack = { r=1.0, g=1.0, b=1.0 },
	QuickSearch = true,
	SearchMouseButton = 2,
	SearchShiftKey = 1,
	ColorAHRecipes = true,
	AHColorLearnable = { r=1.0, g=1.0, b=1.0 },
	AHColorAltLearnable = { r=0.1, g=1.0, b=0.1 },
	AHColorWillLearn = { r=1.0, g=0.75, b=0.1 },
	AHColorAltWillLearn = { r=0.1, g=0.75, b=1.0 },
	AHColorUnavailable = { r=1.0, g=0.1, b=0.1 },
	SavePosition = true,
	FrameStrata = 1,
})

TradeskillInfo:RegisterDefaults('realm', {
	userdata = {}, -- Stores all known characters
--	userdata[playername].knownRecipes = {}, -- Stores all characters know recipes with difficulty
--	userdata[playername].skills = {}, -- Stores all characters skill level for tradeskills.
})
TradeskillInfo:RegisterDefaults('account', {
	difficulty = {}, -- Stores at what level difficulty is changed for all recipes.
})

BINDING_HEADER_TRADESKILLINFO = "Tradeskill Info";
BINDING_NAME_TOGGLE_TRADESKILLINFO = "Toggle Tradeskill Info Window";
BINDING_NAME_TOGGLE_TRADESKILLINFOCONFIG = "Toggle Tradeskill Info Config Window";

TradeskillInfo.vars = {};
TradeskillInfo.vars.MouseButtons = { "LeftButton", "RightButton" };
TradeskillInfo.vars.ShiftKeys = { IsShiftKeyDown, IsControlKeyDown, IsAltKeyDown };
TradeskillInfo.libs = {};
TradeskillInfo.libs.Abacus = Rock("LibAbacus-3.0");

local function getIdFromLink(link)
  if not link then return end
--  local _,_,id,name = strfind(link,"|Hitem:(%d+):.+%[(.+)%]")
  local _,_,id = strfind(link,"item:(%d+):")
  if not id then
--  	local _,_,id,name = strfind(link,"|Henchant:(%d+)|h%[(.+)%]")
  	local _,_,id = strfind(link,"enchant:(%d+)")
  	if id then return -tonumber(id) end
	else
		return tonumber(id)
	end
end

local function getNameFromLink(link)
	if not link then return end
  local _,_,name = strfind(link,"|Hitem:.+%[(.+)%]")
	return name
end

local function getItemLink(id,combineName)
	if id > 0 then
		local itemName,itemLink,itemQuality,itemTexture
		itemName,itemLink,itemQuality,_,_,_,_,_,_,itemTexture = GetItemInfo(id);
		if itemLink then
			local _, _, _, hexColor = GetItemQualityColor(itemQuality);
			return itemLink, itemQuality, "item:"..id..":0:0:0:0:0:0:0", itemTexture;
		else
			local _, _, _, hexColor = GetItemQualityColor(1);
			return nil, 1, "item:"..id..":0:0:0:0:0:0:0", "Interface\\Icons\\INV_Misc_QuestionMark.blp";
		end
	else
		if combineName then
			local _, _, _, hexColor = GetItemQualityColor(1);
			return hexColor.."|Henchant:"..-id.."|h["..combineName.."]|h|r", 1, "enchant:"..-id, "Interface\\Icons\\Spell_Holy_GreaterHeal.blp"
		else
			return nil, 1, "enchant:"..-id, "Interface\\Icons\\Spell_Holy_GreaterHeal.blp"
		end
	end
end

-- Splits a partioned string into a table with numbers
local function splitn(s,c)
	local r = {};
	for m,n in string.gmatch(s,"(%d+)(%"..c.."?)") do
		table.insert(r,tonumber(m))
		if n == '' then break end
	end
	return r;
end

-- Splits a partioned string into a table with strings
local function splits(s,c)
	local r = {};
	for m,n in string.gmatch(s,"([^"..c.."]*)(%"..c.."?)") do
		table.insert(r,m)
		if n == '' then break end
	end
	return r;
end

-- Combines a table into a partioned string
local function ICombineTable(t,c)
	local s = "";
	for i,d in ipairs(t) do
		if i == 1 then
			s = s .. d;
		else
			s = s .. c .. d;
		end
	end
	return s;
end

-- Combines a table into a partioned string
local function CombineTable(t,c)
	local s = "";
	for i,d in pairs(t) do
		if s == "" then
			s = s .. i .. d;
		else
			s = s .. c .. i .. d;
		end
	end
	return s;
end

function TradeskillInfo:OnInitialize()
	self:BuildWhereUsed();
--	self:BuildRecipeTable();
	self:RegisterChatCommand({"/TradeskillInfo", "/tsi"}, {
		desc = 'Complete tradeskill information',
		handler = TradeskillInfo,
		type = 'group',
		args = {
			profit = {
				name = 'Combine profit',
				desc = 'Show cost of combine and profit',
				type = 'toggle',
				get = function() return self.db.profile.ShowSkillProfit end,
				set = function(val) self.db.profile.ShowSkillProfit = val end,
			},
			level = {
				name = 'Combine level',
				desc = 'Show skill level of the combines',
				type = 'toggle',
				get = function() return self.db.profile.ShowSkillLevel end,
				set = function(val) self.db.profile.ShowSkillLevel = val end,
			},
			source = {
				name = 'Source',
				desc = 'Show the source of the item',
				type = 'toggle',
				get = function() return self.db.profile.TooltipSource end,
				set = function(val) self.db.profile.TooltipSource = val end,
			},
			usedin = {
				name = 'Used In',
				desc = 'Show what tradeskill an item is used in in it\'s tooltip',
				type = 'toggle',
				get = function() return self.db.profile.TooltipUsedIn end,
				set = function(val) self.db.profile.TooltipUsedIn = val end,
			},
			useableby = {
				name = 'Usable By',
				desc = 'Show who can use an item in it\'s tooltip',
				type = 'toggle',
				get = function() return self.db.profile.TooltipUsableBy end,
				set = function(val) self.db.profile.TooltipUsableBy = val end,
			},
			known = {
				name = 'Known By',
				desc = 'Show who knows a recipe in it\'s tooltip',
				type = 'toggle',
				get = function() return self.db.profile.TooltipKnownBy end,
				set = function(val) self.db.profile.TooltipKnownBy = val end,
			},
			learn = {
				name = 'Learnable By',
				desc = 'Show who can learn a recipe in it\'s tooltip',
				type = 'toggle',
				get = function() return self.db.profile.TooltipLearnableBy end,
				set = function(val) self.db.profile.TooltipLearnableBy = val end,
			},
			willbe = {
				name = 'Will be able to learn',
				desc = 'Show who will be able to learn a recipe in it\'s tooltip',
				type = 'toggle',
				get = function() return self.db.profile.TooltipAvailableTo end,
				set = function(val) self.db.profile.TooltipAvailableTo = val end,
			},
			reagents = {
				name = 'Reagents',
				desc = 'Show what reagents a recipe takes at the trainer',
				type = 'toggle',
				get = function() return self.db.profile.TrainerReagents end,
				set = function(val) self.db.profile.TrainerReagents = val end,
			},
			config = {
				name = 'Config',
				desc = 'Show config screen',
				type = 'execute',
				func = function() TradeskillInfo:Config_Toggle() end,
			},
			menu = {
				name = 'Menu',
				desc = 'Show TradeskillInfo UI',
				type = 'execute',
				func = function() TradeskillInfo:UI_Toggle() end,
			},
		},
	});
end

function TradeskillInfo:InitPlayer()
	if not self.vars.playername then
		self.vars.playername = UnitName("player");
		if not self.db.realm.userdata[self.vars.playername] then
			self.db.realm.userdata[self.vars.playername] = {};
		end
		if not self.db.realm.userdata[self.vars.playername].knownRecipes then
			self.db.realm.userdata[self.vars.playername].knownRecipes = {};
		end
		if not self.db.realm.userdata[self.vars.playername].skills then
			self.db.realm.userdata[self.vars.playername].skills = {};
		end
	end
end

function TradeskillInfo:OnEnable()
	self:InitPlayer();
	self:HookTradeSkillUI();
	self:HookCraftUI();
	self:SecureHook("ContainerFrameItemButton_OnModifiedClick");
	self:SecureHook("BankFrameItemButtonGeneric_OnModifiedClick");
	self:SecureHook("MerchantItemButton_OnModifiedClick");
	self:SecureHook("ChatFrame_OnHyperlinkShow");
	self:HookAuctionUI();
	self:RegisterEvent("AceEvent_FullyInitialized","OnFullyInitialized")
	self:RegisterEvent("TRADE_SKILL_SHOW", "OnTradeShow");
	self:RegisterEvent("SKILL_LINES_CHANGED", "OnSkillUpdate");
	self:RegisterEvent("CRAFT_SHOW", "OnCraftShow");
	self:RegisterEvent("ADDON_LOADED", "OnAddonLoaded");
	self:UpdateSkills();
	self:UpdateSpecializations();
	self:HookTooltips();
end

function TradeskillInfo:OnDisable()
end

function TradeskillInfo:OnFullyInitialized()
	self:UpdateSkills();
	self:UpdateSpecializations();
end

function TradeskillInfo:OnAddonLoaded(addon)
	if addon == "Blizzard_AuctionUI" then
		self:HookAuctionUI();
	elseif addon == "Blizzard_TradeSkillUI" then
		self:HookTradeSkillUI();
	elseif addon == "Blizzard_CraftUI" then
		self:HookCraftUI();
	end
end

function TradeskillInfo:OnTradeShow()
	self:ScheduleEvent(self.UpdateKnownRecipes,1,self);
end

function TradeskillInfo:OnTradeUpdate()
	if (GetTradeSkillLine() ~= "UNKNOWN") then
		self:ScheduleEvent(self.UpdateKnownRecipes,1,self);
	end
end

function TradeskillInfo:OnSkillUpdate()
	if (GetTradeSkillLine() ~= "UNKNOWN") or
		(GetCraftDisplaySkillLine() ~= nil) then
		self:ScheduleEvent(self.UpdateKnownRecipes,1,self);
	end
end

function TradeskillInfo:OnCraftShow()
	self:ScheduleEvent(self.UpdateKnownRecipes,1,self);
end

function TradeskillInfo:OnCraftUpdate()
	if (GetCraftDisplaySkillLine() ~= nil) then
		self:ScheduleEvent(self.UpdateKnownRecipes,1,self);
	end
end

function TradeskillInfo:HookAuctionUI()
	if AuctionFrame then
		for j=1,8 do
			local button = getglobal("BrowseButton"..j.."Item");
			self:HookScript(button,"OnClick","AuctionItemButton_OnClick");
			button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		end
		self:SecureHook("AuctionFrameBrowse_Update");
	end
end

function TradeskillInfo:GetExtraItemDetailText(something, tradeskill, skill_index)
--Thanks to nogudnik for providing this code!
    local skillName, skillType, numAvailable, isExpanded = GetTradeSkillInfo(skill_index);
    if ( skillType == "header" ) then return end
    if ( skill_index > GetNumTradeSkills() ) then return end

    local link = GetTradeSkillItemLink(skill_index);
    local itemId = getIdFromLink(link)
    local text = nil

    if self:CombineExists(itemId) then
        if self:ShowingSkillProfit() then
            -- Insert item value and reagent costs
            local value,cost,profit = self:GetCombineCost(itemId);
            text = string.format("s: %s - c: %s = p: %s",
                self:GetMoneyString(value), self:GetMoneyString(cost), self:GetMoneyString(profit));
        end
        if self:ShowingSkillLevel() then
            local sep = ""
            if text then sep = "\n" else text = "" end
            text = text .. sep .. self:GetColoredDifficulty(itemId)
        end
    end

    return text
end

function TradeskillInfo:HookTradeSkillUI()
    if TradeSkillFrame and not self:IsHooked("TradeSkillFrame_SetSelection") then
        self:SecureHook("TradeSkillFrame_SetSelection");
    end

    if Skillet and not self:IsHooked(Skillet, "GetExtraItemDetailText") then
        self:Hook(Skillet, "GetExtraItemDetailText")
    end
end
function TradeskillInfo:HookCraftUI()
	if CraftFrame and not self:IsHooked("CraftFrame_SetSelection") then
		self:SecureHook("CraftFrame_SetSelection");
	end
end
	
function TradeskillInfo:UpdateKnownRecipes()
	if not self.processingUpdates and
		(GetTradeSkillLine() ~= "UNKNOWN") or
		(GetCraftDisplaySkillLine() ~= nil) then
		self.processingUpdates = true;

		self:UpdateSkills();
		self:UpdateSpecializations();
		self:UpdateKnownTradeRecipes();
		self:UpdateKnownCraftRecipes();
		self.processingUpdates = false;
	end
end

function TradeskillInfo:UpdateSkills(startLine, endLine)
	local numSkills = GetNumSkillLines()
	if not startLine then
		self.db.realm.userdata[self.vars.playername].skills = {};
		startLine = 1;
		endLine = numSkills;
	end
	for i = startLine, endLine do
		local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier = GetSkillLineInfo(i)
		if isHeader and not isExpanded then
			ExpandSkillHeader(i);
			self:UpdateSkills(i+1, i+GetNumSkillLines()-numSkills);
			CollapseSkillHeader(i);
		elseif not isHeader and self.vars.skillnames[skillName] then
			self.db.realm.userdata[self.vars.playername].skills[self.vars.skillnames[skillName]] = skillRank;
		end
	end
end

function TradeskillInfo:UpdateSpecializations()
	local i = 1
	while true do
		local spellName = GetSpellName(i, BOOKTYPE_SPELL)
		if not spellName then do break end end
		if self.vars.specializationnames[spellName] then
			self.db.realm.userdata[self.vars.playername].skills[self.vars.specializationnames[spellName]] = 1;
		end
		i = i + 1
	end
end

function TradeskillInfo:MakeSpecialCase(id,itemName)
	if not self.vars.specialcases[id] then
		return id;
	end
	local spec=tostring(id)..'|'..itemName;
	for k,v in pairs(self.vars.specialcases) do
		if v==spec then
			return k
		end
	end
	return id;
end

function TradeskillInfo:GetSpecialCase(id,itemName)
	if id > 100 or not self.vars.specialcases[id] then
		return id,itemName;
	end
	_, _, id,itemName = string.find(self.vars.specialcases[id],"(%d+)|(.+)");
	return tonumber(id),itemName;
end
		
function TradeskillInfo:UpdateKnownTradeRecipes(startLine, endLine)
	local skillName, currentSkillLvl, _ = GetTradeSkillLine()
	if (skillName ~= "UNKNOWN") then
		local numSkills = GetNumTradeSkills();
		if not startLine then
			startLine = 1;
			endLine= numSkills;
		end
		local i;
		for i=startLine, endLine do
			local itemName, itemType, _,	isExpanded = GetTradeSkillInfo(i);
			if (itemType == "header" and not isExpanded) then
				ExpandTradeSkillSubClass(i);
				self:UpdateKnownTradeRecipes(i+1, i+GetNumTradeSkills()-numSkills);
				CollapseTradeSkillSubClass(i);
			elseif (itemType ~= "header" and (GetTradeSkillLine() == skillName)) then
				local link = GetTradeSkillItemLink(i);
				local id = getIdFromLink(link);
				local diff = self.vars.difficulty[itemType];
				id = self:MakeSpecialCase(id,itemName);
				if id then
					self.db.realm.userdata[self.vars.playername].knownRecipes[id] = diff;
					self:UpdateDifficultyData(id, diff, currentSkillLvl);
				else
					self:Print("UpdateKnownTradeRecipes startLine=%d endLine%d line=%d name=%s type=%s link=%s",startLine,endLine,i,itemName,itemType,link);
					return;
				end
			end
		end
	end
end

function TradeskillInfo:UpdateKnownCraftRecipes(startLine, endLine)
	local skillName, currentSkillLvl, _ = GetCraftDisplaySkillLine()
	if (skillName ~= nil) then
		if skillName ~= "Enchanting" then return end  -- Only enchanting supported
		local numSkills = GetNumCrafts();
		if not startLine then
			startLine = 1;
			endLine= numSkills;
		end
		for i=startLine, endLine do
			local craftName, _, craftType, _,	isExpanded = GetCraftInfo(i);
			if (craftType == "header" and not isExpanded) then
				ExpandCraftSkillLine(i);
				self:UpdateKnownCraftRecipes(i+1, i+GetNumCrafts()-numSkills);
				CollapseCraftSkillLine(i);
			elseif (craftType ~= "header" and (GetCraftDisplaySkillLine() == skillName)) then
				local link = GetCraftItemLink(i);
				local id = getIdFromLink(link);
				local diff = self.vars.difficulty[craftType];
				if self.vars.enchantItems[id] then  -- Enchants that generate items are stored by there itemid
					id = self.vars.enchantItems[id];
				end
				self.db.realm.userdata[self.vars.playername].knownRecipes[id] = diff;
				self:UpdateDifficultyData(id, diff, currentSkillLvl);
			end
		end
	end
end

function TradeskillInfo:UpdateDifficultyData(id, difficulty, currentSkillLvl)
	-- Update global difficulty
	if not self.db.account.difficulty[id] then
		self.db.account.difficulty[id] = "0/0/0/"..self:GetCombineLevel(id);
	end
	local d = splitn(self.db.account.difficulty[id],'/');
	if d[difficulty] > currentSkillLvl or d[difficulty] == 0 then
		d[difficulty] = currentSkillLvl;
	end
	self.db.account.difficulty[id] = ICombineTable(d,'/');
	d = nil;
end

----------------------------------------------------------------------
-- TradeSkillFrame Hook to display recipe skill level and cost/profit
----------------------------------------------------------------------
function TradeskillInfo:TradeSkillFrame_SetSelection(id)
	local skillName, skillType, numAvailable, isExpanded = GetTradeSkillInfo(id);
	if ( skillType == "header" ) then return end
	if ( GetTradeSkillSelectionIndex() > GetNumTradeSkills() ) then return end

	local link = GetTradeSkillItemLink(TradeSkillFrame.selectedSkill);
	local itemId = getIdFromLink(link)
	if self:CombineExists(itemId) then

		if self:ShowingSkillLevel() then
			-- Insert skill required.
			local text = "";
			if TradeSkillRequirementLabel:IsVisible() then
				text = TradeSkillRequirementText:GetText() .. ", ";
			end
			local skillLineName = GetTradeSkillLine();
--			text = text .. "skill(" .. self:GetCombineLevel(itemId) .. ")"
			text = text .. self:GetColoredDifficulty(itemId)
			TradeSkillRequirementLabel:Show();
			TradeSkillRequirementText:SetText(text);
		end

		if self:ShowingSkillProfit() then
			-- Insert item value and reagent costs
			local value,cost,profit = self:GetCombineCost(itemId);
			TradeSkillReagentLabel:SetText(string.format("%s s: %s - c: %s = p: %s", SPELL_REAGENTS,
				self:GetMoneyString(value), self:GetMoneyString(cost), self:GetMoneyString(profit)));
		else
			--TradeSkillReagentLabel:SetText(SPELL_REAGENTS);
		end

	end
end

----------------------------------------------------------------------
-- CraftFrame Hook to display recipe skill level
----------------------------------------------------------------------
function TradeskillInfo:CraftFrame_SetSelection(id)
	if not id then return end
	local craftName, craftSubSpellName, craftType, numAvailable, isExpanded, trainingPointCost, requiredLevel = GetCraftInfo(id);
	if ( craftType == "header" ) then return end
	if ( GetCraftSelectionIndex() > GetNumCrafts() ) then return end

	local link = GetCraftItemLink(GetCraftSelectionIndex());
	local enchantId = getIdFromLink(link);
	if self:CombineExists(enchantId) then

		if self:ShowingSkillLevel() then
			local text = REQUIRES_LABEL .. " ";
			if CraftRequirements:GetText() and CraftRequirements:GetText() ~= "" then
				text = CraftRequirements:GetText() .. ", ";
			end
			text = text .. "skill(" ..self:GetCombineLevel(enchantId) .. ")"
			CraftRequirements:SetText(text);
		end
	end
end

----------------------------------------------------------------------
-- OnClick hooks
----------------------------------------------------------------------
function TradeskillInfo:ContainerFrameItemButton_OnModifiedClick(button, ignoreModifiers)
	local link = GetContainerItemLink(this:GetParent():GetID(),this:GetID())
	if self:Item_OnClick(button,link) then return end
end

function TradeskillInfo:BankFrameItemButtonGeneric_OnModifiedClick(button)
	local link = GetContainerItemLink(BANK_CONTAINER,this:GetID())
	if self:Item_OnClick(button,link) then return end
end

function TradeskillInfo:MerchantItemButton_OnModifiedClick(button)
	local link = GetMerchantItemLink(this:GetID())
	if self:Item_OnClick(button,link) then return end
end

function TradeskillInfo:ChatFrame_OnHyperlinkShow(link,text,button)
	if self:Item_OnClick(button,text) then return end
end

function TradeskillInfo:AuctionItemButton_OnClick(object,button)
	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
	local itemID = this:GetParent():GetID()+offset
	local link = GetAuctionItemLink("list",itemID)
	if self:Item_OnClick(arg1,link) then return end
	self.hooks[object].OnClick(object,button)
end

function TradeskillInfo:Item_OnClick(button,link)
	if self.db.profile.QuickSearch then
		if ( button == self.vars.MouseButtons[self.db.profile.SearchMouseButton] and
				 self.vars.ShiftKeys[self.db.profile.SearchShiftKey]() ) then
			local id = getIdFromLink(link);
			if not self:ComponentExists(id) then return end
			if self:LoadUI(true) then -- Have TradeskillInfoUI
				local name = getNameFromLink(link);
				TradeskillInfoUI:SetSearchText("id="..id.." "..name);
				TradeskillInfoUI:Frame_Show();
			else
				self:PrintWhereUsed(id);
			end
		end
	end
end

function TradeskillInfo:GetMoneyString(value)
	if (value == nil) then
		return "|cffffcc00??|r"; -- No price
	elseif ( self.db.profile.MoneyFormat == 1 ) then
		return self.libs.Abacus:FormatMoneyCondensed(value,true,true)
	elseif ( self.db.profile.MoneyFormat == 2 ) then
		return self.libs.Abacus:FormatMoneyShort(value,true,true)
	elseif ( self.db.profile.MoneyFormat == 3 ) then
		return self.libs.Abacus:FormatMoneyFull(value,true,true)
	else
		return self.libs.Abacus:FormatMoneyExtended(value,true,true)
	end
end

----------------------------------------------------------------------
-- Combine support functions
----------------------------------------------------------------------

function TradeskillInfo:Combines()
	return pairs(self.vars.combines);
end

function TradeskillInfo:CombineExists(id)
	if id and self.vars.combines[id] then return true end
end

function TradeskillInfo:GetCombine(id)
	if not self:CombineExists(id) then return end
	local combine = {};
	local found, _, skill, spec, level, components, recipe, yield, item = string.find(self.vars.combines[id],"%d*|?(%u)(%l*)(%d+)|([^|]+)[|]?(%d*)[|]?([^|]*)[|]?(%d*)");
	combine.skill = skill;
	combine.spec = spec;
	combine.level = tonumber(level);
	if recipe ~= "" then combine.recipe = tonumber(recipe) end
	if yield ~= "" then combine.yield = tonumber(yield) else combine.yield = 1 end
	if item ~= "" then combine.item = tonumber(item) end
	if combine.item then
		combine.link, combine.quality, combine.itemString, combine.texture = getItemLink(combine.item);
	else
		combine.link, combine.quality, combine.itemString, combine.texture = getItemLink(id);
	end
	combine.name = self:GetCombineName(id);
	return combine;
end

function TradeskillInfo:GetCombineName(id)
	local name
	if id > 0 then
		name = self:GetComponent(id);
	else
		if self.vars.enchants[id] then
			_,_,name = string.find(self.vars.enchants[id],"(.+)/");
		else
			name = ""
		end
	end
	if not name then name=tostring(id) end
	return name
end

function TradeskillInfo:GetCombineEnchantId(id)
	if not self:CombineExists(id) then return 0 end
	local enchantId
	if id > 0 then
		_,_,enchantId = string.find(self.vars.combines[id],"(%d*)|?%a+%d+");
	else
		enchantId = -1 * id
	end
	return tonumber(enchantId)
end

function TradeskillInfo:GetCombineLevel(id)
	if not self:CombineExists(id) then return 0 end
	local _,_,level = string.find(self.vars.combines[id],"%d*|?%a+(%d+)");
	return tonumber(level)
end

function TradeskillInfo:GetCombineSkill(id)
	if not self:CombineExists(id) then return end
	local _,_,skill,spec,level = string.find(self.vars.combines[id],"%d*|?(%u)(%l*)(%d+)");
	if not spec then spec = "" end
	return skill,spec,tonumber(level)
end

function TradeskillInfo:GetCombineRecipe(id)
	if not self:CombineExists(id) then return end
	local _, _, recipe = string.find(self.vars.combines[id],"%d*|?[^|]+|[^|]+[|]?(%d*)");
	if recipe and recipe ~= "" then recipe = tonumber(recipe) end
	if not self.vars.recipes[recipe] then recipe = "" end
	return recipe;
end

function TradeskillInfo:GetCombineYield(id)
	if not self:CombineExists(id) then return end
	local _, _, yield = string.find(self.vars.combines[id],"%d*|?[^|]+|[^|]+[|]?%d*[|]?([^|]*)");
	if yield and yield ~= "" then yield = tonumber(yield) else yield = 1 end
	return yield
end

function TradeskillInfo:GetCombineItem(id)
	if not self:CombineExists(id) then return end
	local _, _, item = string.find(self.vars.combines[id],"%d*|?[^|]+|[^|]+[|]?%d*[|]?[^|]*[|]?(%d*)");
	if item and item ~= "" then item = tonumber(item) else item = nil end
	return item
end

function TradeskillInfo:GetCombineComponents(id)
	if not self:CombineExists(id) then return end
	local components = {};
	local _, _, compstring = string.find(self.vars.combines[id],"%d*|?[^|]+|([^|]+)");
	for s in string.gmatch(compstring,"%S+") do
		local c = {};
		_,_,c.id,c.num = string.find(s,"(%d+):(%d+)");
		c.id = tonumber(c.id) or tonumber(s);
		c.num = tonumber(c.num) or 1;
		c.name,c.cost,c.source = self:GetComponent(c.id);
		c.link, c.quality, c.itemString, c.texture = getItemLink(c.id);
		table.insert(components,c);
	end
	return components;
end

function TradeskillInfo:GetCombineDescription(id)
	local description
	if id < 0 then
		if self.vars.enchants[id] then
			_,_,description = string.find(self.vars.enchants[id],"[^/]*/(.*)");
		end
	end
	return description
end

function TradeskillInfo:GetCombineTexture(id)
	if not self:CombineExists(id) then return end
	local combineLink,combineItemString,combineTexture
	local item = self:GetCombineItem(id);
	if item and item ~= "" then
		combineLink,_,combineItemString,combineTexture = getItemLink(tonumber(item));
	elseif id < 0 then
		local combineName = self:GetCombineName(id);
		combineLink,_,combineItemString,combineTexture = getItemLink(id,combineName);
	else
		combineLink,_,combineItemString,combineTexture = getItemLink(id);
	end
	return combineTexture,combineLink,combineItemString;
end

function TradeskillInfo:GetCombineAvailability(id)
	if not self:CombineExists(id) then return end
	local player,alt = 0,0;
	-- 0 = Unavailable, 1 = known, 2 = learnable, 3 = will be able to learn
	local combineSkill,combineSpec,combineLevel = self:GetCombineSkill(id);
	local playerSkillLevel = self:GetCharSkillLevel(self.vars.playername,combineSkill);
	local playerSpec = self:GetCharSkillLevel(self.vars.playername,combineSpec);
	if playerSkillLevel and (combineSpec=="" or playerSpec) then
		if playerSkillLevel >= combineLevel then
			if self:IsCombineKnowByChar(self.vars.playername,id) then
				player = 1;
			else
				player = 2;
			end
		else
			player = 3;
		end
	end

	for name in pairs(self.db.realm.userdata) do
		if name ~= self.vars.playername then
			local skillLevel = self:GetCharSkillLevel(name,combineSkill);
			local charSpec = self:GetCharSkillLevel(name,combineSpec);
			if skillLevel and (combineSpec=="" or charSpec) then
				if skillLevel >= combineLevel then
					if self:IsCombineKnowByChar(name,id) then
						alt = 1;
					elseif alt == 0 or alt == 3 then
						alt = 2;
					end
				elseif alt == 0 then
					alt = 3
				end
			end
		end
		if alt == 1 then break end
	end
	return player,alt
end

function TradeskillInfo:GetColoredDifficulty(id)
	if not self:CombineExists(id) then return "" end
	local s = "";
	if self.db.account.difficulty[id] then
		local d = splitn(self.db.account.difficulty[id],'/');
		for i,l in ipairs(d) do
			if i == 1 then
				s = self.vars.diffcolors[i]..d[i].."|r";
			else
				s = s.."/"..self.vars.diffcolors[i]..d[i].."|r";
			end
		end
	else
		local level = self:GetCombineLevel(id);
		local knownRecipes = self.db.realm.userdata[self.vars.playername].knownRecipes;
		if knownRecipes and
			 knownRecipes[id] then
			diff = knownRecipes[id];
			s = "skill("..self.vars.diffcolors[diff]..level.."|r)";
		else
			s = "skill("..level..")";
		end
	end
	return s
end

function TradeskillInfo:GetCombineCost(id)
	if not self:CombineExists(id) then return end
	local components = self:GetCombineComponents(id);
	local value = 0;
	local item = self:GetCombineItem(id);
	if item then
		_,value = self:GetComponent(item);
	elseif id > 0 then
		_,value = self:GetComponent(id)
	end
	local cost = 0;
	for _,c in ipairs(components) do
		cost = cost + c.cost * c.num
	end
	components = nil;
	return value, cost, value-cost;
end

function TradeskillInfo:PrintCombine(id)
	if not self:CombineExists(id) then return end
	local combine = self:GetCombine(id)
	local text = string.format("%s : %s(%d) %s ", combine.link or combine.name, self.vars.tradeskills[combine.skill], combine.level, self.vars.specializations[combine.spec] or "" );
	for i,c in ipairs(combine.components) do
		text = text .. string.format("x%d*%s ", c.num, c.link or c.name);
	end
	combine = nil;
	self:Print(text);
end

function TradeskillInfo:GetCombineFactionAvailable(id)
	if not self:CombineExists(id) then return end
	local rid = self:GetCombineRecipe(id);
	if rid and rid~="" then
		return self:GetRecipeFactionAvailable(rid);
	end
	return true;
end

----------------------------------------------------------------------
-- Component support functions
----------------------------------------------------------------------

function TradeskillInfo:Components()
	return pairs(self.vars.components)
end

function TradeskillInfo:ComponentExists(id)
	if id and self.vars.components[id] then return true end
end

function TradeskillInfo:GetIdFromName(name)
	for i,s in pairs(self.vars.components) do
		local _,_,n = string.find(s,"(.+)/%d+/%a+")
		if n == name then
			return i;
		end
	end
end

function TradeskillInfo:GetComponent(id)
	if not self:ComponentExists(id) then return end
	local _,_,name,cost,source = string.find(self.vars.components[id],"(.+)/(%d+)/(%a+)")
	return name,tonumber(cost),source
end

function TradeskillInfo:GetComponentSource(id)
	if not self:ComponentExists(id) then return end
	local _,_,name,cost,source = string.find(self.vars.components[id],"(.+)/(%d+)/(%a+)")
	local ret
	for s in string.gmatch(source,"%u%l*") do
		if self.vars.sources[s] then
			local sourcename = self.vars.sources[s];
			if ret then
				ret = ret..", "..sourcename;
			else
				ret = sourcename;
			end
		else
			self:Print("Found unknown source",s);
		end
	end
	return ret
end

----------------------------------------------------------------------
-- Where Used
----------------------------------------------------------------------

function TradeskillInfo:PrintWhereUsed(id)
	if not self.vars.whereUsed[id] then
		self:Print("Not used in any know tradeskill");
		return
	end
	local skills = {}
	local num = 0;
	for s in string.gmatch(self.vars.whereUsed[id],"%S+") do
		num = num + 1;
    local _,_,skill,item = string.find(s, "(%u+)([-]?%d+)")
    if not skills[skill] then
    	skills[skill] = {}
    end
    table.insert(skills[skill],tonumber(item))
	end
	local name = self:GetComponent(id);
	self:Print("Found "..name.." in "..num.." combines");
	for n,s in pairs(skills) do
		self:Print(table.getn(s).." "..self.vars.tradeskills[n].." combines");
		for _,i in ipairs(s) do
			self:PrintCombine(i);
		end
	end
	skills = nil
end

function TradeskillInfo:GetUsedIn(id)
	if not self.vars.whereUsedOverview[id] then return end
	local overview
	for s in string.gmatch(self.vars.whereUsedOverview[id],"%S+") do
    local _,_,skill,num = string.find(s, "(%u+)(%d+)")
    local skillname = self.vars.tradeskills[skill];
    if skillname then
    	if not overview then
    		overview = skillname.."("..num..")";
    	else
    		overview = overview..", "..skillname.."("..num..")";
    	end
	  else
	  	self:Print("Found unknown skill",s);
	  end
	end
	return overview;
end

function TradeskillInfo:BuildWhereUsed()
	self.vars.whereUsed = {};
	for i,_ in pairs(self.vars.combines) do
		local skill,spec,level = self:GetCombineSkill(i);
		local components = self:GetCombineComponents(i);
		for _,c in ipairs(components) do
			if not self.vars.whereUsed[c.id] then
				self.vars.whereUsed[c.id]=skill..tostring(i);
			else
				self.vars.whereUsed[c.id]=self.vars.whereUsed[c.id].." "..skill..tostring(i);
			end
		end
		components = nil
	end

	self.vars.whereUsedOverview = {}
	for i,_ in pairs(self.vars.whereUsed) do
		local skills = self:GetItemUseCount(i);
		local overview
		for s,n in pairs(skills) do
	    if not overview then
	    	overview = s..n;
	    else
	    	overview = overview.." "..s..tostring(n);
	    end
	  end
		self.vars.whereUsedOverview[i] = overview;
	end
end

local function AddTable(tbl1,tbl2)
	for i,v in pairs(tbl2) do
		if tbl1[i] then
			tbl1[i] = tbl1[i] + v;
		else
			tbl1[i] = v;
		end
	end
end

function TradeskillInfo:GetItemUseCount(item,deep)
	if not deep then deep = 1 end
	local skills = {};
	if self.vars.whereUsed[item] and deep < 5 then
		for s in string.gmatch(self.vars.whereUsed[item],"%S+") do
			local _,_,skill,item2 = string.find(s, "(%u)([-]?%d+)");
			if skill then
				AddTable(skills,{[skill]=1});
				local skills2 = self:GetItemUseCount(tonumber(item2),deep+1);
				AddTable(skills,skills2);
			end
		end
	end
	return skills
end

function TradeskillInfo:GetItemUsedIn(item,use)
	if not use then use = {} end
	if self.vars.whereUsed[item] then
		for s in string.gmatch(self.vars.whereUsed[item],"%S+") do
			local _,_,skill,item2 = string.find(s,"(%u)([-]?%d+)");
			item2 = tonumber(item2);
			if not use[item2] then
				use[item2] = true;
				self:GetItemUsedIn(item2,use);
			end
		end
	end
	return use
end

----------------------------------------------------------------------
--- Recipe functions
----------------------------------------------------------------------

--function TradeskillInfo:BuildRecipeTable()
--	self.vars.recipes = {};
--	self.db.account.recipes = {};
--	for i,_ in pairs(self.vars.combines) do
--		local recipe = self:GetCombineRecipe(i);
--		if recipe then
--			self.vars.recipes[recipe] = tostring(i);
--		end
--	end
--end

function TradeskillInfo:GetRecipeItem(recipe)
	if not self.vars.recipes[recipe] then return end
	local _, _, item = string.find(self.vars.recipes[recipe],"([-]?%d+)|");
	return tonumber(item);
end

function TradeskillInfo:GetRecipeSources(recipe,opposing)
	if not self.vars.recipes[recipe] then return end
	local found, _, sources,price,level = string.find(self.vars.recipes[recipe],"[^|]+|(%w+)[|]?(%d*)[|]?(%d*)");
	if not found then return end
	if price == "" then price = nil else price = tonumber(price) end
	local uf = UnitFactionGroup("player")
	local res = ""
	for s,n in string.gmatch(sources,"(%u%l*)(%d*)") do
		if (s=="V" or s=="Q" or s=="D") and n~="" then
			local found,_,vname,znr,fnr,pos,note = string.find(self.vars.vendors[tonumber(n)],"([^|]+)|(%d+)|(%d+)[|]?([^|]*)[|]?([^|]*)");
			if found then
				if opposing or (uf=="Horde" and fnr~="1") or (uf=="Alliance" and fnr~="2") then
					local zone = self.vars.zones[tonumber(znr)];
					local faction = self.vars.factions[tonumber(fnr)];
					if res ~= "" then
						res = res.."\n";
					end
					if pos ~= "" then
						pos = " ("..pos..")"
					end
					if note ~= "" then
						note = " "..note
					end
					res = res..self.vars.sources[s]..": "..vname..", "..zone..pos..note
					if level ~= "" then
						local rep = getglobal("FACTION_STANDING_LABEL"..level);
						res = res.." "..faction.."-"..rep;
					end
				end
			else
				self:Print("Unknown NPC. Please report it. Source=",s);
			end
		elseif self.vars.sources[s] then
			local _,_,f = string.find(s,"%u(%l*)")
			if opposing or (uf=="Horde" and f~="a") or (uf=="Alliance" and f~="h") then
				if res ~= "" then
					res = res.."\n";
				end
				res = res..self.vars.sources[s];
			end
		else
			self:Print("Unknown source. Please report it. Source=",s);
		end
	end
	return res,price
end

-- Returns true if the recipe is available to this players faction
function TradeskillInfo:GetRecipeFactionAvailable(recipe)
	if not self.vars.recipes[recipe] then return end
	local found, _, sources = string.find(self.vars.recipes[recipe],"[^|]+|(%w+)");
	if not found then return end
	local uf = UnitFactionGroup("player")
	for s,n in string.gmatch(sources,"(%u%l*)(%d*)") do
		if (s=="V" or s=="Q") and n~="" then
			local found,_,fnr = string.find(self.vars.vendors[tonumber(n)],"[^|]+|[^|]+|(%d+)");
			if found then
				if (uf=="Horde" and fnr~="1") or (uf=="Alliance" and fnr~="2") then
					return true;
				end
			end
		else
			local _,_,f = string.find(s,"%u(%l*)")
			if (uf=="Horde" and f~="a") or (uf=="Alliance" and f~="h") then
				return true;
			end
		end
	end
end

function TradeskillInfo:GetRecipeKnownBy(recipe)
	local item = self:GetRecipeItem(recipe);
	local res;
	if item then
		res = self:GetCombineKnownBy(item);
	end
	return res
end

function TradeskillInfo:GetRecipeLearnableBy(recipe)
	local item = self:GetRecipeItem(recipe);
	local res;
	if item then
		res = self:GetCombineLearnableBy(item);
	end
	return res
end

function TradeskillInfo:GetRecipeAvailableTo(recipe)
	local item = self:GetRecipeItem(recipe);
	local res;
	if item then
		res = self:GetCombineAvailableTo(item);
	end
	return res
end

----------------------------------------------------------------
--  Saved Skills and Known Combines functions
----------------------------------------------------------------

function TradeskillInfo:GetChars()
	local chars = {};
	for n,_ in pairs(self.db.realm.userdata) do
		table.insert(chars,n);
	end
	return chars;
end

function TradeskillInfo:Chars()
	return pairs(self.db.realm.userdata);
end

function TradeskillInfo:GetAltChars()
	local chars = {};
	for n,_ in pairs(self.db.realm.userdata) do
		if n ~= self.vars.playername then
			table.insert(chars,n);
		end
	end
	return chars;
end

function TradeskillInfo:AltChars()
	return function()
		local name = next(self.db.realm.userdata);
		if name == self.vars.playername then
			name = next(self.db.realm.userdata);
		end
		if name then
			return name;
		else
			return nil;
		end
	end, nil, nil
end

function TradeskillInfo:GetCharSkillLevel(name,skill)
	return self.db.realm.userdata[name].skills[skill]
end

function TradeskillInfo:GetCharSkills(name)
	local skills = {};
	for skill,level in pairs(self.db.realm.userdata[name].skills) do
		skills[skill] = level;
	end
	return skills;
end

function TradeskillInfo:CharSkills(name)
	return pairs(self.db.realm.userdata[name].skills);
end

function TradeskillInfo:IsCombineKnowByChar(name,id)
	return self.db.realm.userdata[name].knownRecipes[id];
end

function TradeskillInfo:GetCombineKnownBy(id)
	local text
	for name in pairs(self.db.realm.userdata) do
		local known = self:IsCombineKnowByChar(name,id);
		if known then
			if text then
				text = text..", "..self.vars.diffcolors[known]..name.."|r";
			else
				text = self.vars.diffcolors[known]..name.."|r";
			end
		end
	end
	return text;
end

function TradeskillInfo:IsCombineLearnableByChar(name,id)
	local combineSkill,combineSpec,combineLevel = self:GetCombineSkill(id);
	local charLevel = self:GetCharSkillLevel(name,combineSkill);
	local charSpec = self:GetCharSkillLevel(name,combineSpec);
	if charLevel and charLevel >= combineLevel and not self:IsCombineKnowByChar(name,id) and (combineSpec=="" or charSpec) then
		return charLevel;
	end
end

function TradeskillInfo:GetCombineLearnableBy(id)
	local text
	for name,userdata in pairs(self.db.realm.userdata) do
		local charLevel = self:IsCombineLearnableByChar(name,id);
		if charLevel then
			if text then
				text = text..", "..name.."("..charLevel..")";
			else
				text = name.."("..charLevel..")";
			end
		end
	end
	return text;
end

function TradeskillInfo:IsCombineAvailableToChar(name,id)
	local combineSkill,combineSpec,combineLevel = self:GetCombineSkill(id);
	local charLevel = self:GetCharSkillLevel(name,combineSkill);
	local charSpec = self:GetCharSkillLevel(name,combineSpec);
	if charLevel and charLevel < combineLevel and (combineSpec=="" or charSpec) then
		return charLevel;
	end
end

function TradeskillInfo:GetCombineAvailableTo(id)
	local text
	for name,userdata in pairs(self.db.realm.userdata) do
		local charLevel = self:IsCombineAvailableToChar(name,id)
		if charLevel then
			if text then
				text = text..", "..name.."("..charLevel..")";
			else
				text = name.."("..charLevel..")";
			end
		end
	end
	return text;
end

function TradeskillInfo:GetItemUsableByChar(name,id,deep)
	if not deep then deep = 1 end
	local num = 0;
	if self.vars.whereUsed[id] and deep < 5 then
		for s in string.gmatch(self.vars.whereUsed[id],"%S+") do
			local _,_,skill,combine = string.find(s, "(%u)([-]?%d+)");
			local known = self:IsCombineKnowByChar(name,tonumber(combine));
			if known then 
				num = num + 1 + self:GetItemUsableByChar(name,tonumber(combine),deep+1)
			end
		end
	end
	return num
end

function TradeskillInfo:GetItemUsableBy(id)
	if not self.vars.whereUsed[id] then return end
	local text
	for name,userdata in pairs(self.db.realm.userdata) do
		local num = self:GetItemUsableByChar(name,id);
		if num > 0 then
			if text then
				text = text..", "..name.."("..num..")";
			else
				text = name.."("..num..")";
			end
		end
	end
	return text;
end

----------------------------------------------------------------
--  Tooltip Functions
----------------------------------------------------------------

function TradeskillInfo:HookTooltips()
	self:SecureHook(GameTooltip, "SetBagItem");
	self:SecureHook(GameTooltip, "SetInventoryItem");
	self:SecureHook(GameTooltip, "SetLootItem");
	self:SecureHook(GameTooltip, "SetHyperlink");
	self:SecureHook(GameTooltip, "SetCraftItem");
	self:SecureHook(GameTooltip, "SetTradeSkillItem");
	self:SecureHook(GameTooltip, "SetMerchantItem");
	self:SecureHook(GameTooltip, "SetAuctionItem");
	self:SecureHook(GameTooltip, "SetTrainerService");
	self:SecureHook(GameTooltip, "SetGuildBankItem");
	self:SecureHook("SetItemRef");
end

--- Hooks for tooltips

function TradeskillInfo:SetItemRef(link, text, button)
--	if IsControlKeyDown() or IsShiftKeyDown() then return end
	if ( IsModifiedClick() ) then return end
    local id = getIdFromLink(link);
	if id then
		self:AddToTooltip(ItemRefTooltip,id);
	end
end

function TradeskillInfo:SetBagItem(tooltip, bag, slot)
	local link = GetContainerItemLink(bag, slot);
	local id = getIdFromLink(link);
	self:AddToTooltip(tooltip, id);
end

function TradeskillInfo:SetGuildBankItem(tooltip, tab, slot)
	local link = GetGuildBankItemLink(tab, slot);
	local id = getIdFromLink(link);
	self:AddToTooltip(tooltip, id);
end

function TradeskillInfo:SetInventoryItem(tooltip, unit, slot, nameOnly)
	if slot > 39 and slot < 68 then
		local link = GetContainerItemLink(BANK_CONTAINER, slot-39)
		local id = getIdFromLink(link);
		self:AddToTooltip(tooltip, id);
	end
end

function TradeskillInfo:SetLootItem(tooltip, index)
	local link = GetLootSlotLink(index);
	local id = getIdFromLink(link);
	self:AddToTooltip(tooltip, id);
end

function TradeskillInfo:SetHyperlink(tooltip, link)
	local id = getIdFromLink(link)
	self:AddToTooltip(tooltip, id);
end

function TradeskillInfo:SetCraftItem(tooltip, itemIndex, reagentIndex)
	local link
	if reagentIndex then
		link = GetCraftReagentItemLink(itemIndex, reagentIndex);
	else
		link = GetCraftItemLink(itemIndex);
	end
	local id = getIdFromLink(link)
	self:AddToTooltip(tooltip, id);
end

function TradeskillInfo:SetTradeSkillItem(tooltip, itemIndex, reagentIndex)
	local link
	if reagentIndex then
		link = GetTradeSkillReagentItemLink(itemIndex, reagentIndex);
	else
		link = GetTradeSkillItemLink(itemIndex);
	end
	local id = getIdFromLink(link)
	self:AddToTooltip(tooltip, id);
end

function TradeskillInfo:SetMerchantItem(tooltip, index)
	local link = GetMerchantItemLink(index);
	local id = getIdFromLink(link);
	self:AddToTooltip(tooltip, id);
end

function TradeskillInfo:SetAuctionItem(tooltip, type, index)
	local link = GetAuctionItemLink(type, index);
	local id = getIdFromLink(link);
	self:AddToTooltip(tooltip, id);
end

function TradeskillInfo:SetTrainerService(tooltip, selectedService)
	local name = getglobal(tooltip:GetName().."TextLeft1"):GetText();
	if category ~= "header" then
		local id = self:GetIdFromName(name);
		if id then
			self:AddToTooltip(tooltip, id);
			self:AddReagentsToTooltip(tooltip, id);
		end
	end
end

---- Processing of tooltips

function TradeskillInfo:AddToTooltip(tooltip, id)
	self:AddUsedInToTooltip(tooltip, id);
	self:AddUsableByToTooltip(tooltip, id);
	self:AddSourceToTooltip(tooltip, id);
	self:AddRecipeKnownByToTooltip(tooltip, id);
	self:AddBankedAmountToTooltip(tooltip, id);
	self:AddAltAmountToTooltip(tooltip, id);
	self:AddIdToTooltip(tooltip, id);
	self:AddStackToTooltip(tooltip, id);
	tooltip:Show();
end

function TradeskillInfo:AddSourceToTooltip(tooltip, id)
	if self:ShowingTooltipSource() then
		local source = self:GetComponentSource(id);
		if source then
			local c = self.db.profile.ColorSource;
			tooltip:AddLine("Source: "..source, c.r, c.g, c.b, 1);
		end
	end
	if self:ShowingTooltipRecipeSource() or self:ShowingTooltipRecipePrice() then
		source, price = self:GetRecipeSources(id);
		if source and self:ShowingTooltipRecipeSource() then
			local c = self.db.profile.ColorRecipeSource;
			tooltip:AddLine("Source: "..source, c.r, c.g, c.b, 0);
		end
		if price and self:ShowingTooltipRecipePrice() then
			local c = self.db.profile.ColorRecipePrice;
			tooltip:AddLine("Vendor sell price: "..self:GetMoneyString(price), c.r, c.g, c.b, 0);
		end
	end
end

function TradeskillInfo:AddUsedInToTooltip(tooltip, id)
	if self:ShowingTooltipUsedIn() then
		local usedIn = self:GetUsedIn(id);
		if usedIn then
			local c = self.db.profile.ColorUsedIn;
			tooltip:AddLine("Used In: "..usedIn, c.r, c.g, c.b, 1);
		end
	end
end

function TradeskillInfo:AddUsableByToTooltip(tooltip, id)
	if self:ShowingTooltipUsableBy() then
		local usableBy = self:GetItemUsableBy(id);
		if usableBy then
			local c = self.db.profile.ColorUsableBy;
			tooltip:AddLine("Usable By: "..usableBy, c.r, c.g, c.b, 1);
		end
	end
end

function TradeskillInfo:AddRecipeKnownByToTooltip(tooltip, id)
	id = self:GetRecipeItem(id);
	if id then
		if self:ShowingTooltipKnownBy() then
			local knownBy = self:GetCombineKnownBy(id)
			if knownBy then
				local c = self.db.profile.ColorKnownBy;
				tooltip:AddLine("Known By: "..knownBy, c.r, c.g, c.b, 1);
			end
		end
		if self:ShowingTooltipLearnableBy() then
			local learnableBy = self:GetCombineLearnableBy(id)
			if learnableBy then
				local c = self.db.profile.ColorLearnableBy;
				tooltip:AddLine("Learnable By: "..learnableBy, c.r, c.g, c.b, 1);
			end
		end
		if self:ShowingTooltipAvailableTo() then
			local availableTo = self:GetCombineAvailableTo(id)
			if availableTo then
				local c = self.db.profile.ColorAvailableTo;
				tooltip:AddLine("Will Be Learnable By: "..availableTo, c.r, c.g, c.b, 1);
			end
		end
	end
end

function TradeskillInfo:AddBankedAmountToTooltip(tooltip, id)
	if self:ShowingTooltipBankedAmount() and CharacterInfoStorage then
		local amount = CharacterInfoStorage:GetNumItemsBank(self.vars.playername,id);
		if amount > 0 then
			local c = self.db.profile.ColorBankedAmount;
			tooltip:AddLine("Banked: "..tostring(amount), c.r, c.g, c.b, 1);
		end
	end
end

function TradeskillInfo:AddAltAmountToTooltip(tooltip, id)
	if self:ShowingTooltipAltAmount() and CharacterInfoStorage then
		local chars = CharacterInfoStorage:GetCharacters();
		local text = "";
		for _,name in ipairs(chars) do
			if name ~= self.vars.playername then
				local amount = CharacterInfoStorage:GetNumItems(name,id);
				if amount > 0 then
					if text ~= "" then
						text = text..", ";
					end
					text = text..name.."("..tostring(amount)..")";
				end
			end
		end
		if text ~= "" then
			local c = self.db.profile.ColorAltAmount;
			tooltip:AddLine("Alts have: "..text, c.r, c.g, c.b, 1);
		end
	end
end

function TradeskillInfo:AddReagentsToTooltip(tooltip, id)
	if self:ShowingTrainerReagents() then
		local components = self:GetCombineComponents(id);
		if components then
			local text
			for _,c in ipairs(components) do
				if not c.quality then c.quality = 1 end
				local _, _, _, hexColor = GetItemQualityColor(c.quality);
				if not text then
					text = c.num.."*"..hexColor..c.name.."|r";
				else
					text = text..", "..c.num.."*"..hexColor..c.name.."|r";
				end
			end
			local c = self.db.profile.ColorTrainerReagents;
			tooltip:AddLine("Reagents: "..text, c.r, c.g, c.b, 1);
			tooltip:Show();
		end
		components = nil;
	end
end

function TradeskillInfo:AddIdToTooltip(tooltip, id)
	if self:ShowingTooltipID() then
		if id then
			local c = self.db.profile.ColorID;
			tooltip:AddLine("ItemID: "..id, c.r, c.g, c.b, 1);
		end
	end
end

function TradeskillInfo:AddStackToTooltip(tooltip, id)
	if self:ShowingTooltipStack() then
		if id then
			local stack
			_,_,_,_,_,_,_, stack = GetItemInfo(id);
			if stack and stack > 1 then
				local c = self.db.profile.ColorStack;
				tooltip:AddLine("Stack size: "..stack, c.r, c.g, c.b );
			end
		end
	end
end

		
----------------------------------------------------------------------
-- Parse enchant tooltips to store information
----------------------------------------------------------------------
--do
--	local enchants
--	local index
--	function TradeskillInfo:ParseEnchantTooltip()
--		self.db.account.enchantdescriptions = {};
--		enchants = {};
--		index = 0;
--		for i in pairs(self.vars.enchants) do
--			table.insert(enchants,i);
--		end
--		self:ScheduleEvent(self.SetEnchantTooltip,1,self);
--	end
--
--	function TradeskillInfo:SetEnchantTooltip()
--		index = index + 1;
--		if enchants[index] then
--			GameTooltip:SetOwner(UIParent);
--			GameTooltip:SetHyperlink("enchant:"..-enchants[index]);
--			self:ScheduleEvent(self.ReadEnchantTooltip,1,self);
--		end
--	end
--
--	function TradeskillInfo:ReadEnchantTooltip()
--		local enchantname = GameTooltipTextLeft1:GetText();
--		local enchantdescription = GameTooltipTextLeft5:GetText();
--		if not enchantname then enchantname="" end
--		if not enchantdescription then enchantdescription="" end
--		self.db.account.enchantdescriptions[enchants[index]] = enchantname.."/"..enchantdescription;
--		GameTooltip:Hide();
--		self:ScheduleEvent(self.SetEnchantTooltip,1,self);
--	end
--end

----------------------------------------------------------------------
-- UI Load and Toggle
----------------------------------------------------------------------

function TradeskillInfo:LoadUI(quiet)
	if not IsAddOnLoaded("TradeskillInfoUI") then
		loaded,reason = LoadAddOn("TradeskillInfoUI");
		if not loaded then
			if not quiet then self:Print("Could not load the UI. Reason: ",reason) end
		else
			self:Config_Init();
		end
		return loaded
	end
	return true
end

function TradeskillInfo:UI_Toggle()
	if self:LoadUI() then
		TradeskillInfoUI:Frame_Toggle();
	end
end

function TradeskillInfo:Config_Toggle()
	if self:LoadUI() then
		if TradeskillInfoConfigFrame:IsVisible() then
			self:Config_Hide();
		else
			self:Config_Show();
		end
	end
end

----------------------------------------------------------------------
-- Auction House
----------------------------------------------------------------------
function TradeskillInfo:AuctionFrameBrowse_Update()
	if not self:ColoringAHRecipes() then return end
	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame);

	for i=1, NUM_BROWSE_TO_DISPLAY do		
		local index = offset + i;
		local button = getglobal("BrowseButton"..i);
		if button:IsVisible() then
			local recipeLink = GetAuctionItemLink("list", index)
			local buttonName = "BrowseButton"..i;
			local iconTexture = getglobal(buttonName.."ItemIconTexture");
			local recipeId = getIdFromLink(recipeLink);
			--self:Print("Item: %d(%d) %d %s",i,index,recipeId,recipeLink);
			local id = self:GetRecipeItem(recipeId);
			if id then
				local you,alt = self:GetCombineAvailability(id);
				--self:Print("recipe: %s you %d alt %d",id,you,alt);
				-- 0 = Unavailable, 1 = known, 2 = learnable, 3 = will be able to learn
				if you == 2 then
					local c = self.db.profile.AHColorLearnable;
					iconTexture:SetVertexColor(c.r, c.g, c.b);
				elseif alt == 2 then
					local c = self.db.profile.AHColorAltLearnable;
					iconTexture:SetVertexColor(c.r, c.g, c.b);
				elseif you == 3 then
					local c = self.db.profile.AHColorWillLearn;
					iconTexture:SetVertexColor(c.r, c.g, c.b);
				elseif alt == 3 then
					local c = self.db.profile.AHColorAltWillLearn;
					iconTexture:SetVertexColor(c.r, c.g, c.b);
				else
					local c = self.db.profile.AHColorUnavailable;
					iconTexture:SetVertexColor(c.r, c.g, c.b);
				end
--				local knownBy = self:GetCombineKnownBy(id)			
--				local learnableBy = self:GetCombineLearnableBy(id)
--				local availableTo = self:GetCombineAvailableTo(id)
--				if learnableBy then
--					iconTexture:SetVertexColor(1.0, 0.1, 0.1);
--				elseif availableTo then
--					iconTexture:SetVertexColor(1.0, 0.1, 0.1);
--				elseif knownBy then
--					iconTexture:SetVertexColor(1.0, 0.1, 0.1);
--				end
			end
		end
	end
end

----------------------------------------------------------------------
-- Property functions
----------------------------------------------------------------------

function TradeskillInfo:ShowingSkillLevel()
	return self.db.profile.ShowSkillLevel;
end

function TradeskillInfo:ShowingSkillProfit()
	return self.db.profile.ShowSkillProfit;
end

function TradeskillInfo:ShowingTooltipUsedIn()
	return self.db.profile.TooltipUsedIn;
end

function TradeskillInfo:ShowingTooltipSource()
	return self.db.profile.TooltipSource;
end

function TradeskillInfo:ShowingTooltipRecipeSource()
	return self.db.profile.TooltipRecipeSource;
end

function TradeskillInfo:ShowingTooltipRecipePrice()
	return self.db.profile.TooltipRecipePrice;
end

function TradeskillInfo:ShowingTooltipKnownBy()
	return self.db.profile.TooltipKnownBy;
end

function TradeskillInfo:ShowingTooltipLearnableBy()
	return self.db.profile.TooltipLearnableBy;
end

function TradeskillInfo:ShowingTooltipAvailableTo()
	return self.db.profile.TooltipAvailableTo;
end

function TradeskillInfo:ShowingTrainerReagents()
	return self.db.profile.TrainerReagents;
end

function TradeskillInfo:ShowingTooltipUsableBy()
	return self.db.profile.TooltipUsableBy;
end

function TradeskillInfo:ShowingTooltipID()
	return self.db.profile.TooltipID;
end

function TradeskillInfo:ShowingTooltipStack()
	return self.db.profile.TooltipStack;
end

function TradeskillInfo:ColoringAHRecipes()
	return self.db.profile.ColorAHRecipes;
end

function TradeskillInfo:ShowingTooltipBankedAmount()
	return self.db.profile.TooltipBankedAmount;
end

function TradeskillInfo:ShowingTooltipAltAmount()
	return self.db.profile.TooltipAltAmount;
end

--[[ FuBar Stuff --]]
TradeskillInfo.title = "TSI"
TradeskillInfo.hasIcon = "Interface\\Icons\\INV_Elemental_Mote_Nether"
TradeskillInfo.hasNoColor = true
TradeskillInfo.hideWithoutStandby = true
TradeskillInfo.independentProfile = true
TradeskillInfo.cannotDetachTooltip = true

TradeskillInfo.OnMenuRequest = {
	type = "group",
	handler = TradeskillInfo,
	args = {
		GUI_Display = {
			type = "execute",
			name = "Toggle GUI",
			desc = "Toggle the TradeskillInfo GUI",
            func  = function() TradeskillInfo:UI_Toggle() end,
		},
		GUI_Config = {
			type = "execute",
			name = "Options",
			desc = "Toggle the TradeskillInfo Options Screen",
			func  = function() TradeskillInfo:Config_Toggle() end,
		},
	},
}
function TradeskillInfo:OnDoubleClick()
TradeskillInfo:UI_Toggle()
end
function TradeskillInfo:OnClick()
TradeskillInfo:UI_Toggle()
end

