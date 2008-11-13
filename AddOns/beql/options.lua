local beql = beql
local L = AceLibrary("AceLocale-2.2"):new("beql")

function beql:CreateOptions()

beql.options = { 
    type='group',
    args = {
		Spacing1 = {
			name = " ",
			type = "header",
			order = 19,
		},    
		qlogoption = {
			type = 'group',
			name = L["Quest Log Options"],
			desc = L["Options related to the Quest Log"],
			order = 20,
			args = {			
				Locked = {
					type = 'toggle',
					name = L["Lock Quest Log"],
					desc = L["Makes the quest log unmovable"],
					get  = function() return beql.db.profile.locked end,
					set = 'setmovable',
					order = 1
				},
				Spacing1 = {
					name = " ",
					type = "header",
					order = 2,
				},
				AlwaysMinimize = {
					type = 'toggle',
					name = L["Always Open Minimized"],
					desc = L["Force the quest log to open minimized"],
					get = function() return beql.db.profile.alwaysminimize end,
					set = function(newval) beql.db.profile.alwaysminimize = newval end,
					disabled = function() return beql.db.profile.alwaysmaximize end,
					order = 3,
				},
				AlwaysMaximize = {
					type = 'toggle',
					name = L["Always Open Maximized"],
					desc = L["Force the quest log to open maximized"],
					get = function() return beql.db.profile.alwaysmaximize end,
					set = function(newval) beql.db.profile.alwaysmaximize = newval end,
					disabled = function() return beql.db.profile.alwaysminimize end,
					order = 4,
				},
				ShowLevel = {
					type = 'toggle',
					name = L["Show Quest Level"],
					desc = L["Shows the quests level"],
					get = function() return beql.db.profile.showlevel end,
					set = function(newval) beql.db.profile.showlevel = newval QuestLog_Update() beql:ManageQuests() QuestWatch_Update() end,
					disabled = function() return beql.db.profile.disabled.showlevel end,
					order = 5,
				},
				InfoOnQuestCompletion = {
					type = 'toggle',
					name = L["Info on Quest Completion"],
					desc = L["Shows a message and plays a sound when you complete a quest"],
					get = function() return beql.db.profile.InfoOnQuestCompletion end,
					set = 'setinfoonquestcomplete',
					order = 6,
				},
				QuestCompletionSound = {
					type = 'group',
					name = L["Completion Sound"],
					desc = L["Select the sound to be played when a quest is completed"],
					order = 7,
					disabled = function() return not beql.db.profile.InfoOnQuestCompletion end,
					args = {
						
					}
				},				
				AnnounceQuestStatus = {
					type = 'toggle',
					name = L["Quest Progression to Party Chat"],
					desc = L["Prints the Quest Progression Status to the Party Chat"],
					get = function() return beql.db.profile.AnnounceQuest end,
					set = function(newval) beql.db.profile.AnnounceQuest = newval end,
					order = 8,
				},
				AutoComplete = {
					type = 'toggle',
					name = L["Auto Complete Quest"],
					desc = L["Automatically Complete Quests"],
					get = function() return beql.db.profile.autocomplete end,
					set = function(newval) beql.db.profile.autocomplete = newval end,
					order = 9,
				},		
				SimpleQuestLog = {
					type = 'toggle',
					name = L["Simple Quest Log"],
					desc = L["Uses the default Blizzard Quest Log"].." - "..L["Requires Interface Reload"],
					get = function() return beql.db.profile.simplequestlog end,
					set = function(newval) beql.db.profile.simplequestlog = newval ReloadUI() end,
					disabled = function() return beql.db.profile.disabled.simplequestlog end,
					order = 10,
				},
				QuestLogAlpha = {
					type = 'range',
					name = L["Quest Log Alpha"],
					desc = L["Sets the Alpha of the Quest Log"],
					get = function()
						return beql.db.profile.QuestLogAlpha
					end,
					set = function(newval)
								beql.db.profile.QuestLogAlpha = newval
								QuestLogFrame:SetAlpha(beql.db.profile.QuestLogAlpha)
					end,
					min = 0,
					max = 1,
					step = 0.01,
					order = 11,
				},
				QuestLogFontSize = {
					type = 'range',
					name = L["Font Size"],
					desc = L["Font Size"],
					get = function() return beql.db.profile.QuestLogFontSize end,
					set = function(newval)
						beql.db.profile.QuestLogFontSize = newval
						beql:SetQuestLogFontSize(newval)
					end,
					min = 6,
					max = 20,
					step = 1,
					order = 12,
				},
				QuestLogScale = {
					type = 'range',
					name = L["Quest Log Scale"],
					desc = L["Sets the Scale of the Quest Log"],
					get = function()
							return beql.db.profile.QuestLogScale
					end,
					set = function(newval)
								beql.db.profile.QuestLogScale = newval
								QuestLogFrame:SetScale(beql.db.profile.QuestLogScale)
					end,
					min = 0.4,
					max = 1.5,
					step = 0.01,
					order = 13,
				},
			},
		},
		DisableTracker = {
			type = 'toggle',
			name = L["Disable Tracker"],
			desc = L["Disable the Tracker"].." - "..L["Requires Interface Reload"],
			get = function() return beql.db.profile.disabledtracker end,
			set = function(newval) beql.db.profile.disabledtracker = newval ReloadUI() end,
		},
		qtrackeroption = {
			type = 'group',
			name = L["Quest Tracker Options"],
			desc = L["Options related to the Quest Tracker"],
			order = 21,
			disabled = function() return beql.db.profile.disabled.tracker or beql.db.profile.disabletracker end,
			args = {
				LockedTracker = {
					type = 'toggle',
					name = L["Lock Tracker"],
					desc = L["Makes the quest tracker unmovable"],
					get = function() return beql.db.profile.lockedtracker end,
					set = 'setmovabletracker',
					disabled = function() return beql.db.profile.disabled.lockedtracker end,
					order = 1,
				},
				Spacing1 = {
					name = " ",
					type = "header",
					order = 2,
				},
				ShowTrackerHeader = {
					type = 'toggle',
					name = L["Show Tracker Header"],
					desc = L["Shows the trackers header"],
					get = function() return beql.db.profile.ShowTrackerHeader end,
					set = function(newval) beql.db.profile.ShowTrackerHeader = newval QuestWatch_Update() end,
					order = 4,
				},
				TrackerAutoResize = {
					type = 'toggle',
					name = L["Auto Resize Tracker"],
					desc = L["Automatical resizes the tracker depending on the lenght of the text in it"],
					get = function() return beql.db.profile.TrackerAutoResize end,
					set = function(newval) beql.db.profile.TrackerAutoResize = newval QuestWatch_Update() end,
					order = 5,				
				},
				TrackerFixedWidth = {
					type = 'range',
					name = L["Fixed Tracker Width"],
					desc = L["Sets the fixed width of the tracker if auto resize is disabled"],
					get = function() return beql.db.profile.TrackerFixedWidth end,
					set = function(newval) beql.db.profile.TrackerFixedWidth = newval QuestWatch_Update() end,
					min = 200,
					max = 600,
					step = 10,
					order = 6,
					disabled = function() return beql.db.profile.TrackerAutoResize end,
				},
				TrackerFontHeight = {
					type = 'range',
					name = L["Font Size"],
					desc = L["Changes the font size of the tracker"],
					get = function()
						return beql.db.profile.TrackerFontHeight
					end,
					set = function(newval)
						beql.db.profile.TrackerFontHeight = newval
						QuestWatch_Update()
					end,
					min = 8,
					max = 18,
					step = 1,
					order = 9,
				},	
				Spacing2 = {
					name = " ",
					type = "header",
					order = 11,
				}, 
				AddNew = {
					type = 'toggle',
					name = L["Add New Quests"],
					desc = L["Automatical add new Quests to tracker"],
					get = function() return beql.db.profile.AddNew end,
					set = function(newval) beql.db.profile.AddNew = newval QuestWatch_Update() end,
					order = 13,
				},
				AddUntracked = {
					type = 'toggle',
					name = L["Add Untracked"],
					desc = L["Automatical add quests with updated objectives to tracker"],
					get = function() 
						if AUTO_QUEST_WATCH == "1" then
							return true
						else
							return false
						end
					end,
					set = function(newval) 
						if newval then
							AUTO_QUEST_WATCH = "1"
						else
							AUTO_QUEST_WATCH = "0"
						end
						QuestWatch_Update() 
					end,
					order = 17,
				},		
				Spacing3 = {
					name = " ",
					type = "header",
					order = 19,
				},  						

				ShowZonesInTracker = {
					type = 'toggle',
					name = L["Show Quest Zones"],
					desc = L["Show the quests zone it belongs to above its name"],
					get = function() return beql.db.profile.ShowZonesInTracker end,
					set = function(newval) beql.db.profile.ShowZonesInTracker = newval QuestWatch_Update() end,
					order = 21,
				},			
				Spacing4 = {
					name = " ",
					type = "header",
					order = 23,
				},  					
				RemoveFinished = {
					type = 'toggle',
					name = L["Remove Completed Quests"],
					desc = L["Automatical remove completed quests from tracker"],
					get = function() return beql.db.profile.RemoveFinished end,
					set = function(newval) beql.db.profile.RemoveFinished = newval QuestWatch_Update() end,
					order = 25,
				},

				MinimizeFinished = {
					type = 'toggle',
					name = L["Hide Completed Objectives"],
					desc = L["Automatical hide completed objectives in tracker"],
					get = function() return beql.db.profile.MinimizeFinished end,
					set = function(newval) beql.db.profile.MinimizeFinished = newval QuestWatch_Update() end,
					order = 27,
				},	
				HideCompletedOnly = {
					type = 'toggle',
					name = L["Hide Objectives for Completed only"],
					desc = L["Hide objectives only for completed quests"],
					get = function() return beql.db.profile.HideCompletedOnly end,
					set = function(newval) beql.db.profile.HideCompletedOnly = newval QuestWatch_Update() end,
					disabled = function() return beql.db.profile.MinimizeFinished or beql.db.profile.RemoveFinished end,
					order = 29,
				},
				SortTrackerItems = {
					type = 'toggle',
					name = L["Sort Tracker Quests"],
					desc = L["Sort the quests in tracker"],
					get = function() return beql.db.profile.SortTrackerItems end,
					set = function(newval) beql.db.profile.SortTrackerItems = newval beql:SortWatchedQuests() QuestWatch_Update() end,
					order = 31,
				},
				MarkerOptions = {
					type = 'group',
					name = L["Markers"],
					desc = L["Customize the Objective/Quest Markers"],
					order = 33,
					args = {
						ShowObjectiveMarkers = {	
							type = 'toggle',
							name = L["Show Objective Markers"],
							desc = L["Display Markers before objectives"],
							get = function() return beql.db.profile.ShowObjectiveMarkers end,
							set = function(newval) beql.db.profile.ShowObjectiveMarkers = newval QuestWatch_Update() end,
							disabled = function() return beql.db.profile.disabled.markers end,
							order = 20,
						},					
						UseTrackerListing = {
							type = 'toggle',
							name = L["Use Listing"],
							desc = L["User Listing rather than symbols"],
							get = function() return beql.db.profile.UseTrackerListing end,
							set = function(newval) beql.db.profile.UseTrackerListing = newval QuestWatch_Update() end,
							disabled = function() return not beql.db.profile.ShowObjectiveMarkers end,
							order = 21,
						},	
						TrackerList = {
							type = 'range',
							name = L["List Type"],
							desc = L["Set the type of listing"],
							get = function()
								return beql.db.profile.TrackerList
							end,
							set = function(newval)
								beql.db.profile.TrackerList = newval
								QuestWatch_Update()
							end,
							min = 0,
							max = 3,
							step = 1,
							disabled = function() return not beql.db.profile.UseTrackerListing end,
							order = 22,
						},
						TrackerSymbol = {
							type = 'range',
							name = L["Symbol Type"],
							desc = L["Set the type of symbol"],
							get = function()
								return beql.db.profile.TrackerSymbol
							end,
							set = function(newval)
								beql.db.profile.TrackerSymbol = newval
								QuestWatch_Update()
							end,
							min = 0,
							max = 3,
							step = 1,
							disabled = function() return beql.db.profile.UseTrackerListing or not beql.db.profile.ShowObjectiveMarkers end,
							order = 23,
						},
					},
				},				
				Colors = {
					type = 'group',
					name = L["Colors"],
					desc = L["Set tracker Colors"],
					order = 35,
					args = {
						BackgroundAlpha = {
							type = 'toggle',
							name = L["Background"],
							desc = L["Use Background"],
							get = function() return beql.db.profile.BackgroundAlpha end,
							set = function(newval) beql.db.profile.BackgroundAlpha = newval QuestWatch_Update() end,
							order = 51,					
						},					
						CustomBackgroundColor = {
							type = 'toggle',
							name = L["Custom Background Color"],
							desc = L["Use custom color for background"],
							get = function() return beql.db.profile.CustomBackgroundColor end,
							set = function(newval) beql.db.profile.CustomBackgroundColor = newval QuestWatch_Update() end,
							disabled = function() return not beql.db.profile.BackgroundAlpha end,
							order = 52,
						},
						BackgroundColor = {
							type = 'color',
							name = L["Background Color"],
							desc = L["Sets the Background Color"],
							get = function() 
								return beql.db.profile.Color.BackgroundColor.r, beql.db.profile.Color.BackgroundColor.g, beql.db.profile.Color.BackgroundColor.b, beql.db.profile.Color.BackgroundColor.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.BackgroundColor.r = r
								beql.db.profile.Color.BackgroundColor.g = g
								beql.db.profile.Color.BackgroundColor.b = b
								beql.db.profile.Color.BackgroundColor.a = a
								QuestWatch_Update()
							end,					
							hasAlpha = true,
							disabled = function() return not beql.db.profile.CustomBackgroundColor end,
							order = 53,							
						},
						BackgroundCornerColor = {
							type = 'color',
							name = L["Background Corner Color"],
							desc = L["Sets the Background Corner Color"],
							get = function() 
								return beql.db.profile.Color.BackgroundCornerColor.r, beql.db.profile.Color.BackgroundCornerColor.g, beql.db.profile.Color.BackgroundCornerColor.b, beql.db.profile.Color.BackgroundCornerColor.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.BackgroundCornerColor.r = r
								beql.db.profile.Color.BackgroundCornerColor.g = g
								beql.db.profile.Color.BackgroundCornerColor.b = b
								beql.db.profile.Color.BackgroundCornerColor.a = a
								QuestWatch_Update()
							end,					
							hasAlpha = true,
							disabled = function() return not beql.db.profile.CustomBackgroundColor end,
							order = 54,
						},
						CustomZoneColor = {
							type = 'toggle',
							name = L["Custom Zone Color"],
							desc = L["Use custom color for Zone names"],
							get = function() return beql.db.profile.CustomZoneColor end,
							set = function(newval) beql.db.profile.CustomZoneColor = newval QuestWatch_Update() end,
							order = 55,
						},					
						ColorZone = {
							type = 'color',
							name = L["Zone Color"],
							desc = L["Sets the zone color"],
							get = function() 
								return beql.db.profile.Color.Zone.r, beql.db.profile.Color.Zone.g, beql.db.profile.Color.Zone.b, beql.db.profile.Color.Zone.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.Zone.r = r
								beql.db.profile.Color.Zone.g = g
								beql.db.profile.Color.Zone.b = b
								beql.db.profile.Color.Zone.a = a
								QuestWatch_Update()
							end,					
							hasAlpha = false,
							disabled = function() return not beql.db.profile.CustomZoneColor end,
							order = 56,
						},
						FadeColor = {
							type = 'toggle',
							name = L["Fade Colors"],
							desc = L["Fade the objective colors"],
							get = function() return beql.db.profile.FadeColor end,
							set = function(newval) beql.db.profile.FadeColor = newval QuestWatch_Update() end,
							order = 57,
						},
						CustomObjetiveColor = {
							type = 'toggle',
							name = L["Custom Objective Color"],
							desc = L["Use custom color for objective text"],
							get = function() return beql.db.profile.CustomObjetiveColor end,
							set = function(newval) beql.db.profile.CustomObjetiveColor = newval QuestWatch_Update() end,
							order = 58,
						},							
						ColorObjectiveEmpty = {
							type = 'color',
							name = L["Objective Color"],
							desc = L["Sets the color for objectives"],
							get = function() 
								return beql.db.profile.Color.ObjectiveEmpty.r, beql.db.profile.Color.ObjectiveEmpty.g, beql.db.profile.Color.ObjectiveEmpty.b, beql.db.profile.Color.ObjectiveEmpty.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.ObjectiveEmpty.r = r
								beql.db.profile.Color.ObjectiveEmpty.g = g
								beql.db.profile.Color.ObjectiveEmpty.b = b
								beql.db.profile.Color.ObjectiveEmpty.a = a
								QuestWatch_Update()
							end,					
							hasAlpha = false,
							disabled = function() return not beql.db.profile.CustomObjetiveColor end,
							order = 59,
						},
						ColorObjectiveComplete = {
							type = 'color',
							name = L["Completed Objective Color"],
							desc = L["Sets the color for completed objectives"],
							get = function() 
								return beql.db.profile.Color.ObjectiveComplete.r, beql.db.profile.Color.ObjectiveComplete.g, beql.db.profile.Color.ObjectiveComplete.b, beql.db.profile.Color.ObjectiveComplete.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.ObjectiveComplete.r = r
								beql.db.profile.Color.ObjectiveComplete.g = g
								beql.db.profile.Color.ObjectiveComplete.b = b
								beql.db.profile.Color.ObjectiveComplete.a = a
								QuestWatch_Update()
							end,					
							hasAlpha = false,
							disabled = function() return not beql.db.profile.CustomObjetiveColor end,	
							order = 60,						
						},
						

						CustomHeaderColor = {
							type = 'toggle',
							name = L["Custom Header Color"],
							desc = L["Use custom color for headers"],
							get = function() return beql.db.profile.CustomHeaderColor end,
							set = function(newval) beql.db.profile.CustomHeaderColor = newval QuestWatch_Update() end,
							order = 61,
						},
						HeaderQuestLevelColor = {
							type = 'toggle',
							name = L["Use Quest Level Colors"],
							desc = L["Use the colors to indicate quest difficulty"],
							get = function() return beql.db.profile.HeaderQuestLevelColor end,
							set = function(newval) beql.db.profile.HeaderQuestLevelColor = newval QuestWatch_Update() end,
							disabled = function() return not beql.db.profile.CustomHeaderColor end,
							order = 62,
						},				
						ColorHeaderEmpty = {
							type = 'color',
							name = L["Header Color"],
							desc = L["Sets the color for headers"],
							get = function() 
								return beql.db.profile.Color.HeaderEmpty.r, beql.db.profile.Color.HeaderEmpty.g, beql.db.profile.Color.HeaderEmpty.b, beql.db.profile.Color.HeaderEmpty.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.HeaderEmpty.r = r
								beql.db.profile.Color.HeaderEmpty.g = g
								beql.db.profile.Color.HeaderEmpty.b = b
								beql.db.profile.Color.HeaderEmpty.a = a
								QuestWatch_Update()
							end,					
							hasAlpha = false,
							disabled = function() return not beql.db.profile.CustomHeaderColor or beql.db.profile.HeaderQuestLevelColor end,	
							order = 63,
						},								
						ColorHeaderComplete = {
							type = 'color',
							name = L["Completed Header Color"],
							desc = L["Sets the color for completed headers"],
							get = function() 
								return beql.db.profile.Color.HeaderComplete.r, beql.db.profile.Color.HeaderComplete.g, beql.db.profile.Color.HeaderComplete.b, beql.db.profile.Color.HeaderComplete.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.HeaderComplete.r = r
								beql.db.profile.Color.HeaderComplete.g = g
								beql.db.profile.Color.HeaderComplete.b = b
								beql.db.profile.Color.HeaderComplete.a = a
								QuestWatch_Update()
							end,					
							hasAlpha = false,
							disabled = function() return not beql.db.profile.CustomHeaderColor end,	
							order = 64,
						},	
						ColorHeaderFailed = {
							type = 'color',
							name = L["Failed Header Color"],
							desc = L["Sets the color for failed quests"],
							get = function() 
								return beql.db.profile.Color.HeaderFailed.r, beql.db.profile.Color.HeaderFailed.g, beql.db.profile.Color.HeaderFailed.b, beql.db.profile.Color.HeaderFailed.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.HeaderFailed.r = r
								beql.db.profile.Color.HeaderFailed.g = g
								beql.db.profile.Color.HeaderFailed.b = b
								beql.db.profile.Color.HeaderFailed.a = a
								QuestWatch_Update()
							end,					
							hasAlpha = false,
							disabled = function() return not beql.db.profile.CustomHeaderColor end,	
							order = 65,						
						}					
					},
				},
				QuestTrackerAlpha = {
					type = 'range',
					name = L["Quest Tracker Alpha"],
					desc = L["Sets the Alpha of the Quest Tracker"],
					get = function()
						return beql.db.profile.QuestTrackerAlpha
					end,
					set = function(newval)
								beql.db.profile.QuestTrackerAlpha = newval
								QuestWatchFrame:SetAlpha(beql.db.profile.QuestTrackerAlpha)
					end,
					min = 0,
					max = 1,
					step = 0.01,
					order = 37,
				},				
				ResetTracker = {
					type = 'execute',
					name = L["Reset tracker position"],
					desc = L["Reset tracker position"],
					func = function()
								QuestWatchFrame:ClearAllPoints()
								QuestWatchFrame:SetPoint("TOPLEFT","UIParent","Center",0,0)
								beql:SavePositionTracker()
					end
				},
			},
		},
		qtooltip = {
			type = 'group',
			name = L["Tooltip"],
			desc = L["Tooltip Options"],
			order = 21,
			args = {
				TooltipMob = {
					type = 'toggle',
					name = L["Mob Tooltip Quest Info"],
					desc = L["Show quest info in mob tooltips"],
					get = function() return beql.db.profile.tooltipmob end,
					set = function(newval) beql.db.profile.tooltipmob = newval end,
					order = 1,
				},
				TooltipItem = {
					type = 'toggle',
					name = L["Item Tooltip Quest Info"],
					desc = L["Show quest info in item tooltips"],
					get = function() return beql.db.profile.tooltipitem end,
					set = function(newval) beql.db.profile.tooltipitem = newval end,
					order = 5,				
				},	
				ActiveTracker = {
					type = 'toggle',
					name = L["Tracker Tooltip"],
					desc = L["Showing mouseover tooltips in tracker"],
					get = function() return beql.db.profile.activetracker end,
					set = function(newval) beql.db.profile.activetracker = newval beql:CheckMouseEvents() end,
					order = 9,
				},	
				TrackerTooltipDesc = {
					type = 'toggle',
					name = L["Quest Description in Tracker Tooltip"],
					desc = L["Displays the actual quest's description in the tracker tooltip"],
					get = function() return beql.db.profile.activetrackerdesc end,
					set = function(newval) beql.db.profile.activetrackerdesc = newval end,
					disabled = function() return not beql.db.profile.activetracker end,
					order = 15,
				},
				TrackerTooltipParty = {
					type = 'toggle',
					name = L["Party Quest Progression info"],
					desc = L["Displays Party members quest status in the tooltip - Quixote must be installed on the partymembers client"],
					get = function() return beql.db.profile.activetrackerparty end,
					set = function(newval) beql.db.profile.activetrackerparty = newval end,
					disabled = function() return not beql.db.profile.activetracker end,
					order = 17,
				},				
				TrackerMouseLeft = {
					type = 'toggle',
					name = L["Enable Left Click"],
					desc = L["Left clicking a quest in the tracker opens the Quest Log"],
					get = function() return beql.db.profile.activetrackerleft end,
					set = function(newval) beql.db.profile.activetrackerleft = newval beql:CheckMouseEvents() end,
					order = 19,					
				},
				TrackerMouseRight = {
					type = 'toggle',
					name = L["Enable Right Click"],
					desc = L["Right clicking a quest in the tracker removes it from the tracker"],
					get = function() return beql.db.profile.activetrackerright end,
					set = function(newval) beql.db.profile.activetrackerright = newval beql:CheckMouseEvents() end,
					order = 21,					
				},
				Colors = {
					type = 'group',
					name = L["Colors"],
					desc = L["Colors"],
					args = {
						ColorTitleDiff = {
							type = 'toggle',
							name = L["Use Quest Level Colors"],
							desc = L["Use Quest Level Colors"],
							get = function() return beql.db.profile.TooltipTitleDiff end,
							set = function(newval) beql.db.profile.TooltipTitleDiff = newval end,
							order = 3,
						},
						ColorTitle = {
							type = 'color',
							name = L["Header Color"],
							desc = L["Sets the color for headers"],
							get = function() 
								return beql.db.profile.Color.TooltipQuestTitle.r, 
										beql.db.profile.Color.TooltipQuestTitle.g, 
										beql.db.profile.Color.TooltipQuestTitle.b, 
										beql.db.profile.Color.TooltipQuestTitle.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.TooltipQuestTitle.r = r
								beql.db.profile.Color.TooltipQuestTitle.g = g
								beql.db.profile.Color.TooltipQuestTitle.b = b
								beql.db.profile.Color.TooltipQuestTitle.a = a
							end,					
							hasAlpha = false,
							disabled = function() return beql.db.profile.TooltipTitleDiff end,
							order = 1,
						},
						ColorDesc = {
							type = 'color',
							name = L["Quest Description Color"],
							desc = L["Sets the color for the Quest description"],
							get = function() 
								return beql.db.profile.Color.TooltipDesc.r, 
										beql.db.profile.Color.TooltipDesc.g, 
										beql.db.profile.Color.TooltipDesc.b, 
										beql.db.profile.Color.TooltipDesc.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.TooltipDesc.r = r
								beql.db.profile.Color.TooltipDesc.g = g
								beql.db.profile.Color.TooltipDesc.b = b
								beql.db.profile.Color.TooltipDesc.a = a
							end,					
							hasAlpha = false,
							order = 5,
						},		
						ColorPartyQ = {
							type = 'color',
							name = L["Party Member with Quixote Color"],
							desc = L["Sets the color for Party member"],
							get = function() 
								return beql.db.profile.Color.TooltipPartyQuixote.r, 
										beql.db.profile.Color.TooltipPartyQuixote.g, 
										beql.db.profile.Color.TooltipPartyQuixote.b, 
										beql.db.profile.Color.TooltipPartyQuixote.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.TooltipPartyQuixote.r = r
								beql.db.profile.Color.TooltipPartyQuixote.g = g
								beql.db.profile.Color.TooltipPartyQuixote.b = b
								beql.db.profile.Color.TooltipPartyQuixote.a = a
							end,					
							hasAlpha = false,
							order = 9,
						},
						ColorPartyNQ = {
							type = 'color',
							name = L["Party Member Color"],
							desc = L["Sets the color for Party member"],
							get = function() 
								return beql.db.profile.Color.TooltipPartyNonQuixote.r, 
										beql.db.profile.Color.TooltipPartyNonQuixote.g, 
										beql.db.profile.Color.TooltipPartyNonQuixote.b, 
										beql.db.profile.Color.TooltipPartyNonQuixote.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.TooltipPartyNonQuixote.r = r
								beql.db.profile.Color.TooltipPartyNonQuixote.g = g
								beql.db.profile.Color.TooltipPartyNonQuixote.b = b
								beql.db.profile.Color.TooltipPartyNonQuixote.a = a
							end,					
							hasAlpha = false,
							order = 7,							
						},
						ColorPartyObj = {
							type = 'color',
							name = L["Objective Color"],
							desc = L["Sets the color for objectives"],
							get = function() 
								return beql.db.profile.Color.TooltipPartyObj.r, 
										beql.db.profile.Color.TooltipPartyObj.g, 
										beql.db.profile.Color.TooltipPartyObj.b, 
										beql.db.profile.Color.TooltipPartyObj.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.TooltipPartyObj.r = r
								beql.db.profile.Color.TooltipPartyObj.g = g
								beql.db.profile.Color.TooltipPartyObj.b = b
								beql.db.profile.Color.TooltipPartyObj.a = a
							end,					
							hasAlpha = false,
							order = 11,							
						},
						ColorPartyObj = {
							type = 'color',
							name = L["Completed Objective Color"],
							desc = L["Sets the color for completed objectives"],
							get = function() 
								return beql.db.profile.Color.TooltipPartyObjComp.r, 
										beql.db.profile.Color.TooltipPartyObjComp.g, 
										beql.db.profile.Color.TooltipPartyObjComp.b, 
										beql.db.profile.Color.TooltipPartyObjComp.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.TooltipPartyObjComp.r = r
								beql.db.profile.Color.TooltipPartyObjComp.g = g
								beql.db.profile.Color.TooltipPartyObjComp.b = b
								beql.db.profile.Color.TooltipPartyObjComp.a = a
							end,					
							hasAlpha = false,
							order = 13,							
						},						
						ColorObjFade = {
							type = 'toggle',
							name = L["Fade Colors"],
							desc = L["Fade Colors"],
							get = function() return beql.db.profile.TooltipObjFade end,
							set = function(newval) beql.db.profile.TooltipObjFade = newval end,
							order = 15,							
						},	
						ColorMobTooltip = {
							type = 'color',
							name = L["Mob Tooltip Quest Info"],
							desc = L["Mob Tooltip Quest Info"],
							get = function() 
								return beql.db.profile.Color.ColorMobTooltip.r, 
										beql.db.profile.Color.ColorMobTooltip.g, 
										beql.db.profile.Color.ColorMobTooltip.b, 
										beql.db.profile.Color.ColorMobTooltip.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.ColorMobTooltip.r = r
								beql.db.profile.Color.ColorMobTooltip.g = g
								beql.db.profile.Color.ColorMobTooltip.b = b
								beql.db.profile.Color.ColorMobTooltip.a = a
							end,					
							hasAlpha = false,
							order = 17,		
							disabled = function() return beql.db.profile.TooltipItemFade end,
						},
						ColorItemTooltip = {
							type = 'color',
							name = L["Item Tooltip Quest Info"],
							desc = L["Item Tooltip Quest Info"],
							get = function() 
								return beql.db.profile.Color.ColorItemTooltip.r, 
										beql.db.profile.Color.ColorItemTooltip.g, 
										beql.db.profile.Color.ColorItemTooltip.b, 
										beql.db.profile.Color.ColorItemTooltip.a
							end,
							set = function(r, g, b, a)
								beql.db.profile.Color.ColorItemTooltip.r = r
								beql.db.profile.Color.ColorItemTooltip.g = g
								beql.db.profile.Color.ColorItemTooltip.b = b
								beql.db.profile.Color.ColorItemTooltip.a = a
							end,					
							hasAlpha = false,
							disabled = function() return beql.db.profile.TooltipItemFade end,
							order = 19,								
						},
						TooltipItemFade = {
							type = 'toggle',
							name = L["Use Quest Level Colors"],
							desc = L["Use Quest Level Colors"],
							get = function() return beql.db.profile.TooltipItemFade end,
							set = function(newval) beql.db.profile.TooltipItemFade = newval end,
							order = 21,								
						},
					},
				}				
			},
		},
		qlocales = {
			type = 'group',
			name = L["Pick Locale"],
			desc = L["Change Locale (needs Interface Reload)"],
			order = 22,
			args = {

			},		
		},  
    },
}

StaticPopupDialogs["CONFIRM_RELOADUI"] = {
	text = L["Reload UI ?"],
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),	
	OnAccept = function(parentframedata)
		beql:Nyelv("PREV",true)
	end,
	OnCancel = function(parentframedata,override)
		-- Do nothing
	end,
	timeout = 20,
	exclusive = 1,
	notCloseablebyLogout = 1,
}

end

function beql:setmovable(newValue)
	self.db.profile.locked = newValue
	if self.db.profile.locked then
		QuestLogFrame:RegisterForDrag(0)
	else
		QuestLogFrame:RegisterForDrag("LeftButton")
	end	
end

function beql:addlocaleoptions()
	--beql.options.args.qlocales.args
	local values = {}
    for k in L:IterateAvailableLocales() do 
		values[k] = _G[string.upper(k)] or k
		beql.options.args.qlocales.args["locale"..k] = {
			type = 'toggle',
			name = k,
			desc = " ",
			get = function() 
				if L:GetLocale() == k then
					return true
				else
					return false
				end
			end,
			set = function() beql:Nyelv(k) end,
		}
    end	
end

function beql:setmovabletracker(newValue)
	self.db.profile.lockedtracker = newValue
	if not self.db.profile.disabled.tracker and not self.db.profile.disabledtracker then
		if self.db.profile.lockedtracker then
			QuestWatchFrame:RegisterForDrag(0)
			beql.TrackerTitleBar:RegisterForDrag(0)
		else
			QuestWatchFrame:RegisterForDrag("LeftButton")
			beql.TrackerTitleBar:RegisterForDrag("LeftButton")
		end
	end
	beql:CheckMouseEvents()
end

function beql:CheckMouseEvents()
	if beql.db.profile.disabledtracker then
		return
	else
		if not beql.db.profile.activetracker and not beql.db.profile.activetrackerleft and not beql.db.profile.activetrackerright and beql.db.profile.lockedtracker then
			QuestWatchFrame:EnableMouse(false)
			beql.TrackerTitleBar:EnableMouse(false)
		else
			QuestWatchFrame:EnableMouse(true)
			beql.TrackerTitleBar:EnableMouse(true)
		end
	end
end

function beql:setinfoonquestcomplete(newValue)
	self.db.profile.InfoOnQuestCompletion = newValue
end
