--[[
TradeFilter3
		Filter that shit!

File Author: @file-author@
File Revision: @file-abbreviated-hash@
File Date: @file-date-iso@

* Copyright (c) 2008-10, @file-author@
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
* THIS SOFTWARE IS PROVIDED BY @file-author@ ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL @file-author@ BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

TradeFilter3 = LibStub("AceAddon-3.0"):NewAddon("TradeFilter3", "AceEvent-3.0")
local L =  LibStub("AceLocale-3.0"):GetLocale("TradeFilter3", true)
local libfriends = LibStub("LibFriends-1.0")
local LDB = LibStub("LibDataBroker-1.1", true)
local TF3 = TradeFilter3

--[[ Locals ]]--
local ipairs = ipairs
local pairs = pairs
local find = string.find
local sub = string.sub
local gsub = string.gsub
local len = string.len
local lower = string.lower
local format = string.format
local insert = table.insert
local remove = table.remove
local sort = table.sort
local floor = math.floor
local power = math.pow
local timerCount = 0
local currentFriend
local redirectFrame = L["redirectFrame"]
local debugFrame = L["debugFrame"]
local lastmsgID
local lastmsg
local lastuserID
local msgsFiltered = 0
local msgsBlackFiltered = 0

local MAJOR_VERSION = GetAddOnMetadata("TradeFilter3", "Version")
if (len(MAJOR_VERSION)<=8) then
	TF3.version = sub(MAJOR_VERSION, 0, 8)
else
	TF3.version = MAJOR_VERSION .. " DEV"
end
TF3.date = GetAddOnMetadata("TradeFilter3", "X-Date")

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
		filterDuelSpam = false,
		filterTrade = false,
		addfilterTRADE_enable = false,
		addfilterBASE_enable = false,
		addfilterBG_enable = false,
		exmptfriendslist = true,
		exmptparty = true,
		ebl = false,
		ewl = false,
		blacklist_enable = true,
		whitelist_enable = true,
		redirect_blacklist = false,
		wlbp = false,
		wlblbp = false,
		special_enable = false,
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

	local AC = LibStub("AceConsole-3.0")
	AC:RegisterChatCommand("tf", function() TF3:OpenOptions() end)
	AC:RegisterChatCommand("filter", function() TF3:OpenOptions() end)

	local ACfg = LibStub("AceConfig-3.0")
	ACfg:RegisterOptionsTable("TradeFilter3", TF3:getOptions())

	-- Set up options panels.
	self.OptionsPanel = ACD:AddToBlizOptions(self.name, L["TFR"], nil, "generalGroup")
	self.OptionsPanel.about = LAP.new(self.name, self.name)

	if (TF3.db.profile.firstlogin) then
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
	InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel)
	InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel)
end

function TF3:FirstLogin()
	TF3.db.profile.whitelist = L.WHITELIST
	TF3.db.profile.blacklist = L.BLACKLIST
	TF3.db.profile.filters = L.FILTERS
	print(L.TOC.Title .. ": " .. TF3.version .. " " .. L["ENABLED"])
end

function TF3:IsLoggedIn()
	self:RegisterEvent("FRIENDLIST_UPDATE", "GetFriends")
	libfriends.RegisterCallback(self, "Added")
	libfriends.RegisterCallback(self, "Removed")
	self:UnregisterEvent("PLAYER_LOGIN")
	TF3:DuelFilter()

	--[[ LibDataBroker object ]]--
	if (LDB) then
		TF3Frame = CreateFrame("Frame", "LDB_TradeFilter3")
		TF3Frame.obj = LDB:NewDataObject(L["TFR"], {
			type = "data source",
			icon = "Interface\\Icons\\Ability_Warrior_RallyingCry",
			text = L["0 Messages Filtered"],
			value = msgsFiltered,
			suffix = L[" Messages Filtered"],
			OnClick = function(self, button)
				if (button == "RightButton") then
					TF3:OpenOptions()
				else
					msgsFiltered = 0
					msgsBlackFiltered = 0
					TF3Frame.obj.text = msgsFiltered .. L[" Messages Filtered"]
					TF3Frame.obj.value = msgsFiltered
					TF3Frame.obj.OnEnter(self)
				end
			end,
			OnEnter = function(self)
				GameTooltip:SetOwner(self, "ANCHOR_NONE")
				GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
				GameTooltip:ClearLines()
				TF3Frame.obj.OnTooltipShow(GameTooltip)
				GameTooltip:Show()
			end,
			OnLeave = function(self)
				GameTooltip:Hide()
			end,
			OnTooltipShow = function(self)
				local hint = L["|cffeda55fRight Click|r to open config GUI.\n|cffeda55fLeft Click|r reset filtered count."]
				self:AddLine(L["Messages filtered are saved per session only"])
				self:AddLine(" ")
				self:AddLine(msgsFiltered .. L[" Messages Filtered"])
				self:AddLine(msgsBlackFiltered .. "|cFFFF0000" .. L[" Blacklist Filtered"] .. "|r")
				self:AddLine(" ")
				self:AddLine(hint, 0.2, 1, 0.2, 1)
			end,
		})
	end
end

--[[ LibDataBroker object updater ]]--
function TF3:LDBUpdate(arg)
	if (arg == "ldbblack") then
		msgsBlackFiltered = msgsBlackFiltered + 1
	elseif (arg == "ldbfilter") then
		msgsFiltered = msgsFiltered + 1
	end
	TF3Frame.obj.text = msgsBlackFiltered + msgsFiltered .. L[" Messages Filtered"]
	TF3Frame.obj.value = msgsBlackFiltered + msgsFiltered
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

function TF3:GetColoredName(userID, cName)
	if (cName ~= "") then
		local localizedClass, englishClass, localizedRace, englishRace, sex = GetPlayerInfoByGUID(cName)
		if (englishClass) then
			local classColorTable = RAID_CLASS_COLORS[englishClass]
			if not (classColorTable) then
				return userID
			end
				return format("\124cff%.2x%.2x%.2x", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255)..userID.."\124r"
		end
	end
	return userID
end

--[[ Party Functions ]]--
function TF3:IsParty(userID)
	if not (TF3.db.profile.exmptparty) then return false end
	local numPartyMembers = GetNumSubgroupMembers()
	local numRaidMembers = GetNumGroupMembers()
  if (numRaidMembers > 0) then
    for i=1, numRaidMembers, 1 do
      local partymember = UnitName("raid"..i)
      if find(userID,partymember) then
        return true
      end
    end
  elseif (numPartyMembers > 0 and numRaidMembers == 0) then
    for i=1, numPartyMembers, 1 do
      local partymember = UnitName("party"..i)
      if find(userID,partymember) then
        return true
      end
    end
  end
	return false
end

--[[ Friends Functions ]]--
function TF3:GetFriends()
	local friends = TF3.db.profile.friendslist
	local numFriends = GetNumFriends()
	if (#friends ~= numFriends) then
		if (TF3.db.profile.debug) then
			TF3:FindFrame(debugFrame, "|cFF33FF99" .. L["TFFR"] .. "|r")
		end
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
		if (TF3.db.profile.debug) then
			TF3:FindFrame(debugFrame, "|cFF33FF99" .. L["TFFRC"] .. "|r")
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
				remove(friends, k)
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
	if not (TF3.db.profile.exmptfriendslist) then return false end
	local friends = TF3.db.profile.friendslist
	for _,name in pairs(friends) do
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
function TF3:BlackList(msg, userID, msgID, coloredName)
	if not (TF3.db.profile.blacklist) then
		TF3.db.profile.blacklist = L.BLACKLIST
	end
	local blword = TF3.db.profile.blacklist
	local msg = lower(msg)
	if (TF3.db.profile.wlblbp) then
		return false
	else
		if (TF3.db.profile.blacklist_enable) then
			for _,word in pairs(blword) do
				if (find(msg,lower(word))) then
					if (TF3.db.profile.debug) then
						if (msgID ~= lastmsgID) then
							TF3:FindFrame(debugFrame, "|cFFFF0000[" .. L["bLists"] .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r")
							TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cFFFF0000" .. word .. "|r")
							if not (TF3.db.profile.redirect_blacklist) then
								lastmsgID = msgID
								if (LDB) then
									TF3:LDBUpdate("ldbblack")
								end
							end
						end
					end
					if (TF3.db.profile.redirect_blacklist) then
						if (msgID ~= lastmsgID) then
							TF3:FindFrame(redirectFrame, "|cFFFF0000[" .. L["bLists"] .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r")
							TF3:FindFrame(redirectFrame, L["MATCHED"] .. " |cFFFF0000" .. word .. "|r")
							lastmsgID = msgID
							TF3:LDBUpdate("ldbblack")
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
	if not (TF3.db.profile.whitelist) then
		TF3.db.profile.whitelist = L.WHITELIST
	end
	local wlword = TF3.db.profile.whitelist
	local msg = lower(msg)
	if (TF3.db.profile.whitelist_enable) then
		for _,word in pairs(wlword) do
			if (find(msg,lower(word))) then
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
	if not (TF3.db.profile.filters.SPECIAL) then
		TF3.db.profile.filters.SPECIAL = L.FILTERS.SPECIAL
	end
	local schans = TF3.db.profile.filters.SPECIAL
	local chanName = lower(chanName)
	for _,names in pairs(schans) do
		if (find(chanName,lower(names)) and names ~= "") then
			return true
		end
	end
	return false
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
	TF3:CreateFrame(toFrame, msg)
end

function TF3:CreateFrame(newFrame, msg)
  local newFrame = FCF_OpenNewWindow(newFrame)
	newFrame:AddMessage(msg)
end

--[[ PreFilter Functions ]]--
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
	local blacklisted = TF3:BlackList(msg, userID, msgID, coloredName)
	local whitelisted = TF3:WhiteList(msg, userID, msgID, coloredName)
	if (TF3.db.profile.filterGAC) then
		if (find(prefix,"ET") and distType == "GUILD") then
			if not (TF3:IsFriend(userID)) then
				if (userID == UnitName("Player") and not TF3.db.profile.filterSELF) then
					filtered = false
				elseif (whitelisted and not blacklisted) then
					filtered = false
				elseif (blacklisted) then
					filtered = true
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
	local blacklisted = TF3:BlackList(msg, userID, msgID, coloredName)
	local whitelisted = TF3:WhiteList(msg, userID, msgID, coloredName)
	if (TF3.db.profile.filterSAY) then
		if (event == "CHAT_MSG_SAY") then
			if not (TF3:IsFriend(userID)) and not (TF3:IsParty(userID)) then
				if (userID == UnitName("Player") and not TF3.db.profile.filterSELF) then
					filtered = false
				elseif (whitelisted and not blacklisted) then
					filtered = false
				elseif (blacklisted) then
					filtered = true
				else
					filtered = TF3:FilterFunc("0. " .. L["Say/Yell"], ...)
				end
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
	local blacklisted = TF3:BlackList(msg, userID, msgID, coloredName)
	local whitelisted = TF3:WhiteList(msg, userID, msgID, coloredName)
	if (TF3.db.profile.filterYELL) then
		if (event == "CHAT_MSG_YELL") then
			if not (TF3:IsFriend(userID)) and not (TF3:IsParty(userID)) then
				if (userID == UnitName("Player") and not TF3.db.profile.filterSELF) then
					filtered = false
				elseif (whitelisted and not blacklisted) then
					filtered = false
				elseif (blacklisted) then
					filtered = true
				else
					filtered = TF3:FilterFunc("0. " .. L["Say/Yell"], ...)
				end
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
	local blacklisted = TF3:BlackList(msg, userID, msgID, coloredName)
	local whitelisted = TF3:WhiteList(msg, userID, msgID, coloredName)
	if (TF3.db.profile.filterBG) then
		if (event == "CHAT_MSG_BATTLEGROUND" or event == "CHAT_MSG_BATTLEGROUND_LEADER") then
			if not (TF3:IsFriend(userID)) then
				if (userID == UnitName("Player") and not TF3.db.profile.filterSELF) then
					filtered = false
				elseif (whitelisted and not blacklisted) then
					filtered = false
				elseif (blacklisted) then
					filtered = true
				else
					filtered = TF3:FilterFunc("0. BG", ...)
				end
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
	local blacklisted = TF3:BlackList(msg, userID, msgID, coloredName)
	local whitelisted = TF3:WhiteList(msg, userID, msgID, coloredName)
	--[[ Check for Trade Channel and User setting ]]--
	if (zoneID == 2) then
		if (TF3.db.profile.filterTrade) then
			if not (TF3:IsFriend(userID)) then
				if (userID == UnitName("Player") and not TF3.db.profile.filterSELF) then
					filtered = false
				elseif (whitelisted and not blacklisted) then
					filtered = false
				elseif (blacklisted) then
					filtered = true
				else
					filtered = TF3:FilterFunc("2. " .. L["Trade"], ...)
				end
			end
		end
--[[ Check for General Channel and User setting ]]--
	elseif (chanID == 1) then
		if (TF3.db.profile.filterGeneral) then
			if not (TF3:IsFriend(userID)) then
				if (userID == UnitName("Player") and not TF3.db.profile.filterSELF) then
					filtered = false
				elseif (whitelisted and not blacklisted) then
					filtered = false
				elseif (blacklisted) then
					filtered = true
				else
					filtered = TF3:FilterFunc("1. " .. L["General"], ...)
				end
			elseif (chanID == 1 and not TF3.db.profile.filterGeneral) then
				filtered = false
			end
		end
--[[ Check for LFG Channel and User setting ]]--
	elseif (zoneID == 26) then
		if (TF3.db.profile.filterLFG) then
			if not (TF3:IsFriend(userID)) then
				if (userID == UnitName("Player") and not TF3.db.profile.filterSELF) then
					filtered = false
				elseif (whitelisted and not blacklisted) then
					filtered = false
				elseif (blacklisted) then
					filtered = true
				else
					filtered = TF3:FilterFunc("26. " .. L["LFG"], ...)
				end
			end
		end
--[[ Check for Special Channel and User setting ]]--
	elseif (TF3:SpecialChans(chanName)) then
		if (TF3.db.profile.special_enable) then
			if not (TF3:IsFriend(userID)) then
				if (userID == UnitName("Player") and not TF3.db.profile.filterSELF) then
					filtered = false
				elseif (whitelisted and not blacklisted) then
					filtered = false
				elseif (blacklisted) then
					filtered = true
				else
					filtered = TF3:FilterFunc("X. " .. chanName, ...)
				end
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
		if (zoneID == 2 or chan == "X. " .. chanName) then
			if not (TF3.db.profile.filters.TRADE) then
				TF3.db.profile.filters.TRADE = L.FILTERS.TRADE
			end
			for _,word in pairs(TF3.db.profile.filters.TRADE) do
				if (TF3.db.profile.debug and not TF3.db.profile.debug_checking) then
					if (lastmsg ~= msg or lastuserID ~= userID) then
						TF3:FindFrame(debugFrame, L["CFM"] .. " " .. word)
					end
				end
				if (find(msg,lower(word))) then
					if (TF3.db.profile.debug) then
						if (lastmsg ~= msg or lastuserID ~= userID) then
							TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cffff8080" .. word .. "|r")
							lastmsg, lastuserID = msg, userID
						end
					end
					filtered = false
				end
			end
		elseif (chan == "0. BG") then
			if not (TF3.db.profile.filters.BG) then
				TF3.db.profile.filters.BG = L.FILTERS.BG
			end
			for _,word in pairs(TF3.db.profile.filters.BG) do
				if (TF3.db.profile.debug and not TF3.db.profile.debug_checking) then
					if (lastmsg ~= msg or lastuserID ~= userID) then
						TF3:FindFrame(debugFrame, L["CFM"] .. " " .. word)
					end
				end
				if (find(msg,lower(word))) then
					if (TF3.db.profile.debug) then
						if (lastmsg ~= msg or lastuserID ~= userID) then
							TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cffff8080" .. word .. "|r")
							lastmsg, lastuserID = msg, userID
						end
					end
					filtered = false
				end
			end
		else
			if not (TF3.db.profile.filters.BASE) then
				TF3.db.profile.filters.BASE = L.FILTERS.BASE
			end
			for _,word in pairs(TF3.db.profile.filters.BASE) do
				if (TF3.db.profile.debug and not TF3.db.profile.debug_checking) then
					if (lastmsg ~= msg or lastuserID ~= userID) then
						TF3:FindFrame(debugFrame, L["CFM"] .. " " .. word)
					end
				end
				if (find(msg,lower(word))) then
					if (TF3.db.profile.debug) then
						if (lastmsg ~= msg or lastuserID ~= userID) then
							TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cffff8080" .. word .. "|r")
							lastmsg, lastuserID = msg, userID
						end
					end
					filtered = false
					end
				end
			end
		if (filtered) then
			if (lastmsg ~= msg or lastuserID ~= userID) then
				if (TF3.db.profile.debug) then
					TF3:FindFrame(debugFrame, L["NOMATCH"])
				end
				if (TF3.db.profile.redirect) then
					TF3:FindFrame(redirectFrame, "|cFFC08080[" .. chan .. "]|r |cFFD9D9D9[" .. msgID .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r")
				end
				if (LDB) then
					TF3:LDBUpdate("ldbfilter")
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
