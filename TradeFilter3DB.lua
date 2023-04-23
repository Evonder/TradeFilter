--[[
File Author: @file-author@
File Revision: @file-abbreviated-hash@
File Date: @file-date-iso@
]]--

local TradeFilter3 = LibStub("AceAddon-3.0"):GetAddon("TradeFilter3")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeFilter3")
local TF3 = TradeFilter3

function TF3:FixWowAceSubnamespaces(db)
	if (db == "whitelist") then
		-- print("Importing whitelist")
		whitelist = {
			["WLIST1"] = L["WHITELIST/WLIST1"],
			["WLIST2"] = L["WHITELIST/WLIST2"],
			["WLIST3"] = L["WHITELIST/WLIST3"],
			["WLIST4"] = L["WHITELIST/WLIST4"],
			["WLIST5"] = L["WHITELIST/WLIST5"],
			["WLIST6"] = L["WHITELIST/WLIST6"],
			["WLIST7"] = L["WHITELIST/WLIST7"],
		}
		return whitelist
	elseif (db == "blacklist") then
		-- print("Importing blacklist")
		blacklist =  {
			["BLIST1"] = L["BLACKLIST/BLIST1"],
			["BLIST10"] = L["BLACKLIST/BLIST10"],
			["BLIST11"] = L["BLACKLIST/BLIST11"],
			["BLIST12"] = L["BLACKLIST/BLIST12"],
			["BLIST13"] = L["BLACKLIST/BLIST13"],
			["BLIST14"] = L["BLACKLIST/BLIST14"],
			["BLIST15"] = L["BLACKLIST/BLIST15"],
			["BLIST16"] = L["BLACKLIST/BLIST16"],
			["BLIST17"] = L["BLACKLIST/BLIST17"],
			["BLIST18"] = L["BLACKLIST/BLIST18"],
			["BLIST2"] = L["BLACKLIST/BLIST2"],
			["BLIST3"] = L["BLACKLIST/BLIST3"],
			["BLIST4"] = L["BLACKLIST/BLIST4"],
			["BLIST5"] = L["BLACKLIST/BLIST5"],
			["BLIST6"] = L["BLACKLIST/BLIST6"],
			["BLIST7"] = L["BLACKLIST/BLIST7"],
			["BLIST8"] = L["BLACKLIST/BLIST8"],
			["BLIST9"] = L["BLACKLIST/BLIST9"],
		}
		return blacklist
	elseif (db == "BASE") then
		-- print("Importing Base filters")
		BASE = {
			["FILTER1"] = L["FILTERS/BASE/FILTER1"],
			["FILTER2"] = L["FILTERS/BASE/FILTER2"],
			["FILTER3"] = L["FILTERS/BASE/FILTER3"],
			["FILTER4"] = L["FILTERS/BASE/FILTER4"],
			["FILTER5"] = L["FILTERS/BASE/FILTER5"],
			["FILTER6"] = L["FILTERS/BASE/FILTER6"],
			["FILTER7"] = L["FILTERS/BASE/FILTER7"],
			["FILTER8"] = L["FILTERS/BASE/FILTER8"],
			["FILTER9"] = L["FILTERS/BASE/FILTER9"],
		}
		return BASE
	elseif (db == "BG") then
		-- print("Importing BG filters")
		BG = {
			["FILTER1"] = L["FILTERS/BG/FILTER1"],
			["FILTER10"] = L["FILTERS/BG/FILTER10"],
			["FILTER11"] = L["FILTERS/BG/FILTER11"],
			["FILTER12"] = L["FILTERS/BG/FILTER12"],
			["FILTER13"] = L["FILTERS/BG/FILTER13"],
			["FILTER14"] = L["FILTERS/BG/FILTER14"],
			["FILTER15"] = L["FILTERS/BG/FILTER15"],
			["FILTER16"] = L["FILTERS/BG/FILTER16"],
			["FILTER17"] = L["FILTERS/BG/FILTER17"],
			["FILTER18"] = L["FILTERS/BG/FILTER18"],
			["FILTER19"] = L["FILTERS/BG/FILTER19"],
			["FILTER2"] = L["FILTERS/BG/FILTER2"],
			["FILTER20"] = L["FILTERS/BG/FILTER20"],
			["FILTER21"] = L["FILTERS/BG/FILTER21"],
			["FILTER22"] = L["FILTERS/BG/FILTER22"],
			["FILTER3"] = L["FILTERS/BG/FILTER3"],
			["FILTER4"] = L["FILTERS/BG/FILTER4"],
			["FILTER5"] = L["FILTERS/BG/FILTER5"],
			["FILTER6"] = L["FILTERS/BG/FILTER6"],
			["FILTER7"] = L["FILTERS/BG/FILTER7"],
			["FILTER8"] = L["FILTERS/BG/FILTER8"],
			["FILTER9"] = L["FILTERS/BG/FILTER9"],
		}
		return BG
	elseif (db == "TRADE") then
		-- print("Importing TRADE filters")
		TRADE = {
			["FILTER1"] = L["FILTERS/TRADE/FILTER1"],
			["FILTER10"] = L["FILTERS/TRADE/FILTER10"],
			["FILTER2"] = L["FILTERS/TRADE/FILTER2"],
			["FILTER3"] = L["FILTERS/TRADE/FILTER3"],
			["FILTER4"] = L["FILTERS/TRADE/FILTER4"],
			["FILTER5"] = L["FILTERS/TRADE/FILTER5"],
			["FILTER6"] = L["FILTERS/TRADE/FILTER6"],
			["FILTER7"] = L["FILTERS/TRADE/FILTER7"],
			["FILTER8"] = L["FILTERS/TRADE/FILTER8"],
			["FILTER9"] = L["FILTERS/TRADE/FILTER9"],
		}
		return TRADE
	elseif (db == "SPECIAL") then
		-- print("Importing SPECIAL filters")
		SPECIAL = {
			["FILTER1"] = L["FILTERS/SPECIAL/FILTER1"],
			["FILTER2"] = L["FILTERS/SPECIAL/FILTER2"],
		}
		return SPECIAL
	end
end

function TF3:dbImportSV()
	TF3.db.profile.whitelist = TF3:FixWowAceSubnamespaces("whitelist")
	TF3.db.profile.blacklist = TF3:FixWowAceSubnamespaces("blacklist")
	TF3.db.profile.filters.BASE = TF3:FixWowAceSubnamespaces("BASE")
	TF3.db.profile.filters.BG = TF3:FixWowAceSubnamespaces("BG")
	TF3.db.profile.filters.TRADE = TF3:FixWowAceSubnamespaces("TRADE")
	TF3.db.profile.filters.SPECIAL = TF3:FixWowAceSubnamespaces("SPECIAL")
end