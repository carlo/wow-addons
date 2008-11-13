if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_Aura = PitBull:NewModule("Aura", "LibRockTimer-1.0", "LibRockEvent-1.0", "LibParser-4.0")
local self = PitBull_Aura
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Show buffs and debuffs for PitBull frames as well as highlight frames that need cleansing."] = "정리할 필요가 있는 강조 프레임 뿐만 아니라 PitBull 프레임을 위해 버프/디버프를 표시합니다.",
		["Up then Left"] = "좌측 다음 위로",
		["Up then Right"] = "우측 다음 위로",
		["Down then Left"] = "좌측 다음 아래로",
		["Down then Right"] = "우측 다음 아래로",
		["Left then Up"] = "위에 다음 좌측으로",
		["Left then Down"] = "아래에 다음 좌측으로",
		["Right then Up"] = "위에 다음 우측으로",
		["Right then Down"] = "아래에 다음 우측으로",
	["Auras"] = "오라",
	["Options for buff and debuff display for this unit type."] = "이 유닛에 대해 버프/디버프 표시를 위한 옵션",
	["Split"] = "분할",
	["Split buff and debuff positions."] = "버프/디버프의 위치를 분할해 표시합니다",
	["Snap"] = "크기 조절",
	["Resize auras to fill the available row space."] = "열 공간을 가능한 채우기 위해 오라의 크기를 조절합니다",
	["Sort"] = "정렬",
	["Sort this unit's debuffs by type then alphabetically."] = "이 유닛의 디버프를 알파벳 유형에 따라 정렬합니다",
	["Enable"] = "활성화",
	["Enable buffs or debuffs."] = "버프 혹은 디버프를 활성화합니다",
	["Buffs"] = "버프",
	["Enable buffs."] = "버프를 활성화합니다",
	["Debuffs"] = "디버프",
	["Enable debuffs."] = "디버프를 활성화합니다",
	["Highlight"] = "강조",
	["Options for highlighting the buff icons."] = "버프 아이콘을 강조하기 위한 옵션",
	["Highlight buffs."] = "버프를 강조합니다",
	["Buff types"] = "버프 유형",
	["Highlight different buffs with different colors based on type."] = "유형에 따라 각기 다른 색상으로 각각의 버프를 강조합니다",
	["Highlight debuffs."] = "디버프를 강조합니다",
	["Debuff types"] = "디버프 유형",
	["Highlight different debuffs with different colors based on type."] = "유형에 따라 각기 다른 색상으로 각각의 디버프를 강조합니다",
	["Colors"] = "색상",
	["Set the highlight colors for the various types."] = "다양한 유형에 대해 강조 색상을 설정합니다",
	["Set the highlight colors for the various buff types."] = "다양한 버프 유형에 대해 강조 색상을 설정합니다",
	["Own"] = "자신",
	["Set the color for buffs that you cast."] = "자신에게 시전한 버프에 대해 색상을 설정합니다",
	["Other"] = "다른이",
	["Set the color for buffs cast by others."] = "다른이가 시전한 버프에 대해 색상을 설정합니다",
	["Set the highlight colors for the various debuff types."] = "다양한 디버프 유형에 대해 강조 색상을 설정합니다",
	["Curse"] = "저주",
	["Set color for curses."] = "저주에 대해 색상을 설정합니다",
	["Poison"] = "독",
	["Set color for poisons."] = "독에 대해 색상을 설정합니다",
	["Magic"] = "마법",
	["Set color for magic."] = "마법에 대해 색상을 설정합니다",
	["Disease"] = "질병",
	["Set color for diseases."] = "질병에 대해 색상을 설정합니다",
	["Other"] = "기타",
	["Set color for others."] = "기타에 대해 색상을 설정합니다",
	["Frame debuff highlight"] = "프레임 디버프 강조",
	["Highlighting the unit frame itself when the unit is debuffed."] = "유닛이 디버프에 걸린 경우에 유닛 프레임 자체를 강조합니다",
	["Never"] = "안함",
	["All Debuffs"] = "모든 디버프",
	["Cureable"] = "치유가능한",
	["Cureable by me"] = "자신이 치유가능한",
	["Frame debuff highlight style"] = "프레임 디버프 강조 방식",
	["Set how the frame debuff highlight looks."] = "프레임 디버프 강조 외형을 설정합니다",
	["Border"] = "테두리",
	["Thin Border"] = "가는 테두리",
	["Normal"] = "보통의",
	["Enable buff filtering"] = "버프 선별 활성화",
	["Filter certain buffs based on your class."] = "자신의 직업에 기반해 모든 버프를 선별합니다",
	["Buff filtering"] = "버프 선별",
	["Select buffs to be filtered."] = "선별해 낼 버프를 선택합니다",
	["Enable debuff filtering"] = "디버프 선별 활성화",
	["Filter certain debuffs based on your class."] = "자신의 직업에 기반해 모든 디버프를 선별합니다",
	["Debuff size"] = "디버프 크기",
	["Set size of debuff icons."] = "디버프 아이콘의 크기를 설정합니다",
	["Buff size"] = "버프 크기",
	["Set size of buff icons."] = "버프 아이콘의 크기를 설정합니다",
	["Max buffs"] = "최대 버프",
	["Set the maximum number of buffs to display."] = "표시할 버프의 최대 갯수를 설정합니다",
	["Max debuffs"] = "최대 디버프",
	["Set the maximum number of debuffs to display."] = "표시할 디버프의 최대 갯수를 설정합니다",
	["Direction"] = "방향",
	["Options for how to position aura icons on this frame."] = "이 프레임에 오라 아이콘의 위치 선정을 위한 옵션",
	["Flip buffs/debuffs"] = "버프/디버프 반전",
	["Flip the positions of buffs and debuffs."] = "버프/디버프의 위치를 뒤바꿔 표시합니다",
	["Growth direction"] = "확장 방향",
	["Set the growth direction for extra rows of buffs and debuffs."] = "버프/디버프의 별도의 열을 위한 확장 방향을 설정합니다",
		["Up"] = "위로",
		["Down"] = "아래로",
	["Buff direction"] = "버프 방향",
	["Set the direction in which buffs grow."] = "버프의 진행 방향을 설정합니다",
	["Debuff direction"] = "디버프 방향",
	["Set the direction in which debuffs grow."] = "디버프의 진행 방향을 설정합니다",
	["Use Weapon Buff Spell Icon"] = "무기 버프 주문 아이콘 사용",
	["Check to have weapon buffs show the spell icon, uncheck to have weapon buffs show the weapon icon."] = "무기 버프에 주문 아이콘을 표시하려면 체크하세요. 비체크시, 무기 버프에 무기 아이콘이 표시됩니다",
	["Weapon Buffs"] = "무기 버프",
	["Enable weapon buffs."] = "무기 버프를 활성화합니다",
	["Use Weapon Item Quality"] = "무기 아이템 품질 사용",
	["Weapon buffs will be highlighted using the color of the weapon's quality."] = "무기 버프에 무기 품질의 색상을 사용해 강조합니다",
	["Weapon"] = "무기",
	["Set the color for weapon buffs."] = "무기 버프를 위한 색상을 설정합니다",
	["Aura"] = "오라",
	["Aura options for all units."] = "모든 유닛을 위한 오라 옵션",
	["Cooldown spiral"] = "나선형 재사용 대기 시간",
	["Toggle whether the cooldown spiral shows."] = "블리자드 나선형 재사용 대기 시간 표시 여부를 전환합니다",
	["Cooldown text"] = "재사용 대기 시간 문자",
	["Options for the cooldown text display."] = "재사용 대기 시간 문자를 위한 옵션",
	["Toggle"] = "전환",
	["Toggle whether to show the cooldown text."] = "재사용 대기 시간 문자 표시 여부를 전환합니다",
	["Opacity"] = "투명도",
	["How transparent/opaque the cooldown text is."] = "재사용 대기 시간 문자의 반투명도/투명도를 설정합니다",
	["Zoom textures"] = "텍스쳐 확대",
	["Zoom-in on the buff/debuff textures slightly."] = "버프/디버프 텍스쳐를 약간 확대해 보여줍니다",
} or {}

local L = PitBull:L("PitBull-Aura", localization)

self.desc = L["Show buffs and debuffs for PitBull frames as well as highlight frames that need cleansing."]

local BS = AceLibrary("LibBabble-Spell-3.0")
local BSL = BS:GetLookupTable()
local SEA = AceLibrary("LibSpecialEvents-Aura-3.0")

local newList, del = Rock:GetRecyclingFunctions("PitBull", "newList", "del")
local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

local IsWackyUnit = PitBull.IsWackyUnit

local GetTime = GetTime
local GameTooltip = GameTooltip
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local GetPlayerBuff = GetPlayerBuff
local GetPlayerBuffName = GetPlayerBuffName
local GetPlayerBuffTexture = GetPlayerBuffTexture
local GetPlayerBuffDispelType = GetPlayerBuffDispelType
local GetPlayerBuffApplications = GetPlayerBuffApplications
local GetPlayerBuffTimeLeft = GetPlayerBuffTimeLeft
local math_floor = math.floor
local math_min = math.min
local table_sort = table.sort
local unpack = unpack
local select = select
local pairs = pairs
local ipairs = ipairs
local debugstack = debugstack
local setmetatable = setmetatable
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local GetMouseFocus = GetMouseFocus
local CancelPlayerBuff = CancelPlayerBuff
local UnitIsUnit = UnitIsUnit
local UnitIsFriend = UnitIsFriend

local canDispel, friendBuffs, friendDebuffs, selfBuffs, selfDebuffs, petBuffs, petDebuffs, enemyDebuffs
local totalSelfBuffs, totalPetBuffs, totalSelfDebuffs, totalPetDebuffs, allFriendlyBuffs, allFriendlyDebuffs
local playerClass, playerRace
do
	local _
	_, playerClass = UnitClass('player')
	_, playerRace = UnitRace('player')
	if playerClass == 'PRIEST' then
		canDispel = {
			["Magic"] = true,
			["Disease"] = true,
		}
		selfBuffs = {
			[BSL["Blessed Recovery"]] = true,
			[BSL["Fade"]] = true,
			[BSL["Feedback"]] = playerRace == "Human" or nil,
			[BSL["Focused Casting"]] = true,
			[BSL["Inner Fire"]] = true,
			[BSL["Inner Focus"]] = true,
			[BSL["Levitate"]] = true,
			[BSL["Pain Suppression"]] = true,
			[BSL["Shadowform"]] = true,
			[BSL["Shadowguard"]] = playerRace == "Troll" or nil,
			[BSL["Touch of Weakness"]] = (playerRace == "BloodElf" or playerRace == "Scourge") or nil,
		}
		selfDebuffs = {
			[BSL["Mind Vision"]] = true,
		}
		friendBuffs = {
			[BSL["Divine Spirit"]] = true,
			[BSL["Elune's Grace"]] = playerRace == "NightElf" or nil,
			[BSL["Fear Ward"]] = (playerRace == "Draenei" or playerRace == "Dwarf") or nil,
			[BSL["Power Infusion"]] = true,
			[BSL["Power Word: Fortitude"]] = true,
			[BSL["Power Word: Shield"]] = true,
			[BSL["Prayer of Fortitude"]] = true,
			[BSL["Prayer of Mending"]] = true,
			[BSL["Prayer of Shadow Protection"]] = true,
			[BSL["Prayer of Spirit"]] = true,
			[BSL["Renew"]] = true,
			[BSL["Symbol of Hope"]] = playerRace == "Draenei" or nil,
			[BSL["Shadow Protection"]] = true,
		}
		enemyDebuffs = {
			[BSL["Devouring Plague"]] = playerRace == "Scourge" or nil,
			[BSL["Hex of Weakness"]] = playerRace == "Troll" or nil,
			[BSL["Holy Fire"]] = true,
			[BSL["Mind Control"]] = true,
			[BSL["Mind Flay"]] = true,
			[BSL["Mind Soothe"]] = true,
			[BSL["Mind Vision"]] = true,
			[BSL["Psychic Scream"]] = true,
			[BSL["Shackle Undead"]] = true,
			[BSL["Shadow Vulnerability"]] = true,
			[BSL["Silence"]] = true,
			[BSL["Shadow Word: Pain"]] = true,
			[BSL["Starshards"]] = playerRace == "NightElf" or nil,
			[BSL["Touch of Weakness"]] = (playerRace == "BloodElf" or playerRace == "Scourge") or nil,
			[BSL["Vampiric Embrace"]] = true,
			[BSL["Vampiric Touch"]] = true,
		}
		friendDebuffs = {
			[BSL["Weakened Soul"]] = true,
		}
	elseif playerClass == 'SHAMAN' then
		canDispel = {
			["Poison"] = true,
			["Disease"] = true,
		}
		selfBuffs = {
			[BSL["Clearcasting"]] = true,
			[BSL["Elemental Devastation"]] = true,
			[BSL["Elemental Mastery"]] = true,
			[BSL["Far Sight"]] = true,
			[BSL["Focused Casting"]] = true,
			[BSL["Ghost Wolf"]] = true,
			[BSL["Lightning Shield"]] = true,
			[BSL["Nature's Swiftness"]] = true,
			[BSL["Sentry Totem"]] = true,
			[BSL["Shamanistic Rage"]] = true,
			[BSL["Water Shield"]] = true,
		}
		friendBuffs = {
			[BSL["Ancestral Fortitude"]] = true,
			[BSL["Bloodlust"]] = (playerRace == "Troll" or playerRace == "Tauren" or playerRace == "Orc") or nil,
			[BSL["Earth Shield"]] = true,
			[BSL["Fire Resistance"]] = true,
			[BSL["Frost Resistance"]] = true,
			[BSL["Grace of Air"]] = true,
			[BSL["Grounding Totem Effect"]] = true,
			[BSL["Healing Stream"]] = true,
			[BSL["Healing Way"]] = true,
			[BSL["Heroism"]] = playerRace == "Draenei" or nil,
			[BSL["Mana Spring"]] = true,
			[BSL["Mana Tide"]] = true,
			[BSL["Nature Resistance"]] = true,
			[BSL["Stoneskin"]] = true,
			[BSL["Strength of Earth"]] = true,
			[BSL["Totem of Wrath"]] = true,
			[BSL["Tranquil Air"]] = true,
			[BSL["Water Breathing"]] = true,
			[BSL["Water Walking"]] = true,
			[BSL["Windwall"]] = true,
			[BSL["Wrath of Air Totem"]] = true,
		}
		enemyDebuffs = {
			[BSL["Earthbind"]] = true,
			[BSL["Flame Shock"]] = true,
			[BSL["Frost Shock"]] = true,
			[BSL["Frostbrand Attack"]] = true,
			[BSL["Stormstrike"]] = true,
			[BSL["Stoneclaw Stun"]] = true,
		}
	elseif playerClass == 'PALADIN' then
		canDispel = {
			["Magic"] = true,
			["Poison"] = true,
			["Disease"] = true,
		}
		selfBuffs = {
			[BSL["Avenging Wrath"]] = true,
			[BSL["Divine Favor"]] = true,
			[BSL["Divine Illumination"]] = true,
			[BSL["Divine Protection"]] = true,
			[BSL["Divine Shield"]] = true,
			[BSL["Holy Shield"]] = true,
			[BSL["Righteous Fury"]] = true,
			[BSL["Seal of Blood"]] = playerRace == "BloodElf" or nil,
			[BSL["Seal of Command"]] = true,
			[BSL["Seal of Justice"]] = true,
			[BSL["Seal of Light"]] = true,
			[BSL["Seal of Righteousness"]] = true,
			[BSL["Seal of Vengeance"]] = true,
			[BSL["Seal of Wisdom"]] = true,
			[BSL["Seal of the Crusader"]] = true,
			[BSL["Sense Undead"]] = true,
			[BSL["Summon Charger"]] = true,
			[BSL["Summon Warhorse"]] = true,
			[BSL["Vengeance"]] = true,
		}
		friendBuffs = {
			[BSL["Blessing of Freedom"]] = true,
			[BSL["Blessing of Kings"]] = true,
			[BSL["Blessing of Light"]] = true,
			[BSL["Blessing of Might"]] = true,
			[BSL["Blessing of Protection"]] = true,
			[BSL["Blessing of Sacrifice"]] = true,
			[BSL["Blessing of Salvation"]] = true,
			[BSL["Blessing of Sanctuary"]] = true,
			[BSL["Blessing of Wisdom"]] = true,
			[BSL["Concentration Aura"]] = true,
			[BSL["Crusader Aura"]] = true,
			[BSL["Devotion Aura"]] = true,
			[BSL["Divine Intervention"]] = true,
			[BSL["Fire Resistance Aura"]] = true,
			[BSL["Frost Resistance Aura"]] = true,
			[BSL["Greater Blessing of Kings"]] = true,
			[BSL["Greater Blessing of Light"]] = true,
			[BSL["Greater Blessing of Might"]] = true,
			[BSL["Greater Blessing of Salvation"]] = true,
			[BSL["Greater Blessing of Sanctuary"]] = true,
			[BSL["Greater Blessing of Wisdom"]] = true,
			[BSL["Retribution Aura"]] = true,
			[BSL["Sanctity Aura"]] = true,
			[BSL["Shadow Resistance Aura"]] = true,
		}
		enemyDebuffs = {
			[BSL["Avenger's Shield"]] = true,
			[BSL["Consecration"]] = true,
			[BSL["Hammer of Justice"]] = true,
			[BSL["Judgement of Justice"]] = true,
			[BSL["Judgement of Light"]] = true,
			[BSL["Judgement of Wisdom"]] = true,
			[BSL["Judgement of the Crusader"]] = true,
			[BSL["Repentance"]] = true,
			[BSL["Stun"]] = true, -- from Seal of Justice
			[BSL["Turn Undead"]] = true,
		}
		friendDebuffs = {
			[BSL["Forbearance"]] = true,
		}
	elseif playerClass == 'MAGE' then
		canDispel = {
			["Curse"] = true,
		}
		selfBuffs = {
			[BSL["Arcane Power"]] = true,
			[BSL["Blazing Speed"]] = true,
			[BSL["Blink"]] = true,
			[BSL["Clearcasting"]] = true,
			[BSL["Combustion"]] = true,
			[BSL["Evocation"]] = true,
			[BSL["Fire Ward"]] = true,
			[BSL["Frost Armor"]] = true,
			[BSL["Frost Ward"]] = true,
			[BSL["Ice Armor"]] = true,
			[BSL["Ice Barrier"]] = true,
			[BSL["Ice Block"]] = true,
			[BSL["Invisibility"]] = true,
			[BSL["Mage Armor"]] = true,
			[BSL["Mana Shield"]] = true,
			[BSL["Molten Armor"]] = true,
			[BSL["Presence of Mind"]] = true,
			[BSL["Slow Fall"]] = true,
		}
		friendBuffs = {
			[BSL["Amplify Magic"]] = true,
			[BSL["Arcane Brilliance"]] = true,
			[BSL["Arcane Intellect"]] = true,
			[BSL["Dampen Magic"]] = true,
		}
		selfDebuffs = {
			[BSL["Arcane Blast"]] = true,
			[BSL["Hypothermia"]] = true,
		}
		enemyDebuffs = {
			[BSL["Blast Wave"]] = true,
			[BSL["Blizzard"]] = true,
			[BSL["Cone of Cold"]] = true,
			[BSL["Chilled"]] = true,
			[BSL["Detect Magic"]] = true,
			[BSL["Dragon's Breath"]] = true,
			[BSL["Fire Vulnerability"]] = true,
			[BSL["Fireball"]] = true,
			[BSL["Flamestrike"]] = true,
			[BSL["Frost Armor"]] = true,
			[BSL["Frost Nova"]] = true,
			[BSL["Frostbite"]] = true,
			[BSL["Frostbolt"]] = true,
			[BSL["Ice Armor"]] = true,
			[BSL["Ignite"]] = true,
			[BSL["Impact"]] = true,
			[BSL["Polymorph"]] = true,
			[BSL["Polymorph: Pig"]] = true,
			[BSL["Polymorph: Turtle"]] = true,
			[BSL["Pyroblast"]] = true,
			[BSL["Slow"]] = true,
		}
	elseif playerClass == 'DRUID' then
		canDispel = {
			["Curse"] = true,
			["Poison"] = true,
		}
		selfBuffs = {
			[BSL["Aquatic Form"]] = true,
			[BSL["Barkskin"]] = true,
			[BSL["Bear Form"]] = true,
			[BSL["Cat Form"]] = true,
			[BSL["Clearcasting"]] = true,
			[BSL["Dash"]] = true,
			[BSL["Dire Bear Form"]] = true,
			[BSL["Enrage"]] = true,
			[BSL["Flight Form"]] = true,
			[BSL["Frenzied Regeneration"]] = true,
			[BSL["Moonkin Form"]] = true,
			[BSL["Nature's Grasp"]] = true,
			[BSL["Nature's Swiftness"]] = true,
			[BSL["Omen of Clarity"]] = true,
			[BSL["Prowl"]] = true,
			[BSL["Swift Flight Form"]] = true,
			[BSL["Tiger's Fury"]] = true,
			[BSL["Track Humanoids"]] = true,
			[BSL["Travel Form"]] = true,
		}
		friendBuffs = {
			[BSL["Abolish Poison"]] = true,
			[BSL["Gift of the Wild"]] = true,
			[BSL["Innervate"]] = true,
			[BSL["Leader of the Pack"]] = true,
			[BSL["Lifebloom"]] = true,
			[BSL["Mark of the Wild"]] = true,
			[BSL["Moonkin Aura"]] = true,
			[BSL["Regrowth"]] = true,
			[BSL["Rejuvenation"]] = true,
			[BSL["Thorns"]] = true,
			[BSL["Tranquility"]] = true,
			[BSL["Tree of Life"]] = true,
		}
		enemyDebuffs = {
			[BSL["Bash"]] = true,
			[BSL["Challenging Roar"]] = true,
			[BSL["Cyclone"]] = true,
			[BSL["Demoralizing Roar"]] = true,
			[BSL["Entangling Roots"]] = true,
			[BSL["Faerie Fire"]] = true,
			[BSL["Faerie Fire (Feral)"]] = true,
			[BSL["Feral Charge"]] = true,
			[BSL["Hibernate"]] = true,
			[BSL["Hurricane"]] = true,
			[BSL["Insect Swarm"]] = true,
			[BSL["Lacerate"]] = true,
			[BSL["Maim"]] = true,
			[BSL["Mangle (Bear)"]] = true,
			[BSL["Mangle (Cat)"]] = true,
			[BSL["Moonfire"]] = true,
			[BSL["Pounce"]] = true,
			[BSL["Rake"]] = true,
			[BSL["Rip"]] = true,
			[BSL["Soothe Animal"]] = true,
		}
	elseif playerClass == 'WARRIOR' then
		selfBuffs = {
			-- Trainer Skill
			[BSL["Bloodrage"]] = true,
			[BSL["Berserker Rage"]] = true,
			[BSL["Retaliation"]] = true,
			[BSL["Shield Wall"]] = true,
			[BSL["Recklessness"]] = true,
			[BSL["Spell Reflection"]] = true,
			[BSL["Shield Block"]] = true,
			-- Talents: Arms
			[BSL["Sweeping Strikes"]] = true,
			[BSL["Second Wind"]] = true,
			-- Talents: Fury
			[BSL["Bloodthirst"]] = true,
			[BSL["Rampage"]] = true,
			[BSL["Blood Craze"]] = true,
			[BSL["Flurry"]] = true,
			[BSL["Enrage"]] = true,
			-- Talents: Prot
			[BSL["Last Stand"]] = true,
			-- T4, Tank, 2/4 piece bonus
			[BSL["Blade Turning"]] = true,
			[BSL["Revenge"]] = true,
			-- T5, Tank, 2/4 piece bonus
			[BSL["Battle Rush"]] = true,
			[BSL["Reinforced Shield"]] = true,
			-- T5, DPS, 2 piece bonus
			[BSL["Overpower"]] = true,
		}
		selfDebuffs = {
			-- Talents: Fury
			[BSL["Death Wish"]] = true,
		}
		friendBuffs = {
			-- Trainer
			[BSL["Battle Shout"]] = true,
			[BSL["Commanding Shout"]] = true,
			[BSL["Intervene"]] = true,
		}
		enemyDebuffs = {
			-- Trainer Skill
			[BSL["Charge Stun"]] = true,
			[BSL["Hamstring"]] = true,
			[BSL["Thunder Clap"]] = true,
			[BSL["Rend"]] = true,
			[BSL["Mocking Blow"]] = true,
			[BSL["Demoralizing Shout"]] = true,
			[BSL["Intimidating Shout"]] = true,
			[BSL["Intercept Stun"]] = true,
			[BSL["Taunt"]] = true,
			[BSL["Dazed"]] = true,
			[BSL["Disarm"]] = true,
			[BSL["Challenging Shout"]] = true,
			[BSL["Sunder Armor"]] = true,
			-- Talents: Arms
			[BSL["Deep Wound"]] = true,
			[BSL["Improved Hamstring"]] = true,
			[BSL["Mace Stun Effect"]] = true,
			[BSL["Mortal Strike"]] = true,
			[BSL["Blood Frenzy"]] = true,
			-- Talents: Fury
			[BSL["Piercing Howl"]] = true,
			-- Talents: Prot
			[BSL["Shield Bash - Silenced"]] = true,
			[BSL["Revenge Stun"]] = true,
			[BSL["Concussion Blow"]] = true,
		}
	elseif playerClass == 'WARLOCK' then
		canDispel = {
			["Magic"] = true,
		}
		selfBuffs = {
			-- Affliction Talents
			[BSL["Amplify Curse"]] = true,
			[BSL["Shadow Trance"]] = true,
			-- Demonology Talents
			[BSL["Master Demonologist"]] = true,
			[BSL["Soul Link"]] = true,
			[BSL["Demonic Knowledge"]] = true,
			[BSL["Demonic Sacrifice"]] = true,
			[BSL["Fel Domination"]] = true,
			-- Destruction Talents
			[BSL["Nether Protection"]] = true,
			[BSL["Backlash"]] = true,
			-- Trainer Skills
			[BSL["Shadow Ward"]] = true,
			[BSL["Demon Armor"]] = true,
			[BSL["Demon Skin"]] = true,
			[BSL["Fel Armor"]] = true,
			[BSL["Sense Demons"]] = true,
			[BSL["Summon Felsteed"]] = true,
			[BSL["Summon Dreadsteed"]] = true,
			-- Pet Abilities
			[BSL["Sacrifice"]] = true,
		}
		friendBuffs = {
			-- Trainer Skills
			[BSL["Soulstone Resurrection"]] = true,
			[BSL["Unending Breath"]] = true,
			[BSL["Detect Invisibility"]] = true,
			-- Pet Abilities
			[BSL["Blood Pact"]] = true, -- Imp
			[BSL["Fire Shield"]] = true, -- Imp
			[BSL["Paranoia"]] = true, -- Felhound
			[BSL["Demonic Frenzy"]] = true, -- Felguard
		}
		enemyDebuffs = {
			-- Trainer Skills - Affliction
			[BSL["Corruption"]] = true,
			[BSL["Curse of Agony"]] = true,
			[BSL["Curse of Doom"]] = true,
			[BSL["Curse of Recklessness"]] = true,
			[BSL["Curse of Shadow"]] = true,
			[BSL["Curse of Tongues"]] = true,
			[BSL["Curse of Weakness"]] = true,
			[BSL["Curse of the Elements"]] = true,
			[BSL["Death Coil"]] = true,
			[BSL["Fear"]] = true,
			[BSL["Howl of Terror"]] = true,
			[BSL["Drain Life"]] = true,
			[BSL["Drain Mana"]] = true,
			[BSL["Drain Soul"]] = true,
			[BSL["Seed of Corruption"]] = true,
			-- Trainer Spells Demonology
			[BSL["Banish"]] = true,
			--Trainer Spells Destruction
			[BSL["Rain of Fire"]] = true,
			[BSL["Hellfire"]] = true,
			[BSL["Immolate"]] = true,
			-- Talents Affliction
			[BSL["Curse of Exhaustion"]] = true,
			[BSL["Siphon Life"]] = true,
			[BSL["Shadow Embrace"]] = true,
			[BSL["Unstable Affliction"]] = true,
			[BSL["Silence"]] = true, -- Unstable Affliction dispel
			-- Talents Destruction
			[BSL["Aftermath"]] = true,
			[BSL["Shadowfury"]] = true,
			[BSL["Pyroclasm"]] = true,
			[BSL["Shadow Vulnerability"]] = true, -- Improved Shadowbolt
			[BSL["Shadowburn"]] = true,
			-- Pet Abilities
			[BSL["Spell Lock"]] = true,  --Felhunter
			[BSL["Tainted Blood"]] = true,  -- Felhunter
			[BSL["Inferno"]] = true,  -- Infernal Stun ??
			[BSL["Cripple"]] = true,  -- Doomguard
			[BSL["Seduction"]] = true, -- Succubus
			[BSL["Soothing Kiss"]] = true, -- Succubus
			[BSL["Suffering"]] = true, -- Voidwalker
		}
	elseif playerClass == 'HUNTER' then
		selfBuffs = {
			[BSL["Aspect of the Beast"]] = true,
			[BSL["Aspect of the Cheetah"]] = true,
			[BSL["Aspect of the Hawk"]] = true,
			[BSL["Aspect of the Monkey"]] = true,
			[BSL["Aspect of the Viper"]] = true,
			[BSL["Deterrence"]] = true,
			[BSL["Eagle Eye"]] = true,
			[BSL["Eyes of the Beast"]] = true,
			[BSL["Feign Death"]] = true,
			[BSL["Master Tactician"]] = true,
			[BSL["Quick Shots"]] = true,
			[BSL["Rapid Fire"]] = true,
			[BSL["Rapid Killing"]] = true,
			[BSL["The Beast Within"]] = true,
		}
		friendBuffs = {
			[BSL["Aspect of the Pack"]] = true,
			[BSL["Aspect of the Wild"]] = true,
			[BSL["Ferocious Inspiration"]] = true,
			[BSL["Misdirection"]] = true,
			[BSL["Spirit Bond"]] = true,
			[BSL["Trueshot Aura"]] = true,
		}
		petBuffs = {
			[BSL["Bestial Wrath"]] = true,
			[BSL["Boar Charge"]] = true,
			[BSL["Feed Pet Effect"]] = true,
			[BSL["Dash"]] = true,
			[BSL["Dive"]] = true,
			[BSL["Furious Howl"]] = true,
			[BSL["Mend Pet"]] = true,
			[BSL["Prowl"]] = true,
			[BSL["Shell Shield"]] = true,
			[BSL["Warp"]] = true,
		}
		enemyDebuffs = {
			[BSL["Beast Lore"]] = true,
			[BSL["Concussive Barrage"]] = true,
			[BSL["Concussive Shot"]] = true,
			[BSL["Counterattack"]] = true,
			[BSL["Entrapment"]] = true,
			[BSL["Explosive Trap Effect"]] = true,
			[BSL["Expose Weakness"]] = true,
			[BSL["Flare"]] = true,
			[BSL["Freezing Trap Effect"]] = true,
			[BSL["Frost Trap Aura"]] = true,
			[BSL["Hunter's Mark"]] = true,
			[BSL["Improved Concussive Shot"]] = true,
			[BSL["Improved Wing Clip"]] = true,
			[BSL["Intimidation"]] = true,
			[BSL["Scare Beast"]] = true,
			[BSL["Serpent Sting"]] = true,
			[BSL["Scatter Shot"]] = true,
			[BSL["Scorpid Sting"]] = true,
			[BSL["Silencing Shot"]] = true,
			[BSL["Tame Beast"]] = true,
			[BSL["Viper Sting"]] = true,
			[BSL["Wing Clip"]] = true,
			[BSL["Wyvern Sting"]] = true,
			--snake trap
			[BSL["Crippling Poison"]] = true,
			[BSL["Deadly Poison"]] = true,
			[BSL["Mind-numbing Poison"]] = true,
			--pets
			[BSL["Boar Charge"]] = true,
			[BSL["Fire Breath"]] = true,
			[BSL["Growl"]] = true,
			[BSL["Poison Spit"]] = true,
			[BSL["Scorpid Poison"]] = true,
			[BSL["Screech"]] = true,
		}
	elseif playerClass == 'ROGUE' then
		selfBuffs = {
			[BSL["Stealth"]] = true,
			[BSL["Evasion"]] = true,
			[BSL["Slice and Dice"]] = true,
			[BSL["Sprint"]] = true,
			[BSL["Vanish"]] = true,
			[BSL["Cloak of Shadows"]] = true,
			-- Talents: Assassination
			[BSL["Remorseless"]] = true,
			[BSL["Cold Blood"]] = true,
			[BSL["Find Weakness"]] = true,
			-- Talents: Combat
			[BSL["Blade Flurry"]] = true,
			[BSL["Adrenaline Rush"]] = true,
			-- Talents: Subtlety
			[BSL["Ghostly Strike"]] = true,
			[BSL["Shadowstep"]] = true,
		}
		enemyDebuffs = {
			[BSL["Sap"]] = true,
			[BSL["Gouge"]] = true,
			[BSL["Expose Armor"]] = true,
			[BSL["Garrote"]] = true,
			[BSL["Garrote - Silence"]] = true,
			[BSL["Rupture"]] = true,
			[BSL["Cheap Shot"]] = true,
			[BSL["Kidney Shot"]] = true,
			[BSL["Blind"]] = true,
			[BSL["Deadly Throw"]] = true,
			-- Talents: Combat
			[BSL["Riposte"]] = true,
			[BSL["Kick - Silenced"]] = true,
			[BSL["Mace Stun Effect"]] = true,
			-- Talents: Subtlety
			[BSL["Hemorrhage"]] = true,
			-- Poison
			[BSL["Crippling Poison"]] = true,
			[BSL["Crippling Poison II"]] = true,
			[BSL["Mind-numbing Poison"]] = true,
			[BSL["Mind-numbing Poison II"]] = true,
			[BSL["Mind-numbing Poison III"]] = true,
			[BSL["Deadly Poison"]] = true,
			[BSL["Deadly Poison II"]] = true,
			[BSL["Deadly Poison III"]] = true,
			[BSL["Deadly Poison IV"]] = true,
			[BSL["Deadly Poison V"]] = true,
			[BSL["Deadly Poison VI"]] = true,
			[BSL["Deadly Poison VII"]] = true,
			[BSL["Wound Poison"]] = true,
			[BSL["Wound Poison II"]] = true,
			[BSL["Wound Poison III"]] = true,
			[BSL["Wound Poison IV"]] = true,
			[BSL["Wound Poison V"]] = true,
			-- PVP Gloves
			[BSL["Deadly Interrupt Effect"]] = true,
		}
	end
	if not canDispel then
		canDispel = {}
	end
	if not selfBuffs then
		selfBuffs = {}
	end
	if not selfDebuffs then
		selfDebuffs = {}
	end
	if not friendBuffs then
		friendBuffs = {}
	end
	if not enemyDebuffs then
		enemyDebuffs = {}
	end
	if not friendDebuffs then
		friendDebuffs = {}
	end
	if not petBuffs then
		petBuffs = {}
	end
	if not petDebuffs then
		petDebuffs = {}
	end
	if playerRace == "BloodElf" then
		enemyDebuffs[BSL["Arcane Torrent"]] = true
		selfBuffs[BSL["Mana Tap"]] = true
	elseif playerRace == "Troll" then
		selfBuffs[BSL["Berserking"]] = true
	elseif playerRace == "Orc" then
		selfBuffs[BSL["Blood Fury"]] = true
		selfDebuffs[BSL["Blood Fury"]] = true
	elseif playerRace == "Scourge" then
		selfBuffs[BSL["Cannibalize"]] = true
		selfBuffs[BSL["Will of the Forsaken"]] = true
	elseif playerRace == "Tauren" then
		enemyDebuffs[BSL["War Stomp"]] = true
	elseif playerRace == "Dwarf" then
		selfBuffs[BSL["Find Treasure"]] = true
		selfBuffs[BSL["Stoneform"]] = true
	elseif playerRace == "Draenei" then
		friendBuffs[BSL["Gift of the Naaru"]] = true
	elseif playerRace == "Human" then
		selfBuffs[BSL["Perception"]] = true
	elseif playerRace == "NightElf" then
		selfBuffs[BSL["Shadowmeld"]] = true
	end
	if playerRace == "BloodElf" or playerRace == "Troll" or playerRace == "Orc" or playerRace == "Scourge" or playerRace == "Tauren" then
		-- horde
		friendBuffs[BSL["Silverwing Flag"]] = true
	else
		-- alliance
		friendBuffs[BSL["Warsong Flag"]] = true
	end
	friendBuffs[BSL["Netherstorm Flag"]] = true

	totalSelfBuffs, totalPetBuffs, totalSelfDebuffs, totalPetDebuffs, allFriendlyBuffs, allFriendlyDebuffs = {}, {}, {}, {}, {}, {}
	for k in pairs(selfBuffs) do
		totalSelfBuffs[k] = true
		allFriendlyBuffs[k] = true
	end
	for k in pairs(selfDebuffs) do
		totalSelfDebuffs[k] = true
		allFriendlyDebuffs[k] = true
	end
	for k in pairs(petBuffs) do
		totalPetBuffs[k] = true
		allFriendlyBuffs[k] = true
	end
	for k in pairs(petDebuffs) do
		totalPetDebuffs[k] = true
		allFriendlyDebuffs[k] = true
	end
	for k in pairs(friendBuffs) do
		totalSelfBuffs[k] = true
		totalPetBuffs[k] = true
		allFriendlyBuffs[k] = true
	end
	for k in pairs(friendDebuffs) do
		totalSelfDebuffs[k] = true
		totalPetDebuffs[k] = true
		allFriendlyDebuffs[k] = true
	end
end

PitBull_Aura:RegisterPitBullChildFrames("auraFrame", "auraFrame2", "debuffhighlight")

local unitsShown = {}

local configMode = PitBull.configMode

local border_path, debuffHighlight_path, debuffHighlightBorder_path, debuffHighlightThinBorder_path
do
	local path = "Interface\\AddOns\\" .. debugstack():match("[d%.][d%.][O%.]ns\\(.-)\\[A-Za-z]-%.lua")
	border_path = path .. "\\border"
	debuffHighlight_path = path .. "\\debuffHighlight"
	debuffHighlightBorder_path = path .. "\\debuffHighlightBorder"
	debuffHighlightThinBorder_path = path .. "\\debuffHighlightThinBorder"
end

function PitBull_Aura:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("Aura")
	PitBull:SetDatabaseNamespaceDefaults("Aura", "profile", {
		["**"] = {
			hidden = false,
			hiddenBuffs = false,
			hiddenDebuffs = false,
			hiddenWeaponBuffs = false,
			highlight = { Buffs = true, Debuffs = true},
			highlightType = { Buffs = true, Debuffs = true},
			highlightStyle = "border",
			split = false,
			snap = true,
			buffFilter = true,
			debuffFilter = true,
			maxbuffs = 6,
			maxdebuffs = 6,
			buffsize = 16,
			debuffsize = 16,
			flip = false,
			grow = -1,
			buffdirection = "Right then Down",
			debuffdirection = "Right then Down",
			frameHighlight = "Cureable by me",
			buffFilterSelection = {
				["*"] = true,
			},
			sort = true,
		},
		target = {
			buffFilter = false,
			debuffFilter = false,
			frameHighlight = "Never",
			maxbuffs = 40,
			maxdebuffs = 40,
		},
		colors = {
			buffs = {
				Own = {1, 1, 0, 1},
                Weapon = {1, 0, 0, 1},
				["nil"] = {0, 1, 0, 1},
			},
			debuffs = {
				Poison = {0, 1, 0, 1},
				Magic = {0, 0, 1, 1},
				Disease = {.55, .15, 0, 1},
				Curse = {5, 0, 5, 1},
				["nil"] = {1, 0, 0, 1},
			},
			weaponBuffItemQuality = true
		},
		cooldown = true,
		cooldownText = false,
		cooldownTextAlpha = 0.5,
		zoomAura = true,
		weaponBuffSpellIcon = true,
	})
end

function PitBull_Aura:OnEnable(first)
	self:AddEventListener("UNIT_AURA", "UNIT_AURA", 0.25)
	self:AddEventListener("LibSpecialEvents-Aura-3.0", {PlayerItemBuffGained=true, PlayerItemBuffLost=true}, "SpecialEvents_PlayerItemBuff", 0.25)
	self:AddRepeatingTimer(0.2, "UpdateAuraFrameTexts")
	self:AddParserListener({
		eventType_in = { "Aura", "Fade", "Dispel" },
		recipientName_not = false,
		recipientID = false,
	}, "OnParserAura")
	self:AddRepeatingTimer(0.25, "WackyFrames_Update")
	self:AddEventListener("UNIT_TARGET")
end

local changedNames = {}
local changedUnits = {}
function PitBull_Aura:OnParserAura(info)
	changedNames[info.recipientName] = true
end

function PitBull_Aura:UNIT_TARGET(ns, event, unit)
	changedUnits[unit .. "target"] = true
	changedUnits[unit .. "targettarget"] = true
end

function PitBull_Aura:UNIT_AURA(ns, event, units)
	local p = self.db.profile
	for unit in pairs(units) do
		for frame in PitBull:IterateUnitFramesForUnit(unit) do
			changedNames[frame.__name] = true
			if unitsShown[frame] and not p[frame.group].hidden then
				self:UpdateAuras(unit, frame)
			end
		end
	end
end

function PitBull_Aura:SpecialEvents_PlayerItemBuff()
	local t = newList()
	t.player = true
	self:UNIT_AURA(nil, nil, t)
	t = del(t)
end

local function buffFrame_OnUpdate(this)
	if GameTooltip:IsOwned(this) then
		if this.itemSlot then
			GameTooltip:SetInventoryItem("player", this.itemSlot)
		elseif this.player then
			local id = GetPlayerBuff(this.id, "HELPFUL")
			GameTooltip:SetPlayerBuff(id, "HELPFUL")
		else
			GameTooltip:SetUnitBuff(this.unit, this.id)
		end
	else
		PitBull_Aura:RemoveTimer("PitBull_Aura-buffFrame-Update")
	end
end

local function buffFrame_OnEnter(this)
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	GameTooltip.owner = this
	if this.itemSlot then
		GameTooltip:SetInventoryItem("player", this.itemSlot)
	elseif this.player then
		local id = GetPlayerBuff(this.id, "HELPFUL")
		GameTooltip:SetPlayerBuff(id, "HELPFUL")
	else
		GameTooltip:SetUnitBuff(this.unit, this.id)
	end
	PitBull_Aura:AddRepeatingTimer("PitBull_Aura-buffFrame-Update", 0.2, buffFrame_OnUpdate, this)
end

local down_button, down_button_name
local function buffFrame_OnMouseDown(this, ...)
	down_button = nil
	if this.player and not IsAltKeyDown() and not IsControlKeyDown() and not IsShiftKeyDown() then
		local id = GetPlayerBuff(this.id, "HELPFUL")
		down_button_name = GetPlayerBuffName(id)
		down_button = this
	end
end

local function buffFrame_OnMouseUp(this, ...)
	if down_button == GetMouseFocus() and down_button == this and this.player then
		local id = GetPlayerBuff(this.id, "HELPFUL")
		if GetPlayerBuffName(id) == down_button_name then -- don't want to cancel some other buff accidentally.
			if this.itemSlot then
				CancelItemTempEnchantment(this.itemSlot - 15)
			else
				CancelPlayerBuff(id)
			end
		end
	end
end

local function debuffFrame_OnUpdate(this)
	if GameTooltip:IsOwned(this) then
		if this.player then
			local id = GetPlayerBuff(this.id, "HARMFUL")
			GameTooltip:SetPlayerBuff(id, "HARMFUL")
		else
			GameTooltip:SetUnitDebuff(this.unit, this.id)
		end
	else
		PitBull_Aura:RemoveTimer("PitBull_Aura-debuffFrame-Update")
	end
end

local function debuffFrame_OnEnter(this)
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	GameTooltip.owner = this
	if this.player then
		local id = GetPlayerBuff(this.id, "HARMFUL")
		GameTooltip:SetPlayerBuff(id, "HARMFUL")
	else
		GameTooltip:SetUnitDebuff(this.unit, this.id)
	end
	PitBull_Aura:AddRepeatingTimer("PitBull_Aura-debuffFrame-Update", 0.2, debuffFrame_OnUpdate, this)
end

local function buffFrame_OnLeave(this)
	if GameTooltip:IsOwned(this) then
		PitBull_Aura:RemoveTimer("PitBull_Aura-buffFrame-Update")
		PitBull_Aura:RemoveTimer("PitBull_Aura-debuffFrame-Update")
		GameTooltip.owner = nil
		GameTooltip:Hide()
	end
end
local debuffFrame_OnLeave = buffFrame_OnLeave

local aurasNeedTextUpdate = {}

local math_ceil = math.ceil
local HOUR_ONELETTER_ABBR = HOUR_ONELETTER_ABBR:gsub(" ", "") -- "%dh"
local MINUTE_ONELETTER_ABBR = MINUTE_ONELETTER_ABBR:gsub(" ", "") -- "%dm"
local function formatTime(seconds)
	if seconds >= 3600 then
		return HOUR_ONELETTER_ABBR:format(math_ceil(seconds/3600))
	elseif seconds >= 180 then
		return MINUTE_ONELETTER_ABBR:format(math_ceil(seconds/60))
	elseif seconds > 60 then
		seconds = math_ceil(seconds)
		return ("%d:%d"):format(seconds/60, seconds%60)
	else
		return ("%d"):format(math_ceil(seconds))
	end
end

function PitBull_Aura:UpdateAuraFrameTexts()
	if not self.db.profile.cooldownText then
		return
	end
	local now = GetTime()
	for frame in pairs(aurasNeedTextUpdate) do
		frame.cooldownText:SetText(formatTime(frame.cooldownTimeTillDone - now))
	end
end

local buffsort_isfriend
local function buffsort(a, b)
	-- num, name, texture, applications, duration, timeLeft, itemSlot
	if not a then
		return false
	elseif not b then
		return true
	end
	
	-- weapon buffs first - main hand then offhand
	local a_name, b_name = a[2], b[2]
	local a_itemSlot, b_itemSlot = a[7], b[7]
	if a_itemSlot and not b_itemSlot then
		return true
	elseif not a_itemSlot and b_itemSlot then
		return false
	elseif a_itemSlot and b_itemSlot then
		return a_itemSlot < b_itemSlot
	end

	-- sort by name
	if a_name ~= b_name then
		if not a_name then
			return false
		elseif not b_name then
			return true
		end
		if buffsort_isfriend then
			local a_mybuff = allFriendlyBuffs[a_name]
			local b_mybuff = allFriendlyBuffs[b_name]
			if not a_mybuff ~= not b_mybuff then
				if a_mybuff then
					return true
				else
					return false
				end
			end
		end
		return a_name < b_name
	end

	-- show your own buffs first
	local a_timeLeft, b_timeLeft = a[6], b[6]
	if not a_timeLeft ~= not b_timeLeft then
		if a_timeLeft then
			return true
		else
			return false
		end
	end

	-- keep ID order
	local a_id, b_id = a[1], b[1]
	if not a_id then
		return false
	elseif not b_id then
		return true
	end
	return a_id < b_id
end

local debuffsort_isfriend
local function debuffsort(a, b)
	-- num, name, texture, applications, dispelType, duration, timeLeft
	if not a then
		return false
	elseif not b then
		return true
	end
	if debuffsort_isfriend then
		-- sort by dispel type
		local a_dispelType, b_dispelType = a[5], b[5]
		if a_dispelType ~= b_dispelType then
			if not a_dispelType then
				return false
			elseif not b_dispelType then
				return true
			end
			return a_dispelType < b_dispelType
		end
	end

	-- sort by name
	local a_name, b_name = a[2], b[2]
	if a_name ~= b_name then
		if not a_name then
			return false
		elseif not b_name then
			return true
		end
		if not debuffsort_isfriend then
			local a_mydebuff = enemyDebuffs[a_name]
			local b_mydebuff = enemyDebuffs[b_name]
			if not a_mydebuff ~= not b_mydebuff then
				if a_mydebuff then
					return true
				else
					return false
				end
			end
		else
			local a_mydebuff = allFriendlyDebuffs[a_name]
			local b_mydebuff = allFriendlyDebuffs[b_name]
			if not a_mydebuff ~= not b_mydebuff then
				if a_mydebuff then
					return true
				else
					return false
				end
			end
		end
		return a_name < b_name
	end

	-- show your own buffs first
	local a_timeLeft, b_timeLeft = a[7], b[7]
	if not a_timeLeft ~= not b_timeLeft then
		if a_timeLeft then
			return true
		else
			return false
		end
	end

	-- keep ID order
	local a_id, b_id = a[1], b[1]
	if not a_id then
		return false
	elseif not b_id then
		return true
	end
	return a_id < b_id
end

local function clear_buff_frame(buff)
	local f = buff.text
	if f then
		buff.text = delFrame(f)
	end
	f = buff.border
	if f then
		buff.border = delFrame(f)
	end
	f = buff.cooldownText
	if f then
		aurasNeedTextUpdate[buff] = nil
		buff.cooldownText = delFrame(f)
	end
	f = buff.cooldown
	if f then
		f.startCooldownTime = nil
		buff.cooldown = delFrame(f)
	end
	buff.icon = delFrame(buff.icon)
	buff.unit = nil
	buff.id = nil
	buff.dispelType = nil
	buff.name = nil
	buff.player = nil
	buff:SetScript("OnEnter", nil)
	buff:SetScript("OnLeave", nil)
	buff:SetScript("OnMouseDown", nil)
	buff:SetScript("OnMouseUp", nil)
	if GameTooltip.owner == buff then
		buffFrame_OnLeave(buff)
	end
	delFrame(buff)
end

local PlayerBuffDurations = setmetatable({}, {__index=function(self,key)
	for i = 1, 40 do
		local name, _, texture, _, duration = UnitBuff("player", i)
		if not texture then
			break
		end
		if name == key then
			self[key] = duration
			return duration
		end
	end
end})

local firstUpdateBuffs = true
local function UpdateBuffs(unit, frame)
	if firstUpdateBuffs then
		SEA:PlayerItemBuffScan()
		firstUpdateBuffs = false
	end

	local auraFrame = frame.auraFrame
	if not auraFrame then
		return
	end

	local profile = PitBull_Aura.db.profile
	local db = profile[frame.group]

	local split = frame.auraFrame2
	local raidFilter = db.buffFilter
	local size = db.buffsize
	local maxbuffs = db.maxbuffs

	local buffFilterSelection = db.buffFilterSelection

	local buffs = auraFrame.buffs
	if not buffs then
		buffs = newList()
		auraFrame.buffs = buffs
	end

	local font, fontsize = PitBull:GetFont()

	local max_buffs_per_row
	do
		local width = auraFrame:GetWidth()
		max_buffs_per_row = math_floor(width / size)
		if db.snap then
			local scale_adjust = width / (size * max_buffs_per_row)
			size = size * scale_adjust
		end
	end

	local isPlayer = UnitIsUnit(unit, "player")
	local isPet = not isPlayer and UnitIsUnit(unit, "pet")
	local isFriend = not isPet and UnitIsFriend("player", unit)
	local list = newList()
	if unit == "player" and not db.hiddenWeaponBuffs then
		local num = 1
		local weapon, quality, texture
		local spell = SEA:GetPlayerMainHandItemBuff()
		if spell and (db.sort or num <= maxbuffs) then
			local link = GetInventoryItemLink("player", 16)
			if link then
				weapon, _, quality, _, _, _, _, _, _, texture = GetItemInfo(GetInventoryItemLink("player", 16))
				if profile.weaponBuffSpellIcon then
					texture = BS:GetSpellIcon(spell) or BS:GetSpellIcon(string.format("%s Weapon", spell)) or select(10, GetItemInfo(spell)) or texture
				end
				list[#list + 1] = newList(num, weapon, texture, 0, nil, nil, 16, quality)
				num = num + 1
			end
		end
		spell = SEA:GetPlayerOffHandItemBuff()
		if spell and (db.sort or num <= maxbuffs) then
			local link = GetInventoryItemLink("player", 17)
			if link then
				weapon, _, quality, _, _, _, _, _, _, texture = GetItemInfo(GetInventoryItemLink("player", 17))
				if profile.weaponBuffSpellIcon then
					texture = BS:GetSpellIcon(spell) or BS:GetSpellIcon(string.format("%s Weapon", spell)) or select(10, GetItemInfo(spell)) or texture
				end
				list[#list + 1] = newList(num, weapon, texture, 0, nil, nil, 17, quality)
			end
		end
	end
	for num = 1, (db.sort and 40 or (maxbuffs - #list)) do
		local name, _, texture, applications, duration, timeLeft
		local good = true
		if isPlayer then
			local id = GetPlayerBuff(num, "HELPFUL")
			if id > 0 then
				name, texture, applications, timeLeft = GetPlayerBuffName(id), GetPlayerBuffTexture(id), GetPlayerBuffApplications(id), GetPlayerBuffTimeLeft(id)
				duration = PlayerBuffDurations[name]
				if not duration or timeLeft > duration then
					duration = timeLeft
					PlayerBuffDurations[name] = timeLeft
				end
				if texture and raidFilter then
					if not (totalSelfBuffs[name] and buffFilterSelection[name]) then
						good = false
					end
				end
			end
		else
			name, _, texture, applications, duration, timeLeft = UnitBuff(unit, num)
			if texture and raidFilter then
				if isPet then
					if not (totalPetBuffs[name] and buffFilterSelection[name]) then
						good = false
					end
				elseif isFriend then
					if not (friendBuffs[name] and buffFilterSelection[name]) then
						good = false
					end
				end
			end
		end

		if (texture and good) or configMode then
			list[#list + 1] = newList(num, name, texture, applications, duration, timeLeft)
		end
	end

	if db.sort then
		buffsort_isfriend = isPlayer or isPet or isFriend
		table_sort(list, buffsort)

		for i = maxbuffs+1, #list do
			list[i] = del(list[i])
		end
	end

	for i = #buffs, #list+1, -1 do
		clear_buff_frame(buffs[i])
		buffs[i] = nil
	end

	local do_buff_highlight = db.highlight.Buffs
	local do_buff_highlight_type = db.highlightType.Buffs
	local buff_highlight_colors = PitBull_Aura.db.profile.colors.buffs
	local show_cooldown = profile.cooldown
	local show_cooldown_text = profile.cooldownText
	local cooldown_text_alpha = profile.cooldownTextAlpha

	for i, v in ipairs(list) do
		local num, name, texture, applications, duration, timeLeft, itemSlot, itemQuality = unpack(v)
		list[i] = del(v)

		local buffFrame = buffs[i]
		local text, icon
		if not buffFrame then
			buffFrame = newFrame("Button", auraFrame)
			buffs[i] = buffFrame

			icon = newFrame("Texture", buffFrame, "BACKGROUND")
			if PitBull_Aura.db.profile.zoomAura then
				icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			end
			buffFrame.icon = icon
			icon:ClearAllPoints()
			icon:SetAllPoints(buffFrame)
		else
			text = buffFrame.text
			icon = buffFrame.icon
		end

		icon:SetTexture(texture)

		if not applications or applications <= 1 then
			if text then
				buffFrame.text = delFrame(text)
				text = nil
			end
		else
			if not text then
				text = newFrame("FontString", buffFrame, "OVERLAY")
				buffFrame.text = text
				text:SetFont( font, fontsize, "OUTLINE" )
				text:SetShadowColor(0, 0, 0, 1)
				text:SetShadowOffset(0.8, -0.8)
				text:ClearAllPoints()
				text:SetPoint("BOTTOMRIGHT", buffFrame, "BOTTOMRIGHT", 0, 0)
			end
			text:SetText(applications)
		end
		local border = buffFrame.border
		if do_buff_highlight or (not texture and configMode) then
			if not border then
				border = newFrame("Texture", buffFrame, "BORDER")
				buffFrame.border = border
				border:SetTexture(border_path)
				border:ClearAllPoints()
				border:SetAllPoints(buffFrame)
			end
			if do_buff_highlight_type and itemQuality then
				if profile.colors.weaponBuffItemQuality then
					local r, g, b = GetItemQualityColor(itemQuality)
					border:SetVertexColor(r, g, b, 1)
				else
					border:SetVertexColor(unpack(buff_highlight_colors["Weapon"]))
				end
			elseif do_buff_highlight_type and duration and duration > 0 and not isPlayer then	-- cannot tell if player's buffs were cast by player as they all have a duration, and there is no way to map between the GetPlayerBuff and UnitBuff indices buffId and buffIndex
				border:SetVertexColor(unpack(buff_highlight_colors["Own"]))
			else
				border:SetVertexColor(unpack(buff_highlight_colors["nil"]))
			end
		else
			if border then
				buffFrame.border = delFrame(border)
			end
		end

		local cooldownText = buffFrame.cooldownText
		local cooldown = buffFrame.cooldown
		if texture then
			buffFrame:SetScript("OnEnter", buffFrame_OnEnter)
			buffFrame:SetScript("OnLeave", buffFrame_OnLeave)
			buffFrame:SetScript("OnMouseDown", buffFrame_OnMouseDown)
			buffFrame:SetScript("OnMouseUp", buffFrame_OnMouseUp)
			buffFrame.id = num
			buffFrame.player = isPlayer
			buffFrame.unit = unit
			buffFrame.name = name
			buffFrame.itemSlot = itemSlot

			if duration and duration > 0 then
				if show_cooldown_text then
					if not cooldownText then
						cooldownText = newFrame("FontString", buffFrame, "OVERLAY")
						buffFrame.cooldownText = cooldownText
						aurasNeedTextUpdate[buffFrame] = true
						cooldownText:SetAlpha(self.db.profile.cooldownTextAlpha)
						cooldownText:SetFont(font, fontsize * 0.8, "OUTLINE")
						cooldownText:SetShadowColor(0, 0, 0, 1)
						cooldownText:SetShadowOffset(0.8, -0.8)
						cooldownText:ClearAllPoints()
						cooldownText:SetPoint("TOP", buffFrame, "TOP", 0, 0)
					end
					buffFrame.cooldownTimeTillDone = GetTime() + timeLeft
					cooldownText:SetText(formatTime(timeLeft))
				else
					if cooldownText then
						aurasNeedTextUpdate[buffFrame] = nil
						buffFrame.cooldownText = delFrame(cooldownText)
						cooldownText = nil
					end
				end
				if show_cooldown then
					if not cooldown then
						cooldown = newFrame("Cooldown", buffFrame)
						cooldown:SetReverse(true)
						buffFrame.cooldown = cooldown
						cooldown:SetAllPoints(buffFrame)
					end
					local startCooldownTime = GetTime() + timeLeft - duration
					cooldown:SetCooldown(startCooldownTime, duration)
				else
					if cooldown then
						cooldown.startCooldownTime = nil
						buffFrame.cooldown = delFrame(cooldown)
						cooldown = nil
					end
				end
			else
				if cooldownText then
					aurasNeedTextUpdate[buffFrame] = nil
					buffFrame.cooldownText = delFrame(cooldownText)
					cooldownText = nil
				end
				if cooldown then
					cooldown.startCooldownTime = nil
					buffFrame.cooldown = delFrame(cooldown)
					cooldown = nil
				end
			end
		else
			if not text then
				text = newFrame("FontString", buffFrame, "OVERLAY")
				buffFrame.text = text
				text:SetFont( font, fontsize, "OUTLINE" )
				text:SetShadowColor(0, 0, 0, 1)
				text:SetShadowOffset(0.8, -0.8)
				text:ClearAllPoints()
				text:SetPoint("BOTTOMRIGHT", buffFrame, "BOTTOMRIGHT", 0, 0)
			end
			text:SetText("X")
			if cooldownText then
				aurasNeedTextUpdate[buffFrame] = nil
				buffFrame.cooldownText = delFrame(cooldownText)
				cooldownText = nil
			end
			if cooldown then
				cooldown.startCooldownTime = nil
				buffFrame.cooldown = delFrame(cooldown)
				cooldown = nil
			end
		end
		if cooldown then
			if text then
				text:SetParent(cooldown)
			end
			if cooldownText then
				cooldownText:SetParent(cooldown)
			end
		else
			if text then
				text:SetParent(buffFrame)
			end
			if cooldownText then
				cooldownText:SetParent(buffFrame)
			end
		end
	end
	list = del(list)
	local num_buffs = #buffs

	local lastrow = 1

	if num_buffs == 0 then
		auraFrame.buffs = del(buffs)
	else
		local direction = db.buffdirection
		local pos_a = 0
		local pos_b = 0
		local group_grow = db.grow
		local group_flip = db.flip

		for i = 1, num_buffs do
			local buff = buffs[i]
			buff:Show()
			buff:ClearAllPoints()
			-- Workaround, find and fix invalid sizes.
			buff:SetWidth(size)
			buff:SetHeight(size)
			if split then
				if direction == "Up then Left" then
					buff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -pos_a, pos_b)
				elseif direction == "Up then Right" then
					buff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", pos_a, pos_b)
				elseif direction == "Down then Left" then
					buff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -pos_a, -pos_b)
				elseif direction == "Down then Right" then
					buff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", pos_a, -pos_b)
				elseif direction == "Left then Up" then
					buff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -pos_b, pos_a)
				elseif direction == "Left then Down" then
					buff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -pos_b, -pos_a)
				elseif direction == "Right then Up" then
					buff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", pos_b, pos_a)
				elseif direction == "Right then Down" then
					buff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", pos_b, -pos_a)
				end
			else
				if group_flip then
					buff:SetPoint("TOPRIGHT", auraFrame, "TOPRIGHT", -pos_b, pos_a * group_grow)
				else
					buff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", pos_b, pos_a * group_grow)
				end
			end
			if i ~= num_buffs and i % max_buffs_per_row == 0 then
				lastrow = lastrow + 1
				pos_a = pos_a + size
				pos_b = 0
			else
				pos_b = pos_b + size
			end
		end
	end

	if not split then
		auraFrame:SetHeight(lastrow * size)
	end
end

local PlayerDebuffDurations = setmetatable({}, {__index=function(self,key)
	for i = 1, 40 do
		local name, _, texture, applications, dispelType, duration, timeLeft = UnitDebuff("player", i)
		if not texture then
			break
		end
		if name == key then
			self[key] = duration
			return duration
		end
	end
end})

local function UpdateDebuffs(unit, frame, buffs)
	local split = frame.auraFrame2
	local auraFrame = split or frame.auraFrame

	if not auraFrame then
		return
	end

	local profile = PitBull_Aura.db.profile
	local db = profile[frame.group]

	local snap = db.snap
	local raidFilter = db.debuffFilter
	local size = db.debuffsize
	local maxdebuffs = db.maxdebuffs

	local debuffs = auraFrame.debuffs
	if not debuffs then
		debuffs = newList()
		auraFrame.debuffs = debuffs
	end

	local auraFrame_width = auraFrame:GetWidth()
	local max_debuffs_per_row = math_floor(auraFrame_width / size)
	local scale_adjust = auraFrame_width / (size * max_debuffs_per_row)
	local font, fontsize = PitBull:GetFont()

	if snap then
		size = size * scale_adjust
	end

	local isPlayer = UnitIsUnit(unit, "player")
	local isPet = not isPlayer and UnitIsUnit(unit, "pet")
	local isFriend = not isPet and UnitIsFriend("player", unit)
	local list = newList()
	for num = 1, (db.sort and 40 or maxdebuffs) do
		local name, _, texture, applications, dispelType, duration, timeLeft
		local good = true
		if isPlayer then
			local id = GetPlayerBuff(num, "HARMFUL")
			if id > 0 then
				name, texture, applications, dispelType, timeLeft = GetPlayerBuffName(id), GetPlayerBuffTexture(id), GetPlayerBuffApplications(id), GetPlayerBuffDispelType(id), GetPlayerBuffTimeLeft(id)
				duration = PlayerDebuffDurations[name]
				if not duration or timeLeft > duration then
					duration = timeLeft
					PlayerDebuffDurations[name] = timeLeft
				end
				if texture and raidFilter then
					if not canDispel[dispelType] and not selfDebuffs[name] and not friendDebuffs[name] then
						good = false
					end
				end
			end
		else
			name, _, texture, applications, dispelType, duration, timeLeft = UnitDebuff(unit, num)
			if texture and raidFilter then
				if isPet then
					if not canDispel[dispelType] and not totalPetDebuffs[name] then
						good = false
					end
				elseif isFriend then
					if not canDispel[dispelType] and not friendDebuffs[name] then
						good = false
					end
				else
					if not enemyDebuffs[name] then
						good = false
					end
				end
			end
		end

		if (texture and good) or configMode then
			list[#list + 1] = newList(num, name, texture, applications, dispelType, duration, timeLeft)
		end
	end

	if db.sort then
		debuffsort_isfriend = isPlayer or isPet or isFriend
		table_sort(list, debuffsort)

		for i = maxdebuffs+1, #list do
			list[i] = del(list[i])
		end
	end

	for j = #debuffs, #list+1, -1 do
		clear_buff_frame(debuffs[j])
		debuffs[j] = nil
	end

	local do_debuff_highlight = db.highlight.Debuffs
	local do_debuff_highlight_type = db.highlightType.Debuffs
	local debuff_highlight_colors = PitBull_Aura.db.profile.colors.debuffs
	local show_cooldown = profile.cooldown
	local show_cooldown_text = profile.cooldownText
	local cooldown_text_alpha = profile.cooldownTextAlpha

	for i, v in ipairs(list) do
		local num, name, texture, applications, dispelType, duration, timeLeft = unpack(v)
		list[i] = del(v)
		local debuffFrame = debuffs[i]
		local text, icon
		if not debuffFrame then
			debuffFrame = newFrame("Button", auraFrame)
			debuffs[i] = debuffFrame

			icon = newFrame("Texture", debuffFrame, "BACKGROUND")
			if PitBull_Aura.db.profile.zoomAura then
				icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			end
			debuffFrame.icon = icon
			icon:ClearAllPoints()
			icon:SetAllPoints(debuffFrame)
		else
			text = debuffFrame.text
			icon = debuffFrame.icon
		end

		icon:SetTexture(texture)

		if not applications or applications <= 1 then
			if text then
				debuffFrame.text = delFrame(text)
				text = nil
			end
		else
			if not text then
				text = newFrame("FontString", debuffFrame, "OVERLAY")
				debuffFrame.text = text
				text:SetFont( font, fontsize, "OUTLINE" )
				text:SetShadowColor(0, 0, 0, 1)
				text:SetShadowOffset(0.8, -0.8)
				text:ClearAllPoints()
				text:SetPoint("BOTTOMRIGHT", debuffFrame, "BOTTOMRIGHT", 0, 0)
			end
			text:SetText(applications)
		end
		local border = debuffFrame.border
		if do_debuff_highlight or (not texture and configMode) then
			if not border then
				border = newFrame("Texture", debuffFrame, "BORDER")
				debuffFrame.border = border
				border:SetTexture(border_path)
				border:ClearAllPoints()
				border:SetAllPoints(debuffFrame)
			end
			if do_debuff_highlight_type and dispelType then
				border:SetVertexColor(unpack(debuff_highlight_colors[dispelType]))
			else
				border:SetVertexColor(unpack(debuff_highlight_colors["nil"]))
			end
		else
			if border then
				debuffFrame.border = delFrame(border)
			end
		end

		local cooldownText = debuffFrame.cooldownText
		local cooldown = debuffFrame.cooldown
		if texture then
			debuffFrame:SetScript("OnEnter", debuffFrame_OnEnter)
			debuffFrame:SetScript("OnLeave", debuffFrame_OnLeave)
			debuffFrame.id = num
			debuffFrame.player = isPlayer
			debuffFrame.unit = unit
			debuffFrame.name = name
			debuffFrame.dispelType = dispelType

			if duration and duration > 0 then
				if show_cooldown_text then
					if not cooldownText then
						cooldownText = newFrame("FontString", debuffFrame, "OVERLAY")
						debuffFrame.cooldownText = cooldownText
						aurasNeedTextUpdate[debuffFrame] = true
						cooldownText:SetAlpha(self.db.profile.cooldownTextAlpha)
						cooldownText:SetFont(font, fontsize * 0.8, "OUTLINE")
						cooldownText:SetShadowColor(0, 0, 0, 1)
						cooldownText:SetShadowOffset(0.8, -0.8)
						cooldownText:ClearAllPoints()
						cooldownText:SetPoint("TOP", debuffFrame, "TOP", 0, 0)
					end
					debuffFrame.cooldownTimeTillDone = GetTime() + timeLeft
					cooldownText:SetText(formatTime(timeLeft))
				else
					if cooldownText then
						aurasNeedTextUpdate[debuffFrame] = nil
						debuffFrame.cooldownText = delFrame(cooldownText)
						cooldownText = nil
					end
				end
				if show_cooldown then
					if not cooldown then
						cooldown = newFrame("Cooldown", debuffFrame)
						cooldown:SetReverse(true)
						debuffFrame.cooldown = cooldown
						cooldown:SetAllPoints(debuffFrame)
					end
					local startCooldownTime = GetTime() + timeLeft - duration
					cooldown:SetCooldown(startCooldownTime, duration)
				else
					if cooldown then
						cooldown.startCooldownTime = nil
						debuffFrame.cooldown = delFrame(cooldown)
						cooldown = nil
					end
				end
			else
				if cooldownText then
					aurasNeedTextUpdate[debuffFrame] = nil
					debuffFrame.cooldownText = delFrame(cooldownText)
					cooldownText = nil
				end
				if cooldown then
					cooldown.startCooldownTime = nil
					debuffFrame.cooldown = delFrame(cooldown)
					cooldown = nil
				end
			end
		else
			-- debuffFrame.name = ''
			if not text then
				text = newFrame("FontString", debuffFrame, "OVERLAY")
				debuffFrame.text = text
				text:SetFont( font, fontsize, "OUTLINE" )
				text:SetShadowColor(0, 0, 0, 1)
				text:SetShadowOffset(0.8, -0.8)
				text:ClearAllPoints()
				text:SetPoint("BOTTOMRIGHT", debuffFrame, "BOTTOMRIGHT", 0, 0)
			end
			text:SetText("X")
			if cooldownText then
				aurasNeedTextUpdate[debuffFrame] = nil
				debuffFrame.cooldownText = delFrame(cooldownText)
				cooldownText = nil
			end
			if cooldown then
				cooldown.startCooldownTime = nil
				debuffFrame.cooldown = delFrame(cooldown)
				cooldown = nil
			end
		end
		if cooldown then
			if text then
				text:SetParent(cooldown)
			end
			if cooldownText then
				cooldownText:SetParent(cooldown)
			end
		else
			if text then
				text:SetParent(debuffFrame)
			end
			if cooldownText then
				cooldownText:SetParent(debuffFrame)
			end
		end
	end
	list = del(list)

	local num_debuffs = #debuffs

	if num_debuffs == 0 then
		auraFrame.debuffs = del(debuffs)
	elseif split then
		-- note that this is the top row that we"ll be using for the first few debuffs.  split mode they descend, nonsplit they ascend
		local direction = db.debuffdirection
		local pos_a = 0
		local pos_b = 0

		for i = 1, num_debuffs do
			local debuff = debuffs[i]
			debuff:Show()
			debuff:SetBackdropBorderColor(1,0,0)
			debuff:ClearAllPoints()
			-- Workaround, find and fix invalid sizes.
			debuff:SetWidth(size)
			debuff:SetHeight(size)
			if direction == "Up then Left" then
				debuff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -pos_a, pos_b)
			elseif direction == "Up then Right" then
				debuff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", pos_a, pos_b)
			elseif direction == "Down then Left" then
				debuff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -pos_a, -pos_b)
			elseif direction == "Down then Right" then
				debuff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", pos_a, -pos_b)
			elseif direction == "Left then Up" then
				debuff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -pos_b, pos_a)
			elseif direction == "Left then Down" then
				debuff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -pos_b, -pos_a)
			elseif direction == "Right then Up" then
				debuff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", pos_b, pos_a)
			elseif direction == "Right then Down" then
				debuff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", pos_b, -pos_a)
			end
			if i % max_debuffs_per_row == 0 then
				pos_a = pos_a + size
				pos_b = 0
			else
				pos_b = pos_b + size
			end
		end
	else
		local buffsize = db.buffsize

		if snap then
			buffsize = buffsize * scale_adjust
		end

		local max_buffs_per_row = math_floor(auraFrame_width / buffsize)
		local num_buffs = auraFrame.buffs and #auraFrame.buffs or 0

		local num_buffs_bottomrow = num_buffs % max_buffs_per_row
		local num_debuffs_toprow = num_debuffs % max_debuffs_per_row

		local colliding = (num_debuffs_toprow * size + num_buffs_bottomrow * buffsize) > auraFrame_width

		-- start at the bottom full row of buffs
		local offset = math_floor(num_buffs / max_buffs_per_row) * buffsize +
		-- if colliding, push it down the sum of the values
		(colliding and (buffsize + size) or 0) +
		-- if sharing a row, push it down the larger value.
		((not colliding and num_debuffs_toprow > 0 and num_buffs_bottomrow > 0) and (buffsize > size and buffsize or size) or 0) +
		-- if one row"s full and the other isnt, push it the pertaining value.
		((num_debuffs_toprow == 0 and num_buffs_bottomrow > 0) and buffsize or 0) +
		((num_debuffs_toprow > 0 and num_buffs_bottomrow == 0) and size or 0)

		local flip = db.flip
		flip = (flip and buffs) or (not flip and not buffs)
		local grow = db.grow

		offset = grow == 1 and offset - buffsize + size or grow * offset

		-- note that this will be the bottom row that we draw debuffs on.
		local row = math_floor(num_debuffs / max_debuffs_per_row)
		local pos_b = 0
		local offset_a = grow * size
		local pos_a = (row - 1) * offset_a + offset

		for i = 1, num_debuffs do
			local debuff = debuffs[i]
			debuff:Show()
			debuff:SetBackdropBorderColor(1,0,0)
			debuff:ClearAllPoints()
			-- Workaround, find and fix invalid sizes.
			debuff:SetWidth(size)
			debuff:SetHeight(size)
			if flip then
				debuff:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", pos_b, pos_a)
			else
				debuff:SetPoint("TOPRIGHT", auraFrame, "TOPRIGHT", -pos_b, pos_a)
			end
			if i % max_debuffs_per_row == 0 then
				pos_b = 0
				pos_a = pos_a - offset_a
			else
				pos_b = pos_b + size
			end
		end
	end
end

local function UpdateFrameHighlight(unit, frame)
	if not frame.debuffhighlight then
		return
	end
	local frameHighlight = PitBull_Aura.db.profile[frame.group].frameHighlight

	local htexture, hdispel, hashighlight, checkagain

	if frameHighlight == "Never" or ((frameHighlight == "Cureable by me" or frameHighlight == "Cureable") and not UnitIsFriend("player", unit)) then
	else
		for i = 1, 40 do
			if not hashighlight or hashighlight == "nil" or checkagain then -- if hashighlight is "nil" we keep trying there might be a curable debuff we prioritize those for highlighting
				local _
				_, _, htexture, _, hdispel = UnitDebuff(unit, i) -- ignore the raidfilter for frame highlighting
				if htexture then
					if not hdispel then -- no dispel type set
						if frameHighlight == "All Debuffs" then -- only set highlight to "nil"  if we want to show all debuffs
							hashighlight = "nil" -- we specifically continue here to find an optional cureable or cureable by me debuff which has priority for highlighting
						end
					elseif frameHighlight == "Cureable" or frameHighlight == "All Debuffs" then
						if canDispel and canDispel[hdispel] then
							hashighlight = hdispel
							break -- break here, we"ve got a cureable by me debuff...
						else
							hashighlight = hdispel -- continue here to try and find a cureable by me debuff.
						end
					elseif frameHighlight == "Cureable by me" and canDispel and canDispel[hdispel] then
						hashighlight = hdispel
						break -- break here, we"ve got a cureable by me debuff...
					end
				else
					break
				end
			end
		end
	end

	if hashighlight then
		local style = PitBull_Aura.db.profile[frame.group].highlightStyle
		if style == "border" then
			frame.debuffhighlight:SetTexture(debuffHighlightBorder_path)
		elseif style == "thinborder" then
			frame.debuffhighlight:SetTexture(debuffHighlightThinBorder_path)
		else
			frame.debuffhighlight:SetTexture(debuffHighlight_path)
		end
		frame.debuffhighlight:SetBlendMode("ADD")
		frame.debuffhighlight:SetAlpha(0.75)
		local r,g,b = unpack(PitBull_Aura.db.profile.colors.debuffs[hashighlight])
		frame.debuffhighlight:SetVertexColor(r,g,b)
		frame.debuffhighlight:Show()
	else
		frame.debuffhighlight:Hide()
	end

end

function PitBull_Aura:UpdateAuras(unit, frame)
	local db = self.db.profile[frame.group]
	
	if db.frameHighlight == "Never" then
		frame.debuffhighlight:Hide()
	else
		UpdateFrameHighlight(unit, frame)
	end
	if not unitsShown[frame] or db.hidden then
		return
	end
	
	
	local buffs
	if not db.hiddenBuffs then
		buffs = true
		UpdateBuffs(unit, frame)
	end
	if not db.hiddenDebuffs then
		UpdateDebuffs(unit, frame, buffs)
	end
end

do
	local mt = {__index = function(t,k)
		t[k] = 0
		return 0
	end}
	local shortframedelay = setmetatable({}, mt)
	local longframedelay = setmetatable({}, mt)
	function PitBull_Aura:OnUpdateFrame(unit, frame)
		if not frame.auraFrame or self.db.profile[frame.group].hidden or not unitsShown[frame] then
			return
		end
		if not IsWackyUnit[unit] then
			self:UpdateAuras(unit, frame)
		end
	end
end

local num = 0
local lastName = {}
function PitBull_Aura:WackyFrames_Update()
	num = (num + 1) % 20
	for unit, frame in PitBull:IterateWackyUnitFrames() do
		local name = frame.__name
		if name and (num == 0 or changedUnits[unit] or changedNames[name] or lastName[unit] ~= name) then
			self:UpdateAuras(unit, frame)
		end
		lastName[unit] = name
	end
	for k in pairs(changedNames) do
		changedNames[k] = nil
	end
	for k in pairs(changedUnits) do
		changedUnits[k] = nil
	end
end

function PitBull_Aura:OnPopulateUnitFrame(unit, frame)
	local db = self.db.profile[frame.group]
	if not db.hidden then
		frame.auraFrame = newFrame("Frame", frame)
		if db.split then
			frame.auraFrame2 = newFrame("Frame", frame)
		end
	end
	local highlight = newFrame("Texture", frame.overlay, "OVERLAY")
	frame.debuffhighlight = highlight
	if db.highlightStyle == "border" then
		frame.debuffhighlight:SetTexture(debuffHighlightBorder_path)
	elseif db.highlightStyle == "thinborder" then
		frame.debuffhighlight:SetTexture(debuffHighlightThinBorder_path)
	else
		frame.debuffhighlight:SetTexture(debuffHighlight_path)
	end
	highlight:SetBlendMode("ADD")
	highlight:SetAlpha(0.75)
	highlight:Hide()
	highlight:SetAllPoints(frame)
end

function PitBull_Aura:OnUpdateFont(font, fontsize)
	for unit,frame in PitBull:IterateUnitFrames() do
		self:ClearAuras(unit, frame)
		self:UpdateAuras(unit, frame)
	end
end

function PitBull_Aura:ClearAuras(unit, frame)
	if not frame.auraFrame then
		return
	end
	local buffs = frame.auraFrame.buffs
	if buffs then
		for i = 1, #buffs do
			clear_buff_frame(buffs[i])
			buffs[i] = nil
		end
		frame.auraFrame.buffs = del(buffs)
	end

	local debuffs
	if frame.auraFrame2 then
		debuffs = frame.auraFrame2.debuffs
	else
		debuffs = frame.auraFrame.debuffs
	end
	if debuffs then
		for i = 1, #debuffs do
			clear_buff_frame(debuffs[i])
			debuffs[i] = nil
		end
		if frame.auraFrame2 then
			frame.auraFrame2.debuffs = del(debuffs)
		else
			frame.auraFrame.debuffs = del(debuffs)
		end
	end
end

function PitBull_Aura:OnClearUnitFrame(unit, frame)
	if frame.auraFrame then
		self:ClearAuras(unit, frame)

		frame.auraFrame = delFrame(frame.auraFrame)
		if frame.auraFrame2 then
			frame.auraFrame2 = delFrame(frame.auraFrame2)
		end
	end
	if frame.debuffhighlight then
		frame.debuffhighlight = delFrame(frame.debuffhighlight)
	end
	unitsShown[frame] = nil
end

function PitBull_Aura:OnUnknownLayout(unit, frame, name)
	if name == "auraFrame" then
		frame.auraFrame:SetHeight(self.db.profile[frame.group].buffsize)
		frame.auraFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT")
		frame.auraFrame:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT")
	elseif name == "auraFrame2" then
		frame.auraFrame2:SetHeight(self.db.profile[frame.group].debuffsize)
		frame.auraFrame2:SetPoint("TOPLEFT", frame.auraFrame, "BOTTOMLEFT")
		frame.auraFrame2:SetPoint("TOPRIGHT", frame.auraFrame, "BOTTOMRIGHT")
	elseif name == "debuffhighlight" then
		frame.debuffhighlight:SetBlendMode("ADD")
		frame.debuffhighlight:SetAlpha(0.75)
		frame.debuffhighlight:SetAllPoints( frame )
		frame.debuffhighlight:Hide()
	end
end
function PitBull_Aura:OnUpdateLayout(unit, frame)
	local now = not frame.auraFrame or not frame.auraFrame:IsShown()
	if not now == unitsShown[frame] then
		return
	end
	unitsShown[frame] = not now
	if now then
		self:ClearAuras(unit, frame)
	else
		self:UpdateAuras(unit, frame)
	end
end

function PitBull_Aura:OnChangeConfigMode(value)
	configMode = value
	for unit, frame in PitBull:IterateUnitFrames() do
		self:UpdateAuras(unit, frame)
	end
end

local function updategroup(group)
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_Aura:OnClearUnitFrame(unit, frame)
		PitBull_Aura:OnPopulateUnitFrame(unit, frame)
		unitsShown[frame] = false
		PitBull:UpdateLayout(frame)
	end
end

local function getSplit(group)
	return PitBull_Aura.db.profile[group].split
end

local function setSplit(group, value)
	PitBull_Aura.db.profile[group].split = value
	updategroup(group)
end

local function getSnap(group)
	return PitBull_Aura.db.profile[group].snap
end

local function setSnap(group, value)
	PitBull_Aura.db.profile[group].snap = value
	updategroup(group)
end

local function getSort(group)
	return PitBull_Aura.db.profile[group].sort
end

local function setSort(group, value)
	PitBull_Aura.db.profile[group].sort = value
	updategroup(group)
end

local function getAllOrBuffHidden(group)
	return PitBull_Aura.db.profile[group].hidden or PitBull_Aura.db.profile[group]["hiddenBuffs"]
end
local function getAllOrDebuffHidden(group)
	return PitBull_Aura.db.profile[group].hidden or PitBull_Aura.db.profile[group]["hiddenDebuffs"]
end

local function getHidden(group)
	return PitBull_Aura.db.profile[group].hidden
end

local function getMultiHidden(table)
	local group, type = table.group, table.type
	return PitBull_Aura.db.profile[group]["hidden"..type]
end

local function getMultiEnabled(table)
	local group, type = table.group, table.type
	return not PitBull_Aura.db.profile[group]["hidden"..type]
end

local function setMultiEnabled(table, value)
	value = not value
	local group, type = table.group, table.type
	PitBull_Aura.db.profile[group]["hidden"..type] = value
	if PitBull_Aura.db.profile[group].hiddenBuffs and PitBull_Aura.db.profile[group].hiddenDebuffs then
		PitBull_Aura.db.profile[group].hidden = true
	else
		PitBull_Aura.db.profile[group].hidden = false
	end
	updategroup(group)
end

local function getHighlight(table)
	local group, type = table.group, table.type
	return PitBull_Aura.db.profile[group].highlight[type]
end

local function setHighlight(table, value)
	local group, type = table.group, table.type
	PitBull_Aura.db.profile[group].highlight[type] = value
	updategroup(group)
end

local function getTypeHighlight(table)
	local group, type = table.group, table.type
	return PitBull_Aura.db.profile[group].highlightType[type]
end

local function setTypeHighlight(table, value)
	local group, type = table.group, table.type
	PitBull_Aura.db.profile[group].highlightType[type] = value
	updategroup(group)
end

local function getHighlightColor(table)
	local group, type, type2 = table[1], table[2], table[3]
	return unpack(type2 and PitBull_Aura.db.profile.colors[type][type2] or PitBull_Aura.db.profile.colors[type])
end

local function setHighlightColor(table, r, g, b, a)
	local group, type, type2 = table[1], table[2], table[3]
	if type2 then
		PitBull_Aura.db.profile.colors[type][type2] = {r, g, b, a}
	else
		PitBull_Aura.db.profile.colors[type] = {r, g, b, a}
	end
	updategroup(group)
end

local function getHighlightStyle(group)
	return PitBull_Aura.db.profile[group].highlightStyle
end

local function setHighlightStyle(group, value)
	PitBull_Aura.db.profile[group].highlightStyle = value
	updategroup(group)
end

local function getEnableBuffFilter(group)
	return PitBull_Aura.db.profile[group].buffFilter
end

local function setEnableBuffFilter(group, value)
	PitBull_Aura.db.profile[group].buffFilter = value

	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_Aura:OnUpdateFrame(unit, frame)
	end
end

local function getEnableDebuffFilter(group)
	return PitBull_Aura.db.profile[group].debuffFilter
end

local function setEnableDebuffFilter(group, value)
	PitBull_Aura.db.profile[group].debuffFilter = value

	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_Aura:OnUpdateFrame(unit, frame)
	end
end

local function getFrameHighlight(group)
	return PitBull_Aura.db.profile[group].frameHighlight
end

local function setFrameHighlight(group, value)
	if PitBull_Aura.db.profile[group].frameHighlight == value then
		return
	end

	PitBull_Aura.db.profile[group].frameHighlight = value

	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_Aura:OnUpdateFrame(unit, frame)
	end
end

local function getBuffSize(group)
	return PitBull_Aura.db.profile[group].buffsize
end

local function setBuffSize(group, value)
	if PitBull_Aura.db.profile[group].buffsize == value then
		return
	end

	PitBull_Aura.db.profile[group].buffsize = value

	updategroup(group)
end

local function getDebuffSize(group)
	return PitBull_Aura.db.profile[group].debuffsize
end

local function setDebuffSize(group, value)
	if PitBull_Aura.db.profile[group].debuffsize == value then
		return
	end

	PitBull_Aura.db.profile[group].debuffsize = value

	updategroup(group)
end

local function getMaxBuffs(group)
	return PitBull_Aura.db.profile[group].maxbuffs
end

local function setMaxBuffs(group, value)
	if PitBull_Aura.db.profile[group].maxbuffs == value then
		return
	end

	PitBull_Aura.db.profile[group].maxbuffs = value

	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_Aura:OnUpdateFrame(unit, frame)
	end
end

local function getMaxDebuffs(group)
	return PitBull_Aura.db.profile[group].maxdebuffs
end

local function setMaxDebuffs(group, value)
	if PitBull_Aura.db.profile[group].maxdebuffs == value then
		return
	end

	PitBull_Aura.db.profile[group].maxdebuffs = value

	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_Aura:OnUpdateFrame(unit, frame)
	end
end

local function getFlipped(group)
	return PitBull_Aura.db.profile[group].flip
end

local function setFlipped(group, value)
	if PitBull_Aura.db.profile[group].flip == value then
		return
	end

	PitBull_Aura.db.profile[group].flip = value

	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_Aura:OnUpdateFrame(unit, frame)
	end
end

local function getWeaponBuffItemQuality()
	return PitBull_Aura.db.profile.colors.weaponBuffItemQuality
end

local function setWeaponBuffItemQuality(group, value)
	PitBull_Aura.db.profile.colors.weaponBuffItemQuality = value
	updategroup(group)
end

local function getWeaponBuffSpellIcon()
	return PitBull_Aura.db.profile.weaponBuffSpellIcon
end

local function setWeaponBuffSpellIcon(group, value)
	PitBull_Aura.db.profile.weaponBuffSpellIcon = value
	updategroup(group)
end

local function getGrowthDirection(group)
	local d = PitBull_Aura.db.profile[group].grow
	if d == 1 then
		return "Up"
	elseif d == -1 then
		return "Down"
	end
end

local function setGrowthDirection(group, value)
	if getGrowthDirection(group) == value then
		return
	end

	if value == "Up" then
		PitBull_Aura.db.profile[group].grow = 1
	elseif value == "Down" then
		PitBull_Aura.db.profile[group].grow = -1
	end

	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_Aura:OnUpdateFrame(unit, frame)
	end
end

local function getBuffDirection(group)
	return PitBull_Aura.db.profile[group].buffdirection
end

local function setBuffDirection(group, value)
	if PitBull_Aura.db.profile[group].buffdirection == value then
		return
	end

	PitBull_Aura.db.profile[group].buffdirection = value

	updategroup(group)
end

local function getDebuffDirection(group)
	return PitBull_Aura.db.profile[group].debuffdirection
end

local function setDebuffDirection(group, value)
	if PitBull_Aura.db.profile[group].debuffdirection == value then
		return
	end

	PitBull_Aura.db.profile[group].debuffdirection = value

	updategroup(group)
end

local function getBuffFilterSelection(group, key)
	return PitBull_Aura.db.profile[group].buffFilterSelection[key]
end

local function setBuffFilterSelection(group, key, value)
	PitBull_Aura.db.profile[group].buffFilterSelection[key] = value

	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull_Aura:OnUpdateFrame(unit, frame)
	end
end

local function checkSplitOptionsHidden(group)
	return PitBull_Aura.db.profile[group].split
end

local function checkNonSplitOptionsHidden(group)
	return not PitBull_Aura.db.profile[group].split
end

local buffdirectiontable = {
	["Up then Left"] = L["Up then Left"],
	["Up then Right"] = L["Up then Right"],
	["Down then Left"] = L["Down then Left"],
	["Down then Right"] = L["Down then Right"],
	["Left then Up"] = L["Left then Up"],
	["Left then Down"] = L["Left then Down"],
	["Right then Up"] = L["Right then Up"],
	["Right then Down"] = L["Right then Down"],
}

local buffFilterValidate
PitBull_Aura:RegisterPitBullOptionsMethod(function(group)
	if not buffFilterValidate then
		buffFilterValidate = {}
		for k in pairs(allFriendlyBuffs) do
			buffFilterValidate[k] = k
		end
	end
	local options = {
		type = 'group',
		name = L["Auras"],
		desc = L["Options for buff and debuff display for this unit type."],
		args = {
			Split = {
				type = 'boolean',
				name = L["Split"],
				desc = L["Split buff and debuff positions."],
				get = getSplit,
				set = setSplit,
				passValue = group,
				disabled = getHidden,
			},
			Snap = {
				type = 'boolean',
				name = L["Snap"],
				desc = L["Resize auras to fill the available row space."],
				get = getSnap,
				set = setSnap,
				passValue = group,
				disabled = getHidden,
			},
			Sort = {
				type = 'boolean',
				name = L["Sort"],
				desc = L["Sort this unit's debuffs by type then alphabetically."],
				get = getSort,
				set = setSort,
				passValue = group,
				disabled = getHidden,
			},
			Enable = {
				type = 'group',
				name = L["Enable"],
				desc = L["Enable buffs or debuffs."],
				args = {
					Buffs = {
						type = 'boolean',
						name = L["Buffs"],
						desc = L["Enable buffs."],
						get = getMultiEnabled,
						set = setMultiEnabled,
						passValue = {["group"] = group, ["type"] = "Buffs"},
					},
					Debuffs = {
						type = 'boolean',
						name = L["Debuffs"],
						desc = L["Enable debuffs."],
						get = getMultiEnabled,
						set = setMultiEnabled,
						passValue = {["group"] = group, ["type"] = "Debuffs"},
					}
				},
				order = 1,
			},
			highlight = {
				type = 'group',
				name = L["Highlight"],
				desc = L["Options for highlighting the buff icons."],
				disabled = getHidden,
				passValue = group,
				args = {
					Buffs = {
						type = 'boolean',
						name = L["Buffs"],
						desc = L["Highlight buffs."],
						get = getHighlight,
						set = setHighlight,
						passValue = {["group"] = group, ["type"] = "Buffs"},
						disabled = getMultiHidden,
					},
					BuffsType = {
						type = 'boolean',
						name = L["Buff types"],
						desc = L["Highlight different buffs with different colors based on type."],
						get = getTypeHighlight,
						set = setTypeHighlight,
						passValue = {["group"] = group, ["type"] = "Buffs"},
						disabled = function(group, type) return (not getHighlight(group, type) or getMultiHidden(group, type) or getAllOrBuffHidden(group, type)) end,
					},
					Debuffs = {
						type = 'boolean',
						name = L["Debuffs"],
						desc = L["Highlight debuffs."],
						get = getHighlight,
						set = setHighlight,
						passValue = {["group"] = group, ["type"] = "Debuffs"},
						disabled = getMultiHidden,
					},
					DebuffsType = {
						type = 'boolean',
						name = L["Debuff types"],
						desc = L["Highlight different debuffs with different colors based on type."],
						get = getTypeHighlight,
						set = setTypeHighlight,
						passValue = {["group"] = group, ["type"] = "Debuffs"},
						disabled = function(group, type) return (not getHighlight(group, type) or getMultiHidden(group, type) or getAllOrDebuffHidden(group, type)) end,
					},
					Colors = {
						type = 'group',
						name = L["Colors"],
						desc = L["Set the highlight colors for the various types."],
						args = {
							Buffs = {
								type = 'group',
								name = L["Buffs"],
								desc = L["Set the highlight colors for the various buff types."],
								args = {
									Own = {
										type = 'color',
										name = L["Own"],
										desc = L["Set the color for buffs that you cast."],
										hasAlpha = true,
										get = getHighlightColor,
										set = setHighlightColor,
										passValue = {group, "buffs", "Own"},
									},
									Other = {
										type = 'color',
										name = L["Other"],
										desc = L["Set the color for buffs cast by others."],
										hasAlpha = true,
										get = getHighlightColor,
										set = setHighlightColor,
										passValue = {group, "buffs", "nil"},
									},
								},
							},
							Debuffs = {
								type = 'group',
								name = L["Debuffs"],
								desc = L["Set the highlight colors for the various debuff types."],
								args = {
									Curse = {
										type = 'color',
										name = L["Curse"],
										desc = L["Set color for curses."],
										hasAlpha = true,
										get = getHighlightColor,
										set = setHighlightColor,
										passValue = {group, "debuffs", "Curse"},
									},
									Poison = {
										type = 'color',
										name = L["Poison"],
										desc = L["Set color for poisons."],
										hasAlpha = true,
										get = getHighlightColor,
										set = setHighlightColor,
										passValue = {group, "debuffs", "Poison"},
									},
									Magic = {
										type = 'color',
										name = L["Magic"],
										desc = L["Set color for magic."],
										hasAlpha = true,
										get = getHighlightColor,
										set = setHighlightColor,
										passValue = {group, "debuffs", "Magic"},
									},
									Disease = {
										type = 'color',
										name = L["Disease"],
										desc = L["Set color for diseases."],
										hasAlpha = true,
										get = getHighlightColor,
										set = setHighlightColor,
										passValue = {group, "debuffs", "Disease"},
									},
									Other = {
										type = 'color',
										name = L["Other"],
										desc = L["Set color for others."],
										hasAlpha = true,
										get = getHighlightColor,
										set = setHighlightColor,
										passValue = {group, "debuffs", "nil"},
									},
								}
							}
						}
					}
				}
			},
			framehighlight = {
				type = 'choice',
				name = L["Frame debuff highlight"],
				desc = L["Highlighting the unit frame itself when the unit is debuffed."],
				choices = {
					["Never"] = L["Never"],
					["All Debuffs"] = L["All Debuffs"],
					["Cureable"] = L["Cureable"],
					["Cureable by me"] = L["Cureable by me"],
				},
				get = getFrameHighlight,
				set = setFrameHighlight,
				passValue = group,
			},
			frameHighlightStyle = {
				type = 'choice',
				name = L["Frame debuff highlight style"],
				desc = L["Set how the frame debuff highlight looks."],
				choices = {
					border = L["Border"],
					thinborder = L["Thin Border"],
					normal = L["Normal"],
				},
				get = getHighlightStyle,
				set = setHighlightStyle,
				passValue = group,
				disabled = getAllOrDebuffHidden,
			},
			buffFilter = {
				type = 'boolean',
				name = L["Enable buff filtering"],
				desc = L["Filter certain buffs based on your class."],
				get = getEnableBuffFilter,
				set = setEnableBuffFilter,
				passValue = group,
				disabled = getHidden,
			},
			buffFilterSelection = {
				type = 'multichoice',
				name = L["Buff filtering"],
				desc = L["Select buffs to be filtered."],
				choices = buffFilterValidate,
				get = getBuffFilterSelection,
				set = setBuffFilterSelection,
				disabled = getAllOrBuffHidden,
				passValue = group,
			},
			debuffFilter = {
				type = 'boolean',
				name = L["Enable debuff filtering"],
				desc = L["Filter certain debuffs based on your class."],
				get = getEnableDebuffFilter,
				set = setEnableDebuffFilter,
				passValue = group,
				disabled = getHidden,
			},
			debuffsize = {
				type = 'number',
				name = L["Debuff size"],
				desc = L["Set size of debuff icons."],
				get = getDebuffSize,
				set = setDebuffSize,
				passValue = group,
				min = 4,
				max = 48,
				step = 1,
				disabled = getAllOrDebuffHidden,
			},
			buffsize = {
				type = 'number',
				name = L["Buff size"],
				desc = L["Set size of buff icons."],
				get = getBuffSize,
				set = setBuffSize,
				passValue = group,
				min = 4,
				max = 48,
				step = 1,
				disabled = getAllOrBuffHidden,
			},
			maxbuffs = {
				type = 'number',
				name = L["Max buffs"],
				desc = L["Set the maximum number of buffs to display."],
				get = getMaxBuffs,
				set = setMaxBuffs,
				passValue = group,
				min = 0,
				max = 40,
				step = 1,
				disabled = getAllOrBuffHidden,
			},
			maxdebuffs = {
				type = 'number',
				name = L["Max debuffs"],
				desc = L["Set the maximum number of debuffs to display."],
				get = getMaxDebuffs,
				set = setMaxDebuffs,
				passValue = group,
				min = 0,
				max = 40,
				step = 1,
				disabled = getAllOrDebuffHidden,
			},
			direction = {
				type = 'group',
				name = L["Direction"],
				desc = L["Options for how to position aura icons on this frame."],
				disabled = getHidden,
				passValue = group,
				args = {
					-- options when not in split mode
					flip = {
						type = 'boolean',
						name = L["Flip buffs/debuffs"],
						desc = L["Flip the positions of buffs and debuffs."],
						get = getFlipped,
						set = setFlipped,
						passValue = group,
						hidden = checkSplitOptionsHidden,
					},
					grow = {
						type = 'choice',
						name = L["Growth direction"],
						desc = L["Set the growth direction for extra rows of buffs and debuffs."],
						get = getGrowthDirection,
						set = setGrowthDirection,
						passValue = group,
						choices = {
							["Up"] = L["Up"],
							["Down"] = L["Down"],
						},
						hidden = checkSplitOptionsHidden,
					},
					-- options when in split mode
					buffDirection = {
						type = 'choice',
						name = L["Buff direction"],
						desc = L["Set the direction in which buffs grow."],
						get = getBuffDirection,
						set = setBuffDirection,
						passValue = group,
						choices = buffdirectiontable,
						hidden = checkNonSplitOptionsHidden,
						disabled = getAllOrBuffHidden,
					},
					debuffDirection = {
						type = 'choice',
						name = L["Debuff direction"],
						desc = L["Set the direction in which debuffs grow."],
						get = getDebuffDirection,
						set = setDebuffDirection,
						passValue = group,
						choices = buffdirectiontable,
						hidden = checkNonSplitOptionsHidden,
						disabled = getAllOrDebuffHidden,
					},
				},
			},
		}
	}
    
	-- weapon buffs are only for the player
	if group == "player" then
		options.args.WeaponBuffSpellIcon = {
			type = 'boolean',
			name = L["Use Weapon Buff Spell Icon"],
			desc = L["Check to have weapon buffs show the spell icon, uncheck to have weapon buffs show the weapon icon."],
			get = getWeaponBuffSpellIcon,
			set = setWeaponBuffSpellIcon,
			passValue = group,
			disabled = function() return not getMultiEnabled({["group"] = group, ["type"] = "WeaponBuffs"}) end,
		}
		options.args.Enable.args.WeaponBuffs = {
			type = 'boolean',
			name = L["Weapon Buffs"],
			desc = L["Enable weapon buffs."],
			get = getMultiEnabled,
			set = setMultiEnabled,
			passValue = {["group"] = group, ["type"] = "WeaponBuffs"},
			disabled = function() return not getMultiEnabled({["group"] = group, ["type"] = "Buffs"}) end,
		}
		local buffColourArgs = options.args.highlight.args.Colors.args.Buffs.args
		buffColourArgs.ItemQualityColor = {
			type = 'boolean',
			name = L["Use Weapon Item Quality"],
			desc = L["Weapon buffs will be highlighted using the color of the weapon's quality."],
			get = getWeaponBuffItemQuality,
			set = setWeaponBuffItemQuality,
			passValue = group
		}
		buffColourArgs.Weapon = {
			type = 'color',
			name = L["Weapon"],
			desc = L["Set the color for weapon buffs."],
			hasAlpha = true,
			get = getHighlightColor,
			set = setHighlightColor,
			passValue = {group, "buffs", "Weapon"},
			disabled = getWeaponBuffItemQuality,
		}
	end
    
    return options
end)

-- Global settings
PitBull.options.args.global.args.Aura = {
	type = 'group',
	name = L["Aura"],
	desc = L["Aura options for all units."],
	args = {
		cooldown = {
			type = 'boolean',
			name = L["Cooldown spiral"],
			desc = L["Toggle whether the cooldown spiral shows."],
			get = function()
				return PitBull_Aura.db.profile.cooldown
			end,
			set = function(value)
				PitBull_Aura.db.profile.cooldown = value
				for unit, frame in PitBull:IterateUnitFrames() do
					PitBull_Aura:UpdateAuras(unit, frame)
				end
			end,
		},
		cooldownText = {
			type = 'group',
			name = L["Cooldown text"],
			desc = L["Options for the cooldown text display."],
			args = {
				toggle = {
					type = 'boolean',
					name = L["Toggle"],
					desc = L["Toggle whether to show the cooldown text."],
					get = function()
						return PitBull_Aura.db.profile.cooldownText
					end,
					set = function(value)
						PitBull_Aura.db.profile.cooldownText = value
						for unit, frame in PitBull:IterateUnitFrames() do
							PitBull_Aura:UpdateAuras(unit, frame)
						end
					end,
				},
				alpha = {
					type = 'number',
					name = L["Opacity"],
					desc = L["How transparent/opaque the cooldown text is."],
					min = 0.05,
					max = 1,
					step = 0.01,
					bigStep = 0.05,
					get = function()
						return PitBull_Aura.db.profile.cooldownTextAlpha
					end,
					set = function(value)
						PitBull_Aura.db.profile.cooldownTextAlpha = value
						if PitBull_Aura.db.profile.cooldownText then
							PitBull_Aura.db.profile.cooldownText = false
							for unit, frame in PitBull:IterateUnitFrames() do
								PitBull_Aura:UpdateAuras(unit, frame)
							end
							PitBull_Aura.db.profile.cooldownText = true
							for unit, frame in PitBull:IterateUnitFrames() do
								PitBull_Aura:UpdateAuras(unit, frame)
							end
						end
					end,
				},
			}
		},
		zoomAura = {
			type = 'boolean',
			name = L["Zoom textures"],
			desc = L["Zoom-in on the buff/debuff textures slightly."],
			get = function()
				return PitBull_Aura.db.profile.zoomAura
			end,
			set = function(value)
				PitBull_Aura.db.profile.zoomAura = value
				for unit, frame in PitBull:IterateUnitFrames() do
					PitBull_Aura:ClearAuras(unit, frame)
					PitBull_Aura:UpdateAuras(unit, frame)
				end
			end,
		}
	},
}
