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
		filterLFG = false,
		filterGeneral = false,
		filterTrade = true,
		addfilter_enable = false,
		friendslist = {},
		filter = {
			"CUSTOM FILTER 1",
			"CUSTOM FILTER 2",
			"CUSTOM FILTER 3",
			"[lL][fF] [pP][oO][rR][tT]",
			"[bB][uU][yY][iI][nN][gG]",
			"[wW][tT][bBsStT]",
			"[lL][fF][wWeEmM]",
			"[lL][fF] [eE][nN][cC][hH][aA][nN][tT]",
			"[lL][fF] [jJ][cC]",
			"[lL][fF] [dD][pP][sS]",
			"[lL][fF] [tT][aA][nN][kK]",
			"[lL][fF] [hH][eE][aA][lL][eE][rR]",
			"[lL][fF]%d[mM]?",
			"[lL][fF][mM]?",
			"[lL][fF][gG]",
			"AH",
			"looking for work",
			"lockpick",
			"[sS][eE][lL][lL][iI][nN][gG]",
			"[bB][uU][yY][iI][nN][gG]",
			"2[vV]2",
			"3[vV]3",
			"5[vV]5",
		},
	}
}

function TF3:OnInitialize()
	--[[ Libraries ]]--
	local L =  LibStub("AceLocale-3.0"):GetLocale("TradeFilter3")
	local ACD = LibStub("AceConfigDialog-3.0")
	local LAP = LibStub("LibAboutPanel")

	self.db = LibStub("AceDB-3.0"):New("TradeFilter3DB", defaults);

	local ACP = LibStub("AceDBOptions-3.0"):GetOptionsTable(TradeFilter3.db);

	local AC = LibStub("AceConsole-3.0")
	AC:RegisterChatCommand("filter", function() TF3:OpenOptions() end)
	AC:RegisterChatCommand("tradefilter", function() TF3:OpenOptions() end)
	AC:Print("|cFF33FF99TradeFilter3|r: " .. MAJOR_VERSION .. "." .. MINOR_VERSION .. " |cff00ff00Loaded!|r")

	local ACR = LibStub("AceConfigRegistry-3.0")
	ACR:RegisterOptionsTable("TradeFilter3", options)
	ACR:RegisterOptionsTable("TradeFilter3P", ACP)

	-- Set up options panels.
	self.OptionsPanel = ACD:AddToBlizOptions(self.name, L["TFR"], nil, "generalGroup")
	self.OptionsPanel.channel = ACD:AddToBlizOptions(self.name, L["channelGroup"], self.name, "channelGroup")
	self.OptionsPanel.custom = ACD:AddToBlizOptions(self.name, L["addFilterGroup"], self.name, "addFilterGroup")
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

--[[ PreFilter ]]--
local function PreFilterFunc(...)
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
	local filtered = false
	local userID = arg2 or select(2, ...)
	local zoneID = arg7 or select(7, ...)
	local chanID = arg8 or select(8, ...)
	--[[ Check for Trade Channel and User setting ]]--
	if (zoneID == 2 and TF3.db.profile.filtertrade and userID ~= UnitName("Player") and TF3:IsFriend(userID) == false) then
		filtered = TF3:FilterFunc()
	elseif (zoneID == 2 and not TF3.db.profile.filtertrade) then
		filtered = false
	end
	--[[ Check for General Channel and User setting ]]--
	if (chanID == 1 and TF3.db.profile.filtergeneral and userID ~= UnitName("Player") and TF3:IsFriend(userID) == false) then
		filtered = TF3:FilterFunc()
	elseif (chanID == 1 and not TF3.db.profile.filtergeneral) then
		filtered = false
	end
	--[[ Check for LFG Channel and User setting ]]--
	if (zoneID == 26 and TF3.db.profile.filterLFG and userID ~= UnitName("Player") and TF3:IsFriend(userID) == false) then
		filtered = TF3:FilterFunc()
	elseif (chanID == 26 and not TF3.db.profile.filterLFG) then
		filtered = false
	end
	--[[ Check for SAY Channel and User setting ]]--
	if (event == "CHAT_MSG_SAY" and TF3.db.profile.filterSAY and userID ~= UnitName("Player") and TF3:IsFriend(userID) == false) then
		filtered = TF3:FilterFunc()
	elseif (event == "CHAT_MSG_SAY" and not TF3.db.profile.filterSAY) then
		filtered = false
	end
	--[[ Check for YELL Channel and User setting ]]--
	if (event == "CHAT_MSG_YELL" and TF3.db.profile.filterYELL and userID ~= UnitName("Player") and TF3:IsFriend(userID) == false) then
		filtered = TF3:FilterFunc()
	elseif (event == "CHAT_MSG_YELL" and not TF3.db.profile.filterYELL) then
		filtered = false
	end
	return filtered
end

--[[ Filter Func ]]--
function TF3:FilterFunc(...)
	local filterFuncList = ChatFrame_GetMessageEventFilters("CHAT_MSG_CHANNEL")
	local arg1 = lower(arg1)
	if (filterFuncList and self.db.profile.turnOn) then
		filtered = true
		--@alpha@
		if (self.db.profile.debug) then
			TF3:FindFrame(debugFrame, "arg1: " .. arg1 .. " arg2: " .. arg2)
		end
		--@end-alpha@
		if (self.db.profile.addfilter_enable) then
			for i, matchIt in ipairs(self.db.profile.filter) do
				--@alpha@
				if (self.db.profile.debug) then
					TF3:FindFrame(debugFrame, "Checking for Match with " .. matchIt)
				end
				--@end-alpha@
				if (find(arg1, matchIt)) then
					--@alpha@
					if (self.db.profile.debug) then
						TF3:FindFrame(debugFrame, "|cff00ff00**** Matched ***|r")
					end
					--@end-alpha@
				filtered = false
				end
			end
		else
			for i=4,#self.db.profile.filter do
				--@alpha@
				if (self.db.profile.debug) then
					TF3:FindFrame(debugFrame, "Checking for Match with " .. self.db.profile.filter[i])
				end
				--@end-alpha@
				if (find(arg1, self.db.profile.filter[i])) then
					--@alpha@
					if (self.db.profile.debug) then
						TF3:FindFrame(debugFrame, "|cff00ff00**** Matched ***|r")
					end
					--@end-alpha@
				filtered = false
				end
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
					TF3:FindFrame(redirectFrame, "zID:" .. formatIt(CHAT_CHANNEL_GET, arg7) .. " cID:" .. formatIt(CHAT_CHANNEL_GET, arg8) .. " - " .. formatIt(CHAT_CHANNEL_GET, arg2) .. arg1)
				end
				lastArg1, lastArg2 = arg1, arg2
			end
		end
	end
	return filtered
end

--[[ Pass ALL chat messages to PreFilter function ]]--
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", PreFilterFunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", PreFilterFunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", PreFilterFunc)
