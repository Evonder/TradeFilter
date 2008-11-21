--[[

TradeFilter
		Filter that shit!

By Evonder (evonder@gmail.com) AKA: Networkerror

Basic structure and code ripped from crashmstr (wowzn@crashmstr.com)
		which was ripped from TasteTheNaimbow (Thank you Guillotine!)

Versioning:
	v1.0
			- Initial release for WotLK
			- Added Custom Filter option

* Copyright (c) <year>, <copyright holder>
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
local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("TradeFilter")

TradeFilter = Rock:NewAddon("TradeFilter", "LibRockDB-1.0", "LibRockConfig-1.0", "LibRockEvent-1.0", "LibRockHook-1.0", "LibRockTimer-1.0", "LibRockConsole-1.0")

local MAJOR_VERSION = "1.0"
local MINOR_VERSION = 000 + tonumber(("$Revision: 8 $"):match("%d+"))
TradeFilter.version = MAJOR_VERSION .. "r" .. MINOR_VERSION
TradeFilter.date = string.sub("$Date: 2008-11-21 12:00:00 -0800 (Fri, 21 Nov 2008) $", 8, 17)

TradeFilter:SetDatabase("TradeFilterDB")
TradeFilter:SetDatabaseDefaults('profile', {
	turnOn = true,
	redirect = false,
	debug = false,
	addfilter = false,
	addfilter1 = "Add Custom Filter 1",
	addfilter2 = "Add Custom Filter 2",
	addfilter3 = "Add Custom Filter 3",
	filter = {
		{"[wW][tT][bBsStT]",true},
		{"[lL][fF][wWeE]",true},
		{"LFEnchant",true},
		{"LF [eE][nN][cC][hH][aA][nN][tT]",true},
		{"LF [jJ][cC]",true},
		{"[lL][fF]%d[mM]?",true},
		{"[lL][fF][gG]",true},
		{"AH",true},
		{"looking for work",true},
		{"lockpick",true},
		{"[sS][eE][lL][lL][iI][nN][gG]",true},
		{"3[vV]3",true},
		{"5[vV]5",true},
	}
})

function TradeFilter:GetAddFilter()
	return self.db.profile.addfilter
end

function TradeFilter:SetAddFilter()
	self.db.profile.addfilter = not self.db.profile.addfilter
end

function TradeFilter:GetAddFilter1()
	return self.db.profile.addfilter1
end

function TradeFilter:SetAddFilter1(v)
	self.db.profile.addfilter1 = ""..v..""
end

function TradeFilter:GetAddFilter2()
	return self.db.profile.addfilter2
end

function TradeFilter:SetAddFilter2(v)
	self.db.profile.addfilter2 = ""..v..""
end

function TradeFilter:GetAddFilter3()
	return self.db.profile.addfilter3
end

function TradeFilter:SetAddFilter3(v)
	self.db.profile.addfilter3 = ""..v..""
end

function TradeFilter:IsFilterGeneral()
	return self.db.profile.filtergeneral
end

function TradeFilter:ToggleFilterGeneral()
	self.db.profile.filtergeneral = not self.db.profile.filtergeneral
end

function TradeFilter:IsFilterTrade()
	return self.db.profile.filtertrade
end

function TradeFilter:ToggleFilterTrade()
	self.db.profile.filtertrade = not self.db.profile.filtertrade
end

function TradeFilter:IsDebug()
	return self.db.profile.debug
end

function TradeFilter:ToggleDebug()
	self.db.profile.debug = not self.db.profile.debug
end

function TradeFilter:IsRedirect()
	return self.db.profile.redirect
end

function TradeFilter:ToggleRedirect()
	self.db.profile.redirect = not self.db.profile.redirect
end

function TradeFilter:IsTurnOn()
	return self.db.profile.turnOn
end

function TradeFilter:ToggleTurnOn()
	self.db.profile.turnOn = not self.db.profile.turnOn
end

function TradeFilter:OnEnable()
	TradeFilter:AddTimer(0, "PostEnable")
end

function TradeFilter:PostEnable()
	print("|cFF33FF99TradeFilter|r: " .. TradeFilter.version .. " |cff00ff00Enabled|r")
end 

function TradeFilter:OnDisable()
	print("|cFF33FF99TradeFilter|r: " .. TradeFilter.version .. " |cffff8080Disabled|r")
end

function TradeFilter:OnInitialize()
local optionsTable = {
		name = "TradeFilter",
		desc = self.notes,
		handler = TradeFilter,
    type='group',
    args = {
			turnOn = {
				type = 'boolean',
				order = 1,
				name = L["TurnOn"],
				desc = L["TurnOnDesc"],
				get = "IsTurnOn",
				set = "ToggleTurnOn",
			},
			redirect = {
				type = 'boolean',
				order = 2,
				name = L["Redir"],
				desc = L["RedirDesc"],
				get = "IsRedirect",
				set = "ToggleRedirect",
			},
			debug = {
        type = 'boolean',
				order = 3,
				disabled = true,
        name = L["Debug"],
        desc = L["DebugDesc"],
        get = "IsDebug",
        set = "ToggleDebug",
			},
			reload = {
				type = 'execute',
				name = L["RUI"],
				desc = L["RUID"],
				buttonText = L["RUI"],
				func = function()
					_G.ReloadUI()
				end,
				--disabled = function()
				--	return not self:IsDebug or return not self:IsRedirect
				--end,
				order = -1,
			},
			channelGroup = {
				type = 'group',
				order = 1,
				disabled = false,
				name = "Channel Selection",
				desc = "Channel Selection [Not Implemented Yet]",
				args = {
					tradeChannel = {
						type = 'boolean',
						order = 1,
						disabled = false,
						name = "Trade Chat",
						desc = "Trade Chat",
						get = "IsFilterTrade",
						set = "ToggleFilterTrade",
					},
					generalChannel = {
						type = 'boolean',
						order = 2,
						disabled = false,
						name = "General Chat",
						desc = "General Chat",
						get = "IsFilterGeneral",
						set = "ToggleFilterGeneral",
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
						type = 'boolean',
						order = 1,
						name = L["AddFilter"],
						desc = L["AddFilterD"],
						get = "GetAddFilter",
						set = "SetAddFilter",
					},
					addFilter1 = {
						type = 'text',
						disabled = function()
							return not self:GetAddFilter()
						end,
						order = 2,
						name = L["AddFilter1"],
						desc = L["AddFilter1D"],
						get = "GetAddFilter1",
						set = "SetAddFilter1",
						usage = L["AddFilterUsage"],
					},
					addFilter2 = {
						type = 'text',
						disabled = function()
							return not self:GetAddFilter()
						end,
						order = 3,
						name = L["AddFilter2"],
						desc = L["AddFilter1D"],
						get = "GetAddFilter2",
						set = "SetAddFilter2",
						usage = L["AddFilterUsage"],
					},
					addFilter3 = {
						type = 'text',
						disabled = function()
							return not self:GetAddFilter()
						end,
						order = 4,
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
	self:SetConfigTable(optionsTable)
	self.OnMenuRequest = optionsTable
	self:SetConfigSlashCommand("/TradeFilter", "/Filter")
end

--[[ Locals ]]--
local _G = getfenv()
local redirectFrame = nil
local debugFrame = nil
local lastArg1
local lastArg2

--[[ Window Functions ]]--
function TradeFilter:FindOrCreateChatWindow(window, create)
	local frame = nil
--[[
	if frame == nil and create then
		frame = CreateFrame("Frame", window, UIParent)
		_G["ChatFrame" .. NUM_CHAT_WINDOWS+1] = frame
		--setglobal("ChatFrame" .. NUM_CHAT_WINDOWS+1, frame)
		frame:Show()
		if (TradeFilter:IsDebug()) then TradeFilter:SendMessageToChat(debugFrame,"TradeFilter: created the frame " .. window) end
		if frame then
			DEFAULT_CHAT_FRAME:AddMessage("TradeFilter: created the frame " .. window .. "", 1.0, 0.0, 0.0, 0.0, 53, 5.0)
			frame:AddMessage("TradeFilter: created the frame " .. window)
		end
		
		for i=1,NUM_CHAT_WINDOWS do
			name, fontSize, r, g, b, alpha, shown, locked, docked = GetChatWindowInfo(i)
			if (TradeFilter:IsDebug()) then TradeFilter:SendMessageToChat(debugFrame, name .. " found") end
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
		if (TradeFilter:IsDebug()) then
			TradeFilter:SendMessageToChat(debugFrame, name .. " found")
		end
		if (name == window) then
			SetChatWindowShown(i, true)
			--SetChatWindowDocked(i+1, true)
			--SetChatWindowAlpha(i, 50)
			frame = getglobal("ChatFrame" .. i)
			frame:AddMessage("TradeFilter: found the frame " .. window);
		end
	end
	
	return frame
end

--[[ Chat Functions ]]--
function TradeFilter:SendMessageToChat(frame, message)
	if frame then
		frame:AddMessage(message)
	end
end

local function TradeFilter_OnEvent(...)
	--[[ Taken from SpamMeNot
		arg1:	chat message 
		arg2:	author 
		arg3:	language 
		arg4:	channel name with number ex: "1. General - Stormwind City" 
				zone is always current zone even if not the same as the 
				channel name 
		arg5:	target 
				second player name when two users are passed for a 
				CHANNEL_NOTICE_USER (E.G. x kicked y) 
		arg6:	AFK/DND/GM "CHAT_FLAG_"..arg6 flags 
		arg7:	zone ID used for generic system channels (1 for General, 
				2 for Trade, 22 for LocalDefense, 23 for WorldDefense and 
				26 for LFG)	not used for custom channels or if you joined 
				an Out-Of-Zone channel ex: "General - Stormwind City" 
		arg8:	channel number 
		arg9:	channel name without number (this is _sometimes_ in lowercase) 
				zone is always current zone even if not the same as the 
				channel name 
		arg11:	spam id
	]]--
	local event = select(1, ...)
	local msg = select(2, ...)
	local author = select(3, ...)
	local status = select(7, ...)
	local zoneID = select(8, ...)
	local lineID = select(12, ...)
	local showIt = true
	local filterFuncList = ChatFrame_GetMessageEventFilters("CHAT_MSG_CHANNEL")
	if (TradeFilter:IsDebug() and debugFrame == nil) then
		debugFrame = TradeFilter:FindOrCreateChatWindow("DEBUG", true)
		TradeFilter:SendMessageToChat(debugFrame,"*** Debug is ON ***")
	end
	if (TradeFilter:IsRedirect() and redirectFrame == nil) then
		redirectFrame = TradeFilter:FindOrCreateChatWindow("SPAM", true)
		TradeFilter:SendMessageToChat(redirectFrame,"*** Redirect is ON ***")
	end
	if (filterFuncList and TradeFilter:IsTurnOn()) then
		--[[
		if (TradeFilter:IsFilterGeneral()) then
			if (zoneID == 2) then
				showIt = false
			end
		elseif (TradeFilter:IsFilterTrade()) then
			if (zoneID == 1) then
				showIt = false
			end
		elseif (TradeFilter:IsFilterTrade() and TradeFilter:IsFilterGeneral()) then
			if (zoneID == 1) or (zoneID == 2) then
				showIt = false
			end
			]]--
			if (zoneID == 2) then
				showIt = false
			if (TradeFilter:IsDebug()) then
				TradeFilter:SendMessageToChat(debugFrame, "arg1: " .. arg1 .. " arg2: " .. arg2)
			end
			for i, matchIt in ipairs(TradeFilter.db.profile.filter) do
				if (TradeFilter:IsDebug() and not TradeFilter:GetAddFilter()) then
					TradeFilter:SendMessageToChat(debugFrame, "Checking for Match with " .. matchIt[1])
				elseif (TradeFilter:IsDebug() and TradeFilter:GetAddFilter()) then
					TradeFilter:SendMessageToChat(debugFrame, "Checking for Match with " .. matchIt[1])
					TradeFilter:SendMessageToChat(debugFrame, TradeFilter.db.profile.addfilter1)
					TradeFilter:SendMessageToChat(debugFrame, TradeFilter.db.profile.addfilter2)
					TradeFilter:SendMessageToChat(debugFrame, TradeFilter.db.profile.addfilter3)
				end
				if(not TradeFilter:GetAddFilter()) then
					if matchIt[2] and string.find(arg1, matchIt[1]) then
						if (TradeFilter:IsDebug()) then
							TradeFilter:SendMessageToChat(debugFrame, "|cff00ff00**** Matched ***|r")
						end
						showIt = true
					end
				elseif(TradeFilter:GetAddFilter()) then
					if matchIt[2] and string.find(arg1, matchIt[1]) or string.find(arg1, TradeFilter.db.profile.addfilter1) or string.find(arg1, TradeFilter.db.profile.addfilter2) or string.find(arg1, TradeFilter.db.profile.addfilter3) then
						if (TradeFilter:IsDebug()) then
							TradeFilter:SendMessageToChat(debugFrame, "|cff00ff00**** Matched ***|r")
						end
						showIt = true
					end
				end
			end
			if showIt == false then
				if lastArg1 ~= arg1 or lastArg2 ~= arg2 then
					if (TradeFilter:IsDebug()) then
						TradeFilter:SendMessageToChat(debugFrame, "|cff00ff00*** NO Match - Redirected ***|r")
					end
					if (TradeFilter:IsRedirect()) then
						TradeFilter:SendMessageToChat(redirectFrame, string.format(CHAT_CHANNEL_GET, arg8) .. string.format(CHAT_CHANNEL_GET, arg2) .. arg1)
					end
					lastArg1, lastArg2 = arg1, arg2
					return true
				end
			end
		end
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", TradeFilter_OnEvent)
