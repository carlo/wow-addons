--[[
    Full credits of the textures go to nbistudio from ui.worldofwar.net!
    
    Description:    Adds a texture at the bottom of the UI and moves the
                    Minimap and right ActionBars.
]]

XArt = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDB-2.0", "AceConsole-2.0")

function XArt:OnInitialize()
    self:RegisterDB("XArtCDB")
    self:RegisterChatCommand({"/xartc"})
end

function XArt:OnEnable()
    self:CreateArtFrame()
    self:AlignTexture()
end

function XArt:OnDisable()
    self.frame:Hide()
    self.frame = nil
end

function XArt:CreateArtFrame()
    self.frame = CreateFrame("Frame", "XArtFrame", UIParent)
    self.frame:SetFrameStrata("BACKGROUND")
    self.frame:EnableMouse(false)
    self.frame:SetMovable(false)
    self.frame:SetWidth(1920)
    self.frame:SetHeight(256)
    self.frame:ClearAllPoints()
    self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    
    for i=1,4 do
        self["art"..i] = self.frame:CreateTexture("$parentArt"..i,"BACKGROUND")
        self["art"..i]:SetWidth(512)
        self["art"..i]:SetHeight(256)
        self["art"..i]:SetTexture("Interface\\Addons\\XArtC\\Textures\\royalbar2-"..i)
        self["art"..i]:ClearAllPoints()
        if i == 1 then
            self["art"..i]:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, -12)
        else
            self["art"..i]:SetPoint("BOTTOMLEFT", self["art"..i-1], "BOTTOMRIGHT", 0, 0)
        end
        self["art"..i]:Show()
    end
    self.frame:Show()
end

function XArt:AlignTexture()
    self.frame:SetScale(UIParent:GetWidth()/1920)
end

