local ADDON_NAME, Addon = ...
local Commands = Addon:GetModule("Commands")
local PinHelper = Addon:GetModule("PinHelper")
local UI = Addon:GetModule("UI")

local function HandleInput(input)
  local s = input
  if type(s) == "string" then
    local cmd
    local AceAddon = Addon:GetLibrary("AceAddon", true)
    if AceAddon and AceAddon.GetArgs then
      cmd = AceAddon:GetArgs(s)
    else
      cmd = s:match("^(%S+)")
    end
    if cmd then
      cmd = cmd:lower()
    end
    if cmd == "clear" then
      PinHelper:Clear()
      return
    end
    if cmd == "debug" then
      Addon:GetModule("Debug"):Print()
      return
    end
  end
  UI:Toggle()
end

function Commands:Initialize()
  local AceAddon = Addon:GetLibrary("AceAddon", true)
  if AceAddon and AceAddon.RegisterChatCommand then
    AceAddon:RegisterChatCommand("tamed", HandleInput)
    AceAddon:RegisterChatCommand("tamed_forever", HandleInput)
  else
    SLASH_TAMEDFOREVER1 = "/tamed"
    SLASH_TAMEDFOREVER2 = "/tamed_forever"
    SlashCmdList.TAMEDFOREVER = HandleInput
  end
  self.Initialize = nil
end
