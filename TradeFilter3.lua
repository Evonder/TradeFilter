--[[
TradeFilter3
		Filter that shit!

File Author: @file-author@
File Revision: @file-abbreviated-hash@
File Date: @file-date-iso@
Project Revision: @project-revision@

* Copyright (c) 2008-24, @file-author@
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
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS AND CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

local TradeFilter3 = LibStub("AceAddon-3.0"):NewAddon("TradeFilter3", "AceEvent-3.0")
local L =  LibStub("AceLocale-3.0"):GetLocale("TradeFilter3", true)
local LDB = LibStub("LibDataBroker-1.1", true)
local TF3 = TradeFilter3

--[[ Locals ]]--
local pairs = pairs
local find = string.find
local sub = string.sub
local len = string.len
local lower = string.lower
local format = string.format
local TF3Frame
local redirectFrame = L["redirectFrame"]
local debugFrame = L["debugFrame"]
local currentChatFrames = {}
local chatFrames = {}
local lastmsgID = 0
local wlmsgID = 0
local msgsFiltered = 0
local msgsBlackFiltered = 0
local numGroupMembers = 0
local subGroupMembers = 0
local OptionsPanel
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

local MAJOR_VERSION = GetAddOnMetadata("TradeFilter3", "Version")
if (len(MAJOR_VERSION)<=8) then
    TF3.version = sub(MAJOR_VERSION, 0, 8)
else
    TF3.version = MAJOR_VERSION .. " DEV"
end
TF3.date = GetAddOnMetadata("TradeFilter3", "X-Date")

--[[ Database Defaults ]]--
local defaults = {
    profile = {
        turnOn = true,
        firstlogin = true,
        redirect = true,
        debug = false,
        debug_checking = true,
        filterSAY = false,
        filterYELL = false,
        filterGAC = false,
        filterSELF = false,
        filterLFG = false,
        filterBG = false,
        filterGeneral = false,
        filterDuelSpam = false,
        filterTrade = true,
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
        whitelist = {},
        blacklist = {},
        filters = {},
    },
}

function TF3:OnInitialize()
    --[[ Libraries ]]--
    local ACD = LibStub("AceConfigDialog-3.0")

    self.db = LibStub("AceDB-3.0"):New("TradeFilter3DB", defaults);

    local AC = LibStub("AceConsole-3.0")
    AC:RegisterChatCommand("tf", function() TF3:OpenOptions() end)
    AC:RegisterChatCommand("filter", function() TF3:OpenOptions() end)

    local ACfg = LibStub("AceConfig-3.0")
    ACfg:RegisterOptionsTable("TradeFilter3", TF3:getOptions())

    -- Set up options panels.
    _, OptionsPanel = ACD:AddToBlizOptions(self.name, L["TFR"], nil, "generalGroup")

    if (TF3.db.profile.firstlogin) then
        TF3:FirstLogin()
    end

    if IsLoggedIn() then
        self:IsLoggedIn()
    else
        self:RegisterEvent("PLAYER_LOGIN", "IsLoggedIn")
    end

    TF3:LDBInitialize()
    
    TF3:indexChatFrames()
    self:RegisterEvent("ZONE_CHANGED", "indexChatFrames")
    self:RegisterEvent("ZONE_CHANGED_INDOORS", "indexChatFrames")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "indexChatFrames")
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "numGroupMembers")
end

-- :OpenOptions(): Opens the options window.
function TF3:OpenOptions()
    Settings.OpenToCategory(OptionsPanel)
end

function TF3:FirstLogin()
    TF3:dbImportSV()
    TF3.db.profile.firstlogin = false
    print(L["TOC/Title"] .. ": " .. TF3.version .. " " .. L["ENABLED"])
end

function TF3:IsLoggedIn()
    self:UnregisterEvent("PLAYER_LOGIN")
    TF3:DuelFilter()
end

--[[ LibDataBroker Object Initialize ]]--
function TF3:LDBInitialize()
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

function TF3:GetColoredName(userID, guid)
    if (userID and guid) then
        local _, englishClass, _, _, _, _, _ = GetPlayerInfoByGUID(guid)
        if (englishClass) then
            local classColorTable = RAID_CLASS_COLORS[englishClass]
            if (not classColorTable) then
                return userID
            end
            return format("\124cff%.2x%.2x%.2x", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255)..userID.."\124r"
        end
    end
    return userID
end

--[[ Party/Raid/BG Functions ]]--
function TF3:numGroupMembers()
    numGroupMembers = GetNumGroupMembers()
    subGroupMembers = GetNumSubgroupMembers()
end

function TF3:instanceType()
    local inInstance, instanceType = IsInInstance()
    if (inInstance) then
        return instanceType
    else
        return false
    end
end

function TF3:IsParty(userID, msgID)
    local lastmsgIDp = 0
    local UnitInParty = UnitInParty
    local UnitInRaid = UnitInRaid
    if (msgID == lastmsgIDp) then
        return
    end
    if (not userID) then
        return false
    end
    if (UnitInParty(userID) or UnitInRaid(userID)) then
        return true
    end
    lastmsgIDp = msgID
    return false
end

--[[ Friends Functions ]]--
function TF3:IsFriend(guid)
    if (guid) then
        return C_FriendList.IsFriend(guid)
    else
        return false
    end
end

--[[ Duel Spam Functions ]]--
function TF3:DuelFilter()
    if (TF3.db.profile.filterDuelSpam) then
        DUEL_WINNER_KNOCKOUT, DUEL_WINNER_RETREAT = "", ""
    else
        DUEL_WINNER_KNOCKOUT, DUEL_WINNER_RETREAT = L["DUEL_WINNER_KNOCKOUT"], L["DUEL_WINNER_RETREAT"]
    end
end

--[[ Window and Chat Functions ]]--
function TF3:indexChatFrames()
    local name, frame
    for i=1,NUM_CHAT_WINDOWS do
        name = GetChatWindowInfo(i)
        frame = _G["ChatFrame" .. i]
        if (name ~= nil) then
            currentChatFrames[name] = frame
        end
    end
    for k,_ in pairs(currentChatFrames) do
        chatFrames[#chatFrames+1] = k
    end
end

function TF3:FindFrame(toFrame, msg, msgID)
    local frame
    if (msgID == lastmsgID or msgID == wlmsgID) then
        return
    end
    for i=1, #chatFrames do
        if (chatFrames[i] == toFrame and toFrame == redirectFrame) then
            frame = currentChatFrames[redirectFrame]
            frame:AddMessage(msg)
            return
        elseif (chatFrames[i] == toFrame and toFrame == debugFrame) then
            frame = currentChatFrames[debugFrame]
            frame:AddMessage(msg)
            return
        end
    end
    TF3:createChatFrame(toFrame, msg, msgID)
    return
end

function TF3:createChatFrame(toFrame, msg, msgID)
    local frame
    frame = FCF_OpenNewWindow(toFrame)
    ChatFrame_RemoveAllMessageGroups(frame)
    ChatFrame_RemoveAllChannels(frame)
    frame:AddMessage(msg)
    lastmsgID = msgID
    TF3:indexChatFrames()
end

--[[ BlackList Func ]]--
--[[ Base blacklist words from BadBoy(Funkydude) ]]--
local function TF3:BlackList(msg, userID, chanName, msgID, coloredName, whitelisted)
    if (msgID == lastmsgID) then
        return
    end
    if (not TF3.db.profile.blacklist) then
        TF3.db.profile.blacklist = TF3:FixWowAceSubnamespaces("blacklist")
    end
    local blword = TF3.db.profile.blacklist
    if (TF3.db.profile.wlblbp and whitelisted) then
        return false
    else
        for _,word in pairs(blword) do
            if (find(msg,lower(word))) then
                if (TF3.db.profile.debug) then
                    if (TF3.db.profile.filterYELL and event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL") then
                        TF3:FindFrame(debugFrame, "|cFFFF0000[" .. L["bLists"] .. "]|r |cFFC08080[say/YELL]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r", msgID)
                    elseif (TF3.db.profile.filterBG and TF3:instanceType()) then
                        TF3:FindFrame(debugFrame, "|cFFFF0000[" .. L["bLists"] .. "]|r |cFFC08080[BG]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r", msgID)
                    else
                        TF3:FindFrame(debugFrame, "|cFFFF0000[" .. L["bLists"] .. "]|r |cFFC08080[" .. chanName .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r", msgID)
                    end
                    TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cFFFF0000" .. word .. "|r", msgID)
                end
                if (TF3.db.profile.redirect_blacklist) then
                    if (TF3.db.profile.filterYELL and event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL") then
                        TF3:FindFrame(redirectFrame, "|cFFFF0000[" .. L["bLists"] .. "]|r |cFFC08080[say/YELL]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r", msgID)
                    elseif (TF3.db.profile.filterBG and TF3:instanceType()) then
                        TF3:FindFrame(redirectFrame, "|cFFFF0000[" .. L["bLists"] .. "]|r |cFFC08080[BG]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r", msgID)
                    else
                        TF3:FindFrame(redirectFrame, "|cFFFF0000[" .. L["bLists"] .. "]|r |cFFC08080[" .. chanName .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r", msgID)
                    end
                    TF3:FindFrame(redirectFrame, L["MATCHED"] .. " |cFFFF0000" .. word .. "|r", msgID)
                end
                if (LDB) then
                    TF3:LDBUpdate("ldbblack")
                end
                return true
            end
        end
        return false
    end
end

--[[ WhiteList Func ]]--
local function TF3:WhiteList(event, msg, userID, chanName, msgID, coloredName)
    if (msgID == wlmsgID) then
        return
    end
    if (not TF3.db.profile.whitelist) then
        TF3.db.profile.whitelist = TF3:FixWowAceSubnamespaces("whitelist")
    end
    local wlword = TF3.db.profile.whitelist
    for _,word in pairs(wlword) do
        if (find(msg,lower(word))) then
            if (TF3.db.profile.debug) then
                if (TF3.db.profile.filterYELL and event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL") then
                    TF3:FindFrame(debugFrame, "|cFFFFFF80[" .. L["wLists"] .. "]|r |cFFD9D9D9[msgId: " .. msgID .. "]|r |cFFD9D9D9[lastmsgID: " .. wlmsgID .. "]|r |cFFC08080[say/YELL]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r", msgID)
                elseif (TF3.db.profile.filterBG and TF3:instanceType()) then
                    TF3:FindFrame(debugFrame, "|cFFFFFF80[" .. L["wLists"] .. "]|r |cFFD9D9D9[msgId: " .. msgID .. "]|r |cFFD9D9D9[lastmsgID: " .. wlmsgID .. "]|r |cFFC08080[BG]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r", msgID)
                else
                    TF3:FindFrame(debugFrame, "|cFFFFFF80[" .. L["wLists"] .. "]|r |cFFD9D9D9[msgId: " .. msgID .. "]|r |cFFD9D9D9[lastmsgID: " .. wlmsgID .. "]|r |cFFC08080[" .. chanName .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r", msgID)
                end
                TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cFFFFFF80" .. word .. "|r", msgID)
            end
            wlmsgID = msgID
            return true
        end
    end
    return false
end

--[[ Check for Trade/General/LFG/Say/Yell Channel and User setting ]]--
local function PreFilterFunc(self, event, ...)
    local filtered = false
    local msg = arg1 or select(1, ...)
    local userID = arg2 or select(2, ...)
    local zoneID = arg7 or select(7, ...)
    local chanID = arg8 or select(8, ...)
    local chanName = arg9 or select(9, ...)
    local msgID = arg11 or select(11, ...)
    local guid = arg12 or select(12, ...)
    local coloredName = TF3:GetColoredName(userID, guid)
    local msg = lower(msg)
    local blacklisted = nil
    local whitelisted = nil
    if (msgID == lastmsgID) then
        return
    end
    if (chanID == 5) then return end
    if (TF3.db.profile.whitelist_enable) then
        whitelisted = TF3:WhiteList(event, msg, userID, chanName, msgID, coloredName)
    end
    if (TF3.db.profile.blacklist_enable) then
        blacklisted = TF3:BlackList(event, msg, userID, chanName, msgID, coloredName, whitelisted)
    end
    --[[ Check for SAY Channel and User setting ]]--
    if (event == "CHAT_MSG_SAY" and TF3.db.profile.filterYELL) then
        if (find(lower(userID),lower(UnitName("player"))) and not TF3.db.profile.filterSELF) then
            return false
        end
        if (TF3.db.profile.exmptfriendslist) then
            if (TF3:IsFriend(guid)) then
                return false
            end
        end
        if (TF3.db.profile.exmptparty and numGroupMembers ~= 0 or TF3.db.profile.exmptparty and subGroupMembers ~= 0) then
            if (TF3:IsParty(userID, msgID)) then
                return false
            end
        end
        if (whitelisted and not blacklisted) then
            return false
        end
        if (blacklisted) then
            return true
        end
        filtered = TF3:FilterFunc(L["Say/Yell"], msg, userID, zoneID, chanName, msgID, coloredName)
    --[[ Check for YELL Channel and User setting ]]--
    elseif (event == "CHAT_MSG_YELL" and TF3.db.profile.filterYELL) then
        if (find(lower(userID),lower(UnitName("player"))) and not TF3.db.profile.filterSELF) then
            return false
        end
        if (TF3.db.profile.exmptfriendslist) then
            if (TF3:IsFriend(guid)) then
                return false
            end
        end
        if (TF3.db.profile.exmptparty and numGroupMembers ~= 0 or TF3.db.profile.exmptparty and subGroupMembers ~= 0) then
            if (TF3:IsParty(userID, msgID)) then
                return false
            end
        end
        if (whitelisted and not blacklisted) then
            return false
        end
        if (blacklisted) then
            return true
        end
        filtered = TF3:FilterFunc(L["Say/Yell"], msg, userID, zoneID, chanName, msgID, coloredName)
    --[[ Check for Trade Channel and User setting ]]--
    elseif (zoneID == 2 and TF3.db.profile.filterTrade) then
        if (find(lower(userID),lower(UnitName("player"))) and not TF3.db.profile.filterSELF) then
            return false
        end
        if (TF3.db.profile.exmptfriendslist) then
            if (TF3:IsFriend(guid)) then
                return false
            end
        end
        if (TF3.db.profile.exmptparty and numGroupMembers ~= 0 or TF3.db.profile.exmptparty and subGroupMembers ~= 0) then
            if (TF3:IsParty(userID, msgID)) then
                return false
            end
        end
        if (whitelisted and not blacklisted) then
            return false
        end
        if (blacklisted) then
            return true
        end
        filtered = TF3:FilterFunc(nil, msg, userID, zoneID, chanName, msgID, coloredName)
    --[[ Check for General Channel and User setting ]]--
    elseif (zoneID == 1 and TF3.db.profile.filterGeneral) then
        if (find(lower(userID),lower(UnitName("player"))) and not TF3.db.profile.filterSELF) then
            return false
        end
        if (TF3.db.profile.exmptfriendslist) then
            if (TF3:IsFriend(guid)) then
                return false
            end
        end
        if (TF3.db.profile.exmptparty and numGroupMembers ~= 0 or TF3.db.profile.exmptparty and subGroupMembers ~= 0) then
            if (TF3:IsParty(userID, msgID)) then
                return false
            end
        end
        if (whitelisted and not blacklisted) then
            return false
        end
        if (blacklisted) then
            return true
        end
        filtered = TF3:FilterFunc(nil, msg, userID, zoneID, chanName, msgID, coloredName)
    --[[ Check for LFG Channel and User setting ]]--
    elseif (zoneID == 26 and TF3.db.profile.filterLFG) then
        if (find(lower(userID),lower(UnitName("player"))) and not TF3.db.profile.filterSELF) then
            return false
        end
        if (TF3.db.profile.exmptfriendslist) then
            if (TF3:IsFriend(guid)) then
                return false
            end
        end
        if (TF3.db.profile.exmptparty and numGroupMembers ~= 0 or TF3.db.profile.exmptparty and subGroupMembers ~= 0) then
            if (TF3:IsParty(userID, msgID)) then
                return false
            end
        end
        if (whitelisted and not blacklisted) then
            return false
        end
        if (blacklisted) then
            return true
        end
        filtered = TF3:FilterFunc(nil, msg, userID, zoneID, chanName, msgID, coloredName)
    --[[ Check for Battleground Channel and User setting ]]--
    elseif (event == "CHAT_MSG_INSTANCE_CHAT" and TF3:instanceType() == "pvp" and TF3.db.profile.filterBG or event == "CHAT_MSG_INSTANCE_CHAT_LEADER" and TF3:instanceType() == "pvp" and TF3.db.profile.filterBG) then
        if (find(lower(userID),lower(UnitName("player"))) and not TF3.db.profile.filterSELF) then
            return false
        end
        if (TF3.db.profile.exmptfriendslist) then
            if (TF3:IsFriend(guid)) then
                return false
            end
        end
        if (TF3.db.profile.exmptparty and numGroupMembers ~= 0 or TF3.db.profile.exmptparty and subGroupMembers ~= 0) then
            if (TF3:IsParty(userID, msgID)) then
                return false
            end
        end
        if (whitelisted and not blacklisted) then
            return false
        end
        if (blacklisted) then
            return true
        end
        filtered = TF3:FilterFunc("BG", msg, userID, zoneID, chanName, msgID, coloredName)
    end
    return filtered
end

--[[ Filter Func ]]--
local function TF3:FilterFunc(chan, msg, userID, zoneID, chanName, msgID, coloredName)
    if (msgID == lastmsgID or msgID == wlmsgID) then
        return
    end
    local filterFuncList = ChatFrame_GetMessageEventFilters("CHAT_MSG_CHANNEL")
    local filtered
    if (filterFuncList and TF3.db.profile.turnOn) then
        filtered = true
        if (TF3.db.profile.debug) then
                if (chan) then
                    TF3:FindFrame(debugFrame, "|cFFC08080[" .. chan .. "]|r |cFFD9D9D9[" .. msgID .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r", msgID)
                else
                    TF3:FindFrame(debugFrame, "|cFFC08080[" .. chanName .. "]|r |cFFD9D9D9[" .. msgID .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r", msgID)
                end
        end
        if (zoneID == 2) then
            if (not TF3.db.profile.filters.TRADE) then
                TF3.db.profile.filters.TRADE = TF3:FixWowAceSubnamespaces("TRADE")
            end
            for _,word in pairs(TF3.db.profile.filters.TRADE) do
                if (TF3.db.profile.debug and not TF3.db.profile.debug_checking) then
                    TF3:FindFrame(debugFrame, L["CFM"] .. " " .. word, msgID)
                end
                if (find(msg,lower(word))) then
                    if (TF3.db.profile.debug) then
                        TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cffff8080" .. word .. "|r", msgID)
                    end
                    filtered = false
                end
            end
        elseif (chan == "BG") then
            if (not TF3.db.profile.filters.BG) then
                TF3.db.profile.filters.BG = TF3:FixWowAceSubnamespaces("BG")
            end
            for _,word in pairs(TF3.db.profile.filters.BG) do
                if (TF3.db.profile.debug and not TF3.db.profile.debug_checking) then
                    TF3:FindFrame(debugFrame, L["CFM"] .. " " .. word, msgID)
                end
                if (find(msg,lower(word))) then
                    if (TF3.db.profile.debug) then
                        TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cffff8080" .. word .. "|r", msgID)
                    end
                    filtered = false
                end
            end
        else
            if (not TF3.db.profile.filters.BASE) then
                TF3.db.profile.filters.BASE = TF3:FixWowAceSubnamespaces("BASE")
            end
            for _,word in pairs(TF3.db.profile.filters.BASE) do
                if (TF3.db.profile.debug and not TF3.db.profile.debug_checking) then
                    TF3:FindFrame(debugFrame, L["CFM"] .. " " .. word, msgID)
                end
                if (find(msg,lower(word))) then
                    if (TF3.db.profile.debug) then
                        TF3:FindFrame(debugFrame, L["MATCHED"] .. " |cffff8080" .. word .. "|r", msgID)
                    end
                    filtered = false
                end
            end
        end
        if (filtered) then
            if (TF3.db.profile.debug) then
                TF3:FindFrame(debugFrame, L["NOMATCH"], msgID)
            end
            if (TF3.db.profile.redirect) then
                if (chan) then
                    TF3:FindFrame(redirectFrame, "|cFFC08080[" .. chan .. "]|r |cFFD9D9D9[" .. msgID .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r", msgID)
                else
                    TF3:FindFrame(redirectFrame, "|cFFC08080[" .. chanName .. "]|r |cFFD9D9D9[" .. msgID .. "]|r |Hplayer:" .. userID .. ":" .. msgID .. "|h[" .. coloredName .. "]|h |cFFC08080: " .. msg .. "|r", msgID)
                end
            end
            if (LDB) then
                TF3:LDBUpdate("ldbfilter")
            end
        end
    end
    lastmsgID = msgID
    return filtered
end

--[[ Pass ALL chat messages to PreFilter function ]]--
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", PreFilterFunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", PreFilterFunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", PreFilterFunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", PreFilterFunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", PreFilterFunc)
