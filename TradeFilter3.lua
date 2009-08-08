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

TradeFilter3 = LibStub("AceAddon-3.0"):NewAddon("TradeFilter3", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L =  LibStub("AceLocale-3.0"):GetLocale("TradeFilter3", true)
local friends = LibStub("LibFriends-1.0")
local LDB = LibStub("LibDataBroker-1.1")
local TF3 = TradeFilter3

local MAJOR_VERSION = "3.0"
local MINOR_VERSION = 000 + tonumber(("$Revision: @project-revision@ $"):match("%d+"))
TF3.version = MAJOR_VERSION .. "." .. MINOR_VERSION
TF3.date = string.sub("$Date: @file-date-iso@ $", 8, 17)

--[[ Locals ]]--
local ipairs = ipairs
local pairs = pairs
local find = string.find
local sub = string.gsub
local lower = string.lower
local formatIt = string.format
local insert = table.insert
local sort = table.sort
local timerCount = 0
local repeatdata = {}
local currentFriend
local redirectFrame = L["redirectFrame"]
local debugFrame = L["debugFrame"]
local repeatFrame = L["repeatFrame"]
local lastmsgID
local lastmsg
local lastuserID

--[[ Database Defaults ]]--
defaults = {
	profile = {
		turnOn = true,
		firstlogin = true,
		redirect = false,
		debug = false,
		filterSAY = false,
		filterYELL = false,
		filterGAC = false,
		filterSELF = false,
		filterLFG = false,
		filterGeneral = false,
		filterTrade = true,
		editfilter_enable = false,
		ebl = false,
		ewl = false,
		blacklist_enable = true,
		whitelist_enable = true,
		redirect_blacklist = false,
		wlbp = false,
		wlblbp = false,
		repeat_enable = true,
		special_enable = false,
		num_repeats = "2",
		time_repeats = "30",
		repeats_blocked =  0,
		friendslist = {},
		whitelist = {},
		blacklist = {},
		filters = {},
		basefilters = {},
		tradefilters = {},
		specialfilters = {},
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

local function OnTooltipShow(self)
	self:AddLine("|cffeda55fRight Click|r to open config GUI")
	self:AddLine("|cffeda55fLeft Click|r reset repeat count")
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()
	OnTooltipShow(GameTooltip)
	GameTooltip:Show()
end

local function OnLeave(self)
	GameTooltip:Hide()
end

local function OnClick(clickedframe, button)
	if (button == "RightButton") then
		TF3:OpenOptions()
	else
		TF3.db.profile.repeats_blocked = 0
		TF3Frame.Blocked.text = TF3.db.profile.repeats_blocked .. "Repeats Blocked"
		TF3Frame.Blocked.value = TF3.db.profile.repeats_blocked
	end
end

function TF3:IsLoggedIn()
	self:RegisterEvent("FRIENDLIST_UPDATE", "GetFriends")
	friends.RegisterCallback(self, "Added")
	friends.RegisterCallback(self, "Removed")
	self:ScheduleRepeatingTimer("RecycleTables", 1800, repeatdata)
	self:UnregisterEvent("PLAYER_LOGIN")
	
	if (LDB) then
		TF3Frame = CreateFrame("Frame", "LDB_TradeFilter3")
		TF3Frame.Blocked = LDB:NewDataObject(L["TFR"], {
			type = "data source",
			text = "0 Blocked Repeats",
			value = TF3.db.profile.repeats_blocked,
			suffix = "Repeats Blocked",
			OnClick = OnClick,
			OnEnter = OnEnter,
			OnLeave = OnLeave,
			OnTooltipShow = OnTooltipShow,
		})
	end
end

--[[ Helper Functions ]]--
function TF3:WipeTable(t)
	if (t ~= nil and type(t) == "table") then
		wipe(t)
	end
end

function TF3:CopyTable(t)
  local new_t = {}
  for k, v in pairs(t) do
    if (type(v) == "table") then
      new_t[k] = TF3:CopyTable(v)
    else
			new_t[k] = v
    end
  end
  return new_t
end

function TF3:GetNumElements(t)
 local count = 0
 for _ in pairs(t) do
  count = count + 1
 end
 return count
end

function TF3:RecycleTables(t, state)
	local gtime = math.floor(GetTime()*math.pow(10,0)+0.5) / math.pow(10,0)
	if (t ~= nil and type(t) == "table" and TF3:GetNumElements(t) >= 100) then
		local key, value = next(t, state)
		if key then
			for k,v in pairs(value) do
				if(k == "lastIndex" and gtime - v > 1800) then
					if (TF3.db.profile.debug) then
						TF3:FindFrame(debugFrame, "|cFFFFFF80" .. L["RMVRT1"] .. "|r |cFF33FF99" .. key .. "|r |cFFFFFF80" .. L["RMVRT2"] .. "|r")
					end
					t[key] = nil
				end
			end
			return value, TF3:RecycleTables(t, key)
		end
		timerCount = timerCount + 1
		if (TF3.db.profile.debug) then
			TF3:FindFrame(debugFrame, ("%d " .. L["SECPSD"]):format(1800 * timerCount))
		end
	end
end

--[[ Friends Functions ]]--
function TF3:GetFriends()
	local friends = TF3.db.profile.friendslist
	local numFriends = GetNumFriends()
	if (#friends ~= numFriends) then
		print("|cFF33FF99" .. L["TFFR"] .. "|r")
		TF3:WipeTable(friends)
		for i=1, numFriends do
			local name = GetFriendInfo(i)
			if name then
				friends[i] = name
				print("|cFFFFFF80" .. name .. " " .. L["FADD"] .. "|r")
			end
		end
	end
	self:UnregisterEvent("FRIENDLIST_UPDATE")
end

function TF3:Added(event, name)
	local friends = TF3.db.profile.friendslist
	if name ~= UnitName("player") then
		friends[#friends + 1] = name
		if (TF3.db.profile.debug) then
			TF3:FindFrame(debugFrame, "|cFFFFFF80" .. name .. " " .. L["FADD"] .. "|r")
		end
	end
	if currentFriend then
		self:GetFriends()
	end
end

function TF3:Removed(event, name)
	local friends = TF3.db.profile.friendslist
	if friends ~= nil then
		for k,v in ipairs(friends) do
			if find(name,v) then
				friends[k] = nil
				if (TF3.db.profile.debug) then
					TF3:FindFrame(debugFrame, "|cFFFFFF80" .. name .. " " .. L["FREM"] .. "|r")
				end
			end
		end
	end
	if currentFriend then
		self:GetFriends()
	end
end

function TF3:IsFriend(userID)
	local friends = TF3.db.profile.friendslist
	for _,name in ipairs(friends) do
		if find(userID,name) then
			return true
		end
	end
	return false
end

--[[ BlackList Func ]]--
--[[ Base blacklist words from BadBoy(Funkydude) ]]--
function TF3:BlackList(msg, userID, msgID, arg)
	local blword = TF3.db.profile.blacklist
	local msg = lower(msg)
	if (arg == whitelist and TF3.db.profile.wlblbp == true) then
		return false
	else
		if (TF3.db.profile.blacklist_enable) then
			for _,word in pairs(blword) do
				if (find(msg,word)) then
					if (TF3.db.profile.debug) then
						if (msgID ~= lastmsgID) then
							TF3:FindFrame(debugFrame, "|cFFFF0000[" .. L["bLists"] .. "]|r |cFFD9D9D9[" .. userID .. "]:|r |cFFC08080" .. msg .. "|r")
							TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cFFFF0000" .. word .. "|r")
							if not (TF3.db.profile.redirect_blacklist) then
								lastmsgID = msgID
							end
						end
					end
					if (TF3.db.profile.redirect_blacklist) then
						if (msgID ~= lastmsgID) then
							TF3:FindFrame(redirectFrame, "|cFFFF0000[" .. L["bLists"] .. "]|r |cFFD9D9D9[" .. userID .. "]:|r |cFFC08080" .. msg .. "|r")
							TF3:FindFrame(redirectFrame, L["MATCHED"] .. " |cFFFF0000" .. word .. "|r")
							lastmsgID = msgID
						end
					end
					return true
				end
			end
		end
		return false
	end
end

--[[ WhiteList Func ]]--
function TF3:WhiteList(msg, userID, msgID)
	local wlword = TF3.db.profile.whitelist
	local msg = lower(msg)
	if (TF3.db.profile.whitelist_enable) then
		for _,word in pairs(wlword) do
			if (find(msg,word) and TF3:FindRepeat(msg, userID, msgID, whitelist) == false and TF3:BlackList(msg, userID, msgID, whitelist) == false) then
				if (TF3.db.profile.debug) then
					if (msgID ~= lastmsgID) then
						TF3:FindFrame(debugFrame, "|cFFFFFF80[" .. L["wLists"] .. "]|r |cFFD9D9D9[" .. userID .. "]:|r |cFFC08080" .. msg .. "|r")
						TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cFFFFFF80" .. word .. "|r")
						lastmsgID = msgID
					end
				end
				return true
			end
		end
	end
	return false
end

--[[ Special Channels Func ]]--
function TF3:SpecialChans(chanName)
	local schans = TF3.db.profile.filters.SPECIAL
	if (schans == nil) then
		schans = L.FILTERS.SPECIAL
	end
	local chanName = lower(chanName)
	for _,names in pairs(schans) do
		if (find(chanName,names) and names ~= "") then
			return true
		end
	end
	return false
end

--[[ Repeat Func ]]--
function TF3:FindRepeat(msg, userID, msgID, arg)
	local gtime = math.floor(GetTime()*math.pow(10,0)+0.5) / math.pow(10,0)
	if (arg == whitelist and TF3.db.profile.wlbp == true) then
		return false
	elseif (TF3.db.profile.repeat_enable == false) then
		return false
	else
		if (msgID ~= repeatdata[userID].lastmsgID and msg == repeatdata[userID].lastmsg and gtime - repeatdata[userID].lastIndex < tonumber(TF3.db.profile.time_repeats)) then
			repeatdata[userID].repeats = repeatdata[userID].repeats + 1
			if (repeatdata[userID].repeats >= tonumber(TF3.db.profile.num_repeats)) then
				if (TF3.db.profile.debug) then
					if (msg ~= lastmsg) then
						TF3:FindFrame(repeatFrame, "|cFFFF8C00[" .. L["#RPT"] .. "]|r |cFFD9D9D9[" .. msgID .. "]|r |cFFD9D9D9[" .. userID .. "]:|r |cFFC08080" .. msg .. "|r")
						TF3.db.profile.repeats_blocked = TF3.db.profile.repeats_blocked + 1
						if (LDB) then
							TF3Frame.Blocked.text = TF3.db.profile.repeats_blocked .. "Repeats Blocked"
							TF3Frame.Blocked.value = TF3.db.profile.repeats_blocked
						end
						lastmsg = msg
					end
				end	
				return true
			end
		elseif (msg ~= repeatdata[userID].lastmsg) then
			repeatdata[userID].repeats = 1
		end
		repeatdata[userID].lastmsg = msg
		repeatdata[userID].lastmsgID = msgID
		repeatdata[userID].lastIndex  = gtime
		return false
	end
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

--[[ Check for AddOn Channel and User setting ]]--
local function PreFilterFunc_Addon(self, event, ...)
	local filtered = false
	local prefix = arg1 or select(1, ...)
	local msg = arg2 or select(2, ...)
	local distType = arg3 or select(3, ...)
	local userID = arg4 or select(4, ...)
	if not (repeatdata[userID]) then
		repeatdata[userID] = {}
		repeatdata[userID].lastmsg = msg
		repeatdata[userID].lastmsgID = msgID
		repeatdata[userID].lastIndex = 1
		repeatdata[userID].repeats = 1
	end
	if (distType == "GUILD" and find(prefix,"ET") and TF3.db.profile.filterGAC and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID) == true) then
			filtered = false
		elseif (TF3:BlackList(msg, userID) == true) then
			filtered = true
		elseif (TF3.db.profile.repeat_enable) then
			if (TF3:FindRepeat(msg, userID) == true) then
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

--[[ Check for SAY Channel and User setting ]]--
local function PreFilterFunc_Say(self, event, ...)
	local filtered = false
	local msg = arg1 or select(1, ...)
	local userID = arg2 or select(2, ...)
	local chanName = arg9 or select(9, ...)
	local msgID = arg11 or select(11, ...)
	if not (repeatdata[userID]) then
		repeatdata[userID] = {}
		repeatdata[userID].lastmsg = msg
		repeatdata[userID].lastmsgID = msgID
		repeatdata[userID].lastIndex = 1
		repeatdata[userID].repeats = 1
	end
	if (event == "CHAT_MSG_SAY" and TF3.db.profile.filterSAY and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID) == true) then
			filtered = false
		elseif (TF3:BlackList(msg, userID, msgID) == true) then
			filtered = true
		elseif (TF3.db.profile.repeat_enable) then
			if (TF3:FindRepeat(msg, userID, msgID) == true) then
				filtered = true
			else
				filtered = TF3:FilterFunc(...)
			end
		else
			filtered = TF3:FilterFunc(...)
		end
	elseif (event == "CHAT_MSG_SAY" and not TF3.db.profile.filterSAY) then
		filtered = false
	end
	return filtered
end

--[[ Check for YELL Channel and User setting ]]--
local function PreFilterFunc_Yell(self, event, ...)
	local filtered = false
	local msg = arg1 or select(1, ...)
	local userID = arg2 or select(2, ...)
	local msgID = arg11 or select(11, ...)
	if not (repeatdata[userID]) then
		repeatdata[userID] = {}
		repeatdata[userID].lastmsg = msg
		repeatdata[userID].lastmsgID = msgID
		repeatdata[userID].lastIndex = 1
		repeatdata[userID].repeats = 1
	end
	if (event == "CHAT_MSG_YELL" and TF3.db.profile.filterYELL and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID) == true) then
			filtered = false
		elseif (TF3:BlackList(msg, userID, msgID) == true) then
			filtered = true
		elseif (TF3.db.profile.repeat_enable) then
			if (TF3:FindRepeat(msg, userID, msgID) == true) then
				filtered = true
			else
				filtered = TF3:FilterFunc(...)
			end
		else
			filtered = TF3:FilterFunc(...)
		end
	elseif (event == "CHAT_MSG_YELL" and not TF3.db.profile.filterYELL) then
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
	local chanName = arg9 or select(9, ...)
	local msgID = arg11 or select(11, ...)
	if not (repeatdata[userID]) then
		repeatdata[userID] = {}
		repeatdata[userID].lastmsg = msg
		repeatdata[userID].lastmsgID = msgID
		repeatdata[userID].lastIndex = 1
		repeatdata[userID].repeats = 1
	end
	--[[ Check for Trade Channel and User setting ]]--
	if (zoneID == 2 and TF3.db.profile.filtertrade and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID) == true) then
			filtered = false
		elseif (TF3:BlackList(msg, userID, msgID) == true) then
			filtered = true
		elseif (TF3.db.profile.repeat_enable) then
			if (TF3:FindRepeat(msg, userID, msgID) == true) then
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
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID) == true) then
			filtered = false
		elseif (TF3:BlackList(msg, userID, msgID) == true) then
			filtered = true
		elseif (TF3.db.profile.repeat_enable) then
			if (TF3:FindRepeat(msg, userID, msgID) == true) then
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
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID) == true) then
			filtered = false
		elseif (TF3:BlackList(msg, userID, msgID) == true) then
			filtered = true
		elseif (TF3.db.profile.repeat_enable) then
			if (TF3:FindRepeat(msg, userID, msgID) == true) then
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
	--[[ Check for Special Channel and User setting ]]--
	if (TF3:SpecialChans(chanName) == true and TF3.db.profile.special_enable and TF3:IsFriend(userID) == false) then
		if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID) == true) then
			filtered = false
		elseif (TF3:BlackList(msg, userID, msgID) == true) then
			filtered = true
		elseif (TF3.db.profile.repeat_enable) then
			if (TF3:FindRepeat(msg, userID, msgID) == true) then
				filtered = true
			else
				filtered = TF3:FilterFunc(...)
			end
		else
			filtered = TF3:FilterFunc(...)
		end
	elseif (TF3:SpecialChans(chanName) == true and not TF3.db.profile.special_enable) then
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
	local chanName = arg9 or select(9, ...)
	local msgID = arg11 or select(11, ...)
	local msg = lower(msg)
	if (chanID == 1) then
		chan = "1. " .. L["General"]
	elseif (zoneID == 2) then
		chan = "2. " .. L["Trade"]
	elseif (zoneID == 26) then
		chan = "26. " .. L["LFG"]
	elseif (TF3:SpecialChans(chanName) == true) then
		chan = "X. Special Channel"
	else
		chan = "0. " .. L["Say/Yell"]
	end
	if (filterFuncList and TF3.db.profile.turnOn) then
		filtered = true
		if (TF3.db.profile.debug) then
			if (lastmsg ~= msg or lastuserID ~= userID) then
				TF3:FindFrame(debugFrame, "|cFFC08080[" .. chan .. "]|r |cFFD9D9D9[" .. msgID .. "]|r |cFFD9D9D9[" .. userID .. "]:|r |cFFC08080" .. msg .. "|r")
			end
		end
		if (zoneID == 2) then
			if (TF3.db.profile.filters.TRADE == nil) then
				TF3.db.profile.filters.TRADE = L.FILTERS.TRADE
			end
			for k,v in pairs(TF3.db.profile.filters.TRADE) do
				if (TF3.db.profile.debug and not TF3.db.profile.debug_checking) then
					if (lastmsg ~= msg or lastuserID ~= userID) then
						TF3:FindFrame(debugFrame, L["CFM"] .. " " .. v)
					end
				end
				if (find(msg,v)) then
					if (TF3.db.profile.debug) then
						if (lastmsg ~= msg or lastuserID ~= userID) then
							TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cffff8080" .. v .. "|r")
							lastmsg, lastuserID = msg, userID
						end
					end
					filtered = false
				end
			end
		else
			if (TF3.db.profile.filters.BASE == nil) then
				TF3.db.profile.filters.BASE = L.FILTERS.BASE
			end
			for k,v in pairs(TF3.db.profile.filters.BASE) do
				if (TF3.db.profile.debug and not TF3.db.profile.debug_checking) then
					if (lastmsg ~= msg or lastuserID ~= userID) then
						TF3:FindFrame(debugFrame, L["CFM"] .. " " .. v)
					end
				end
				if (find(msg,v)) then
					if (TF3.db.profile.debug) then
						if (lastmsg ~= msg or lastuserID ~= userID) then
							TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cffff8080" .. v .. "|r")
							lastmsg, lastuserID = msg, userID
						end
					end
					filtered = false
					end
				end
			end
		if (filtered == true) then
			if (lastmsg ~= msg or lastuserID ~= userID) then
				if (TF3.db.profile.debug) then
					TF3:FindFrame(debugFrame, L["NOMATCH"])
				end
				if (TF3.db.profile.redirect) then
					TF3:FindFrame(redirectFrame, "|cFFC08080[" .. chan .. "]|r |cFFD9D9D9[" .. msgID .. "]|r |cFFD9D9D9[" .. userID .. "]:|r |cFFC08080" .. msg .. "|r")
				end
				lastmsg, lastuserID = msg, userID
			end
		end
	end
	return filtered
end

--[[ Pass ALL chat messages to PreFilter function ]]--
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", PreFilterFunc_Say)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", PreFilterFunc_Yell)
ChatFrame_AddMessageEventFilter("CHAT_MSG_ADDON", PreFilterFunc_Addon)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", PreFilterFunc)
