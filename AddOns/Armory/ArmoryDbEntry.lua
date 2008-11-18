--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryDbEntry.lua,v 1.9, 2008-11-18 18:15:39Z, Maxim Baars$
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

ArmoryDbEntry = {};
ArmoryDbEntry.__index = ArmoryDbEntry;

----------------------------------------------------------
-- Constructor
----------------------------------------------------------

function ArmoryDbEntry:new(db)
    local self = {};
    setmetatable(self, ArmoryDbEntry);
    if ( db.db and db.orig ) then
        self.db = db.db;
        self.orig = db.orig;
    else
        self.db = db;
        self.orig = db;
    end
    return self;
end

----------------------------------------------------------
-- Methods
----------------------------------------------------------

function ArmoryDbEntry:Contains(...)
    local db = self.db;
    local key;

    for i = 1, select("#", ...) do
        key = select(i, ...);
        if ( key == nil or db[key] == nil ) then
            return false;
        end
        db = db[key];
    end

    return true;
end

----------------------------------------------------------

function ArmoryDbEntry:Clear(key)
    local db = self.db;
    
    if ( key ~= nil ) then
        if ( type(db[key]) == "table" ) then
            db = db[key];
        else
            db[key] = nil;
            return;
        end
    end
    
    table.wipe(db);
end

----------------------------------------------------------

function ArmoryDbEntry:SetPosition(...)
    local oldPosition = self.db;
    local newEntry = false;
    local key;

    for i = 1, select("#", ...) do
        key = select(i, ...);
        if ( self.db[key] == nil ) then
            self.db[key] = {};
            newEntry = true;
        end
        self.db = self.db[key];
    end

    return newEntry, oldPosition;
end

function ArmoryDbEntry:ResetPosition(position)
    if ( not position ) then
        self.db = self.orig;
    else
        self.db = position;
    end
end

----------------------------------------------------------

function ArmoryDbEntry:SetValue(key, ...)
    if ( select("#", ...) > 1 ) then
        self.db[key] = self.Save(...);
    else
        self.db[key] = ...;
    end
end

function ArmoryDbEntry:GetValue(key, index)
    if ( self.IsNativeTable(self.db[key]) ) then
        if ( index == nil ) then
            return self.Load(self.db[key]);
        else
            return self.Load(self.db[key][tostring(index)]);
        end
    elseif ( self.db[key] ~= nil ) then
        if ( index == nil ) then
            return self.db[key];
        elseif ( self.IsNativeTable(self.db[key][index]) ) then
            return self.Load(self.db[key][index]);
        else
            return self.db[key][index];
        end
    end
end

function ArmoryDbEntry:GetNumValues(key, index)
    if ( index == nil ) then
        return self.NumValues(self.db[key]);
    elseif ( self.db[key] ~= nil ) then
        return self.NumValues(self.db[key][index]);
    else
        return 0;
    end
end

function ArmoryDbEntry:GetRawValue(key, index)
    if ( index == nil ) then
        return self.db[key];
    elseif ( self.db[key] ~= nil ) then
        return self.db[key][index];
    end
end

function ArmoryDbEntry:SetSubValue(key, subkey, ...)
    if ( self.db[key] == nil ) then
        self.db[key] = {};
    end
    if ( select("#", ...) > 1 ) then
        self.db[key][subkey] = self.Save(...);
    else
        self.db[key][subkey] = ...;
    end
end

function ArmoryDbEntry:GetSubValue(key, subkey, index)
    if ( self.db[key] ~= nil ) then
        if ( self.IsNativeTable(self.db[key][subkey]) ) then
            if ( index == nil ) then
                return self.Load(self.db[key][subkey]);
            else
                return self.Load(self.db[key][subkey][tostring(index)]);
            end
        elseif ( self.db[key][subkey] ~= nil ) then
            if ( index == nil ) then
                return self.db[key][subkey];
            elseif ( self.IsNativeTable(self.db[key][subkey][index]) ) then
                return self.Load(self.db[key][subkey][index]);
            else
                return self.db[key][subkey][index];
            end
        end
    end    
end

function ArmoryDbEntry:GetRawSubValue(key, subkey, index)
    if ( self.db[key] ) then
        if ( index == nil ) then
            return self.db[key][subkey];
        elseif ( self.db[key][subkey] ~= nil ) then
            return self.db[key][subkey][index];
        end
    end
end

function ArmoryDbEntry:GetNumSubValues(key, subkey, index)
    if ( self.db[key] ) then
        if ( index == nil ) then
            return self.NumValues(self.db[key][subkey]);
        elseif ( self.db[key][subkey] ~= nil ) then
            return self.NumValues(self.db[key][subkey][index]);
        end
    end
    return 0;
end

----------------------------------------------------------

function ArmoryDbEntry:SetExpandableListValues(key, funcNumLines, funcGetLineState, funcGetLineInfo, funcExpand, funcCollapse, funcAdditionalInfo, funcSelect)
    local collapsedHeaders;
    
    if ( funcExpand and funcCollapse ) then
        collapsedHeaders = {};
        for i = funcNumLines(), 1, -1 do
            local isHeader, isExpanded = funcGetLineState(i);
            if ( isHeader and not isExpanded ) then
                table.insert(collapsedHeaders, i);
                funcExpand(i);
            end
        end
    end
    
    self.db[key] = {};
    for i = 1, funcNumLines() do
        self.db[key][i] = self.Save(funcGetLineInfo(i));
        if ( funcAdditionalInfo and not funcGetLineState(i) ) then
            if ( funcSelect ) then
                funcSelect(i);
            end
            for subkey, func in pairs(funcAdditionalInfo()) do
                if ( subkey and func ) then 
                    self.db[key][i][subkey] = self.Save(func(i));
                end
            end
        end
    end

    if ( collapsedHeaders and #collapsedHeaders > 0 ) then
        table.sort(collapsedHeaders);
        for _, i in pairs(collapsedHeaders) do
            funcCollapse(i);
        end
    end
end

----------------------------------------------------------
-- Static methods
----------------------------------------------------------

-- Implement our own variable storage system
-- (sometimes "var = {...}; unpack(var);" doesn't work for some reason)
function ArmoryDbEntry.Save(...)
    local t = {};
    local n = select("#", ...);
    if ( n == 1 ) then
        return ...;
    elseif ( n > 1 ) then
        t.count = n;
        for i = 1, n do
            t[tostring(i)] = select(i, ...);
        end
        return t;
    end
end

function ArmoryDbEntry.Load(t, i)
    if ( type(t) == "table" and t.count ~= nil ) then
        i = i or 1;
        if ( i <= t.count ) then
            return t[tostring(i)], ArmoryDbEntry.Load(t, i + 1);
        end
    else
        return t;
    end
end

function ArmoryDbEntry.NumValues(t)
    if ( type(t) == "table" ) then
        if ( t.count == nil ) then
            return #t;
        else
            return t.count;
        end
    elseif ( t ) then
        return 1;
    else
        return 0;
    end
end

function ArmoryDbEntry.IsNativeTable(t)
    return ( type(t) == "table" and t.count ~= nil );
end
