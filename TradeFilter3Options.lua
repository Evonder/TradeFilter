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
							print("|cFF33FF99TradeFilter3|r: " .. TF3.version .. " |cff00ff00Enabled|r")
							TF3.db.profile.turnOn = not TF3.db.profile.turnOn
						else
							print("|cFF33FF99TradeFilter3|r: " .. TF3.version .. " |cffff8080Disabled|r")
							TF3.db.profile.turnOn = not TF3.db.profile.turnOn
						end
					end,
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
				--@alpha@
				debug = {
					type = 'toggle',
					order = 3,
					width = "full",
					disabled = false,
					hidden = false,
					name = L["Debug"],
					desc = L["DebugDesc"],
					get = function() return TF3.db.profile.debug end,
					set = function() TF3.db.profile.debug = not TF3.db.profile.debug end,
				},
				--@end-alpha@
				reload = {
					type = 'execute',
					name = L["RUI"],
					desc = L["RUID"],
					func = function()
						_G.ReloadUI()
					end,
					--disabled = function()
					--	if not TF3:IsRedirect() or not TF3:IsDebug() then
					--		return false
					--	end
					--	return true
					--end,
					order = -1,
				},
				channelGroup = {
					type = "group",
					handler = TF3,
					order = 1,
					width = "double",
					disabled = false,
					name = "Channel Selection",
					desc = "Channel Selection",
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
				addFilterGroup = {
					type = "group",
					disabled = false,
					name = L["addFilterGroup"],
					desc = L["AddFilterGD"],
					args = {
						optionsHeader2 = {
							type	= "header",
							order	= 1,
							name	= L["AddFilter"],
						},
						addfilter_enable = {
							type = 'toggle',
							order = 2,
							width = "double",
							name = L["AddFilter"],
							desc = L["AddFilterD"],
							get = function() return TF3.db.profile.addfilter_enable end,
							set = function() TF3.db.profile.addfilter_enable = not TF3.db.profile.addfilter_enable end,
						},
						addfilter1 = {
							type = 'input',
							disabled = function()
								return not TF3.db.profile.addfilter_enable
							end,
							order = 3,
							width = "double",
							name = L["AddFilter1"],
							desc = L["AddFilter1D"],
							get = function(info)
								return TF3.db.profile.filter[1]
							end,
							set = function(info, value)
								TF3.db.profile.filter[1] = value
								print("The " .. TF3.db.profile.filter[1] .. " was set to: " .. tostring(value))
							end,
							usage = L["AddFilterUsage"],
						},
						addfilter2 = {
							type = 'input',
							disabled = function()
								return not TF3.db.profile.addfilter_enable
							end,
							order = 4,
							width = "double",
							name = L["AddFilter2"],
							desc = L["AddFilter1D"],
							get = function(info)
								return TF3.db.profile.filter[2]
							end,
							set = function(info, value)
								TF3.db.profile.filter[2] = value
								print("The " .. TF3.db.profile.filter[2] .. " was set to: " .. tostring(value))
							end,
							usage = L["AddFilterUsage"],
						},
						addfilter3 = {
							type = 'input',
							disabled = function()
								return not TF3.db.profile.addfilter_enable
							end,
							order = 5,
							width = "double",
							name = L["AddFilter3"],
							desc = L["AddFilter1D"],
							get = function(info)
								return TF3.db.profile.filter[3]
							end,
							set = function(info, value)
								TF3.db.profile.filter[3] = value
								print("The " .. TF3.db.profile.filter[3] .. " was set to: " .. tostring(value))
							end,
							usage = L["AddFilterUsage"],
						},
					},
				},
			},
		},
	},
}
