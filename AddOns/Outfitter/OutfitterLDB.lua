Outfitter.LDB = {}

function Outfitter.LDB:Initialize()
	self.LDB = LibStub("LibDataBroker-1.1", true)
	self.DataObj = self.LDB:NewDataObject(Outfitter.cTitle,
	{
		type = "data source",
		icon = "Interface\\AddOns\\Outfitter\\Textures\\Icon",
		text = "Outfitter",
		OnClick = function(frame, button)
			if button == "LeftButton" then
				Outfitter.MinimapDropDown_OnLoad(frame)
				frame.ChangedValueFunc = Outfitter.MinimapButton_ItemSelected
				ToggleDropDownMenu(nil, nil, frame, frame, 22, 1)
				
				-- Hack to force the menu to position correctly.  UIDropDownMenu code
				-- keeps thinking that it's off the screen and trying to reposition
				-- it, which it does very poorly
				
				Outfitter.MinimapDropDown_AdjustScreenPosition(frame)
				
				PlaySound("igMainMenuOptionCheckBoxOn")
			else
				Outfitter:ToggleUI(true)
			end
		end
	})
	
	Outfitter:RegisterOutfitEvent("WEAR_OUTFIT", function (...) self:OutfitEvent(...) end)
	Outfitter:RegisterOutfitEvent("UNWEAR_OUTFIT", function (...) self:OutfitEvent(...) end)
	Outfitter:RegisterOutfitEvent("OUTFITTER_INIT", function (...) self:OutfitEvent(...) end)
end

function Outfitter.LDB:OutfitEvent()
	self.DataObj.text = Outfitter:GetCurrentOutfitInfo()
end

Outfitter.LDB:Initialize()
