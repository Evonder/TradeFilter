--[[
File Author: @file-author@
File Revision: @file-revision@
File Date: @file-date-iso@
]]--

local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("TradeFilter")
L:AddTranslations("enUS", function() return {
	["TurnOn"] = "Turn On",
	["TurnOnDesc"] = "Enable Trade Channel Filter.",
	["Redir"] = "Redirect Spam [Requires UI Reload]",
	["RedirDesc"] = "Redirect Trade Channel Spam to SPAM Channel [Requires UI Reload].",
	["Debug"] = "Debugging [Requires UI Reload]",
	["DebugDesc"] = "Enable Debugging and Output to DEBUG Channel [Requires UI Reload].",
	["AddFilterG"] = "Add Filter Expression",
	["AddFilterGD"] = "Add Filter Expression to be matched in Trade Channel Group.",
	["AddFilter"] = "Add Filter Expression",
	["AddFilterD"] = "Add Filter Expression to be matched in Trade Channel. [Requires UI Reload to Enable]",
	["AddFilter1"] = "Custom Filter Expression 1",
	["AddFilter2"] = "Custom Filter Expression 2",
	["AddFilter3"] = "Custom Filter Expression 3",
	["AddFilter1D"] = "Add Custom Filter Expression to be Allowed in Trade Channel.",
	["AddFilterUsage"] = "Case Insensitive LFG = [lL][fF][gG]",
	["RUI"] = "Reload UI",
	["RUID"] = "Reload the User Interface for some changes to take effect.",
	["TC"] = "Filter Trade Channel",
	["TCD"] = "Select this to apply filter to Trade Channel",
	["GC"] = "Filter General Channel",
	["GCD"] = "Select this to apply filter to General Channel.",
	["LFGC"] = "Filter LFG Channel",
	["LFGCD"] = "Select this to apply filter to LFG Channel.",
	["SAYC"] = "Filter SAY Channel",
	["SAYCD"] = "Select this to apply filter to SAY Channel.",
} end)
