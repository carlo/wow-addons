--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryGlyphFrame.lua,v 1.2, 2008-11-11 10:16:26Z, Maxim Baars$
    URL: http://www.wow-neighbours.com

    License:
        This program is free software; you can redistribute it and/or
        modify it under the terms of the GNU General Public License
        as published by the Free Software Foundation; either version 2
        of the License, or (at your option) any later version.

        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.

        You should have received a copy of the GNU General Public License
        along with this program(see GPL.txt); if not, write to the Free Software
        Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

    Note:
        This AddOn's source code is specifically designed to work with
        World of Warcraft's interpreted AddOn system.
        You have an implicit licence to use this AddOn with these facilities
        since that is it's designated purpose as per:
        http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]] 

ARMORY_GLYPHTYPE_MAJOR = 1;
ARMORY_GLYPHTYPE_MINOR = 2;

ARMORY_GLYPH_MINOR = { r = 0, g = 0.25, b = 1};
ARMORY_GLYPH_MAJOR = { r = 1, g = 0.25, b = 0};

ARMORY_GLYPH_SLOTS = {};
-- Empty Texture
ARMORY_GLYPH_SLOTS[0] = { left = 0.78125; right = 0.91015625; top = 0.69921875; bottom = 0.828125;}
-- Major Glyphs
ARMORY_GLYPH_SLOTS[3] = { left = 0.392578125; right = 0.521484375; top = 0.87109375; bottom = 1;}
ARMORY_GLYPH_SLOTS[1] = { left = 0; right = 0.12890625; top = 0.87109375; bottom = 1;}
ARMORY_GLYPH_SLOTS[5] = { left = 0.26171875; right = 0.390625; top = 0.87109375; bottom = 1;}
-- Minor Glyphs
ARMORY_GLYPH_SLOTS[2] = { left = 0.130859375; right = 0.259765625; top = 0.87109375; bottom = 1;}
ARMORY_GLYPH_SLOTS[6] = { left = 0.654296875; right = 0.783203125; top = 0.87109375; bottom = 1;}
ARMORY_GLYPH_SLOTS[4] = { left = 0.5234375; right = 0.65234375; top = 0.87109375; bottom = 1;}

ARMORY_NUM_GLYPH_SLOTS = 6

function ArmoryGlyphFrameGlyph_OnLoad(self)
    local name = self:GetName();
    self.glyph = getglobal(name .. "Glyph");
    self.setting = getglobal(name .. "Setting");
    self.highlight = getglobal(name .. "Highlight");
    self.background = getglobal(name .. "Background");
    self.ring = getglobal(name .. "Ring");
    self.shine = getglobal(name .. "Shine");
    self.glyphType = nil;
end

function ArmoryGlyphFrameGlyph_UpdateSlot(self)
    local id = self:GetID();

    local enabled, glyphType, glyphSpell, iconFilename = Armory:GetGlyphSocketInfo(id);

    local isMinor = glyphType == 2;
    if ( isMinor ) then
        ArmoryGlyphFrameGlyph_SetGlyphType(self, ARMORY_GLYPHTYPE_MINOR);
    else
        ArmoryGlyphFrameGlyph_SetGlyphType(self, ARMORY_GLYPHTYPE_MAJOR);
    end

    if ( not enabled ) then
        self.shine:Hide();
        self.background:Hide();
        self.glyph:Hide();
        self.ring:Hide();
        self.setting:SetTexture("Interface\\Spellbook\\UI-GlyphFrame-Locked");
        self.setting:SetTexCoord(.1, .9, .1, .9);
    elseif ( not glyphSpell ) then
        self.spell = nil;
        self.shine:Show();
        self.background:Show();
        self.background:SetTexCoord(ARMORY_GLYPH_SLOTS[0].left, ARMORY_GLYPH_SLOTS[0].right, ARMORY_GLYPH_SLOTS[0].top, ARMORY_GLYPH_SLOTS[0].bottom);
        if ( not GlyphMatchesSocket(id) ) then
            self.background:SetAlpha(1);
        end
        self.glyph:Hide();
        self.ring:Show();
    else
        self.spell = glyphSpell;
        self.shine:Show();
        self.background:Show();
        self.background:SetAlpha(1);
        self.background:SetTexCoord(ARMORY_GLYPH_SLOTS[id].left, ARMORY_GLYPH_SLOTS[id].right, ARMORY_GLYPH_SLOTS[id].top, ARMORY_GLYPH_SLOTS[id].bottom);
        self.glyph:Show();
        if ( iconFilename ) then
            self.glyph:SetTexture(iconFilename);
        else
            self.glyph:SetTexture("Interface\\Spellbook\\UI-Glyph-Rune1");
        end
        self.ring:Show();
    end
end

function ArmoryGlyphFrameGlyph_SetGlyphType(glyph, glyphType)
	glyph.glyphType = glyphType;
	
	glyph.setting:SetTexture("Interface\\Spellbook\\UI-GlyphFrame");
	if ( glyphType == ARMORY_GLYPHTYPE_MAJOR ) then
		glyph.glyph:SetVertexColor(ARMORY_GLYPH_MAJOR.r, ARMORY_GLYPH_MAJOR.g, ARMORY_GLYPH_MAJOR.b);
		glyph.setting:SetWidth(108);
		glyph.setting:SetHeight(108);
		glyph.setting:SetTexCoord(0.740234375, 0.953125, 0.484375, 0.697265625);
		glyph.highlight:SetWidth(108);
		glyph.highlight:SetHeight(108);
		glyph.highlight:SetTexCoord(0.740234375, 0.953125, 0.484375, 0.697265625);
		glyph.ring:SetWidth(82);
		glyph.ring:SetHeight(82);
		glyph.ring:SetPoint("CENTER", glyph, "CENTER", 0, -1);
		glyph.ring:SetTexCoord(0.767578125, 0.92578125, 0.32421875, 0.482421875);
		glyph.shine:SetTexCoord(0.9609375, 1, 0.9609375, 1);
		glyph.background:SetWidth(70);
		glyph.background:SetHeight(70);
	else
		glyph.glyph:SetVertexColor(ARMORY_GLYPH_MINOR.r, ARMORY_GLYPH_MINOR.g, ARMORY_GLYPH_MINOR.b);
		glyph.setting:SetWidth(86);
		glyph.setting:SetHeight(86);
		glyph.setting:SetTexCoord(0.765625, 0.927734375, 0.15625, 0.31640625);
		glyph.highlight:SetWidth(86);
		glyph.highlight:SetHeight(86);
		glyph.highlight:SetTexCoord(0.765625, 0.927734375, 0.15625, 0.31640625);
		glyph.ring:SetWidth(62);
		glyph.ring:SetHeight(62);
		glyph.ring:SetPoint("CENTER", glyph, "CENTER", 0, 1);
		glyph.ring:SetTexCoord(0.787109375, 0.908203125, 0.033203125, 0.154296875);
		glyph.shine:SetTexCoord(0.9609375, 1, 0.921875, 0.9609375);
		glyph.background:SetWidth(64);
		glyph.background:SetHeight(64);
	end
end

function ArmoryGlyphFrameGlyph_OnClick(self, button)
    if ( IsModifiedClick("CHATLINK") and ChatFrameEditBox:IsVisible() ) then
        local link = Armory:GetGlyphLink(self:GetID());
        if ( link ) then
	        ChatEdit_InsertLink(link);
        end
    end
end

function ArmoryGlyphFrameGlyph_OnEnter(self)
    if ( self.background:IsShown() ) then
        self.highlight:Show();
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetGlyph(self:GetID());
    GameTooltip:Show();
end

function ArmoryGlyphFrameGlyph_OnLeave(self)
    self.highlight:Hide();
    GameTooltip:Hide();
end

function ArmoryGlyphFrame_OnShow(self)
    for i = 1, ARMORY_NUM_GLYPH_SLOTS do
        ArmoryGlyphFrameGlyph_UpdateSlot(getglobal("ArmoryGlyphFrameGlyph" .. i));
    end
end

function ArmoryGlyphFrame_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("GLYPH_ADDED");
    self:RegisterEvent("GLYPH_REMOVED");
    self:RegisterEvent("GLYPH_UPDATED");
    self:RegisterEvent("PLAYER_LEVEL_UP");
end

function ArmoryGlyphFrame_OnEvent(self, event, ...)
    if ( not Armory:CanHandleEvents() ) then
        return;
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
    end
    Armory:Execute(ArmoryGlyphFrame_Update);
end

function ArmoryGlyphFrame_Update()
    Armory:UpdateGlyphs();
    ArmoryGlyphFrame_OnShow(ArmoryGlyphFrame);
end