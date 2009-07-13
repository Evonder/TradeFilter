--[[
TradeFilter3
		Filter that shit!

File Author: @file-author@
File Revision: @file-revision@
File Date: @file-date-iso@

* Copyright (c) 2008, Evonder
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the <organization> nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY <copyright holder> ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

TradeFilter3 = LibStub("AceAddon-3.0"):NewAddon("TradeFilter3", "AceConsole-3.0", "AceEvent-3.0")
local L =  LibStub("AceLocale-3.0"):GetLocale("TradeFilter3", true)
local friends = LibStub("LibFriends-1.0")
local TF3 = TradeFilter3

local MAJOR_VERSION = "3.0"
local MINOR_VERSION = 000 + tonumber(("$Revision: @project-revision@ $"):match("%d+"))
TF3.version = MAJOR_VERSION .. "." .. MINOR_VERSION
TF3.date = string.sub("$Date: @file-date-iso@ $", 8, 17)

--[[ Locals ]]--
local _G = _G
local ipairs = _G.ipairs
local find = _G.string.find
local sub = _G.string.gsub
local lower = _G.string.lower
local formatIt = _G.string.format
local friendCache = {}
local repeatdata = {}
local currentFriend
local redirectFrame = L["redirectFrame"]
local debugFrame = L["debugFrame"]
local repeatFrame = L["repeatFrame"]
local lastmsg
local lastuserID
local last_msg = ""

--[[ Database Defaults ]]--
defaults = {
	profile = {
		turnOn = true,
		firstlogin = true,
		redirect = false,
		debug = false,
		filterSAY = false,
		filterYELL = false,
		filterSELF = false,
		filterLFG = false,
		filterGeneral = false,
		filterTrade = true,
		editfilter_enable = false,
		editlists_enable = false,
		repeat_enable = false,
		num_repeats = "2",
		time_repeats = "30",
		repeats_blocked =  0,
		friendslist = {},
		whitelist = {},
		blacklist = {},
		filters = {},
		basefilters = {},
		tradefilters = {},
	},
}

function TF3:OnInitialize()
	--[[ Libraries ]]--
	local ACD = LibStub("AceConfigDialog-3.0")
	local LAP = LibStub("LibAboutPanel")

	self.db = LibStub("AceDB-3.0"):New("TradeFilter3DB", defaults);

	local ACP = LibStub("AceDBOptions-3.0"):GetOptionsTable(TradeFilter3.db);

	local AC = LibStub("AceConsole-3.0")
	AC:RegisterChatCommand("tf", function() TF3:OpenOptions() end)
	AC:RegisterChatCommand("filter", function() TF3:OpenOptions() end)
	AC:Print(L.TOC.Title .. " " .. MAJOR_VERSION .. "." .. MINOR_VERSION .. " " .. L["LOADED"])

	local ACR = LibStub("AceConfigRegistry-3.0")
	ACR:RegisterOptionsTable("TradeFilter3", options)
	ACR:RegisterOptionsTable("TradeFilter3P", ACP)

	-- Set up options panels.
	self.OptionsPanel = ACD:AddToBlizOptions(self.name, L["TFR"], nil, "generalGroup")
	self.OptionsPanel.profiles = ACD:AddToBlizOptions("TradeFilter3P", L["Profiles"], self.name)
	self.OptionsPanel.about = LAP.new(self.name, self.name)
	
	if (TF3.db.profile.firstlogin == true) then
		TF3:FirstLogin()
		TF3.db.profile.firstlogin = false
	end
	
	if IsLoggedIn() then
		self:IsLoggedIn()
	else
		self:RegisterEvent("PLAYER_LOGIN", "IsLoggedIn")
	end
end

-- :OpenOptions(): Opens the options window.
function TF3:OpenOptions()
	InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel.profiles)
	InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel)
end

function TF3:FirstLogin()
	TF3.db.profile.whitelist = L.WHITELIST
	TF3.db.profile.blacklist = L.BLACKLIST
	TF3.db.profile.filters = L.FILTERS
end

function TF3:IsLoggedIn()
	self:RegisterEvent("FRIENDLIST_UPDATE", "GetFriends")
	friends.RegisterCallback(self, "Added")
	friends.RegisterCallback(self, "Removed")
	self:UnregisterEvent("PLAYER_LOGIN")
	self:UnregisterEvent("FRIENDLIST_UPDATE")
end

--[[ Friends Functions - Borrowed from AuldLangSyne Sync module ]]--
function TF3:GetFriends()
	local friends = self.db.profile.friendslist
	local numFriends = GetNumFriends()
	if #friendCache ~= numFriends then
		for i=1, numFriends do
			local name = GetFriendInfo(i)
			if name then
				friends[name] = true
				print(name .. " " .. L["FADD"])
			end
		end
	end
	self:StopGet()
end

function TF3:StopGet()
	for name in pairs(friendCache) do
		friendCache[name] = nil
	end
	currentFriend = nil
end

function TF3:Added(event, name)
	if name ~= UnitName("player") then
		self.db.profile.friendslist[name] = true
		print(name .. " " .. L["FADD"])
	end
	if currentFriend then
		self:GetFriends()
	end
end

function TF3:Removed(event, name)
	if self.db.profile.friendslist[name] ~= nil then
		self.db.profile.friendslist[name] = nil
		print(name .. " " .. L["FREM"])
	end
	if currentFriend then
		self:GetFriends()
	end
end

--[[ IsFriend Func ]]--
function TF3:IsFriend(userID)
	local friends = self.db.profile.friendslist
	for name in pairs(friends) do
		if find(userID,name) then
			return true
		end
	end
	return false
end

--[[ BlackList Func ]]--
--[[ Base blacklist words borrowed from BadBoy(Funkydude) ]]--
function TF3:BlackList(userID, msg)
	local blword = self.db.profile.blacklist
	local msg = lower(msg)
	local msg = sub(msg, " ", "")
	for _,word in pairs(blword) do
		if find(msg,word) then
			--@alpha@
			if (TF3.db.profile.debug) then
				if (msg ~= last_msg) then
					TF3:FindFrame(debugFrame, "|cFFFF0000[" .. L["bLists"] .. "]|r |cFFD9D9D9[" .. userID .. "]:|r |cFFC08080" .. msg .. "|r")
					last_msg = msg
				end
			end
			--@end-alpha@
			return true
		end
	end
	return false
end

--[[ WhiteList Func ]]--
function TF3:WhiteList(userID, msg)
	local wlword = self.db.profile.whitelist
	local msg = lower(msg)
	local msg = sub(msg, " ", "")
	for _,word in pairs(wlword) do
		if find(msg,word) then
			--@alpha@
			if (TF3.db.profile.debug) then
				if (msg ~= last_msg) then
					TF3:FindFrame(debugFrame, "|cFFFFFF80[" .. L["wLists"] .. "]|r |cFFD9D9D9[" .. userID .. "]:|r |cFFC08080" .. msg .. "|r")
					last_msg = msg
				end
			end
			--@end-alpha@
			return true
		end
	end
	return false
end

--[[ Repeat Func ]]--
function TF3:FindRepeat(userID, msg)
	local gtime = math.floor(GetTime()*math.pow(10,0)+0.5) / math.pow(10,0)
	if not repeatdata[userID] then
		repeatdata[userID] = {}
		repeatdata[userID].lastmsg = msg
		repeatdata[userID].lastIndex = 1
		repeatdata[userID].repeats = 0
	else
		if (msg == repeatdata[userID].lastmsg and gtime - repeatdata[userID].lastIndex < tonumber(TF3.db.profile.time_repeats)) then
			repeatdata[userID].repeats = repeatdata[userID].repeats + 1
			if (repeatdata[userID].repeats >= tonumber(TF3.db.profile.num_repeats)) then
				if (TF3.db.profile.debug) then
					if (msg ~= last_msg) then
						TF3:FindFrame(repeatFrame, "|cFFFF8C00[" .. L["#RPT"] .. "]|r |cFFD9D9D9[" .. userID .. "]:|r |cFFC08080" .. msg .. "|r")
						TF3.db.profile.repeats_blocked = TF3.db.profile.repeats_blocked + 1
						last_msg = msg
					end
				else
					if (msg ~= last_msg) then
						TF3.db.profile.repeats_blocked = TF3.db.profile.repeats_blocked + 1
						last_msg = msg
					end
				end
				return true
			end
	  elseif (msg ~= repeatdata[userID].lastmsg) then
	    repeatdata[userID].repeats = 0
	  end
		repeatdata[userID].lastmsg = msg
		repeatdata[userID].lastIndex  = gtime
	end
	return false
end

--[[ Window and Chat Functions ]]--
function TF3:FindFrame(toFrame, msg)
	for i=1,NUM_CHAT_WINDOWS do
		local name = GetChatWindowInfo(i)
		if (toFrame == name) then
			toFrame = _G["ChatFrame" .. i]
			toFrame:AddMessage(msg)
		elseif (toFrame ~= name) then
--~ 			TF3:CreateFrame(toFrame)
		end
	end
end

function TF3:CreateFrame(newFrame)
--~ 	Looking for the proper solution
end

--[[ PreFilter Functions ]]--
--[[----------------------------------------------------------------------------------
Taken from SpamMeNot
			arg1:	chat message
			arg2:	author
			arg7:	zone ID used for generic system channels (1 for General,
					2 for Trade, 22 for LocalDefense, 23 for WorldDefense and
					26 for LFG)	not used for custom channels or if you joined
					an Out-Of-Zone channel ex: "General - Stormwind City"
			arg8:	channel number
	the arguments a1..a9 are all nil until Blizzard actually passes them
	we're expected to use global variables which is generally a bad idea
	global variables may not be available in a later patch so we have to do this:
------------------------------------------------------------------------------------]]

--[[ Check for SAY Channel and User setting ]]--
local function PreFilterFunc_Say(self, event, ...)
	local filtered = false
	local msg = arg1 or select(1, ...)
	local userID = arg2 or select(2, ...)
	if (event == "CHAT_MSG_SAY" and TF3.db.profile.filterSAY and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(userID, msg) == true) then
			filtered = false
		elseif (TF3:BlackList(userID, msg) == true) then
			filtered = true
		elseif (TF3.db.profile.repeat_enable) then
			if (TF3:FindRepeat(userID, msg) == true) then
				filtered = true
			else
				filtered = TF3:FilterFunc(...)
			end
		else
			filtered = TF3:FilterFunc(...)
		end
	else
		filtered = false
	end
	return filtered
end


--[[ Check for YELL Channel and User setting ]]--
local function PreFilterFunc_Yell(self, event, ...)
	local filtered = false
	local msg = arg1 or select(1, ...)
	local userID = arg2 or select(2, ...)
	if (event == "CHAT_MSG_YELL" and TF3.db.profile.filterYELL and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(userID, msg) == true) then
			filtered = false
		elseif (TF3:BlackList(userID, msg) == true) then
			filtered = true
		elseif (TF3.db.profile.repeat_enable) then
			if (TF3:FindRepeat(userID, msg) == true) then
				filtered = true
			else
				filtered = TF3:FilterFunc(...)
			end
		else
			filtered = TF3:FilterFunc(...)
		end
	else
		filtered = false
	end
	return filtered
end

--[[ Check for Trade/General/LFG Channel and User setting ]]--
local function PreFilterFunc(self, event, ...)
	local filtered = false
	local msg = arg1 or select(1, ...)
	local userID = arg2 or select(2, ...)
	local zoneID = arg7 or select(7, ...)
	local chanID = arg8 or select(8, ...)
	--[[ Check for Trade Channel and User setting ]]--
	if (zoneID == 2 and TF3.db.profile.filtertrade and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(userID, msg) == true) then
			filtered = false
		elseif (TF3:BlackList(userID, msg) == true) then
			filtered = true
		elseif (TF3.db.profile.repeat_enable) then
			if (TF3:FindRepeat(userID, msg) == true) then
				filtered = true
			else
				filtered = TF3:FilterFunc(...)
			end
		else
			filtered = TF3:FilterFunc(...)
		end
	elseif (zoneID == 2 and not TF3.db.profile.filterTrade) then
		filtered = false
	end
	--[[ Check for General Channel and User setting ]]--
	if (chanID == 1 and TF3.db.profile.filtergeneral and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(userID, msg) == true) then
			filtered = false
		elseif (TF3:BlackList(userID, msg) == true) then
			filtered = true
		elseif (TF3.db.profile.repeat_enable) then
			if (TF3:FindRepeat(userID, msg) == true) then
				filtered = true
			else
				filtered = TF3:FilterFunc(...)
			end
		else
			filtered = TF3:FilterFunc(...)
		end
	elseif (chanID == 1 and not TF3.db.profile.filterGeneral) then
		filtered = false
	end
	--[[ Check for LFG Channel and User setting ]]--
	if (zoneID == 26 and TF3.db.profile.filterLFG and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(userID, msg) == true) then
			filtered = false
		elseif (TF3:BlackList(userID, msg) == true) then
			filtered = true
		elseif (TF3.db.profile.repeat_enable) then
			if (TF3:FindRepeat(userID, msg) == true) then
				filtered = true
			else
				filtered = TF3:FilterFunc(...)
			end
		else
			filtered = TF3:FilterFunc(...)
		end
	elseif (chanID == 26 and not TF3.db.profile.filterLFG) then
		filtered = false
	end
	return filtered
end

--[[ Filter Func ]]--
function TF3:FilterFunc(...)
	local filterFuncList = ChatFrame_GetMessageEventFilters("CHAT_MSG_CHANNEL")
	local msg = arg1 or select(1, ...)
	local userID = arg2 or select(2, ...)
	local zoneID = arg7 or select(7, ...)
	local chanID = arg8 or select(8, ...)
	local msg = lower(msg)
	if (chanID == 1) then
		chan = "1. " .. L["General"]
	elseif (zoneID == 2) then
		chan = "2. " .. L["Trade"]
	elseif (zoneID == 26) then
		chan = "26. " .. L["LFG"]
	else
		chan = "0. " .. L["Say/Yell"]
	end
	if (filterFuncList and TF3.db.profile.turnOn) then
		filtered = true
		--@alpha@
		if (TF3.db.profile.debug) then
			if (msg ~= last_msg) then
				TF3:FindFrame(debugFrame, "|cFFC08080[" .. chan .. "]|r |cFFD9D9D9[" .. userID .. "]:|r |cFFC08080" .. msg .. "|r")
			end
		end
		--@end-alpha@
		if (zoneID == 2) then
			for i,v in pairs(TF3.db.profile.filters.TRADE) do
				--@alpha@
				if (TF3.db.profile.debug) then
					if (msg ~= last_msg) then
						TF3:FindFrame(debugFrame, L["CFM"] .. " " .. v)
					end
				end
				--@end-alpha@
				if (find(msg,v)) then
					--@alpha@
					if (TF3.db.profile.debug) then
						if (msg ~= last_msg) then
							TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cffff8080" .. v .. "|r")
							last_msg = msg
						end
					end
				--@end-alpha@
					filtered = false
				end
			end
		else
			for i,v in pairs(TF3.db.profile.filters.BASE) do
				--@alpha@
					if (msg ~= last_msg) then
						TF3:FindFrame(debugFrame, L["CFM"] .. " " .. v)
					end
				--@end-alpha@
				if (find(msg,v)) then
					--@alpha@
					if (TF3.db.profile.debug) then
						if (msg ~= last_msg) then
							TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cffff8080" .. v .. "|r")
							last_msg = msg
						end
					end
					--@end-alpha@
					filtered = false
				end
			end
		end
		if (filtered == true) then
			if (lastmsg ~= msg or lastuserID ~= userID) then
				--@alpha@
				if (TF3.db.profile.debug) then
					TF3:FindFrame(debugFrame, L["NOMATCH"])
				end
				--@end-alpha@
				if (TF3.db.profile.redirect) then
					TF3:FindFrame(redirectFrame, "|cFFC08080[" .. chan .. "]|r |cFFD9D9D9[" .. userID .. "]:|r |cFFC08080" .. msg .. "|r")
				end
				lastmsg, lastuserID = msg, userID
				last_msg = msg
			end
		end
	end
	return filtered
end

--[[ Pass ALL chat messages to PreFilter function ]]--
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", PreFilterFunc_Say)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", PreFilterFunc_Yell)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", PreFilterFunc)
