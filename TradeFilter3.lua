--[[
TradeFilter3
		Filter that shit!

File Author: @file-author@
File Revision: @file-abbreviated-hash@
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
local LDB = LibStub("LibDataBroker-1.1", true)
local TF3 = TradeFilter3

--[[ Locals ]]--
local ipairs = ipairs
local pairs = pairs
local find = string.find
local sub = string.sub
local gsub = string.gsub
local lower = string.lower
local format = string.format
local insert = table.insert
local sort = table.sort
local floor = math.floor
local power = math.pow
local timerCount = 0
local currentFriend
local redirectFrame = L["redirectFrame"]
local debugFrame = L["debugFrame"]
local repeatFrame = L["repeatFrame"]
local lastmsgID
local lastmsg
local rptmsg
local rptmsgID
local lastuserID
local rptdone

TF3.repeatdata = {}
TF3.currentPartyMembers = {}

local MAJOR_VERSION = "@project-version@"
if (find(MAJOR_VERSION, "release" or "beta")) then
	TF3.version = MAJOR_VERSION
else
	TF3.version = MAJOR_VERSION .. " DEV"
end
TF3.date = "@file-date-iso@"

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
		filterBG = false,
		filterGeneral = false,
		filterTrade = true,
		editfilterTRADE_enable = false,
		editfilterBASE_enable = false,
		editfilterBG_enable = false,
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
		repeat_recycle_time = "1800",
		repeat_recycle_size = "50",
		repeats_blocked =  0,
		friendslist = {},
		whitelist = {},
		blacklist = {},
		filters = {},
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
	AC:Print(L.TOC.Title .. " " .. TF3.version .. " " .. L["ENABLED"])

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
	local hint = L["|cffeda55fRight Click|r to open config GUI.\n|cffeda55fLeft Click|r reset repeat count."]
	self:AddLine(TF3.db.profile.repeats_blocked .. L[" Repeats Blocked"])
	self:AddLine(" ")
	self:AddLine(hint, 0.2, 1, 0.2, 1)
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
		TF3Frame.Blocked.text = TF3.db.profile.repeats_blocked .. L[" Repeats Blocked"]
		TF3Frame.Blocked.value = TF3.db.profile.repeats_blocked
	end
end

function TF3:IsLoggedIn()
	self:RegisterEvent("FRIENDLIST_UPDATE", "GetFriends")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "GetParty")
	friends.RegisterCallback(self, "Added")
	friends.RegisterCallback(self, "Removed")
	self:ScheduleRepeatingTimer("RecycleTables", tonumber(TF3.db.profile.repeat_recycle_time), TF3.repeatdata)
	self:UnregisterEvent("PLAYER_LOGIN")
	TF3:DuelFilter()
	
	if (LDB) then
		TF3Frame = CreateFrame("Frame", "LDB_TradeFilter3")
		TF3Frame.Blocked = LDB:NewDataObject(L["TFR"], {
			type = "data source",
			icon = "Interface\\Icons\\Ability_Warrior_RallyingCry",
			text = L["0 Repeats Blocked"],
			value = TF3.db.profile.repeats_blocked,
			suffix = L[" Repeats Blocked"],
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
	if not (t or type(t) ~= "table") then
		return 0
	end
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

function TF3:RecycleTables(t, state)
	local gtime = floor(GetTime()*power(10,0)+0.5) / power(10,0)
	if (t ~= nil and type(t) == "table" and TF3:GetNumElements(t) >= tonumber(TF3.db.profile.repeat_recycle_size)) then
		local key, value = next(t, state)
		if key then
			for k,v in pairs(value) do
				if(k == "lastIndex" and gtime - v > tonumber(TF3.db.profile.repeat_recycle_time)) then
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
			TF3:FindFrame(debugFrame, ("%d " .. L["SECPSD"]):format(tonumber(TF3.db.profile.repeat_recycle_time) * timerCount))
		end
	end
end

function TF3:GetColoredName(userID, cName)
	if (cName ~= "") then
		local localizedClass, englishClass, localizedRace, englishRace, sex = GetPlayerInfoByGUID(cName)
		if (englishClass) then
			local classColorTable = RAID_CLASS_COLORS[englishClass]
			if (not classColorTable) then
				return userID;
			end
				return string.format("\124cff%.2x%.2x%.2x", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255)..userID.."\124r"
		end
	end
	return userID;
end

--[[ Party Functions ]]--
function TF3:GetParty()
	local currentParty = TF3.currentPartyMembers
	local numPartyMembers = GetNumPartyMembers()
	local numRaidMembers = GetNumRaidMembers()
	local function partytype()
	if (numRaidMembers ~= 0) then
		if (#currentParty ~= numPartyMembers) then
			TF3:WipeTable(TF3.currentPartyMembers)
			for i=1, numRaidMembers do
				local partymember = UnitName("raid"..i)
				if partymember then
					TF3.currentPartyMembers[i] = partymember
					if (TF3.db.profile.debug) then
						TF3:FindFrame(debugFrame, "|cFFFFFF80" .. partymember .. " " .. L["PADD"] .. "|r")
					end
				end
			end		
		end
	elseif (numPartyMembers ~= 0) then
		if (#currentParty ~= numPartyMembers) then
			TF3:WipeTable(TF3.currentPartyMembers)
			for i=1, numPartyMembers do
				local partymember = UnitName("party"..i)
				if partymember then
					TF3.currentPartyMembers[i] = partymember
					if (TF3.db.profile.debug) then
						TF3:FindFrame(debugFrame, "|cFFFFFF80" .. partymember .. " " .. L["PADD"] .. "|r")
					end
				end
			end		
		end
	else
		TF3:WipeTable(TF3.currentPartyMembers)
	end
end

function TF3:IsParty(userID)
	local currentParty = TF3.currentPartyMembers
	for _,partymember in ipairs(currentParty) do
		if find(userID,partymember) then
			return true
		end
	end
	return false
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
				if (TF3.db.profile.debug) then
					TF3:FindFrame(debugFrame, "|cFFFFFF80" .. name .. " " .. L["FADD"] .. "|r")
				end
			end
		end
		print("|cFF33FF99" .. L["TFFRC"] .. "|r")
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

--[[ Duel Spam Functions ]]--
function TF3:DuelFilter()
	if (TF3.db.profile.filterDuelSpam) then
		DUEL_WINNER_KNOCKOUT, DUEL_WINNER_RETREAT = "", ""
	else
		DUEL_WINNER_KNOCKOUT, DUEL_WINNER_RETREAT = L["DUEL_WINNER_KNOCKOUT"], L["DUEL_WINNER_RETREAT"]
	end
end	

--[[ BlackList Func ]]--
--[[ Base blacklist words from BadBoy(Funkydude) ]]--
function TF3:BlackList(msg, userID, msgID, coloredName, arg)
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
							TF3:FindFrame(debugFrame, "|cFFFF0000[" .. L["bLists"] .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r")
							TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cFFFF0000" .. word .. "|r")
							if not (TF3.db.profile.redirect_blacklist) then
								lastmsgID = msgID
							end
						end
					end
					if (TF3.db.profile.redirect_blacklist) then
						if (msgID ~= lastmsgID) then
							TF3:FindFrame(redirectFrame, "|cFFFF0000[" .. L["bLists"] .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r")
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
function TF3:WhiteList(msg, userID, msgID, coloredName)
	local wlword = TF3.db.profile.whitelist
	local msg = lower(msg)
	if (TF3.db.profile.whitelist_enable) then
		for _,word in pairs(wlword) do
			if (find(msg,word) and TF3:FindRepeat(msg, userID, msgID, coloredName, whitelist) == false and TF3:BlackList(msg, userID, msgID, coloredName, whitelist) == false) then
				if (TF3.db.profile.debug) then
					if (msgID ~= lastmsgID) then
						TF3:FindFrame(debugFrame, "|cFFFFFF80[" .. L["wLists"] .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r")
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
	local chanName = lower(chanName)
	if (schans == nil) then
		schans = L.FILTERS.SPECIAL
	end
	for _,names in pairs(schans) do
		if (find(chanName,lower(names)) and names ~= "") then
			return true
		end
	end
	return false
end

--[[ Repeat Func ]]--
function TF3:FindRepeat(msg, userID, msgID, coloredName, arg)
	local gtime = floor(GetTime()*power(10,0)+0.5) / power(10,0)
	if (arg == whitelist and TF3.db.profile.wlbp == true) then
		return false
	elseif (TF3.db.profile.repeat_enable == false) then
		return false
	else
		if (msgID ~= TF3.repeatdata[userID].lastmsgID and msg == TF3.repeatdata[userID].lastmsg and gtime - TF3.repeatdata[userID].lastIndex < tonumber(TF3.db.profile.time_repeats)) then
			TF3.repeatdata[userID].repeats = TF3.repeatdata[userID].repeats + 1
			if (TF3.repeatdata[userID].repeats >= tonumber(TF3.db.profile.num_repeats)) then
				if (msg ~= rptmsg or msg == rptmsg and msgID ~= rptmsgID) then
					if (TF3.db.profile.debug) then
						if rptmsg ~= nil then
							TF3:FindFrame(repeatFrame, "|cFFFF8C00[" .. L["#RPT"] .. "]|r |cFFD9D9D9[" .. msgID .. "(" .. rptmsgID .. ")" .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080" .. msg .. "(" .. rptmsg .. ")" .. "|r")
						else
							TF3:FindFrame(repeatFrame, "|cFFFF8C00[" .. L["#RPT"] .. "]|r |cFFD9D9D9[" .. msgID .. "(" .. TF3.repeatdata[userID].lastmsgID .. ")" .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080" .. msg .. "(" .. TF3.repeatdata[userID].lastmsg .. ")" .. "|r")
						end
					end
					TF3.db.profile.repeats_blocked = TF3.db.profile.repeats_blocked + 1
					if (LDB) then
						TF3Frame.Blocked.text = TF3.db.profile.repeats_blocked .. L[" Repeats Blocked"]
						TF3Frame.Blocked.value = TF3.db.profile.repeats_blocked
					end
					rptmsg = msg
					rptmsgID = msgID
				end	
				rptdone = 1 + msgID
				return true
			end
		elseif (msg ~= TF3.repeatdata[userID].lastmsg) then
			TF3.repeatdata[userID].repeats = 1
		end
		TF3.repeatdata[userID].lastmsg = msg
		TF3.repeatdata[userID].lastmsgID = msgID
		TF3.repeatdata[userID].lastIndex  = gtime
		return false
	end
end

--[[ Window and Chat Functions ]]--
function TF3:FindFrame(toFrame, msg)
	for i=1,FCF_GetNumActiveChatFrames() do
		local name = GetChatWindowInfo(i)
		if (toFrame == name) then
			local msgFrame = _G["ChatFrame" .. i]
			msgFrame:AddMessage(msg)
			return
		end
	end
	if (toFrame ~= name) then
		TF3:CreateFrame(toFrame, msg)
	end
end

function TF3:CreateFrame(newFrame, msg)
  local newFrame = FCF_OpenNewWindow(newFrame)
	newFrame:AddMessage(msg)
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
	local msgID = arg11 or select(11, ...)
	local cName = arg12 or select(12, ...)
	local coloredName = TF3:GetColoredName(userID, cName)
	if (TF3.repeatdata[userID] ~= type(table) and TF3.db.profile.repeat_enable) then
		TF3.repeatdata[userID] = {}
		TF3.repeatdata[userID].lastmsg = msg
		TF3.repeatdata[userID].lastmsgID = msgID
		TF3.repeatdata[userID].lastIndex = 1
		TF3.repeatdata[userID].repeats = 1
		rptdone = msgID
	end
	if (TF3.db.profile.filterGAC) then
		if (find(prefix,"ET") and distType == "GUILD") then
			if (TF3:IsFriend(userID) == false) then
				if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID, coloredName) == true) then
					filtered = false
				elseif (TF3:BlackList(msg, userID, msgID, coloredName) == true) then
					filtered = true
				elseif (TF3.db.profile.repeat_enable and rptdone ~= msgID) then
					if (TF3:FindRepeat(msg, userID, msgID, coloredName) == true) then
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
		end
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
	local cName = arg12 or select(12, ...)
	local coloredName = TF3:GetColoredName(userID, cName)
	if (TF3.repeatdata[userID] ~= type(table) and TF3.db.profile.repeat_enable) then
		TF3.repeatdata[userID] = {}
		TF3.repeatdata[userID].lastmsg = msg
		TF3.repeatdata[userID].lastmsgID = msgID
		TF3.repeatdata[userID].lastIndex = 1
		TF3.repeatdata[userID].repeats = 1
		rptdone = msgID
	end
	if (TF3.db.profile.filterSAY) then
		if (event == "CHAT_MSG_SAY") then
			if (TF3:IsFriend(userID) == false and TF3:IsParty(userID) == false) then
				if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID, coloredName) == true) then
					filtered = false
				elseif (TF3:BlackList(msg, userID, msgID, coloredName) == true) then
					filtered = true
				elseif (TF3.db.profile.repeat_enable and rptdone ~= msgID) then
					if (TF3:FindRepeat(msg, userID, msgID, coloredName) == true) then
						filtered = true
					else
						filtered = TF3:FilterFunc("0. " .. L["Say/Yell"], ...)
					end
				else
					filtered = TF3:FilterFunc("0. " .. L["Say/Yell"], ...)
				end
			elseif (event == "CHAT_MSG_SAY" and not TF3.db.profile.filterSAY) then
				filtered = false
			end
		end
	end
	return filtered
end

--[[ Check for YELL Channel and User setting ]]--
local function PreFilterFunc_Yell(self, event, ...)
	local filtered = false
	local msg = arg1 or select(1, ...)
	local userID = arg2 or select(2, ...)
	local msgID = arg11 or select(11, ...)
	local cName = arg12 or select(12, ...)
	local coloredName = TF3:GetColoredName(userID, cName)
	if (TF3.repeatdata[userID] ~= type(table) and TF3.db.profile.repeat_enable) then
		TF3.repeatdata[userID] = {}
		TF3.repeatdata[userID].lastmsg = msg
		TF3.repeatdata[userID].lastmsgID = msgID
		TF3.repeatdata[userID].lastIndex = 1
		TF3.repeatdata[userID].repeats = 1
		rptdone = msgID
	end
	if (TF3.db.profile.filterYELL) then
		if (event == "CHAT_MSG_YELL") then
			if (TF3:IsFriend(userID) == false and TF3:IsParty(userID) == false) then
				if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID, coloredName) == true) then
					filtered = false
				elseif (TF3:BlackList(msg, userID, msgID, coloredName) == true) then
					filtered = true
				elseif (TF3.db.profile.repeat_enable and rptdone ~= msgID) then
					if (TF3:FindRepeat(msg, userID, msgID, coloredName) == true) then
						filtered = true
					else
						filtered = TF3:FilterFunc("0. " .. L["Say/Yell"], ...)
					end
				else
					filtered = TF3:FilterFunc("0. " .. L["Say/Yell"], ...)
				end
			elseif (event == "CHAT_MSG_YELL" and not TF3.db.profile.filterYELL) then
				filtered = false
			end
		end
	end
	return filtered
end

--[[ Check for Battleground Channel and User setting ]]--
local function PreFilterFunc_BG(self, event, ...)
	local filtered = false
	local msg = arg1 or select(1, ...)
	local userID = arg2 or select(2, ...)
	local msgID = arg11 or select(11, ...)
	local cName = arg12 or select(12, ...)
	local coloredName = TF3:GetColoredName(userID, cName)
	if (TF3.repeatdata[userID] ~= type(table) and TF3.db.profile.repeat_enable) then
		TF3.repeatdata[userID] = {}
		TF3.repeatdata[userID].lastmsg = msg
		TF3.repeatdata[userID].lastmsgID = msgID
		TF3.repeatdata[userID].lastIndex = 1
		TF3.repeatdata[userID].repeats = 1
		rptdone = msgID
	end
	if (TF3.db.profile.filterBG) then
		if (event == "CHAT_MSG_BATTLEGROUND" or event == "CHAT_MSG_BATTLEGROUND_LEADER") then
			if (TF3:IsFriend(userID) == false) then
				if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID, coloredName) == true) then
					filtered = false
				elseif (TF3:BlackList(msg, userID, msgID, coloredName) == true) then
					filtered = true
				elseif (TF3.db.profile.repeat_enable and rptdone ~= msgID) then
					if (TF3:FindRepeat(msg, userID, msgID, coloredName) == true) then
						filtered = true
					else
						filtered = TF3:FilterFunc("0. BG", ...)
					end
				else
					filtered = TF3:FilterFunc("0. BG", ...)
				end
			elseif (not TF3.db.profile.filterBG and event == "CHAT_MSG_BATTLEGROUND" or event == "CHAT_MSG_BATTLEGROUND_LEADER") then
				filtered = false
			end
		end
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
	local cName = arg12 or select(12, ...)
	local coloredName = TF3:GetColoredName(userID, cName)
	if (TF3.repeatdata[userID] ~= type(table) and TF3.db.profile.repeat_enable) then
		TF3.repeatdata[userID] = {}
		TF3.repeatdata[userID].lastmsg = msg
		TF3.repeatdata[userID].lastmsgID = msgID
		TF3.repeatdata[userID].lastIndex = 1
		TF3.repeatdata[userID].repeats = 1
		rptdone = msgID
	end
	--[[ Check for Trade Channel and User setting ]]--
	if (zoneID == 2) then
		if (TF3.db.profile.filtertrade) then
			if (TF3:IsFriend(userID) == false) then
				if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID, coloredName) == true) then
					filtered = false
				elseif (TF3:BlackList(msg, userID, msgID, coloredName) == true) then
					filtered = true
				elseif (TF3.db.profile.repeat_enable and rptdone ~= msgID) then
					if (TF3:FindRepeat(msg, userID, msgID, coloredName) == true) then
						filtered = true
					else
						filtered = TF3:FilterFunc("2. " .. L["Trade"], ...)
					end
				else
					filtered = TF3:FilterFunc("2. " .. L["Trade"], ...)
				end
			elseif (zoneID == 2 and not TF3.db.profile.filterTrade) then
				filtered = false
			end
		end
--~ 	end
	--[[ Check for General Channel and User setting ]]--
	elseif (chanID == 1) then
		if (TF3.db.profile.filtergeneral) then
			if (TF3:IsFriend(userID) == false) then
				if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID, coloredName) == true) then
					filtered = false
				elseif (TF3:BlackList(msg, userID, msgID, coloredName) == true) then
					filtered = true
				elseif (TF3.db.profile.repeat_enable and rptdone ~= msgID) then
					if (TF3:FindRepeat(msg, userID, msgID, coloredName) == true) then
						filtered = true
					else
						filtered = TF3:FilterFunc("1. " .. L["General"], ...)
					end
				else
					filtered = TF3:FilterFunc("1. " .. L["General"], ...)
				end
			elseif (chanID == 1 and not TF3.db.profile.filterGeneral) then
				filtered = false
			end
		end
--~ 	end
	--[[ Check for LFG Channel and User setting ]]--
	elseif (zoneID == 26) then
		if (TF3.db.profile.filterLFG) then
			if (TF3:IsFriend(userID) == false) then
				if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID, coloredName) == true) then
					filtered = false
				elseif (TF3:BlackList(msg, userID, msgID, coloredName) == true) then
					filtered = true
				elseif (TF3.db.profile.repeat_enable and rptdone ~= msgID) then
					if (TF3:FindRepeat(msg, userID, msgID, coloredName) == true) then
						filtered = true
					else
						filtered = TF3:FilterFunc("26. " .. L["LFG"], ...)
					end
				else
					filtered = TF3:FilterFunc("26. " .. L["LFG"], ...)
				end
			elseif (chanID == 26 and not TF3.db.profile.filterLFG) then
				filtered = false
			end
		end
--~ 	end
	--[[ Check for Special Channel and User setting ]]--
	elseif (TF3:SpecialChans(chanName) == true) then	
		if (TF3.db.profile.special_enable) then
			if (TF3:IsFriend(userID) == false) then
				if (userID == UnitName("Player") and TF3.db.profile.filterSELF == false or TF3:WhiteList(msg, userID, msgID, coloredName) == true) then
					filtered = false
				elseif (TF3:BlackList(msg, userID, msgID, coloredName) == true) then
					filtered = true
				elseif (TF3.db.profile.repeat_enable and rptdone ~= msgID) then
					if (TF3:FindRepeat(msg, userID, msgID, coloredName) == true) then
						filtered = true
					else
						filtered = TF3:FilterFunc("X. " .. chanName, ...)
					end
				else
					filtered = TF3:FilterFunc("X. " .. chanName, ...)
				end
			elseif (TF3:SpecialChans(chanName) == true and not TF3.db.profile.special_enable) then
				filtered = false
			end
		end
	end
	return filtered
end

--[[ Filter Func ]]--
function TF3:FilterFunc(chan, ...)
	local filterFuncList = ChatFrame_GetMessageEventFilters("CHAT_MSG_CHANNEL")
	local msg = arg1 or select(1, ...)
	local userID = arg2 or select(2, ...)
	local zoneID = arg7 or select(7, ...)
	local chanID = arg8 or select(8, ...)
	local chanName = arg9 or select(9, ...)
	local msgID = arg11 or select(11, ...)
	local cName = arg12 or select(12, ...)
	local coloredName = TF3:GetColoredName(userID, cName)
	local msg = lower(msg)
	if (filterFuncList and TF3.db.profile.turnOn) then
		filtered = true
		if (TF3.db.profile.debug) then
			if (lastmsg ~= msg or lastuserID ~= userID) then
				TF3:FindFrame(debugFrame, "|cFFC08080[" .. chan .. "]|r |cFFD9D9D9[" .. msgID .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r")
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
		elseif (chan == "0. BG") then
			if (TF3.db.profile.filters.BG == nil) then
				TF3.db.profile.filters.BG = L.FILTERS.BG
			end
			for k,v in pairs(TF3.db.profile.filters.BG) do
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
					TF3:FindFrame(redirectFrame, "|cFFC08080[" .. chan .. "]|r |cFFD9D9D9[" .. msgID .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r")
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
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", PreFilterFunc_BG)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", PreFilterFunc_BG)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", PreFilterFunc)
