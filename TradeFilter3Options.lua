--[[
File Author: @file-author@
File Revision: @file-revision@
File Date: @file-date-iso@
]]--
local TradeFilter3 = LibStub("AceAddon-3.0"):GetAddon("TradeFilter3")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeFilter3")
local TF3 = TradeFilter3

--[[ Options Table ]]--
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
				turnOn = {
					type = 'toggle',
					order = 1,
					width = "double",
					name = L["TurnOn"],
					desc = L["TurnOnDesc"],
					get = function() return TF3.db.profile.turnOn end,
					set = function()
						if (TF3.db.profile.turnOn == false) then
							print(L.TOC.Title .. " " .. TF3.version .. " " .. L["ENABLED"])
							TF3.db.profile.turnOn = not TF3.db.profile.turnOn
						else
							print(L.TOC.Title .. " " .. TF3.version .. " " .. L["DISABLED"])
							TF3.db.profile.turnOn = not TF3.db.profile.turnOn
						end
					end,
				},
				channelGroup = {
					type = "group",
					handler = TF3,
					order = 1,
					disabled = function()
						return not TF3.db.profile.turnOn
					end,
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
							get = function() return TF3.db.profile.filtertrade end,
							set = function() TF3.db.profile.filtertrade = not TF3.db.profile.filtertrade end,
						},
						generalChannel = {
							type = 'toggle',
							order = 3,
							width = "double",
							disabled = false,
							name = L["GC"],
							desc = L["GCD"],
							get = function() return TF3.db.profile.filtergeneral end,
							set = function() TF3.db.profile.filtergeneral = not TF3.db.profile.filtergeneral end,
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
					},
				},
				editFilterGroup = {
					type = "group",
					handler = TF3,
					order = 2,
					disabled = function()
						return not TF3.db.profile.turnOn
					end,
					name = L["EditFilterGroup"],
					desc = L["EditFilterGD"],
					args = {
						optionsHeader2 = {
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
							get = function() return TF3.db.profile.addfilter_enable end,
							set = function() TF3.db.profile.addfilter_enable = not TF3.db.profile.addfilter_enable end,
						},
						optionsHeader2a = {
							type	= "header",
							order	= 3,
							name	= L["BTF"],
						},
						reset_tradefilters = {
							type = 'execute',
							disabled = function()
								return not TF3.db.profile.addfilter_enable
							end,
							order = 4,
							width = "double",
							name = L["RTF"],
							desc = L["RTF"],
							func = function() TF3.db.profile.filters.TRADE = TF3:CopyTable(L.FILTERS.TRADE) end,
						},
						tradefilters = {
							type = 'input',
							disabled = function()
								return not TF3.db.profile.addfilter_enable
							end,
							multiline = 8,
							order = 5,
							width = "full",
							name = L["BTF"],
--~ 							desc = L["BTF"],
							get = function(info)
								local ret = ""
									for k, v in pairs(TF3.db.profile.filters.TRADE) do
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
									key = "FILTER"
									TF3.db.profile.filters.TRADE[key..k] = v
								end
							end,
						},
						optionsHeader2b = {
							type	= "header",
							order	= 6,
							name	= L["BCF"],
						},
						reset_basefilters = {
							type = 'execute',
							disabled = function()
								return not TF3.db.profile.addfilter_enable
							end,
							order = 7,
							width = "double",
							name = L["RBF"],
							desc = L["RBF"],
							func = function() TF3.db.profile.filters.BASE = TF3:CopyTable(L.FILTERS.BASE) end,
						},

						basefilters = {
							type = 'input',
							disabled = function()
								return not TF3.db.profile.addfilter_enable
							end,
							multiline = 8,
							order = 8,
							width = "full",
							name = L["BCF"],
							desc = L["BCFD"],
							get = function(info)
								local ret = ""
									for k, v in pairs(TF3.db.profile.filters.BASE) do
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
									key = "FILTER"
									TF3.db.profile.filters.BASE[key..k] = v
								end
							end,
						},
					},
				},
				listsGroup = {
					type = "group",
					handler = TF3,
					order = 3,
					disabled = function()
						return not TF3.db.profile.turnOn
					end,
					name = L["listsGroup"],
					desc = L["listsGD"],
					args = {
						optionsHeader3 = {
							type	= "header",
							order	= 1,
							name	= L["bwLists"],
						},
						editlists_enable = {
							type = 'toggle',
							order = 2,
							width = "double",
							name = L["EditLists"],
							desc = L["EditLists"],
							get = function() return TF3.db.profile.editlists_enable end,
							set = function() TF3.db.profile.editlists_enable = not TF3.db.profile.editlists_enable end,
						},
						blacklist_enable = {
							type = 'toggle',
							order = 3,
							width = "double",
							name = L["BLE"],
							desc = L["BLE"],
							get = function() return TF3.db.profile.blacklist_enable end,
							set = function() TF3.db.profile.blacklist_enable = not TF3.db.profile.blacklist_enable end,
						},
						whitelist_enable = {
							type = 'toggle',
							order = 4,
							width = "double",
							name = L["WLE"],
							desc = L["WLE"],
							get = function() return TF3.db.profile.whitelist_enable end,
							set = function() TF3.db.profile.whitelist_enable = not TF3.db.profile.whitelist_enable end,
						},
						optionsHeader3a = {
							type	= "header",
							order	= 5,
							name	= L["bLists"],
						},
						reset_blist = {
							type = 'execute',
							disabled = function()
								return not TF3.db.profile.editlists_enable
							end,
							order = 6,
							width = "double",
							name = L["RBLS"],
							desc = L["RBLS"],
							func = function() TF3.db.profile.blacklist = TF3:CopyTable(L.BLACKLIST) end,
						},
						blist = {
							type = 'input',
							disabled = function()
								return not TF3.db.profile.editlists_enable
							end,
							multiline = 8,
							order = 7,
							width = "full",
							name = L["bLists"],
							get = function(info)
								local ret = ""
								for k, v in pairs(TF3.db.profile.blacklist) do
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
									key = "BLIST"
									TF3.db.profile.blacklist[key..k] = v
								end
							end,
						},
						optionsHeader3b = {
							type	= "header",
							order	= 8,
							name	= L["wLists"],
						},
						reset_wlist = {
							type = 'execute',
							disabled = function()
								return not TF3.db.profile.editlists_enable
							end,
							order = 9,
							width = "double",
							name = L["RWLS"],
							desc = L["RWLS"],
							func = function() TF3.db.profile.whitelist = TF3:CopyTable(L.WHITELIST) end,
						},
						wlist = {
							type = 'input',
							disabled = function()
								return not TF3.db.profile.editlists_enable
							end,
							multiline = 8,
							order = 10,
							width = "full",
							name = L["wLists"],
							get = function(info)
								local ret = ""
								for k, v in pairs(TF3.db.profile.whitelist) do
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
									key = "WLIST"
									TF3.db.profile.whitelist[key..k] = v
								end
							end,
						},
					},
				},
				repeatGroup = {
					type = "group",
					handler = TF3,
					order = 4,
					disabled = function()
						return not TF3.db.profile.turnOn
					end,
					name = L["REPEAT"],
					desc = L["REPEAT"],
					args = {
						optionsHeader4 = {
							type	= "header",
							order	= 1,
							name	= L["REPEAT"],
						},
						repeat_enable = {
							type = 'toggle',
							order = 2,
							width = "double",
							name = L["RPTENABLE"],
							desc = L["RPTENABLED"],
							get = function() return TF3.db.profile.repeat_enable end,
							set = function() TF3.db.profile.repeat_enable = not TF3.db.profile.repeat_enable end,
						},
						num_repeats = {
							type = 'input',
							disabled = function()
								return not TF3.db.profile.repeat_enable
							end,
							order = 3,
							width = "full",
							name = L["#RPT"],
							desc = L["#RPTD"],
							usage = L["RPTU"],
							get = function(info) return TF3.db.profile.num_repeats end,
							set = function(info, value) TF3.db.profile.num_repeats = value end,
						},
						time_repeats = {
							type = 'input',
							disabled = function()
								return not TF3.db.profile.repeat_enable
							end,
							order = 4,
							width = "full",
							name = L["TRPT"],
							desc = L["TRPTD"],
							usage = L["RPTU"],
							get = function(info) return TF3.db.profile.time_repeats end,
							set = function(info, value) TF3.db.profile.time_repeats = value end,
						},
						repeats_blocked = {
							type = 'input',
							disabled = true,
							order = 5,
							width = "half",
							name = L["RPTBLOCKED"],
							desc = L["RPTBLOCKEDD"],
							get = function(info) return tostring(TF3.db.profile.repeats_blocked) end,
						},
						reset_repeats_blocked = {
							type = 'execute',
							order = 6,
							width = "half",
							name = L["RPTRESET"],
							desc = L["RPTRESETD"],
							func = function() TF3.db.profile.repeats_blocked = 0 end,
						},
					},
				},
				outputGroup = {
					type = "group",
					handler = TF3,
					order = 5,
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
							name = L["RedirBL"],
							desc = L["RedirDesc"],
							get = function() return TF3.db.profile.redirect_blacklist end,
							set = function() TF3.db.profile.redirect_blacklist = not TF3.db.profile.redirect_blacklist end,
						},
						--@alpha@
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
							disabled = false,
							hidden = false,
							name = L["DebugChecking"],
							desc = L["DebugCheckingD"],
							get = function() return TF3.db.profile.debug_checking end,
							set = function() TF3.db.profile.debug_checking = not TF3.db.profile.debug_checking end,
						},
						--@end-alpha@
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
			},
		},
	},
}
