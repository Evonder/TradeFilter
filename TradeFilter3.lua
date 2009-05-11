--[[
TradeFilter3
		Filter that shit!

File Author: @file-author@
File Revision: @file-revision@
File Date: @file-date-iso@

Basic structure and code from crashmstr (wowzn@crashmstr.com)
		which was ripped from TasteTheNaimbow (Thank you Guillotine!)

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
TradeFilter3 = LibStub("AceAddon-3.0"):NewAddon("TradeFilter3", "AceHook-3.0", "AceEvent-3.0", "AceConsole-3.0")
local TF3 = TradeFilter3

local MAJOR_VERSION = "3.0"
local MINOR_VERSION = 000 + tonumber(("$Revision: @project-revision@ $"):match("%d+"))
TF3.version = MAJOR_VERSION .. "." .. MINOR_VERSION
TF3.date = string.sub("$Date: @file-date-iso@ $", 8, 17)

--[[ Libraries ]]--
local L =  LibStub("AceLocale-3.0"):GetLocale("TradeFilter3")
local ACD = LibStub("AceConfigDialog-3.0")

function TF3:OnInitialize()
	--[[ Database Defaults ]]--
	local defaults = {
		profile = {
			turnOn = true,
			redirect = false,
			debug = false,
			filterSAY = false,
			filterLFG = false,
			filterGeneral = false,
			filterTrade = true,
			addfilter = false,
			addfilter1 = "[lL][fF] [pP][oO][rR][tT]",
			addfilter2 = "[lL][fF][mM]",
			addfilter3 = "[bB][uU][yY][iI][nN][gG]",
			filter = {
				{"[wW][tT][bBsStT]",true},
				{"[lL][fF][wWeE]",true},
				{"[lL][fF][eE][nN][cC][hH][aA][nN][tT]",true},
				{"[lL][fF] [eE][nN][cC][hH][aA][nN][tT]",true},
				{"[lL][fF] [jJ][cC]",true},
				{"[lL][fF] [dD][pP][sS]",true},
				{"[lL][fF] [tT][aA][nN][kK]",true},
				{"[lL][fF] [hH][eE][aA][lL][eE][rR]",true},
				{"[lL][fF]%d[mM]?",true},
				{"[lL][fF][gG]",true},
				{"AH",true},
				{"looking for work",true},
				{"lockpick",true},
				{"[sS][eE][lL][lL][iI][nN][gG]",true},
				{"[bB][uU][yY][iI][nN][gG]",true},
				{"3[vV]3",true},
				{"5[vV]5",true},
			},
		}
	}
	
	self.db = LibStub("AceDB-3.0"):New("TradeFilter3DB", defaults, "Default");
	
	local ACP = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db);
	
	self:RegisterChatCommand("filter", function() self:OpenOptions() end)
	self:RegisterChatCommand("tradefilter", function() self:OpenOptions() end)
	
	local ACR = LibStub("AceConfigRegistry-3.0")
	ACR:RegisterOptionsTable("TradeFilter3", options)
	ACR:RegisterOptionsTable("TradeFilter3P", ACP)
	
	-- Set up options panels.
	self.OptionsPanel = ACD:AddToBlizOptions(self.name, L["TFR"], nil, "general")
	self.OptionsPanel.channel = ACD:AddToBlizOptions(self.name, L["channelGroup"], self.name, "channelGroup")
	self.OptionsPanel.custom = ACD:AddToBlizOptions(self.name, L["addFilterGroup"], self.name, "addFilterGroup")
	self.OptionsPanel.profiles = ACD:AddToBlizOptions("TradeFilter3P", L["Profiles"], self.name)
end

-- :OpenOptions(): Opens the options window.
function TF3:OpenOptions()
	InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel)
end

--[[ Options Table ]]--
function TF3:GetAddFilter()
	return self.db.profile.addfilter
end

function TF3:SetAddFilter()
	self.db.profile.addfilter = not self.db.profile.addfilter
end

function TF3:GetAddFilter1()
	return self.db.profile.addfilter1
end

function TF3:SetAddFilter1(v)
	self.db.profile.addfilter1 = ""..v..""
end

function TF3:GetAddFilter2()
	return self.db.profile.addfilter2
end

function TF3:SetAddFilter2(v)
	self.db.profile.addfilter2 = ""..v..""
end

function TF3:GetAddFilter3()
	return self.db.profile.addfilter3
end

function TF3:SetAddFilter3(v)
	self.db.profile.addfilter3 = ""..v..""
end

function TF3:IsFilterSAY()
	return self.db.profile.filterSAY
end

function TF3:ToggleFilterSAY()
	self.db.profile.filterSAY = not self.db.profile.filterSAY
end

function TF3:IsFilterLFG()
	return self.db.profile.filterLFG
end

function TF3:ToggleFilterLFG()
	self.db.profile.filterLFG = not self.db.profile.filterLFG
end

function TF3:IsFilterGeneral()
	return self.db.profile.filtergeneral
end

function TF3:ToggleFilterGeneral()
	self.db.profile.filtergeneral = not self.db.profile.filtergeneral
end

function TF3:IsFilterTrade()
	return self.db.profile.filtertrade
end

function TF3:ToggleFilterTrade()
	self.db.profile.filtertrade = not self.db.profile.filtertrade
end

function TF3:IsDebug()
	return self.db.profile.debug
end

function TF3:ToggleDebug()
	self.db.profile.debug = not self.db.profile.debug
end

function TF3:IsRedirect()
	return self.db.profile.redirect
end

function TF3:ToggleRedirect()
	self.db.profile.redirect = not self.db.profile.redirect
end

function TF3:IsTurnOn()
	return self.db.profile.turnOn
end

function TF3:ToggleTurnOn(info, value)
	self.db.profile.turnOn = not self.db.profile.turnOn
	self.db.profile.turnOn = value
	if (value == "false") then
		value = "Disabled"
	elseif (value == "true") then
		value = "Enabled"
	end
--	print("|cFF33FF99TradeFilter3|r: " .. TradeFilter3.version .. " |cff00ff00Enabled " .. tostring(value) .. "|r")
end

options = {
    type='group',
		name = TF3.name,
		handler = TF3,
    args = {
			general = {
				type = "group",
				name = TF3.name,
				args = {
					turnOn = {
						type = 'toggle',
						order = 1,
						width = "double",
						name = L["TurnOn"],
						desc = L["TurnOnDesc"],
						get = "IsTurnOn",
						set = "ToggleTurnOn",
					},
					redirect = {
						type = 'toggle',
						order = 2,
						width = "double",
						name = L["Redir"],
						desc = L["RedirDesc"],
						get = "IsRedirect",
						set = "ToggleRedirect",
					},
					debug = {
						type = 'toggle',
						order = 3,
						width = "full",
						disabled = false,
						hidden = false,
						name = L["Debug"],
						desc = L["DebugDesc"],
						get = "IsDebug",
						set = "ToggleDebug",
					},
					reload = {
						type = 'execute',
						name = L["RUI"],
						desc = L["RUID"],
						func = function()
							_G.ReloadUI()
						end,
						--disabled = function()
						--	return not self:IsDebug or return not self:IsRedirect
						--end,
						order = -1,
					},
				},
			},
			channelGroup = {
				type = 'group',
				order = 1,
				width = "double",
				disabled = false,
				name = "Channel Selection",
				desc = "Channel Selection [Not Implemented Yet]",
				args = {
					tradeChannel = {
						type = 'toggle',
						order = 1,
						width = "double",
						disabled = false,
						name = L["TC"],
						desc = L["TCD"],
						get = "IsFilterTrade",
						set = "ToggleFilterTrade",
					},
					generalChannel = {
						type = 'toggle',
						order = 2,
						width = "double",
						disabled = false,
						name = L["GC"],
						desc = L["GCD"],
						get = "IsFilterGeneral",
						set = "ToggleFilterGeneral",
					},
					LFGChannel = {
						type = 'toggle',
						order = 3,
						width = "double",
						disabled = false,
						name = L["LFGC"],
						desc = L["LFGCD"],
						get = "IsFilterLFG",
						set = "ToggleFilterLFG",
					},
					SAYChannel = {
						type = 'toggle',
						order = 4,
						width = "double",
						disabled = false,
						name = L["SAYC"],
						desc = L["SAYCD"],
						get = "IsFilterSAY",
						set = "ToggleFilterSAY",
					},
				},
			},
			addFilterGroup = {
				type = 'group',
				disabled = false,
				name = L["AddFilterG"],
				desc = L["AddFilterGD"],
				args = {
					addFilter = {
						type = 'toggle',
						order = 1,
						width = "double",
						name = L["AddFilter"],
						desc = L["AddFilterD"],
						get = "GetAddFilter",
						set = "SetAddFilter",
					},
					addFilter1 = {
						type = 'input',
						disabled = function()
							return not TF3:GetAddFilter()
						end,
						order = 2,
						width = "double",
						name = L["AddFilter1"],
						desc = L["AddFilter1D"],
						get = "GetAddFilter1",
						set = "SetAddFilter1",
						usage = L["AddFilterUsage"],
					},
					addFilter2 = {
						type = 'input',
						disabled = function()
							return not TF3:GetAddFilter()
						end,
						order = 3,
						width = "double",
						name = L["AddFilter2"],
						desc = L["AddFilter1D"],
						get = "GetAddFilter2",
						set = "SetAddFilter2",
						usage = L["AddFilterUsage"],
					},
					addFilter3 = {
						type = 'input',
						disabled = function()
							return not TF3:GetAddFilter()
						end,
						order = 4,
						width = "double",
						name = L["AddFilter3"],
						desc = L["AddFilter1D"],
						get = "GetAddFilter3",
						set = "SetAddFilter3",
						usage = L["AddFilterUsage"],
					},
				},
			},
		},
	}

 --[[ Locals ]]--
 --local filtered = false
 local redirectFrame = nil
 local debugFrame = nil
 local lastArg1

--[[ Window Functions ]]--
function TF3:FindOrCreateChatWindow(window, create)
	local frame = nil
--[[
	if frame == nil and create then
		frame = CreateFrame("Frame", window, UIParent)
		_G["ChatFrame" .. NUM_CHAT_WINDOWS+1] = frame
		--setglobal("ChatFrame" .. NUM_CHAT_WINDOWS+1, frame)
		frame:Show()
		if (TF3:IsDebug()) then TF3:SendMessageToChat(debugFrame,"TF3: created the frame " .. window) end
		if frame then
			DEFAULT_CHAT_FRAME:AddMessage("TF3: created the frame " .. window .. "", 1.0, 0.0, 0.0, 0.0, 53, 5.0)
			frame:AddMessage("TF3: created the frame " .. window)
		end
		
		for i=1,NUM_CHAT_WINDOWS do
			name, fontSize, r, g, b, alpha, shown, locked, docked = GetChatWindowInfo(i)
			if (TF3:IsDebug()) then TF3:SendMessageToChat(debugFrame, name .. " found") end
			if (name == window) then
				SetChatWindowShown(i, true)
				SetChatWindowDocked(i, true)
				SetChatWindowAlpha(i, 50)
			end
		end
	end
]]--

	for i=1,NUM_CHAT_WINDOWS do
		name, fontSize, r, g, b, alpha, shown, locked, docked = GetChatWindowInfo(i)
		if (TF3:IsDebug()) then
			TF3:SendMessageToChat(debugFrame, name .. " found")
		end
		if (name == window) then
			SetChatWindowShown(i, true)
			--SetChatWindowDocked(i+1, true)
			--SetChatWindowAlpha(i, 50)
			frame = getglobal("ChatFrame" .. i)
			frame:AddMessage("TradeFilter3: found the frame " .. window);
		end
	end
	
	return frame
end

--[[ Chat Functions ]]--
function TF3:SendMessageToChat(frame, message)
	if frame then
		frame:AddMessage(message)
	end
end

--[[ PreFilter ]]--
local function PreFilter_OnEvent(...)
	--[[ Taken from SpamMeNot
		arg1:	chat message 
		arg2:	author 
		arg7:	zone ID used for generic system channels (1 for General, 
				2 for Trade, 22 for LocalDefense, 23 for WorldDefense and 
				26 for LFG)	not used for custom channels or if you joined 
				an Out-Of-Zone channel ex: "General - Stormwind City" 
		arg8:	channel number 
	]]
	  -- the arguments a1..a9 are all nil until Blizzard actually passes them
    -- we're expected to use global variables which is generally a bad idea
    -- global variables may not be available in a later patch so we have to do this:
	local filtered = false
	local userID = arg2 or select(2, ...)
	local zoneID = arg7 or select(7, ...)
	local chanID = arg8 or select(8, ...)
	--TF3:SendMessageToChat(debugFrame,"userID, zoneID, chanID")
	if (TF3:IsDebug() and debugFrame == nil) then
		debugFrame = TF3:FindOrCreateChatWindow("DEBUG", true)
		TF3:SendMessageToChat(debugFrame,"*** Debug is ON: Passing PreFilter ***")
	end
	if (TF3:IsRedirect() and redirectFrame == nil) then
		redirectFrame = TF3:FindOrCreateChatWindow("SPAM", true)
		TF3:SendMessageToChat(redirectFrame,"*** Redirect is ON: Passing PreFilter ***")
	end
	--[[ Check for Trade Channel and User setting ]]--
	if (zoneID == 2 and TF3:IsFilterTrade() and userID ~= UnitName("Player")) then
		filtered = TF3:TF3_OnEvent()
	elseif (zoneID == 2 and not TF3:IsFilterTrade()) then
		filtered = false
	end
	--[[ Check for General Channel and User setting ]]--
	if (chanID == 1 and TF3:IsFilterGeneral()and userID ~= UnitName("Player")) then
		filtered = TF3:TF3_OnEvent()
	elseif (chanID == 1 and not TF3:IsFilterGeneral()) then
		filtered = false
	end
	--[[ Check for LFG Channel and User setting ]]--
	if (zoneID == 26 and TF3:IsFilterLFG() and userID ~= UnitName("Player")) then
		filtered = TF3:TF3_OnEvent()
	elseif (chanID == 26 and not TF3:IsFilterLFG()) then
		filtered = false
	end
	--[[ Check for SAY Channel and User setting ]]--
	if (chanID == 0 and TF3:IsFilterSAY() and userID ~= UnitName("Player")) then
		filtered = TF3:TF3_OnEvent()
	elseif (chanID == 0 and not TF3:IsFilterSAY()) then
		filtered = false
	end	
	return filtered
end

--[[ Filter Func ]]--
function TF3:TF3_OnEvent(...)
	local filtered = false
	local filterFuncList = ChatFrame_GetMessageEventFilters("CHAT_MSG_CHANNEL")
	if (TF3:IsDebug() and debugFrame == nil) then
		debugFrame = TF3:FindOrCreateChatWindow("DEBUG", true)
		TF3:SendMessageToChat(debugFrame,"*** Debug is ON ***")
	end
	if (TF3:IsRedirect() and redirectFrame == nil) then
		redirectFrame = TF3:FindOrCreateChatWindow("SPAM", true)
		TF3:SendMessageToChat(redirectFrame,"*** Redirect is ON ***")
	end
	if (filterFuncList and TF3:IsTurnOn()) then
		filtered = true
		if (TF3:IsDebug()) then
			TF3:SendMessageToChat(debugFrame, "arg1: " .. arg1 .. " arg2: " .. arg2)
		end
		for i, matchIt in ipairs(TF3.db.profile.filter) do
			if (TF3:IsDebug() and not TF3:GetAddFilter()) then
				TF3:SendMessageToChat(debugFrame, "Checking for Match with " .. matchIt[1])
			elseif (TF3:IsDebug() and TF3:GetAddFilter()) then
				TF3:SendMessageToChat(debugFrame, "Checking for Match with " .. matchIt[1])
				TF3:SendMessageToChat(debugFrame, TF3.db.profile.addfilter1)
				TF3:SendMessageToChat(debugFrame, TF3.db.profile.addfilter2)
				TF3:SendMessageToChat(debugFrame, TF3.db.profile.addfilter3)
			end
			if(not TF3:GetAddFilter()) then
				if matchIt[2] and string.find(arg1, matchIt[1]) then
					if (TF3:IsDebug()) then
						TF3:SendMessageToChat(debugFrame, "|cff00ff00**** Matched ***|r")
					end
					filtered = false
				end
			elseif(TF3:GetAddFilter()) then
				if matchIt[2] and string.find(arg1, matchIt[1]) or string.find(arg1, TF3.db.profile.addfilter1) or string.find(arg1, TF3.db.profile.addfilter2) or string.find(arg1, TF3.db.profile.addfilter3) then
					if (TF3:IsDebug()) then
						TF3:SendMessageToChat(debugFrame, "|cff00ff00**** Matched ***|r")
					end
					filtered = false
				end
			end
		end
		if filtered == true then
			if lastArg1 ~= arg1 or lastArg2 ~= arg2 then
				if (TF3:IsDebug()) then
					TF3:SendMessageToChat(debugFrame, "|cff00ff00*** NO Match - Redirected ***|r")
				end
				if (TF3:IsRedirect()) then
					TF3:SendMessageToChat(redirectFrame, "zID" .. string.format(CHAT_CHANNEL_GET, arg7) .. " cID" .. string.format(CHAT_CHANNEL_GET, arg8) .. " " .. string.format(CHAT_CHANNEL_GET, arg2) .. arg1)
				end
				lastArg1, lastArg2 = arg1, arg2
			end
		end
	end
	return filtered
end

--[[ Pass ALL chat messages to PreFilter function ]]--
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", PreFilter_OnEvent)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", PreFilter_OnEvent)
