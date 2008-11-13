--this mod sets the watched faction to the faction you last gained reputation from
local options = {
    type='group',
    args = {
        toggle = {
            type = 'toggle',
            name = 'Enabled',
            desc = 'Toggles the status of the addon.',
            get = "IsEnabled",
            set = "ToggleEnabled",
        },
    },
}


DynRepBar = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceEvent-2.0", "AceDB-2.0")
DynRepBar:RegisterChatCommand({"/dynrepbar", "/drb"}, options)
DynRepBar:RegisterDB("DynRepBarDB", "DynRepBarDBPC")
DynRepBar:RegisterDefaults("char", {
    enabled = true,
    lastWatched = 1,
} )




function DynRepBar:OnInitialize()
    -- Called when the addon is loaded
end

function DynRepBar:OnEnable()
    -- Called when the addon is enabled
    if self.db.char.enabled then
       self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    end
end

function DynRepBar:OnDisable()
    -- Called when the addon is disabled
end

function DynRepBar:IsEnabled()
         return self.db.char.enabled
end

function DynRepBar:ToggleEnabled()
         if self.db.char.enabled then
            --deactivate
            SetWatchedFactionIndex(0)
            self:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
         else
            SetWatchedFactionIndex(self.db.char.lastWatched);
            self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
         end

         self.db.char.enabled = not self.db.char.enabled
end

-- Event Handler
-- receives and handles the events
function DynRepBar:CHAT_MSG_COMBAT_FACTION_CHANGE()
        local faction
        --INCREASD
	faction,_ = DynRepBarGlobalParser_ParseMessage(arg1, FACTION_STANDING_INCREASED)
	if faction then
		DynRepBar:changeBar(faction);
		return;
	end

        --LOST
	faction,_ = DynRepBarGlobalParser_ParseMessage(arg1, FACTION_STANDING_DECREASED)
	if faction then
		DynRepBar:changeBar(faction);
		return;
	end

        --Changed
	faction,_ = DynRepBarGlobalParser_ParseMessage(arg1, FACTION_STANDING_CHANGED)
	if faction then
	   DynRepBar:changeBar(faction);
	   return;
	end
	DynRepBar:msg_to_chat("Nothing matched 8[");

end

--Displays a message to chat
function DynRepBar:msg_to_chat(msg)
         self:Print(msg);
end

--change the watched faction
function DynRepBar:changeBar(faction)
         local oldName,_,_,_,_ = GetWatchedFactionInfo();
         --DynRepBar_msg_to_chat("Trying to set Faction "..faction.." from "..oldName);
         for i=1, GetNumFactions() do
          local name,_,_,_,_,_,_,_,_,_ = GetFactionInfo(i);
            --DynRepBar_msg_to_chat("found "..name.." "..i);
           if ((name==faction) and not IsFactionInactive(i)) then
             if not(name==oldName)then
             --DynRepBar_msg_to_chat("set");
             SetWatchedFactionIndex(i);
             --remember
             self.db.char.lastWatched  = i;
             else  --DynRepBar_msg_to_chat("Already set to this");
             end
           else
               --DynRepBar_msg_to_chat("Not the right match")
           end
        end
end
