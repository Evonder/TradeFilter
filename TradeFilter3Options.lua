---@diagnostic disable: undefined-field
--[[
File Author: @file-author@
File Revision: @file-abbreviated-hash@
File Date: @file-date-iso@
]]--

local TradeFilter3 = LibStub("AceAddon-3.0"):GetAddon("TradeFilter3")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeFilter3")
local TF3 = TradeFilter3

--[[ Locals ]]--
local ipairs = ipairs
local pairs = pairs
local insert = table.insert
local sort = table.sort
local sub = string.sub

--[[ Options Table ]]--
local options
function TF3:getOptions()
	if not options then
		options = {
			type="group",
			name = TF3.name,
			handler = TF3,
			childGroups = "tab",
			args = {
				generalGroup = {
					type = "group",
					name = TF3.name,
					args = {
						mainHeader = {
							type = "description",
							name = "  " .. L["NJAOF"] .. "\n  " .. TF3.version .. "\n  " .. sub(TF3.date,6,7) .. "-" .. sub(TF3.date,9,10) .. "-" .. sub(TF3.date,1,4),
							order = 1,
							image = "Interface\\Icons\\Ability_Warrior_RallyingCry",
							imageWidth = 32, imageHeight = 32,
						},
						turnOn = {
							type = 'toggle',
							order = 2,
							width = "double",
							name = L["TurnOn"],
							desc = L["TurnOnDesc"],
							get = function() return TF3.db.profile.turnOn end,
							set = function()
								if not (TF3.db.profile.turnOn) then
									print(L["TOC/Title"] .. " " .. TF3.version .. " " .. L["ENABLED"])
									TF3.db.profile.turnOn = not TF3.db.profile.turnOn
								else
									print(L["TOC/Title"] .. " " .. TF3.version .. " " .. L["DISABLED"])
									TF3.db.profile.turnOn = not TF3.db.profile.turnOn
								end
							end,
						},
						channelGroup = {
							type = "group",
							handler = TF3,
							order = 1,
							disabled = function() return not TF3.db.profile.turnOn end,
							name = L["channelGroup"],
							desc = L["channelGroup"],
							args = {
								optionsHeader1 = {
									type	= "header",
									order	= 1,
									name	= L["channelGroup"],
								},
								tradeChannel = {
									type = 'toggle',
									order = 2,
									width = "double",
									disabled = false,
									name = L["TC"],
									desc = L["TCD"],
									get = function() return TF3.db.profile.filterTrade end,
									set = function() TF3.db.profile.filterTrade = not TF3.db.profile.filterTrade end,
								},
								generalChannel = {
									type = 'toggle',
									order = 3,
									width = "double",
									disabled = false,
									name = L["GC"],
									desc = L["GCD"],
									get = function() return TF3.db.profile.filterGeneral end,
									set = function() TF3.db.profile.filterGeneral = not TF3.db.profile.filterGeneral end,
								},
								LFGChannel = {
									type = 'toggle',
									order = 4,
									width = "double",
									disabled = false,
									name = L["LFGC"],
									desc = L["LFGCD"],
									get = function() return TF3.db.profile.filterLFG end,
									set = function() TF3.db.profile.filterLFG = not TF3.db.profile.filterLFG end,
								},
								Battlegrounds = {
									type = 'toggle',
									order = 4,
									width = "double",
									disabled = false,
									name = L["BGC"],
									desc = L["BGCD"],
									get = function() return TF3.db.profile.filterBG end,
									set = function() TF3.db.profile.filterBG = not TF3.db.profile.filterBG end,
								},
								SAYChannel = {
									type = 'toggle',
									order = 5,
									width = "double",
									disabled = false,
									name = L["SAYC"],
									desc = L["SAYCD"],
									get = function() return TF3.db.profile.filterSAY end,
									set = function() TF3.db.profile.filterSAY = not TF3.db.profile.filterSAY end,
								},
								YELLChannel = {
									type = 'toggle',
									order = 6,
									width = "double",
									disabled = false,
									name = L["YELLC"],
									desc = L["YELLCD"],
									get = function() return TF3.db.profile.filterYELL end,
									set = function() TF3.db.profile.filterYELL = not TF3.db.profile.filterYELL end,
								},
								optionsHeader1a = {
									type	= "header",
									order	= 7,
									name	= L["FDS"],
								},
								filterDuelSpam = {
									type = 'toggle',
									order = 8,
									width = "double",
									disabled = false,
									name = L["FDS"],
									desc = L["FDSD"],
									get = function() return TF3.db.profile.filterDuelSpam end,
									set = function() TF3.db.profile.filterDuelSpam = not TF3.db.profile.filterDuelSpam; TF3:DuelFilter()end,
								},
							},
						},
						editFilterGroup = {
							type = "group",
							childGroups = "tab",
							handler = TF3,
							order = 2,
							disabled = function() return not TF3.db.profile.turnOn end,
							name = L["EditFilterGroup"],
							desc = L["EditFilterGD"],
							args = {
								editFilterGroupTRADE = {
									type = "group",
									handler = TF3,
									order = 1,
									disabled = function() return not TF3.db.profile.turnOn end,
									name = L["TRADE Filters"],
									args = {
										optionsHeader1 = {
											type	= "header",
											order	= 1,
											name	= L["EditFilter"],
										},
										editfilter_enable = {
											type = 'toggle',
											order = 2,
											width = "double",
											name = L["EditFilter"],
											desc = L["EditFilterD"],
											get = function() return TF3.db.profile.addfilterTRADE_enable end,
											set = function() TF3.db.profile.addfilterTRADE_enable = not TF3.db.profile.addfilterTRADE_enable end,
										},
										optionsHeader2 = {
											type	= "header",
											order	= 3,
											name	= L["BTF"],
										},
										tradefilters = {
											type = 'input',
											disabled = function() return not TF3.db.profile.addfilterTRADE_enable end,
											multiline = 10,
											order = 4,
											width = "full",
											name = L["BTF"],
											desc = L["BTFD"],
											usage = L["INPUSAGE"],
											get = function(info)
												local a = {}
												local ret = ""
												if not (TF3.db.profile.filters.TRADE) then
													TF3.db.profile.filters.TRADE = TF3:FixWowAceSubnamespaces("TRADE")
												end
												for _,v in pairs(TF3.db.profile.filters.TRADE) do
													insert(a, v)
												end
												sort(a)
												for _,v in ipairs(a) do
													if ret == "" then
														ret = v
													else
														ret = ret .. "\n" .. v
													end
												end
												return ret
											end,
											set = function(info, value)
												TF3:WipeTable(TF3.db.profile.filters.TRADE)
												local tbl = { strsplit("\n", value) }
												for k, v in pairs(tbl) do
													if (v ~= "") then
														key = "FILTER"
														TF3.db.profile.filters.TRADE[key..k] = v
													end
												end
											end,
										},
										reset_tradefilters = {
											type = 'execute',
											disabled = function() return not TF3.db.profile.addfilterTRADE_enable end,
											order = 5,
											name = L["RTF"],
											desc = L["RTF"],
											func = function()
												local t = TF3:FixWowAceSubnamespaces("TRADE")
												TF3.db.profile.filters.TRADE = TF3:CopyTable(t)
											end,
										},
									},
								},
								editFilterGroupBASE = {
									type = "group",
									handler = TF3,
									order = 2,
									disabled = function() return not TF3.db.profile.turnOn end,
									name = L["BASE Filters"],
									args = {
										optionsHeader1 = {
											type	= "header",
											order	= 1,
											name	= L["EditFilter"],
										},
										editfilter_enable = {
											type = 'toggle',
											order = 2,
											width = "double",
											name = L["EditFilter"],
											desc = L["EditFilterD"],
											get = function() return TF3.db.profile.addfilterBASE_enable end,
											set = function() TF3.db.profile.addfilterBASE_enable = not TF3.db.profile.addfilterBASE_enable end,
										},
										optionsHeader2 = {
											type	= "header",
											order	= 6,
											name	= L["BCF"],
										},
										basefilters = {
											type = 'input',
											disabled = function() return not TF3.db.profile.addfilterBASE_enable end,
											multiline = 10,
											order = 7,
											width = "full",
											name = L["BCF"],
											desc = L["BCFD"],
											usage = L["INPUSAGE"],
											get = function(info)
												local a = {}
												local ret = ""
												if not (TF3.db.profile.filters.BASE) then
													TF3.db.profile.filters.BASE = TF3:FixWowAceSubnamespaces("BASE")
												end
												for _,v in pairs(TF3.db.profile.filters.BASE) do
													insert(a, v)
												end
												sort(a)
												for _,v in ipairs(a) do
													if ret == "" then
														ret = v
													else
														ret = ret .. "\n" .. v
													end
												end
												return ret
											end,
											set = function(info, value)
												TF3:WipeTable(TF3.db.profile.filters.BASE)
												local tbl = { strsplit("\n", value) }
												for k, v in pairs(tbl) do
													if (v ~= "") then
														key = "FILTER"
														TF3.db.profile.filters.BASE[key..k] = v
													end
												end
											end,
										},
										reset_basefilters = {
											type = 'execute',
											disabled = function() return not TF3.db.profile.addfilterBASE_enable end,
											order = 8,
											name = L["RBF"],
											desc = L["RBF"],
											func = function()
												local t = TF3:FixWowAceSubnamespaces("BASE")
												TF3.db.profile.filters.BASE = TF3:CopyTable(t)
											end,
										},
									},
								},
								editFilterGroupBG = {
									type = "group",
									handler = TF3,
									order = 3,
									disabled = function() return not TF3.db.profile.turnOn end,
									name = L["BG Filters"],
									args = {
										optionsHeader1 = {
											type	= "header",
											order	= 1,
											name	= L["EditFilter"],
										},
										editfilter_enable = {
											type = 'toggle',
											order = 2,
											width = "double",
											name = L["EditFilter"],
											desc = L["EditFilterD"],
											get = function() return TF3.db.profile.addfilterBG_enable end,
											set = function() TF3.db.profile.addfilterBG_enable = not TF3.db.profile.addfilterBG_enable end,
										},
										optionsHeader2 = {
											type	= "header",
											order	= 6,
											name	= L["BG"],
										},
										bgfilters = {
											type = 'input',
											disabled = function() return not TF3.db.profile.addfilterBG_enable end,
											multiline = 10,
											order = 7,
											width = "full",
											name = L["BG"],
											desc = L["BGD"],
											usage = L["INPUSAGE"],
											get = function(info)
												local a = {}
												local ret = ""
												if not (TF3.db.profile.filters.BG) then
													TF3.db.profile.filters.BG = TF3:FixWowAceSubnamespaces("BG")
												end
												for _,v in pairs(TF3.db.profile.filters.BG) do
													insert(a, v)
												end
												sort(a)
												for _,v in ipairs(a) do
													if ret == "" then
														ret = v
													else
														ret = ret .. "\n" .. v
													end
												end
												return ret
											end,
											set = function(info, value)
												TF3:WipeTable(TF3.db.profile.filters.BG)
												local tbl = { strsplit("\n", value) }
												for k, v in pairs(tbl) do
													if (v ~= "") then
														key = "FILTER"
														TF3.db.profile.filters.BG[key..k] = v
													end
												end
											end,
										},
										reset_bgfilters = {
											type = 'execute',
											disabled = function() return not TF3.db.profile.addfilterBG_enable end,
											order = 8,
											name = L["RBF"],
											desc = L["RBF"],
											func = function()
												local t = TF3:FixWowAceSubnamespaces("BG")
												TF3.db.profile.filters.BG = TF3:CopyTable(t)
											end,
										},
									},
								},
							},
						},
						listsGroup = {
							type = "group",
							childGroups = "tab",
							handler = TF3,
							order = 3,
							disabled = function() return not TF3.db.profile.turnOn end,
							name = L["listsGroup"],
							desc = L["listsGD"],
							args = {
								listsGroupBlack = {
									type = "group",
									handler = TF3,
									order = 1,
									disabled = function() return not TF3.db.profile.turnOn end,
									name = L["bLists"],
									desc = L["listsGD"],
									args = {
										optionsHeader1 = {
											type	= "header",
											order	= 1,
											name	= L["bLists"],
										},
										blacklist_enable = {
											type = 'toggle',
											order = 2,
											width = "double",
											name = L["BLE"],
											desc = L["BLE"],
											get = function() return TF3.db.profile.blacklist_enable end,
											set = function() TF3.db.profile.blacklist_enable = not TF3.db.profile.blacklist_enable end,
										},
										editblacklist = {
											type = 'toggle',
											order = 3,
											disabled = function() return not TF3.db.profile.blacklist_enable end,
											width = "double",
											name = L["EBL"],
											desc = L["EBL"],
											get = function() return TF3.db.profile.ebl end,
											set = function() TF3.db.profile.ebl = not TF3.db.profile.ebl end,
										},
										blist = {
											type = 'input',
											disabled = function() return not TF3.db.profile.ebl	end,
											multiline = 10,
											order = 4,
											width = "full",
											name = L["bLists"],
											usage = L["INPUSAGE"],
											get = function(info)
												local a = {}
												local ret = ""
												if not (TF3.db.profile.blacklist) then
													TF3.db.profile.blacklist = TF3:FixWowAceSubnamespaces("blacklist")
												end
												for _,v in pairs(TF3.db.profile.blacklist) do
													insert(a, v)
												end
												sort(a)
												for _,v in ipairs(a) do
													if ret == "" then
														ret = v
													else
														ret = ret .. "\n" .. v
													end
												end
												return ret
											end,
											set = function(info, value)
												TF3:WipeTable(TF3.db.profile.blacklist)
												local tbl = { strsplit("\n", value) }
												for k, v in pairs(tbl) do
													if (v ~= "") then
														key = "BLIST"
														TF3.db.profile.blacklist[key..k] = v
													end
												end
											end,
										},
										reset_blist = {
											type = 'execute',
											disabled = function() return not TF3.db.profile.ebl	end,
											order = 5,
											name = L["RBLS"],
											desc = L["RBLS"],
											func = function()
												local t = TF3:FixWowAceSubnamespaces("blacklist")
												TF3.db.profile.blacklist = TF3:CopyTable(t)
											end,
										},
									},
								},
								listsGroupWhite = {
									type = "group",
									handler = TF3,
									order = 2,
									disabled = function()
										return not TF3.db.profile.turnOn
									end,
									name = L["wLists"],
									desc = L["listsGD"],
									args = {
										optionsHeader3b = {
											type	= "header",
											order	= 1,
											name	= L["wLists"],
										},
										whitelist_enable = {
											type = 'toggle',
											order = 2,
											width = "double",
											name = L["WLE"],
											desc = L["WLE"],
											get = function() return TF3.db.profile.whitelist_enable end,
											set = function() TF3.db.profile.whitelist_enable = not TF3.db.profile.whitelist_enable end,
										},
										editwhitelist = {
											type = 'toggle',
											order = 3,
											disabled = function() return not TF3.db.profile.whitelist_enable end,
											width = "double",
											name = L["EWL"],
											desc = L["EWL"],
											get = function() return TF3.db.profile.ewl end,
											set = function() TF3.db.profile.ewl = not TF3.db.profile.ewl end,
										},
										whitelist_blacklist_bypass = {
											type = 'toggle',
											order = 5,
											disabled = function() return not TF3.db.profile.whitelist_enable end,
											width = "double",
											name = L["BLBYPASS"],
											desc = L["BLBYPASSD"],
											get = function() return TF3.db.profile.wlblbp end,
											set = function() TF3.db.profile.wlblbp = not TF3.db.profile.wlblbp end,
										},
										wlist = {
											type = 'input',
											disabled = function() return not TF3.db.profile.ewl	end,
											multiline = 10,
											order = 6,
											width = "full",
											name = L["wLists"],
											usage = L["INPUSAGE"],
											get = function(info)
												local a = {}
												local ret = ""
												if not (TF3.db.profile.whitelist) then
													TF3.db.profile.whitelist = TF3:FixWowAceSubnamespaces("whitelist")
												end
												for _,v in pairs(TF3.db.profile.whitelist) do
													insert(a, v)
												end
												sort(a)
												for _,v in ipairs(a) do
													if ret == "" then
														ret = v
													else
														ret = ret .. "\n" .. v
													end
												end
												return ret
											end,
											set = function(info, value)
												TF3:WipeTable(TF3.db.profile.whitelist)
												local tbl = { strsplit("\n", value) }
												for k, v in pairs(tbl) do
													if (v ~= "") then
														key = "WLIST"
														TF3.db.profile.whitelist[key..k] = v
													end
												end
											end,
										},
										reset_wlist = {
											type = 'execute',
											disabled = function() return not TF3.db.profile.ewl	end,
											order = 7,
											name = L["RWLS"],
											desc = L["RWLS"],
											func = function()
												local t = TF3:FixWowAceSubnamespaces("whitelist")
												TF3.db.profile.whitelist = TF3:CopyTable(t)
											end,
										},
									},
								},
							},
						},
						exemptGroupMain = {
							type = "group",
							handler = TF3,
							childGroups = "tab",
							order = 5,
							disabled = function() return not TF3.db.profile.turnOn end,
							name = L["Exempt List"],
							desc = L["Current Exempt List"],
							args = {
								enable_exempt_party = {
									type = 'toggle',
									order = 1,
									disabled = false,
									name = L["Party Members"],
									desc = L["If enabled party members will be exempt from filtration."],
									get = function() return TF3.db.profile.exmptparty end,
									set = function() TF3.db.profile.exmptparty = not TF3.db.profile.exmptparty end,
								},
								enable_exempt_friends = {
									type = 'toggle',
									order = 2,
									disabled = false,
									name = L["Friends"],
									desc = L["If enabled your friends list will be exempt from filtration."],
									get = function() return TF3.db.profile.exmptfriendslist end,
									set = function() TF3.db.profile.exmptfriendslist = not TF3.db.profile.exmptfriendslist end,
								},
							},
						},
						outputGroup = {
							type = "group",
							handler = TF3,
							order = 6,
							disabled = function()
								return not TF3.db.profile.turnOn
							end,
							name = L["OUTPUT"],
							desc = L["OUTPUT"],
							args = {
								optionsHeader5 = {
									type	= "header",
									order	= 1,
									name	= L["OUTPUT"],
								},
								redirect = {
									type = 'toggle',
									order = 2,
									width = "full",
									name = L["Redir"],
									desc = L["RedirDesc"],
									get = function() return TF3.db.profile.redirect end,
									set = function() TF3.db.profile.redirect = not TF3.db.profile.redirect end,
								},
								redirect_blacklist = {
									type = 'toggle',
									order = 3,
									width = "full",
									disabled = function() return not TF3.db.profile.redirect end,
									name = L["RedirBL"],
									desc = L["RedirDesc"],
									get = function() return TF3.db.profile.redirect_blacklist end,
									set = function() TF3.db.profile.redirect_blacklist = not TF3.db.profile.redirect_blacklist end,
								},
								optionsHeader6 = {
									type	= "header",
									order	= 4,
									name	= L["DEBUGGING"],
								},
								debug = {
									type = 'toggle',
									order = 5,
									width = "full",
									disabled = false,
									hidden = false,
									name = L["Debug"],
									desc = L["DebugDesc"],
									get = function() return TF3.db.profile.debug end,
									set = function() TF3.db.profile.debug = not TF3.db.profile.debug end,
								},
								debug_checking = {
									type = 'toggle',
									order = 6,
									width = "full",
									disabled = function() return not TF3.db.profile.debug end,
									hidden = false,
									name = L["DebugChecking"],
									desc = L["DebugCheckingD"],
									get = function() return TF3.db.profile.debug_checking end,
									set = function() TF3.db.profile.debug_checking = not TF3.db.profile.debug_checking end,
								},
								optionsHeader4 = {
									type	= "header",
									order	= 7,
									name	= L["FSELF"],
									desc = L["FSELFD"],
								},
								filterSELF = {
									type = 'toggle',
									order = 8,
									width = "double",
									disabled = false,
									name = L["FSELF"],
									desc = L["FSELFD"],
									get = function() return TF3.db.profile.filterSELF end,
									set = function() TF3.db.profile.filterSELF = not TF3.db.profile.filterSELF end,
								},
							},
						},
						Profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(TF3.db),
					},
				},
			},
		}
		end
	return options
end
