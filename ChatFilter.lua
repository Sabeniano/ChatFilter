-- ChatFilter Addon - Isolated Namespace with Global Monitoring and Alert Formatting

local addonName, addonTable = ...
addonTable.frame = CreateFrame("Frame")
addonTable.whitelistedWords = {}  -- Table for user-defined words to monitor

ChatFilterDB = ChatFilterDB or {}

--------------------------------------------------
-- Save & Load
--------------------------------------------------
local function SaveWords()
    ChatFilterDB.whitelistedWords = {}
    for word in pairs(addonTable.whitelistedWords) do
        table.insert(ChatFilterDB.whitelistedWords, word)
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[ChatFilter]:|r Whitelist saved.")
end

local function LoadWords()
    if ChatFilterDB.whitelistedWords then
        for _, word in ipairs(ChatFilterDB.whitelistedWords) do
            addonTable.whitelistedWords[word:lower()] = true
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[ChatFilter]:|r Whitelist loaded.")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[ChatFilter]:|r No saved whitelist found.")
    end
end

--------------------------------------------------
-- Chat Monitoring
--------------------------------------------------
local function OnChatMessage(self, event, message, sender, channel, ...)
    for word in pairs(addonTable.whitelistedWords) do
        if message:lower():find(word) then
            local clickableName = "|Hplayer:" .. sender .. "|h|cff3399ff" .. sender .. "|r|h"
            if SELECTED_CHAT_FRAME and SELECTED_CHAT_FRAME.name == "Alert" then
                SELECTED_CHAT_FRAME:AddMessage("|cffffffff[|r|cff3399ffAlert|r|cffffffff]|r: " .. clickableName .. ": |cffffffff" .. message .. "|r")
            else
                -- Only fallback if the "Alert" tab doesn't exist
                local alertTabFound = false
                for i = 1, NUM_CHAT_WINDOWS do
                    local chatFrame = _G["ChatFrame" .. i]
                    if chatFrame.name == "Alert" then
                        chatFrame:AddMessage("|cffffffff[|r|cff3399ffAlert|r|cffffffff]|r: " .. clickableName .. ": |cffffffff" .. message .. "|r")
                        alertTabFound = true
                        break
                    end
                end
                if not alertTabFound then
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|r|cff3399ffAlert|r|cffffffff]|r: " .. clickableName .. ": |cffffffff" .. message .. "|r")
                end
            end

            -- Attempt to flash the taskbar if supported
            if FlashClientIcon then
                FlashClientIcon()
            end
        end
    end
end

--------------------------------------------------
-- ADDON_LOADED
--------------------------------------------------
local function OnAddonLoaded(self, event, addon)
    if addon == addonName then
        LoadWords()
        addonTable.frame:RegisterEvent("CHAT_MSG_CHANNEL")
        addonTable.frame:RegisterEvent("CHAT_MSG_SAY")
        addonTable.frame:RegisterEvent("CHAT_MSG_WHISPER")
        addonTable.frame:RegisterEvent("CHAT_MSG_YELL")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[ChatFilter]:|r ADDON_LOADED - DB loaded.")
    end
end

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        OnAddonLoaded(self, event, ...)
    else
        OnChatMessage(self, event, ...)
    end
end

addonTable.frame:SetScript("OnEvent", OnEvent)
addonTable.frame:RegisterEvent("ADDON_LOADED")

--------------------------------------------------
-- Slash Commands
--------------------------------------------------
SLASH_CHATFILTER1 = "/cfaddon"
SLASH_CHATFILTER2 = "/cf"

function SlashCmdList.CHATFILTER(msg)
    local command, arg = msg:match("^(%S*)%s*(.-)$")

    if command == "add" and arg ~= "" then
        addonTable.whitelistedWords[arg:lower()] = true
        SaveWords()
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[ChatFilter]:|r Added word: " .. arg)
    elseif command == "remove" and arg ~= "" then
        addonTable.whitelistedWords[arg:lower()] = nil
        SaveWords()
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[ChatFilter]:|r Removed word: " .. arg)
    elseif command == "list" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[ChatFilter]:|r Whitelisted words:")
        for word in pairs(addonTable.whitelistedWords) do
            DEFAULT_CHAT_FRAME:AddMessage(" - " .. word)
        end
    elseif command == "clear" then
        addonTable.whitelistedWords = {}
        SaveWords()
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[ChatFilter]:|r Whitelist cleared.")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700[ChatFilter]:|r Commands:")
        DEFAULT_CHAT_FRAME:AddMessage("  /cfaddon add <word> - Add word")
        DEFAULT_CHAT_FRAME:AddMessage("  /cfaddon remove <word> - Remove word")
        DEFAULT_CHAT_FRAME:AddMessage("  /cfaddon list - List words")
        DEFAULT_CHAT_FRAME:AddMessage("  /cfaddon clear - Clear whitelist")
    end
end
