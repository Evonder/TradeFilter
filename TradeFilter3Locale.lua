--[[
File Author: @file-author@
File Revision: @file-abbreviated-hash@
File Date: @file-date-iso@
]]--
local debug = false
--@debug@
debug = true
--@end-debug@

local L =  LibStub("AceLocale-3.0"):NewLocale("TradeFilter3", "enUS", true)
if L then
--@localization(locale="enUS", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="enUS", namespace="BLACKLIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="enUS", namespace="FILTERS", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="enUS", namespace="FILTERS/BASE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="enUS", namespace="FILTERS/BG", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="enUS", namespace="FILTERS/SPECIAL", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="enUS", namespace="FILTERS/TRADE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="enUS", namespace="TOC", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="enUS", namespace="WHITELIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
if GetLocale() == "enUS" then return end
end

local L =  LibStub("AceLocale-3.0"):NewLocale("TradeFilter3", "deDE")
if L then
--@localization(locale="deDE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="deDE", namespace="BLACKLIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="deDE", namespace="FILTERS", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="deDE", namespace="FILTERS/BASE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="deDE", namespace="FILTERS/BG", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="deDE", namespace="FILTERS/SPECIAL", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="deDE", namespace="FILTERS/TRADE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="deDE", namespace="TOC", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="deDE", namespace="WHITELIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
if GetLocale() == "deDE" then return end
end

local L =  LibStub("AceLocale-3.0"):NewLocale("TradeFilter3", "zhCN")
if L then
--@localization(locale="zhCN", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhCN", namespace="BLACKLIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhCN", namespace="FILTERS", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhCN", namespace="FILTERS/BASE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhCN", namespace="FILTERS/BG", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhCN", namespace="FILTERS/SPECIAL", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhCN", namespace="FILTERS/TRADE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhCN", namespace="TOC", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhCN", namespace="WHITELIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
if GetLocale() == "zhCN" then return end
end

local L =  LibStub("AceLocale-3.0"):NewLocale("TradeFilter3", "zhTW")
if L then
--@localization(locale="zhTW", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhTW", namespace="BLACKLIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhTW", namespace="FILTERS", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhTW", namespace="FILTERS/BASE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhTW", namespace="FILTERS/BG", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhTW", namespace="FILTERS/SPECIAL", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhTW", namespace="FILTERS/TRADE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhTW", namespace="TOC", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="zhTW", namespace="WHITELIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
if GetLocale() == "zhTW" then return end
end

local L =  LibStub("AceLocale-3.0"):NewLocale("TradeFilter3", "koKR")
if L then
--@localization(locale="koKR", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="koKR", namespace="BLACKLIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="koKR", namespace="FILTERS", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="koKR", namespace="FILTERS/BASE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="koKR", namespace="FILTERS/BG", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="koKR", namespace="FILTERS/SPECIAL", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="koKR", namespace="FILTERS/TRADE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="koKR", namespace="TOC", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="koKR", namespace="WHITELIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
if GetLocale() == "koKR" then return end
end

local L =  LibStub("AceLocale-3.0"):NewLocale("TradeFilter3", "frFR")
if L then
--@localization(locale="frFR", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="frFR", namespace="BLACKLIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="frFR", namespace="FILTERS", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="frFR", namespace="FILTERS/BASE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="frFR", namespace="FILTERS/BG", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="frFR", namespace="FILTERS/SPECIAL", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="frFR", namespace="FILTERS/TRADE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="frFR", namespace="TOC", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="frFR", namespace="WHITELIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
if GetLocale() == "frFR" then return end
end

local L =  LibStub("AceLocale-3.0"):NewLocale("TradeFilter3", "ruRU")
if L then
--@localization(locale="ruRU", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="ruRU", namespace="BLACKLIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="ruRU", namespace="FILTERS", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="ruRU", namespace="FILTERS/BASE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="ruRU", namespace="FILTERS/BG", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="ruRU", namespace="FILTERS/SPECIAL", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="ruRU", namespace="FILTERS/TRADE", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="ruRU", namespace="TOC", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
--@localization(locale="ruRU", namespace="WHITELIST", format="lua_additive_table", handle-unlocalized="english", same-key-is-true=true, handle-subnamespaces="concat")@
if GetLocale() == "ruRU" then return end
end
