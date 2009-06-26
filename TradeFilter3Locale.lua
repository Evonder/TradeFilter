--[[
File Author: @file-author@
File Revision: @file-revision@
File Date: @file-date-iso@
]]--
local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local L =  LibStub("AceLocale-3.0"):NewLocale("TradeFilter3", "enUS", true, debug)
if L then
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, handle-subnamespaces="concat")@
if GetLocale() == "enUS" then return end
end

local L =  LibStub("AceLocale-3.0"):NewLocale("TradeFilter3", "deDE", true, debug)
if L then
--@localization(locale="deDE", format="lua_additive_table", same-key-is-true=true, handle-subnamespaces="concat")@
if GetLocale() == "deDE" then return end
end

local L =  LibStub("AceLocale-3.0"):NewLocale("TradeFilter3", "zhCN", true, debug)
if L then
--@localization(locale="zhCN", format="lua_additive_table", same-key-is-true=true, handle-subnamespaces="concat")@
if GetLocale() == "zhCN" then return end
end

local L =  LibStub("AceLocale-3.0"):NewLocale("TradeFilter3", "zhTW", true, debug)
if L then
--@localization(locale="zhTW", format="lua_additive_table", same-key-is-true=true, handle-subnamespaces="concat")@
if GetLocale() == "zhTW" then return end
end
