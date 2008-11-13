if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 49324 $"):match("%d+"))

local PitBull = PitBull
local PitBull_HideBlizzard = PitBull:NewModule("HideBlizzard")
local self = PitBull_HideBlizzard
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-09-19 21:13:35 -0400 (Wed, 19 Sep 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Hide Blizzard frames that are no longer needed."] = "더 이상 필요치 않는 블리자드 프레임을 숨깁니다.",
	["Hide Blizzard frames"] = "블리자드 프레임 숨김",
	["Toggles hiding frames provided by the default user interface.\n\nNote that it's not uncommon to have other addons that provide similar functionality, like hiding the cast bar."] = "기본 사용자 인터페이스를 통해 프레임 숨김 기능을 전환합니다.\n\nNote that it's not uncommon to have other addons that provide similar functionality, like hiding the cast bar.",
	["Player"] = "플레이어",
	["Hides the standard player frame."] = "기본 플레이어 프레임을 숨깁니다.",
	["Party"] = "파티",
	["Hides the standard party frames."] = "기본 파티 프레임을 숨깁니다.",
	["Target"] = "대상",
	["Hides the standard target frame."] = "기본 대상 프레임을 숨깁니다.",
	["Cast bar"] = "시전바",
	["Hides the standard cast bar."] = "기본 시전바를 숨깁니다.",
	["Buffs/Debuffs"] = "버프/디버프",
	["Hides the standard buff/debuff frame in the top-right corner of the screen."] = "화면의 상단 우측 모서리에 있는 기본 버프/디버프 프레임을 숨깁니다.",
} or {}

local L = PitBull:L("PitBull-HideBlizzard", localization)

self.desc = L["Hide Blizzard frames that are no longer needed."]

local newList, del = Rock:GetRecyclingFunctions("PitBull", "newList", "del")
local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

local UnitIsUnit = UnitIsUnit

function PitBull_HideBlizzard:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("HideBlizzard")
	PitBull:SetDatabaseNamespaceDefaults("HideBlizzard", "profile", {
		player = true,
		party = true,
		target = true,
		castbar = true,
		aura = false,
	})

	PitBull.options.args.HideBlizzard = {
		type = 'group',
		order = 2,
		name = L["Hide Blizzard frames"],
		desc = L["Toggles hiding frames provided by the default user interface.\n\nNote that it's not uncommon to have other addons that provide similar functionality, like hiding the cast bar."],
		child_get = function(key)
			return self.db.profile[key]
		end,
		child_set = function(key, value)
			self.db.profile[key] = value
			self:UpdateBlizzardFrames()
		end,
		child_type = 'boolean',
		args = {
			player = {
				name = L["Player"],
				desc = L["Hides the standard player frame."],
				passValue = "player",
			},
			party = {
				name = L["Party"],
				desc = L["Hides the standard party frames."],
				passValue = "party",
			},
			target = {
				name = L["Target"],
				desc = L["Hides the standard target frame."],
				passValue = "target",
			},
			castbar = {
				name = L["Cast bar"],
				desc = L["Hides the standard cast bar."],
				passValue = "castbar",
			},
			aura = {
				name = L["Buffs/Debuffs"],
				desc = L["Hides the standard buff/debuff frame in the top-right corner of the screen."],
				passValue = "aura",
			}
		},
		hidden = function()
			return not PitBull:IsModuleActive(self)
		end,
	}
end

function PitBull_HideBlizzard:OnEnable(first)
	self:UpdateBlizzardFrames()
end

function PitBull_HideBlizzard:OnDisable()
	self:ShowBlizzardPlayerFrame()
	self:ShowBlizzardPartyFrames()
	self:ShowBlizzardTargetFrame()
	self:ShowBlizzardCastingBar()
	self:ShowBlizzardAuraFrame()
end

function PitBull_HideBlizzard:UpdateBlizzardFrames()
	if self.db.profile.player then
		self:HideBlizzardPlayerFrame()
	else
		self:ShowBlizzardPlayerFrame()
	end
	if self.db.profile.party then
		self:HideBlizzardPartyFrames()
	else
		self:ShowBlizzardPartyFrames()
	end
	if self.db.profile.target then
		self:HideBlizzardTargetFrame()
	else
		self:ShowBlizzardTargetFrame()
	end
	if self.db.profile.castbar then
		self:HideBlizzardCastingBar()
	else
		self:ShowBlizzardCastingBar()
	end
	if self.db.profile.aura then
		self:HideBlizzardAuraFrame()
	else
		self:ShowBlizzardAuraFrame()
	end
end

local playerFrameState = true

function PitBull_HideBlizzard:HideBlizzardPlayerFrame()
	if not playerFrameState then
		return
	end
	playerFrameState = false
	PlayerFrame:UnregisterAllEvents()
	PlayerFrameHealthBar:UnregisterAllEvents()
	PlayerFrameManaBar:UnregisterAllEvents()
	PlayerFrame:Hide()
end

function PitBull_HideBlizzard:ShowBlizzardPlayerFrame()
	if playerFrameState then
		return
	end
	playerFrameState = true
	PlayerFrame:RegisterEvent("UNIT_LEVEL")
	PlayerFrame:RegisterEvent("UNIT_COMBAT")
	PlayerFrame:RegisterEvent("UNIT_SPELLMISS")
	PlayerFrame:RegisterEvent("UNIT_PVP_UPDATE")
	PlayerFrame:RegisterEvent("UNIT_MAXMANA")
	PlayerFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
	PlayerFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
	PlayerFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
	PlayerFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	PlayerFrame:RegisterEvent("PARTY_LEADER_CHANGED")
	PlayerFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	PlayerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	PlayerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	PlayerFrameHealthBar:RegisterEvent("UNIT_HEALTH")
	PlayerFrameHealthBar:RegisterEvent("UNIT_MAXHEALTH")
	PlayerFrameManaBar:RegisterEvent("UNIT_MANA")
	PlayerFrameManaBar:RegisterEvent("UNIT_RAGE")
	PlayerFrameManaBar:RegisterEvent("UNIT_FOCUS")
	PlayerFrameManaBar:RegisterEvent("UNIT_ENERGY")
	PlayerFrameManaBar:RegisterEvent("UNIT_HAPPINESS")
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXMANA")
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXRAGE")
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXFOCUS")
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXENERGY")
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXHAPPINESS")
	PlayerFrameManaBar:RegisterEvent("UNIT_DISPLAYPOWER")
	PlayerFrame:RegisterEvent("UNIT_NAME_UPDATE")
	PlayerFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	PlayerFrame:RegisterEvent("UNIT_DISPLAYPOWER")
	PlayerFrame:Show()
end

local partyFrameState = true

function PitBull_HideBlizzard:HideBlizzardPartyFrames()
	if not partyFrameState then
		return
	end
	partyFrameState = false
	for i = 1, 4 do
		local frame = _G["PartyMemberFrame"..i]
		frame:UnregisterAllEvents()
		frame:Hide()
		frame.Show = function() end
	end
	
	UIParent:UnregisterEvent("RAID_ROSTER_UPDATE")
end

function PitBull_HideBlizzard:ShowBlizzardPartyFrames()
	if partyFrameState then
		return
	end
	partyFrameState = true
	for i = 1, 4 do
		local frame = _G["PartyMemberFrame"..i]
		frame.Show = nil
		frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
		frame:RegisterEvent("PARTY_LEADER_CHANGED")
		frame:RegisterEvent("PARTY_MEMBER_ENABLE")
		frame:RegisterEvent("PARTY_MEMBER_DISABLE")
		frame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
		frame:RegisterEvent("UNIT_PVP_UPDATE")
		frame:RegisterEvent("UNIT_AURA")
		frame:RegisterEvent("UNIT_PET")
		frame:RegisterEvent("VARIABLES_LOADED")
		frame:RegisterEvent("UNIT_NAME_UPDATE")
		frame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
		frame:RegisterEvent("UNIT_DISPLAYPOWER")

		UnitFrame_OnEvent("PARTY_MEMBERS_CHANGED")
		
		_G.this = frame
		PartyMemberFrame_UpdateMember()
	end
	
	UIParent:RegisterEvent("RAID_ROSTER_UPDATE")
end

local targetFrameState = true

function PitBull_HideBlizzard:HideBlizzardTargetFrame()
	if not targetFrameState then
		return
	end
	targetFrameState = false
	TargetFrame:UnregisterAllEvents()
	TargetFrame:Hide()

	ComboFrame:UnregisterAllEvents()
end

function PitBull_HideBlizzard:ShowBlizzardTargetFrame()
	if targetFrameState then
		return
	end
	targetFrameState = true
	TargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	TargetFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
	TargetFrame:RegisterEvent("UNIT_HEALTH")
	TargetFrame:RegisterEvent("UNIT_LEVEL")
	TargetFrame:RegisterEvent("UNIT_FACTION")
	TargetFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
	TargetFrame:RegisterEvent("UNIT_AURA")
	TargetFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
	TargetFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	if UnitExists("target") then
		TargetFrame:Show()
	end

	ComboFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
	ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	ComboFrame:RegisterEvent("PLAYER_COMBO_POINTS")
end

local castingBarState = true
function PitBull_HideBlizzard:HideBlizzardCastingBar()
	if not castingBarState then
		return
	end
	castingBarState = false
	CastingBarFrame:UnregisterAllEvents()
	PetCastingBarFrame:UnregisterAllEvents()
end

function PitBull_HideBlizzard:ShowBlizzardCastingBar()
	if castingBarState then
		return
	end
	castingBarState = true
	local t = newList(CastingBarFrame, PetCastingBarFrame)
	for i,v in ipairs(t) do
		v:RegisterEvent("UNIT_SPELLCAST_START")
		v:RegisterEvent("UNIT_SPELLCAST_STOP")
		v:RegisterEvent("UNIT_SPELLCAST_FAILED")
		v:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
		v:RegisterEvent("UNIT_SPELLCAST_DELAYED")
		v:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		v:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
		v:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
	t = del(t)
	
	PetCastingBarFrame:RegisterEvent("UNIT_PET")
end

local auraFrameState = true
function PitBull_HideBlizzard:HideBlizzardAuraFrame()
	if not auraFrameState then
		return
	end
	auraFrameState = false
	BuffFrame:Hide()
	TemporaryEnchantFrame:Hide()
	BuffFrame:UnregisterAllEvents()
end

function PitBull_HideBlizzard:ShowBlizzardAuraFrame()
	if auraFrameState then
		return
	end
	auraFrameState = true
	BuffFrame:Show()
	TemporaryEnchantFrame:Show()
	BuffFrame:RegisterEvent("PLAYER_AURAS_CHANGED")
	
	BuffFrame_Update()
end
