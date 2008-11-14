----------------------------------------
-- Outfitter
----------------------------------------

Outfitter.cContributors = {"Bruce Quinton", "Dridzt", "Kal_Zakath13", "Smurfy", "XMinionX", "Zanoroy", "Dussander"}
Outfitter.cFriendsAndFamily = {"Brian", "Dave", "Glenn", "Leah", "Mark", "Gian", "Jerry", "The Mighty Pol", "Forge"}
Outfitter.cTranslators = {"Jullye (FR)", "Quetzaco (FR)", "Ekhurr (FR)", "Negwe (FR)", "Ani (DE)", "Zokrym (DE)", "Dessa (DE)", "Unknown (KR)", "Delika (RU)"}
Outfitter.cTesters = {"Whishann", "HunterZ", "docthis", "Irdx", "TigaFIN", "iceeagle", "Denrax", "rasmoe", "Katlefiya", "gtmsece", "Militis", "Casard", "saltorio", "elusif"}

Outfitter.Debug =
{
	InventoryCache = false,
	EquipmentChanges = false,
}

----------------------------------------
----------------------------------------

gOutfitter_Settings = nil
gOutfitter_GlobalSettings = nil

Outfitter.Initialized = false
Outfitter.Suspended = false
	
-- Outfit state
	
Outfitter.OutfitStack = {}
Outfitter.OutfitStack.Outfits = {}

Outfitter.CurrentOutfit = nil
Outfitter.ExpectedOutfit = nil
Outfitter.CurrentInventoryOutfit = nil

Outfitter.EquippedNeedsUpdate = false
Outfitter.WeaponsNeedUpdate = false
Outfitter.LastEquipmentUpdateTime = 0
	
Outfitter.SpecialState = {} -- The current state as determined by the engine, not necessarily the state of the outfit itself

-- Player state

Outfitter.CurrentZone = ""
Outfitter.CurrentZoneIDs = {}

Outfitter.InCombat = false
Outfitter.MaybeInCombat = false

Outfitter.IsDead = false
Outfitter.IsFeigning = false

Outfitter.BankFrameIsOpen = false

Outfitter.SettingTypeInfo =
{
	string      = {Default = "",    FrameType = "EditBox"          },
	number      = {Default = 0,     FrameType = "EditBox"          },
	stringtable = {Default = {},    FrameType = "ScrollableEditBox"},
	zonelist    = {Default = {},    FrameType = "ZoneListEditBox"  },
	boolean     = {Default = false, FrameType = "Checkbox"         },
}

Outfitter.Style = {}

Outfitter.Style.ButtonBar =
{
	ButtonHeight = 37,
	ButtonWidth = 37,
	
	BackgroundTextureHeight = 128,
	BackgroundTextureWidth = 128,
	
	BackgroundWidth = 42,
	BackgroundWidth0 = 26,
	BackgroundWidthN = 27,
	
	BackgroundHeight = 41,
	BackgroundHeight0 = 28,
	BackgroundHeightN = 25,
}

-- UI

Outfitter.CurrentPanel = 0
Outfitter.Collapsed = {}
Outfitter.SelectedOutfit = nil
Outfitter.DisplayIsDirty = true
Outfitter.OutfitInfoCache = {}

function Outfitter:FormatItemList(pList)
	local vNumItems = #pList
	
	if vNumItems == 0 then
		return ""
	elseif vNumItems == 1 then
		return string.format(self.cSingleItemFormat, pList[1])
	elseif vNumItems == 2 then
		return string.format(self.cTwoItemFormat, pList[1], pList[2])
	else
		local vStartIndex, vEndIndex, vPrefix, vRepeat, vSuffix = string.find(self.cMultiItemFormat, "(.*){{(.*)}}(.*)")
		local vResult
		local vParamIndex = 1
		
		if vPrefix and string.find(vPrefix, "%%") then
			vResult = string.format(vPrefix, pList[1])
			vParamIndex = 2
		else
			vResult = vPrefix or ""
		end
		
		if vRepeat then
			for vIndex = vParamIndex, vNumItems - 1 do
				vResult = vResult..string.format(vRepeat, pList[vIndex])
			end
		end
			
		if vSuffix then
			vResult = vResult..string.format(vSuffix, pList[vNumItems])
		end
		
		return vResult
	end
end

-- Define global variables to be used directly in the XML
-- file since those references can't be object paths

Outfitter_cTitle        = Outfitter.cTitle
Outfitter_cTitleVersion = Outfitter.cTitleVersion

Outfitter_cCreateUsingTitle = Outfitter.cCreateUsingTitle
Outfitter_cAutomationLabel = Outfitter.cAutomationLabel
Outfitter_cOutfitterTabTitle = Outfitter.cOutfitterTabTitle
Outfitter_cOptionsTabTitle = Outfitter.cOptionsTabTitle
Outfitter_cAboutTabTitle = Outfitter.cAboutTabTitle

Outfitter_cNewOutfit = Outfitter.cNewOutfit
Outfitter_cNameAlreadyUsedError = Outfitter.cNameAlreadyUsedError
Outfitter_cEnableAll = Outfitter.cEnableAll
Outfitter_cEnableNone = Outfitter.cEnableNone
Outfitter_cOptionsTitle = Outfitter.cOptionsTitle

Outfitter.cSpecialThanksNames = "%s"
Outfitter.cTranslationCredit = "Translations by %s"

Outfitter_cAboutTitle = Outfitter.cAboutTitle
Outfitter_cAuthor = string.format(Outfitter.cAuthor, Outfitter:FormatItemList(Outfitter.cContributors))
Outfitter_cTestersTitle = Outfitter.cTestersTitle
Outfitter_cTestersNames = string.format(Outfitter.cTestersNames, Outfitter:FormatItemList(Outfitter.cTesters))
Outfitter_cSpecialThanksTitle = Outfitter.cSpecialThanksTitle
Outfitter_cSpecialThanksNames = string.format(Outfitter.cSpecialThanksNames, Outfitter:FormatItemList(Outfitter.cFriendsAndFamily))
Outfitter_cTranslationCredit = string.format(Outfitter.cTranslationCredit, Outfitter:FormatItemList(Outfitter.cTranslators))
Outfitter_cURL = Outfitter.cURL

Outfitter_cEditScriptTitle = Outfitter.cEditScriptTitle
Outfitter_cEditScriptEllide = Outfitter.cEditScriptEllide
Outfitter_cPresetScript = Outfitter.cPresetScript
Outfitter_cSettings = Outfitter.cSettings
Outfitter_cSource = Outfitter.cSource

Outfitter_cIconFilterLabel = Outfitter.cIconFilterLabel
Outfitter_cIconSetLabel = Outfitter.cIconSetLabel

-- These definitions are for backward compatibility with third-party addons
-- which call into Outfitter directly (OutfitterFu, FishingBuddy, ArkInventory)
-- Hopefully the authors of those addons will eventually migrate their code to
-- use the new functions instead so that these can eventually be eliminated.

Outfitter_cFishingStatName = Outfitter.cFishingStatName

Outfitter_cCompleteOutfits = Outfitter.cCompleteOutfits
Outfitter_cAccessoryOutfits = Outfitter.cAccessoryOutfits
Outfitter_cOddsNEndsOutfits = Outfitter.cOddsNEndsOutfits

function Outfitter_OnLoad(...) return Outfitter:OnLoad(...) end
function Outfitter_IsInitialized(...) return Outfitter:IsInitialized(...) end
function Outfitter_Update(...) return Outfitter:Update(...) end

function Outfitter_FindOutfitByStatID(...) return Outfitter:FindOutfitByStatID(...) end
function Outfitter_FindOutfitByName(...) return Outfitter:FindOutfitByName(...) end

function Outfitter_GetCategoryOrder(...) return Outfitter:GetCategoryOrder(...) end
function Outfitter_GetOutfitsByCategoryID(...) return Outfitter:GetOutfitsByCategoryID(...) end
function Outfitter_HasVisibleOutfits(...) return Outfitter:HasVisibleOutfits(...) end
function Outfitter_OutfitIsVisible(...) return Outfitter:OutfitIsVisible(...) end

function Outfitter_GenerateSmartOutfit(...) return Outfitter:GenerateSmartOutfit(...) end
function Outfitter_AddOutfit(...) return Outfitter:AddOutfit(...) end
function Outfitter_DeleteOutfit(...) return Outfitter:DeleteOutfit(...) end

function Outfitter_WearOutfit(pOutfit, pCategoryID, pWearBelowOutfit) return Outfitter:WearOutfit(pOutfit) end
function Outfitter_RemoveOutfit(...) return Outfitter:RemoveOutfit(...) end
function Outfitter_WearingOutfit(...) return Outfitter:WearingOutfit(...) end

function Outfitter_RegisterOutfitEvent(...) return Outfitter:RegisterOutfitEvent(...) end
function Outfitter_UnregisterOutfitEvent(...) return Outfitter:UnregisterOutfitEvent(...) end

function Outfitter_GetOutfitFromListItem(...) return Outfitter:GetOutfitFromListItem(...) end
function Outfitter_GetCurrentOutfitInfo(...) return Outfitter:GetCurrentOutfitInfo(...) end
function Outfitter_SetShowMinimapButton(...) return Outfitter:SetShowMinimapButton(...) end

function Outfitter_GetItemInfoFromLink(...) return Outfitter:GetItemInfoFromLink(...) end
function Outfitter_GetOutfitsUsingItem(...) return Outfitter:GetOutfitsUsingItem(...) end

function OutfitterItemList_GetEquippableItems(...) return Outfitter.ItemList_GetEquippableItems(...) end
function OutfitterItemList_GetMissingItems(...) return Outfitter.ItemList_GetMissingItems(...) end

function OutfitterMinimapButton_ItemSelected(...) return Outfitter.MinimapButton_ItemSelected(...) end

--

Outfitter.OrigGameTooltipOnShow = nil
Outfitter.OrigGameTooltipOnHide = nil

Outfitter.cMinEquipmentUpdateInterval = 1.5

Outfitter.cInitializationEvents =
{
	["PLAYER_ENTERING_WORLD"] = true,
	["BAG_UPDATE"] = true,
	["UNIT_INVENTORY_CHANGED"] = true,
	["ZONE_CHANGED_NEW_AREA"] = true,
	["ZONE_CHANGED"] = true,
	["ZONE_CHANGED_INDOORS"] = true,
	["PLAYER_ALIVE"] = true,
}

Outfitter.BANKED_FONT_COLOR = {r = 0.25, g = 0.2, b = 1.0}
Outfitter.BANKED_FONT_COLOR_CODE = "|cff4033ff"
Outfitter.OUTFIT_MESSAGE_COLOR = {r = 0.2, g = 0.75, b = 0.3}

Outfitter.cItemLinkFormat = "|Hitem:(-?%d+):(-?%d+):(-?%d+):(-?%d+):(-?%d+):(-?%d+):(-?%d+):(-?%d+):(-?%d+)|h%[([^%]]*)%]|h"

Outfitter.cUniqueEquippedGemIDs =
{
	[2850] = true, -- Blood of Amber, ItemCode 33140, +13 Spell Critical Strike Rating
	-- [2945] = true, -- Bold Ornate Ruby, ItemCode 28362, +20 Attack Power
	[2749] = true, -- Brilliant Bladestone, ItemCode 33139, +12 Intellect
	[1068] = true, -- Charmed Amani Jewel, ItemCode 34256, +15 Stamina
	[1593] = true, -- Crimson Sun, ItemCode 33131, +24 Attack Power
	[368] = true, -- Delicate Fire Ruby, ItemCode 33132, +12 Agility
	[3210] = true, -- Don Julio's Heart, ItemCode 33133
	[1957] = true, -- Facet of Eternity, ItemCode 33144, +12 Defense Rating
	[1071] = true, -- Falling Star, ItemCode 33135, +18 Stamina
	-- [2914] = true, -- Gleaming Ornate Dawnstone, ItemCode 28120, +10 Spell Critical Strike Rating FIXME: Is this supposed to be 2934 maybe?
	
	[3218] = true, -- Great Bladestone, ItemCode 33141, +12 Spell Hit Rating
	-- [2946] = true, -- Inscribed Ornate Topaz, ItemCode 28363, +10 Attack Power, +5 Critical Strike Rating
	[3211] = true, -- Kailee's Rose, ItemCode 33134, +26 Healing and +9 Spell Damage
	[3215] = true, -- Mystic Bladestone, ItemCode 33138, +12 Resilience Rating
	-- [2916] = true, -- Potent Ornate Topaz, ItemCode 28123, +6 Spell Damage, +5 Spell Crit Rating
	[1591] = true, -- Radiant Spencerite, ItemCode 32735, +20 Attack Power
	[2784] = true, -- Rigid Bladestone, ItemCode 33142, +12 Hit Rating
	-- [2912] = true, -- Runed Ornate Ruby, ItemCode 28118, +12 Spell Damage
	-- [2913] = true, -- Smooth Ornate Dawnstone, ItemCode 28119, +10 Critical Strike Rating
	[370] = true, -- Sparkling Falling Star, ItemCode 33137, +12 Spirit
	
	[3220] = true, -- Stone of Blades, ItemCode 33143, +12 Critical Strike Rating
	[2891] = true, -- Sublime Mystic Dawnstone, ItemCode 27679, +10 Resilience Rating
	[2899] = true, -- Barbed Deep Peridot, ItemCode 27786 & 27809, +3 Stamina, +4 Critical Strike Rating
	[3103] = true, -- Don Amancio's Heart, ItemCode 30598, +8 Strength (numerous enchants of +8 str)
	[3065] = true, -- Don Rodrigo's Heart, ItemCode 30571, +8 Strength
	[3268] = true, -- Eye of the Sea, ItemCode 34831, +15 Stamina
	[2943] = true, -- Mighty Blood Garnet, ItemCode 28360, +14 Attack Power
	[2944] = true, -- Mighty Blood Garnet, ItemCode 28361, +14 Attack Power
	[2898] = true, -- Notched Deep Peridot, ItemCode 27785, +3 Stamina, +4 Spell Critical Strike Rating
	[2923] = true, -- Notched Deep Peridot, ItemCode 27820, +3 Stamina, +4 Spell Critical Strike Rating
	[2896] = true, -- Stark Blood Garnet, ItemCode 27777, +8 Spell Damage
	[2924] = true, -- Stark Blood Garnet, ItemCode 27812, +8 Spell Damage
	[2970] = true, -- Swift Starfire Diamond, ItemCode 28557, +12 Spell Damage and Minor Run Speed Increase
	[2969] = true, -- Swift Windfire Diamond, ItemCode 28556, +20 Attack Power and Minor Run Speed Increase

	[3156] = true, -- Unstable Amethyst, ItemCode 32634, +8 Attack Power and +6 Stamina
	[3159] = true, -- Unstable Citrine, ItemCode 32637, +8 Attack Power
	[3157] = true, -- Unstable Peridot, ItemCode 32635,
	[3158] = true, -- Unstable Sapphire, ItemCode 32636,
	[3161] = true, -- Unstable Talasite, ItemCode 32639,
	[3160] = true, -- Unstable Topaz, ItemCode 32638,

	-- [3091] = true, -- Radiant Chrysoprase, ItemCode 30608, +5 Spell Critical Rating and +5 Spell Penetration
	-- [3077] = true, -- Dazzling Chrysoprase, ItemCode 30589, +5 Intellect and 2 mana per 5 sec.
	-- [3082] = true, -- Effulgent Chrysoprase, ItemCode 30594, +5 Defense Rating and 2 mana per 5 sec.
	-- [3078] = true, -- Enduring Chrysoprase, ItemCode 30590, +6 Stamina and +5 Defense Rating
	-- [3085] = true, -- Jagged Chrysoprase, ItemCode 30602, +6 Stamina and +5 Crit Rating
	-- [3089] = true, -- Lambent Chrysoprase, ItemCode 30606, +5 Spell Hit Rating and 2 mana per 5 sec.
	-- [3047] = true, -- Polished Chrysoprase, ItemCode 30548, +6 Stamina and +5 Spell Crit Rating
	-- [3058] = true, -- Rune Covered Chrysoprase, ItemCode 30560, +5 Spell Critical Rating and 2 mana per 5 sec.
	-- [3074] = true, -- Seer's Chrysoprase, ItemCode 30586, +4 Intellect and +5 Spirit
	-- [3080] = true, -- Steady Chrysoprase, ItemCode 30592, +6 Stamina and +5 Resilience Rating
	-- [3049] = true, -- Sundered Chrysoprase, ItemCode 30550, +5 Critical Strike Rating and +2 mana per 5 sec.
	-- [3071] = true, -- Timeless Chrysoprase, ItemCode 30583, +5 Intellect and +6 Stamina
	-- [3088] = true, -- Vivid Chrysoprase, ItemCode 30605, +5 Spell Hit Rating and +6 Stamina

	-- [3062] = true, -- Assassin's Fire Opal, Item 30565, +6 Critical Rating and +5 Dodge Rating
	-- [3084] = true, -- Beaming Fire Opal, ItemCode 30601, +5 Dodge Rating and +4 Resilience Rating
	-- [3075] = true, -- Champion's Fire Opal, ItemCode 30587, +5 Strength and +4 Defense
	-- [3070] = true, -- Deadly Fire Opal, ItemCode 30582, +8 Attack Power and +5 Critical Rating
	-- [3069] = true, -- Durable Fire Opal, ItemCode 30581, +11 Healing and +4 Resilience Rating
	-- [3079] = true, -- Empowered Fire Opal, ItemCode 30591, +8 Attack Power and +5 Resilience Rating
	-- [3072] = true, -- Enscribed Fire Opal, ItemCode 30584, +5 Strength and +4 Critical Rating
	-- [3057] = true, -- Etched Fire Opal, ItemCode 30559, +5 Strength and +4 Hit Rating
	-- [3056] = true, -- Glimmering Fire Opal, ItemCode 30558, +5 Parry Rating and +4 Defense Rating
	-- [3055] = true, -- Glinting Fire Opal, ItemCode 30556, +5 Agility and +4 Hit Rating
	-- [3073] = true, -- Glistening Fire Opal, ItemCode 30585, +4 Agility and +5 Defense Rating
	-- [3050] = true, -- Infused Fire Opal, ItemCode 30551, +6 Spell Damage and +4 Intellect
	-- [3081] = true, -- Iridescent Fire Opal, ItemCode 30593, +11 Healing and +4 Spell Critical Rating
	-- [3046] = true, -- Luminous Fire Opal, ItemCode 30547, +11 Healing and +4 Intellect
	-- [3066] = true, -- Mysterious Fire Opal, ItemCode 30573, +6 Spell Damage and +5 Spell Penetration
	-- [3068] = true, -- Nimble Fire Opal, ItemCode 30575, +5 Dodge Rating and +4 Hit Rating
	-- [3076] = true, -- Potent Fire Opal, ItemCode 30588, +6 Spell Damage and +4 Spell Critical Rating
	-- [3052] = true, -- Pristine Fire Opal, ItemCode 30553, +10 Attack Power and +4 Hit Rating
	-- [3087] = true, -- Resplendent Fire Opal, Item ID 30604, ItemCode 3087, 
	-- [3061] = true, -- Shining Fire Opal, ItemCode 30564, +6 Spell Damage and +5 Spell Hit Rating
	-- [3090] = true, -- Splendid Fire Opal, ItemCode 30607, +5 Parry Rating and +4 Resilience Rating
	-- [3053] = true, -- Stalwart Fire Opal, ItemCode 30554, +5 Defense Rating and +4 Dodge Rating

	-- [3100] = true, -- Blessed Tanzanite, ItemCode 30552, +11 Healing and +6 Stamina
	-- [3067] = true, -- Brutal Tanzanite, ItemCode 30574, +10 Attack Power and +6 Stamina
	-- [3063] = true, -- Defender's Tanzanite, ItemCode 30566, +5 Parry Rating and +6 Stamina
	-- [3083] = true, -- Fluorescent Tanzanite, ItemCode 30600, +6 Spell Damage and +4 Spirit
	-- [3099] = true, -- Glowing Tanzanite, ItemCode 30555, +6 Spell Damage and +6 Stamina
	-- [3064] = true, -- Imperial Tanzanite, ItemCode 30572, +5 Spirit and +9 Healing
	-- [3060] = true, -- Regal Tanzanite, ItemCode 30563, +5 Dodge Rating and +6 Stamina
	-- [3086] = true, -- Royal Tanzanite, ItemCode 30603, +11 Healing and 2 mana per 5 sec.
	-- [3048] = true, -- Shifting Tanzanite, ItemCode 30549, +5 Strength and +4 Agility
	-- [3045] = true, -- Sovereign Tanzanite, ItemCode 30546, +5 Strength and +6 Stamina
}

StaticPopupDialogs.OUTFITTER_CANT_RELOADUI =
{
	text = TEXT(Outfitter.cCantReloadUI),
	button1 = TEXT(OKAY),
	OnAccept = function() end,
	OnCancel = function() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
}

Outfitter.cCategoryDescriptions =
{
	Complete = Outfitter.cCompleteCategoryDescription,
	Accessory = Outfitter.cAccessoryCategoryDescription,
	OddsNEnds = Outfitter.cOddsNEndsCategoryDescription,
}

Outfitter.cSlotNames =
{
	-- First priority goes to armor
	
	"HeadSlot",
	"ShoulderSlot",
	"ChestSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	
	-- Second priority goes to weapons
	
	"MainHandSlot",
	"SecondaryHandSlot",
	"RangedSlot",
	"AmmoSlot",
	
	-- Last priority goes to items with no durability
	
	"BackSlot",
	"NeckSlot",
	"ShirtSlot",
	"TabardSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot",
}

Outfitter.cSlotDisplayNames =
{
	HeadSlot = HEADSLOT,
	NeckSlot = NECKSLOT,
	ShoulderSlot = SHOULDERSLOT,
	BackSlot = BACKSLOT,
	ChestSlot = CHESTSLOT,
	ShirtSlot = SHIRTSLOT,
	TabardSlot = TABARDSLOT,
	WristSlot = WRISTSLOT,
	HandsSlot = HANDSSLOT,
	WaistSlot = WAISTSLOT,
	LegsSlot = LEGSSLOT,
	FeetSlot = FEETSLOT,
	Finger0Slot = Outfitter.cFinger0SlotName,
	Finger1Slot = Outfitter.cFinger1SlotName,
	Trinket0Slot = Outfitter.cTrinket0SlotName,
	Trinket1Slot = Outfitter.cTrinket1SlotName,
	MainHandSlot = MAINHANDSLOT,
	SecondaryHandSlot = SECONDARYHANDSLOT,
	RangedSlot = RANGEDSLOT,
	AmmoSlot = AMMOSLOT,
}

Outfitter.cInvTypeToSlotName =
{
	INVTYPE_2HWEAPON = {SlotName = "MainHandSlot", MetaSlotName = "TwoHandSlot"},
	INVTYPE_BAG = {SlotName = "Bag"},
	INVTYPE_BODY = {SlotName = "ShirtSlot"},
	INVTYPE_CHEST = {SlotName = "ChestSlot"},
	INVTYPE_CLOAK = {SlotName = "BackSlot"},
	INVTYPE_FEET = {SlotName = "FeetSlot"},
	INVTYPE_FINGER = {SlotName = "Finger0Slot"},
	INVTYPE_HAND = {SlotName = "HandsSlot"},
	INVTYPE_HEAD = {SlotName = "HeadSlot"},
	INVTYPE_HOLDABLE = {SlotName = "SecondaryHandSlot"},
	INVTYPE_LEGS = {SlotName = "LegsSlot"},
	INVTYPE_NECK = {SlotName = "NeckSlot"},
	INVTYPE_RANGED = {SlotName = "RangedSlot"},
	INVTYPE_ROBE = {SlotName = "ChestSlot"},
	INVTYPE_SHIELD = {SlotName = "SecondaryHandSlot"},
	INVTYPE_SHOULDER = {SlotName = "ShoulderSlot"},
	INVTYPE_TABARD = {SlotName = "TabardSlot"},
	INVTYPE_TRINKET = {SlotName = "Trinket0Slot"},
	INVTYPE_WAIST = {SlotName = "WaistSlot"},
	INVTYPE_WEAPON = {SlotName = "MainHandSlot", MetaSlotName = "Weapon0Slot"},
	INVTYPE_WEAPONMAINHAND = {SlotName = "MainHandSlot"},
	INVTYPE_WEAPONOFFHAND = {SlotName = "SecondaryHandSlot"},
	INVTYPE_WRIST = {SlotName = "WristSlot"},
	INVTYPE_RANGEDRIGHT = {SlotName = "RangedSlot"},
	INVTYPE_AMMO = {SlotName = "AmmoSlot"},
	INVTYPE_THROWN = {SlotName = "RangedSlot"},
	INVTYPE_RELIC = {SlotName = "RangedSlot"},
}

Outfitter.cHalfAlternateStatSlot =
{
	Trinket0Slot = "Trinket1Slot",
	Finger0Slot = "Finger1Slot",
	Weapon0Slot = "Weapon1Slot",
}

Outfitter.cFullAlternateStatSlot =
{
	Trinket0Slot = "Trinket1Slot",
	Trinket1Slot = "Trinket0Slot",
	Finger0Slot = "Finger1Slot",
	Finger1Slot = "Finger0Slot",
	Weapon0Slot = "Weapon1Slot",
	Weapon1Slot = "Weapon0Slot",
}

Outfitter.cCategoryOrder =
{
	"Complete",
	"Accessory"
}

Outfitter.cItemAliases =
{
	[18608] = 18609,	-- Benediction -> Anathema
	[18609] = 18608,	-- Anathema -> Benediction
	[17223] = 17074,	-- Thunderstrike -> Shadowstrike
	[17074] = 17223,	-- Shadowstrike -> Thunderstrike
}

Outfitter.cFishingPoles =
{
	{Code = 25978, SubCode = 0}, -- Seth's Graphite Fishing Pole
	{Code = 19970, SubCode = 0}, -- Arcanite Fishing Pole
	{Code = 19022, SubCode = 0}, -- Nat Pagles Fishing Pole
	{Code = 12224, SubCode = 0}, -- Blump Family Fishing Pole
	{Code = 6367, SubCode = 0}, -- Big Iron Fishing Pole
	{Code = 6365, SubCode = 0}, -- Strong Fishing Pole
	{Code = 6256, SubCode = 0}, -- Fishing Pole
}

Outfitter.cRidingItems =
{
	{Code = 11122, SubCode = 0}, -- Carrot on a Stick
	{Code = 25653, SubCode = 0}, -- Riding Crop
}

Outfitter.cArgentDawnTrinkets = 
{
	{Code = 13209, SubCode = 0}, -- Seal of the Dawn
	{Code = 19812, SubCode = 0}, -- Rune of the Dawn
	{Code = 12846, SubCode = 0}, -- Argent Dawn Commission
}

Outfitter.cStatIDItems =
{
	Fishing = Outfitter.cFishingPoles,
	Riding = Outfitter.cRidingItems,
	ArgentDawn = Outfitter.cArgentDawnTrinkets,
}

Outfitter.cIgnoredUnusedItems = 
{
	[2901] = "Mining Pick",
	[5956] = "Blacksmith hammer",
	[6219] = "Arclight Spanner",
	[7005] = "Skinning Knife",
	[7297] = "Morbent's Bane",
	[10696] = "Enchanted Azsharite Felbane Sword",
	[10697] = "Enchanted Azsharite Felbane Dagger",
	[10698] = "Enchanted Azsharite Felbane Staff",
	[20406] = "Twilight Cultist Mantle",
	[20407] = "Twilight Cultist Robe",
	[20408] = "Twilight Cultist Cowl",
}

Outfitter.cSmartOutfits =
{
	{Name = Outfitter.cFishingOutfit, StatID = "Fishing", ScriptID = "Fishing"},
	{Name = Outfitter.cHerbalismOutfit, StatID = "Herbalism", ScriptID = "Herbalism"},
	{Name = Outfitter.cMiningOutfit, StatID = "Mining", ScriptID = "Mining"},
	{Name = Outfitter.cSkinningOutfit, StatID = "Skinning", ScriptID = "Skinning"},
	{Name = Outfitter.cFireResistOutfit, StatID = "FireResist"},
	{Name = Outfitter.cNatureResistOutfit, StatID = "NatureResist"},
	{Name = Outfitter.cShadowResistOutfit, StatID = "ShadowResist"},
	{Name = Outfitter.cArcaneResistOutfit, StatID = "ArcaneResist"},
	{Name = Outfitter.cFrostResistOutfit, StatID = "FrostResist"},
}

Outfitter.cStatCategoryInfo =
{
	{Category = "Stat", Name = Outfitter.cStatsCategory},
	{Category = "Melee", Name = Outfitter.cMeleeCategory},
	{Category = "Spell", Name = Outfitter.cSpellsCategory},
	{Category = "Regen", Name = Outfitter.cRegenCategory},
	{Category = "Resist", Name = Outfitter.cResistCategory},
	{Category = "Trade", Name = Outfitter.cTradeCategory},
}

Outfitter.cSpecialIDEvents =
{
	Battle = {Equip = "BATTLE_STANCE", Unequip = "NOT_BATTLE_STANCE"},
	Defensive = {Equip = "DEFENSIVE_STANCE", Unequip = "NOT_DEFENSIVE_STANCE"},
	Berserker = {Equip = "BERSERKER_STANCE", Unequip = "NOT_BERSERKER_STANCE"},
	
	Bear = {Equip = "BEAR_FORM", Unequip = "NOT_BEAR_FORM"},
	Cat = {Equip = "CAT_FORM", Unequip = "NOT_CAT_FORM"},
	Aquatic = {Equip = "AQUATIC_FORM", Unequip = "NOT_AQUATIC_FORM"},
	Travel = {Equip = "TRAVEL_FORM", Unequip = "NOT_TRAVEL_FORM"},
	Moonkin = {Equip = "MOONKIN_FORM", Unequip = "NOT_MOONKIN_FORM"},
	Tree = {Equip = "TREE_FORM", Unequip = "NOT_TREE_FORM"},
	Prowl = {Equip = "STEALTH", Unequip = "NOT_STEALTH"},
	Flight = {Equip = "FLIGHT_FORM", Unequip = "NOT_FLIGHT_FORM"},
	Caster = {Equip = "CASTER_FORM", Unequip = "NOT_CASTER_FORM"},
	
	Shadowform = {Equip = "SHADOWFORM", Unequip = "NOT_SHADOWFORM"},

	Stealth = {Equip = "STEALTH", Unequip = "NOT_STEALTH"},

	GhostWolf = {Equip = "GHOST_WOLF", Unequip = "NOT_GHOST_WOLF"},

	Monkey = {Equip = "MONKEY_ASPECT", Unequip = "NOT_MONKEY_ASPECT"},
	Hawk = {Equip = "HAWK_ASPECT", Unequip = "NOT_HAWK_ASPECT"},
	Cheetah = {Equip = "CHEETAH_ASPECT", Unequip = "NOT_CHEETAH_ASPECT"},
	Pack = {Equip = "PACK_ASPECT", Unequip = "NOT_PACK_ASPECT"},
	Beast = {Equip = "BEAST_ASPECT", Unequip = "NOT_BEAST_ASPECT"},
	Wild = {Equip = "WILD_ASPECT", Unequip = "NOT_WILD_ASPECT"},
	Viper = {Equip = "VIPER_ASPECT", Unequip = "NOT_VIPER_ASPECT"},
	Feigning = {Equip = "FEIGN_DEATH", Unequip = "NOT_FEIGN_DEATH"},
	
	Evocate = {Equip = "EVOCATE", Unequip = "NOT_EVOCATE"},
	
	Blood = {Equip = "BLOOD", Unequip = "NOT_BLOOD"},
	Frost = {Equip = "FROST", Unequip = "NOT_FROST"},
	Unholy = {Equip = "UNHOLY", Unequip = "NOT_UNHOLY"},

	Dining = {Equip = "DINING", Unequip = "NOT_DINING"},
	City = {Equip = "CITY", Unequip = "NOT_CITY"},
	Riding = {Equip = "MOUNTED", Unequip = "NOT_MOUNTED"},
	Swimming = {Equip = "SWIMMING", Unequip = "NOT_SWIMMING"},
	Spirit = {Equip = "SPIRIT_REGEN", Unequip = "NOT_SPIRIT_REGEN"},
	ArgentDawn = {Equip = "ARGENT_DAWN", Unequip = "NOT_ARGENT_DAWN"},

	Battleground = {Equip = "BATTLEGROUND", Unequip = "NOT_BATTLEGROUND"},
	AB = {Equip = "BATTLEGROUND_AB", Unequip = "NOT_BATTLEGROUND_AB"},
	AV = {Equip = "BATTLEGROUND_AV", Unequip = "NOT_BATTLEGROUND_AV"},
	WSG = {Equip = "BATTLEGROUND_WSG", Unequip = "NOT_BATTLEGROUND_WSG"},
	EotS = {Equip = "BATTLEGROUND_EOTS", Unequip = "NOT_BATTLEGROUND_EOTS"},
	Arena = {Equip = "BATTLEGROUND_ARENA", Unequip = "NOT_BATTLEGROUND_ARENA"},
	BladesEdgeArena = {Equip = "BATTLEGROUND_BLADESEDGE", Unequip = "NOT_BATTLEGROUND_BLADESEDGE"},
	NagrandArena = {Equip = "BATTLEGROUND_NAGRAND", Unequip = "NOT_BATTLEGROUND_NAGRAND"},
	LordaeronArena = {Equip = "BATTLEGROUND_LORDAERON", Unequip = "NOT_BATTLEGROUND_LORDAERON"},
}

Outfitter.cClassSpecialOutfits =
{
	WARRIOR =
	{
		{Name = Outfitter.cWarriorBattleStance, ScriptID = "Battle"},
		{Name = Outfitter.cWarriorDefensiveStance, ScriptID = "Defensive"},
		{Name = Outfitter.cWarriorBerserkerStance, ScriptID = "Berserker"},
	},
	
	DRUID =
	{
		{Name = Outfitter.cDruidCasterForm, ScriptID = "Caster"},
		{Name = Outfitter.cDruidBearForm, ScriptID = "Bear"},
		{Name = Outfitter.cDruidCatForm, ScriptID = "Cat"},
		{Name = Outfitter.cDruidAquaticForm, ScriptID = "Aquatic"},
		{Name = Outfitter.cDruidTravelForm, ScriptID = "Travel"},
		{Name = Outfitter.cDruidMoonkinForm, ScriptID = "Moonkin"},
		{Name = Outfitter.cDruidTreeOfLifeForm, ScriptID = "Tree"},
		{Name = Outfitter.cDruidProwl, ScriptID = "Prowl"},
		{Name = Outfitter.cDruidFlightForm, ScriptID = "Flight"},
	},
	
	PRIEST =
	{
		{Name = Outfitter.cPriestShadowform, ScriptID = "Shadowform"},
	},
	
	ROGUE =
	{
		{Name = Outfitter.cRogueStealth, ScriptID = "Stealth"},
	},
	
	SHAMAN =
	{
		{Name = Outfitter.cShamanGhostWolf, ScriptID = "GhostWolf"},
	},
	
	HUNTER =
	{
		{Name = Outfitter.cHunterMonkey, ScriptID = "Monkey"},
		{Name = Outfitter.cHunterHawk, ScriptID = "Hawk"},
		{Name = Outfitter.cHunterCheetah, ScriptID = "Cheetah"},
		{Name = Outfitter.cHunterPack, ScriptID = "Pack"},
		{Name = Outfitter.cHunterBeast, ScriptID = "Beast"},
		{Name = Outfitter.cHunterWild, ScriptID = "Wild"},
		{Name = Outfitter.cHunterViper, ScriptID = "Viper"},
	},
	
	MAGE =
	{
		{Name = Outfitter.cMageEvocate, ScriptID = "Evocate"},
	},
	
	DEATHKNIGHT =
	{
		{Name = Outfitter.cDeathknightBlood, ScriptID = "Blood"},
		{Name = Outfitter.cDeathknightFrost, ScriptID = "Frost"},
		{Name = Outfitter.cDeathknightUnholy, ScriptID = "Unholy"},
	},
}

Outfitter.cSpellNameSpecialID =
{
	[Outfitter.cAspectOfTheCheetah] = "Cheetah",
	[Outfitter.cAspectOfThePack] = "Pack",
	[Outfitter.cAspectOfTheBeast] = "Beast",
	[Outfitter.cAspectOfTheWild] = "Wild",
	[Outfitter.cAspectOfTheViper] = "Viper",
	[Outfitter.cEvocate] = "Evocate",
}

Outfitter.cAuraIconSpecialID =
{
	["INV_Misc_Fork&Knife"] = "Dining",
	["Spell_Shadow_Shadowform"] = "Shadowform",
	["Spell_Nature_SpiritWolf"] = "GhostWolf",
	["Ability_Rogue_FeignDeath"] = "Feigning",
	["Ability_Hunter_AspectOfTheMonkey"] = "Monkey",
	["Spell_Nature_RavenForm"] = "Hawk",
	[Outfitter.cProwl] = "Prowl",
}

-- Note that zone special outfits will be worn in the order
-- the are listed here, with later outfits being worn over
-- earlier outfits (when they're being applied at the same time)
-- This allows BG-specific outfits to take priority over the generic
-- BG outfit

Outfitter.cZoneSpecialIDs =
{
	"ArgentDawn",
	"City",
	"Battleground",
	"AV",
	"AB",
	"WSG",
	"Arena",
	"BladesEdgeArena",
	"NagrandArena",
	"LordaeronArena",
	"EotS",
}

Outfitter.cZoneSpecialIDMap =
{
	[Outfitter.cWesternPlaguelands] = {"ArgentDawn"},
	[Outfitter.cEasternPlaguelands] = {"ArgentDawn"},
	[Outfitter.cStratholme] = {"ArgentDawn"},
	[Outfitter.cScholomance] = {"ArgentDawn"},
	[Outfitter.cNaxxramas] = {"ArgentDawn", "Naxx"},
	[Outfitter.cAlteracValley] = {"Battleground", "AV"},
	[Outfitter.cArathiBasin] = {"Battleground", "AB"},
	[Outfitter.cWarsongGulch] = {"Battleground", "WSG"},
	[Outfitter.cEotS] = {"Battleground", "EotS"},
	[Outfitter.cBladesEdgeArena] = {"Battleground", "BladesEdgeArena", "Arena"},
	[Outfitter.cNagrandArena] = {"Battleground", "NagrandArena", "Arena"},
	[Outfitter.cRuinsOfLordaeron] = {"Battleground", "LordaeronArena", "Arena"},
	[Outfitter.cIronforge] = {"City"},
	[Outfitter.cCityOfIronforge] = {"City"},
	[Outfitter.cDarnassus] = {"City"},
	[Outfitter.cStormwind] = {"City"},
	[Outfitter.cOrgrimmar] = {"City"},
	[Outfitter.cThunderBluff] = {"City"},
	[Outfitter.cUndercity] = {"City"},
	[Outfitter.cSilvermoon] = {"City"},
	[Outfitter.cExodar] = {"City"},
	[Outfitter.cShattrath] = {"City"},
}

Outfitter.cCombatEquipmentSlots =
{
	MainHandSlot = true,
	SecondaryHandSlot = true,
	RangedSlot = true,
	AmmoSlot = true,
}

Outfitter.EquippableItems = nil

Outfitter.cMaxDisplayedItems = 14

Outfitter.cPanelFrames =
{
	"OutfitterMainFrame",
	"OutfitterOptionsFrame",
	"OutfitterAboutFrame",
}
--[[
Outfitter.cShapeshiftInfo =
{
	-- Warriors
	
	[Outfitter.cBattleStance] = {ID = "Battle", Type = "WARSTANCE"},
	[Outfitter.cDefensiveStance] = {ID = "Defensive", Type = "WARSTANCE"},
	[Outfitter.cBerserkerStance] = {ID = "Berserker", Type = "WARSTANCE"},
	
	-- Druids
	
	[Outfitter.cBearForm] = {ID = "Bear", Type = "DRUIDFORM", MaybeInCombat = true},
	[Outfitter.cCatForm] = {ID = "Cat", Type = "DRUIDFORM"},
	[Outfitter.cAquaticForm] = {ID = "Aquatic", Type = "DRUIDFORM"},
	[Outfitter.cTravelForm] = {ID = "Travel", Type = "DRUIDFORM"},
	[Outfitter.cDireBearForm] = {ID = "Bear", Type = "DRUIDFORM"},
	[Outfitter.cMoonkinForm] = {ID = "Moonkin", Type = "DRUIDFORM"},
	[Outfitter.cTreeOfLifeForm] = {ID = "Tree", Type = "DRUIDFORM"},
	[Outfitter.cFlightForm] = {ID = "Flight", Type = "DRUIDFORM"},
	[Outfitter.cSwiftFlightForm] = {ID = "Flight", Type = "DRUIDFORM"},
	CasterForm = {ID = "Caster", Type = "DRUIDFORM"}, -- this is a psuedo-form which is active when no other druid form is
	
	-- Rogues
	
	[Outfitter.cStealth] = {ID = "Stealth"},
}
]]

Outfitter.cShapeshiftTextureInfo =
{
	-- Warriors
	
	Ability_Warrior_OffensiveStance = {ID = "Battle"},
	Ability_Warrior_DefensiveStance = {ID = "Defensive"},
	Ability_Racial_Avatar = {ID = "Berserker"},
	
	-- Druids
	
	Ability_Racial_BearForm = {ID = "Bear", MaybeInCombat = true},
	Ability_Druid_CatForm = {ID = "Cat"},
	Ability_Druid_AquaticForm = {ID = "Aquatic"},
	Ability_Druid_TravelForm = {ID = "Travel"},
	Spell_Nature_ForceOfNature = {ID = "Moonkin"},
	Ability_Druid_TreeofLife = {ID = "Tree"},
	Ability_Druid_FlightForm = {ID = "Flight"},
	CasterForm = {ID = "Caster"}, -- this is a psuedo-form which is active when no other druid form is
	
	-- Rogues
	
	Ability_Stealth = {ID = "Stealth"},
	Spell_Nature_Invisibility = {ID = "Stealth"},
	
	-- Deathknight
	
	Spell_Deathknight_BloodPresence = {ID = "Blood"},
	Spell_Deathknight_FrostPresence = {ID = "Frost"},
}

StaticPopupDialogs.OUTFITTER_CONFIRM_DELETE =
{
	text = TEXT(Outfitter.cConfirmDeleteMsg),
	button1 = TEXT(DELETE),
	button2 = TEXT(CANCEL),
	OnAccept = function() Outfitter:DeleteSelectedOutfit() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs.OUTFITTER_CONFIRM_REBUILD =
{
	text = TEXT(Outfitter.cConfirmRebuildMsg),
	button1 = TEXT(Outfitter.cRebuild),
	button2 = TEXT(CANCEL),
	OnAccept = function() Outfitter:RebuildOutfit(Outfitter.OutfitToRebuild) Outfitter.OutfitToRebuild = nil end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

StaticPopupDialogs.OUTFITTER_CONFIRM_SET_CURRENT =
{
	text = TEXT(Outfitter.cConfirmSetCurrentMsg),
	button1 = TEXT(Outfitter.cSetCurrent),
	button2 = TEXT(CANCEL),
	OnAccept = function() Outfitter:SetOutfitToCurrent(Outfitter.OutfitToRebuild); Outfitter.OutfitToRebuild = nil end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

function Outfitter:ToggleOutfitterFrame()
	if self:IsOpen() then
		OutfitterFrame:Hide()
	else
		OutfitterFrame:Show()
	end
end

function Outfitter:IsOpen()
	return OutfitterFrame:IsVisible()
end

function Outfitter:OnLoad()
	for vEventID, _ in pairs(self.cInitializationEvents) do
		MCEventLib:RegisterEvent(vEventID, self.InitializationCheck, self)
	end
end

function Outfitter:OnShow()
	self.SetFrameLevel(OutfitterFrame, PaperDollFrame:GetFrameLevel() - 1)
	
	self:ShowPanel(1) -- Always switch to the main view when showing the window
end

function Outfitter:OnHide()
	self:ClearSelection()
	
	if self.QuickSlots then
		self.QuickSlots:Close()
	end
	
	OutfitterFrame:Hide()  -- This seems redundant, but the OnHide handler gets called
	                       -- in response to the parent being hidden (the character window)
	                       -- so calling Hide() on the frame here ensures that when the
	                       -- character window is hidden then Outfitter won't be displayed
	                       -- next time it's opened
end

function Outfitter:SchedulePlayerEnteringWorld()
	MCSchedulerLib:RescheduleTask(0.05, self.PlayerEnteringWorld, self)
end

function Outfitter:PlayerEnteringWorld()
	self.IsCasting = false
	self.IsChanneling = false
	
	self:BeginEquipmentUpdate()
	
	self.ItemList_FlushEquippableItems()
	
	self:RegenEnabled()
	self:UpdateAuraStates()
	
	self:ScheduleUpdateZone()
	
	self:SetSpecialOutfitEnabled("Riding", false)
	
	self:ResumeLoadScreenEvents()
	self:EndEquipmentUpdate()
end

function Outfitter:PlayerLeavingWorld()
	-- To improve load screen performance, suspend events which are
	-- fired repeatedly and rapidly during zoning
	
	self.Suspended = true
	
	MCEventLib:UnregisterEvent("BAG_UPDATE", self.BagUpdate, self)
	MCEventLib:UnregisterEvent("UNIT_INVENTORY_CHANGED", self.UnitInventoryChanged, self)
	MCEventLib:UnregisterEvent("UNIT_AURA", self.UnitAuraChanged, self)
	MCEventLib:UnregisterEvent("PLAYERBANKSLOTS_CHANGED", self.BankSlotsChanged, self)
end

function Outfitter:ResumeLoadScreenEvents()
	if self.Suspended then
		-- To improve load screen performance, suspend events which are
		-- fired repeatedly and rapidly during zoning
		
		self.Suspended = false

		MCEventLib:RegisterEvent("BAG_UPDATE", self.BagUpdate, self)
		MCEventLib:RegisterEvent("UNIT_INVENTORY_CHANGED", self.UnitInventoryChanged, self, true) -- Register as a blind event handler (no event id param)
		MCEventLib:RegisterEvent("UNIT_AURA", self.UnitAuraChanged, self)
		MCEventLib:RegisterEvent("PLAYERBANKSLOTS_CHANGED", self.BankSlotsChanged, self)
		
		self:ScheduleSynch()
	end
end

function Outfitter:VariablesLoaded()
	self.Settings = gOutfitter_Settings
	
	self.OriginalStaticPopup_EscapePressed = StaticPopup_EscapePressed
	StaticPopup_EscapePressed = self.StaticPopup_EscapePressed
end

function Outfitter:BankSlotsChanged()
	self:ScheduleSynch()
end

function Outfitter:BagUpdate()
	self:ScheduleSynch()
end

Outfitter.OutfitEvents = {}

function Outfitter:RegisterOutfitEvent(pEvent, pFunction)
	local vHandlers = self.OutfitEvents[pEvent]
	
	if not vHandlers then
		vHandlers = {}
		self.OutfitEvents[pEvent] = vHandlers
	end
	
	table.insert(vHandlers, pFunction)
end

function Outfitter:UnregisterOutfitEvent(pEvent, pFunction)
	local vHandlers = self.OutfitEvents[pEvent]
	
	if not vHandlers then
		return
	end
	
	for vIndex, vFunction in ipairs(vHandlers) do
		if vFunction == pFunction then
			table.remove(vHandlers, vIndex)
			return
		end
	end
end

function Outfitter:DispatchOutfitEvent(pEvent, pParameter1, pParameter2)
	-- Don't send out events until we're initialized
	
	if not self.Initialized then
		return
	end
	
	-- Post a message
	
	local vHandlers = self.OutfitEvents[pEvent]
	
	if vHandlers then
		for _, vFunction in ipairs(vHandlers) do
			-- Call in protected mode so that if they fail it doesn't
			-- screw up Outfitter or other addons wishing to be notified
			
			local vSucceeded, vMessage = pcall(vFunction, pEvent, pParameter1, pParameter2)
			
			if vMessage then
				self:ErrorMessage("Error dispatching event "..pEvent)
				self:ErrorMessage(vMessage)
			end
		end
	end
	
	local vEventID
	
	if pEvent == "WEAR_OUTFIT" then
		vEventID = "OUTFIT_EQUIPPED"
	elseif pEvent == "UNWEAR_OUTFIT" then
		vEventID = "OUTFIT_UNEQUIPPED"
	end
	
	local vOutfits = self.OutfitScriptEvents[vEventID]
	
	if vOutfits then
		local vScriptContext = vOutfits[pParameter2]
		
		if vScriptContext then
			local vSucceeded, vMessage = pcall(vScriptContext.Function, vScriptContext, vEventID)
			
			if vMessage then
				self:ErrorMessage("Error dispatching outfit event %s", pEvent or "nil")
				self:ErrorMessage(vMessage)
			end
		end
	end

	-- Translate to the event ids for dispatch through the event system
	
	if pEvent == "WEAR_OUTFIT" then
		MCEventLib:DispatchEvent("WEAROUTFIT")
	elseif pEvent == "UNWEAR_OUTFIT" then
		MCEventLib:DispatchEvent("UNWEAROUTFIT")
	end

	-- Set the correct Helm and Cloak settings.
	
	MCSchedulerLib:ScheduleUniqueTask(0.5, self.OutfitStack.UpdateOutfitDisplay, self.OutfitStack)
end

function Outfitter:BankFrameOpened()
	self.BankFrameIsOpen = true
	self:BankSlotsChanged()
end

function Outfitter:BankFrameClosed()
	self.BankFrameIsOpen = false
	self:BankSlotsChanged()
end

function Outfitter:RegenDisabled(pEvent)
	self.InCombat = true
	
	if self.OutfitBar then
		self.OutfitBar:AdjustAlpha()
	end
end

function Outfitter:RegenEnabled(pEvent)
	self:BeginEquipmentUpdate()
	self.InCombat = false
	self:EndEquipmentUpdate()
	
	if self.OutfitBar then
		self.OutfitBar:AdjustAlpha()
	end
end

function Outfitter:PlayerDead(pEvent)
	self.IsDead = true
end

function Outfitter:PlayerAlive(pEvent)
	if UnitIsDeadOrGhost("player") then
		return
	end
	
	self:BeginEquipmentUpdate()
	self.IsDead = false
	self:UpdateAuraStates()
	self:EndEquipmentUpdate()
end

function Outfitter:UnitHealthOrManaChanged(pUnitID)
	if pUnitID ~= "player" then
		return
	end
	
	self:BeginEquipmentUpdate()
	
	-- Check to see if the player is full while dining
	
	if self.SpecialState.Dining
	and self:PlayerIsFull() then
		self:SetSpecialOutfitEnabled("Dining", false)
	end
	
	-- If the mana drops, see if there was a recent spellcast
	
	local vPlayerMana = UnitMana("player")
	
	if vPlayerMana and (not self.PreviousManaLevel or vPlayerMana < self.PreviousManaLevel) then
		local vTime = GetTime()
		
		if self.SpellcastSentTime and vTime < self.SpellcastSentTime + 10 then
			self.SpellcastSentTime = nil
			
			-- Five second rule has begun
			
			if self.SpiritRegenEnabled then
				self.SpiritRegenEnabled = false
				self:SetSpecialOutfitEnabled("Spirit", false)
			end
			
			MCSchedulerLib:RescheduleTask(5.0, self.SpiritRegenTimer, self)
		end
	end
	
	self.PreviousManaLevel = vPlayerMana
	
	--
	
	if self.SpellcastSentMana then
		MCSchedulerLib:RescheduleTask(0.01, self.CheckSpellcastManaDrop, self)
	end
	
	--
	
	self:EndEquipmentUpdate()
end

function Outfitter:UnitSpellcastDebug(pEventID, pUnitID, pSpellName)
	if pUnitID ~= "player" then
		return
	end
	
	self:DebugMessage("UnitSpellcastDebug: %s %s %s", pEventID, pUnitID, pSpellName)
end

function Outfitter:UnitSpellcastSent(pEventID, pUnitID, pSpellName)
	if pUnitID ~= "player" then
		return
	end
	
	self.SpellcastSentTime = GetTime()
	
	if not self.IsCasting then
		self:DebugMessage(GREEN_FONT_COLOR_CODE.."IsCasting")
		self.IsCasting = true
	end
end

function Outfitter:UnitSpellcastChannelStart(pEventID, pUnitID, pSpellName)
	if pUnitID ~= "player" then
		return
	end
	
	self:DebugMessage(GREEN_FONT_COLOR_CODE.."IsChanneling")
	self.IsChanneling = true
end

function Outfitter:UnitSpellcastChannelStop(pEventID, pUnitID, pSpellName)
	if pUnitID ~= "player" then
		return
	end
	
	if not self.IsChanneling then
		return
	end

	self:DebugMessage(RED_FONT_COLOR_CODE.."NOT IsChanneling")
	self:DebugMessage(RED_FONT_COLOR_CODE.."NOT IsCasting")
	
	self:BeginEquipmentUpdate()
	self.IsChanneling = false
	self.IsCasting = false
	self:SetUpdateDelay(GetTime(), 0.5) -- Need a short delay because the 'in combat' message doesn't come until after the spellcast is done
	self:EndEquipmentUpdate()
end

function Outfitter:UnitSpellcastStop(pEventID, pUnitID, pSpellName)
	if pUnitID ~= "player" then
		return
	end
	
	if not self.IsCasting then
		return
	end
	
	self:DebugMessage(RED_FONT_COLOR_CODE.."NOT IsCasting")
	
	self:BeginEquipmentUpdate()
	self.IsCasting = false
	self:SetUpdateDelay(GetTime(), 0.5) -- Need a short delay because the 'in combat' message doesn't come until after the spellcast is done
	self:EndEquipmentUpdate()
end

function Outfitter:SpiritRegenTimer()
	self.SpiritRegenEnabled = true
	self:SetSpecialOutfitEnabled("Spirit", true)
end

function Outfitter:PlayerIsFull()
	if UnitHealth("player") < (UnitHealthMax("player") * 0.85) then
		return false
	end

	if UnitPowerType("player") ~= 0 then
		return true
	end
	
	return UnitMana("player") > (UnitManaMax("player") * 0.85)
end

function Outfitter:UnitInventoryChanged(pUnitID)
	if pUnitID == "player" then
		self:ScheduleSynch()
	end
end

function Outfitter:ScheduleSynch()
	MCSchedulerLib:ScheduleUniqueTask(0.01, self.Synchronize, self)
end

function Outfitter:InventoryChanged()
	self.DisplayIsDirty = true -- Update the list so the checkboxes reflect the current state
	
	local vNewItemsOutfit, vCurrentOutfit = self:GetNewItemsOutfit(self.CurrentOutfit)
	
	if vNewItemsOutfit then
		-- Save the new outfit
		
		self.CurrentOutfit = vCurrentOutfit
		
		-- Update the selected outfit or temporary outfit
		
		self:SubtractOutfit(vNewItemsOutfit, self.ExpectedOutfit)
		
		if self.SelectedOutfit then
			self:UpdateOutfitFromInventory(self.SelectedOutfit, vNewItemsOutfit)
		else
			self:UpdateTemporaryOutfit(vNewItemsOutfit)
		end
		
		if self.QuickSlots then
			self.QuickSlots:InventoryChanged(self:OutfitIsAmmoOnly(vNewItemsOutfit))
		end
	end
	
	self:Update(true)
end

function Outfitter:OutfitIsAmmoOnly(pOutfit)
	local vHasAmmoItem = false
	
	for vInventorySlot, vItem in pairs(pOutfit.Items) do
		if vInventorySlot ~= "AmmoSlot" then
			return false
		else
			vHasAmmoItem = true
		end
	end
	
	return vHasAmmoItem
end

function Outfitter:ExecuteCommand(pCommand)
	local vCommands =
	{
		wear = {useOutfit = true, func = self.WearOutfitNow},
		unwear = {useOutfit = true, func = self.RemoveOutfitNow},
		toggle = {useOutfit = true, func = self.ToggleOutfitNow},
		reset = {func = self.AskReset},
		
		summary = {func = self.OutfitSummary},
		rating = {func = self.RatingSummary},
		sortbags = {func = self.SortBags},
		iteminfo = {func = self.ShowLinkInfo},
		itemstats = {func = self.ShowLinkStats},
		
		missing = {func = self.ShowMissingItems},
		
		sound = {func = self.SetSoundOption},
		help = {func = self.ShowCommandHelp},
		
		disable = {func = self.DisableAutoChanges},
		enable = {func = self.EnableAutoChanges},
	}
	
	-- Evaluate options if the command uses them
	
	local vCommand
	
	if string.find(pCommand, "|h") then -- Commands which use item links don't appear to parse correctly
		vCommand = pCommand
	else
		vCommand = SecureCmdOptionParse(pCommand)
	end
	
	if not vCommand then
		return
	end
	
	--
	
	local vStartIndex, vEndIndex, vCommand, vParameter = string.find(vCommand, "(%w+) ?(.*)")
	
	if not vCommand then
		self:ShowCommandHelp()
		return
	end
	
	vCommand = strlower(vCommand)
	
	local vCommandInfo = vCommands[vCommand]
	
	if not vCommandInfo then
		self:ShowCommandHelp()
		self:ErrorMessage("Unknown command %s", vCommand)
		return
	end
	
	local vOutfit = nil
	local vCategoryID = nil
	
	if vCommandInfo.useOutfit then
		if not vParameter then
			self:ErrorMessage("Expected outfit name for "..vCommand.." command")
			return
		end
		
		vOutfit, vCategoryID = self:FindOutfitByName(vParameter)
		
		if not vOutfit then
			self:ErrorMessage("Couldn't find outfit named "..vParameter)
			return
		end
		
		vCommandInfo.func(self, vOutfit)
	else
		vCommandInfo.func(self, vParameter)
	end
end

function Outfitter:DisableAutoChanges()
	self:SetAutoSwitch(false)
	self:NoteMessage(self.cAutoChangesDisabled)
end

function Outfitter:EnableAutoChanges()
	self:SetAutoSwitch(true)
	self:NoteMessage(self.cAutoChangesEnabled)
end

function Outfitter:ShowCommandHelp()
	self:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/outfitter wear <outfit name>"..NORMAL_FONT_COLOR_CODE..": Wear an outfit")
	self:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/outfitter unwear <outfit name>"..NORMAL_FONT_COLOR_CODE..": Remove an outfit")
	self:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/outfitter toggle <outfit name>"..NORMAL_FONT_COLOR_CODE..": Wears or removes an outfit")
	self:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/outfitter reset"..NORMAL_FONT_COLOR_CODE..": Resets Outfitter, restoring default settings and outfits")
	self:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/outfitter sound [on|off]"..NORMAL_FONT_COLOR_CODE..": Turns equipment sound effects off during Outfitter's gear changes")
	self:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/outfitter disable"..NORMAL_FONT_COLOR_CODE..": Prevents all scripts from running")
	self:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/outfitter enable"..NORMAL_FONT_COLOR_CODE..": Allows enabled scripts to run")
	self:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/outfitter missing"..NORMAL_FONT_COLOR_CODE..": Generates a list of items which are in your outfits but can't be found")
end

function Outfitter:UnequipItemByName(pItemName)
	local vInventoryID = tonumber(pItemName)
	
	if pItemName  ~= tostring(vInventoryIDthen) then
		-- Search the inventory for a matching item name
		
		vInventoryID = nil
		
		for _, vInventorySlot in ipairs(self.cSlotNames) do
			local vCurrentItemInfo = self:GetInventoryItemInfo(vInventorySlot)
			
			if vCurrentItemInfo and strlower(vCurrentItemInfo.Name) == strlower(pItemName) then
				vInventoryID = self.cSlotIDs[vInventorySlot]
			end
		end
		
		if not vInventoryID then
			self:ErrorMessage("Couldn't find an item named "..pItemName)
		end
	end
	
	local vEmptyBagSlot = self:GetEmptyBagSlot(NUM_BAG_SLOTS, 1)
	
	if not vEmptyBagSlot then
		self:ErrorMessage("Couldn't unequip "..pItemName.." because all bags are full")
		return
	end
	
	PickupInventoryItem(vInventoryID)
	PickupContainerItem(vEmptyBagSlot.BagIndex, vEmptyBagSlot.BagSlotIndex)
end

function Outfitter:AskRebuildOutfit(pOutfit)
	self.OutfitToRebuild = pOutfit
	
	StaticPopup_Show("OUTFITTER_CONFIRM_REBUILD", self.OutfitToRebuild.Name)
end

function Outfitter:AskSetCurrent(pOutfit)
	self.OutfitToRebuild = pOutfit
	
	StaticPopup_Show("OUTFITTER_CONFIRM_SET_CURRENT", self.OutfitToRebuild.Name)
end

function Outfitter:RebuildOutfit(pOutfit)
	if not pOutfit then
		return
	end
	
	local vOutfit = self:GenerateSmartOutfit("temp", pOutfit.StatID, self.ItemList_GetEquippableItems(true))
	
	if vOutfit then
		pOutfit.Items = vOutfit.Items
		self:OutfitSettingsChanged(pOutfit)
		self:WearOutfit(pOutfit)
		self:Update(true)
	end
end

function Outfitter:SetOutfitToCurrent(pOutfit)
	if not pOutfit then
		return
	end
	
	for vSlotName in pairs(pOutfit.Items) do
		self:SetInventoryItem(pOutfit, vSlotName)
	end
	
	self:OutfitSettingsChanged(pOutfit)
	self:WearOutfit(pOutfit)
	
	self:Update(true)
end

function Outfitter:AskDeleteOutfit(pOutfit)
	gOutfitter_OutfitToDelete = pOutfit
	StaticPopup_Show("OUTFITTER_CONFIRM_DELETE", gOutfitter_OutfitToDelete.Name)
end

function Outfitter:DeleteSelectedOutfit()
	if not gOutfitter_OutfitToDelete then
		return
	end
	
	self:DeleteOutfit(gOutfitter_OutfitToDelete)
	
	self:Update(true)
end

function Outfitter:TalentsChanged()
	if self.PlayerClass == "WARRIOR" then
		local vNumTalents = GetNumTalents(2)
		
		for vTalentIndex = 1, vNumTalents do
			local vTalentName, vIconPath, vTier, vColumn, vCurrentRank, vMaxRank, vIsExceptional, vMeetsPrereq = GetTalentInfo(2, vTalentIndex)
			
			if vIconPath == "Interface\\Icons\\Ability_Warrior_TitansGrip" then
				--self:TestMessage("%s has %s points", vTalentName, vCurrentRank)
				
				self.CanDualWield2H = vCurrentRank == 1
				break
			end
		end
	else
		self.CanDualWield2H = false
	end
end

function Outfitter:SetScript(pOutfit, pScript)
	Outfitter:DeactivateScript(pOutfit)
	
	if pScript == "" then
		pScript = nil
	end
	
	pOutfit.Script = pScript
	pOutfit.ScriptID = nil
	
	Outfitter:OutfitSettingsChanged(Outfitter.SelectedOutfit)
	Outfitter:ActivateScript(pOutfit)
end

function Outfitter:SetScriptID(pOutfit, pScriptID)
	Outfitter:DeactivateScript(pOutfit)
	
	if pScriptID == "" then
		pScriptID = nil
	end
	
	pOutfit.Script = nil
	pOutfit.ScriptID = pScriptID
	
	Outfitter:OutfitSettingsChanged(Outfitter.SelectedOutfit)
	Outfitter:ActivateScript(pOutfit)
end

function Outfitter:GetScript(pOutfit)
	if pOutfit.ScriptID then
		local vPresetScript = Outfitter:GetPresetScriptByID(pOutfit.ScriptID)
		
		if vPresetScript then
			return vPresetScript.Script, pOutfit.ScriptID
		end
	else
		return pOutfit.Script
	end
end

function Outfitter:ShowPanel(pPanelIndex)
	self:CancelDialogs() -- Force any dialogs to close if they're open
	
	if Outfitter.CurrentPanel > 0
	and Outfitter.CurrentPanel ~= pPanelIndex then
		Outfitter:HidePanel(Outfitter.CurrentPanel)
	end
	
	-- NOTE: Don't check for redundant calls since this function
	-- will be called to reset the field values as well as to 
	-- actually show the panel when it's hidden
	
	Outfitter.CurrentPanel = pPanelIndex
	
	getglobal(Outfitter.cPanelFrames[pPanelIndex]):Show()
	
	PanelTemplates_SetTab(OutfitterFrame, pPanelIndex)
	
	-- Update the control values
	
	if pPanelIndex == 1 then
		-- Main panel
		
	elseif pPanelIndex == 2 then
		-- Options panel
		
	elseif pPanelIndex == 3 then
		-- About panel
		
	else
		Outfitter:ErrorMessage("Unknown index (%d) in ShowPanel()", pPanelIndex)
	end
	
	Outfitter:Update(false)
end

function Outfitter:HidePanel(pPanelIndex)
	if Outfitter.CurrentPanel ~= pPanelIndex then
		return
	end
	
	getglobal(Outfitter.cPanelFrames[pPanelIndex]):Hide()
	Outfitter.CurrentPanel = 0
end

function Outfitter:CancelDialogs()
end

function Outfitter:AddDividerMenuItem()
	UIDropDownMenu_AddButton({text = " ", notCheckable = true, notClickable = true}, UIDROPDOWNMENU_MENU_LEVEL)
end

function Outfitter:AddCategoryMenuItem(pName)
	UIDropDownMenu_AddButton({text = pName, notCheckable = true, notClickable = true}, UIDROPDOWNMENU_MENU_LEVEL)
end

function Outfitter:AddMenuItem(pFrame, pName, pValue, pChecked, pLevel, pColorCode, pDisabled, pAdditionalOptions)
	if not pColorCode then
		pColorCode = NORMAL_FONT_COLOR_CODE
	elseif type(pColorCode) ~= "string" then
		Outfitter:ErrorMessage("AddMenuItem: pColorCode is not a string")
		Outfitter:DebugStack()
		pColorCode = nil
	end
	
	local vDesc =
	{
		text = pName,
		checked = pChecked,
		arg1 = pFrame,
		arg2 = pValue,
		value = pValue,
		func = Outfitter.DropDown_OnClick,
		colorCode = pColorCode,
		disabled = pDisabled,
	}
	
	if pAdditionalOptions then
		for vKey, vValue in pairs(pAdditionalOptions) do
			vDesc[vKey] = vValue
		end
	end
	
	UIDropDownMenu_AddButton(vDesc, pLevel or UIDROPDOWNMENU_MENU_LEVEL)
end

function Outfitter:AddSubmenuItem(pFrame, pName, pValue, pDisabled, pAdditionalOptions)
	local vDesc =
	{
		text = pName,
		hasArrow = 1,
		arg1 = pFrame,
		arg2 = pValue,
		value = pValue,
		colorCode = NORMAL_FONT_COLOR_CODE,
		disabled = pDisabled,
	}
	
	if pAdditionalOptions then
		for vKey, vValue in pairs(pAdditionalOptions) do
			vDesc[vKey] = vValue
		end
	end
	
	UIDropDownMenu_AddButton(vDesc, UIDROPDOWNMENU_MENU_LEVEL)
end

function Outfitter:InitializeOutfitMenu(pFrame, pOutfit)
	if not pOutfit then
		return
	end
	
	if UIDROPDOWNMENU_MENU_LEVEL == 1 then
		self:AddCategoryMenuItem(pOutfit.Name)
		
		-- General
		
		Outfitter:AddMenuItem(pFrame, PET_RENAME, "RENAME")
		if pOutfit.StatID then
			local vStatName = Outfitter:GetStatIDName(pOutfit.StatID)
			
			if vStatName then
				Outfitter:AddMenuItem(pFrame, format(Outfitter.cRebuildOutfitFormat, vStatName), "REBUILD")
			end
		end
		Outfitter:AddMenuItem(pFrame, Outfitter.cSetCurrentItems, "SET_CURRENT")
		Outfitter:AddSubmenuItem(pFrame, Outfitter.cKeyBinding, "BINDING")
		Outfitter:AddSubmenuItem(pFrame, Outfitter.cOutfitDisplay, "DISPLAY")
		Outfitter:AddSubmenuItem(pFrame, Outfitter.cBankCategoryTitle, "BANKING")
		if pOutfit.CategoryID ~= "Complete" then
			Outfitter:AddMenuItem(pFrame, Outfitter.cUnequipOthers, "UNEQUIP_OTHERS", pOutfit.UnequipOthers)
		end
		Outfitter:AddMenuItem(pFrame, DELETE, "DELETE")
		
		-- Automation
		
		Outfitter:AddCategoryMenuItem(Outfitter.cAutomation)
		
		local vPresetScript = Outfitter:GetPresetScriptByID(pOutfit.ScriptID)
		local vScriptName
		
		if vPresetScript then
			vScriptName = vPresetScript.Name
		elseif pOutfit.Script then
			vScriptName = Outfitter.cCustomScript
		else
			vScriptName = nil
		end
		
		Outfitter:AddSubmenuItem(pFrame, string.format(Outfitter.cScriptFormat, vScriptName or Outfitter.cNoScript), "SCRIPT")
		Outfitter:AddMenuItem(pFrame, Outfitter.cScriptSettings, "SCRIPT_SETTINGS", nil, UIDROPDOWNMENU_MENU_LEVEL, nil, vScriptName == nil)
		Outfitter:AddMenuItem(pFrame, Outfitter.cDisableScript, "DISABLE", pOutfit.Disabled, UIDROPDOWNMENU_MENU_LEVEL, nil, vScriptName == nil)
		Outfitter:AddMenuItem(pFrame, Outfitter.cDisableOutfitInCombat, "COMBATDISABLE", pOutfit.CombatDisabled, UIDROPDOWNMENU_MENU_LEVEL, nil, vScriptName == nil)
		
		-- Outfit bar
		
		if Outfitter.OutfitBar then
			Outfitter:AddCategoryMenuItem(Outfitter.cOutfitBar)
			Outfitter:AddMenuItem(pFrame, Outfitter.cShowInOutfitBar, "OUTFITBAR_SHOW", Outfitter.OutfitBar:IsOutfitShown(pOutfit), UIDROPDOWNMENU_MENU_LEVEL)
			Outfitter:AddMenuItem(pFrame, Outfitter.cChangeIcon, "OUTFITBAR_CHOOSEICON", nil, UIDROPDOWNMENU_MENU_LEVEL)
		end
		
	elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
		if UIDROPDOWNMENU_MENU_VALUE == "BANKING" then
			Outfitter:AddMenuItem(pFrame, Outfitter.cDepositToBank, "DEPOSIT", nil, UIDROPDOWNMENU_MENU_LEVEL, nil, not Outfitter.BankFrameIsOpen)
			Outfitter:AddMenuItem(pFrame, Outfitter.cDepositUniqueToBank, "DEPOSITUNIQUE", nil, UIDROPDOWNMENU_MENU_LEVEL, nil, not Outfitter.BankFrameIsOpen)
			Outfitter:AddMenuItem(pFrame, Outfitter.cWithdrawFromBank, "WITHDRAW", nil, UIDROPDOWNMENU_MENU_LEVEL, nil, not Outfitter.BankFrameIsOpen)
			
		elseif UIDROPDOWNMENU_MENU_VALUE == "BINDING" then
			Outfitter:AddMenuItem(pFrame, Outfitter.cNone, "BINDING_NONE", not pOutfit.BindingIndex, UIDROPDOWNMENU_MENU_LEVEL)
			
			for vIndex = 1, 10 do
				Outfitter:AddMenuItem(pFrame, getglobal("BINDING_NAME_OUTFITTER_OUTFIT"..vIndex), "BINDING_"..vIndex, pOutfit.BindingIndex == vIndex, UIDROPDOWNMENU_MENU_LEVEL)
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == "DISPLAY" then
			Outfitter:AddCategoryMenuItem(Outfitter.cHelm)
			Outfitter:AddMenuItem(pFrame, Outfitter.cDontChange, "IGNOREHELM", pOutfit.ShowHelm == nil, UIDROPDOWNMENU_MENU_LEVEL)
			Outfitter:AddMenuItem(pFrame, Outfitter.cShow, "SHOWHELM", pOutfit.ShowHelm == true, UIDROPDOWNMENU_MENU_LEVEL)
			Outfitter:AddMenuItem(pFrame, Outfitter.cHide, "HIDEHELM", pOutfit.ShowHelm == false, UIDROPDOWNMENU_MENU_LEVEL)
			
			Outfitter:AddCategoryMenuItem(Outfitter.cCloak)
			Outfitter:AddMenuItem(pFrame, Outfitter.cDontChange, "IGNORECLOAK", pOutfit.ShowCloak == nil, UIDROPDOWNMENU_MENU_LEVEL)
			Outfitter:AddMenuItem(pFrame, Outfitter.cShow, "SHOWCLOAK", pOutfit.ShowCloak == true, UIDROPDOWNMENU_MENU_LEVEL)
			Outfitter:AddMenuItem(pFrame, Outfitter.cHide, "HIDECLOAK", pOutfit.ShowCloak == false, UIDROPDOWNMENU_MENU_LEVEL)
			
			Outfitter:AddCategoryMenuItem(Outfitter.cPlayerTitle)
			
			local vNumTitles = GetNumTitles()
			
			Outfitter:AddMenuItem(pFrame, Outfitter.cDontChange, "IGNORETITLE", pOutfit.ShowTitleID == nil, UIDROPDOWNMENU_MENU_LEVEL)
			Outfitter:AddMenuItem(pFrame, NONE, "TITLE_-1", 0 == pOutfit.ShowTitleID, UIDROPDOWNMENU_MENU_LEVEL)
			
			for vTitleID = 1, vNumTitles do
				if IsTitleKnown(vTitleID) ~= 0 then
					Outfitter:AddMenuItem(pFrame, GetTitleName(vTitleID), "TITLE_"..vTitleID, vTitleID == pOutfit.ShowTitleID, UIDROPDOWNMENU_MENU_LEVEL)
				end
			end
			
		elseif UIDROPDOWNMENU_MENU_VALUE == "SCRIPT" then
			Outfitter:AddMenuItem(pFrame, Outfitter.cNoScript, "PRESET_NONE", pOutfit.ScriptID == nil and Outfitter:GetScript(pOutfit) == nil, UIDROPDOWNMENU_MENU_LEVEL)
			Outfitter:AddMenuItem(pFrame, Outfitter.cEditScriptEllide, "EDIT_SCRIPT", pOutfit.ScriptID == nil and Outfitter:GetScript(pOutfit) ~= nil, UIDROPDOWNMENU_MENU_LEVEL)
			
			local vCategory
			
			for _, vPresetScript in ipairs(Outfitter.PresetScripts) do
				if not vPresetScript.Class
				or vPresetScript.Class == Outfitter.PlayerClass then
					-- Start a new category if it's changing
					
					local vNewCategory = vPresetScript.Category or vPresetScript.Class or "GENERAL"
					
					if vCategory ~= vNewCategory then
						vCategory = vNewCategory
						Outfitter:AddSubmenuItem(pFrame, Outfitter.cScriptCategoryName[vCategory] or Outfitter.cClassName[vCategory], vCategory)
					end
				end
			end
		end
	elseif UIDROPDOWNMENU_MENU_LEVEL == 3 then
		for _, vPresetScript in ipairs(Outfitter.PresetScripts) do
			if not vPresetScript.Class
			or vPresetScript.Class == Outfitter.PlayerClass then
				local vCategory = vPresetScript.Category or vPresetScript.Class or "GENERAL"
				
				if vCategory == UIDROPDOWNMENU_MENU_VALUE then
					local vName = vPresetScript.Name
					local vScriptFields = Outfitter:ParseScriptFields(vPresetScript.Script)
					
					if vScriptFields.Inputs ~= nil and #vScriptFields.Inputs ~= 0 then
						vName = vName.."..."
					end
					
					Outfitter:AddMenuItem(
							pFrame,
							vName,
							"PRESET_"..vPresetScript.ID,
							pOutfit.ScriptID == vPresetScript.ID,
							nil, -- Level
							nil, -- Color
							nil, -- Disabled
							{tooltipTitle = vName, tooltipText = vScriptFields.Description})
				end
			end
		end
	end
end

function Outfitter.ItemDropDown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	local vItem = vFrame:GetParent():GetParent()
	local vOutfit = Outfitter:GetOutfitFromListItem(vItem)
	
	Outfitter:InitializeOutfitMenu(vFrame, vOutfit)
	
	vFrame:SetHeight(vFrame.SavedHeight)
end

function Outfitter:SetAutoSwitch(pAutoSwitch)
	local vDisableAutoSwitch = not pAutoSwitch
	
	if self.Settings.Options.DisableAutoSwitch == vDisableAutoSwitch then
		return
	end
	
	self.Settings.Options.DisableAutoSwitch = vDisableAutoSwitch
	
	if pAutoSwitch then
		Outfitter:ActivateAllScripts()
	else
		Outfitter:DeactivateAllScripts()
	end
	
	Outfitter.DisplayIsDirty = true
	Outfitter:Update(false)
end

function Outfitter:SetShowTooltipInfo(pShowInfo)
	self.Settings.Options.DisableToolTipInfo = not pShowInfo
	Outfitter:Update(false)
end

function Outfitter:SetShowMinimapButton(pShowButton)
	self.Settings.Options.HideMinimapButton = not pShowButton
	
	if self.Settings.Options.HideMinimapButton then
		OutfitterMinimapButton:Hide()
	else
		OutfitterMinimapButton:Show()
	end
	
	Outfitter:Update(false)
end

function Outfitter:SetShowHotkeyMessages(pShowHotkeyMessages)
	self.Settings.Options.DisableHotkeyMessages = not pShowHotkeyMessages
	
	Outfitter:Update(false)
end

function Outfitter.UIDropDownMenu_SetAnchor(...) UIDropDownMenu_SetAnchor(...) end

function Outfitter.MinimapDropDown_OnLoad(self)
	Outfitter.UIDropDownMenu_SetAnchor(self, 3, -7, "TOPRIGHT", self:GetName(), "TOPLEFT")
	Outfitter:DropDownMenu_Initialize(self, Outfitter.MinimapDropDown_Initialize)
	--self:Refresh() -- Don't refresh on menus which don't have a text portion
	
	if not Outfitter.RegisteredMinimapEvents then
		Outfitter:RegisterOutfitEvent("WEAR_OUTFIT", Outfitter.MinimapDropDown_OutfitEvent)
		Outfitter:RegisterOutfitEvent("UNWEAR_OUTFIT", Outfitter.MinimapDropDown_OutfitEvent)
		
		Outfitter.RegisteredMinimapEvents = true
	end
end

function Outfitter.MinimapDropDown_OutfitEvent(pEvent, pParameter1, pParameter2)
	MCSchedulerLib:ScheduleUniqueTask(0.1, Outfitter.MinimapDropDown_OutfitEvent2)
end

function Outfitter.MinimapDropDown_OutfitEvent2()
	if UIDROPDOWNMENU_OPEN_MENU ~= "OutfitterMinimapButton" then
		return
	end
	
	Outfitter:DropDownMenu_Initialize(OutfitterMinimapButton, Outfitter.MinimapDropDown_Initialize)
end

function Outfitter.MinimapDropDown_AdjustScreenPosition(pMenu)
	local vListFrame = getglobal("DropDownList1")
	
	if not vListFrame:IsVisible() then
		return
	end
	
	local vCenterX, vCenterY = pMenu:GetCenter()
	local vScreenWidth, vScreenHeight = GetScreenWidth(), GetScreenHeight()
	
	local vAnchor
	local vOffsetX, vOffsetY
	
	if vCenterY < vScreenHeight / 2 then
		vAnchor = "BOTTOM"
		vOffsetY = -8
	else
		vAnchor = "TOP"
		vOffsetY = -17
	end
	
	if vCenterX < vScreenWidth / 2 then
		vAnchor = vAnchor.."LEFT"
		vOffsetX = 21
	else
		vAnchor = vAnchor.."RIGHT"
		vOffsetX = 3
	end
	
	vListFrame:ClearAllPoints()
	vListFrame:SetPoint(vAnchor, pMenu.relativeTo, pMenu.relativePoint, vOffsetX, vOffsetY)
end

function Outfitter:OutfitIsVisible(pOutfit)
	return not pOutfit.Disabled
	   and not Outfitter:IsEmptyOutfit(pOutfit)
end

function Outfitter:HasVisibleOutfits(pOutfits)
	if not pOutfits then
		return false
	end
	
	for vIndex, vOutfit in pairs(pOutfits) do
		if Outfitter:OutfitIsVisible(vOutfit) then	
			return true
		end
	end
	
	return false
end

function Outfitter.MinimapDropDown_Initialize()
	-- Just return if not initialized yet
	
	if not Outfitter.Initialized then
		return
	end
	
	--
	
	local vFrame = _G[UIDROPDOWNMENU_INIT_MENU]
	
	Outfitter:AddCategoryMenuItem(Outfitter.cTitleVersion)
	Outfitter:AddMenuItem(vFrame, Outfitter.cOpenOutfitter, 0)
	Outfitter:AddMenuItem(vFrame, Outfitter.cAutoSwitch, -1, Outfitter.Settings.Options.DisableAutoSwitch)
	
	Outfitter.MinimapDropDown_InitializeOutfitList()
end

function Outfitter:GetCategoryOrder()
	return Outfitter.cCategoryOrder
end

function Outfitter:GetOutfitsByCategoryID(pCategoryID)
	return self.Settings.Outfits[pCategoryID]
end

function Outfitter.MinimapDropDown_InitializeOutfitList()
	-- Just return if not initialized yet
	
	if not Outfitter.Initialized then
		return
	end
	
	--
	
	local vFrame = _G[UIDROPDOWNMENU_INIT_MENU]
	local vEquippableItems = Outfitter.ItemList_GetEquippableItems()
	local vCategoryOrder = Outfitter:GetCategoryOrder()
		
	for vCategoryIndex, vCategoryID in ipairs(vCategoryOrder) do
		local vCategoryName = Outfitter["c"..vCategoryID.."Outfits"]
		local vOutfits = Outfitter:GetOutfitsByCategoryID(vCategoryID)

		if Outfitter:HasVisibleOutfits(vOutfits) then
			Outfitter:AddCategoryMenuItem(vCategoryName)
			
			for vIndex, vOutfit in ipairs(vOutfits) do
				if Outfitter:OutfitIsVisible(vOutfit) then
					local vWearingOutfit = Outfitter:WearingOutfit(vOutfit)
					local vMissingItems, vBankedItems = Outfitter.ItemList_GetMissingItems(vEquippableItems, vOutfit)
					local vItemColor = NORMAL_FONT_COLOR_CODE
					
					if vMissingItems then
						vItemColor = RED_FONT_COLOR_CODE
					elseif vBankedItems then
						vItemColor = Outfitter.BANKED_FONT_COLOR_CODE
					end
					
					Outfitter:AddMenuItem(vFrame, vOutfit.Name, {CategoryID = vCategoryID, Index = vIndex}, vWearingOutfit, nil, vItemColor)
				end
			end
		end
	end
end

function Outfitter.DropDown_OnClick(pItem, pOwner, pValue)
	if pOwner.AutoSetValue then
		pOwner:SetSelectedValue(pValue)
	end
	
	if pOwner.ChangedValueFunc then
		pOwner.ChangedValueFunc(pOwner, pValue)
	end
	
	CloseDropDownMenus()
end

function Outfitter.Item_SetTextColor(pItem, pRed, pGreen, pBlue)
	local vItemNameField
	
	if pItem.isCategory then
		vItemNameField = getglobal(pItem:GetName().."CategoryName")
	else
		vItemNameField = getglobal(pItem:GetName().."OutfitName")
	end
	
	vItemNameField:SetTextColor(pRed, pGreen, pBlue)
end

function Outfitter:GenerateItemListString(pLabel, pListColorCode, pItems)
	local vItemList = nil

	for vIndex, vOutfitItem in ipairs(pItems) do
		if not vItemList then
			vItemList = HIGHLIGHT_FONT_COLOR_CODE..pLabel..pListColorCode..vOutfitItem.Name
		else
			vItemList = vItemList..Outfitter.cMissingItemsSeparator..vOutfitItem.Name
		end
	end
	
	return vItemList
end

function Outfitter.AddNewbieTip(pItem, pNormalText, pRed, pGreen, pBlue, pNewbieText, pNoNormalText)
	if SHOW_NEWBIE_TIPS == "1" then
		GameTooltip_SetDefaultAnchor(GameTooltip, pItem)
		if pNormalText then
			GameTooltip:SetText(pNormalText, pRed, pGreen, pBlue)
			GameTooltip:AddLine(pNewbieText, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		else
			GameTooltip:SetText(pNewbieText, pRed, pGreen, pBlue, 1, 1)
		end
		GameTooltip:Show()
	else
		if not pNoNormalText then
			GameTooltip:SetOwner(pItem, "ANCHOR_RIGHT")
			GameTooltip:SetText(pNormalText, pRed, pGreen, pBlue)
		end
	end
end

function Outfitter.Item_OnEnter(pItem)
	Outfitter.Item_SetTextColor(pItem, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	
	if pItem.isCategory then
		local vDescription = Outfitter.cCategoryDescriptions[pItem.categoryID]
		
		if vDescription then
			local vCategoryName = Outfitter["c"..pItem.categoryID.."Outfits"]
			
			Outfitter.AddNewbieTip(pItem, vCategoryName, 1.0, 1.0, 1.0, vDescription, 1)
		end
		
		ResetCursor()
	elseif pItem.isOutfitItem then
		local vHasCooldown, vRepairCost
		
		GameTooltip:SetOwner(pItem, "ANCHOR_TOP")
		
		if pItem.outfitItem.Location.SlotName then
			if not pItem.outfitItem.Location.SlotID then
				pItem.outfitItem.Location.SlotID = Outfitter.cSlotIDs[pItem.outfitItem.Location.SlotName]
			end
			
			GameTooltip:SetInventoryItem("player", pItem.outfitItem.Location.SlotID)
		else
			vHasCooldown, vRepairCost = GameTooltip:SetBagItem(pItem.outfitItem.Location.BagIndex, pItem.outfitItem.Location.BagSlotIndex)
		end
		
		GameTooltip:Show()

		if InRepairMode() and (vRepairCost and vRepairCost > 0) then
			GameTooltip:AddLine(TEXT(REPAIR_COST), "", 1, 1, 1)
			SetTooltipMoney(GameTooltip, vRepairCost)
			GameTooltip:Show()
		elseif MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 then
			if pItem.outfitItem.Location.BagIndex then
				ShowContainerSellCursor(pItem.outfitItem.Location.BagIndex, pItem.outfitItem.Location.BagSlotIndex)
			end
		else
			ResetCursor()
		end
	else
		local vOutfit = Outfitter:GetOutfitFromListItem(pItem)
		
		Outfitter:ShowOutfitTooltip(vOutfit, pItem, pItem.MissingItems, pItem.BankedItems)
	end
end

function Outfitter:ShowOutfitTooltip(pOutfit, pOwner, pMissingItems, pBankedItems, pShowEmptyTooltips, pTooltipAnchor)
	-- local vEquippableItems = Outfitter.ItemList_GetEquippableItems()
	-- local vMissingItems, vBankedItems = Outfitter.ItemList_GetMissingItems(vEquippableItems, pOutfit)
	
	local vDescription = Outfitter:GetOutfitDescription(pOutfit)
	
	if pMissingItems
	or pBankedItems
	or pShowEmptyTooltips then
		GameTooltip:SetOwner(pOwner, pTooltipAnchor or "ANCHOR_LEFT")
		
		GameTooltip:AddLine(pOutfit.Name)
		
		if vDescription then
			GameTooltip:AddLine(vDescription, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
		end
		
		if pMissingItems then
			local vItemList = Outfitter:GenerateItemListString(Outfitter.cMissingItemsLabel, RED_FONT_COLOR_CODE, pMissingItems)
			GameTooltip:AddLine(vItemList, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
		end
		
		if pBankedItems then
			local vItemList = Outfitter:GenerateItemListString(Outfitter.cBankedItemsLabel, Outfitter.BANKED_FONT_COLOR_CODE, pBankedItems)
			GameTooltip:AddLine(vItemList, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
		end
		
		GameTooltip:Show()
	elseif vDescription then
		Outfitter.AddNewbieTip(pOwner, pOutfit.Name, 1.0, 1.0, 1.0, vDescription, 1)
	end
	
	ResetCursor()
end

function Outfitter:GetOutfitDescription(pOutfit)
	return Outfitter:GetScriptDescription(Outfitter:GetScript(pOutfit))
end

function Outfitter:OutfitHasSettings(pOutfit)
	return Outfitter:ScriptHasSettings(Outfitter:GetScript(pOutfit))
end

function Outfitter.Item_OnLeave(pItem)
	if pItem.isCategory then
		Outfitter.Item_SetTextColor(pItem, 1, 1, 1)
	else
		Outfitter.Item_SetTextColor(pItem, pItem.DefaultColor.r, pItem.DefaultColor.g, pItem.DefaultColor.b)
	end
	
	GameTooltip:Hide()
end

function Outfitter.Item_OnClick(pItem, pButton, pIgnoreModifiers)
	if pItem.isCategory then
		local vCategoryOutfits = Outfitter.Settings.Outfits[pItem.categoryID]
		
		Outfitter.Collapsed[pItem.categoryID] = not Outfitter.Collapsed[pItem.categoryID]
		Outfitter.DisplayIsDirty = true
	elseif pItem.isOutfitItem then
		if pButton == "LeftButton" then
			Outfitter:PickupItemLocation(pItem.outfitItem.Location)
			StackSplitFrame:Hide()
		else
			if MerchantFrame:IsShown() and MerchantFrame.selectedTab == 2 then
				-- Don't sell the item if the buyback tab is selected
				return
			else
				if pItem.outfitItem.Location.BagIndex then
					UseContainerItem(pItem.outfitItem.Location.BagIndex, pItem.outfitItem.Location.BagSlotIndex)
					StackSplitFrame:Hide()
				end
			end
		end
	else
		local vOutfit = Outfitter:GetOutfitFromListItem(pItem)
		
		if not vOutfit then
			-- Error: outfit not found
			return
		end
		
		if pButton == "LeftButton" then
			vOutfit.Disabled = nil
			Outfitter:WearOutfit(vOutfit)
		else
			if DropDownList1:IsShown() then
				ToggleDropDownMenu(nil, nil, pItem.OutfitMenu)
			else
				ToggleDropDownMenu(nil, nil, pItem.OutfitMenu, "cursor")
				PlaySound("igMainMenuOptionCheckBoxOn")
			end
		end
	end
	
	Outfitter:Update(true)
end

function Outfitter.Item_CheckboxClicked(pItem)
	if pItem.isCategory then
		return
	end
	
	local vOutfits = Outfitter.Settings.Outfits[pItem.categoryID]
	
	if not vOutfits then
		-- Error: outfit category not found
		return
	end
	
	local vOutfit = vOutfits[pItem.outfitIndex]
	
	if not vOutfit then
		-- Error: outfit not found
		return
	end
	
	local vCheckbox = getglobal(pItem:GetName().."OutfitSelected")
	
	if vCheckbox:GetChecked() then
		vOutfit.Disabled = nil
		Outfitter:WearOutfit(vOutfit)
	else
		Outfitter:RemoveOutfit(vOutfit)
	end
	
	Outfitter:Update(true)
end

function Outfitter.Item_SetToOutfit(pItemIndex, pOutfit, pCategoryID, pOutfitIndex, pEquippableItems)
	local vItemName = "OutfitterItem"..pItemIndex
	local vItem = getglobal(vItemName)
	local vOutfitFrameName = vItemName.."Outfit"
	local vOutfitFrame = getglobal(vOutfitFrameName)
	local vItemFrame = getglobal(vItemName.."Item")
	local vCategoryFrame = getglobal(vItemName.."Category")
	local vMissingItems, vBankedItems = Outfitter.ItemList_GetMissingItems(pEquippableItems, pOutfit)
	
	vOutfitFrame:Show()
	vCategoryFrame:Hide()
	vItemFrame:Hide()
	
	local vItemSelectedCheckmark = getglobal(vOutfitFrameName.."Selected")
	local vItemNameField = getglobal(vOutfitFrameName.."Name")
	local vItemMenu = getglobal(vOutfitFrameName.."Menu")
	
	vItemSelectedCheckmark:Show()
	
	if Outfitter:WearingOutfit(pOutfit) then
		vItemSelectedCheckmark:SetChecked(true)
	else
		vItemSelectedCheckmark:SetChecked(nil)
	end
	
	vItem.MissingItems = vMissingItems
	vItem.BankedItems = vBankedItems
	
	if pOutfit.Disabled then
		vItemNameField:SetText(format(Outfitter.cDisabledOutfitName, pOutfit.Name))
		vItem.DefaultColor = GRAY_FONT_COLOR
	else
		vItemNameField:SetText(pOutfit.Name)
		if vMissingItems then
			vItem.DefaultColor = RED_FONT_COLOR
		elseif vBankedItems then
			vItem.DefaultColor = Outfitter.BANKED_FONT_COLOR
		else
			vItem.DefaultColor = NORMAL_FONT_COLOR
		end
	end
	
	vItemNameField:SetTextColor(vItem.DefaultColor.r, vItem.DefaultColor.g, vItem.DefaultColor.b)
	
	vItemMenu:Show()
	
	vItem.isCategory = false
	vItem.isOutfitItem = false
	vItem.outfitItem = nil
	vItem.categoryID = pOutfit.CategoryID
	vItem.outfitIndex = pOutfitIndex
	
	vItem:Show()
	
	-- Show the script icon if there's one attached
	
	local vScriptIcon = getglobal(vOutfitFrameName.."ScriptIcon")
	
	if pOutfit.ScriptID or pOutfit.Script then
		vScriptIcon:SetTexture("Interface\\Addons\\Outfitter\\Textures\\Gear")
		
		if Outfitter.Settings.Options.DisableAutoSwitch or pOutfit.Disabled then
			vScriptIcon:SetVertexColor(0.4, 0.4, 0.4)
		else
			vScriptIcon:SetVertexColor(1, 1, 1)
		end

		vScriptIcon:Show()
	else
		vScriptIcon:Hide()
	end
	
	-- Update the highlighting
	
	if Outfitter.SelectedOutfit == pOutfit then
		OutfitterMainFrameHighlight:SetPoint("TOPLEFT", vItem, "TOPLEFT", 0, 0)
		OutfitterMainFrameHighlight:Show()
	end
end

function Outfitter.Item_SetToItem(pItemIndex, pOutfitItem)
	local vItemName = "OutfitterItem"..pItemIndex
	local vItem = getglobal(vItemName)
	local vCategoryFrameName = vItemName.."Category"
	local vItemFrameName = vItemName.."Item"
	local vItemFrame = getglobal(vItemFrameName)
	local vOutfitFrame = getglobal(vItemName.."Outfit")
	local vCategoryFrame = getglobal(vCategoryFrameName)
	
	vItem.isOutfitItem = true
	vItem.isCategory = false
	vItem.outfitItem = pOutfitItem
	
	vItemFrame:Show()
	vOutfitFrame:Hide()
	vCategoryFrame:Hide()

	local vItemNameField = getglobal(vItemFrameName.."Name")
	local vItemIcon = getglobal(vItemFrameName.."Icon")
	
	vItemNameField:SetText(pOutfitItem.Name)
	
	if pOutfitItem.Quality then
		vItem.DefaultColor = ITEM_QUALITY_COLORS[pOutfitItem.Quality]
	else
		vItem.DefaultColor = GRAY_FONT_COLOR
	end
	
	if pOutfitItem.Texture then
		vItemIcon:SetTexture(pOutfitItem.Texture)
		vItemIcon:Show()
	else
		vItemIcon:Hide()
	end
	
	vItemNameField:SetTextColor(vItem.DefaultColor.r, vItem.DefaultColor.g, vItem.DefaultColor.b)
	
	vItem:Show()
end

function Outfitter.Item_SetToCategory(pItemIndex, pCategoryID)
	local vCategoryName = Outfitter["c"..pCategoryID.."Outfits"]
	local vItemName = "OutfitterItem"..pItemIndex
	local vItem = getglobal(vItemName)
	local vCategoryFrameName = vItemName.."Category"
	local vOutfitFrame = getglobal(vItemName.."Outfit")
	local vItemFrame = getglobal(vItemName.."Item")
	local vCategoryFrame = getglobal(vCategoryFrameName)
	
	vOutfitFrame:Hide()
	vCategoryFrame:Show()
	vItemFrame:Hide()
	
	local vItemNameField = getglobal(vCategoryFrameName.."Name")
	local vExpandButton = getglobal(vCategoryFrameName.."Expand")
	
	vItem.MissingItems = nil
	vItem.BankedItems = nil
	
	if Outfitter.Collapsed[pCategoryID] then
		vExpandButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
	else
		vExpandButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
	end
	
	vItemNameField:SetText(vCategoryName)
	
	vItem.isCategory = true
	vItem.isOutfitItem = false
	vItem.outfitItem = nil
	vItem.categoryID = pCategoryID
	
	vItem:Show()
end

function Outfitter:AddOutfitsToList(pOutfits, pCategoryID, pItemIndex, pFirstItemIndex, pEquippableItems)
	local vOutfits = pOutfits[pCategoryID]
	local vItemIndex = pItemIndex
	local vFirstItemIndex = pFirstItemIndex
	
	if vFirstItemIndex == 0 then
		Outfitter.Item_SetToCategory(vItemIndex, pCategoryID, false)
		vItemIndex = vItemIndex + 1
	else
		vFirstItemIndex = vFirstItemIndex - 1
	end

	if vItemIndex >= Outfitter.cMaxDisplayedItems then
		return vItemIndex, vFirstItemIndex
	end

	if not Outfitter.Collapsed[pCategoryID]
	and vOutfits then
		for vIndex, vOutfit in ipairs(vOutfits) do
			if vFirstItemIndex == 0 then
				Outfitter.Item_SetToOutfit(vItemIndex, vOutfit, pCategoryID, vIndex, pEquippableItems)
				vItemIndex = vItemIndex + 1
				
				if vItemIndex >= Outfitter.cMaxDisplayedItems then
					return vItemIndex, vFirstItemIndex
				end
			else
				vFirstItemIndex = vFirstItemIndex - 1
			end
		end
	end
	
	return vItemIndex, vFirstItemIndex
end

function Outfitter:AddOutfitItemsToList(pOutfitItems, pCategoryID, pItemIndex, pFirstItemIndex)
	local vItemIndex = pItemIndex
	local vFirstItemIndex = pFirstItemIndex
	
	if vFirstItemIndex == 0 then
		Outfitter.Item_SetToCategory(vItemIndex, pCategoryID, false)
		vItemIndex = vItemIndex + 1
	else
		vFirstItemIndex = vFirstItemIndex - 1
	end

	if vItemIndex >= Outfitter.cMaxDisplayedItems then
		return vItemIndex, vFirstItemIndex
	end

	if not Outfitter.Collapsed[pCategoryID] then
		for vIndex, vOutfitItem in ipairs(pOutfitItems) do
			if vFirstItemIndex == 0 then
				Outfitter.Item_SetToItem(vItemIndex, vOutfitItem)
				vItemIndex = vItemIndex + 1
				
				if vItemIndex >= Outfitter.cMaxDisplayedItems then
					return vItemIndex, vFirstItemIndex
				end
			else
				vFirstItemIndex = vFirstItemIndex - 1
			end
		end
	end
	
	return vItemIndex, vFirstItemIndex
end

function Outfitter:SortOutfits()
	for vCategoryID, vOutfits in pairs(self.Settings.Outfits) do
		table.sort(vOutfits, Outfiter_CompareOutfitNames)
	end
end

function Outfiter_CompareOutfitNames(pOutfit1, pOutfit2)
	return pOutfit1.Name < pOutfit2.Name
end

function Outfitter:Update(pOutfitsChanged)
	-- Flush the caches
	
	if pOutfitsChanged then
		self:EraseTable(self.OutfitInfoCache)
	end
	
	--
	
	if not OutfitterFrame:IsVisible() then
		return
	end
	
	if self.CurrentPanel == 1 then
		-- Main panel
		
		if not self.DisplayIsDirty then
			return
		end
		
		self.DisplayIsDirty = false
		
		-- Sort the outfits
		
		self:SortOutfits()
		
		-- Get the equippable items so outfits can be marked if they're missing anything
		
		local vEquippableItems = self.ItemList_GetEquippableItems()
		
		-- Update the slot enables if they're shown
		
		if pOutfitsChanged
		and OutfitterSlotEnables:IsVisible() then
			self:UpdateSlotEnables(self.SelectedOutfit, vEquippableItems)
		end
		
		self.ItemList_CompiledUnusedItemsList(vEquippableItems)
		
		-- Update the list
		
		OutfitterMainFrameHighlight:Hide()
		
		local vFirstItemIndex = FauxScrollFrame_GetOffset(OutfitterMainFrameScrollFrame)
		local vItemIndex = 0
		
		self.ItemList_ResetIgnoreItemFlags(vEquippableItems)
		
		for vCategoryIndex, vCategoryID in ipairs(self.cCategoryOrder) do
			vItemIndex, vFirstItemIndex = self:AddOutfitsToList(self.Settings.Outfits, vCategoryID, vItemIndex, vFirstItemIndex, vEquippableItems)
			
			if vItemIndex >= self.cMaxDisplayedItems then
				break
			end
		end
		
		if vItemIndex < self.cMaxDisplayedItems
		and vEquippableItems.UnusedItems then
			vItemIndex, vFirstItemIndex = self:AddOutfitItemsToList(vEquippableItems.UnusedItems, "OddsNEnds", vItemIndex, vFirstItemIndex)
		end
		
		-- Hide any unused items
		
		for vItemIndex2 = vItemIndex, (self.cMaxDisplayedItems - 1) do
			local vItemName = "OutfitterItem"..vItemIndex2
			local vItem = getglobal(vItemName)
			
			vItem:Hide()
		end
		
		local vTotalNumItems = 0
		
		for vCategoryIndex, vCategoryID in ipairs(self.cCategoryOrder) do
			vTotalNumItems = vTotalNumItems + 1
			
			local vOutfits = self.Settings.Outfits[vCategoryID]
			
			if not self.Collapsed[vCategoryID]
			and vOutfits then
				vTotalNumItems = vTotalNumItems + #vOutfits
			end
		end
		
		if vEquippableItems.UnusedItems then
			vTotalNumItems = vTotalNumItems + 1
			
			if not self.Collapsed["OddsNEnds"] then
				vTotalNumItems = vTotalNumItems + #vEquippableItems.UnusedItems
			end
		end
		
		FauxScrollFrame_Update(
				OutfitterMainFrameScrollFrame,
				vTotalNumItems,                 -- numItems
				self.cMaxDisplayedItems,        -- numToDisplay
				18,                             -- valueStep
				nil, nil, nil,                  -- button, smallWidth, bigWidth
				nil,                            -- highlightFrame
				0, 0)                           -- smallHighlightWidth, bigHighlightWidth
	elseif self.CurrentPanel == 2 then -- Options panel
		OutfitterAutoSwitch:SetChecked(self.Settings.Options.DisableAutoSwitch)
		OutfitterShowMinimapButton:SetChecked(not self.Settings.Options.HideMinimapButton)
		OutfitterTooltipInfo:SetChecked(not self.Settings.Options.DisableToolTipInfo)
		OutfitterShowHotkeyMessages:SetChecked(not self.Settings.Options.DisableHotkeyMessages)
		OutfitterShowOutfitBar:SetChecked(self.Settings.OutfitBar.ShowOutfitBar)
	end
end

function Outfitter.OnVerticalScroll(pScrollFrame)
	Outfitter.DisplayIsDirty = true
	Outfitter:Update(false)
end

function Outfitter:SelectOutfit(pOutfit)
	if not self:IsOpen() then
		return
	end
	
	self.SelectedOutfit = pOutfit
	
	-- Get the equippable items so outfits can be marked if they're missing anything
	
	local vEquippableItems = self.ItemList_GetEquippableItems()
	
	-- Update the slot enables
	
	self:UpdateSlotEnables(pOutfit, vEquippableItems)
	OutfitterSlotEnables:Show()
	
	-- Done, rebuild the list
	
	self.DisplayIsDirty = true
end

function Outfitter:UpdateSlotEnables(pOutfit, pEquippableItems)
	if UnitHasRelicSlot("player") then
		OutfitterEnableAmmoSlot:Hide()
	else
		OutfitterEnableAmmoSlot:Show()
	end
	
	for _, vInventorySlot in ipairs(Outfitter.cSlotNames) do
		local vOutfitItem = pOutfit.Items[vInventorySlot]
		local vCheckbox = getglobal("OutfitterEnable"..vInventorySlot)
		
		if not vOutfitItem then
			vCheckbox:SetChecked(false)
		else
			if Outfitter.ItemList_InventorySlotContainsItem(pEquippableItems, vInventorySlot, vOutfitItem) then
				vCheckbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
				vCheckbox.IsUnknown = false
			else
				vCheckbox:SetCheckedTexture("Interface\\Addons\\Outfitter\\Textures\\CheckboxUnknown")
				vCheckbox.IsUnknown = true
			end
			
			vCheckbox:SetChecked(true)
		end
	end
end

function Outfitter:ClearSelection()
	Outfitter.SelectedOutfit = nil
	Outfitter.DisplayIsDirty = true
	OutfitterSlotEnables:Hide()
end

function Outfitter:FindOutfitItemIndex(pOutfit)
	local vOutfitCategoryID, vOutfitIndex = Outfitter:FindOutfit(pOutfit)
	
	if not vOutfitCategoryID then
		return nil
	end
	
	local vItemIndex = 0
	
	for vCategoryIndex, vCategoryID in ipairs(Outfitter.cCategoryOrder) do
		vItemIndex = vItemIndex + 1
		
		if not Outfitter.Collapsed[vCategoryID] then
			if vOutfitCategoryID == vCategoryID then
				return vItemIndex + vOutfitIndex - 1
			else
				vItemIndex = vItemIndex + #self.Settings.Outfits[vCategoryID]
			end
		end
	end
	
	return nil
end

function Outfitter:WearOutfitByName(pOutfitName, pLayerID)
	vOutfit = Outfitter:FindOutfitByName(pOutfitName)
	
	if not vOutfit then
		Outfitter:ErrorMessage("Couldn't find outfit named %s", pOutfitName)
		return
	end
	
	self:WearOutfit(vOutfit, pLayerID)
end

function Outfitter:RemoveOutfitByName(pOutfitName, pLayerID)
	vOutfit = Outfitter:FindOutfitByName(pOutfitName)
	
	if not vOutfit then
		Outfitter:ErrorMessage("Couldn't find outfit named %s", pOutfitName)
		return
	end
	
	self:RemoveOutfit(vOutfit)
end

function Outfitter:WearOutfitNow(pOutfit, pLayerID, pCallerIsScript)
	self:BeginEquipmentUpdate()
	self:WearOutfit(pOutfit, pLayerID, pCallerIsScript)
	self:EndEquipmentUpdate(nil, true)
end

function Outfitter:WearOutfit(pOutfit, pLayerID, pCallerIsScript)
	self:BeginEquipmentUpdate()
	
	-- Update the equipment
	
	pOutfit.didEquip = pCallerIsScript
	pOutfit.didUnequip = false
	
	self.EquippedNeedsUpdate = true
	self.WeaponsNeedUpdate = true
	
	-- Add the outfit to the stack
	
	if pOutfit.CategoryID == "Complete" then
		self.OutfitStack:Clear()
	elseif pOutfit.UnequipOthers then
		self.OutfitStack:ClearCategory("Accessory")
	end
	
	self.OutfitStack:AddOutfit(pOutfit, pLayerID)
	
	-- If it's a Complete outfit, push it onto the list of recent complete outfits
	
	if pOutfit.CategoryID == "Complete" and pOutfit.Name then
		for vRecentIndex, vRecentName in ipairs(self.Settings.RecentCompleteOutfits) do
			if vRecentName == pOutfit.Name then
				table.remove(self.Settings.RecentCompleteOutfits, vRecentIndex)
				break
			end
		end
		
		table.insert(self.Settings.RecentCompleteOutfits, pOutfit.Name)
	end
	
	-- If Outfitter is open then also select the outfit.  This is important
	-- because the UI can't function correctly if the selected outfit and
	-- top outfit don't stay the same.
	
	if self:IsOpen() then
		if self.OutfitStack:IsTopmostOutfit(pOutfit) then
			self:SelectOutfit(pOutfit)
		else
			self:ClearSelection()
		end
	end
	
	self:EndEquipmentUpdate("Outfitter:WearOutfit")
end

function Outfitter:RemoveOutfitNow(pOutfit, pCallerIsScript)
	self:BeginEquipmentUpdate()
	self:RemoveOutfit(pOutfit, pCallerIsScript)
	self:EndEquipmentUpdate(nil, true)
end


function Outfitter:RemoveOutfit(pOutfit, pCallerIsScript)
	-- HACK: Disabling the unequipping of Complete outfits to see it works better
	-- for more end-user situations
	
	-- UPDATE: It doesn't :(  Stealth, riding and other gear as Complete outfits
	-- fail to unequip
	
	--if pOutfit.CategoryID == "Complete" then
	--	return
	--end
	
	-- Remove it from the stack
	
	if not self.OutfitStack:RemoveOutfit(pOutfit) then
		return
	end
	
	-- If it's a Complete outfit, move it to the bottom of the list of recent complete outfits
	
	if pOutfit.CategoryID == "Complete" and pOutfit.Name then
		for vRecentIndex, vRecentName in ipairs(self.Settings.RecentCompleteOutfits) do
			if vRecentName == pOutfit.Name then
				table.remove(self.Settings.RecentCompleteOutfits, vRecentIndex)
				break
			end
		end
		
		table.insert(self.Settings.RecentCompleteOutfits, 1, pOutfit.Name)
	end
	
	--
	
	self:BeginEquipmentUpdate()
	
	-- Clear the selection if the outfit being removed
	-- is selected too
	
	if self.SelectedOutfit == pOutfit then
		self:ClearSelection()
	end

	-- Update the list
	
	pOutfit.didEquip = false
	pOutfit.didUnequip = pCallerIsScript
	
	self.EquippedNeedsUpdate = true
	self.WeaponsNeedUpdate = true
	
	self:EndEquipmentUpdate("Outfitter:RemoveOutfit")
	
	self:DispatchOutfitEvent("UNWEAR_OUTFIT", pOutfit.Name, pOutfit)
	
	-- If they're removing a complete outfit, find something else to wear instead
	
	if pOutfit.CategoryID == "Complete"
	and #self.Settings.RecentCompleteOutfits then
		local vOutfit
		
		while not vOutfit do
			local vOutfitName = self.Settings.RecentCompleteOutfits[#self.Settings.RecentCompleteOutfits]
			
			vOutfit = self:FindOutfitByName(vOutfitName)
			
			if vOutfit and vOutfit.CategoryID == "Complete" then
				self:WearOutfit(vOutfit)
				break
			end
			
			table.remove(self.Settings.RecentCompleteOutfits)
			
			if #self.Settings.RecentCompleteOutfits then
				break
			end
		end
	end
end

function Outfitter:ToggleOutfitNow(pOutfit)
	if self:WearingOutfit(pOutfit) then
		self:RemoveOutfitNow(pOutfit)
		return false
	else
		self:WearOutfitNow(pOutfit)
		return true
	end
end

function Outfitter:ToggleOutfit(pOutfit)
	if self:WearingOutfit(pOutfit) then
		self:RemoveOutfit(pOutfit)
		return false
	else
		self:WearOutfit(pOutfit)
		return true
	end
end

function Outfitter:SetSoundOption(pParam)
	if pParam == "on" then
		self.Settings.DisableEquipSounds = nil
		self:NoteMessage("Outfitter will no longer affect sounds during equipment changes")
	elseif pParam == "off" then
		self.Settings.DisableEquipSounds = true
		self:NoteMessage("Outfitter will now disable sound effects during equipment changes")
	else
		self:NoteMessage("Valid sound options are 'default' and 'off'")
	end
end

function Outfitter:ShowLinkStats(pLink)
	local vStats = self:GetItemLinkStats(pLink)
	
	if not vStats then
		self:NoteMessage("Couldn't get item stats from the link provided")
		return
	end
	
	-- self:ConvertRatingsToStats(vStats)
	-- self:DistributeSecondaryStats(vStats, self:GetPlayerStatDistribution())
	
	for vStatName, vStatValue in pairs(vStats) do
		self:NoteMessage("%s: %s", vStatName, vStatValue or "nil")
	end
end

function Outfitter:ShowLinkInfo(pLink)
	local vItemInfo = self:GetItemInfoFromLink(pLink)
	
	if not vItemInfo then
		self:NoteMessage("Couldn't get item info from the link provided")
		return
	end
	
	self:NoteMessage("Name: "..vItemInfo.Name)
	self:NoteMessage("Quality: "..vItemInfo.Quality)
	self:NoteMessage("Code: "..vItemInfo.Code)
	self:NoteMessage("SubCode: "..vItemInfo.SubCode)
	self:NoteMessage("Type: "..vItemInfo.Type)
	self:NoteMessage("SubType: "..vItemInfo.SubType)
	self:NoteMessage("InvType: "..vItemInfo.InvType)
	self:NoteMessage("Level: "..vItemInfo.Level)
	if vItemInfo.EnchantCode then
		self:NoteMessage("EnchantCode: "..vItemInfo.EnchantCode)
	end
	if vItemInfo.JewelCode1 then
		self:NoteMessage("JewelCode1: "..vItemInfo.JewelCode1)
	end
	if vItemInfo.JewelCode2 then
		self:NoteMessage("JewelCode2: "..vItemInfo.JewelCode2)
	end
	if vItemInfo.JewelCode3 then
		self:NoteMessage("JewelCode3: "..vItemInfo.JewelCode3)
	end
	if vItemInfo.JewelCode4 then
		self:NoteMessage("JewelCode4: "..vItemInfo.JewelCode4)
	end
	if vItemInfo.UniqueID then
		self:NoteMessage("UniqueID: "..vItemInfo.UniqueID)
	end
	
	local vStats = self:GetItemLinkStats(pLink)
	
	self:ConvertRatingsToStats(vStats)
	self:DistributeSecondaryStats(vStats, self:GetPlayerStatDistribution())
	
	self:DebugTable("Stats", vStats)
end

StaticPopupDialogs.OUTFITTER_CONFIRM_RESET =
{
	text = TEXT(Outfitter.cConfirmResetMsg),
	button1 = TEXT(Outfitter.cReset),
	button2 = TEXT(CANCEL),
	OnAccept = function() Outfitter:Reset() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

function Outfitter.AskReset()
	StaticPopup_Show("OUTFITTER_CONFIRM_RESET")
end

function Outfitter:Reset()
	OutfitterFrame:Hide()
	
	self:ClearSelection()
	self.OutfitStack:Clear()
	
	self:InitializeSettings()

	self.CurrentOutfit = self:GetInventoryOutfit()
	self:InitializeOutfits()
	
	self.EquippedNeedsUpdate = false
	self.WeaponsNeedUpdate = false
end

function Outfitter:SetOutfitBindingIndex(pOutfit, pBindingIndex)
	if pBindingIndex then
		for vCategoryID, vOutfits in pairs(self.Settings.Outfits) do
			for vOutfitIndex, vOutfit in ipairs(vOutfits) do
				if vOutfit.BindingIndex == pBindingIndex then
					vOutfit.BindingIndex = nil
				end
			end
		end
	end
	
	pOutfit.BindingIndex = pBindingIndex
end

Outfitter.LastBindingIndex = nil
Outfitter.LastBindingTime = nil

Outfitter.cMinBindingTime = 0.75

function Outfitter:WearBoundOutfit(pBindingIndex)
	-- Check for the user spamming the button to prevent the outfit from
	-- toggling if they're panicking
	
	local vTime = GetTime()
	
	if self.LastBindingIndex == pBindingIndex then
		local vElapsed = vTime - self.LastBindingTime
		
		if vElapsed < self.cMinBindingTime then
			self.LastBindingTime = vTime
			return
		end
	end
	
	--
	
	for vCategoryID, vOutfits in pairs(self.Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			if vOutfit.BindingIndex == pBindingIndex then
				vOutfit.Disabled = nil
				if vCategoryID == "Complete" then
					self:WearOutfit(vOutfit)
					if not self.Settings.Options.DisableHotkeyMessages then
						UIErrorsFrame:AddMessage(format(self.cEquipOutfitMessageFormat, vOutfit.Name), self.OUTFIT_MESSAGE_COLOR.r, self.OUTFIT_MESSAGE_COLOR.g, self.OUTFIT_MESSAGE_COLOR.b)
					end
				else
					local vEquipped = self:ToggleOutfit(vOutfit, vCategoryID)
					
					if not self.Settings.Options.DisableHotkeyMessages then
						if vEquipped then
							UIErrorsFrame:AddMessage(format(self.cEquipOutfitMessageFormat, vOutfit.Name), self.OUTFIT_MESSAGE_COLOR.r, self.OUTFIT_MESSAGE_COLOR.g, self.OUTFIT_MESSAGE_COLOR.b)
						else
							UIErrorsFrame:AddMessage(format(self.cUnequipOutfitMessageFormat, vOutfit.Name), self.OUTFIT_MESSAGE_COLOR.r, self.OUTFIT_MESSAGE_COLOR.g, self.OUTFIT_MESSAGE_COLOR.b)
						end
					end
				end
				
				-- Remember the binding used to filter for button spam
				
				self.LastBindingIndex = pBindingIndex
				self.LastBindingTime = vTime
				
				return
			end
		end
	end
end

function Outfitter:FindOutfit(pOutfit)
	for vCategoryID, vOutfits in pairs(self.Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			if vOutfit == pOutfit then
				return vCategoryID, vOutfitIndex
			end
		end
	end
	
	return nil, nil
end

function Outfitter:FindOutfitByName(pName)
	if not pName
	or pName == "" then
		return nil
	end
	
	local vLowerName = strlower(pName)
	
	for vCategoryID, vOutfits in pairs(self.Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			if strlower(vOutfit.Name) == vLowerName then
				return vOutfit, vCategoryID, vOutfitIndex
			end
		end
	end
	
	return nil, nil
end

function Outfitter:GetOutfitCategoryID(pOutfit)
	for vCategoryID, vOutfits in pairs(self.Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			if vOutfit == pOutfit then
				return vCategoryID, vOutfitIndex
			end
		end
	end
end

-- Outfitter doesn't use this function, but other addons such as
-- Fishing Buddy might use it to locate specific generated outfits

function Outfitter:FindOutfitByStatID(pStatID)
	if not pStatID or pStatID == "" then
		return nil
	end

	for vCategoryID, vOutfits in pairs(self.Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			if vOutfit.StatID and vOutfit.StatID == pStatID then
				return vOutfit, vCategoryID, vOutfitIndex
			end
		end
	end
	
	return nil
end

function Outfitter:GetPlayerStatDistribution()
	return self.cStatDistribution[self.PlayerClass]
end

Outfitter.BaseRatings61 =
{
	Expertise = 2.5,
	
	MeleeHaste = 10,
	MeleeHit = 10,
	MeleeCrit = 14,
	
	SpellHaste = 10,
	SpellHit = 8,
	SpellCrit = 14,
	
	Defense = 1.5,
	Dodge = 12,
	Parry = 15,
	Block = 5,
	Resilience = 25,
}

function Outfitter:GetPlayerRatingStatDistribution()
	local vLevel = UnitLevel("player")
	
	if Outfitter.RatingStatDistribution
	and Outfitter.RatingStatDistributionLevel == vLevel then
		return Outfitter.RatingStatDistribution
	end
	
	--
	
	Outfitter.RatingStatDistribution = {}
	
	if vLevel < 10 then
		vLevel = 10
	end
	
	local vLevelFactor
	local vDodgeLevelFactor
	
	if vLevel <= 10 then
		vLevelFactor = 1 / 26
	elseif vLevel <= 60 then
		vLevelFactor = (vLevel - 8) / 52
	elseif vLevel <= 70 then
		vLevelFactor = 82 / (262 - 3 * vLevel)
	else
		vLevelFactor = (82 / 52) * (131 / 63) ^ ((vLevel - 70) / 10)
	end
	
	if vLevel <= 34 then
		vDodgeLevelFactor = 1 / 2
	else
		vDodgeLevelFactor = (vLevel - 8) / 52
	end
	
	for vStatID, vBase in pairs(Outfitter.BaseRatings61) do
		if vStatID == "Dodge" then
			Outfitter.RatingStatDistribution[vStatID.."Rating"] = {[vStatID] = {Coeff = 1.0 / (vBase * vDodgeLevelFactor)}}
		else
			Outfitter.RatingStatDistribution[vStatID.."Rating"] = {[vStatID] = {Coeff = 1.0 / (vBase * vLevelFactor)}}
		end
	end
	
	return Outfitter.RatingStatDistribution
end
	
function Outfitter:OutfitSummary()
	local vStatDistribution = self:GetPlayerStatDistribution()
	
	self:DebugTable("StatDistribution", vStatDistribution)
	
	local vCurrentOutfitStats = Outfitter.TankPoints_GetCurrentOutfitStats(vStatDistribution)
	
	self:DebugTable("Current Stats", vCurrentOutfitStats)
end

function Outfitter:RatingSummary()
	local vRatingIDs =
	{
		"Weapon",
		"Defense",
		"Dodge",
		"Parry",
		"Block",
		"Melee Hit",
		"Ranged Hit",
		"Spell Hit",
		"Melee Crit",
		"Ranged Crit",
		"Spell Crit",
		"Melee Hit Taken",
		"Ranged Hit Taken",
		"Spell Hit Taken",
		"Melee Crit Taken",
		"Ranged Crit Taken",
		"Spell Crit Taken",
		"Melee Haste",
		"Ranged Haste",
		"Spell Haste",
	}
	
	for vRatingID, vRatingName in ipairs(vRatingIDs) do
		local vRating = GetCombatRating(vRatingID)
		local vRatingBonus = GetCombatRatingBonus(vRatingID)
		
		if vRatingBonus > 0 then
			self:NoteMessage(vRatingName..": "..(vRating / vRatingBonus))
		end
	end
end

-- Work-in-progress for bag organization.  Probably will get split into another addon
-- at some point, just playing around with it for now.

local gOutfitter_SortBagItems
local gOutfitter_Categories =
{
	"Armor",
	"Weapons",
	"Consumables",
		"Potions",
		"Healthstone",
		"Mana gem",
		"Flasks",
		"Elixirs",
		"Bandages",
		"Trinkets",
	"Tradeskill",
		"Herbs",
		"Metals",
		"Gems",
		"Cloth",
		"Leather",
		"Cooking",
			"Spices",
			"Meat",
	"QuestItems",
	"Loot",
		"BoEs",
	"Junk",
}

local gOutfitterItemCorrections =
{
	[6533] = {Type = "Consumable", SubType = "Other"}, -- Aquadynamic Fish Attractor
	[27503] = {SubType = "Scroll"}, -- Scroll of Protection V
	[27515] = {Type = "Trade Goods", SubType = "Meat", InvType = ""}, -- Huge Spotted Feltail
}

function Outfitter:CorrectItemInfo(pItemInfo)
	local vCorrection = gOutfitterItemCorrections[pItemInfo.Code]
	
	if not vCorrection then
		return
	end
	
	for vIndex, vValue in pairs(vCorrection) do
		pItemInfo[vIndex] = vValue
	end
end

function Outfitter.GetItemSortRank(pItem)
	if pItem.ItemIsUsed then
		return 0
	elseif pItem.Quality == 0 then
		return 3
	elseif pItem.Equippable then
		return 2
	else
		return 1
	end
end

function Outfitter:SortBags()
	self.SortBagsCoroutineRef = coroutine.create(self.SortBagsThread)
	
	self:RunThreads()
end

function Outfitter:RunThreads()
	if self.SortBagsCoroutineRef then
		local vSuccess, vMessage = coroutine.resume(self.SortBagsCoroutineRef, self)
		
		if not vSuccess then
			self:ErrorMessage("resume failed: %s", vMessage)
		end
	end
end

function Outfitter:SortBagsThread()
	MCEventLib:RegisterEvent("BAG_UPDATE", self.BagSortBagsChanged, self)
	MCEventLib:RegisterEvent("PLAYERBANKSLOTS_CHANGED", self.BagSortBagsChanged, self)
	
	if true then
		self:SortBagRange(NUM_BAG_SLOTS, 0)
		
		if self.BankFrameOpened then
			for vBankSlot = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
				self:SortBagRange(vBankSlot, vBankSlot)
			end
			
			self:SortBagRange(-1, -1)
		end
	else
		self:SortBagRange(5, 5)
	end

	MCEventLib:UnregisterEvent("BAG_UPDATE", self.BagSortBagsChanged, self)
	MCEventLib:UnregisterEvent("PLAYERBANKSLOTS_CHANGED", self.BagSortBagsChanged, self)
	
	self.SortBagsCoroutineRef = nil
end

function Outfitter:BagSortBagsChanged()
	self.BagChangeTime = GetTime()
	
	MCSchedulerLib:RescheduleTask(0.5, self.RunThreads, self)
end

function Outfitter:SortBagRange(pStartIndex, pEndIndex)
	self:TestMessage("SortBagRange: %s, %s", pStartIndex or "nil", pEndIndex or "nil")
	
	-- Gather a list of the items
	
	local vItems = {}
	local vIterator = self:NewObject(self._BagIterator, pStartIndex, pEndIndex)
	
	while vIterator:NextSlot() do
		self:TestMessage("Checking slot %d, %d", vIterator.BagIndex, vIterator.BagSlotIndex)
		
		local vItemInfo = self:GetBagItemInfo(vIterator.BagIndex, vIterator.BagSlotIndex)
		
		if vItemInfo then
			self:CorrectItemInfo(vItemInfo)
			
			vItemInfo.BagIndex = vIterator.BagIndex
			vItemInfo.BagSlotIndex = vIterator.BagSlotIndex
			vItemInfo.ItemIsUsed = self:GetOutfitsUsingItem(vItemInfo)
			vItemInfo.Equippable = vItemInfo.InvType ~= ""
			vItemInfo.SortRank = self.GetItemSortRank(vItemInfo)
			
			table.insert(vItems, vItemInfo)
		end
	end
	
	-- Sort the items
	
	self:TestMessage("Sorting the items")
	
	table.sort(vItems, self.BagSortCompareItems)
	
	-- Assign the items to bag slots
	
	self:TestMessage("Assigning locations")
	
	local vDestBagSlot = self:NewObject(self._BagIterator, pStartIndex, pEndIndex)
	
	for _, vItemInfo in ipairs(vItems) do
		if not vDestBagSlot:NextSlot() then
			break
		end
		
		vItemInfo.DestBagIndex = vDestBagSlot.BagIndex
		vItemInfo.DestBagSlotIndex = vDestBagSlot.BagSlotIndex
	end
	
	--
	
	self:TestMessage("Starting item moves")
	
	while self:BagSortMoveItems(vItems) do
		self:TestMessage("Completed one move")
		
		while not self.BagChangeTime or GetTime() - self.BagChangeTime < 0.5 do
			self:TestMessage("Yielding")
			self:BagSortBagsChanged()
			coroutine.yield()
		end
	end
	
	self:TestMessage("Done moving items")
end	

function Outfitter:BagSortMoveItems(pItems)
	self:TestMessage("BagSortMoveItems")
	
	local vDidMove = false
	local vBagSlotUsed = {}
	
	for vIndex = -1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
		vBagSlotUsed[vIndex] = {}
	end
	
	-- Move the items to their destinations
	
	local vSaved_EnableSFX = GetCVar("Sound_EnableSFX")
	SetCVar("Sound_EnableSFX", "0")
	
	local vNumMoves = 0
	
	for _, vItemInfo in ipairs(pItems) do
		if (vItemInfo.BagIndex ~= vItemInfo.DestBagIndex
		or vItemInfo.BagSlotIndex ~= vItemInfo.DestBagSlotIndex)
		and not vBagSlotUsed[vItemInfo.BagIndex][vItemInfo.BagSlotIndex]
		and not vBagSlotUsed[vItemInfo.DestBagIndex][vItemInfo.DestBagSlotIndex] then
			
			self:TestMessage("Checking item in %d, %d", vItemInfo.BagIndex, vItemInfo.BagSlotIndex)
			
			-- Find the item currently at the destination (if any)
			
			local vDestItemInfo
			
			for _, vItemInfo2 in ipairs(pItems) do
				if vItemInfo2.BagSlotIndex == vItemInfo.DestBagSlotIndex
				and vItemInfo2.BagIndex == vItemInfo.DestBagIndex then
					self:TestMessage("Found item in pItems")
					vDestItemInfo = vItemInfo2
					break
				end
			end
			
			-- Move/swap the items
			
			self:NoteMessage(format(
					"Moving %s from bag %d, %d to %d, %d",
					vItemInfo.Name,
					vItemInfo.BagIndex, vItemInfo.BagSlotIndex,
					vItemInfo.DestBagIndex, vItemInfo.DestBagSlotIndex))
			
			
			ClearCursor()
			self:PickupItemLocation(vItemInfo)
			self:PickupItemLocation({BagIndex = vItemInfo.DestBagIndex, BagSlotIndex = vItemInfo.DestBagSlotIndex})
			if vDestItemInfo then self:PickupItemLocation(vItemInfo) end
			
			-- Mark the bag slots as already being involved in this round
			
			vBagSlotUsed[vItemInfo.BagIndex][vItemInfo.BagSlotIndex] = true
			vBagSlotUsed[vItemInfo.DestBagIndex][vItemInfo.DestBagSlotIndex] = true
			
			-- Update the source and dest item info
			
			if vDestItemInfo then
				vDestItemInfo.BagIndex = vItemInfo.BagIndex
				vDestItemInfo.BagSlotIndex = vItemInfo.BagSlotIndex
			end
			
			vItemInfo.BagIndex = vItemInfo.DestBagIndex
			vItemInfo.BagSlotIndex = vItemInfo.DestBagSlotIndex
			
			vDidMove = true
			
			self:BagSortBagsChanged()
			
			-- Yield every ten item moves
			
			vNumMoves = vNumMoves + 1
			
			if vNumMoves >= 10 then
				SetCVar("Sound_EnableSFX", vSaved_EnableSFX)
				coroutine.yield()
				SetCVar("Sound_EnableSFX", "0")
				
				vNumMoves = 0
			end
		end
	end
	
	SetCVar("Sound_EnableSFX", vSaved_EnableSFX)
	
	self:TestMessage("BagSortMoveItems completed: vDidMove = %s", tern(vDidMove, "true", "false"))
	
	return vDidMove
end

function Outfitter.BagSortCompareItems(pItem1, pItem2) -- Must not be method since it's called by table.sort
	if pItem1.SortRank ~= pItem2.SortRank then
		return pItem1.SortRank < pItem2.SortRank
	end
	
	-- If both items are equippable, sort them by
	-- slot first
	
	if pItem1.Equippable then
		return pItem1.InvType < pItem2.InvType
	end
	
	-- Sort items by type
	
	if pItem1.Type ~= pItem2.Type then
		return pItem1.Type < pItem2.Type
	end
	
	-- Sort by subtype
	
	if pItem1.SubType ~= pItem2.SubType then
		return pItem1.SubType < pItem2.SubType
	end
	
	-- Sort by name
	
	return pItem1.Name < pItem2.Name
end

Outfitter._BagIterator = {}
Outfitter.cGeneralBagType = 0

function Outfitter._BagIterator:Construct(pStartIndex, pEndIndex)
	self:Reset(pStartIndex, pEndIndex)
end

function Outfitter._BagIterator:Reset(pStartIndex, pEndIndex)
	if not pStartIndex then
		pStartIndex = NUM_BAG_SLOTS
		pEndIndex = 0
	end
	
	if not pEndIndex then
		pEndIndex = pStartIndex
	end
	
	if pStartIndex <= pEndIndex then
		self.Direction = 1
	else
		self.Direction = -1
	end
	
	self.BagIndex = pStartIndex
	self.EndBagIndex = pEndIndex
	
	self.BagSlotIndex = 0
	
	if pStartIndex == pEndIndex
	or Outfitter:GetBagType(self.BagIndex)== Outfitter.cGeneralBagType then
		self.NumBagSlots = GetContainerNumSlots(self.BagIndex)
	else
		self.NumBagSlots = 0
	end
end

function Outfitter._BagIterator:NextSlot()
	self.BagSlotIndex = self.BagSlotIndex + 1
	
	while self.BagSlotIndex > self.NumBagSlots do
		if self.BagIndex == self.EndBagIndex then
			return false
		end
		
		self.BagIndex = self.BagIndex + self.Direction
		
		self.BagSlotIndex = 1
		
		if Outfitter:GetBagType(self.BagIndex) == Outfitter.cGeneralBagType then
			self.NumBagSlots = GetContainerNumSlots(self.BagIndex)
		else
			self.NumBagSlots = 0
		end
	end
	
	return true
end

function Outfitter:ItemUsesBothWeaponSlots(pItem)
	if not pItem then
		self:DebugMessage("ItemUsesBothWeaponSlots: nil item")
		self:DebugStack()
		return false
	end
	
	if pItem.InvType ~= "INVTYPE_2HWEAPON"then
		return false
	end
	
	if not self.CanDualWield2H then
		return true
	end
	
	if not pItem.SubType then
		self:DebugMessage("ItemUsesBothWeaponSlots: SubType not specified")
		self:DebugTable("pItem", pItem)
		self:DebugStack()
	end
	
	local vIsDualWieldable2H = pItem.SubType == Outfitter.c2HAxes
	                        or pItem.SubType == Outfitter.c2HMaces
	                        or pItem.SubType == Outfitter.c2HSwords
	
	return not vIsDualWieldable2H
end

function Outfitter:GetItemMetaSlot(pItem)
	if pItem.MetaSlotName == "TwoHandSlot"
	and not self:ItemUsesBothWeaponSlots(pItem) then
		return "Weapon0Slot"
	else
		return pItem.MetaSlotName
	end
end

function Outfitter:GetCompiledOutfit()
	local vCompiledOutfit = Outfitter:NewEmptyOutfit()
	
	vCompiledOutfit.SourceOutfit = {}
	
	for vStackIndex, vOutfit in ipairs(Outfitter.OutfitStack.Outfits) do
		for vInventorySlot, vOutfitItem in pairs(vOutfit.Items) do
			vCompiledOutfit.Items[vInventorySlot] = vOutfitItem
			vCompiledOutfit.SourceOutfit[vInventorySlot] = vOutfit.Name
		end
	end
	
	-- Make sure the OH slot is marked as empty if a 2H weapon is equipped
	-- and the player can't dual-wield 2H weapons
	
	if vCompiledOutfit.Items.MainHandSlot
	and Outfitter:ItemUsesBothWeaponSlots(vCompiledOutfit.Items.MainHandSlot) then
		vCompiledOutfit.Items.SecondaryHandSlot = Outfitter:NewEmptyItemInfo()
	end
	
	return vCompiledOutfit
end

function Outfitter:GetExpectedOutfit(pExcludeOutfit)
	local vCompiledOutfit = Outfitter:NewEmptyOutfit()
	
	vCompiledOutfit.SourceOutfit = {}
	
	for vStackIndex, vOutfit in ipairs(Outfitter.OutfitStack.Outfits) do
		if vOutfit ~= pExcludeOutfit then
			for vInventorySlot, vOutfitItem in pairs(vOutfit.Items) do
				vCompiledOutfit.Items[vInventorySlot] = vOutfitItem
				vCompiledOutfit.SourceOutfit[vInventorySlot] = vOutfit.Name
			end
		end
	end
	
	return vCompiledOutfit
end

function Outfitter:GetBagType(pBagIndex)
	if pBagIndex == 0 then -- special case zero since ContainerIDToInventoryID will barf on it
		return Outfitter.cGeneralBagType
	end
	
	if pBagIndex < 0 then
		pBagIndex = 4 - pBagIndex
	end
	
	local vItemLink = GetInventoryItemLink("player", ContainerIDToInventoryID(pBagIndex))
	
	if not vItemLink then
		return nil
	end
	
	return GetItemFamily(vItemLink)
	--[[
	local vItemInfo = Outfitter:GetItemInfoFromLink(vItemLink)
	
	if not vItemInfo then
		return nil
	end
	
	return vItemInfo.SubType
	]]
end

function Outfitter:GetEmptyBagSlot(pStartBagIndex, pStartBagSlotIndex, pIncludeBank)
	local vStartBagIndex = pStartBagIndex
	local vStartBagSlotIndex = pStartBagSlotIndex
	
	if not vStartBagIndex then
		vStartBagIndex = NUM_BAG_SLOTS
	end
	
	if not vStartBagSlotIndex then
		vStartBagSlotIndex = 1
	end
	
	local vEndBagIndex = 0
	
	if pIncludeBank then
		vEndBagIndex = -1
	end
	
	for vBagIndex = vStartBagIndex, vEndBagIndex, -1 do
		-- Search ordinary container bags for empty slots
		
		if Outfitter:GetBagType(vBagIndex) == Outfitter.cGeneralBagType then
			local vNumBagSlots = GetContainerNumSlots(vBagIndex)
			
			if vNumBagSlots > 0 then
				for vSlotIndex = vStartBagSlotIndex, vNumBagSlots do
					local vItemInfo = Outfitter:GetBagItemInfo(vBagIndex, vSlotIndex)
					
					if not vItemInfo then
						return {BagIndex = vBagIndex, BagSlotIndex = vSlotIndex}
					end
				end
			end
		end
		
		vStartBagSlotIndex = 1
	end
	
	return nil
end

function Outfitter:GetEmptyBagSlotList()
	local vEmptyBagSlots = {}
	
	local vBagIndex = NUM_BAG_SLOTS
	local vBagSlotIndex = 1
	
	while true do
		local vBagSlotInfo = Outfitter:GetEmptyBagSlot(vBagIndex, vBagSlotIndex)
		
		if not vBagSlotInfo then
			return vEmptyBagSlots
		end
		
		table.insert(vEmptyBagSlots, vBagSlotInfo)
		
		vBagIndex = vBagSlotInfo.BagIndex
		vBagSlotIndex = vBagSlotInfo.BagSlotIndex + 1
	end
end

function Outfitter:GetEmptyBankSlotList()
	local vEmptyBagSlots = {}
	
	local vBagIndex = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
	local vBagSlotIndex = 1
	
	while true do
		local vBagSlotInfo = Outfitter:GetEmptyBagSlot(vBagIndex, vBagSlotIndex, true)
		
		if not vBagSlotInfo then
			return vEmptyBagSlots
		
		elseif vBagSlotInfo.BagIndex > NUM_BAG_SLOTS
		or vBagSlotInfo.BagIndex < 0 then
			table.insert(vEmptyBagSlots, vBagSlotInfo)
		end
		
		vBagIndex = vBagSlotInfo.BagIndex
		vBagSlotIndex = vBagSlotInfo.BagSlotIndex + 1
	end
end

function Outfitter:FindItemsInBagsForSlot(pSlotName, pIgnoreItems)
	-- Alias the slot names down for finger and trinket
	
	local vInventorySlot = pSlotName
	
	if vInventorySlot == "Finger1Slot" then
		vInventorySlot = "Finger0Slot"
	elseif vInventorySlot == "Trinket1Slot" then
		vInventorySlot = "Trinket0Slot"
	end
	
	--
	
	local vItems = {}
	local vNumBags, vFirstBagIndex = self:GetNumBags()
	
	for vBagIndex = vFirstBagIndex, vNumBags do
		local vNumBagSlots = GetContainerNumSlots(vBagIndex)
		
		if vNumBagSlots > 0 then
			for vSlotIndex = 1, vNumBagSlots do
				local vItemInfo = self:GetBagItemInfo(vBagIndex, vSlotIndex)
				
				if vItemInfo
				and (not pIgnoreItems or not pIgnoreItems[vItemInfo.Code]) then
					local vItemSlotName = vItemInfo.ItemSlotName
					
					if vItemInfo.MetaSlotName then
						vItemSlotName = self:GetItemMetaSlot(vItemInfo)
					end
					
					if vItemSlotName == "TwoHandSlot" then
						vItemSlotName = "MainHandSlot"
					
					elseif vItemSlotName == "Weapon0Slot" then
						if vInventorySlot == "MainHandSlot"
						or vInventorySlot == "SecondaryHandSlot" then
							vItemSlotName = vInventorySlot
						end
					end
					
					if vItemSlotName == vInventorySlot then
						table.insert(vItems, {BagIndex = vBagIndex, BagSlotIndex = vSlotIndex, Code = vItemInfo.Code, Name = vItemInfo.Name})
					end
				end
			end
		end
	end
	
	if #vItems == 0 then	
		return nil
	end
	
	return vItems
end

function Outfitter:OutfitHasCombatEquipmentSlots(pOutfit)
	for vEquipmentSlot, _ in pairs(Outfitter.cCombatEquipmentSlots) do
		if pOutfit.Items[vEquipmentSlot] then
			return true
		end
	end
	
	return false
end

function Outfitter:OutfitOnlyHasCombatEquipmentSlots(pOutfit)
	for vEquipmentSlot, _ in pairs(pOutfit.Items) do
		if not Outfitter.cCombatEquipmentSlots[vEquipmentSlot] then
			return false
		end
	end
	
	return true
end

function Outfitter:GetItemInfoFromLink(pItemLink)
	if not pItemLink then
		return nil
	end
	
	-- |cff1eff00|Hitem:1465:803:0:0:0:0:0:0|h[Tigerbane]|h|r
	-- |(hex code for item color)|Hitem:(item ID code):(enchant code):(added stats code):0|h[(item name)]|h|r
	
	local	vStartIndex,
			vEndIndex,
			vItemCode,
			vItemEnchantCode,
			vItemJewelCode1,
			vItemJewelCode2,
			vItemJewelCode3,
			vItemJewelCode4,
			vItemSubCode,
			vItemUniqueID,
			vItemUnknownCode1,
			vItemName
	
	vStartIndex,
	vEndIndex,
	vItemCode,
	vItemEnchantCode,
	vItemJewelCode1,
	vItemJewelCode2,
	vItemJewelCode3,
	vItemJewelCode4,
	vItemSubCode,
	vItemUniqueID,
	vItemUnknownCode1,
	vItemName = pItemLink:find(Outfitter.cItemLinkFormat)
	
	if not vStartIndex then
		self:DebugMessage("GetItemInfoFromLink: Pattern didn't match")
		self:DebugMessage(pItemLink:gsub("|", "\\"))
		return nil
	end
	
	vItemCode = tonumber(vItemCode)
	
	local vItemFamilyName,
			vItemLink,
			vItemQuality,
			vItemLevel,
			vItemMinLevel,
			vItemType,
			vItemSubType,
			vItemCount,
			vItemInvType = GetItemInfo(vItemCode)
	
	--
	
	local vItemInfo =
	{
		Link = pItemLink,
		
		Code = vItemCode,
		SubCode = tonumber(vItemSubCode),
		
		Name = vItemName,
		Quality = vItemQuality,
		Level = vItemLevel,
		MinLevel = vItemMinLevel,
		Type = vItemType,
		SubType = vItemSubType,
		
		Count = vItemCount,
		InvType = vItemInvType,
		
		EnchantCode = tonumber(vItemEnchantCode),
		
		JewelCode1 = tonumber(vItemJewelCode1),
		JewelCode2 = tonumber(vItemJewelCode2),
		JewelCode3 = tonumber(vItemJewelCode3),
		JewelCode4 = tonumber(vItemJewelCode4),	
		
		UniqueID = tonumber(vItemUniqueID),
	}
	
	-- Just return if there's no inventory type
	
	if not vItemInvType
	or vItemInvType == "" then
		return vItemInfo
	end
	
	-- If it's a known inventory type add that knowledge to the item info
	
	local vInvTypeInfo = Outfitter.cInvTypeToSlotName[vItemInvType]
	
	if vInvTypeInfo then
		-- Get the slot name
		
		if not vInvTypeInfo.SlotName then
			self:ErrorMessage("Unknown slot name for inventory type "..vItemInvType)
			return vItemInfo
		end
		
		vItemInfo.ItemSlotName = vInvTypeInfo.SlotName
		vItemInfo.MetaSlotName = vInvTypeInfo.MetaSlotName
	else
		-- This function can be used to query non-equippable items, so it's not an error for
		-- the inventory type to be unknown.  Should Blizzard ever add a new type though, this
		-- debug message may be useful in figuring out its characteristics
		
		-- self:ErrorMessage("Unknown slot type "..vItemInvType.." for item "..vItemName)
	end
	
	-- Done
	
	return vItemInfo
end

function Outfitter:CreateNewOutfit()
	Outfitter.NameOutfit_Open(nil)
end

function Outfitter:NewEmptyOutfit(pName)
	return {Name = pName, Items = {}}
end

function Outfitter:IsEmptyOutfit(pOutfit)
	return self:ArrayIsEmpty(pOutfit.Items)
end

function Outfitter:NewNakedOutfit(pName)
	local vOutfit = self:NewEmptyOutfit(pName)

	for _, vInventorySlot in ipairs(Outfitter.cSlotNames) do
		self:AddOutfitItem(vOutfit, vInventorySlot, nil)
	end
	
	return vOutfit
end

function Outfitter:NewEmptyItemInfo()
	return
	{
		Name = "",
		Code = 0,
		SubCode = 0,
		EnchantCode = 0,
		JewelCode1 = 0,
		JewelCode2 = 0,
		JewelCode3 = 0,
		JewelCode4 = 0,
		UniqueID = 0,
		InvType = nil,
	}
end

function Outfitter:AddOutfitItem(pOutfit, pSlotName, pItemInfo)
	if pItemInfo == nil then
		pItemInfo = self:NewEmptyItemInfo()
	end
	
	pOutfit.Items[pSlotName] =
	{
		Code = tonumber(pItemInfo.Code),
		SubCode = tonumber(pItemInfo.SubCode),
		Name = pItemInfo.Name,
		EnchantCode = tonumber(pItemInfo.EnchantCode),
		JewelCode1 = tonumber(pItemInfo.JewelCode1),
		JewelCode2 = tonumber(pItemInfo.JewelCode2),
		JewelCode3 = tonumber(pItemInfo.JewelCode3),
		JewelCode4 = tonumber(pItemInfo.JewelCode4),
		UniqueID = tonumber(pItemInfo.UniqueID),
		InvType = pItemInfo.InvType,
		SubType = pItemInfo.SubType,
	}
end

function Outfitter:CollapseMetaSlotsIfBetter(pOutfit, pStatID)
	-- Compare the weapon slot with the 1H/OH slots
	
	local vWeapon0Item = pOutfit.Items.Weapon0Slot
	local vWeapon1Item = pOutfit.Items.Weapon1Slot
	
	if vWeapon0Item or vWeapon1Item then
		-- Try the various combinations of MH/OH/W0/W1
		
		local v1HItem = pOutfit.Items.MainHandSlot
		local vOHItem = pOutfit.Items.SecondaryHandSlot
		
		local vCombinations =
		{
			{MainHand = v1HItem, SecondaryHand = vOHItem, AllowEmptyMainHand = true},
			{MainHand = v1HItem, SecondaryHand = vWeapon0Item, AllowEmptyMainHand = false},
			{MainHand = v1HItem, SecondaryHand = vWeapon1Item, AllowEmptyMainHand = false},
			{MainHand = vWeapon0Item, SecondaryHand = vOHItem, AllowEmptyMainHand = true},
			{MainHand = vWeapon1Item, SecondaryHand = vOHItem, AllowEmptyMainHand = true},
			{MainHand = vWeapon0Item, SecondaryHand = vWeapon1Item, AllowEmptyMainHand = false},
		}
		
		local vBestCombinationIndex = nil
		local vBestCombinationValue = nil
		
		for vIndex = 1, 6 do
			local vCombination = vCombinations[vIndex]
			
			-- Ignore combinations where the main hand is empty if
			-- that's not allowed in this combinations
			
			if vCombination.AllowEmptyMainHand
			or vCombination.MainHand then
				local vCombinationValue = self:AddStats(vCombination.MainHand, vCombination.SecondaryHand, pStatID)
				
				if not vBestCombinationIndex
				or vCombinationValue > vBestCombinationValue then
					vBestCombinationIndex = vIndex
					vBestCombinationValue = vCombinationValue
				end
			end
		end
		
		if vBestCombinationIndex then
			local vCombination = vCombinations[vBestCombinationIndex]
			
			pOutfit.Items.MainHandSlot = vCombination.MainHand
			pOutfit.Items.SecondaryHandSlot = vCombination.SecondaryHand
		end
		
		pOutfit.Items.Weapon0Slot = nil
		pOutfit.Items.Weapon1Slot = nil
	end
	
	-- Compare the 2H slot with the 1H/OH slots
	
	local v2HItem = pOutfit.Items.TwoHandSlot
	
	if v2HItem then
		local v1HItem = pOutfit.Items.MainHandSlot
		local vOHItem = pOutfit.Items.SecondaryHandSlot
		local v1HOHTotalStat = self:AddStats(v1HItem, vOHItem, pStatID)
		
		if v2HItem[pStatID]
		and v2HItem[pStatID] > v1HOHTotalStat then
			pOutfit.Items.MainHandSlot = v2HItem
			pOutfit.Items.SecondaryHandSlot = nil
		end
		
		pOutfit.Items.TwoHandSlot = nil
	end
end

function Outfitter:RemoveOutfitItem(pOutfit, pSlotName)
	pOutfit.Items[pSlotName] = nil
end

function Outfitter:GetInventoryOutfit(pName, pOutfit)
	local vOutfit
	
	if pOutfit then
		vOutfit = pOutfit
	else
		vOutfit = self:NewEmptyOutfit(pName)
	end
	
	for _, vInventorySlot in ipairs(Outfitter.cSlotNames) do
		local vItemInfo = self:GetInventoryItemInfo(vInventorySlot)
		
		-- To avoid extra memory operations, only update the item if it's different
		
		local vExistingItem = vOutfit.Items[vInventorySlot]
		
		if not vItemInfo then
			if not vExistingItem
			or vExistingItem.Code ~= 0 then
				self:AddOutfitItem(vOutfit, vInventorySlot, nil)
			end
		else
			if not vExistingItem
			or vExistingItem.Code ~= vItemInfo.Code
			or vExistingItem.SubCode ~= vItemInfo.SubCode
			or vExistingItem.EnchantCode ~= vItemInfo.EnchantCode 
			or vExistingItem.JewelCode1 ~= vItemInfo.JewelCode1
			or vExistingItem.JewelCode2 ~= vItemInfo.JewelCode2
			or vExistingItem.JewelCode3 ~= vItemInfo.JewelCode3
			or vExistingItem.JewelCode4 ~= vItemInfo.JewelCode4
			or vExistingItem.UniqueID ~= vItemInfo.UniqueID then
				self:AddOutfitItem(vOutfit, vInventorySlot, vItemInfo)
			end
		end
	end
	
	return vOutfit
end

function Outfitter:UpdateOutfitFromInventory(pOutfit, pNewItemsOutfit)
	if not pNewItemsOutfit then
		return
	end
	
	for vInventorySlot, vItem in pairs(pNewItemsOutfit.Items) do
		-- Only update slots which aren't in an unknown state
		
		local vCheckbox = getglobal("OutfitterEnable"..vInventorySlot)
		
		if not vCheckbox:GetChecked()
		or not vCheckbox.IsUnknown then
			pOutfit.Items[vInventorySlot] = vItem
			self:NoteMessage(format(Outfitter.cAddingItem, vItem.Name, pOutfit.Name))
		end
	end
	
	-- Add the new items to the current compiled outfit
	
	for vInventorySlot, vItem in pairs(pNewItemsOutfit.Items) do
		Outfitter.ExpectedOutfit.Items[vInventorySlot] = pNewItemsOutfit.Items[vInventorySlot]
	end
	
	self:OutfitSettingsChanged(pOutfit)
end

function Outfitter:SubtractOutfit(pOutfit1, pOutfit2, pCheckAlternateSlots)
	local vEquippableItems = Outfitter.ItemList_GetEquippableItems()
	
	-- Remove items from pOutfit1 if they match the item in pOutfit2
	
	for _, vInventorySlot in ipairs(Outfitter.cSlotNames) do
		local vItem1 = pOutfit1.Items[vInventorySlot]
		local vItem2 = pOutfit2.Items[vInventorySlot]
		
		if Outfitter.ItemList_ItemsAreSame(vEquippableItems, vItem1, vItem2) then
			pOutfit1.Items[vInventorySlot] = nil
		elseif pCheckAlternateSlots then
			local vAlternateSlotName = Outfitter.cFullAlternateStatSlot[vInventorySlot]
			
			vItem2 = pOutfit2.Items[vAlternateSlotName]
			
			if Outfitter.ItemList_ItemsAreSame(vEquippableItems, vItem1, vItem2) then
				pOutfit1.Items[vInventorySlot] = nil
			end
		end
	end
end

function Outfitter:GetNewItemsOutfit(pPreviousOutfit)
	-- Get the current outfit and the list
	-- of equippable items
	
	self.CurrentInventoryOutfit = self:GetInventoryOutfit(self.CurrentInventoryOutfit)
	
	local vEquippableItems = self.ItemList_GetEquippableItems()
	
	-- Create a temporary outfit from the differences
	
	local vNewItemsOutfit = self:NewEmptyOutfit()
	local vOutfitHasItems = false
	
	for _, vInventorySlot in ipairs(self.cSlotNames) do
		local vCurrentItem = self.CurrentInventoryOutfit.Items[vInventorySlot]
		local vPreviousItem = pPreviousOutfit.Items[vInventorySlot]
		local vSkipSlot = false
		
		if vInventorySlot == "SecondaryHandSlot" then
			local vMainHandItem = pPreviousOutfit.Items["MainHandSlot"]
			
			if not vMainHandItem then
				--self:DebugMessage("MainHandItem is nil")
				--self:DebugTable("Items", pPreviousOutfit.Items)
			end
			
			if self:ItemUsesBothWeaponSlots(vMainHandItem) then
				vSkipSlot = true
			end
		elseif vInventorySlot == "AmmoSlot"
		and (not vCurrentItem or vCurrentItem.Code == 0) then
			vSkipSlot = true
		end
		
		if not vSkipSlot
		and not self.ItemList_InventorySlotContainsItem(vEquippableItems, vInventorySlot, vPreviousItem) then
			vNewItemsOutfit.Items[vInventorySlot] = vCurrentItem
			vOutfitHasItems = true
		end
	end
	
	if not vOutfitHasItems then
		return nil
	end
	
	return vNewItemsOutfit, self.CurrentInventoryOutfit
end

function Outfitter:UpdateTemporaryOutfit(pNewItemsOutfit)
	-- Just return if nothing has changed
	
	if not pNewItemsOutfit then
		return
	end
	
	-- Merge the new items with an existing temporary outfit
	
	local vTemporaryOutfit = Outfitter.OutfitStack:GetTemporaryOutfit()
	local vUsingExistingTempOutfit = false
	
	if vTemporaryOutfit then
	
		for vInventorySlot, vItem in pairs(pNewItemsOutfit.Items) do
			vTemporaryOutfit.Items[vInventorySlot] = vItem
		end
		
		vUsingExistingTempOutfit = true
	
	-- Otherwise add the new items as the temporary outfit
	
	else
		vTemporaryOutfit = pNewItemsOutfit
	end
	
	-- Subtract out items which are expected to be in the outfit
	
	local vExpectedOutfit = self:GetExpectedOutfit(vTemporaryOutfit)
	
	self:SubtractOutfit(vTemporaryOutfit, vExpectedOutfit)
	
	if self:IsEmptyOutfit(vTemporaryOutfit) then
		if vUsingExistingTempOutfit then
			self:RemoveOutfit(vTemporaryOutfit)
		end
	else
		if not vUsingExistingTempOutfit then
			Outfitter.OutfitStack:AddOutfit(vTemporaryOutfit)
		end
	end
	
	-- Add the new items to the current compiled outfit
	
	for vInventorySlot, vItem in pairs(pNewItemsOutfit.Items) do
		Outfitter.ExpectedOutfit.Items[vInventorySlot] = vItem
	end
end

function Outfitter:SetSlotEnable(pSlotName, pEnable)
	if not self.SelectedOutfit then
		return
	end
	
	if pEnable then
		self:SetInventoryItem(Outfitter.SelectedOutfit, pSlotName)
	else
		self.SelectedOutfit.Items[pSlotName] = nil
	end
	
	self.DisplayIsDirty = true
end

function Outfitter:SetInventoryItem(pOutfit, pSlotName)
	if not pOutfit then
		return
	end

	self:AddOutfitItem(pOutfit, pSlotName, self:GetInventoryItemInfo(pSlotName))
	
	self.DisplayIsDirty = true
end

function Outfitter:GetOutfitByScriptID(pScriptID)
	for vCategoryID, vOutfits in pairs(self.Settings.Outfits) do
		for _, vOutfit in ipairs(vOutfits) do
			if vOutfit.ScriptID == pScriptID then
				return vOutfit
			end
		end
	end
	
	return nil
end

function Outfitter:GetPlayerAuraStates()
	local vAuraStates =
	{
		Dining = false,
		Shadowform = false,
		GhostWolf = false,
		Feigning = false,
		Evocate = false,
		Monkey = false,
		Hawk = false,
		Cheetah = false,
		Pack = false,
		Beast = false,
		Wild = false,
		Viper = false,
		Prowl = false,
	}
	
	local vBuffIndex = 1
	
	while true do
		local vName, _, vTexture = UnitBuff("player", vBuffIndex)
		
		if not vTexture then
			return vAuraStates
		end
		
		local vStartIndex, vEndIndex, vTextureName = string.find(vTexture, "([^%\\]*)$")
		
		--
		
		local vSpecialID = Outfitter.cAuraIconSpecialID[vName]
		
		if not vSpecialID then
			vSpecialID = Outfitter.cAuraIconSpecialID[vTextureName]
		end
		
		if vSpecialID then
			vAuraStates[vSpecialID] = true
		
		--
		
		elseif not vAuraStates.Dining
		and string.find(vTextureName, "INV_Drink") then
			vAuraStates.Dining = true
		
		--
		
		else
			local vTextLine1, vTextLine2 = self:GetBuffTooltipText(vBuffIndex)
			
			if vTextLine1 then
				local vSpecialID = self.cSpellNameSpecialID[vTextLine1]
				
				if vSpecialID then
					vAuraStates[vSpecialID] = true
				end
			end
		end
		
		vBuffIndex = vBuffIndex + 1
	end
end

function Outfitter:GetBuffTooltipText(pBuffIndex)
	OutfitterTooltip:SetOwner(OutfitterFrame, "ANCHOR_BOTTOMRIGHT", 0, 0)
	OutfitterTooltip:SetUnitBuff("player", pBuffIndex)
	
	local vText1, vText2
	
	if OutfitterTooltipTextLeft1:IsShown() then
		vText1 = OutfitterTooltipTextLeft1:GetText()
	end -- if IsShown

	if OutfitterTooltipTextLeft2:IsShown() then
		vText2 = OutfitterTooltipTextLeft2:GetText()
	end -- if IsShown

	OutfitterTooltip:Hide()
	
	return vText1, vText2
end

function Outfitter:UpdateSwimming()
	self:BeginEquipmentUpdate()
	
	MCEventLib:DispatchEvent("TIMER")
	
	self:UpdateMountedState()
	
	local vSwimming = false
	
	if IsSwimming() then
		vSwimming = true
	end
	
	if not self.SpecialState.Swimming then
		self.SpecialState.Swimming = false
	end
	
	self:SetSpecialOutfitEnabled("Swimming", vSwimming)
	self:EndEquipmentUpdate()
end

function Outfitter:UnitAuraChanged(pEvent, pUnitID)
	if pUnitID ~= "player" then
		return
	end
	
	self:UpdateAuraStates()
end

function Outfitter:UpdateAuraStates()
	self:BeginEquipmentUpdate()
	
	-- Check for special aura outfits

	local vAuraStates = self:GetPlayerAuraStates()
	
	for vSpecialID, vIsActive in pairs(vAuraStates) do
		if vSpecialID == "Feigning" then
			self.IsFeigning = vIsActive
		end
		
		if not Outfitter.SpecialState[vSpecialID] then
			self.SpecialState[vSpecialID] = false
		end
		
		-- Don't equip the dining outfit if health and mana are almost topped up

		if vSpecialID == "Dining"
		and vIsActive
		and self:PlayerIsFull() then
			vIsActive = false
		end
		
		-- Update the state
		
		self:SetSpecialOutfitEnabled(vSpecialID, vIsActive)
	end
	
	self:UpdateMountedState()
	
	self:EndEquipmentUpdate()
	
	-- Update shapeshift state on aura change too
	-- NOTE: Currently (WoW client 2.3) the shapeshift info isn't
	-- always up-to-date when the AURA event comes in, so update
	-- the shapeshift state after about 1 frame to allow the state to
	-- synch
	
	MCSchedulerLib:ScheduleUniqueTask(0.01, self.UpdateShapeshiftState, self)
end

function Outfitter:UpdateMountedState()
	local vRiding = IsMounted() and not UnitOnTaxi("player")
	
	self:SetSpecialOutfitEnabled("Riding", vRiding)
end

function Outfitter:UpdateShapeshiftState()
	self:BeginEquipmentUpdate()
	
	if not self.Settings.ShapeshiftIndexInfo then
		self.Settings.ShapeshiftIndexInfo = {}
	end
	
	local vNumForms = GetNumShapeshiftForms()
	
	-- Deactivate the previous shapeshift form first
	
	local vActiveForm
	
	for vIndex = 1, vNumForms do
		local vTexture, vName, vIsActive, vIsCastable = GetShapeshiftFormInfo(vIndex)
		
		_, _, vTexture = vTexture:find("([^\\]+)$")
		
		-- self:TestMessage("%s texture = %s (%d) %s", vName, vTexture, vTexture:len(), tern(vIsActive, "ACTIVE", "not active"))
		
		local vShapeshiftInfo = self.cShapeshiftTextureInfo[vTexture]
		
		if vShapeshiftInfo then
			self.Settings.ShapeshiftIndexInfo[vIndex] = vShapeshiftInfo
		else
			vShapeshiftInfo = self.Settings.ShapeshiftIndexInfo[vIndex]
		end
		
		if vShapeshiftInfo then
			if not vIsActive then
				self:UpdateShapeshiftInfo(vShapeshiftInfo, false)
			else
				vActiveForm = vShapeshiftInfo
			end
		end
	end
	
	-- Substitute the druid caster pseudo-form if necessary or deactivate it
	-- if it's not
	
	if self.PlayerClass == "DRUID" then
		if not vActiveForm then
			vActiveForm = self.cShapeshiftTextureInfo.CasterForm
		else
			self:UpdateShapeshiftInfo(self.cShapeshiftTextureInfo.CasterForm, false)
		end
	end
	
	-- Activate the new form
	
	if vActiveForm then
		self:UpdateShapeshiftInfo(vActiveForm, true)
	end
	
	self:EndEquipmentUpdate()
end

function Outfitter:UpdateShapeshiftInfo(pShapeshiftInfo, pIsActive)
	-- Ensure a proper boolean
	
	if pIsActive then
		pIsActive = true
	else
		pIsActive = false
	end
	
	--
	
	if self.SpecialState[pShapeshiftInfo.ID] == nil then
		self.SpecialState[pShapeshiftInfo.ID] = self:WearingOutfitWithScriptID(pShapeshiftInfo.ID)
	end
	
	if self.SpecialState[pShapeshiftInfo.ID] ~= pIsActive then
		if pIsActive and pShapeshiftInfo.MaybeInCombat then
			self.MaybeInCombat = true
		end
		
		self:SetSpecialOutfitEnabled(pShapeshiftInfo.ID, pIsActive)
	end
end

function Outfitter:SetSpecialOutfitEnabled(pSpecialID, pEnable)
	-- Ensure a proper boolean
	
	if pEnable then
		pEnable = true
	else
		pEnable = false
	end
	
	if self.SpecialState[pSpecialID] == pEnable then
		return
	end
	
	-- Suspend or resume monitoring the player health
	-- if the dining outfit is being changed
	
	if pSpecialID == "Dining" and pEnable then
		MCEventLib:RegisterEvent("UNIT_HEALTH", self.UnitHealthOrManaChanged, self, true) -- Register as a blind event handler
	else
		MCEventLib:UnregisterEvent("UNIT_HEALTH", self.UnitHealthOrManaChanged, self)
	end
	
	--
	
	self.SpecialState[pSpecialID] = pEnable
	
	-- Dispatch the special ID events
	
	local vEvents = self.cSpecialIDEvents[pSpecialID]
	
	if vEvents then
		if pEnable then
			MCEventLib:DispatchEvent(vEvents.Equip)
		else
			MCEventLib:DispatchEvent(vEvents.Unequip)
		end
	else
		self:ErrorMessage("No events found for "..pSpecialID)
	end
end

function Outfitter:WearingOutfitWithScriptID(pSpecialID)
	for vIndex, vOutfit in ipairs(self.OutfitStack.Outfits) do
		if vOutfit.ScriptID == pSpecialID then
			return true, vIndex
		end
	end
end

function Outfitter:ScheduleUpdateZone()
	MCSchedulerLib:RescheduleTask(0.01, self.UpdateZone, self)
end

function Outfitter:UpdateZone()
	local vCurrentZone = GetZoneText()
	
	-- Just return if the zone isn't changing
	
	if vCurrentZone == self.CurrentZone then
		return
	end
	
	self.CurrentZone = vCurrentZone
	self.CurrentZoneIDs = self:GetCurrentZoneIDs(self.CurrentZoneIDs)
	
	self:BeginEquipmentUpdate()
	
	--
	
	for _, vSpecialID in ipairs(self.cZoneSpecialIDs) do
		local vIsActive = self.CurrentZoneIDs[vSpecialID] == true
		local vCurrentIsActive = self.SpecialState[vSpecialID]
		
		if vCurrentIsActive == nil then
			vCurrentIsActive = self:WearingOutfitWithScriptID(vSpecialID)
			self.SpecialState[vSpecialID] = vCurrentIsActive
		end
		
		self:SetSpecialOutfitEnabled(vSpecialID, vIsActive)
	end
	
	self:EndEquipmentUpdate()
end

function Outfitter:GetCurrentZoneIDs(pRecycleTable)
	local vZoneIDs = self:RecycleTable(pRecycleTable)
	
	local vZoneSpecialIDMap = self.cZoneSpecialIDMap[self.CurrentZone]
	local vPVPType, vIsArena, vFactionName = GetZonePVPInfo()
	
	if vZoneSpecialIDMap then
		for _, vZoneSpecialID in ipairs(vZoneSpecialIDMap) do
			if vZoneSpecialID ~= "City" or vPVPType ~= "hostile" then
				vZoneIDs[vZoneSpecialID] = true
			end
		end
	end
	
	return vZoneIDs
end

function Outfitter:InZoneType(pZoneType)
	return self.CurrentZoneIDs[pZoneType] == true
end

function Outfitter:InBattlegroundZone()
	return self:InZoneType("Battleground")
end

function Outfitter:SetAllSlotEnables(pEnable)
	for _, vInventorySlot in ipairs(self.cSlotNames) do
		self:SetSlotEnable(vInventorySlot, pEnable)
	end
	
	self:OutfitSettingsChanged(self.SelectedOutfit)
	self:Update(true)
end

function Outfitter:OutfitIsComplete(pOutfit, pIgnoreAmmoSlot)
	for _, vInventorySlot in ipairs(self.cSlotNames) do
		if not pOutfit.Items[vInventorySlot]
		and (not pIgnoreAmmoSlot or vInventorySlot ~= "AmmoSlot") then
			return false
		end
	end
	
	return true
end

function Outfitter:CalculateOutfitCategory(pOutfit)
	local vIgnoreAmmoSlot = UnitHasRelicSlot("player")

	if self:OutfitIsComplete(pOutfit, vIgnoreAmmoSlot) then
		return "Complete"
	else
		return "Accessory"
	end
end

function Outfitter:OutfitSettingsChanged(pOutfit)
	if not pOutfit then
		return
	end
	
	local vTargetCategoryID = self:CalculateOutfitCategory(pOutfit)
	
	if pOutfit.CategoryID ~= vTargetCategoryID then
		local vOutfitCategoryID, vOutfitIndex = self:FindOutfit(pOutfit)
		
		if not vOutfitCategoryID then
			self:ErrorMessage(pOutfit.Name.." not found in outfit list")
			return
		end
		
		if vOutfitCategoryID ~= pOutfit.CategoryID then
			self:DebugMessage("OutfitSettingsChanged: "..pOutfit.Name.." says it's in "..pOutfit.CategoryID.." but it's in "..vOutfitCategoryID)
		end
		
		table.remove(self.Settings.Outfits[vOutfitCategoryID], vOutfitIndex)
		
		self:AddOutfit(pOutfit)
	end
	
	self.DisplayIsDirty = true
	
	self:DispatchOutfitEvent("EDIT_OUTFIT", pOutfit.Name, pOutfit)
end

function Outfitter:DeleteOutfit(pOutfit)
	local vWearingOutfit = self:WearingOutfit(pOutfit)
	local vOutfitCategoryID, vOutfitIndex = self:FindOutfit(pOutfit)
	
	if not vOutfitCategoryID then
		return
	end
	
	self:DeactivateScript(pOutfit)
	
	-- Delete the outfit
	
	table.remove(self.Settings.Outfits[vOutfitCategoryID], vOutfitIndex)
	
	-- Deselect the outfit
	
	if pOutfit == self.SelectedOutfit then
		self:ClearSelection()
	end
	
	-- Remove the outfit if it's being worn
	
	self:RemoveOutfit(pOutfit)
	
	--
	
	self.DisplayIsDirty = true
	
	self:DispatchOutfitEvent("DELETE_OUTFIT", pOutfit.Name, pOutfit)
end

function Outfitter:AddOutfit(pOutfit)
	local vCategoryID
	
	vCategoryID = self:CalculateOutfitCategory(pOutfit)
	
	if not self.Settings.Outfits then
		self.Settings.Outfits = {}
	end
	
	if not self.Settings.Outfits[vCategoryID] then
		self.Settings.Outfits[vCategoryID] = {}
	end
	
	table.insert(self.Settings.Outfits[vCategoryID], pOutfit)
	pOutfit.CategoryID = vCategoryID
	
	self.DisplayIsDirty = true
	
	self:DispatchOutfitEvent("ADD_OUTFIT", pOutfit.Name, pOutfit)
	
	return vCategoryID
end

function Outfitter:SlotEnableClicked(pCheckbox, pButton)
	-- If the user is attempting to drop an item put it in the slot for them
	
	if CursorHasItem() then
		PickupInventoryItem(self.cSlotIDs[pCheckbox.SlotName])
		return
	end
	
	--
	
	local vChecked = pCheckbox:GetChecked()
	
	if pCheckbox.IsUnknown then
		pCheckbox.IsUnknown = false
		pCheckbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		vChecked = true
	end
	
	self:SetSlotEnable(pCheckbox.SlotName, vChecked)
	self:OutfitSettingsChanged(self.SelectedOutfit)
	self:Update(true)
end

function Outfitter:FindMultipleItemLocation(pItems, pEquippableItems)
	for vListIndex, vListItem in ipairs(pItems) do
		local vItem = self.ItemList_FindItemOrAlt(pEquippableItems, vListItem)
		
		if vItem then
			return vItem, vListItem
		end
	end
	
	return nil, nil
end

function Outfitter:FindAndAddItemsToOutfit(pOutfit, pSlotName, pItems, pEquippableItems)
	vItemLocation, vItem = self:FindMultipleItemLocation(pItems, pEquippableItems)
	
	if vItemLocation then
		local vInventorySlot = pSlotName
		
		if not vInventorySlot then
			vInventorySlot = vItemLocation.ItemSlotName
		end
		
		self:AddOutfitItem(pOutfit, vInventorySlot, vItem)
	end
end

function Outfitter:IsInitialized()
	return self.Initialized
end

function Outfitter:InitializationCheck()
	-- Don't initialize for a short time after WoW comes up to allow
	-- time for WoW to load inventory, bags, talent trees, etc.
	
	MCSchedulerLib:RescheduleTask(1, self.Initialize, self)
end

function Outfitter:Initialize()
	if self.Initialized then
		return
	end
	
	-- Unregister the initialization events
	
	for vEventID, _ in pairs(self.cInitializationEvents) do
		MCEventLib:UnregisterEvent(vEventID, self.InitializationCheck, self)
	end
	
	-- Makes sure they're not upgrading with a reloadui when there are new files
	
	if not self._QuickSlots
	or not self._OutfitIterator
	or not self.BuildEquipmentChangeList then
		OutfitterMinimapButton:Hide() -- Remove access to Outfitter so more errors don't start coming up
		OutfitterButtonFrame:Hide()
		StaticPopup_Show("OUTFITTER_CANT_RELOADUI")
		return
	end
	
	self.MenuManager = self:NewObject(self._MenuManager)
	-- self.MenuManager:Test()
	
	--
	
	local _, vPlayerClass = UnitClass("player")
	
	self.PlayerClass = vPlayerClass
	
	-- Initialize the main UI tabs
	
	self._SidebarWindowFrame.Construct(OutfitterFrame)
	
	PanelTemplates_SetNumTabs(OutfitterFrame, #self.cPanelFrames)
	OutfitterFrame.selectedTab = self.CurrentPanel
	PanelTemplates_UpdateTabs(OutfitterFrame)
	
	-- Install the /outfit command handler

	SlashCmdList.OUTFITTER = function (pCommand) Outfitter:ExecuteCommand(pCommand) end
	SLASH_OUTFITTER1 = "/outfitter"
	
	if not SlashCmdList.UNEQUIP then
		SlashCmdList.UNEQUIP = self.UnequipItemByName
		SLASH_UNEQUIP1 = "/unequip"
	end
	
	-- Initialize the slot ID map
	
	self.cSlotIDs = {}
	self.cSlotIDToInventorySlot = {}
		
	for _, vInventorySlot in ipairs(self.cSlotNames) do
		local vSlotID = GetInventorySlotInfo(vInventorySlot)
		
		self.cSlotIDs[vInventorySlot] = vSlotID
		self.cSlotIDToInventorySlot[vSlotID] = vInventorySlot
	end
	
	-- Initialize the settings
	
	if not gOutfitter_Settings then
		self:InitializeSettings()
	else
		self.Settings = gOutfitter_Settings
	end
	
	if not gOutfitter_GlobalSettings then
		self:InitializeGlobalSettings()
	end
	
	-- Initialize the outfits
	
	self.CurrentOutfit = self:GetInventoryOutfit()
	
	if not self.Settings.Outfits then
		self:InitializeOutfits()
	end
	
	self:CheckDatabase()
	
	-- Initialize the outfit stack
	
	self.OutfitStack:Initialize()
	
	-- Clean up any recent complete outfits which don't exist as
	-- well as duplicate entries
	
	local vUsedRecentNames = {}
	
	for vIndex = #self.Settings.RecentCompleteOutfits, 1, -1 do
		local vName = self.Settings.RecentCompleteOutfits[vIndex]
		
		if not self:FindOutfitByName(vName)
		or vUsedRecentNames[vName] then
			table.remove(self.Settings.RecentCompleteOutfits, vIndex)
		else
			vUsedRecentNames[vName] = true
		end
	end
	
	-- Set the minimap button
	
	if self.Settings.Options.HideMinimapButton then
		OutfitterMinimapButton:Hide()
	else
		OutfitterMinimapButton:Show()
	end
	
	if not self.Settings.Options.MinimapButtonAngle
	and not self.Settings.Options.MinimapButtonX then
		self.Settings.Options.MinimapButtonAngle = -1.5708
	end
	
	if self.Settings.Options.MinimapButtonAngle then
		self.MinimapButton_SetPositionAngle(self.Settings.Options.MinimapButtonAngle)
	else
		self.MinimapButton_SetPosition(self.Settings.Options.MinimapButtonX, self.Settings.Options.MinimapButtonY)
	end
	
	-- Initialize player state
	
	self.SpiritRegenEnabled = true
	
	-- Done initializing
	
	self.Initialized = true
	
	-- Make sure the outfit state is good
	
	self:SetSpecialOutfitEnabled("Riding", false)
	self:SetSpecialOutfitEnabled("Spirit", false)
	self:UpdateAuraStates()
	
	-- Start listening for events
	
	MCEventLib:RegisterEvent("PLAYER_ENTERING_WORLD", self.SchedulePlayerEnteringWorld, self)
	MCEventLib:RegisterEvent("PLAYER_LEAVING_WORLD", self.PlayerLeavingWorld, self)
	
	-- For monitoring mounted, dining and shadowform states
	
	MCEventLib:RegisterEvent("UNIT_AURA", self.UnitAuraChanged, self)
	
	hooksecurefunc("ShapeshiftBar_UpdateState", function () MCSchedulerLib:ScheduleUniqueTask(0.01, self.UpdateShapeshiftState, self) end)
	
	-- For monitoring plaguelands and battlegrounds
	
	MCEventLib:RegisterEvent("ZONE_CHANGED_NEW_AREA", self.ScheduleUpdateZone, self)
	MCEventLib:RegisterEvent("ZONE_CHANGED", self.ScheduleUpdateZone, self)
	MCEventLib:RegisterEvent("ZONE_CHANGED_INDOORS", self.ScheduleUpdateZone, self)
	
	-- For monitoring player combat state
	
	MCEventLib:RegisterEvent("PLAYER_REGEN_ENABLED", self.RegenEnabled, self)
	MCEventLib:RegisterEvent("PLAYER_REGEN_DISABLED", self.RegenDisabled, self)
	
	-- For monitoring player dead/alive state
	
	MCEventLib:RegisterEvent("PLAYER_DEAD", self.PlayerDead, self)
	MCEventLib:RegisterEvent("PLAYER_ALIVE", self.PlayerAlive, self)
	MCEventLib:RegisterEvent("PLAYER_UNGHOST", self.PlayerAlive, self)
	
	MCEventLib:RegisterEvent("UNIT_INVENTORY_CHANGED", self.UnitInventoryChanged, self, true) -- Register as a blind event handler (no event id param)

	-- For indicating which outfits are missing items
	
	MCEventLib:RegisterEvent("BAG_UPDATE", self.BagUpdate, self)
	MCEventLib:RegisterEvent("PLAYERBANKSLOTS_CHANGED", self.BankSlotsChanged, self)
	
	-- For monitoring bank bags
	
	MCEventLib:RegisterEvent("BANKFRAME_OPENED", self.BankFrameOpened, self)
	MCEventLib:RegisterEvent("BANKFRAME_CLOSED", self.BankFrameClosed, self)
	
	-- For unequipping the dining outfit
	
	MCEventLib:RegisterEvent("UNIT_MANA", self.UnitHealthOrManaChanged, self, true) -- Register as a blind event handler (no event id param)
	
	-- For monitoring spellcasts
	
--[[
	for _, vEventID in ipairs({
		"UNIT_SPELLCAST_CHANNEL_START",
		"UNIT_SPELLCAST_CHANNEL_STOP",
		"UNIT_SPELLCAST_CHANNEL_UPDATE",
		"UNIT_SPELLCAST_DELAYED",
		"UNIT_SPELLCAST_FAILED",
		"UNIT_SPELLCAST_FAILED_QUIET",
		"UNIT_SPELLCAST_INTERRUPTED",
		"UNIT_SPELLCAST_SENT",
		"UNIT_SPELLCAST_START",
		"UNIT_SPELLCAST_STOP",
		"UNIT_SPELLCAST_SUCCEEDED",
		"UNIT_SPELLMISS"
	}) do
		MCEventLib:RegisterEvent(vEventID, self.UnitSpellcastDebug, self)
	end
]]
	
	MCEventLib:RegisterEvent("UNIT_SPELLCAST_SENT", self.UnitSpellcastSent, self)
	MCEventLib:RegisterEvent("UNIT_SPELLCAST_START", self.UnitSpellcastSent, self)
	
	MCEventLib:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", self.UnitSpellcastStop, self)
	MCEventLib:RegisterEvent("UNIT_SPELLCAST_STOP", self.UnitSpellcastStop, self)
	
	MCEventLib:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", self.UnitSpellcastChannelStart, self)
	MCEventLib:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.UnitSpellcastChannelStop, self)
	
	MCEventLib:RegisterEvent("UNIT_SPELLCAST_FAILED", self.UnitSpellcastStop, self)
	MCEventLib:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET", self.UnitSpellcastStop, self)
	MCEventLib:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self.UnitSpellcastStop, self)
	
	--
	
	MCEventLib:RegisterEvent("CHARACTER_POINTS_CHANGED", self.TalentsChanged, self)
	self:TalentsChanged()
	
	-- Patch GameTooltip so we can monitor hide/show events
	
	self.HookScript(GameTooltip, "OnShow", self.GameToolTip_OnShow)
	self.HookScript(GameTooltip, "OnHide", self.GameToolTip_OnHide)
	
	--
	
	self:DispatchOutfitEvent("OUTFITTER_INIT")
	
	MCSchedulerLib:ScheduleUniqueRepeatingTask(0.5, self.UpdateSwimming, self, nil, "Outfitter:UpdateSwimming")
	
	-- Activate all outfit scripts
	
	if not self.Settings.Options.DisableAutoSwitch then
		self:ActivateAllScripts()
	end
	
	-- Install the "Used by outfits" tooltip feature
	
	GameTooltip.Outfitter_OrigSetBagItem = GameTooltip.SetBagItem
	GameTooltip.SetBagItem = self.GameTooltip_SetBagItem
	
	GameTooltip.Outfitter_OrigSetInventoryItem = GameTooltip.SetInventoryItem
	GameTooltip.SetInventoryItem = self.GameTooltip_SetInventoryItem
	
	-- Fire things up with a simulated entrance
	
	self:SchedulePlayerEnteringWorld()
end

function Outfitter:InitializeSettings()
	gOutfitter_Settings =
	{
		Version = 17,
		Options = {},
		LastOutfitStack = {},
		LayerIndex = {},
		RecentCompleteOutfits = {},
	}
	
	self.Settings = gOutfitter_Settings
	
	self.OutfitBar:InitializeSettings()
end

function Outfitter:InitializeGlobalSettings()
	gOutfitter_GlobalSettings =
	{
		Version = 1,
		SavedScripts = {},
	}
end

function Outfitter:InitializeOutfits()
	local vOutfit, vItemLocation, vItem
	local vEquippableItems = Outfitter.ItemList_GetEquippableItems(true)
	
	-- Create the outfit categories
	
	gOutfitter_Settings.Outfits = {}
	
	for vCategoryIndex, vCategoryID in ipairs(Outfitter.cCategoryOrder) do
		gOutfitter_Settings.Outfits[vCategoryID] = {}
	end

	-- Create the normal outfit using the current
	-- inventory and set it as the currently equipped outfit
	
	vOutfit = Outfitter:GetInventoryOutfit(Outfitter.cNormalOutfit)
	Outfitter:AddOutfit(vOutfit)
	gOutfitter_Settings.LastOutfitStack = {{Name = Outfitter.cNormalOutfit}}
	Outfitter.OutfitStack.Outfits = {vOutfit}
	
	-- Create the naked outfit
	
	vOutfit = Outfitter:NewNakedOutfit(Outfitter.cNakedOutfit)
	Outfitter:AddOutfit(vOutfit)
	
	-- Generate the smart outfits
	
	for vSmartIndex, vSmartOutfit in ipairs(Outfitter.cSmartOutfits) do
		vOutfit = Outfitter:GenerateSmartOutfit(vSmartOutfit.Name, vSmartOutfit.StatID, vEquippableItems)
		
		if vOutfit then
			vOutfit.ScriptID = vSmartOutfit.ScriptID
			Outfitter:AddOutfit(vOutfit)
		end
	end
	
	Outfitter:InitializeSpecialOccasionOutfits()
end

function Outfitter:CreateEmptySpecialOccasionOutfit(pScriptID, pName)
	vOutfit = Outfitter:GetOutfitByScriptID(pScriptID)
	
	if vOutfit then
		return
	end
	
	vOutfit = Outfitter:NewEmptyOutfit(pName)
	vOutfit.ScriptID = pScriptID
	
	Outfitter:AddOutfit(vOutfit)
end

function Outfitter:InitializeSpecialOccasionOutfits()
	local vEquippableItems = Outfitter.ItemList_GetEquippableItems(true)
	local vOutfit
	
	-- Find an argent dawn trinket and set the argent dawn outfit
	--[[ Taking this out since post-TBC it's largely irrelevant
	vOutfit = Outfitter:GetOutfitByScriptID("ArgentDawn")
	
	if not vOutfit then
		vOutfit = Outfitter:GenerateSmartOutfit(Outfitter.cArgentDawnOutfit, "ArgentDawn", vEquippableItems, true)
		vOutfit.ScriptID = "ArgentDawn"
		Outfitter:AddOutfit(vOutfit)
	end
	]]--
	-- Find riding items
	
	vOutfit = Outfitter:GetOutfitByScriptID("Riding")
	
	if not vOutfit then
		vOutfit = Outfitter:GenerateSmartOutfit(Outfitter.cRidingOutfit, "Riding", vEquippableItems, true)
		vOutfit.ScriptID = "Riding"
		vOutfit.ScriptSettings = {}
		vOutfit.ScriptSettings.DisableBG = true -- Default to disabling in BGs since that appears to be the most popular
		Outfitter:AddOutfit(vOutfit)
	end
	
	-- Create the Battlegrounds outfits
	
	Outfitter:CreateEmptySpecialOccasionOutfit("Battleground", Outfitter.cBattlegroundOutfit)
	
	-- Create the swimming outfit
	
	Outfitter:CreateEmptySpecialOccasionOutfit("Swimming", Outfitter.cSwimmingOutfit)
	
	-- Create class-specific outfits
	
	Outfitter:InitializeClassOutfits()
end

function Outfitter:InitializeClassOutfits()
	local vOutfits = Outfitter.cClassSpecialOutfits[Outfitter.PlayerClass]
	
	if not vOutfits then
		return
	end
	
	for vIndex, vOutfitInfo in ipairs(vOutfits) do
		Outfitter:CreateEmptySpecialOccasionOutfit(vOutfitInfo.ScriptID, vOutfitInfo.Name)
	end
end

function Outfitter:TooltipContainsText(pTooltip, pText)
	local vTooltipName = pTooltip:GetName()
	
	for vLineIndex = 1, 100 do
		local vLeftTextFrame = getglobal(vTooltipName.."TextLeft"..vLineIndex)
		
		if not vLeftTextFrame then
			break
		end
		
		local vLeftText = vLeftTextFrame:GetText()
		
		if vLeftText
		and string.find(vLeftText, pText) then
			return true
		end
	end -- for vLineIndex
	
	return false
end

function Outfitter:CanEquipBagItem(pBagIndex, pBagSlotIndex)
	local vItemInfo = Outfitter:GetBagItemInfo(pBagIndex, pBagSlotIndex)
	
	if vItemInfo
	and vItemInfo.MinLevel
	and UnitLevel("player") < vItemInfo.MinLevel then
		return false
	end
	
	return true
end

function Outfitter:BagItemWillBind(pBagIndex, pBagSlotIndex)
	local vItemLink = GetContainerItemLink(pBagIndex, pBagSlotIndex)
	
	if not vItemLink then
		return nil
	end
	
	OutfitterTooltip:SetOwner(OutfitterFrame, "ANCHOR_BOTTOMRIGHT", 0, 0)
	OutfitterTooltip:SetBagItem(pBagIndex, pBagSlotIndex)
	
	local vIsBOE = Outfitter:TooltipContainsText(OutfitterTooltip, ITEM_BIND_ON_EQUIP)
	
	OutfitterTooltip:Hide()
	
	return vIsBOE
end

function Outfitter:GenerateSmartOutfit(pName, pStatID, pEquippableItems, pAllowEmptyOutfit)
	local vOutfit = Outfitter:NewEmptyOutfit(pName)
	
	if pStatID == "TANKPOINTS" then
		return
	end
	
	local vItems = Outfitter.cStatIDItems[pStatID]
	
	Outfitter.ItemList_ResetIgnoreItemFlags(pEquippableItems)
	
	if vItems then
		Outfitter:FindAndAddItemsToOutfit(vOutfit, nil, vItems, pEquippableItems)
	end
	
	Outfitter:AddItemsWithStatToOutfit(vOutfit, pStatID, pEquippableItems)
	
	if not pAllowEmptyOutfit
	and Outfitter:IsEmptyOutfit(vOutfit) then
		return nil
	end
	
	vOutfit.StatID = pStatID
	
	return vOutfit
end

function Outfitter:ArrayIsEmpty(pArray)
	if not pArray then
		return true
	end
	
	return next(pArray) == nil
end

function Outfitter.NameOutfit_Open(pOutfit)
	gOutfitter_OutfitToRename = pOutfit
	
	if gOutfitter_OutfitToRename then
		OutfitterNameOutfitDialogTitle:SetText(Outfitter.cRenameOutfit)
		OutfitterNameOutfitDialog:SetHeight(OutfitterNameOutfitDialog.baseHeight - 70)
		
		OutfitterNameOutfitDialogName:SetText(gOutfitter_OutfitToRename.Name)
		
		OutfitterNameOutfitDialogAutomation:Hide()
		
		OutfitterNameOutfitDialogCreateUsing:Hide()
	else
		OutfitterNameOutfitDialogTitle:SetText(Outfitter.cNewOutfit)
		OutfitterNameOutfitDialog:SetHeight(OutfitterNameOutfitDialog.baseHeight)
		
		OutfitterNameOutfitDialogName:SetText("")
		
		Outfitter.DropDown_SetSelectedValue(OutfitterNameOutfitDialogAutomation, "NONE")
		OutfitterNameOutfitDialogAutomation:Show()
		OutfitterNameOutfitDialogAutomation.ChangedValueFunc = Outfitter.NameOutfit_PresetScriptChanged
		
		Outfitter.DropDown_SetSelectedValue(OutfitterNameOutfitDialogCreateUsing, "EMPTY")
		OutfitterNameOutfitDialogCreateUsing:Show()
		OutfitterNameOutfitDialogCreateUsing.ChangedValueFunc = Outfitter.NameOutfit_CheckForStatOutfit
	end
	
	OutfitterNameOutfitDialog:Show()
	OutfitterNameOutfitDialogName:SetFocus()
end

function Outfitter.NameOutfit_PresetScriptChanged(pMenu, pValue)
	Outfitter.DropDown_SetSelectedValue(pMenu, pValue)
	
	-- Set the default name if there isn't one or it's the previous default
	
	local vName = OutfitterNameOutfitDialogName:GetText()
	
	if pValue ~= "NONE"
	and (not vName or vName == "" or vName == OutfitterNameOutfitDialog.PreviousDefaultName) then
		vName = Outfitter:GetPresetScriptByID(pValue).Name
		
		OutfitterNameOutfitDialogName:SetText(vName)
		OutfitterNameOutfitDialog.PreviousDefaultName = vName
	end
end

function Outfitter.NameOutfit_CheckForStatOutfit(pMenu, pValue)
	Outfitter.NameOutfit_Update(true)
end

function Outfitter.NameOutfit_Done()
	local vName = OutfitterNameOutfitDialogName:GetText()
	
	if vName
	and vName ~= "" then
		if gOutfitter_OutfitToRename then
			local vWearingOutfit = Outfitter:WearingOutfit(gOutfitter_OutfitToRename)
			
			if vWearingOutfit then
				Outfitter:DispatchOutfitEvent("UNWEAR_OUTFIT", gOutfitter_OutfitToRename.Name, gOutfitter_OutfitToRename)
			end
			
			gOutfitter_OutfitToRename.Name = vName
			Outfitter.DisplayIsDirty = true

			if vWearingOutfit then
				Outfitter:DispatchOutfitEvent("WEAR_OUTFIT", gOutfitter_OutfitToRename.Name, gOutfitter_OutfitToRename)
			end
		else
			-- Create the new outift
			
			local vStatID = UIDropDownMenu_GetSelectedValue(OutfitterNameOutfitDialogCreateUsing)
			local vOutfit
			
			if not vStatID
			or vStatID == 0 then
				vOutfit = Outfitter:GetInventoryOutfit(vName)
			elseif vStatID == "EMPTY" then
				vOutfit = Outfitter:NewEmptyOutfit(vName)
			else
				vOutfit = Outfitter:GenerateSmartOutfit(vName, vStatID, Outfitter.ItemList_GetEquippableItems(true))
			end
			
			if not vOutfit then
				vOutfit = Outfitter:NewEmptyOutfit(vName)
			end
			
			-- Add the outfit
			
			local vCategoryID = Outfitter:AddOutfit(vOutfit)
			
			-- Set the script
			
			local vScriptID = UIDropDownMenu_GetSelectedValue(OutfitterNameOutfitDialogAutomation)
			
			if vScriptID ~= "NONE" then
				Outfitter:SetScriptID(vOutfit, vScriptID)
			end
			
			-- Wear the outfit
			
			Outfitter:WearOutfit(vOutfit)
		end
	end
	
	OutfitterNameOutfitDialog:Hide()
	
	Outfitter:Update(true)
end

function Outfitter.NameOutfit_Cancel()
	OutfitterNameOutfitDialog:Hide()
end

function Outfitter.NameOutfit_Update(pCheckForStatOutfit)
	local vEnableDoneButton = true
	local vErrorMessage = nil
	
	-- If there's no name entered then disable the okay button
	
	local vName = OutfitterNameOutfitDialogName:GetText()
	
	if not vName
	or vName == "" then
		vEnableDoneButton = false
	else
		local vOutfit = Outfitter:FindOutfitByName(vName)
		
		if vOutfit
		and vOutfit ~= gOutfitter_OutfitToRename then
			vErrorMessage = Outfitter.cNameAlreadyUsedError
			vEnableDoneButton = false
		end
	end
	
	-- 
	
	if not vErrorMessage
	and pCheckForStatOutfit then
		local vStatID = UIDropDownMenu_GetSelectedValue(OutfitterNameOutfitDialogCreateUsing)
		
		if vStatID
		and vStatID ~= 0
		and vStatID ~= "EMPTY" then
			local vOutfit = Outfitter:GenerateSmartOutfit("temp outfit", vStatID, Outfitter.ItemList_GetEquippableItems(true))
			
			if not vOutfit
			or Outfitter:IsEmptyOutfit(vOutfit) then
				vErrorMessage = Outfitter.cNoItemsWithStatError
			end
		end
	end
	
	if vErrorMessage then
		OutfitterNameOutfitDialogError:SetText(vErrorMessage)
		OutfitterNameOutfitDialogError:Show()
	else
		OutfitterNameOutfitDialogError:Hide()
	end
	
	Outfitter:SetButtonEnable(OutfitterNameOutfitDialogDoneButton, vEnableDoneButton)
end

function Outfitter:SetButtonEnable(pButton, pEnabled)
	if pEnabled then
		pButton:Enable()
		pButton:SetAlpha(1.0)
		pButton:EnableMouse(true)
		--getglobal(pButton:GetName().."Text"):SetAlpha(1.0)
	else
		pButton:Disable()
		pButton:SetAlpha(0.7)
		pButton:EnableMouse(false)
		--getglobal(pButton:GetName().."Text"):SetAlpha(0.7)
	end
end

function Outfitter:GetOutfitFromListItem(pItem)
	if pItem.isCategory then
		return nil
	end
	
	if not self.Settings.Outfits then
		return nil
	end
	
	local vOutfits = self.Settings.Outfits[pItem.categoryID]
	
	if not vOutfits then
		-- Error: outfit category not found
		return nil
	end
	
	return vOutfits[pItem.outfitIndex]
end

Outfitter.OutfitMenuActions = {}

function Outfitter.OutfitMenuActions.DELETE(pOutfit)
	Outfitter:AskDeleteOutfit(pOutfit)
end

function Outfitter.OutfitMenuActions.RENAME(pOutfit)
	Outfitter.NameOutfit_Open(pOutfit)
end

function Outfitter.OutfitMenuActions.SCRIPT_SETTINGS(pOutfit)
	OutfitterEditScriptDialog:Open(pOutfit)
end

function Outfitter.OutfitMenuActions.EDIT_SCRIPT(pOutfit)
	if pOutfit.ScriptID == nil and pOutfit.Script == nil then
		pOutfit.Script = pOutfit.SavedScript
		pOutfit.SavedScript = nil
	end
	
	OutfitterEditScriptDialog:Open(pOutfit, true)
end

function Outfitter.OutfitMenuActions.DISABLE(pOutfit)
	if pOutfit.Disabled then
		pOutfit.Disabled = nil
		Outfitter:ActivateScript(pOutfit)
	else
		pOutfit.Disabled = true
		Outfitter:DeactivateScript(pOutfit)
	end
	Outfitter:OutfitSettingsChanged(pOutfit)
end

function Outfitter.OutfitMenuActions.SHOWHELM(pOutfit)
	pOutfit.ShowHelm = true
	Outfitter.OutfitStack:UpdateOutfitDisplay()
	Outfitter:OutfitSettingsChanged(pOutfit)
end

function Outfitter.OutfitMenuActions.HIDEHELM(pOutfit)
	pOutfit.ShowHelm = false
	Outfitter.OutfitStack:UpdateOutfitDisplay()
	Outfitter:OutfitSettingsChanged(pOutfit)
end

function Outfitter.OutfitMenuActions.IGNOREHELM(pOutfit)
	pOutfit.ShowHelm = nil
	Outfitter.OutfitStack:UpdateOutfitDisplay()
	Outfitter:OutfitSettingsChanged(pOutfit)
end

function Outfitter.OutfitMenuActions.SHOWCLOAK(pOutfit)
	pOutfit.ShowCloak = true
	Outfitter.OutfitStack:UpdateOutfitDisplay()
	Outfitter:OutfitSettingsChanged(pOutfit)
end

function Outfitter.OutfitMenuActions.HIDECLOAK(pOutfit)
	pOutfit.ShowCloak = false
	Outfitter.OutfitStack:UpdateOutfitDisplay()
	Outfitter:OutfitSettingsChanged(pOutfit)
end

function Outfitter.OutfitMenuActions.IGNORECLOAK(pOutfit)
	pOutfit.ShowCloak = nil
	Outfitter.OutfitStack:UpdateOutfitDisplay()
	Outfitter:OutfitSettingsChanged(pOutfit)
end

function Outfitter.OutfitMenuActions.IGNORETITLE(pOutfit)
	pOutfit.ShowTitleID = nil
	Outfitter.OutfitStack:UpdateOutfitDisplay()
	Outfitter:OutfitSettingsChanged(pOutfit)
end

function Outfitter.OutfitMenuActions.COMBATDISABLE(pOutfit)
	if pOutfit.CombatDisabled then
		pOutfit.CombatDisabled = nil
	else
		pOutfit.CombatDisabled = true
	end
	
	Outfitter:OutfitSettingsChanged(pOutfit)
end

function Outfitter.OutfitMenuActions.REBUILD(pOutfit)
	Outfitter:AskRebuildOutfit(pOutfit)
end

function Outfitter.OutfitMenuActions.SET_CURRENT(pOutfit)
	Outfitter:AskSetCurrent(pOutfit)
end

function Outfitter.OutfitMenuActions.UNEQUIP_OTHERS(pOutfit)
	if pOutfit.UnequipOthers then
		pOutfit.UnequipOthers = nil
	else
		pOutfit.UnequipOthers = true
	end
	
	Outfitter:OutfitSettingsChanged(pOutfit)
end

function Outfitter.OutfitMenuActions.DEPOSIT(pOutfit)
	Outfitter:DepositOutfit(pOutfit)
end

function Outfitter.OutfitMenuActions.DEPOSITUNIQUE(pOutfit)
	Outfitter:DepositOutfit(pOutfit, true)
end

function Outfitter.OutfitMenuActions.WITHDRAW(pOutfit)
	Outfitter:WithdrawOutfit(pOutfit)
end

function Outfitter.OutfitMenuActions.OUTFITBAR_SHOW(pOutfit)
	local vSettings = Outfitter.OutfitBar:GetOutfitSettings(pOutfit)
	
	vSettings.Hide = not vSettings.Hide
	
	Outfitter:OutfitSettingsChanged(pOutfit)
end

function Outfitter.OutfitMenuActions.OUTFITBAR_CHOOSEICON(pOutfit)
	OutfitterChooseIconDialog:Open(pOutfit)
end

function Outfitter:PerformAction(pActionID, pOutfit)
	local vActionFunc = Outfitter.OutfitMenuActions[pActionID]
	
	if vActionFunc then
		vActionFunc(pOutfit)
	elseif string.sub(pActionID, 1, 8) == "BINDING_" then
		local vBindingIndex = string.sub(pActionID, 9)
		
		if vBindingIndex == "NONE" then
			Outfitter:SetOutfitBindingIndex(pOutfit, nil)
		else
			Outfitter:SetOutfitBindingIndex(pOutfit, tonumber(vBindingIndex))
		end
	elseif string.sub(pActionID, 1, 7) == "PRESET_" then
		local vScriptID = string.sub(pActionID, 8)
		
		if vScriptID == "NONE" then
			Outfitter:DeactivateScript(pOutfit)
			
			pOutfit.SavedScript = pOutfit.Script
			
			pOutfit.ScriptID = nil
			pOutfit.Script = nil
		else
			pOutfit.SavedScript = nil
			
			Outfitter:SetScriptID(pOutfit, vScriptID)
			
			-- If the script has settings then open the
			-- dialog
			
			if Outfitter:OutfitHasSettings(pOutfit) then
				OutfitterEditScriptDialog:Open(pOutfit)
			end
		end
		
		Outfitter:OutfitSettingsChanged(pOutfit)
	elseif string.sub(pActionID, 1, 6) == "TITLE_" then
		local vTitleID = tonumber(string.sub(pActionID, 7))
		
		pOutfit.ShowTitleID = vTitleID
		
		MCSchedulerLib:ScheduleUniqueTask(0.5, self.OutfitStack.UpdateOutfitDisplay, self.OutfitStack)
	else
		return
	end
	
	Outfitter:Update(true)
end

function Outfitter.OutfitItemSelected(pMenu, pValue)
	local vItem = pMenu:GetParent():GetParent()
	local vOutfit = Outfitter:GetOutfitFromListItem(vItem)

	if not vOutfit then
		Outfitter:ErrorMessage("Outfit for menu item "..vItem:GetName().." not found")
		return
	end

	Outfitter:PerformAction(pValue, vOutfit)
end

function Outfitter.PresetScriptDropDown_OnLoad(self)
	Outfitter:DropDownMenu_Initialize(self, Outfitter.PresetScriptDropdown_Initialize)
	self:SetMenuWidth(150)
	self:Refresh()
	
	self.AutoSetValue = true
	self.ChangedValueFunc = Outfitter.PresetScriptDropdown_ChangedValue
end

function Outfitter.PresetScriptDropdown_ChangedValue(pFrame, pValue)
	pFrame.Dialog:SetPresetScriptID(pValue)
end

function Outfitter.PresetScriptDropdown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	if UIDROPDOWNMENU_MENU_LEVEL == 2 then
		for _, vPresetScript in ipairs(Outfitter.PresetScripts) do
			if not vPresetScript.Class
			or vPresetScript.Class == Outfitter.PlayerClass then
				local vCategory = vPresetScript.Category or vPresetScript.Class or "GENERAL"
				
				if vCategory == UIDROPDOWNMENU_MENU_VALUE then
					UIDropDownMenu_AddButton({
						text = vPresetScript.Name,
						arg1 = vFrame,
						arg2 = vPresetScript.ID,
						value = vPresetScript.ID,
						func = Outfitter.DropDown_OnClick,
						tooltipTitle = vPresetScript.Name,
						tooltipText = Outfitter:GetScriptDescription(vPresetScript.Script),
						colorCode = NORMAL_FONT_COLOR_CODE,
					}, UIDROPDOWNMENU_MENU_LEVEL)
				end
			end
		end
	else
		local vCategory
		
		for _, vPresetScript in ipairs(Outfitter.PresetScripts) do
			if not vPresetScript.Class
			or vPresetScript.Class == Outfitter.PlayerClass then
				-- Start a new category if it's changing
				
				local vNewCategory = vPresetScript.Category or vPresetScript.Class or "GENERAL"
				
				if vCategory ~= vNewCategory then
					vCategory = vNewCategory
					
					UIDropDownMenu_AddButton({
						text = Outfitter.cScriptCategoryName[vCategory] or Outfitter.cClassName[vCategory],
						hasArrow = 1,
						arg1= vFrame,
						arg2 = vCategory,
						value = vCategory}, UIDROPDOWNMENU_MENU_LEVEL)
				end
			end
		end
	end
end

----------------------------------------
-- Outfitter.StatDropDown
----------------------------------------

function Outfitter.StatDropDown_OnLoad(self)
	Outfitter:DropDownMenu_Initialize(self, Outfitter.StatDropdown_Initialize)
	self:SetWidth(150)
	self:Refresh()

	self.AutoSetValue = true
end

function Outfitter.StatDropdown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
	
	if UIDROPDOWNMENU_MENU_LEVEL == 2 then
		for vStatIndex, vStatInfo in ipairs(Outfitter.cItemStatInfo) do
			if vStatInfo.Category == UIDROPDOWNMENU_MENU_VALUE then
				UIDropDownMenu_AddButton({text = vStatInfo.Name, arg1 = vFrame, arg2 = vStatInfo.ID, value = vStatInfo.ID, func = Outfitter.DropDown_OnClick}, UIDROPDOWNMENU_MENU_LEVEL)
			end
		end
	else
		UIDropDownMenu_AddButton({text = Outfitter.cUseCurrentOutfit, arg1 = vFrame, arg2 = 0, value = 0, func = Outfitter.DropDown_OnClick})
		UIDropDownMenu_AddButton({text = Outfitter.cUseEmptyOutfit, arg1 = vFrame, arg2 = "EMPTY", value = "EMPTY", func = Outfitter.DropDown_OnClick})
		
		UIDropDownMenu_AddButton({text = " ", notCheckable = true, notClickable = true})
		
		for vCategoryIndex, vCategoryInfo in ipairs(Outfitter.cStatCategoryInfo) do
			UIDropDownMenu_AddButton({text = vCategoryInfo.Name, hasArrow = 1, arg1 = vFrame, arg2 = vCategoryInfo.Category, value = vCategoryInfo.Category})
		end
		
		if false and IsAddOnLoaded("TankPoints") then
			UIDropDownMenu_AddButton({text = " ", notCheckable = true, notClickable = true})
			UIDropDownMenu_AddButton({text = Outfitter.cTankPoints, arg1 = vFrame, arg2 = "TANKPOINTS", value = "TANKPOINTS", func = Outfitter.DropDown_OnClick})
		end
	end
end

----------------------------------------
Outfitter._DropDownMenu = {}
----------------------------------------

function Outfitter:DropDownMenu_Initialize(pFrame, pInitFunction, pDisplayMode, pLevel, pMenuList)
	for vName, vFunction in pairs(self._DropDownMenu) do
		pFrame[vName] = vFunction
	end
	
	UIDropDownMenu_Initialize(pFrame, pInitFunction, pDisplayMode, pLevel, pMenuList)
end

function Outfitter._DropDownMenu:SetMenuWidth(pWidth, pPadding)
	UIDropDownMenu_SetWidth(self, pWidth, pPadding)
end

function Outfitter._DropDownMenu:SetMenuText(pText)
	UIDropDownMenu_SetText(self, pText)
end

function Outfitter._DropDownMenu:Refresh()
	UIDropDownMenu_Refresh(self)
end

function Outfitter._DropDownMenu:SetSelectedValue(pValue)
	UIDropDownMenu_SetSelectedValue(self, pValue)
end

----------------------------------------
-- Outfitter.AutomationDropDown
----------------------------------------

function Outfitter.AutomationDropDown_OnLoad(self)
	Outfitter:DropDownMenu_Initialize(self, Outfitter.AutomationDropdown_Initialize)
	self:SetMenuWidth(150)
	self:Refresh()
end

function Outfitter.AutomationDropdown_Initialize()
	local vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)

	if UIDROPDOWNMENU_MENU_LEVEL == 2 then
		for _, vPresetScript in ipairs(Outfitter.PresetScripts) do
			if not vPresetScript.Class
			or vPresetScript.Class == Outfitter.PlayerClass then
				local vCategory = vPresetScript.Category or vPresetScript.Class or "GENERAL"
				
				if vCategory == UIDROPDOWNMENU_MENU_VALUE then
					local vName = vPresetScript.Name
					local vDescription = Outfitter:GetScriptDescription(vPresetScript.Script)
					
					Outfitter:AddMenuItem(
							vFrame,
							vName,
							vPresetScript.ID,
							nil, -- Checked
							UIDROPDOWNMENU_MENU_LEVEL,
							nil, -- Color
							nil, -- Disabled
							{tooltipTitle = vName, tooltipText = vDescription})
				end
			end
		end
	else
		local vCategory
		
		Outfitter:AddMenuItem(vFrame, Outfitter.cNoScript, "NONE")
		
		local vCategory
		
		for _, vPresetScript in ipairs(Outfitter.PresetScripts) do
			if not vPresetScript.Class
			or vPresetScript.Class == Outfitter.PlayerClass then
				-- Start a new category if it's changing
				
				local vNewCategory = vPresetScript.Category or vPresetScript.Class or "GENERAL"
				
				if vCategory ~= vNewCategory then
					vCategory = vNewCategory
					
					UIDropDownMenu_AddButton({
						text = Outfitter.cScriptCategoryName[vCategory] or Outfitter.cClassName[vCategory],
						hasArrow = 1,
						arg1 = vFrame,
						arg2 = vCategory,
						colorCode = NORMAL_FONT_COLOR_CODE,
						value = vCategory}, UIDROPDOWNMENU_MENU_LEVEL)
				end
			end
		end
	end
end

----------------------------------------
-- 
----------------------------------------

function Outfitter:GetStatIDName(pStatID)
	for vStatIndex, vStatInfo in ipairs(Outfitter.cItemStatInfo) do
		if vStatInfo.ID == pStatID then
			return vStatInfo.Name
		end
	end
	
	return nil
end
--[[
function UIDropDownMenu_Refresh(frame, useValue, dropdownLevel)
	Outfitter:TestMessage("UIDropDownMenu_Refresh: frame selected value is %s", UIDropDownMenu_GetSelectedValue(frame) or "nil")
	
	local button, checked, checkImage, normalText, width;
	local maxWidth = 0;
	assert(frame);
	if ( not dropdownLevel ) then
		dropdownLevel = UIDROPDOWNMENU_MENU_LEVEL;
	end
	
	-- Just redraws the existing menu
	for i=1, UIDROPDOWNMENU_MAXBUTTONS do
		button = getglobal("DropDownList"..dropdownLevel.."Button"..i);
		Outfitter:TestMessage(" Examinging button %d, title %s, value is %s", i, button:GetText() or "nil", button.value or "nil")
		
		checked = nil;
		-- See if checked or not
		if ( UIDropDownMenu_GetSelectedName(frame) ) then
			if ( button:GetText() == UIDropDownMenu_GetSelectedName(frame) ) then
				checked = 1;
			end
		elseif ( UIDropDownMenu_GetSelectedID(frame) ) then
			if ( button:GetID() == UIDropDownMenu_GetSelectedID(frame) ) then
				checked = 1;
			end
		elseif ( UIDropDownMenu_GetSelectedValue(frame) ) then
			if ( button.value == UIDropDownMenu_GetSelectedValue(frame) ) then
				checked = 1;
			end
		end

		-- If checked show check image
		checkImage = getglobal("DropDownList"..dropdownLevel.."Button"..i.."Check");
		if ( checked ) then
			Outfitter:TestMessage(" Item is checked")
			
			if ( useValue ) then
				UIDropDownMenu_SetText(frame, button.value);
			else
				UIDropDownMenu_SetText(frame, button:GetText());
			end
			button:LockHighlight();
			checkImage:Show();
		else
			Outfitter:TestMessage(" Item is not checked")
			button:UnlockHighlight();
			checkImage:Hide();
		end

		if ( button:IsShown() ) then
			normalText = getglobal(button:GetName().."NormalText");
			-- Determine the maximum width of a button
			width = normalText:GetWidth() + 40;
			-- Add padding if has and expand arrow or color swatch
			if ( button.hasArrow or button.hasColorSwatch ) then
				width = width + 10;
			end
			if ( button.notCheckable ) then
				width = width - 30;
			end
			if ( width > maxWidth ) then
				maxWidth = width;
			end
		end
	end
	for i=1, UIDROPDOWNMENU_MAXBUTTONS do
		button = getglobal("DropDownList"..dropdownLevel.."Button"..i);
		button:SetWidth(maxWidth);
	end
	getglobal("DropDownList"..dropdownLevel):SetWidth(maxWidth+15);
end
]]

function Outfitter.DropDown_SetSelectedValue(pDropDown, pValue)
	pDropDown:SetMenuText("") -- Set to empty in case the selected value isn't there
	Outfitter:DropDownMenu_Initialize(pDropDown, pDropDown.initialize)
	pDropDown:SetSelectedValue(pValue)
	
	-- All done if the item text got set successfully
	
	local vItemText = UIDropDownMenu_GetText(pDropDown)
	
	if vItemText and vItemText ~= "" then
		return
	end
	
	-- Scan for submenus
	
	local vRootListFrameName = "DropDownList1"
	local vRootListFrame = getglobal(vRootListFrameName)
	local vRootNumItems = vRootListFrame.numButtons
	
	for vRootItemIndex = 1, vRootNumItems do
		local vItem = getglobal(vRootListFrameName.."Button"..vRootItemIndex)
		
		if vItem.hasArrow then
			local vSubMenuFrame = getglobal("DropDownList2")
			
			UIDROPDOWNMENU_OPEN_MENU = pDropDown:GetName()
			UIDROPDOWNMENU_MENU_VALUE = vItem.value
			UIDROPDOWNMENU_MENU_LEVEL = 2
			
			Outfitter:DropDownMenu_Initialize(pDropDown, pDropDown.initialize, nil, 2)
			pDropDown:SetSelectedValue(pValue)
			
			-- All done if the item text got set successfully
			
			local vItemText = UIDropDownMenu_GetText(pDropDown)
			
			if vItemText and vItemText ~= "" then
				return
			end
			
			-- Switch back to the root menu
			
			UIDROPDOWNMENU_OPEN_MENU = nil
			Outfitter:DropDownMenu_Initialize(pDropDown, pDropDown.initialize, nil, 1)
		end
	end
end

function Outfitter.ScrollbarTrench_SizeChanged(pScrollbarTrench)
	local vScrollbarTrenchName = pScrollbarTrench:GetName()
	local vScrollbarTrenchMiddle = getglobal(vScrollbarTrenchName.."Middle")
	
	local vMiddleHeight= pScrollbarTrench:GetHeight() - 51
	vScrollbarTrenchMiddle:SetHeight(vMiddleHeight)
end

function Outfitter.InputBox_OnLoad(self, pChildDepth)
	if not pChildDepth then
		pChildDepth = 0
	end
	
	local vParent = self:GetParent()
	
	for vDepthIndex = 1, pChildDepth do
		vParent = vParent:GetParent()
	end
	
	if vParent.lastEditBox then
		self.prevEditBox = vParent.lastEditBox
		self.nextEditBox = vParent.lastEditBox.nextEditBox
		
		self.prevEditBox.nextEditBox = self
		self.nextEditBox.prevEditBox = self
	else
		self.prevEditBox = self
		self.nextEditBox = self
	end

	vParent.lastEditBox = self
end

function Outfitter.InputBox_TabPressed(self)
	local vReverse = IsShiftKeyDown()
	local vEditBox = self
	
	for vIndex = 1, 50 do
		local vNextEditBox
			
		if vReverse then
			vNextEditBox = vEditBox.prevEditBox
		else
			vNextEditBox = vEditBox.nextEditBox
		end
		
		if vNextEditBox:IsVisible()
		and not vNextEditBox.isDisabled then
			vNextEditBox:SetFocus()
			return
		end
		
		vEditBox = vNextEditBox
	end
end

function Outfitter:ToggleUI(pToggleCharWindow)
	if self:IsOpen() then
		OutfitterFrame:Hide()
		
		if pToggleCharWindow then
			HideUIPanel(CharacterFrame)
		end
	else
		self:OpenUI()
	end
end

function Outfitter:OpenUI()
	ShowUIPanel(CharacterFrame)
	CharacterFrame_ShowSubFrame("PaperDollFrame")
	OutfitterFrame:Show()
end

function Outfitter:WearingOutfitName(pOutfitName)
	local vOutfit = Outfitter:FindOutfitByName(pOutfitName)
	
	return vOutfit and Outfitter:WearingOutfit(vOutfit)
end

function Outfitter:WearingOutfit(pOutfit)
	return Outfitter.OutfitStack:FindOutfit(pOutfit)
end

function Outfitter:CheckDatabase()
	local vOutfit
	
	if not gOutfitter_Settings.Version then
		local vOutfits = gOutfitter_Settings.Outfits[vCategoryID]
		
		if gOutfitter_Settings.Outfits then
			for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
				for vIndex, vOutfit in ipairs(vOutfits) do
					if self:OutfitIsComplete(vOutfit, true) then
						self:AddOutfitItem(vOutfit, "AmmoSlot", nil)
					end
				end
			end
		end
		
		gOutfitter_Settings.Version = 1
	end
	
	-- Versions 1 and 2 both simply add class outfits
	-- so just reinitialize those
	
	if gOutfitter_Settings.Version < 3 then
		self:InitializeClassOutfits()
		gOutfitter_Settings.Version = 3
	end
	
	-- Version 4 sets the BGDisabled flag for the mounted outfit
	
	if gOutfitter_Settings.Version < 4 then
		local vRidingOutfit = self:GetOutfitByScriptID("Riding")
		
		if vRidingOutfit then
			vRidingOutfit.BGDisabled = true
		end
		
		gOutfitter_Settings.Version = 4
	end
	
	-- Version 5 adds moonkin form, just reinitialize class outfits

	if gOutfitter_Settings.Version < 5 then
		self:InitializeClassOutfits()
		gOutfitter_Settings.Version = 5
	end
	
	-- Make sure all outfits have an associated category ID
	
	if gOutfitter_Settings.Outfits then
		for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
			for vIndex, vOutfit in ipairs(vOutfits) do
				vOutfit.CategoryID = vCategoryID
			end
		end
	end
	
	-- Version 6 and 7 adds item sub-code and enchantment codes
	-- (7 tries to clean up failed updates from 6)
	
	if gOutfitter_Settings.Version < 7 then
		MCSchedulerLib:ScheduleTask(5, Outfitter.UpdateDatabaseItemCodes, Outfitter)
		
		gOutfitter_Settings.Version = 7
	end
	
	-- Version 8 removes the old style cloak/helm settings
	
	if gOutfitter_Settings.Version < 8 then
		gOutfitter_Settings.HideHelm = nil
		gOutfitter_Settings.HideCloak = nil
		gOutfitter_Settings.Version = 8
	end
	
	-- Version 9 converts old SpecialIDs to ScriptIDs
	-- and removes the parial and special categories
	
	if gOutfitter_Settings.Version < 9 then
		local vUpdatedOutfits = {}
		local vDeletedOutfits = {}
		
		local vPreservedOutfits =
		{
			Battle = true,
			Defensive = true,
			Berserker = true,
			
			Bear = true,
			Cat = true,
			Aquatic = true,
			Travel = true,
			Moonkin = true,
			Tree = true,
			Prowl = true,
			Flight = true,

			Shadowform = true,

			Stealth = true,

			GhostWolf = true,

			Monkey = true,
			Hawk = true,
			Cheetah = true,
			Pack = true,
			Beast = true,
			Wild = true,
			Viper = true,
			Feigning = true,
			
			Evocate = true,
			
			ArgentDawn = true,

			Battleground = true,
		}
		
		for _, vOutfit in ipairs(gOutfitter_Settings.Outfits.Special) do
			if self:IsEmptyOutfit(vOutfit)
			and not vPreservedOutfits[vOutfit.SpecialID] then
				table.insert(vDeletedOutfits, vOutfit)
			else
				vOutfit.ScriptID = vOutfit.SpecialID
				vOutfit.SpecialID = nil
				
				table.insert(vUpdatedOutfits, vOutfit)
			end
		end
		
		--
		
		for _, vOutfit in ipairs(gOutfitter_Settings.Outfits.Partial) do
			vOutfit.IsAccessory = nil
			table.insert(vUpdatedOutfits, vOutfit)
		end
		
		--
		
		for _, vOutfit in ipairs(vUpdatedOutfits) do
			self:OutfitSettingsChanged(vOutfit)
		end
		
		for _, vOutfit in ipairs(vDeletedOutfits) do
			self:DeleteOutfit(vOutfit)
		end
		
		gOutfitter_Settings.Outfits.Special = nil
		gOutfitter_Settings.Outfits.Partial = nil
		
		gOutfitter_Settings.Version = 9
	end
	
	-- Version 10 eliminates the ScriptEvents field and moves
	-- it to the source instead
	
	if gOutfitter_Settings.Version < 10 then
		for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
			for vIndex, vOutfit in ipairs(vOutfits) do
				if vOutfit.Script and vOutfit.ScriptEvents then
					vOutfit.Script = "-- $EVENTS "..vOutfit.ScriptEvents.."\n"..vOutfit.Script
				end
				vOutfit.ScriptEvents = nil
			end
		end
		
		gOutfitter_Settings.Version = 10
	end
	
	-- Version 11 prevents scripted outfits from being treated as complete outfits
	
	if gOutfitter_Settings.Version < 11 then
		self:CheckOutfitCategories()
		gOutfitter_Settings.Version = 11
	end
	
	-- Version 12 moves the BGDisabled, AQDisabled and NaxxDisabled flags to
	-- the script settings for the riding outfiZt
	
	if gOutfitter_Settings.Version < 12 then
		local vRidingOutfit = self:GetOutfitByScriptID("Riding")
		
		if vRidingOutfit then
			if not vRidingOutfit.ScriptSettings then
				vRidingOutfit.ScriptSettings = {}
			end
			
			vRidingOutfit.ScriptSettings.DisableAQ40 = vRidingOutfit.AQDisabled
			vRidingOutfit.ScriptSettings.DisableBG = vRidingOutfit.BGDisabled
			vRidingOutfit.ScriptSettings.DisableNaxx = vRidingOutfit.NaxxDisabled
			
			vRidingOutfit.AQDisabled = nil
			vRidingOutfit.BGDisabled = nil
			vRidingOutfit.NaxxDisabled = nil
		end
		
		gOutfitter_Settings.Version = 12
	end
	
	-- Version 13 adds the LayerIndex table
	
	if gOutfitter_Settings.Version < 13 then
		gOutfitter_Settings.LayerIndex = {}
		gOutfitter_Settings.Version = 13
	end
	
	-- Version 14 updates all outfits with InvType fields
	
	if gOutfitter_Settings.Version < 14 then
		MCSchedulerLib:ScheduleTask(5, Outfitter.UpdateInvTypes, Outfitter)
		
		gOutfitter_Settings.Version = 14
	end
	
	-- Version 15 allows scripted outfits to be complete outfits
	
	if gOutfitter_Settings.Version < 15 then
		self:CheckOutfitCategories()
		gOutfitter_Settings.Version = 15
	end
	
	-- Version 16 adds the RecentCompleteOutfits list to the settings
	
	if gOutfitter_Settings.Version < 16 then
		gOutfitter_Settings.RecentCompleteOutfits = {}
		gOutfitter_Settings.Version = 16
	end
	
	-- Version 17 updates all outfits with SubType fields
	
	if gOutfitter_Settings.Version < 17 then
		MCSchedulerLib:ScheduleTask(5, Outfitter.UpdateSubTypes, Outfitter)
		
		gOutfitter_Settings.Version = 17
	end
	
	-- Repair missing settings
	
	if not gOutfitter_Settings.RecentCompleteOutfits then
		gOutfitter_Settings.RecentCompleteOutfits = {}
	end
	
	if not gOutfitter_Settings.LayerIndex then
		gOutfitter_Settings.LayerIndex = {}
	end
	
	if not gOutfitter_Settings.LastOutfitStack then
		gOutfitter_Settings.LastOutfitStack = {}
	end
	
	if not gOutfitter_Settings.RecentCompleteOutfits then
		gOutfitter_Settings.RecentCompleteOutfits = {}
	end
	
	if not gOutfitter_Settings.OutfitBar then
		gOutfitter_Settings.OutfitBar = {}
		gOutfitter_Settings.OutfitBar.ShowOutfitBar = true
	end
	
	-- Scan the outfits and make sure everything is in order
	
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vIndex, vOutfit in ipairs(vOutfits) do
			self:CheckOutfit(vOutfit, vCategoryID)
		end
	end
end

function Outfitter:CheckOutfitCategories()
	local vAllOutfits = {}
	
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for _, vOutfit in ipairs(vOutfits) do
			table.insert(vAllOutfits, vOutfit)
		end
	end
	
	for _, vOutfit in ipairs(vAllOutfits) do
		self:OutfitSettingsChanged(vOutfit)
	end
end

Outfitter.DefaultRepairValues =
{
	Code = 0,
	SubCode = 0,
	Name = "",
	EnchantCode = 0,
	JewelCode1 = 0,
	JewelCode2 = 0,
	JewelCode3 = 0,
	JewelCode4 = 0,
	UniqueID = 0,
}

function Outfitter:CheckOutfit(pOutfit, pCategoryID)
	if not pOutfit.Name then
		pOutfit.Name = "Damaged outfit"
	end
	
	if pOutfit.CategoryID ~= pCategoryID then
		pOutfit.CategoryID = pCategoryID
	end
	
	if not pOutfit.Items then
		pOutfit.Items = {}
	end
	
	for vInventorySlot, vItem in pairs(pOutfit.Items) do
		for vField, vDefaultValue in pairs(Outfitter.DefaultRepairValues) do
			if not vItem[vField] then
				vItem[vField] = vDefaultValue
			end
		end
	end
end

function Outfitter:UpdateInvTypes()
	local vEquippableItems = Outfitter.ItemList_GetEquippableItems()
	local vResult = true
	
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vIndex, vOutfit in ipairs(vOutfits) do
			for vInventorySlot, vOutfitItem in pairs(vOutfit.Items) do
				if vOutfitItem.Code ~= 0 then
					local vItem = Outfitter.ItemList_FindItemOrAlt(vEquippableItems, vOutfitItem, false, true)
					
					if vItem then
						vOutfitItem.InvType = vItem.InvType
					else
						vResult = false
					end
				end
			end
		end
	end
	
	return vResult
end

function Outfitter:UpdateSubTypes()
	local vEquippableItems = Outfitter.ItemList_GetEquippableItems()
	local vResult = true
	
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vIndex, vOutfit in ipairs(vOutfits) do
			for vInventorySlot, vOutfitItem in pairs(vOutfit.Items) do
				if vOutfitItem.Code ~= 0 then
					local vItem = Outfitter.ItemList_FindItemOrAlt(vEquippableItems, vOutfitItem, false, true)
					
					if vItem then
						vOutfitItem.SubType = vItem.SubType
					else
						vResult = false
					end
				end
			end
		end
	end
	
	return vResult
end

function Outfitter:UpdateDatabaseItemCodes()
	local vEquippableItems = self.ItemList_GetEquippableItems()
	local vResult = true
	
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vIndex, vOutfit in ipairs(vOutfits) do
			for vInventorySlot, vOutfitItem in pairs(vOutfit.Items) do
				if vOutfitItem.Code ~= 0 then
					local vItem = self.ItemList_FindItemOrAlt(vEquippableItems, vOutfitItem, false, true)
					
					if vItem then
						vOutfitItem.SubCode = vItem.SubCode
						vOutfitItem.Name = vItem.Name
						vOutfitItem.EnchantCode = vItem.EnchantCode
						vOutfitItem.JewelCode1 = vItem.JewelCode1
						vOutfitItem.JewelCode2 = vItem.JewelCode2
						vOutfitItem.JewelCode3 = vItem.JewelCode3
						vOutfitItem.JewelCode4 = vItem.JewelCode4
						vOutfitItem.UniqueID = vItem.UniqueID
						vOutfitItem.Checksum = nil
					else
						vResult = false
					end
				end
			end
		end
	end
	
	return vResult
end

function Outfitter:GetPlayerStat(pStatIndex)
	local _, vEffectiveValue, vPosValue, vNegValue = UnitStat("player", pStatIndex)
	
	return vEffectiveValue - vPosValue - vNegValue, vPosValue + vNegValue
end

function Outfitter:DepositOutfit(pOutfit, pUniqueItemsOnly)
	-- Deselect any outfits to avoid them from being updated when
	-- items get put away
	
	Outfitter:ClearSelection()
	
	-- Build a list of items for the outfit
	
	local vEquippableItems = Outfitter.ItemList_GetEquippableItems()
	
	Outfitter.ItemList_ResetIgnoreItemFlags(vEquippableItems)
	
	-- Make a copy of the outfit
	
	local vUnequipOutfit = Outfitter:NewEmptyOutfit()
	
	for vInventorySlot, vItem in pairs(pOutfit.Items) do
		vUnequipOutfit.Items[vInventorySlot] = vItem
	end
	
	-- Subtract out items from other outfits if unique is specified
	
	if pUniqueItemsOnly then
		for vCategoryID, vOutfits in pairs(self.Settings.Outfits) do
			for vOutfitIndex, vOutfit in ipairs(vOutfits) do
				if vOutfit ~= pOutfit then
					local vMissingItems, vBankedItems = Outfitter.ItemList_GetMissingItems(vEquippableItems, vOutfit)
					
					-- Only subtract out items from outfits which aren't themselves partialy banked
					
					if vBankedItems == nil then
						Outfitter:SubtractOutfit(vUnequipOutfit, vOutfit, true)
					end
				end -- if vOutfit
			end -- for vOutfitIndex
		end -- for vCategoryID
	end -- if pUniqueItemsOnly
	
	-- Build the change list
	
	Outfitter.ItemList_ResetIgnoreItemFlags(vEquippableItems)
	
	local vEquipmentChangeList = Outfitter:BuildUnequipChangeList(vUnequipOutfit, vEquippableItems)
	
	if not vEquipmentChangeList then
		return
	end
	
	-- Eliminate items which are already banked
	
	local vChangeIndex = 1
	local vNumChanges = #vEquipmentChangeList
	
	while vChangeIndex <= vNumChanges do
		vEquipmentChange = vEquipmentChangeList[vChangeIndex]
		
		if Outfitter:IsBankBagIndex(vEquipmentChange.FromLocation.BagIndex) then
			table.remove(vEquipmentChangeList, vChangeIndex)
			vNumChanges = vNumChanges - 1
		else
			vChangeIndex = vChangeIndex + 1
		end
	end
	
	-- Get the list of empty bank slots
	
	local vEmptyBankSlots = Outfitter:GetEmptyBankSlotList()
	
	-- Execute the changes
	
	Outfitter:ExecuteEquipmentChangeList2(vEquipmentChangeList, vEmptyBankSlots, Outfitter.cDepositBagsFullError, vExpectedEquippableItems)
	
	Outfitter:DispatchOutfitEvent("EDIT_OUTFIT", pOutfit.Name, pOutfit)
end

function Outfitter:WithdrawOutfit(pOutfit)
	local vEquippableItems = Outfitter.ItemList_GetEquippableItems()
	
	-- Build a list of items for the outfit
	
	Outfitter.ItemList_ResetIgnoreItemFlags(vEquippableItems)
	
	local vEquipmentChangeList = Outfitter:BuildUnequipChangeList(pOutfit, vEquippableItems)
	
	if not vEquipmentChangeList then
		return
	end
	
	-- Eliminate items which aren't in the bank
	
	local vChangeIndex = 1
	local vNumChanges = #vEquipmentChangeList
	
	while vChangeIndex <= vNumChanges do
		vEquipmentChange = vEquipmentChangeList[vChangeIndex]
		
		if not Outfitter:IsBankBagIndex(vEquipmentChange.FromLocation.BagIndex) then
			table.remove(vEquipmentChangeList, vChangeIndex)
			vNumChanges = vNumChanges - 1
		else
			vChangeIndex = vChangeIndex + 1
		end
	end
	
	-- Get the list of empty bag slots

	local vEmptyBagSlots = Outfitter:GetEmptyBagSlotList()
	
	-- Execute the changes
	
	Outfitter:ExecuteEquipmentChangeList2(vEquipmentChangeList, vEmptyBagSlots, Outfitter.cWithdrawBagsFullError, vExpectedEquippableItems)
	
	Outfitter:DispatchOutfitEvent("EDIT_OUTFIT", pOutfit.Name, pOutfit)
end

function Outfitter:TestAmmoSlot()
	local vItemInfo = Outfitter:GetInventoryItemInfo("AmmoSlot")
	local vSlotID = Outfitter.cSlotIDs.AmmoSlot
	local vItemLink = GetInventoryItemLink("player", vSlotID)
	
	Outfitter:DebugTable("vItemInfo", vItemInfo)
	
	Outfitter:TestMessage("SlotID: "..vSlotID)
	Outfitter:TestMessage("ItemLink: "..vItemLink)
end

function Outfitter.GameToolTip_OnShow(...)
	MCEventLib:DispatchEvent("GAMETOOLTIP_SHOW")
end

function Outfitter.GameToolTip_OnHide(...)
	MCEventLib:DispatchEvent("GAMETOOLTIP_HIDE")
end

function Outfitter:OutfitUsesItem(pOutfit, pItemInfo)
	local vEquippableItems = self.ItemList_GetEquippableItems(false)
	local vItemInfo, vItemInfo2
	
	if pItemInfo.ItemSlotName == "Finger0Slot" then
		vItemInfo = pOutfit.Items.Finger0Slot
		vItemInfo2 = pOutfit.Items.Finger1Slot
	
	elseif pItemInfo.ItemSlotName == "Trinket0Slot" then
		vItemInfo = pOutfit.Items.Trinket0Slot
		vItemInfo2 = pOutfit.Items.Trinket1Slot
	
	elseif self:GetItemMetaSlot(pItemInfo) == "Weapon0Slot" then
		vItemInfo = pOutfit.Items.MainHandSlot
		vItemInfo2 = pOutfit.Items.SecondaryHandSlot
	
	else
		vItemInfo = pOutfit.Items[pItemInfo.ItemSlotName]
	end
	
	return (vItemInfo and Outfitter.ItemList_ItemsAreSame(vEquippableItems, vItemInfo, pItemInfo))
	    or (vItemInfo2 and Outfitter.ItemList_ItemsAreSame(vEquippableItems, vItemInfo2, pItemInfo))
end

function Outfitter:GetOutfitsUsingItem(pItemInfo)
	local vFoundOutfits
	
	for vCategoryID, vOutfits in pairs(self.Settings.Outfits) do
		for _, vOutfit in ipairs(vOutfits) do
			if Outfitter:OutfitUsesItem(vOutfit, pItemInfo) then
				if not vFoundOutfits then
					vFoundOutfits = {}
				end
				
				table.insert(vFoundOutfits, vOutfit)
			end
		end
	end
	
	return vFoundOutfits
end

function Outfitter:GetOutfitsListAsText(pOutfits)
	if not pOutfits
	or #pOutfits == 0 then
		return
	end
	
	local vEquippableItems = Outfitter.ItemList_GetEquippableItems()
	local vNames = nil
	
	for _, vOutfit in ipairs(pOutfits) do
		local vMissingItems, vBankedItems = Outfitter.ItemList_GetMissingItems(vEquippableItems, vOutfit)
		local vName
		
		if vOutfit.Disabled then
			vName = GRAY_FONT_COLOR_CODE
		elseif vMissingItems then
			vName = RED_FONT_COLOR_CODE
		elseif vBankedItems then
			vName = Outfitter.BANKED_FONT_COLOR_CODE
		else
			vName = NORMAL_FONT_COLOR_CODE
		end

		 vName = vName..vOutfit.Name..FONT_COLOR_CODE_CLOSE
		
		if vNames then
			vNames = vNames..", "..vName
		else
			vNames = vName
		end
	end
	
	return vNames
end

function Outfitter:AddOutfitsUsingItemToTooltip(pTooltip, pPrefix, pItemInfo)
	local vOutfitListString
	
	if Outfitter.OutfitInfoCache.OutfitsUsingItem
	and Outfitter.OutfitInfoCache.OutfitsUsingItem.Link
	and Outfitter.OutfitInfoCache.OutfitsUsingItem.Link == pItemInfo.Link then
		vOutfitListString = Outfitter.OutfitInfoCache.OutfitsUsingItem.String
	else
		local vOutfits = Outfitter:GetOutfitsUsingItem(pItemInfo)
		
		if vOutfits then
			vOutfitListString = Outfitter:GetOutfitsListAsText(vOutfits)
		end
		
		-- Update the cache
		
		if pItemInfo.Link then
			if not Outfitter.OutfitInfoCache.OutfitsUsingItem then
				Outfitter.OutfitInfoCache.OutfitsUsingItem = {}
			end
			
			Outfitter.OutfitInfoCache.OutfitsUsingItem.Link = pItemInfo.Link
			Outfitter.OutfitInfoCache.OutfitsUsingItem.String = vOutfitListString
		end
	end
	
	--
	
	if vOutfitListString then
		GameTooltip:AddLine(pPrefix..vOutfitListString, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
		GameTooltip:Show()
	end
end

function Outfitter.GameTooltip_SetBagItem(pTooltip, pBag, pSlot, ...)
	local vResult = {pTooltip:Outfitter_OrigSetBagItem(pBag, pSlot, ...)}
	
	if not Outfitter.Settings.Options.DisableToolTipInfo then
		local vItemInfo = Outfitter:GetBagItemInfo(pBag, pSlot)
		
		if vItemInfo then
			Outfitter:AddOutfitsUsingItemToTooltip(pTooltip, Outfitter.cUsedByPrefix, vItemInfo)
		end
	end
	
	return unpack(vResult)
end

function Outfitter.GameTooltip_SetInventoryItem(pTooltip, pUnit, pSlot, pNameOnly, ...)
	local vResult = {pTooltip:Outfitter_OrigSetInventoryItem(pUnit, pSlot, pNameOnly, ...)}
	
	-- Add the list of outfits the item is used by
	
	if not Outfitter.Settings.Options.DisableToolTipInfo
	and UnitIsUnit(pUnit, "player") then
		local vItemLink = Outfitter:GetInventorySlotIDLink(pSlot)
		local vItemInfo = Outfitter:GetItemInfoFromLink(vItemLink)
		
		if vItemInfo then
			Outfitter:AddOutfitsUsingItemToTooltip(pTooltip, Outfitter.cUsedByPrefix, vItemInfo)
		end
	end
	
	return unpack(vResult)
end

function Outfitter:InitializeFrameMethods(pFrame, pMethods)
	if pMethods then
		for vMethodField, vMethodFunction in pairs(pMethods) do
			pFrame[vMethodField] = vMethodFunction
		end
	end
end

function Outfitter:InitializeFrameWidgets(pFrame, pWidgets)
	if pWidgets then
		local vFrameName = pFrame:GetName()
		
		for _, vWidgetName in pairs(pWidgets) do
			if string.sub(vWidgetName, -1) == "*" then
				vWidgetName = string.sub(vWidgetName, 1, -2)
				
				pFrame[vWidgetName] = {ParentFrame = getglobal(vFrameName..vWidgetName)}
				
				local vIndex = 1
				
				while true do
					local vWidget = getglobal(vFrameName..vWidgetName..vIndex)
					
					if not vWidget then
						break
					end
					
					vWidget:SetID(vIndex)
					table.insert(pFrame[vWidgetName], vWidget)
					
					vIndex = vIndex + 1
				end
			else
				pFrame[vWidgetName] = getglobal(vFrameName..vWidgetName)
			end
		end
	end
end

Outfitter.OpenDialogs = {}

function Outfitter:DialogOpened(pDialog)
	-- Make sure it isn't already open
	
	for _, vDialog in ipairs(self.OpenDialogs) do
		if vDialog == pDialog then
			return
		end
	end
	
	table.insert(self.OpenDialogs, pDialog)
end

function Outfitter:DialogClosed(pDialog)
	for vIndex, vDialog in ipairs(self.OpenDialogs) do
		if vDialog == pDialog then
			table.remove(self.OpenDialogs, vIndex)
			return
		end
	end
	
	Outfitter:ErrorMessage("DialogClosed called on an unknown dialog: "..pDialog:GetName())
end

function Outfitter.StaticPopup_EscapePressed()
	local vClosed = Outfitter.OriginalStaticPopup_EscapePressed()
	local vNumDialogs = #self.OpenDialogs
	
	for vIndex = 1, vNumDialogs do
		local vDialog = self.OpenDialogs[1]
		vDialog:Cancel()
		vClosed = 1
	end
	
	return vClosed
end

function Outfitter:TooltipContainsLine(pTooltip, pText)
	local vTooltipName = pTooltip:GetName()
	
	for vLine = 1, 30 do
		local vText = getglobal(vTooltipName.."TextLeft"..vLine)
		
		if not vText then
			return false
		end
		
		local vTextString = vText:GetText()
		
		if not vTextString then
			return false
		end
		
		if string.find(vTextString, pText) then
			local vColor = {}
			
			vColor.r, vColor.g, vColor.b = vText:GetTextColor()
			
			local vHSVColor = Outfitter:RGBToHSV(vColor)
			
			return true, vHSVColor.s > 0.2 and vHSVColor.v > 0.2 and (vHSVColor.h < 50 or vHSVColor.h > 150)
		end
	end
end

function Outfitter:RecycleTable(pTable)
	if not pTable then
		return {}
	else
		Outfitter:EraseTable(pTable)
		return pTable
	end
end

function Outfitter:EraseTable(pTable)
	for vKey in pairs(pTable) do
		pTable[vKey] = nil
	end
end

function Outfitter:RGBToHSV(pRGBColor)
	local vHSVColor = {}
	local vBaseAngle
	local vHueColor
	
	if not pRGBColor.r
	or not pRGBColor.g
	or not pRGBColor.b then
		vHSVColor.h = 0
		vHSVColor.s = 0
		vHSVColor.v = 1
		
		return vHSVColor
	end
	
	if pRGBColor.r >= pRGBColor.g
	and pRGBColor.r >= pRGBColor.b then
		-- Red is dominant
		
		vHSVColor.v = pRGBColor.r
		
		vBaseAngle = 0
		
		if pRGBColor.g >= pRGBColor.b then
			vHSVColor.s = 1 - pRGBColor.b
			vHueColor = pRGBColor.g
		else
			vHSVColor.s = 1 - pRGBColor.g
			vHueColor = -pRGBColor.b
		end
	elseif pRGBColor.g >= pRGBColor.b then
		-- Green is dominant

		vHSVColor.v = pRGBColor.g

		vBaseAngle = 120
		
		if pRGBColor.r >= pRGBColor.b then
			vHSVColor.s = 1 - pRGBColor.b
			vHueColor = -pRGBColor.r
		else
			vHSVColor.s = 1 - pRGBColor.r
			vHueColor = pRGBColor.b
		end
	else
		-- Blue is dominant
		
		vHSVColor.v = pRGBColor.b

		vBaseAngle = 240
		
		if pRGBColor.r >= pRGBColor.g then
			vHSVColor.s = 1 - pRGBColor.g
			vHueColor = pRGBColor.r
		else
			vHSVColor.s = 1 - pRGBColor.r
			vHueColor = -pRGBColor.g
		end
	end
	
	vHSVColor.h = vBaseAngle + (vHueColor / vHSVColor.v) * 60
	
	if vHSVColor.h < 0 then
		vHSVColor.h = vHSVColor.h + 360
	end
	
	return vHSVColor
end

function Outfitter:FrameEditBox(pEditBox)
	local vLeftTexture = pEditBox:CreateTexture(nil, "ARTWORK")
	
	vLeftTexture:SetWidth(12)
	vLeftTexture:SetPoint("TOPLEFT", pEditBox, "TOPLEFT", -11, 0)
	vLeftTexture:SetPoint("BOTTOMLEFT", pEditBox, "BOTTOMLEFT", -11, -9)
	vLeftTexture:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-FilterBorder")
	vLeftTexture:SetTexCoord(0, 0.09375, 0, 1)
	
	local vRightTexture = pEditBox:CreateTexture(nil, "ARTWORK")
	
	vRightTexture:SetWidth(12)
	vRightTexture:SetPoint("TOPRIGHT", pEditBox, "TOPRIGHT", -12, 0)
	vRightTexture:SetPoint("BOTTOMRIGHT", pEditBox, "BOTTOMRIGHT", -12, -9)
	vRightTexture:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-FilterBorder")
	vRightTexture:SetTexCoord(0.90625, 1, 0, 1)
	
	local vMiddleTexture = pEditBox:CreateTexture(nil, "ARTWORK")
	
	vMiddleTexture:SetPoint("TOPLEFT", vLeftTexture, "TOPRIGHT")
	vMiddleTexture:SetPoint("BOTTOMLEFT", vLeftTexture, "BOTTOMRIGHT")
	vMiddleTexture:SetPoint("TOPRIGHT", vRightTexture, "TOPLEFT")
	vMiddleTexture:SetPoint("BOTTOMRIGHT", vRightTexture, "BOTTOMLEFT")
	vMiddleTexture:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-FilterBorder")
	vMiddleTexture:SetTexCoord(0.09375, 0.90625, 0, 1)
end

function Outfitter:NewObject(pMethods, ...)
	local vObject
	
	if pMethods.New then
		vObject = pMethods:New(...)
	else
		vObject = {}
	end
	
	for vIndex, vValue in pairs(pMethods) do
		vObject[vIndex] = vValue
	end
	
	if vObject.Construct then
		vObject:Construct(...)
	end
	
	return vObject
end

function Outfitter:New(pMethodTable, ...)
	local vObject
	
	if pMethodTable._New then
		vObject = pMethodTable:_New(...)
	else
		vObject = {}
	end
	
	for vKey, vValue in pairs(pMethodTable) do
		vObject[vKey] = vValue
	end
	
	if vObject._Construct then
		vObject:_Construct(...)
	end
	
	return vObject
end

function Outfitter:ConstructFrame(pFrame, pMethods, ...)
	for vKey, vValue in pairs(pMethods) do
		if vKey == "Widgets" and type(vValue) == "table" then
			if not pFrame.Widgets then
				pFrame.Widgets = {}
			end
			
			local vNamePrefix
			
			if pFrame.GetName then
				vNamePrefix = pFrame:GetName()
			else
				vNamePrefix = vValue._Prefix
			end
			
			if vNamePrefix then
				for _, vName in ipairs(vValue) do
					local vWidget = getglobal(vNamePrefix..vName)
					
					if vWidget == nil then
						self:ErrorMessage("Couldn't find global "..vNamePrefix..vName)
					else
						pFrame.Widgets[vName] = vWidget
					end
				end
			else
				Outfitter:ErrorMessage("ConstructFrame: Can't initialize widgets for frame because there's no name prefix")
				Outfitter:DebugStack()
			end
		else
			pFrame[vKey] = vValue
		end
	end
	
	if pMethods.Construct then
		pFrame:Construct(...)
	end
	
	return pFrame
end

function Outfitter.InitializeFrame(pObject, ...)
	if not pObject then
		Outfitter:DebugMessage("InitializeFrame called with nil object")
		Outfitter:DebugStack()
		return
	end
	
	local vNumClasses = select("#", ...)
	
	for vIndex = 1, vNumClasses do
		local vFunctionTable = select(vIndex, ...)
		
		for vFunctionName, vFunction in pairs(vFunctionTable) do
			if type(vFunction) == "table" then
				local vTable = {}
				
				pObject[vFunctionName] = vTable
				
				local vNamePrefix
				
				if pObject.GetName then
					vNamePrefix = pObject:GetName()
				else
					vNamePrefix = pObject[vFunctionName.."Prefix"]
				end
				
				for _, vName in ipairs(vFunction) do
					local vValue = getglobal(vNamePrefix..vName)
					
					if vValue == nil then
						self:ErrorMessage("Couldn't find global "..vNamePrefix..vName)
					else
						vTable[vName] = vValue
					end
				end
			else
				pObject[vFunctionName] = vFunction
			end
		end
	end
end

function Outfitter.HookScript(pFrame, pScriptID, pFunction)
	if not pFrame:GetScript(pScriptID) then
		pFrame:SetScript(pScriptID, pFunction)
	else
		pFrame:HookScript(pScriptID, pFunction)
	end
end

function Outfitter:GetCurrentOutfitInfo()
	return self.OutfitStack:GetCurrentOutfitInfo()
end

function Outfitter:SetUpdateDelay(pTime, pDelay)
	local vUpdateTime = pTime + (pDelay - self.cMinEquipmentUpdateInterval)

	if vUpdateTime > self.LastEquipmentUpdateTime then
		self.LastEquipmentUpdateTime = vUpdateTime
	end
end

function Outfitter:GetItemUseDuration(pInventorySlot)
	-- Set the tooltip
	
	OutfitterTooltip:SetOwner(OutfitterFrame, "ANCHOR_BOTTOMRIGHT", 0, 0)
	
	if not OutfitterTooltip:SetInventoryItem("player", Outfitter.cSlotIDs[pInventorySlot]) then
		OutfitterTooltip:Hide()
		return false
	end
	
	-- Scan for a "Use:" line
	
	for vLineIndex = 1, 100 do
		local vLeftTextFrame = getglobal("OutfitterTooltipTextLeft"..vLineIndex)
		
		if not vLeftTextFrame then
			break
		end
		
		local vLeftText = vLeftTextFrame:GetText()
		
		if vLeftText then
			local vStartIndex, vEndIndex, vSeconds = string.find(vLeftText, Outfitter.cUseDurationTooltipLineFormat)
			
			if not vSeconds then
				vStartIndex, vEndIndex, vSeconds = string.find(vLeftText, Outfitter.cUseDurationTooltipLineFormat2)
			end
			
			if vSeconds then
				OutfitterTooltip:Hide()
				return tonumber(vSeconds)
			end
		end
	end -- for vLineIndex
	
	OutfitterTooltip:Hide()
	return 0
end

Outfitter.cItemUseDuration = {}

function Outfitter:InventoryItemIsActive(pInventorySlot)
	-- See if the item is on cooldown at all
	
	local vSlotID = Outfitter.cSlotIDs[pInventorySlot]
	local vItemLink = Outfitter:GetInventorySlotIDLink(vSlotID)
	local vStartTime, vDuration, vEnable = GetItemCooldown(vItemLink)
	
	if not vStartTime or vStartTime == 0 then
		return false
	end
	
	-- Determine if there's an activity period for the item
	
	local vItemInfo = Outfitter:GetItemInfoFromLink(vItemLink)
	local vUseDuration
	
	if Outfitter.cItemUseDuration[vItemInfo.Code] then
		vUseDuration  = Outfitter.cItemUseDuration[vItemInfo.Code]
	else
		vUseDuration = Outfitter:GetItemUseDuration(pInventorySlot)
		
		if not vUseDuration then
			vUseDuration = 0
		end
		
		Outfitter.cItemUseDuration[vItemInfo.Code] = vUseDuration
	end
	
	-- If the time since started is less than the use duration the item is still active
	-- and shouldn't be unequipped
	
	return GetTime() < vStartTime + vUseDuration
end

function Outfitter_Hook()
	Outfitter_HookTable(_G, "_G")
end

function Outfitter_HookTable(pTable, pPrefix)
	for vKey, vValue in pairs(pTable) do
		if type(vKey) == "string"
		and type(vValue) == "function"
		and not string.find(vKey, "Outfitter") then
			pTable[vKey] = function (...)
				local vStartTime = GetTime()
				local vResult = {vValue(...)}
				local vEndTime = GetTime()
				if vEndTime - vStartTime > 0.1 then
					Outfitter:DebugMessage("Function %s.%s took %f seconds", pPrefix, vKey, vEndTime - vStartTime)
				end
				
				return unpack(vResult)
			end
		end
	end
end

function Outfitter:ShowAllLinks()
	for vCategory, vOutfits in pairs(self.Settings.Outfits) do
		for _, vOutfit in ipairs(vOutfits) do
			for _, vItem in pairs(vOutfit.Items) do
				if vItem.Code ~= 0 then
					Outfitter:NoteMessage(Outfitter:GenerateItemLink(vItem))
				end
			end
		end
	end
end

function Outfitter:GenerateItemLink(pItem)
	if not pItem or pItem.Code == 0 then
		return nil
	end
	
	return string.format("|Hitem:%d:%d:%d:%d:%d:%d:%d:%d|h[%s]|h|r", pItem.Code, pItem.EnchantCode, pItem.JewelCode1, pItem.JewelCode2, pItem.JewelCode3, pItem.JewelCode4, pItem.SubCode, pItem.UniqueID, pItem.Name)
end

function Outfitter:ShowMissingItems()
	if not Outfitter.BankFrameIsOpen then
		Outfitter:ErrorMessage(Outfitter.cMustBeAtBankError)
		return
	end
	
	local vEquippableItems = Outfitter.ItemList_GetEquippableItems()
	local vFoundItems
	
	for vCategory, vOutfits in pairs(self.Settings.Outfits) do
		for _, vOutfit in ipairs(vOutfits) do
			local vMissingItems = Outfitter.ItemList_GetMissingItems(vEquippableItems, vOutfit)
			
			if vMissingItems then
				for _, vItem in pairs(vMissingItems) do
					if not vFoundItems then
						Outfitter:NoteMessage(Outfitter.cMissingItemReportIntro)
						vFoundItems = true
					end
					
					Outfitter:NoteMessage(Outfitter:GenerateItemLink(vItem))
				end
			end
		end
	end
	
	if not vFoundItems then
		Outfitter:NoteMessage(Outfitter.cNoMissingItems)
	end
end
