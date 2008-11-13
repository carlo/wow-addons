--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: ListTemplate.lua 1354 2007-01-17 05:27:36Z dinesh $

	List Frame Template

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
]]
Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/UserInterface/ListTemplate.lua $", "$Rev: 1354 $")

local MAX_COLUMNS = 6;

-------------------------------------------------------------------------------
-- Compare two rows
-------------------------------------------------------------------------------
local CurrentListFrame = nil;
function ListTemplate_CompareRows(row1, row2)
	frame = CurrentListFrame;
	for index, value in ipairs(frame.sortOrder) do
		local column = value;
		local physicalColumn = frame.physicalColumns[column.columnIndex];
		local logicalColumn = physicalColumn.logicalColumn;
		if (logicalColumn.compareAscendingFunc and logicalColumn.compareDescendingFunc) then
			local ascending = logicalColumn.compareAscendingFunc(row1, row2);
			local descending = logicalColumn.compareDescendingFunc(row1, row2);
			if (ascending or descending) then
				if (column.sortAscending) then
					return ascending;
				else
					return descending;
				end
			end
		end
	end
	return false;
end

-------------------------------------------------------------------------------
-- Initialize the list with the column information
-------------------------------------------------------------------------------
function ListTemplate_Initialize(frame, physicalColumns, logicalColumns)
	frame.lines = 19;
	frame.lineHeight = 16;
	frame.content = {};
	frame.physicalColumns = physicalColumns;
	frame.logicalColumns = logicalColumns;

	frame.sortOrder = {};
	for physicalColumnIndex = 1, MAX_COLUMNS do
		local button = getglobal(frame:GetName().."Column"..physicalColumnIndex.."Sort");
		local dropdown = getglobal(frame:GetName().."Column"..physicalColumnIndex.."DropDown");
		if (physicalColumnIndex <= #physicalColumns) then
			local physicalColumn = physicalColumns[physicalColumnIndex];
			local logicalColumn = physicalColumn.logicalColumn
			local column = {};
			column.columnIndex = physicalColumnIndex;
			column.sortAscending = true;
			table.insert(frame.sortOrder, column);
			getglobal(button:GetName().."Arrow"):Hide();
			button:SetText(logicalColumn.title);
			button:Show();
			if (#physicalColumn.logicalColumns > 1) then
				dropdown:Show();
			else
				dropdown:Hide();
			end
			ListTemplate_SetColumnWidth(frame, physicalColumnIndex, physicalColumn.width);
		else
			button:Hide();
			dropdown:Hide();
		end
	end
	getglobal(frame:GetName().."Column1SortArrow"):Show();
	getglobal(frame:GetName().."Column1SortArrow"):SetTexCoord(0, 0.5625, 0, 1.0);

	-- we have to inform FauxScrollFrame of the initial setup, so it can disable the scrollframe, if needed
	FauxScrollFrame_Update(getglobal(frame:GetName().."ScrollFrame"), #physicalColumns, frame.lines, frame.lineHeight)
end

-------------------------------------------------------------------------------
-- Initialize the list with the column information
-------------------------------------------------------------------------------
function ListTemplate_SetColumnWidth(frame, column, width)
	-- Resize the header
	frame.physicalColumns[column].width = width;
	local button = getglobal(frame:GetName().."Column"..column.."Sort");
	button:SetWidth(width + 2);
	local dropdown = getglobal(frame:GetName().."Column"..column.."DropDown");
	UIDropDownMenu_SetWidth(width - 18, dropdown);

	-- Resize each cell in the columns
	for line = 1, frame.lines do
		local textControl = getglobal(frame:GetName().."Item"..line.."Column"..column);
		if (textControl) then
			textControl:SetWidth(width - 20);
		end
	end
end

-------------------------------------------------------------------------------
-- Set the item to display.
-------------------------------------------------------------------------------
function ListTemplate_SetContent(frame, content)
	frame.content = content;

	-- Perform the sort.
	CurrentListFrame = frame;
	table.sort(frame.content, ListTemplate_CompareRows);
	CurrentListFrame = nil;

	-- Update the scroll pane.
	ListTemplateScrollFrame_Update(getglobal(frame:GetName().."ScrollFrame"));
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ListTemplate_SelectRow(frame, row)
	if (frame.selectedRow ~= row) then
		local scrollFrame = getglobal(frame:GetName().."ScrollFrame");
		local firstVisibleRow = FauxScrollFrame_GetOffset(scrollFrame) + 1;
		local lastVisibleRow = firstVisibleRow + frame.lines - 1;

		-- Deselect the previous row
		if (frame.selectedRow and firstVisibleRow <= frame.selectedRow and frame.selectedRow <= lastVisibleRow) then
			local line = frame.selectedRow - firstVisibleRow + 1;
			local item = getglobal(frame:GetName().."Item"..line);
			item:UnlockHighlight();
		end

		-- Update the selected item
		frame.selectedRow = row;

		-- Select the new row
		if (frame.selectedRow and firstVisibleRow <= frame.selectedRow and frame.selectedRow <= lastVisibleRow) then
			local line = frame.selectedRow - firstVisibleRow + 1;
			local item = getglobal(frame:GetName().."Item"..line);
			item:LockHighlight();
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ListTemplate_Sort(frame, columnIndex)
	-- Update the SortColumn order
	if (frame.sortOrder[1].columnIndex == columnIndex) then
		frame.sortOrder[1].sortAscending = not frame.sortOrder[1].sortAscending;
	else
		getglobal(frame:GetName().."Column"..frame.sortOrder[1].columnIndex.."SortArrow"):Hide();
		for index, value in ipairs(frame.sortOrder) do
			if (value.columnIndex == columnIndex) then
				local temp = value;
				table.remove(frame.sortOrder, index);
				table.insert(frame.sortOrder, 1, temp);
				break;
			end
		end
		frame.sortOrder[1].sortAscending = true;
		getglobal(frame:GetName().."Column"..frame.sortOrder[1].columnIndex.."SortArrow"):Show();
	end

	-- Perform the sort.
	CurrentListFrame = frame;
	table.sort(frame.content, ListTemplate_CompareRows);
	CurrentListFrame = nil;

	-- Update the sort arrow.
	if (frame.sortOrder[1].sortAscending) then
		getglobal(frame:GetName().."Column"..frame.sortOrder[1].columnIndex.."SortArrow"):SetTexCoord(0, 0.5625, 0, 1.0);
	else
		getglobal(frame:GetName().."Column"..frame.sortOrder[1].columnIndex.."SortArrow"):SetTexCoord(0, 0.5625, 1.0, 0);
	end
	
	-- Kill the highlight on AuctionFrameSearch
	-- This is ugly at the moment, because ListTemplate is shared by AuctionFramePost and AuctionFrameTransaction, which don't have any highlighting or the SelectResultByIndex function
	if (frame:GetParent():GetName() == "AuctionFrameSearch") then getglobal(frame:GetParent():GetName()):SelectResultByIndex(nil); end

	-- Update the scroll pane.
	ListTemplateScrollFrame_Update(getglobal(frame:GetName().."ScrollFrame"));
end

-------------------------------------------------------------------------------
-- called whenever scrolling the list
-- parameters:
--   frame = the frame to work with or
--           nil, if working with the current frame (default used by
--                UIPanelTemplates.lua:FauxScrollFrame_OnVerticalScroll)
-------------------------------------------------------------------------------
function ListTemplateScrollFrame_Update(frame)
	frame = frame or this;
	local parent = frame:GetParent();
	local content = parent.content;
	FauxScrollFrame_Update(frame, #content, parent.lines, parent.lineHeight);
	for line = 1, parent.lines do
		local item = getglobal(parent:GetName().."Item"..line);
		local contentIndex = line + FauxScrollFrame_GetOffset(frame);
		if contentIndex <= #content then
			for columnIndex = 1, MAX_COLUMNS do
				-- Get the text control (if any)
				local text = getglobal(parent:GetName().."Item"..line.."Column"..columnIndex);
				if (text) then
					text:Hide();
				end

				-- Get the money frame (if any)
				local moneyFrame = getglobal(parent:GetName().."Item"..line.."Column"..columnIndex.."MoneyFrame");
				if (moneyFrame) then
					moneyFrame:Hide();
				end

				-- If the column exists, update it
				if (columnIndex <= #parent.physicalColumns) then
					local physicalColumn = parent.physicalColumns[columnIndex];
					local logicalColumn = physicalColumn.logicalColumn;
					local value = logicalColumn.valueFunc(content[contentIndex]);

					-- Setup the control based on the datatype
					if (value) then
						if (text and (logicalColumn.dataType == "Date" or logicalColumn.dataType == "Number" or logicalColumn.dataType == "String")) then
							text:SetText(value);
							if (logicalColumn.colorFunc) then
								local color = logicalColumn.colorFunc(content[contentIndex]);
								text:SetTextColor(color.r, color.g, color.b);
							else
								text:SetTextColor(255, 255, 255);
							end
							if (logicalColumn.alphaFunc) then
								text:SetAlpha(logicalColumn.alphaFunc(content[contentIndex]));
							else
								text:SetAlpha(1.0);
							end
							if (logicalColumn.dataType == "Number") then
								text:SetJustifyH("RIGHT");
							else
								text:SetJustifyH("LEFT");
							end
							text:Show();
						elseif (moneyFrame and logicalColumn.dataType == "Money") then
							if (value >= 0) then
								MoneyFrame_Update(moneyFrame:GetName(), value);
								SetMoneyFrameColor(moneyFrame:GetName(), 255, 255, 255);
							else
								MoneyFrame_Update(moneyFrame:GetName(), -value);
								SetMoneyFrameColor(moneyFrame:GetName(), 255, 0, 0);
							end
							if (logicalColumn.alphaFunc) then
								moneyFrame:SetAlpha(logicalColumn.alphaFunc(content[contentIndex]));
							else
								moneyFrame:SetAlpha(1.0);
							end
							moneyFrame:Show();
						end
					end
				end
			end

			-- Update the row highlight
			if (parent.selectedRow and parent.selectedRow == contentIndex) then
				item:LockHighlight();
			else
				item:UnlockHighlight();
			end
			item:Show();
		else
			item:Hide();
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ListTemplate_DropDown_OnLoad(self)
	getglobal(self:GetName().."Text"):Hide();
	self.initialize = ListTemplate_DropDown_Initialize;
	UIDropDownMenu_SetSelectedID(self, 1);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ListTemplate_DropDown_Initialize()
	local dropdown = this:GetParent();
	local frame = dropdown:GetParent();
	if (frame.physicalColumns) then
		local physicalColumnIndex = dropdown:GetID();
		local physicalColumn = frame.physicalColumns[physicalColumnIndex];
		for index, value in pairs(physicalColumn.logicalColumns) do
			local logicalColumn = value;
			local info = {};
			info.text = logicalColumn.title;
			info.func = ListTemplate_DropDownItem_OnClick;
			info.owner = dropdown;
			UIDropDownMenu_AddButton(info);
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function  ListTemplate_DropDownItem_OnClick()
	local logicalColumnIndex = this:GetID();
	local physicalColumnIndex = this.owner:GetID();
	local dropdown = this.owner;
	local frame = dropdown:GetParent();
	if (frame.physicalColumns[physicalColumnIndex].logicalColumn ~= frame.physicalColumns[physicalColumnIndex].logicalColumns[logicalColumnIndex]) then
		-- Change the physical column's logical column
		frame.physicalColumns[physicalColumnIndex].logicalColumn = frame.physicalColumns[physicalColumnIndex].logicalColumns[logicalColumnIndex];
		getglobal(frame:GetName().."Column"..physicalColumnIndex.."SortText"):SetText(frame.physicalColumns[physicalColumnIndex].logicalColumn.title);

		-- Sort the content based on the new logical column
		CurrentListFrame = frame;
		table.sort(frame.content, ListTemplate_CompareRows);
		CurrentListFrame = nil;

		-- Update the combo and scroll pane.
		UIDropDownMenu_SetSelectedID(dropdown, logicalColumnIndex);
		ListTemplateScrollFrame_Update(getglobal(frame:GetName().."ScrollFrame"));
	end
end
