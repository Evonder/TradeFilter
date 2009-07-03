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
local currentFriend
local redirectFrame = "SPAM"
local debugFrame = "DEBUG"
local lastArg1
local lastArg2

--[[ Database Defaults ]]--
defaults = {
	profile = {
		turnOn = true,
		redirect = false,
		debug = false,
		filterSAY = false,
		filterYELL = false,
		filterSELF = false,
		filterLFG = false,
		filterGeneral = false,
		filterTrade = true,
		addfilter_enable = false,
		friendslist = {},
		whitelist = L.WHITELIST,
		blacklist = L.BLACKLIST,
		filter = L.FILTER
	}
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
	AC:Print("|cFF33FF99TradeFilter3|r: " .. MAJOR_VERSION .. "." .. MINOR_VERSION .. " |cff00ff00Loaded!|r")

	local ACR = LibStub("AceConfigRegistry-3.0")
	ACR:RegisterOptionsTable("TradeFilter3", options)
	ACR:RegisterOptionsTable("TradeFilter3P", ACP)

	-- Set up options panels.
	self.OptionsPanel = ACD:AddToBlizOptions(self.name, L["TFR"], nil, "generalGroup")
	self.OptionsPanel.profiles = ACD:AddToBlizOptions("TradeFilter3P", L["Profiles"], self.name)
	self.OptionsPanel.about = LAP.new(self.name, self.name)
	
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

function TF3:IsLoggedIn()
self:RegisterEvent("FRIENDLIST_UPDATE", "GetFriends")
friends.RegisterCallback(self, "Added")
friends.RegisterCallback(self, "Removed")
self:UnregisterEvent("PLAYER_LOGIN")
end

--[[ Friends Functions - Stolen from AuldLangSyne Sync module ]]--
function TF3:GetFriends()
	local friends = self.db.profile.friendslist
	local numFriends = GetNumFriends()
	if #friendCache ~= numFriends then
		for i=1, numFriends do
			local name = GetFriendInfo(i)
			if name then
				friends[name] = true
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
	end
	if currentFriend then
		self:GetFriends()
	end
end

function TF3:Removed(event, name)
	if self.db.profile.friendslist[name] ~= nil then
		self.db.profile.friendslist[name] = nil
	end
	if currentFriend then
		self:GetFriends()
	end
end

--[[ IsFriend Func ]]--
function TF3:IsFriend(userID)
	local friends = self.db.profile.friendslist
	for name in pairs(friends) do
		if (userID == name) then
			return true
		end
	end
	return false
end

--[[ BlackList Func ]]--
--[[ Base blacklist words stolen from BadBoy(Funkydude) ]]--
function TF3:BlackList(msg)
	local blword = self.db.profile.blacklist
	local msg = lower(msg) --lower all text
	local msg = sub(msg, " ", "") --Remove spaces
	for _,word in pairs(blword) do
		if find(msg,word) then
			return true -- if msg contains a blword then return true
		end
	end
	return false
end

--[[ WhiteList Func ]]--
function TF3:WhiteList(msg)
	local wlword = self.db.profile.whitelist
	local msg = lower(msg) --lower all text
	local msg = sub(msg, " ", "") --Remove spaces
	for _,word in pairs(wlword) do
		if find(msg,word) then
			return true -- if msg contains a wlword then return true
		end
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
		else
			--TF3:CreateFrame(toFrame)
		end
	end
end

function TF3:CreateFrame(newFrame)
	--Need to find the proper way to create a new chatframe that is docked to the default frame
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
	if (TF3.db.profile.filterSAY and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg) == true) then
			filtered = false
		elseif (TF3:BlackList(msg) == true) then
			filtered = true
		else
			filtered = TF3:FilterFunc(...)
		end
	elseif (event == "CHAT_MSG_SAY" and not TF3.db.profile.filterSAY) then
		filtered = false
	end
	return filtered
end

--[[ Check for SAY Channel and User setting ]]--
local function PreFilterFunc_Yell(self, event, ...)
	local filtered = false
	local msg = arg1 or select(1, ...)
	local userID = arg2 or select(2, ...)
	if (TF3.db.profile.filterYELL and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg) == true) then
			filtered = false
		elseif (TF3:BlackList(msg) == true) then
			filtered = true
		else
			filtered = TF3:FilterFunc(...)
		end
	elseif (event == "CHAT_MSG_YELL" and not TF3.db.profile.filterYELL) then
		filtered = false
	end
	return filtered
end

local function PreFilterFunc(self, event, ...)
	local filtered = false
	local msg = arg1 or select(1, ...)
	local userID = arg2 or select(2, ...)
	local zoneID = arg7 or select(7, ...)
	local chanID = arg8 or select(8, ...)
	--[[ Check for Trade Channel and User setting ]]--
	if (zoneID == 2 and TF3.db.profile.filtertrade and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg) == true) then
			filtered = false
		elseif (TF3:BlackList(msg) == true) then
			filtered = true
		else
			filtered = TF3:FilterFunc(...)
		end
	elseif (zoneID == 2 and not TF3.db.profile.filtertrade) then
		filtered = false
	end
	--[[ Check for General Channel and User setting ]]--
	if (chanID == 1 and TF3.db.profile.filtergeneral and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg) == true) then
			filtered = false
		elseif (TF3:BlackList(msg) == true) then
			filtered = true
		else
			filtered = TF3:FilterFunc(...)
		end
	elseif (chanID == 1 and not TF3.db.profile.filtergeneral) then
		filtered = false
	end
	--[[ Check for LFG Channel and User setting ]]--
	if (zoneID == 26 and TF3.db.profile.filterLFG and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg) == true) then
			filtered = false
		elseif (TF3:BlackList(msg) == true) then
			filtered = true
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
	if (arg8 == 1) then
		chan = "1. General"
	elseif (arg7 == 2) then
		chan = "2. Trade"
	elseif (arg7 == 26) then
		chan = "26. LFG"
	else
		chan = "0. Say/Yell"
	end
	local arg1 = lower(arg1)
	if (filterFuncList and self.db.profile.turnOn) then
		filtered = true
		--@alpha@
		if (self.db.profile.debug) then
			TF3:FindFrame(debugFrame, "arg1: " .. arg1 .. " arg2: " .. arg2)
		end
		--@end-alpha@
		for i,v in pairs(self.db.profile.filter) do
			--@alpha@
			if (self.db.profile.debug) then
				TF3:FindFrame(debugFrame, "Checking for Match with " .. v)
			end
			--@end-alpha@
			if (find(arg1,v)) then
				--@alpha@
				if (self.db.profile.debug) then
					TF3:FindFrame(debugFrame, "|cff00ff00**** Matched ***|r")
				end
				--@end-alpha@
			filtered = false
			end
		end
		if (filtered == true) then
			if (lastArg1 ~= arg1 or lastArg2 ~= arg2) then
				--@alpha@
				if (self.db.profile.debug) then
					TF3:FindFrame(debugFrame, "|cff00ff00*** NO Match - Redirected ***|r")
				end
				--@end-alpha@
				if (self.db.profile.redirect) then
					TF3:FindFrame(redirectFrame, "|cFFC08080[" .. chan .. "]|r |cFFD9D9D9[" .. arg2 .. "]:|r |cFFC08080" .. arg1 .. "|r")
				end
				lastArg1, lastArg2 = arg1, arg2
			end
		end
	end
	return filtered
end

--[[ Pass ALL chat messages to PreFilter function ]]--
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", PreFilterFunc_Say)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", PreFilterFunc_Yell)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", PreFilterFunc)
