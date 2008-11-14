if select(2, UnitClass("player")) ~= "DEATH KNIGHT" then return end
local GT = LibStub:GetLibrary("LibGratuity-3.0")
local GetSpellInfo = GetSpellInfo

local PlayerAura = DrDamage.PlayerAura

function DrDamage:PlayerData()

	--DK spells crit for double-damage (an extra 100%)
	self.Calculation["Death Knight"] = function(calculation)
		if not calculation.isMelee then
			calculation.critM = 1
		end
	end

end