local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
-- register module
local VehicleBarMod = Bartender4:NewModule("Vehicle")

-- fetch upvalues
local ButtonBar = Bartender4.ButtonBar.prototype

-- create prototype information
local VehicleBar = setmetatable({}, {__index = ButtonBar})

local table_insert = table.insert

local defaults = { profile = Bartender4:Merge({
	enabled = true,
	visibility = {
		custom = true,
		customdata = "[target=vehicle,exists]show;hide"
	},
}, Bartender4.ButtonBar.defaults) }

function VehicleBarMod:OnInitialize()
	self.db = Bartender4.db:RegisterNamespace("Vehicle", defaults)
	self:SetEnabledState(self.db.profile.enabled)
end

function VehicleBarMod:OnEnable()
	if not self.bar then
		self.bar = setmetatable(Bartender4.ButtonBar:Create("Vehicle", self.db.profile, L["Vehicle Bar"], true), {__index = VehicleBar})
		local buttons = {VehicleMenuBarLeaveButton, VehicleMenuBarPitchUpButton, VehicleMenuBarPitchDownButton}
		self.bar.buttons = buttons
		
		VehicleBarMod.button_count = 3

		for i,v in pairs(buttons) do
			v:SetParent(self.bar)
			v:Show()
			v.ClearSetPoint = self.bar.ClearSetPoint
		end
		
		self.bar:SetScript("OnEvent", self.bar.OnEvent)
		self.bar:RegisterEvent("UNIT_ENTERED_VEHICLE")
		
		-- setup button skins
		VehicleMenuBarPitchUpButton:GetNormalTexture():SetTexture([[Interface\Vehicles\UI-Vehicles-Button-Pitch-Up]])
		VehicleMenuBarPitchUpButton:GetNormalTexture():SetTexCoord(0.21875, 0.765625, 0.234375, 0.78125)
		VehicleMenuBarPitchUpButton:GetPushedTexture():SetTexture([[Interface\Vehicles\UI-Vehicles-Button-Pitch-Down]])
		VehicleMenuBarPitchUpButton:GetPushedTexture():SetTexCoord(0.21875, 0.765625, 0.234375, 0.78125)
		
		VehicleMenuBarPitchDownButton:GetNormalTexture():SetTexture([[Interface\Vehicles\UI-Vehicles-Button-PitchDown-Up]])
		VehicleMenuBarPitchDownButton:GetNormalTexture():SetTexCoord(0.21875, 0.765625, 0.234375, 0.78125)
		VehicleMenuBarPitchDownButton:GetPushedTexture():SetTexture([[Interface\Vehicles\UI-Vehicles-Button-PitchDown-Down]])
		VehicleMenuBarPitchDownButton:GetPushedTexture():SetTexCoord(0.21875, 0.765625, 0.234375, 0.78125)
		
		VehicleMenuBarLeaveButton:GetNormalTexture():SetTexture([[Interface\Vehicles\UI-Vehicles-Button-Exit-Up]])
		VehicleMenuBarLeaveButton:GetNormalTexture():SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)
		VehicleMenuBarLeaveButton:GetPushedTexture():SetTexture([[Interface\Vehicles\UI-Vehicles-Button-Exit-Down]])
		VehicleMenuBarLeaveButton:GetPushedTexture():SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)
	end
	self.bar:Enable()
	self:ToggleOptions()
	self:ApplyConfig()
end

function VehicleBarMod:ApplyConfig()
	self.bar:ApplyConfig(self.db.profile)
end

VehicleBar.button_width = 30
VehicleBar.button_height = 30
VehicleBar.LBFOverride = true
function VehicleBar:ApplyConfig(config)
	ButtonBar.ApplyConfig(self, config)
	
	if not self.config.position then
		self:ClearSetPoint("CENTER", -105, 27)
		self:SavePosition()
	end
	
	self:UpdateButtonLayout()
end

function VehicleBar:OnEvent(event, arg1)
	if event == "UNIT_ENTERED_VEHICLE" then
		if arg1 == "player" then
			self:UpdateButtonVisibility()
		end
	end
end

function VehicleBar:UpdateButtonVisibility()
	if IsVehicleAimAngleAdjustable() then
		_G["VehicleMenuBarPitchUpButton"]:Show()
		_G["VehicleMenuBarPitchDownButton"]:Show()
	else
		_G["VehicleMenuBarPitchUpButton"]:Hide()
		_G["VehicleMenuBarPitchDownButton"]:Hide()
	end
	
	if CanExitVehicle() then
		_G["VehicleMenuBarLeaveButton"]:Show()
	else
		_G["VehicleMenuBarLeaveButton"]:Hide()
	end
end
