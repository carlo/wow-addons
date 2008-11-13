local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 41486 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

local _, c = _G.UnitClass("player")
if c ~= "HUNTER" then return end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local _G = _G
local tonumber = _G.tonumber
local getmetatable = _G.getmetatable

local AceLibrary = _G.AceLibrary

local ThreatLib = _G.ThreatLib

local BS = AceLibrary("Babble-Spell-2.2")
local Hunter = ThreatLib:GetModule("ClassCore"):NewModule(c)

local distractThreatAmounts		= {110, 160, 250, 350, 465, 600, 900}
local disengageThreatAmounts	= {-140, -280, -405, -545}
local FDString

function Hunter:ClassInit()
	self.className = "HUNTER"
	
	-- CastHandlers
	self.CastHandlers[BS["Distracting Shot"]] 	= self.DistractingShot
	self.CastHandlers[BS["Disengage"]]			= self.Disengage
	
	self.CastHandlers[BS["Feign Death"]]		= self.FeignDeath

	-- ClassBuffs
	self.ClassBuffs[BS["Misdirection"]]			= self.MisdirectionBuff
	

	-- Needed for FD. Ugly as hell, but it works.
	FDString = BS["Feign Death"]
	self:RegisterEvent("UNIT_SPELLCAST_SENT")
	self:RegisterEvent("UI_ERROR_MESSAGE")
	-- ERR_FEIGN_DEATH_RESISTED
end

function Hunter:DistractingShot(rank)
	local ranknum = tonumber(rank:match("%d+"))
	self:AddTargetThreat(distractThreatAmounts[ranknum] * self:threatMods())
end

function Hunter:Disengage(rank)
	local ranknum = tonumber(rank:match("%d+"))
	self:AddTargetThreat(disengageThreatAmounts[ranknum] * self:threatMods())
end

-- Feign is a rather unique case. It's cast on all targets, but may be resisted by any one target. There is no combat log message - only an error event with ERR_FEIGN_DEATH_RESISTED from GlobalStrings
-- ERR_FEIGN_DEATH_RESISTED always happens before SPELLCAST_SUCCESSFUL, so we "prime" FD when we get SENT, then invalidate it if we get a resist, let it through otherwise.
-- The net effect is that a resist on any one target invalidates the threat reset on all targets, but we can't help that since we don't have target data on who resisted
local FeignDeathPrimed = false
function Hunter:FeignDeath()
	if FeignDeathPrimed then
		FeignDeathPrimed = false
		self:_reduceAllThreat(0)
		ThreatLib:Debug("Running FD, clearing threat!")
	end	
end

function Hunter:UNIT_SPELLCAST_SENT(arg1, arg2, arg3, arg4)
	if arg1 == "player" and arg2 == FDString then
		ThreatLib:Debug("FD is primed!")
		FeignDeathPrimed = true
	elseif arg1 == "player" then
		-- call prototype's :UNIT_SPELLCAST_SENT
		getmetatable(self).__index.UNIT_SPELLCAST_SENT(self, arg1, arg2, arg3, arg4)
	end
end

function Hunter:UI_ERROR_MESSAGE(arg1)
	if arg1 == ERR_FEIGN_DEATH_RESISTED then
		ThreatLib:Debug("Canceling FD!")
		FeignDeathPrimed = false
	end
end

function Hunter:MisdirectionBuff(action, rank, apps)
	-- Previous implementation was a bit too clever :P
	if action == "lose" then
		ThreatLib:Debug("Lost Misdirection")
		self:RedirectThreatTo(nil)
	elseif action == "gain" then
		ThreatLib:Debug("Gained misdirection, target is %s", self.currentTarget)
		self:RedirectThreatTo(self.currentTarget)
	end
end

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
	Hunter = ThreatLib:GetModule("ClassCore"):GetModule(c)
end)

end
