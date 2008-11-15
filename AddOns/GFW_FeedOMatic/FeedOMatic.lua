------------------------------------------------------
-- FeedOMatic.lua
------------------------------------------------------

-- Food quality by itemLevel
--
-- levelDelta = petLevel - foodItemLevel
-- levelDelta > 30 = won't eat
-- 30 >= levelDelta > 20 = 8 happiness per tick
-- 20 >= levelDelta > 10 = 17 happiness per tick
-- 10 >= levelDelta = 35 happiness per tick

-- constants
FOM_WARNING_INTERVAL = 10; -- don't warn more than once per this many seconds
MAX_KEEPOPEN_SLOTS = 150;
FOM_FEED_PET_SPELL_ID = 6991;
FOM_COOKING_SPELL_ID = 2550;

-- Variables
FOM_ShouldFeed = false;
FOM_LastWarning = 0;

FOM_LastPetName = nil;

FOM_ExcludedFoodCategories = {
	["Consumable.Food.Edible.Bonus"] = 1;
};
FOM_ExcludedFoods = {};
FOM_CookingDifficulty = {};
FOM_CookingRecipes = {};

-- Anti-freeze code borrowed from ReagentInfo (in turn, from Quest-I-On):
-- keeps WoW from locking up if we try to scan the tradeskill window too fast.
FOM_TradeSkillLock = { };
FOM_TradeSkillLock.Locked = false;
FOM_TradeSkillLock.EventTimer = 0;
FOM_TradeSkillLock.EventCooldown = 0;
FOM_TradeSkillLock.EventCooldownTime = 1;

FOM_DifficultyLabels = {
	GFWUtils.Hilite("all"),
	GFWUtils.ColorText("easy", QuestDifficultyColor["standard"]),
	GFWUtils.ColorText("medium", QuestDifficultyColor["difficult"]),
	GFWUtils.ColorText("difficult", QuestDifficultyColor["verydifficult"]),
	GFWUtils.ColorText("unknown", QuestDifficultyColor["impossible"]),
};

FOM_DifficultyColors = {
	QuestDifficultyColor["trivial"],
	QuestDifficultyColor["standard"],
	QuestDifficultyColor["difficult"],
	QuestDifficultyColor["verydifficult"],
	QuestDifficultyColor["impossible"],
};

FOM_PTDiets = {
	[FOM_DIET_MEAT] = "Consumable.Food.Meat",
	[FOM_DIET_FISH] = "Consumable.Food.Fish",
	[FOM_DIET_BREAD] = "Consumable.Food.Bread",
	[FOM_DIET_CHEESE] = "Consumable.Food.Cheese",
	[FOM_DIET_FRUIT] = "Consumable.Food.Fruit",
	[FOM_DIET_FUNGUS] = "Consumable.Food.Fungus",
}

FOM_PTCategories = {
	"Consumable.Food.Edible.Bread.Conjured",
	"Consumable.Food.Edible.Bread.Combo.Conjured",
	"Consumable.Food.Edible.Basic.Non-Conjured",
	"Consumable.Food.Edible.Combo.Non-Conjured",
	"Consumable.Food.Edible.Bonus",
	"Consumable.Food.Inedible",
};
FOM_CategoryNames = {
	["Consumable.Food.Edible.Bread.Conjured"] = FOM_OPTIONS_FOODS_CONJURED,
	["Consumable.Food.Edible.Bread.Combo.Conjured"] = FOM_OPTIONS_FOODS_CONJ_COMBO,
	["Consumable.Food.Edible.Basic.Non-Conjured"] = FOM_OPTIONS_FOODS_BASIC,
	["Consumable.Food.Edible.Combo.Non-Conjured"] = FOM_OPTIONS_FOODS_COMBO,
	["Consumable.Food.Edible.Bonus"] = FOM_OPTIONS_FOODS_BONUS,
	["Consumable.Food.Inedible"] = FOM_OPTIONS_FOODS_INEDIBLE,
};

-- libraries
local PT = LibStub("LibPeriodicTable-3.1");

function FOM_FeedButton_PostClick(self, button, down)
	if (not down) then
		if (button == "RightButton") then
			FOM_ShowOptions();
		elseif (FOM_NextFoodLink and not FOM_NoFoodError and not InCombatLockdown()) then
		elseif (FOM_NoFoodError and not IsAltKeyDown()) then
			if (FOM_NextFoodLink) then
				GFWUtils.Note(FOM_NoFoodError.."\n"..string.format(FOM_FALLBACK_MESSAGE, FOM_NextFoodLink));
			else
				GFWUtils.Note(FOM_NoFoodError);
			end
		end
	end
end

function FOM_FeedButton_OnEnter()
	if ( PetFrameHappiness.tooltip ) then
		GameTooltip:SetOwner(PetFrameHappiness, "ANCHOR_RIGHT");
		GameTooltip:SetText(PetFrameHappiness.tooltip);
		if ( PetFrameHappiness.tooltipDamage ) then
			GameTooltip:AddLine(PetFrameHappiness.tooltipDamage, "", 1, 1, 1);
		end
		if ( PetFrameHappiness.tooltipLoyalty ) then
			GameTooltip:AddLine(PetFrameHappiness.tooltipLoyalty, "", 1, 1, 1);
		end
		if (FOM_NoFoodError) then
			GameTooltip:AddLine(FOM_NoFoodError, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1);
			if (FOM_NextFoodLink) then
				GameTooltip:AddLine(string.format(FOM_BUTTON_TOOLTIP1_FALLBACK, FOM_NextFoodLink), GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			end
		else
			GameTooltip:AddLine(string.format(FOM_BUTTON_TOOLTIP1, FOM_NextFoodLink or "none"), GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end
		GameTooltip:AddLine(FOM_BUTTON_TOOLTIP2, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		
		if (FOM_Debug) then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine("Next Foods:");
			for _, foodInfo in pairs(SortedFoodList) do
				local line = string.format("%dx%s (bag %d, slot %d)", foodInfo.count, foodInfo.link, foodInfo.bag, foodInfo.slot);
				if (foodInfo.useful) then
					line = line .. " (useful)";
				end
				if (foodInfo.temp) then
					line = line .. " (temp)";
				end
				local color;
				if (foodInfo.delta > 30) then
					color = QuestDifficultyColor["trivial"];
				elseif (foodInfo.delta > 20 and levelDelta <= 30) then
					color = QuestDifficultyColor["standard"];
				elseif (foodInfo.delta > 10 and levelDelta <= 20) then
					color = QuestDifficultyColor["difficult"];
				elseif (foodInfo.delta <= 10) then
					color = QuestDifficultyColor["verydifficult"];
				end
				GameTooltip:AddLine(line, color.r, color.g, color.b);
			end
		end
		
		GameTooltip:Show();
	end
end

function FOM_FeedButton_OnLeave()
	GameTooltip:Hide();
end

function FOM_OnLoad(self)

	-- Register for Events
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("SPELLS_CHANGED");

	-- Register Slash Commands
	SLASH_FEEDOMATIC1 = "/feedomatic";
	SLASH_FEEDOMATIC2 = "/fom";
	SLASH_FEEDOMATIC3 = "/feed";
	SLASH_FEEDOMATIC4 = "/petfeed"; -- Rauen's PetFeed compatibility
	SLASH_FEEDOMATIC5 = "/pf";
	SlashCmdList["FEEDOMATIC"] = function(msg)
		FOM_ChatCommandHandler(msg);
	end
		
	BINDING_HEADER_GFW_FEEDOMATIC = GetAddOnMetadata("GFW_FeedOMatic", "Title"); -- gets us the localized title if needed
	BINDING_NAME_FOM_FEED = FOM_GetFeedPetSpellName();
	
	--GFWUtils.Debug = true;

end

function FOM_HookTooltip(frame)
	if (frame:GetScript("OnTooltipSetItem")) then
		frame:HookScript("OnTooltipSetItem", FOM_OnTooltipSetItem);
	else
		frame:SetScript("OnTooltipSetItem", FOM_OnTooltipSetItem);
	end
end

function FOM_OnTooltipSetItem(self)
	local name, link = self:GetItem();

	if (FOM_Config.Tooltip and link and UnitExists("pet")) then
				
		local itemID = FOM_IDFromLink(link);
		if (not FOM_IsInDiet(itemID)) then
			return false;
		end
		
		local color;
		local _, _, _, itemLevel = GetItemInfo(itemID);
		if (itemLevel) then
			local levelDelta = UnitLevel("pet") - itemLevel;
			local petName = UnitName("pet");
			if (levelDelta >= 30) then
				color = QuestDifficultyColor["trivial"];
				self:AddLine(string.format(FOM_QUALITY_UNDER, petName), color.r, color.g, color.b);
				return true;
			elseif (levelDelta >= 20 and levelDelta < 30) then
				color = QuestDifficultyColor["standard"];
				self:AddLine(string.format(FOM_QUALITY_WILL, petName), color.r, color.g, color.b);
				return true;
			elseif (levelDelta >= 10 and levelDelta < 20) then
				color = QuestDifficultyColor["difficult"];
				self:AddLine(string.format(FOM_QUALITY_LIKE, petName), color.r, color.g, color.b);
				return true;
			elseif (levelDelta < 10) then
				color = QuestDifficultyColor["verydifficult"];
				self:AddLine(string.format(FOM_QUALITY_LOVE, petName), color.r, color.g, color.b);
				return true;
			end
		end
	end
end

function FOM_GetFeedPetSpellName()
	-- we can get the spell name from the ID
	FOM_FeedPetSpellName = GetSpellInfo(FOM_FEED_PET_SPELL_ID);
	
	-- but we also want to know whether we can cast it
	for tabIndex = 1, GetNumSpellTabs() do
		local tabName, tabIcon, offset, numSpells = GetSpellTabInfo(tabIndex);
		for spellID = offset + 1, offset + numSpells do
			if (FOM_FeedPetSpellName == GetSpellName(spellID, BOOKTYPE_SPELL)) then
				return FOM_FeedPetSpellName;
			end
		end
	end
	
	return nil;
end

function FOM_Initialize(self)
	
	local _, realClass = UnitClass("player");
	if (realClass ~= "HUNTER") then
	 	self:UnregisterAllEvents();
		return;
	end
	
	if (UnitLevel("player") < 10) then return; end
		
	-- track whether foods are useful for Cooking 
	self:RegisterEvent("TRADE_SKILL_SHOW");
	self:RegisterEvent("TRADE_SKILL_UPDATE");

	-- Catch when feeding happened so we can notify/emote
	self:RegisterEvent("CHAT_MSG_PET_INFO");
	self:RegisterEvent("CHAT_MSG_SPELL_TRADESKILLS");
	
	-- Only subscribe to inventory updates once we're in the world
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LEAVING_WORLD");

	-- Events for trying to catch when the pet needs feeding
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("PET_BAR_SHOWGRID");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("PET_BAR_UPDATE");
	self:RegisterEvent("PET_UI_UPDATE");
	self:RegisterEvent("UNIT_HAPPINESS");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	
	FOM_FeedButton = CreateFrame("Button", "FOM_FeedButton", PetFrameHappiness, "SecureActionButtonTemplate");
	FOM_FeedButton:SetAllPoints(PetFrameHappiness);
	FOM_FeedButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	FOM_FeedButton:SetScript("PostClick", FOM_FeedButton_PostClick);
	FOM_FeedButton:SetScript("OnEnter", FOM_FeedButton_OnEnter);
	FOM_FeedButton:SetScript("OnLeave", FOM_FeedButton_OnLeave);

	-- set key binding to click FOM_FeedButton
	FOM_UpdateBindings();
	self:RegisterEvent("UPDATE_BINDINGS");
	
	FOM_HookTooltip(GameTooltip);
	FOM_HookTooltip(ItemRefTooltip);
	
	Frame_GFW_FeedOMatic:SetScript("OnUpdate", FOM_OnUpdate);

	self:UnregisterEvent("VARIABLES_LOADED");
	self:UnregisterEvent("SPELLS_CHANGED");

	FOM_Initialized = true;
		
end

function FOM_OnEvent(self, event, arg1)
	--DevTools_Dump(event)

	if ( event == "VARIABLES_LOADED" or event == "SPELLS_CHANGED") then
				
		if (not FOM_Initialized) then FOM_Initialize(self); end
		FOM_PickFoodQueued = true;
		
	elseif ( event == "UPDATE_BINDINGS" ) then

		FOM_UpdateBindings();
		
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then

		self:RegisterEvent("BAG_UPDATE");
		if (InCombatLockdown()) then
			FOM_PickFoodQueued = true;
		else
			FOM_PickFoodForButton();
		end
		return;

	elseif ( event == "PLAYER_LEAVING_WORLD" ) then

		self:UnregisterEvent("BAG_UPDATE");
		
	elseif (event == "BAG_UPDATE" ) then
		
		if (arg1 < 0 or arg1 > 4) then return; end	-- don't bother looking in keyring, bank, etc for food
		if (FOM_BagIsQuiver(arg1)) then return; end	-- don't look in quiver, either
		
		if (InCombatLockdown()) then
			FOM_PickFoodQueued = true;
		else
			FOM_PickFoodForButton();
		end
	
	elseif ((event == "UNIT_NAME_UPDATE" and arg1 == "pet") or event == "PET_BAR_UPDATE" or event == "PLAYER_REGEN_ENABLED") then
	
		if (InCombatLockdown()) then
			FOM_PickFoodQueued = true;
		else
			FOM_PickFoodForButton();
		end
	
	elseif (event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE") then
		FOM_ScanTradeSkill();
		return;

	elseif (event == "CHAT_MSG_PET_INFO" or event == "CHAT_MSG_SPELL_TRADESKILLS") then
		if (not FOM_FEEDPET_LOG_FIRSTPERSON) then
			FOM_FEEDPET_LOG_FIRSTPERSON = GFWUtils.FormatToPattern(FEEDPET_LOG_FIRSTPERSON);
		end
		local _, _, foodEaten = string.find(arg1, FOM_FEEDPET_LOG_FIRSTPERSON);
		if (foodEaten) then
			local foodName = foodEaten;
			if (FOM_NextFoodLink and FOM_NameFromLink(FOM_NextFoodLink) == foodEaten) then
				foodName = FOM_NextFoodLink;
			end
			local pet = UnitName("pet");
			if (pet) then
				if ( FOM_Config.AlertType == 2) then
					GFWUtils.Print(string.format(FOM_FEEDING_EAT, pet, foodName));
				elseif ( FOM_Config.AlertType == 1) then
					SendChatMessage(string.format(FOM_FEEDING_FEED, pet, foodName).. FOM_RandomEmote(foodName), "EMOTE");
				end
			end
		end
	end
 	
	if (FOM_Config.WarningLevel ~= 3) then
		FOM_CheckHappiness();
	end
	
	if (FOM_PickFoodQueued and not InCombatLockdown()) then
		FOM_PickFoodForButton();
	end

	if (FOM_FoodListBorder and FOM_FoodListBorder:IsVisible()) then
		FOM_FoodListUI_UpdateList();
	end
	
end

function FOM_ScanTradeSkill()
	if (GetTradeSkillLine() and GetTradeSkillLine() == FOM_CookingSpellName()) then
		-- Update Cooking reagents list so we can avoid consuming food we could skillup from.
		if (FOM_CookingDifficulty == nil) then
			FOM_CookingDifficulty = { };
		end
		if (FOM_CookingDifficulty and TradeSkillFrame and TradeSkillFrame:IsVisible() and not FOM_TradeSkillLock.Locked) then
			-- This prevents further update events from being handled if we're already processing one.
			-- This is done to prevent the game from freezing under certain conditions.
			FOM_TradeSkillLock.Locked = true;

			GFWUtils.DebugLog("scanning Cooking list");
			for i=1, GetNumTradeSkills() do
				local itemName, type, _, _ = GetTradeSkillInfo(i);
				if (type ~= "header") then
					local itemLink = GetTradeSkillItemLink(i);
					local itemID;
					if (itemLink) then
						_, _, itemID = string.find(itemLink, "item:(%d+)");
						if (itemID) then
							itemID = tonumber(itemID);
							FOM_CookingDifficulty[itemID] = FOM_DifficultyToNum(type);
							local recipeLink = GetTradeSkillRecipeLink(i);
							if (recipeLink) then
								local _, _, spellID = string.find(recipeLink, "enchant:(%d+)");
								if (spellID) then
									FOM_CookingRecipes[itemID] = tonumber(spellID);
								end
							end
						end
					end
				end
			end
		end
	end
end

function FOM_UpdateBindings()
	ClearOverrideBindings(FOM_FeedButton);
	local key = GetBindingKey("FOM_FEED");
	if (key) then
		SetOverrideBindingClick(FOM_FeedButton, nil, key, "FOM_FeedButton");
	end
end

-- Update our list of quest objectives so we can avoid consuming food we want to accumulate for a quest.
function FOM_ScanQuests()
	for questNum = 1, GetNumQuestLogEntries() do
		local _, _, _, _, isHeader, isCollapsed, isComplete  = GetQuestLogTitle(questNum);
		if (not isHeader) then
			for objectiveNum = 1, GetNumQuestLeaderBoards(questNum) do
				local text, type, finished = GetQuestLogLeaderBoard(objectiveNum, questNum);
				if (text and strlen(text) > 0) then
					local _, _, objectiveName, numCurrent, numRequired = string.find(text, "(.*): (%d+)/(%d+)");
					if (objectiveName) then
						local _, link = GetItemInfo(objectiveName);
						-- not guaranteed to get us a link if we don't have the item,
						-- but we shouldn't be here unless we have the item anyway.
						local itemID = FOM_IDFromLink(link);
						if (itemID and FOM_IsKnownFood(itemID)) then
							if (FOM_QuestFood == nil) then
								FOM_QuestFood = { };
							end
							if (FOM_QuestFood[itemID] == nil) then
								FOM_QuestFood[itemID] = tonumber(numRequired);
							else             
								FOM_QuestFood[itemID] = max(FOM_QuestFood[itemID], tonumber(numRequired));
							end
						end
					end
				end
			end
		end
	end
end

function FOM_DifficultyToNum(level)
	if (level == "optimal" or level == "orange") then
		return 4;
	elseif (level == "medium" or level == "yellow") then
		return 3;
	elseif (level == "easy" or level == "green") then
		return 2;
	elseif (level == "trivial" or level == "gray" or level == "grey") then
		return 1;
	else -- bad input
		return nil;
	end
end

function FOM_OnUpdate(self, elapsed)

	-- If it's been more than a second since our last tradeskill update,
	-- we can allow the event to process again.
	FOM_TradeSkillLock.EventTimer = FOM_TradeSkillLock.EventTimer + elapsed;
	if (FOM_TradeSkillLock.Locked) then
		FOM_TradeSkillLock.EventCooldown = FOM_TradeSkillLock.EventCooldown + elapsed;
		if (FOM_TradeSkillLock.EventCooldown > FOM_TradeSkillLock.EventCooldownTime) then

			FOM_TradeSkillLock.EventCooldown = 0;
			FOM_TradeSkillLock.Locked = false;
		end
	end
		
	--GFWUtils.Debug = true;

	if (FOM_ShouldFeed and FOM_Config.IconWarning and PetFrameHappiness and not InCombatLockdown()) then
		if (PetFrameHappiness:IsVisible() and PetFrameHappiness:GetAlpha() == 1 and not FOM_HasFeedEffect()) then
			FOM_FadeOut();
		end
	end
end

function FOM_FadeOut()
    local fadeInfo = {};
    fadeInfo.mode = "OUT";
    fadeInfo.timeToFade = 0.5;
    fadeInfo.finishedFunc = FOM_FadeIn;
    UIFrameFade(PetFrameHappiness, fadeInfo);
end

-- hack since a frame can't have a reference to itself in it
function FOM_FadeIn()
    UIFrameFadeIn(PetFrameHappiness, 0.5);
end

function FOM_ChatCommandHandler(msg)

	if ( msg == "" ) then
		FOM_ShowOptions();
		return;
	end
		
	-- Print Help
	if ( msg == "help" ) then
		local version = GetAddOnMetadata("GFW_FeedOMatic", "Version");
		GFWUtils.Print("Fizzwidget Feed-O-Matic "..version..":");
		GFWUtils.Print("/feedomatic /fom <command>");
		GFWUtils.Print("- "..GFWUtils.Hilite("help").." - Print this helplist.");
		GFWUtils.Print("- "..GFWUtils.Hilite("reset").." - Reset to default settings.");
		return;
	end

	if ( msg == "version" ) then
		local version = GetAddOnMetadata("GFW_FeedOMatic", "Version");
		GFWUtils.Print("Fizzwidget Feed-O-Matic "..version..":");
		return;
	end

	if ( msg == "debug" ) then
		FOM_Debug = not FOM_Debug;
		GFWUtils.Print((not FOM_Debug and "Not " or "").."Showing food list in happiness icon tooltip.");
	end
	
	-- Reset Variables
	if ( msg == "reset" ) then
		GFW_FeedOMatic.db:ResetProfile();
		FOM_CookingDifficulty = nil;
		FOM_QuestFood = nil;
		GFWUtils.Print("Feed-O-Matic configuration reset.");
		return;
	end
	
	-- if we got down to here, we got bad input
	FOM_ChatCommandHandler("help");
end

-- Check Happiness
function FOM_CheckHappiness()

	-- Check for pet
	if not ( UnitExists("pet") ) then 
		FOM_ShouldFeed = nil;		
		return;
	end
		
	-- Get Pet Info
	local pet = UnitName("pet");
	local happiness, damage, loyalty = GetPetHappiness();
	
	-- Check No Happiness
	if ( happiness == 0 ) or ( happiness == nil ) then return; end
	
	local level = 0;
	if (FOM_Config.WarningLevel == 1 or FOM_Config.WarningLevel == 2) then
		level = FOM_Config.WarningLevel;
	end
	
	-- Check if Need Feeding
	if ( happiness < level + 1 ) then
	
		if (UnitIsDead("pet")) then return; end
		if (UnitAffectingCombat("pet")) then return; end
		if (UnitAffectingCombat("player")) then return; end
		
		FOM_ShouldFeed = true;
		if (not FOM_HasFeedEffect() and GetTime() - FOM_LastWarning > FOM_WARNING_INTERVAL) then
			if (FOM_Config.TextWarning) then
				local msg;
				if (level - happiness == 0) then
					msg = FOM_PET_HUNGRY;
				else
					msg = FOM_PET_VERY_HUNGRY;
				end
				if (FOM_NoFoodError) then
					msg = msg .. "\n" .. FOM_NoFoodError;
				end
				GFWUtils.Print(string.format(msg, pet));
				GFWUtils.Note(string.format(msg, pet));
			end
			FOM_PlayHungrySound();
			FOM_LastWarning = GetTime();
		end
	else
		FOM_ShouldFeed = nil;
	end
	
end

FOM_HungrySounds = {
  	[FOM_BAT]		    = "Sound\\Creature\\FelBat\\FelBatDeath.wav",
  	[FOM_BEAR]		    = "Sound\\Creature\\Bear\\mBearDeathA.wav",
  	[FOM_BOAR]		    = "Sound\\Creature\\Boar\\mWildBoarAggro2.wav",
  	[FOM_CAT]		    = "Sound\\Creature\\Tiger\\mTigerStand2A.wav",
  	[FOM_CARRION_BIRD]	= "Sound\\Creature\\Carrion\\mCarrionWoundCriticalA.wav",
  	[FOM_CRAB]		    = "Sound\\Creature\\Crab\\CrabDeathA.wav",
  	[FOM_CROCOLISK]	    = "Sound\\Creature\\Basilisk\\mBasiliskSpellCastA.wav",
  	[FOM_GORILLA]	    = "Sound\\Creature\\Gorilla\\GorillaDeathA.wav",
  	[FOM_HYENA]		    = "Sound\\Creature\\Hyena\\HyenaPreAggroA.wav",
  	[FOM_RAPTOR]	    = "Sound\\Creature\\Raptor\\mRaptorWoundCriticalA.wav",
  	[FOM_SCORPID]	    = "Sound\\Creature\\SilithidWasp\\mSilithidWaspStand2A.wav",
  	[FOM_SPIDER]	    = "Sound\\Creature\\Tarantula\\mTarantulaFidget2a.wav",
  	[FOM_TALLSTRIDER]   = "Sound\\Creature\\TallStrider\\tallStriderPreAggroA.wav",
  	[FOM_TURTLE]	    = "Sound\\Creature\\SeaTurtle\\SeaTurtleWoundCritA.wav",
  	[FOM_WIND_SERPENT]	= "Sound\\Creature\\WindSerpant\\mWindSerpantDeathA.wav",
  	[FOM_WOLF]		    = "Sound\\Creature\\Wolf\\mWolfFidget2c.wav",
	[FOM_DRAGONHAWK]	= "Sound\\Creature\\DragonHawk\\DragonHawkWoundCrit.wav",
	[FOM_NETHER_RAY]	= "Sound\\Creature\\SporeBat\\SporebatWoundCrit.wav",
	[FOM_RAVAGER]		= "Sound\\Creature\\Crawler\\CrawlerWoundCrit.wav",
	[FOM_SERPENT]		= "Sound\\Creature\\Serpent\\SerpentPreAggro.wav",
	[FOM_SPOREBAT]		= "Sound\\Creature\\SporeBat\\SporebatWoundCrit.wav",
	[FOM_WARP_STALKER]	= "Sound\\Creature\\WarpStalker\\WarpStalkerWoundCrit.wav",
	[FOM_CHIMAERA]		= "Sound\\Creature\\Hydra\\mHydraWoundCriticalA.wav",
	[FOM_DEVILSAUR]		= "Sound\\Creature\\Trex\\TrexPreAggro.wav",
	[FOM_MOTH]			= "Sound\\Creature\\FireFly\\FireFlyWoundCrit.wav",
	[FOM_SPIRIT_BEAST]	= "Sound\\Creature\\Harkoa\\HarkoaWound4.wav",
	[FOM_WORM]			= "Sound\\Creature\\Larva\\LArvaPreAggro.wav",		
  	[FOM_BIRD_OF_PREY]	= "Sound\\Creature\\OWl\\OwlPreAggro.wav",
  	[FOM_CORE_HOUND]	= "Sound\\Creature\\FelBeast\\FelBeastPreAggro.wav",
  	[FOM_RHINO]			= "Sound\\Creature\\KodoBeast\\KodoBeastWoundCriticalA.wav",
  	[FOM_SILITHID]	    = "Sound\\Creature\\SilithidWasp\\mSilithidWaspStand2A.wav",
  	[FOM_WASP]		    = "Sound\\Creature\\SilithidWasp\\mSilithidWaspStand2A.wav",
};
function FOM_PlayHungrySound()
	if (FOM_Config.AudioWarning) then
		local type = UnitCreatureFamily("pet");
		local sound = FOM_HungrySounds[type];
		if (sound == nil or FOM_Config.AudioWarningBell) then
			PlaySoundFile("Sound\\Doodad\\BellTollNightElf.wav");
		else
			PlaySoundFile(sound);
		end
	end
end

-- Check Feed Effect
function FOM_HasFeedEffect()

	local i = 1;
	local _, _, buff = UnitBuff("pet", i);
	while buff do
		if ( string.find(buff, "Ability_Hunter_BeastTraining") ) then
			return true;
		end
		i = i + 1;
		_, _, buff = UnitBuff("pet", i);
	end
	return false;

end

function FOM_PickFoodForButton()

	local pet = UnitName("pet");
	if (not pet) then 
		FOM_PickFoodQueued = true;
		return;
	end
	local dietList = {GetPetFoodTypes()};
	if ( dietList == nil or #dietList == 0) then
		FOM_PickFoodQueued = true;
		return ;
	end
	
	local foodBag, foodSlot;
	foodBag, foodSlot, FOM_NextFoodLink = FOM_NewFindFood();
	FOM_SetupButton(foodBag, foodSlot);
	
	if ( foodBag == nil) then
		local fallbackBag, fallbackSlot;
		fallbackBag, fallbackSlot, FOM_NextFoodLink = FOM_NewFindFood(1);
		if (fallbackBag) then
			FOM_NoFoodError = string.format(FOM_ERROR_NO_FOOD_NO_FALLBACK, pet);
			FOM_SetupButton(fallbackBag, fallbackSlot, "alt");
		else
			-- No Food Could be Found
			FOM_NoFoodError = string.format(FOM_ERROR_NO_FOOD, pet);
			FOM_NextFoodLink = nil;
			--GFWUtils.Print("Can't feed? #SortedFoodList:"..#SortedFoodList);
			--DevTools_Dump(GetPetFoodTypes());
		end
		PetFrameHappinessTexture:SetVertexColor(0.5, 0.5, 1);
	else
		FOM_NoFoodError = nil;
		PetFrameHappinessTexture:SetVertexColor(1, 1, 1);
	end
	
	-- debug
	if (false and FOM_NextFoodLink) then
		if (FOM_NoFoodError) then
			GFWUtils.PrintOnce("Next food (fallback):"..FOM_NextFoodLink, 1);
		else
			GFWUtils.PrintOnce("Next food:"..FOM_NextFoodLink, 1);
		end
	end
end

function FOM_SetupButton(bag, slot, modifier)
	if (not FOM_GetFeedPetSpellName()) then
		local version = GetAddOnMetadata("GFW_FeedOMatic", "Version");
		GFWUtils.PrintOnce(GFWUtils.Red("Feed-O-Matic v."..version.." error:").."Can't find Feed Pet spell. (Have you finished your level 10 Hunter quests?)");
		return;
	end
	if (modifier) then
		modifier = modifier.."-";
	else
		modifier = "";
	end
	if (bag and slot) then
		FOM_FeedButton:SetAttribute(modifier.."type1", "spell");
		FOM_FeedButton:SetAttribute(modifier.."spell1", FOM_FeedPetSpellName);
		FOM_FeedButton:SetAttribute("target-bag", bag);
		FOM_FeedButton:SetAttribute("target-slot", slot);
	else
		FOM_FeedButton:SetAttribute(modifier.."type", ATTRIBUTE_NOOP);
		FOM_FeedButton:SetAttribute(modifier.."spell", ATTRIBUTE_NOOP);
		FOM_FeedButton:SetAttribute(modifier.."type1", ATTRIBUTE_NOOP);
		FOM_FeedButton:SetAttribute(modifier.."spell1", ATTRIBUTE_NOOP);
		FOM_FeedButton:SetAttribute("target-bag", nil);
		FOM_FeedButton:SetAttribute("target-slot", nil);
	end
	FOM_PickFoodQueued = nil;
end

function FOM_RandomEmote(foodLink)
	
	local localeEmotes = FOM_Emotes[GetLocale()];
	if (localeEmotes) then
		local randomEmotes = {};
		if (UnitSex("pet") == 2) then
			randomEmotes = GFWTable.Merge(randomEmotes, localeEmotes["male"]);
		elseif (UnitSex("pet") == 3) then
			randomEmotes = GFWTable.Merge(randomEmotes, localeEmotes["female"]);
		end
		
		local itemID = FOM_IDFromLink(foodLink);
		randomEmotes = GFWTable.Merge(randomEmotes, localeEmotes[itemID]);
		
		local sets = PT:ItemSearch(itemID);
		for _, setName in pairs(sets) do
			randomEmotes = GFWTable.Merge(randomEmotes, localeEmotes[setName]);
		end
			
		randomEmotes = GFWTable.Merge(randomEmotes, localeEmotes[UnitCreatureFamily("pet")]);
		randomEmotes = GFWTable.Merge(randomEmotes, localeEmotes["any"]);
	
		return randomEmotes[math.random(table.getn(randomEmotes))];
	else
		return "";
	end
end

function FOM_FlatFoodList(fallback)
	local foodList = {};
	local petLevel = UnitLevel("pet");
	for bagNum = 0, 4 do
		if (not FOM_BagIsQuiver(bagNum)) then
		-- skip bags that can't contain food
			for itemNum = 1, GetContainerNumSlots(bagNum) do
				local itemLink = GetContainerItemLink(bagNum, itemNum);
				-- debug
				--if (bagNum == 0 and itemNum == 1) then _, itemLink = GetItemInfo(21023); end
				if (itemLink) then
					local itemID = FOM_IDFromLink(itemLink);
					local _, itemCount = GetContainerItemInfo(bagNum, itemNum);
					-- debug
					--if (bagNum == 0 and itemNum == 1) then itemCount = 10; end
					local _, _, _, level = GetItemInfo(itemID);
					if (not level) then
						-- how can we not have cached info for an item in your bags?
						-- make sure it's cached for future runs
						FOMTooltip:SetHyperlink("item:"..itemID);
					elseif (petLevel - level < 30) then
						if ( FOM_IsInDiet(itemID) ) then
							local avoid = FOM_ShouldAvoidFood(itemID, itemCount);
							if (fallback or not avoid) then
								table.insert(foodList, {bag=bagNum, slot=itemNum, link=itemLink, count=itemCount, delta=(petLevel - level), priority=FOM_CategoryIndexForFood(itemID)});
							end
						end
					end
				end
			end
		end
	end
	return foodList;
end

function FOM_NewFindFood(fallback)
	SortedFoodList = FOM_FlatFoodList(fallback);

	-- if there are any conjured foods, drop everything else from the list
	local tempFoodsOnly = {};
	for _, foodInfo in pairs(SortedFoodList) do
		if (foodInfo.temp) then
			table.insert(tempFoodsOnly, foodInfo);
		end
	end
	if (table.getn(tempFoodsOnly) > 0) then
		SortedFoodList = tempFoodsOnly;
	end
	
	local function sortCount(a, b)
		return a.count < b.count;
	end
	local function sortQualityDescending(a, b)
		return a.delta < b.delta;
	end
	local function sortQualityAscending(a, b)
		return a.delta > b.delta;
	end
	local function sortPriority(a, b)
		return a.priority > b.priority;
	end
	table.sort(SortedFoodList, sortCount); -- small stacks first
	if (not FOM_Config.UseLowLevelFirst) then
		table.sort(SortedFoodList, sortQualityDescending); -- higher quality first
	else
		table.sort(SortedFoodList, sortQualityAscending); -- lower quality first
	end
	table.sort(SortedFoodList, sortPriority); -- category priorities (conjured ahead of normal ahead of bonus etc)
	
	if (GFWUtils.Debug) then
		if (fallback) then
			GFWUtils.DebugLog("Food list (with fallback):")
		else
			GFWUtils.DebugLog("Food list:")
		end
		for num, foodInfo in pairs(SortedFoodList) do
			GFWUtils.DebugLog(string.format("%d: %dx%s, delta %d", num, foodInfo.count, foodInfo.link, foodInfo.delta));
		end
	end
	for _, foodInfo in pairs(SortedFoodList) do
		return foodInfo.bag, foodInfo.slot, foodInfo.link;
	end
	
	return nil;
end

function FOM_CategoryIndexForFood(itemID)
	for index, category in pairs(FOM_PTCategories) do
		if (PT:ItemInSet(itemID, category)) then
			return index;
		end
	end
end

function FOM_ShouldAvoidFood(itemID, quantity)
	if (FOM_ExcludedFoods[itemID]) then
		return true;
	end
	local foodName = GetItemInfo(itemID);
	if (foodName == nil) then
		GFWUtils.DebugLog("Can't get info for item ID "..itemID..", assuming it's OK to eat.");
		return false;
	end
	if (FOM_Config.AvoidQuestFood) then
		if (FOM_IsQuestFood(itemID, quantity)) then
			GFWUtils.DebugLog("Skipping "..quantity.."x "..foodName.."; is needed for quest.");
			return true;
		end
	end
	for category in pairs(FOM_ExcludedFoodCategories) do
		if (PT:ItemInSet(itemID, category)) then
			GFWUtils.DebugLog("Skipping "..quantity.."x "..foodName.."; is in category "..category..".");
			return true;
		end
	end
	--GFWUtils.DebugLog("Not skipping "..quantity.."x "..foodName.."; doesn't have other uses.");
	return false;
end

function FOM_IsQuestFood(itemID, quantity)
	FOM_ScanQuests();
	if (FOM_QuestFood and FOM_QuestFood[itemID]) then
		return GetItemCount(itemID) <= FOM_QuestFood[itemID];
	end
end

function FOM_IsInDiet(food, dietList)

	if ( dietList == nil ) then
		dietList = {GetPetFoodTypes()};
	end
	if ( dietList == nil or #dietList == 0) then
		FOM_PickFoodQueued = true;
		return false;
	end
	if (type(dietList) ~= "table") then
		dietList = {dietList};
	end
	for _, diet in pairs(dietList) do
		local PTdiet = FOM_PTDiets[diet];
		if (PT:ItemInSet(food, PTdiet)) then
			return true;
		end
	end
	
	return false;

end

function FOM_IsKnownFood(itemID)
	return FOM_IsInDiet(itemID, {FOM_DIET_MEAT, FOM_DIET_FISH, FOM_DIET_BREAD, FOM_DIET_CHEESE, FOM_DIET_FRUIT, FOM_DIET_FUNGUS});
end

function FOM_CookingSpellName()
	return (GetSpellInfo(FOM_COOKING_SPELL_ID));
end

function FOM_BagIsQuiver(bagNum)
	if (bagNum == 0) then return false; end
	local _, bagType = GetContainerNumFreeSlots(bagNum);
	return bagType ~= 0; 	
	-- okay, that's more than just quivers, but currently there's no specialy bag that can contain food
end

function FOM_IDFromLink(itemLink)
	if (itemLink == nil) then return nil; end
	local _, _, itemID  = string.find(itemLink, "item:(%d+)");
	if (tonumber(itemID)) then
		return tonumber(itemID);
	else
		return nil;
	end
end

function FOM_NameFromLink(itemLink)
	if (itemLink == nil) then return nil; end
	local _, _, name = string.find(itemLink, "%[(.-)%]"); 
	if (name) then
		return name;
	end
	return itemLink;
end

------------------------------------------------------
-- foods list options pansl
------------------------------------------------------

local FOM_LIST_HEIGHT = 24;
local FOM_MAX_LIST_DISPLAYED = 10;
local MAX_COOKING_RESULTS = 6;

function FOM_FoodListShowTooltip(button)
	if (button.recipe) then
		local recipe = FOM_CookingRecipes[button.item];
		if (recipe) then
			GameTooltip:SetHyperlink("enchant:"..recipe);
		else
			GameTooltip:SetHyperlink("item:"..button.item);
		end
		local difficulty = FOM_CookingDifficulty[button.item] or 5;
		local c = FOM_DifficultyColors[difficulty];
		GameTooltip:AddDoubleLine(FOM_DIFFICULTY_HEADER, getglobal("FOM_DIFFICULTY_"..difficulty), c.r,c.g,c.b, c.r,c.g,c.b);
		GameTooltip:Show();
	elseif (button.item) then
		GameTooltip:SetHyperlink("item:"..button.item);
		GameTooltip:Show();
	end	
end

function FOM_FoodListButton_OnLoad(self)
	local name = self:GetName();
	self.check = getglobal(name.."Check");
	self.icon = getglobal(name.."Icon");
	self.name = getglobal(name.."Name");
	self.categoryLeft = getglobal(name.."CategoryLeft");
	self.categoryRight = getglobal(name.."CategoryRight");
	self.cookingIcons = {};
	self.cookingItems = {};
	for i = 1, MAX_COOKING_RESULTS do
		self.cookingIcons[i] = getglobal(name.."CreatedIcon"..i);
		self.cookingItems[i] = getglobal(name.."CreatedItem"..i);
	end
end

function FOM_FoodListButton_OnClick(self)
	if (self.header and not self.item) then
		if (FOM_ExcludedFoodCategories[self.header]) then
			FOM_ExcludedFoodCategories[self.header] = nil;
		else
			FOM_ExcludedFoodCategories[self.header] = 1;
		end
	elseif (self.item and not FOM_ExcludedFoodCategories[self.header]) then
		if (FOM_ExcludedFoods[self.item]) then
			FOM_ExcludedFoods[self.item] = nil;
		else
			FOM_ExcludedFoods[self.item] = 1;
		end
	end
	FOM_FoodListUIUpdate();
	if (InCombatLockdown()) then
		FOM_PickFoodQueued = true;
	else
		FOM_PickFoodForButton();
	end
end

function FOM_FoodListUI_UpdateList()
	FOM_FoodsUIList = {};
	for _, header in pairs(FOM_PTCategories) do
		if (PT:GetSetTable(header)) then
			local list = {};
			local uniqueList = {};
			for itemID in PT:IterateSet(header) do
				local name, _, _, iLvl = GetItemInfo(itemID);
				local skip = false;
				if (name) then
					if (FOM_Config.ShowOnlyInventory) then
						if (GetItemCount(itemID) == 0) then
							skip = true;
						end
					end
					local dietChecked = false;
					if (not skip and FOM_Config.ShowOnlyPetFoods) then
						local level = UnitLevel("player") - 5;
						if (UnitExists("pet")) then
							level = UnitLevel("pet");
							if (not FOM_IsInDiet(itemID)) then
								skip = true;
							end
							dietChecked = true;
						end
						if (not skip and level - iLvl >= 30) then
							skip = true;
						end
					end
					if (not skip and not dietChecked and not FOM_IsKnownFood(itemID)) then
						-- make sure PT foods not in pet diets don't show up
						skip = true;
					end
					
					if (not skip) then
						if (not uniqueList[itemID]) then
							tinsert(list, itemID);
						end
						uniqueList[itemID] = iLvl;
					end
				end
			end
			local function sortHigherQualityFirst(a,b)
				return uniqueList[a] > uniqueList[b];
			end
			local function sortLowerQualityFirst(a,b)
				return uniqueList[a] < uniqueList[b];
			end
			if (not FOM_Config.UseLowLevelFirst) then
				table.sort(list, sortHigherQualityFirst);
			else
				table.sort(list, sortLowerQualityFirst);
			end
			tinsert(FOM_FoodsUIList, header);
			for _, itemID in pairs(list) do
				tinsert(FOM_FoodsUIList, {id=itemID,header=header});
			end
		end
	end
	FOM_FoodListUIUpdate();
end

function FOM_FoodListUIUpdate()

	local numListItems = #FOM_FoodsUIList;
	local listOffset = FauxScrollFrame_GetOffset(FOM_FoodListScrollFrame);
	if (listOffset > numListItems - FOM_MAX_LIST_DISPLAYED) then
		listOffset = math.max(0, numListItems - FOM_MAX_LIST_DISPLAYED);
		FauxScrollFrame_SetOffset(FOM_FoodListScrollFrame, listOffset);
	end
	
	FauxScrollFrame_Update(FOM_FoodListScrollFrame, numListItems, FOM_MAX_LIST_DISPLAYED, FOM_LIST_HEIGHT);
	
	for i=1, FOM_MAX_LIST_DISPLAYED, 1 do
		local listIndex = i + listOffset;
		local listItem = FOM_FoodsUIList[listIndex];
		local listButton = getglobal("FOM_FoodList"..i);
		
		if ( listIndex <= numListItems ) then	
			-- Set button widths if scrollbar is shown or hidden
			if ( FOM_FoodListScrollFrame:IsShown() ) then
				listButton:SetWidth(350);
			else
				listButton:SetWidth(368);
			end
							
			listButton:SetID(listIndex);
			listButton:Show();
			
			if ( type(listItem) == "string" ) then
				-- it's a header
				listButton.header = listItem;
				listButton.item = nil;

				listButton.categoryRight:Show();
				listButton.categoryLeft:Show();
				listButton.icon:SetTexture("");
				listButton.name:SetText("");
				listButton:SetText(FOM_CategoryNames[listItem]);
				
				for iconIndex = 1, MAX_COOKING_RESULTS do
					listButton.cookingIcons[iconIndex]:SetTexture("");
					listButton.cookingItems[iconIndex]:Hide();
				end
				
				if (FOM_ExcludedFoodCategories[listItem]) then
					listButton.check:Hide();
				else
					listButton.check:Show();
				end
				listButton:SetAlpha(1);
				
			else
				listButton.header = listItem.header;
				listButton.item = listItem.id;
		
				listButton.categoryLeft:Hide();
				listButton.categoryRight:Hide();

				local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(listItem.id);
				listButton:SetText("");
				listButton.name:SetText(name);
				listButton.icon:SetTexture(texture);

				-- show cooking results
				for iconIndex = 1, MAX_COOKING_RESULTS do
					listButton.cookingIcons[iconIndex]:SetTexture("");
					listButton.cookingItems[iconIndex]:Hide();
				end
				local cookingResultString = PT:ItemInSet(listItem.id, "TradeskillResultMats.Reverse.Cooking");
				if (cookingResultString) then
					local resultIndex = 1;
					local cookingResults = {strsplit(";", cookingResultString)};
					for _, resultString in pairs(cookingResults) do
						local _, _, itemID = string.find(resultString, "^(%d+)");
						if (itemID) then
							if (resultIndex > MAX_COOKING_RESULTS) then
								--print(GetItemInfo(listItem.id), resultIndex)
								break;
							end
							
							itemID = tonumber(itemID);
							icon = GetItemIcon(itemID);
							listButton.cookingIcons[resultIndex]:SetTexture(icon);
							listButton.cookingItems[resultIndex]:Show();
							listButton.cookingItems[resultIndex].item = itemID;
							listButton.cookingItems[resultIndex].recipe = true;
							
							local difficulty = FOM_CookingDifficulty[itemID];
							if (difficulty) then
								listButton.cookingIcons[resultIndex]:SetVertexColor(1, 1, 1);
							else
								listButton.cookingIcons[resultIndex]:SetVertexColor(0.25, 0.25, 0.25);
							end
							resultIndex = resultIndex + 1;
						end
					end
				end
							
							
				if (FOM_ExcludedFoods[listItem.id] or FOM_ExcludedFoodCategories[listItem.header]) then
					listButton.check:Hide();
				else
					listButton.check:Show();
				end
				
				if (FOM_ExcludedFoodCategories[listItem.header]) then
					listButton:SetAlpha(0.5);
				else
					listButton:SetAlpha(1);
				end
			end
			
		else
			listButton:Hide();
		end
	end
	
	if (UnitExists("pet")) then
		FOM_FoodsPanel_ShowOnlyPetFoodsText:SetText(format(FOM_OPTIONS_FOODS_ONLY_PET, UnitName("pet")));
	else
		FOM_FoodsPanel_ShowOnlyPetFoodsText:SetText(FOM_OPTIONS_FOODS_ONLY_LVL);
	end
end

------------------------------------------------------
-- Dongle & GFWOptions stuff
------------------------------------------------------

GFW_FeedOMatic = {};
local GFWOptions = DongleStub("GFWOptions-1.0");

local MAX_KEEP_OPEN_SLOTS = 100;

function FOM_BuildOptionsUI(panel)
	
	local s, widget, lastWidget, lastWidgetLeft, options;

	widget = panel:CreateCheckButton("Tooltip", false);
	widget:SetPoint("TOPLEFT", panel.contentAnchor, "BOTTOMLEFT", -2, -2);
	lastWidget = widget;
	
	widget = panel:CreateCheckButton("UseLowLevelFirst", false);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -2);
	lastWidget = widget;

	widget = panel:CreateCheckButton("AvoidQuestFood", false);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", -2, -2);
	lastWidget = widget;
	
	s = panel:CreateFontString("FOM_OptionsPanel_WarnHeader", "ARTWORK", "GameFontNormal");
	s:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 2, -20);
	s:SetText(FOM_OPTIONS_HEADER_WARNING);
	lastWidget = s;
	lastWidgetLeft = s;

	widget = panel:CreateCheckButton("IconWarning", false);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", -2, -2);
	lastWidget = widget;

	widget = panel:CreateCheckButton("TextWarning", false);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -2);
	lastWidget = widget;

	widget = panel:CreateCheckButton("AudioWarning", false);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -2);
	lastWidget = widget;

	widget = panel:CreateCheckButton("AudioWarningBell", false, true);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 16, 0);
	lastWidget.dependentControls = { widget };
	lastWidget = widget;

	options = {
		{ text=PET_HAPPINESS1, icon="Interface\\PetPaperDollFrame\\UI-PetHappiness", 
			tCoordLeft=0.375, tCoordRight=0.5625, tCoordTop=0, tCoordBottom=0.359375 },
		{ text=PET_HAPPINESS2, icon="Interface\\PetPaperDollFrame\\UI-PetHappiness", 
			tCoordLeft=0.1875, tCoordRight=0.375, tCoordTop=0, tCoordBottom=0.359375 },
		FOM_OPTIONS_LEVEL_NONE,
	};
	widget = panel:CreateDropDown("WarningLevel", options, 130);
	widget:SetPoint("TOPLEFT", lastWidgetLeft, "BOTTOMLEFT", 175, -20);
	lastWidget = widget;

	options = {
		FOM_OPTIONS_NOTIFY_EMOTE,
		FOM_OPTIONS_NOTIFY_TEXT,
		FOM_OPTIONS_NOTIFY_NONE,
	};
	widget = panel:CreateDropDown("AlertType", options, 130);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -20);
	
end

function FOM_BuildFoodsUI(panel)
	
	local borderFrame = CreateFrame("Frame", "FOM_FoodListBorder", panel, "OptionsBoxTemplate");
	borderFrame:SetWidth(378);
	borderFrame:SetHeight(273);
	borderFrame:SetPoint("TOPLEFT", panel.contentAnchor, "BOTTOMLEFT", -5, -5);
	borderFrame:Show();
	
	local headerBgLeft = panel:CreateTexture("FOM_FoodList_HeaderBGLeft", "ARTWORK");
	headerBgLeft:SetTexture("Interface\\TokenFrame\\UI-TokenFrame-CategoryButton");
	headerBgLeft:SetDesaturated(1);
	headerBgLeft:SetTexCoord(0, 1, 0, 0.28125);
	headerBgLeft:SetWidth(313);
	headerBgLeft:SetHeight(24);
	headerBgLeft:SetPoint("TOPLEFT",borderFrame,"TOPLEFT",5,-5);
	headerBgLeft:Show();

	local headerBgRight = panel:CreateTexture("FOM_FoodList_HeaderBGRight", "ARTWORK");
	headerBgRight:SetTexture("Interface\\TokenFrame\\UI-TokenFrame-CategoryButton");
	headerBgRight:SetDesaturated(1);
	headerBgRight:SetTexCoord(0, 0.14453125, 0.296875, 0.578125);
	headerBgRight:SetWidth(61);
	headerBgRight:SetHeight(24);
	headerBgRight:SetPoint("TOPRIGHT",borderFrame,"TOPRIGHT",-5,-5);
	
	local s = panel:CreateFontString("FOM_FoodList_NameHeader", "OVERLAY", "GameFontNormalSmall");
	s:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", 53, -12);
	s:SetText(FOM_OPTIONS_FOODS_NAME);
	
	s = panel:CreateFontString("FOM_FoodList_CookingHeader", "OVERLAY", "GameFontNormalSmall");
	s:SetPoint("TOPRIGHT", borderFrame, "TOPRIGHT", -26, -12);
	s:SetText(FOM_OPTIONS_FOODS_COOKING);
	
	local listItem = CreateFrame("Button", "FOM_FoodList1", panel, "FOM_FoodListItemTemplate");
	listItem:SetPoint("TOPLEFT", panel.contentAnchor, "BOTTOMLEFT", 0, -34);
	for i = 2, FOM_MAX_LIST_DISPLAYED do
		listItem = CreateFrame("Button", "FOM_FoodList" .. i, panel, "FOM_FoodListItemTemplate");
		listItem:SetPoint("TOPLEFT", "FOM_FoodList" .. (i - 1), "BOTTOMLEFT", 0, 0);
	end
	
	local scrollFrame = CreateFrame("ScrollFrame", "FOM_FoodListScrollFrame", panel, "FauxScrollFrameTemplate");
	scrollFrame:SetWidth(346);
	scrollFrame:SetHeight(240);
	scrollFrame:SetPoint("TOPLEFT", panel.contentAnchor, "BOTTOMLEFT", 0, -34);
	scrollFrame:SetScript("OnVerticalScroll", function(self, offset) 
		FauxScrollFrame_OnVerticalScroll(self, offset, FOM_LIST_HEIGHT, FOM_FoodListUIUpdate);
	end);
	
	local widget = panel:CreateCheckButton("ShowOnlyPetFoods", false);
	widget:SetPoint("TOPLEFT", borderFrame, "BOTTOMLEFT", 24, 0);
	lastWidget = widget;

	widget = panel:CreateCheckButton("ShowOnlyInventory", false);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, 0);
	
end

function FOM_ShowOptions()
	local openFunc = InterfaceOptionsFrame_OpenToCategory or InterfaceOptionsFrame_OpenToFrame;
	openFunc(FOM_FoodsPanel);
	openFunc(FOM_OptionsPanel);
end

function GFW_FeedOMatic:Initialize()
	self.defaults = { 
		profile = {
			Tooltip				= true,
			UseLowLevelFirst	= true,
			AvoidQuestFood		= true,
			IconWarning			= false,
			TextWarning			= false,
			AudioWarning		= false,
			AudioWarningBell	= false,
			WarningLevel		= 1,
			AlertType			= 1,
			
			ShowOnlyPetFoods	= false,
			ShowOnlyInventory	= false,
		}
	};

	self.optionsText = {
		Tooltip				= FOM_OPTIONS_TOOLTIP,
		UseLowLevelFirst	= FOM_OPTIONS_LOW_LVL_1ST,
		AvoidQuestFood		= FOM_OPTIONS_AVOID_QUEST,
		IconWarning			= FOM_OPTIONS_WARN_ICON,
		TextWarning			= FOM_OPTIONS_WARN_TEXT,
		AudioWarning		= FOM_OPTIONS_WARN_SOUND,
		AudioWarningBell	= FOM_OPTIONS_SOUND_BELL,
		WarningLevel		= FOM_OPTIONS_WARN_LEVEL,
		AlertType			= FOM_OPTIONS_FEED_NOTIFY,
		
		ShowOnlyPetFoods	= FOM_OPTIONS_FOODS_ONLY_PET,
		ShowOnlyInventory	= FOM_OPTIONS_FOODS_ONLY_INV,
	};

	self.db = self:InitializeDB("GFW_FeedOMaticDB", self.defaults);
	FOM_Config = self.db.profile;
end

function GFW_FeedOMatic:Enable()
	GFWOptions:CreateMainPanel("GFW_FeedOMatic", "FOM_OptionsPanel", FOM_OPTIONS_SUBTEXT);
	FOM_OptionsPanel.BuildUI = FOM_BuildOptionsUI;
	
	FOM_OptionsPanel:CreateChildPanel("FOM_FoodsPanel", FOM_OPTIONS_FOODS_TITLE, FOM_OPTIONS_FOODS_TEXT);
	FOM_FoodsPanel.BuildUI = FOM_BuildFoodsUI;
	FOM_FoodsPanel.Refresh = FOM_FoodListUI_UpdateList;
end

function GFW_FeedOMatic:OptionsChanged()
	if (FOM_FoodListBorder and FOM_FoodListBorder:IsVisible()) then
		FOM_FoodListUI_UpdateList();
	end
	if (InCombatLockdown()) then
		FOM_PickFoodQueued = true;
	else
		FOM_PickFoodForButton();
	end
end

GFW_FeedOMatic = DongleStub("Dongle-1.2"):New("GFW_FeedOMatic", GFW_FeedOMatic);

