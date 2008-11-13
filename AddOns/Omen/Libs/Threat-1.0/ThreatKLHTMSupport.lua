local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 50401 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

---------------------------------------------------------------------------
-- Global stuff
---------------------------------------------------------------------------

local _G = _G
local tonumber = _G.tonumber
local type = _G.type
local select = _G.select
local next = _G.next
local pcall = _G.pcall
local pairs = _G.pairs
local tinsert = _G.tinsert
local UnitExists = _G.UnitExists
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local UnitCanAttack = _G.UnitCanAttack
local GetNumRaidMembers = _G.GetNumRaidMembers
local GetNumPartyMembers = _G.GetNumPartyMembers

---------------------------------------------------------------------------
-- ThreatLib and its internals
---------------------------------------------------------------------------

local ThreatLib = _G.ThreatLib
local ThreatKLHTMSupport = ThreatLib:NewModule("KLHTMSupport", "AceEvent-2.0")

local partyMemberUsesKLHTM = ThreatLib.partyMemberUsesKLHTM
local partyMemberRevisions = ThreatLib.partyMemberRevisions
local IsGroupOfficer = ThreatLib.IsGroupOfficer
local partyUnits = ThreatLib.partyUnits
local TailoredBinaryCheckSum = ThreatLib.TailoredBinaryCheckSum

local playerName

---------------------------------------------------------------------------
-- KTM message processing
---------------------------------------------------------------------------

local OnPureKLHTMMessage = {}
ThreatKLHTMSupport.OnPureKLHTMMessage = OnPureKLHTMMessage
local OnAnyKLHTMMessage = {}
ThreatKLHTMSupport.OnAnyKLHTMMessage = OnAnyKLHTMMessage

function ThreatKLHTMSupport:OnInitialize()
	playerName = UnitName("player")
	ThreatLib:ToggleModuleActive(self, true)
end

function ThreatKLHTMSupport:OnEnable()
	self:RegisterEvent("CHAT_MSG_ADDON")
end

local function handleMessage(self, handler, sender, command, data)
	local func = handler[command]
	if func then
		func(self, sender, data)
	end
end

function ThreatKLHTMSupport:CHAT_MSG_ADDON(prefix, message, distribution, sender)
	if prefix == "KLHTM" and sender ~= playerName and (distribution == "PARTY" or distribution == "RAID") then
		local command, data = message:match("^(%a+) ?(.*)")
		if command then			
			if partyMemberRevisions[sender] then
				partyMemberUsesKLHTM[sender] = nil	
				
			elseif not partyMemberUsesKLHTM[sender] then
				partyMemberUsesKLHTM[sender] = true
				ThreatLib.dispatchEvent('KLHTM_NewPeer', sender)			
			end

			if partyMemberUsesKLHTM[sender] and not partyMemberRevisions[sender] then
				handleMessage(self, OnPureKLHTMMessage, sender, command, data)
			end
			handleMessage(self, OnAnyKLHTMMessage, sender, command, data)
		end
	end
end

---------------------------------------------------------------------------
-- Threat update and misdirection
---------------------------------------------------------------------------

function ThreatKLHTMSupport.OnPureKLHTMMessage:t(sender, data)
	local _ = partyUnits[nil] -- refresh if need be
	local threat = tonumber(data)
	if threat then
		ThreatLib:ThreatUpdatedForUnit( sender, TailoredBinaryCheckSum[self.KLHTMtarget or "_GLOBAL_"], threat)
	end
end

function ThreatKLHTMSupport.OnPureKLHTMMessage:misdirection(sender, data)
	local targetPlayer, amount = data:match("^(%S+) (%d+)$")
	local senderUnit = partyUnits[sender]
	if targetPlayer == playerName and senderUnit and select(2, UnitClass(senderUnit)) == "HUNTER" then
		local targetEnemy = UnitName(senderUnit .. "target") or self.KLHTMtarget or "_GLOBAL_"
		amount = tonumber(amount)
		ThreatLib:Debug("KLHTM misdirection from %q : %q against %q", sender, amount, targetEnemy)
		ThreatLib:GetModule("ClassCore").activeModule:_addTargetThreat(amount, targetEnemy)
	end
end

---------------------------------------------------------------------------
-- Master target
---------------------------------------------------------------------------

local function UpdateKLHTMTarget(target)
	if (target or "") ~= (ThreatKLHTMSupport.KLHTMtarget or "") then
		ThreatKLHTMSupport.KLHTMtarget = target
		ThreatLib.dispatchEvent('KLHTM_TargetChanged', target)
	end
end

function ThreatKLHTMSupport.OnAnyKLHTMMessage:target(sender, data)
	if data and type(data) == "string" then
		local senderUnit = partyUnits[sender]
		if IsGroupOfficer(senderUnit) then
			local senderTargetUnit = senderUnit..'target'
			if UnitExists(senderTargetUnit) then
				UpdateKLHTMTarget(UnitName(senderTargetUnit))
			else
				UpdateKLHTMTarget(ThreatLib:TranslateForeignMobName(data))
			end
			ThreatLib:Debug("KTM Target set to %s (%s) by %s", self.KLHTMtarget, data, sender)
		else
			ThreatLib:Debug("Dropped target from %q", sender)
		end
	end
end

function ThreatKLHTMSupport.OnAnyKLHTMMessage:cleartarget(sender, data)
	local senderUnit = partyUnits[sender]
	if IsGroupOfficer(senderUnit) then
		UpdateKLHTMTarget(nil)
		ThreatLib:Debug("KTM Target cleared by %s", sender)
	else
		ThreatLib:Debug("Dropped cleartarget from %q", sender)
	end
end

---------------------------------------------------------------------------
-- Version responses
---------------------------------------------------------------------------

function ThreatKLHTMSupport.OnPureKLHTMMessage:versionresponse(sender, version)
	local senderUnit = partyUnits[sender]
	if senderUnit and version:match("^%d+\.%d+$") and not partyMemberRevisions[sender]  then
		if version ~= (partyMemberUsesKLHTM[sender] or false) then
			partyMemberUsesKLHTM[sender] = version
			ThreatLib.dispatchEvent('KLHTM_VersionResponse', sender, version)
		end
	end
end

---------------------------------------------------------------------------
-- Empty KLHTM methods
---------------------------------------------------------------------------

do
	local function noop() end

	ThreatLib.IsKLHTMSupportLoaded = noop
	ThreatLib.IsKLHTMBroadcastEnabled = noop
	
	ThreatKLHTMSupport.IsKLHTMBroadcastActive = noop

	ThreatKLHTMSupport.PublishThreatToKLHTM = noop
	ThreatKLHTMSupport.MisdirectToKLHTM = noop
	
	ThreatKLHTMSupport.SetKLHTMMasterTarget = noop
	ThreatKLHTMSupport.ClearKLHTMMasterTarget = noop
	ThreatKLHTMSupport.QueryKLHTMVersions = noop

	ThreatKLHTMSupport.SendKLHTMMessage = noop
end

---------------------------------------------------------------------------
-- Real KLHTM output methods
---------------------------------------------------------------------------

local function LoadKLHTMBroadcastSupport()

	-- Won't load if the real KLHTM has been loaded
	if _G.klhtm then
		ThreatLib.EnableKLHTMBroadcast = function() end
		return 
	end
	
	-- Locals
	local lastPublishedThreat
	local enabled

---------------------------------------------------------------------------
-- Global status accessors
---------------------------------------------------------------------------
	
	function ThreatLib:EnableKLHTMBroadcast(value)
		if enabled and not value then
			if lastPublishedThreat and lastPublishedThreat > 0 then
				ThreatKLHTMSupport:PublishThreatToKLHTM(nil)
			end
			enabled = nil
			ThreatLib.dispatchEvent('KLHTM_BroadcastDisabled')
			
		elseif not enabled and value then
			enabled = true
			lastPublishedThreat = nil
			ThreatLib.dispatchEvent('KLHTM_BroadcastEnabled')
		end
	end
		
	function ThreatLib:IsKLHTMBroadcastEnabled()
		return enabled
	end

	function ThreatLib:IsKLHTMSupportLoaded()
		return true
	end

---------------------------------------------------------------------------
-- Module status accessors
---------------------------------------------------------------------------
	
	function ThreatKLHTMSupport:IsKLHTMBroadcastActive()
		return enabled and next(partyMemberUsesKLHTM) and ThreatLib:IsActive()
	end
	
---------------------------------------------------------------------------
-- Publishing methods
---------------------------------------------------------------------------
	local player
	
	function ThreatKLHTMSupport:PublishThreatToKLHTM()
		if not enabled or (not force and not next(partyMemberUsesKLHTM)) then -- no point
			return
		end
		if not player then
			player = UnitName("player")
		end
		local threat = 0
				
		if self.KLHTMtarget then
			threat = ThreatLib:GetThreat(player, self.KLHTMtarget)
		else
			threat = ThreatLib:GetCumulativeThreat(player)
		end
		if threat and threat ~= (lastPublishedThreat or -1) then
			ThreatLib:Debug("Publishing %s to KTM", threat)
			if self:SendKLHTMMessage('t', threat) then
				lastPublishedThreat = threat
			end
		end
	end
	
	function ThreatKLHTMSupport:MisdirectToKLHTM(targetPlayer, threat)
		if not enabled then
			return
		end		
		self:SendKLHTMMessage('misdirection', ("%s %d"):format(targetPlayer, threat))
	end
	
	function ThreatKLHTMSupport:SetKLHTMMasterTarget(targetUnit)
		if not enabled or not IsGroupOfficer("player") then
			return
		end
		if not targetUnit then
			targetUnit = "target"
		end
		if UnitExists(targetUnit) and UnitCanAttack("player", targetUnit) then
			local target = UnitName(targetUnit)
			if self:SendKLHTMMessage("target", target) then
				UpdateKLHTMTarget(target)
				return true
			end
		end
	end
	
	function ThreatKLHTMSupport:ClearKLHTMMasterTarget()
		if not enabled or not IsGroupOfficer("player") then
			return
		end
		if self:SendKLHTMMessage("cleartarget") then
			UpdateKLHTMTarget(nil)
			return true
		end
	end	
	
	function ThreatKLHTMSupport:QueryKLHTMVersions()
		if not IsGroupOfficer("player") then
			return
		end
		return self:SendKLHTMMessage("versionquery", nil, true)
	end	
	
---------------------------------------------------------------------------
-- Actual sending method
---------------------------------------------------------------------------

	function ThreatKLHTMSupport:SendKLHTMMessage(command, data, force)
		local _ = partyUnits[nil] -- refresh if need be
		if not enabled or (not force and not next(partyMemberUsesKLHTM)) then -- no point
			return
		end
		local distribution
		if GetNumRaidMembers() > 0 then
			distribution = "RAID"
		elseif GetNumPartyMembers() > 0 then
			distribution = "PARTY"
		else
			return
		end
		
		local message
		if data then
			message = command .. " " .. data
		else
			message = command
		end
		
		ChatThrottleLib:SendAddonMessage("ALERT", "KLHTM", message, distribution)
		return true
	end
end

---------------------------------------------------------------------------
-- Enabling stub
---------------------------------------------------------------------------

-- This method will be overriden by LoadKLHTMBroadcastSupport()
function ThreatLib:EnableKLHTMBroadcast(value)
	if value then
		local res, reason = pcall(LoadKLHTMBroadcastSupport)
		if not res then
			geterrorhandler()(reason)
		else
			-- call the real one
			self:EnableKLHTMBroadcast(true)
		end
	end
end

---------------------------------------------------------------------------

tinsert(ThreatLib.UpvalueFixers, function(lib, oldLib)
	ThreatLib = lib
	
	if oldLib then
		if oldLib.IsKLHTMBroadcastEnabled then
			if oldLib:IsKLHTMBroadcastEnabled() then
				ThreatLib:EnableKLHTMBroadcast(true)
			end
		else
			if oldLib:GetModule("KLHTMSupport") and oldLib:GetModule("KLHTMSupport"):IsKLHTMBroadcastEnabled() then
				ThreatLib:EnableKLHTMBroadcast(true)
			end
		end
	end
end)

end

