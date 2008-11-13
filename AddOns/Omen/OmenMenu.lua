local dewdrop = AceLibrary("Dewdrop-2.0")
local L = AceLibrary("AceLocale-2.2"):new("Omen")
local media = LibStub("LibSharedMedia-2.0")
local media_statusbar = media:List("statusbar")
local media_fonts = media:List("font")
local media_sounds = media:List("sound")
media:Register("sound", "Rubber Ducky", [[Sound\Doodad\Goblin_Lottery_Open01.wav]])
media:Register("sound", "Cartoon FX", [[Sound\Doodad\Goblin_Lottery_Open03.wav]])
media:Register("sound", "Explosion", [[Sound\Doodad\Hellfire_Raid_FX_Explosion05.wav]])
media:Register("sound", "Shing!", [[Sound\Doodad\PortcullisActive_Closed.wav]])
media:Register("sound", "Wham!", [[Sound\Doodad\PVP_Lordaeron_Door_Open.wav]])
media:Register("sound", "Simon Chime", [[Sound\Doodad\SimonGame_LargeBlueTree.wav]])
media:Register("sound", "War Drums", [[Sound\Event Sounds\Event_wardrum_ogre.wav]])
media:Register("sound", "Cheer", [[Sound\Event Sounds\OgreEventCheerUnique.wav]])
media:Register("sound", "Humm", [[Sound\Spells\SimonGame_Visual_GameStart.wav]])
media:Register("sound", "Short Circuit", [[Sound\Spells\SimonGame_Visual_BadPress.wav]])
local outlines = {[""] = L["None"], ["OUTLINE"] = L["Outline"], ["THICKOUTLINE"] = L["Thick Outline"]}

local BC = AceLibrary("Babble-Class-2.2")

local waterfall = AceLibrary:HasInstance("Waterfall-1.0") and AceLibrary("Waterfall-1.0")

local formatOptions = {"%2.0f", "%2.1f", "%2.2f"}

local classes = {"Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior"}
local classMenu = {
	type = "group",
	name = L["Classes"],
	desc = L["Select which classes to show on the threat meter"],
	icon = "",
	args = {
	}
}
for k,v in ipairs(classes) do
	local t = {
		type = "toggle",
		name = BC[v],
		desc = BC[v],
		get = function()
			return Omen.db.profile.Classes[strupper(v)]
		end,
		set = function(val) 
			Omen.db.profile.Classes[strupper(v)] = val
			Omen:ArrangeBars()
		end
	}
	classMenu.args[v] = t
end

classes = nil

local options = {
	type='group',
	args = {
		toggle = {
			type = "execute",
			desc = L["Toggle Omen"],
			name = L["Toggle Omen"],
			func = "Toggle",
			order = 102
		},
		togglektm = {
			type = "toggle",
			name = L["Publish to KTM"],
			desc = L["Allow Omen to send threat data to people using KLH Threat Meter."],
			get = function()
				return Omen.db.profile.EnableKTMPublish
			end,
			set = function(v)
				Omen.db.profile.EnableKTMPublish = v
				AceLibrary("Threat-1.0"):EnableKLHTMBroadcast(v)
			end
		},
		showpartyrevs = {
			type = "execute",
			desc = L["Show party revisions"],
			name = L["Show party revisions"],
			func = function()
				local t = AceLibrary("Threat-1.0"):GetPartyRevisions()
				for k, v in pairs(t) do
					Omen:Print(k .. ": " .. v)
				end
			end
		},
		reset = {
			type = "execute",
			name = L["Clear Threat"],
			desc = L["Clears the raid's threat lists. May only be used if you are a raid leader or assistant."],
			func = function() AceLibrary("Threat-1.0"):RequestThreatClear() end,
			disabled = function()
				return not (IsRaidLeader("player") or IsRaidOfficer("player") or IsPartyLeader("player") or (GetNumPartyMembers() + GetNumRaidMembers() == 0))
			end,
			order = 500
		},
		warnings = {
			type = "group",
			name = L["Warnings"],
			desc = L["Warnings"],
			args = {
				showWarnings = {
					type = "toggle",
					name = L["Show Warnings"],
					desc = L["Show Warnings"],
					get = function()
						return Omen.db.profile.EnableWarnings
					end,
					set = function(v)
						Omen.db.profile.EnableWarnings = v
					end
				},
				flashScreen = {
					type = "toggle",
					name = L["Flash Screen"],
					desc = L["Flash Screen"],
					get = function()
						return Omen.db.profile.FlashWarningFrame
					end,
					set = function(v)
						Omen.db.profile.FlashWarningFrame = v
					end
				},			
				showMessage = {
					type = "toggle",
					name = L["Show Warning Message"],
					desc = L["Show Warning Message"],
					get = function()
						return Omen.db.profile.ShowFloatingMessage
					end,
					set = function(v)
						Omen.db.profile.ShowFloatingMessage = v
					end
				},	
				showWhileTanking = {
					type = "toggle",
					name = L["Disable While Tanking"],
					desc = L["Disables warnings while you are in Defensive Stance, Bear Form, or have Righteous Fury"],
					get = function()
						return not Omen.db.profile.WarningsWhileTanking
					end,
					set = function(v)
						Omen.db.profile.WarningsWhileTanking = not v
					end
				},
				warningSound = {
					type = "text",
					name = L["Warning Sound"],
					desc = L["Sound to play on threat warning. Hold CTRL when selecting to hear the sound played."],
					get = function()
						return Omen.db.profile.WarningSound
					end,
					set = function(v)
						if IsControlKeyDown() then
							PlaySoundFile(media:Fetch("sound", v))
						else
							PlaySoundFile(media:Fetch("sound", v))
							Omen.db.profile.WarningSound = v
						end					
					end,
					usage = "<sound>",
					validate = media:List("sound")
				},
				warningThreshold = {
					type = "range",
					name = L["Warning Threshold"],
					desc = L["Sets the the threshold at which you will be warned of your threat level. When your threat is greater than this percentage of the aggro holder's threat, you will be warned."],
					min = 50,
					max = 130,
					step = 1,
					isPercent = false,
					get = function()
						return Omen.db.profile.WarnLevel * 100
					end,
					set = function(v)
						Omen.db.profile.WarnLevel = v / 100
					end
				}
			}
		},
		skins = {
			type = "group",
			name = L["Skins"],
			desc = L["Skins"],
			args = {
				selectSkin = {
					type = "text",
					name = L["Use skin..."],
					desc = L["Select the skin to use"],
					get = function()
						return ""
					end,
					set = function(v)
						Omen:LoadSkin(v)
						Omen:ApplySkin()
					end,
					validate = Omen.SkinList,
					usage = "<skin name>"
				},
				saveSkin = {
					type = "text",
					name = L["Save current skin as..."],
					desc = L["Save current skin as..."],
					get = function() return "" end,
					set = function(v)
						Omen:SaveCurrentSkinAs(v)
					end,
					usage = "<skin name>"
				},
				skinOptions = {
					type = "group",
					name = L["Skin Settings"],
					desc = L["Prevents Omen from hiding itself when ThreatLib is disabled"],
					args = {
						showtitle = {
							type = "toggle",
							name = L["Show Title"],
							desc = L["Show Title"],
							get = function()
								return Omen.ActiveSkin.ShowTitle
							end,
							set = function(v)
								Omen.ActiveSkin.ShowTitle = v
								Omen:ApplySkin()
							end
						},		
						arrows = {
							type = "group",
							name = L["Arrows"],
							desc = L["Arrows"],
							args = {
								showSelfArrow = {
									type = "toggle",
									name = L["Show Self"],
									desc = L["Show Self"],
									get = function()
										return Omen.ActiveSkin.ShowSelfArrow
									end,
									set = function(v)
										Omen.ActiveSkin.ShowSelfArrow = v
										Omen:ApplySkin()
									end								
								},
								selfArrowColor = {
									type = "color",
									hasAlpha = true,
									name = L["Self Color"],
									desc = L["Self Color"],
									get = function()
										local c = Omen.ActiveSkin.SelfArrowColor
										if not c then c = {r = 0, g = 1, b = 0, a = 1} end
										return c.r, c.g, c.b, c.a
									end,
									set = function(r, g, b, a)
										local c = Omen.ActiveSkin.SelfArrowColor
										c.r, c.g, c.b, c.a = r, g, b, a
										Omen:ApplySkin()
									end								
								},								
								showAggroArrow = {
									type = "toggle",
									name = L["Show Aggro"],
									desc = L["Show Aggro"],
									get = function()
										return Omen.ActiveSkin.ShowAggroArrow
									end,
									set = function(v)
										Omen.ActiveSkin.ShowAggroArrow = v
										Omen:ApplySkin()
									end								
								},
								aggroArrowColor = {
									type = "color",
									hasAlpha = true,
									name = L["Aggro Color"],
									desc = L["Aggro Color"],
									get = function()
										local c = Omen.ActiveSkin.AggroArrowColor
										if not c then c = {r = 1, g = 0, b = 0, a = 1} end
										return c.r, c.g, c.b, c.a
									end,
									set = function(r, g, b, a)
										local c = Omen.ActiveSkin.AggroArrowColor
										c.r, c.g, c.b, c.a = r, g, b, a
										Omen:ApplySkin()
									end								
								}
							}
						},
						showColumns = {
							type = "toggle",
							name = L["Show Column Headings"],
							desc = L["Show Column Headings"],
							get = function()
								return Omen.ActiveSkin.ShowColumns
							end,
							set = function(v)
								Omen.ActiveSkin.ShowColumns = v
								Omen:ApplySkin()
							end
						},	
						showVersionNumber = {
							type = "toggle",
							name = L["Show Version Number"],
							desc = L["Show Version Number"],
							get = function()
								return Omen.ActiveSkin.ShowVersionNumber
							end,
							set = function(v)
								Omen.ActiveSkin.ShowVersionNumber = v
								Omen:ApplySkin()
							end						
						},
						backdropColor = {
							type = "color",
							hasAlpha = true,
							name = L["Background Color"],
							desc = L["Background Color"],
							get = function()
								local f = Omen.ActiveSkin.BackdropColor
								return f.r, f.g, f.b, f.a
							end,
							set = function(r,g,b,a)
								local f = Omen.ActiveSkin.BackdropColor
								f.r, f.g, f.b, f.a = r, g, b, a
								Omen:ApplySkin()
							end
						},
						shortenNumbers = {
							type = "toggle",
							name = L["Shorten Numbers"],
							desc = L["Make numbers greater than 1,000 shorter; i.e., show 4,302 as '4.3k'"],
							get = function()
								return Omen.ActiveSkin.ShortThreatNumbers
							end,
							set = function(v)
								Omen.ActiveSkin.ShortThreatNumbers = v
								Omen:ArrangeBars()
							end
						},
						backdropBorderColor = {
							type = "color",
							hasAlpha = true,
							name = L["Border Color"],
							desc = L["Border Color"],
							get = function()
								local f = Omen.ActiveSkin.BorderColor
								return f.r, f.g, f.b, f.a
							end,
							set = function(r,g,b,a)
								local f = Omen.ActiveSkin.BorderColor
								f.r, f.g, f.b, f.a = r, g, b, a
								Omen:ApplySkin()
							end
						},
						tpsUpdateFrequency = {
							type = "range",
							name = L["TPS Update Frequency"],
							desc = L["TPS Update Frequency"],
							step = 0.05,
							min = 0.05,
							max = 2.0,
							isPercent = false,
							get = function()
								return Omen.ActiveSkin.TPSUpdateFrequency
							end,
							set = function(v)
								Omen.ActiveSkin.TPSUpdateFrequency = v
								Omen:ResetTPS()
								Omen:DisableTPSUpdate()
								Omen:EnableTPSUpdate()
							end
						},	
						columns = {
							type = "group",
							name = L["Columns"],
							desc = L["Columns"],
							args = {
								font = {
									type = "group",
									name = L["Font"],
									desc = L["Font"],
									order = 105,
									args = {
										font = {
											type = "text",
											name = L["Font"],
											desc = L["Font"],
											get = function()
												return Omen.ActiveSkin.CustomBarFonts["_COLUMNS_"][4]
											end,
											set = function(v)
												Omen.ActiveSkin.CustomBarFonts["_COLUMNS_"][4] = v
												Omen:ApplySkin()
											end,
											validate = media_fonts,
											usage = "<font name>"
										},
										size = {
											type = "range",
											name = L["Size"],
											desc = L["Size"],
											min = 5,
											max = 25,
											step = 1,
											isPercent = false,
											get = function()
												return Omen.ActiveSkin.CustomBarFonts["_COLUMNS_"][1]
											end,
											set = function(v)
												Omen.ActiveSkin.CustomBarFonts["_COLUMNS_"][1] = v
												Omen:ApplySkin()
											end
										},
										color = {
											type = "color",
											name = L["Color"],
											desc = L["Color"],
											get = function()
												local c = Omen.ActiveSkin.CustomBarFonts["_COLUMNS_"][3]
												return c.r, c.g, c.b
											end,
											set = function(r,g,b)
												local c = Omen.ActiveSkin.CustomBarFonts["_COLUMNS_"][3]
												c.r, c.g, c.b = r,g,b
												Omen:ApplySkin()
											end
										},		
										outlining = {
											type = "text",
											name = L["Outlining"],
											desc = L["Outlining"],
											get = function()
												return Omen.ActiveSkin.CustomBarFonts["_COLUMNS_"][2]
											end,
											set = function(v)
												Omen.ActiveSkin.CustomBarFonts["_COLUMNS_"][2] = v
												Omen:ApplySkin()
											end,
											validate = outlines,
											usage = "<outlining>"
										},	
									}
								}
							}		-- filled in dynamically
						},
						bars = {
							type = "group",
							name = L["Bars"],
							desc = L["Bars"],
							args = {
								animateBars = {
									type = "toggle",
									desc = L["Animate Bars"],
									name = L["Animate Bars"],
									get = function()
										return Omen.ActiveSkin.AnimateBars
									end,
									set = function(t)
										Omen.ActiveSkin.AnimateBars = t
									end
								},
		
								stretchBarTextures = {
									type = "toggle",
									desc = L["Stretch Bar Textures"],
									name = L["Stretch Bar Textures"],
									get = function()
										return Omen.ActiveSkin.StretchBarTextures
									end,
									set = function(t)
										Omen.ActiveSkin.StretchBarTextures = t
										Omen:ApplySkin()
										Omen:ShowTest()
									end
								},
								maxBars = {
									type = "range",
									name = L["Number of bars"],
									desc = L["Number of bars"],
									step = 1,
									min = 1,
									max = 40,
									isPercent = false,
									get = function()
										return Omen.db.profile.MaxBars
									end,
									set = function(v)
										Omen.db.profile.MaxBars = v
										Omen:ShowTest()
										Omen:ArrangeBars()
									end
								},
								barHeight = {
									type = "range",
									name = L["Bar Height"],
									desc = L["Bar Height"],
									step = 1,
									min = 10,
									max = 100,
									isPercent = false,
									get = function()
									return Omen.ActiveSkin.BarHeight
									end,
									set = function(h)
										Omen.ActiveSkin.BarHeight = h
										Omen:ApplySkin()
									end
								},
								barTexture = {
									type = "text",
									name = L["Bar Texture"],
									desc = L["Bar Texture"],
									get = function()
										return Omen.ActiveSkin.BarTexture
									end,
									set = function(tex)
										Omen.ActiveSkin.BarTexture = tex
										Omen:ApplySkin()
									end,
									validate = media_statusbar,
									usage = "<texture>",
								},
								font = {
									type = "group",
									name = L["Font"],
									desc = L["Font"],
									args = {
										font = {
											type = "text",
											name = L["Font"],
											desc = L["Font"],
											get = function()
												return Omen.ActiveSkin.CustomBarFonts["_BARS_"][4]
											end,
											set = function(v)
												Omen.ActiveSkin.CustomBarFonts["_BARS_"][4] = v
												Omen:ApplySkin()
											end,
											validate = media_fonts,
											usage = "<font name>"
										},
										size = {
											type = "range",
											name = L["Size"],
											desc = L["Size"],
											min = 5,
											max = 25,
											step = 1,
											isPercent = false,
											get = function()
												return Omen.ActiveSkin.CustomBarFonts["_BARS_"][1]
											end,
											set = function(v)
												Omen.ActiveSkin.CustomBarFonts["_BARS_"][1] = v
												Omen:ApplySkin()
											end
										},
										color = {
											type = "color",
											name = L["Color"],
											desc = L["Color"],
											get = function()
												local c = Omen.ActiveSkin.CustomBarFonts["_BARS_"][3]
												return c.r, c.g, c.b
											end,
											set = function(r,g,b)
												local c = Omen.ActiveSkin.CustomBarFonts["_BARS_"][3]
												c.r, c.g, c.b = r,g,b
												Omen:ApplySkin()
											end
										},		
										outlining = {
											type = "text",
											name = L["Outlining"],
											desc = L["Outlining"],
											get = function()
												return Omen.ActiveSkin.CustomBarFonts["_BARS_"][2]
											end,
											set = function(v)
												Omen.ActiveSkin.CustomBarFonts["_BARS_"][2] = v
												Omen:ApplySkin()
											end,
											validate = outlines,
											usage = "<outlining>"
										}
									}
								}						
							}
						}
					}
				}
			}
		},
		display = {
			type = "group",
			name = L["Display"],
			desc = L["Display options"],
			args = {
				showktm = {
					type = "toggle",
					name = L["Show KTM Data"],
					desc = L["Show data coming from people using KLHThreatMeter rather than ThreatLib. People using KTM will be denoted with a *"],
					get = function()
						return Omen.db.profile.ShowKtmData
					end,
					set = function(v)
						Omen.db.profile.ShowKtmData = v
					end
				},			
				center = {
					type = "execute",
					name = L["Reset Position"],
					desc = L["Resets Omen to the center of the screen"],
					func = function()
						Omen.Anchor:ClearAllPoints()
						Omen.Anchor:SetPoint("CENTER", UIParent, "CENTER")
					end
				},
				growUp = {
					type = "toggle",
					desc = L["Grow Upwards"],
					name = L["Grow Upwards"],
					get = function()
						return Omen.db.profile.GrowUp
					end,
					set = function(t)
						Omen.db.profile.GrowUp = t
						Omen:SetAnchors()
					end
				},					
				classes = classMenu,
				aggrobar = {
					type = "toggle",
					name = L["Show Aggro Gain"],
					desc = L["Show Aggro Gain"],
					get = function()
						return Omen.db.profile.ShowAggroGain
					end,
					set = function(v)
						Omen.db.profile.ShowAggroGain = v
					end
				},
				alwaysShow = {
					type = "toggle",
					name = L["Always show Omen"],
					desc = L["Always show Omen"],
					get = function()
						return Omen.db.profile.AlwaysShowOmen
					end,
					set = function(v)
						Omen.db.profile.AlwaysShowOmen = v
						if v then
							Omen.Anchor:Show()
						end
					end
				},
				showself = {
					type = "toggle",
					name = L["Always show self"],
					desc = L["Always show your position on the meter, even if you aren't in the top X slots."],
					get = function()
						return Omen.db.profile.AlwaysShowSelf
					end,
					set = function(v)	
						Omen.db.profile.AlwaysShowSelf = v
					end
				},						
				scale = {
					type = "range",
					name = L["Scale"],
					desc = L["Scale"],
					step = 0.01,
					min = 0.25,
					max = 5.0,
					isPercent = false,
					get = function()
						return Omen.db.profile.Scale
					end,
					set = function(v)
						Omen.db.profile.Scale = v
						Omen.Anchor:SetScale(v)
					end
				},
			}
		},
		lock = {
			type = "toggle",
			name = L["Lock"],
			desc = L["Lock the Omen window so that it may not be moved"],
			get = function()
				return Omen.db.profile.Locked
			end,
			set = function(v)	
				Omen.db.profile.Locked = v
				Omen:ApplySkin()
			end
		},
		showtest = {
			type = "execute",
			desc = L["Show Test Bars"],
			name = L["Show Test Bars"],
			func = "ShowTest"
		},
		activeWhenSolo = {
			type = "toggle",
			name = L["Active When Solo"],
			desc = L["Activate Omen when solo or in a battlegroups (testing purposes only)"],
			get = function()
				return Omen.db.profile.ActivateSolo
			end,
			set = function(v)
				Omen.db.profile.ActivateSolo = v
				AceLibrary("Threat-1.0"):RequestActiveOnSolo(v)
			end
		},	
		activeWithPet = {
			type = "toggle",
			name = L["Active With Pet"],
			desc = L["Activate Omen when you have a pet"],
			get = function()
				return Omen.db.profile.ActivateWithPet
			end,
			set = function(v)
				Omen.db.profile.ActivateWithPet = v
				if UnitName("pet") then
					Omen:Toggle(v)
				elseif not v then
					Omen:Toggle(v)
				end
			end
		},	
	}
}
options.args.display.args.skinOptions = options.args.skins.args.skinOptions

local default_color = {r = 1, g = 0, b = 0}
local barOptions = {
	type='group',
	args = {
		showThreatBar = {
			name = L["Pullout Threat Bar"],
			desc = L["Pullout Threat Bar"],
			type = "execute",
			disabled = function()
				return Omen.lastBarClicked.unitid == nil or Omen.lastBarClicked.unitid == "player"
			end,
			func = function()
				if Omen.lastBarClicked.unitid then
					local bar = OmenThreatBar:new()
					bar:CreateBar(Omen.lastBarClicked.unitname, Omen.lastBarClicked.unitid, Omen.db.profile.BarTexture)
				end
			end
		},
		showGraph = {
			name = L["Compare Threat Velocity"],
			desc = L["Compare Threat Velocity"],
			type = "execute",
			disabled = true,
			func = function()
				Omen:UpdateGraphCompare(Omen.lastBarClicked.unitname)
			end
		},
		customColor = {
			type = "color",
			hasAlpha = true,
			name = L["Bar Color"],
			desc = L["Bar Color"],
			get = function()
				return Omen.lastBarClicked.tex:GetVertexColor()
			end,
			set = function(r,g,b,a)
				local f = Omen.ActiveSkin.CustomColors[Omen.lastBarClicked.unitname]
				if not f then
					f = {}
					Omen.ActiveSkin.CustomColors[Omen.lastBarClicked.unitname] = f
				end
				f.r, f.g, f.b = r, g, b
				Omen:ApplySkin()
			end
		},
		font = {
			type = "group",
			name = L["Font"],
			desc = L["Font"],
			args = {
				font = {
					type = "text",
					name = L["Font"],
					desc = L["Font"],
					get = function()
						return (Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname] and Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname][4]) or Omen.ActiveSkin.CustomBarFonts["_BARS_"][4]
					end,
					set = function(v)
						Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname] = Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname] or {10, 10, {r = 1, g = 1, b = 1}, ""}
						Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname][4] = v
						Omen:ApplySkin()
					end,
					validate = media_fonts,
					usage = "<font name>"
				},
				size = {
					type = "range",
					name = L["Size"],
					desc = L["Size"],
					min = 5,
					max = 25,
					step = 1,
					isPercent = false,
					get = function()
						return (Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname] and Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname][1]) or Omen.ActiveSkin.CustomBarFonts["_BARS_"][1]
					end,
					set = function(v)
						Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname] = Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname] or {10, 10, {r = 1, g = 1, b = 1}, ""}
						Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname][1] = v
						Omen:ApplySkin()
					end
				},
				color = {
					type = "color",
					name = L["Color"],
					desc = L["Color"],
					get = function()
						local c = (Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname] and Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname][3]) or Omen.ActiveSkin.CustomBarFonts["_BARS_"][3]
						return c.r, c.g, c.b
					end,
					set = function(r,g,b)
						Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname] = Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname] or {10, 10, {r = 1, g = 1, b = 1}, ""}
						local c = Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname][3]
						c.r, c.g, c.b = r,g,b
						Omen:ApplySkin()
					end
				},		
				outlining = {
					type = "text",
					name = L["Outlining"],
					desc = L["Outlining"],
					get = function()
						return (Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname] and Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname][2]) or Omen.ActiveSkin.CustomBarFonts["_BARS_"][2]
					end,
					set = function(v)
						Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname] = Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname] or {10, 10, {r = 1, g = 1, b = 1}, ""}
						Omen.ActiveSkin.CustomBarFonts[Omen.lastBarClicked.unitname][2] = v
						Omen:ApplySkin()
					end,
					validate = outlines,
					usage = "<outlining>"
				},
			}
		},
		defaultColor = {
			type = "execute",
			name = L["Use Default Color"],
			desc = L["Use Default Color"],
			func = function()
				Omen.ActiveSkin.CustomColors[Omen.lastBarClicked.unitname] = nil
				Omen:ApplySkin()
			end,
			disabled = function()
				return Omen.ActiveSkin.CustomColors[Omen.lastBarClicked.unitname] == nil
			end
		},
		barTexture = {
			type = "text",
			name = L["Bar Texture"],
			desc = L["Bar Texture"],
			get = function() return Omen.ActiveSkin.CustomBarTextures[Omen.lastBarClicked.unitname] or Omen.ActiveSkin.BarTexture end,
			set = function(tex)
				Omen.ActiveSkin.CustomBarTextures[Omen.lastBarClicked.unitname] = tex
				Omen:ApplySkin()
			end,
			validate = media_statusbar,
			usage = "<texture>",
		},
		defaultTexture = {
			type = "execute",
			name = L["Use Default Texture"],
			desc = L["Use Default Texture"],
			func = function()
				Omen.ActiveSkin.CustomBarTextures[Omen.lastBarClicked.unitname] = nil
				Omen:ApplySkin()
			end,
			disabled = function()
				return Omen.ActiveSkin.CustomBarTextures[Omen.lastBarClicked.unitname] == nil
			end	
		},
		barHeight = {
			type = "range",
			name = L["Bar Height"],
			desc = L["Bar Height"],
			step = 1,
			min = 10,
			max = 100,
			isPercent = false,
			get = function()
				return Omen.ActiveSkin.CustomBarHeights[Omen.lastBarClicked.unitname] or Omen.ActiveSkin.BarHeight
			end,
			set = function(h)	
				if h == Omen.ActiveSkin.BarHeight then
					h = nil
				end
				Omen.ActiveSkin.CustomBarHeights[Omen.lastBarClicked.unitname] = h
				Omen:ApplySkin()
			end
		},
		defaultBarHeight = {
			type = "execute",
			name = L["Use Default Bar Height"],
			desc = L["Use Default Bar Height"],
			func = function()
				Omen.ActiveSkin.CustomBarHeights[Omen.lastBarClicked.unitname] = nil
				Omen:ApplySkin()
			end,
			disabled = function()
				return Omen.ActiveSkin.CustomBarHeights[Omen.lastBarClicked.unitname] == nil
			end	
		}
	}
}

local threatBarMenu = {
	type = "group",
	args = {
		barTexture = {
			type = "text",
			name = L["Bar Texture"],
			desc = L["Bar Texture"],
			get = function() return dewdrop:GetOpenedParent().parent.db.profile.texture end,
			set = function(tex)
				dewdrop:GetOpenedParent().parent.db.profile.texture = tex
				dewdrop:GetOpenedParent().parent:UpdateTexture()
			end,
			validate = media_statusbar,
			usage = "<texture>",
		},	
		remove = {
			type = "execute",
			name = "|cffff0000" .. L["Remove"],
			desc = L["Remove"],
			func = function() dewdrop:GetOpenedParent().parent:Remove() end
		},
		fade = {
			type = "execute",
			name = L["Fade out"],
			desc = L["Fade out"],
			func = function() dewdrop:GetOpenedParent().parent:Fade() end
		},
		alpha = {
			type = "range",
			name = L["Alpha"],
			desc = L["Alpha"],
			min = 0.1,
			max = 1,
			step = 0.05,
			isPercent = true,
			get = function()
				if dewdrop:GetOpenedParent() then
					return dewdrop:GetOpenedParent().parent.db.profile.Alpha or 1
				else
					return 1
				end
			end,
			set = function(v)
				dewdrop:GetOpenedParent().parent.db.profile.Alpha = v
				dewdrop:GetOpenedParent():SetAlpha(v)
			end
		}
	}
}
Omen.threatBarMenu = threatBarMenu
Omen.OnMenuRequest = options
Omen.barMenu = barOptions
Omen.mainMenu = options
Omen:RegisterChatCommand({"/omen"}, options, "OMEN")

if waterfall then
	waterfall:Register("Omen", 
						"aceOptions", options,
						"title", "Omen Configuration",
						"treeLevels", 5);
end

	--[[
		clearplayer = {
			type = "execute",
			desc = "|cffffff00Clear Player event log",
			name = "|cffffff00Clear Player event log",
			func = function() AceLibrary("Threat-1.0"):ClearEventLog("player"); Omen:Print("Player log cleared"); end,
			order = 500,
			disabled = true
		},
		clearpet = {
			type = "execute",
			desc = "|cffffff00Clear Pet event log",
			name = "|cffffff00Clear Pet event log",
			func = function() AceLibrary("Threat-1.0"):ClearEventLog("pet"); Omen:Print("Pet log cleared"); end,
			order = 502,
			disabled = true
		},
		dumpplayer = {
			type = "execute",
			name = "|cff00ff00Dump Player event log",
			desc = "|cff00ff00Dump Player event log",
			func = function() AceLibrary("Threat-1.0"):DumpEventLog("player"); end,
			order = 501,
			disabled = true
		},
		dumppet = {
			type = "execute",
			name = "|cff00ff00Dump Pet event log",
			desc = "|cff00ff00Dump Pet event log",
			func = function() AceLibrary("Threat-1.0"):DumpEventLog("pet"); end,
			order = 503,
			disabled = true
		},
		logevents = {
			type = "toggle",
			name = "|cffff0000Log events",
			desc = "Log events, bloats memory usage, debug only",
			get = function()
				return AceLibrary("Threat-1.0").LogEvents
			end,
			set = function(v)	
				AceLibrary("Threat-1.0").LogEvents = v
			end,
			order = 510,
			disabled = true
		},
		]]--