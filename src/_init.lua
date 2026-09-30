local ADDON_NAME, Addon = ...

Addon.ADDON_NAME = ADDON_NAME
Addon.DISPLAY_NAME = "Tamed Forever"
Addon.VERSION = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")) or "1.0.0-forever"
Addon.ICON = "Interface\\ICONS\\Ability_Hunter_BeastTaming"
Addon.DATA_ORIGIN = "imported-from-tamed"
Addon.DATA_FOREVER_STATUS = "unverified"

do
  local modules = {}

  function Addon:GetModule(key)
    key = key:upper()
    if type(modules[key]) ~= "table" then
      modules[key] = {}
    end
    return modules[key]
  end
end

do
  local libraries = {}

  local function TryLib(name)
    local ok, lib = pcall(function()
      return LibStub(name)
    end)
    if ok then
      return lib
    end
    return nil
  end

  local aceAddon
  local aceOk, aceLib = pcall(function()
    return LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0")
  end)
  if aceOk then
    aceAddon = aceLib
  end

  libraries.AceAddon = aceAddon
  libraries.AceGUI = TryLib("AceGUI-3.0")
  libraries.LDB = TryLib("LibDataBroker-1.1")
  libraries.LDBIcon = TryLib("LibDBIcon-1.0")

  function Addon:GetLibrary(key, silent)
    local lib = libraries[key]
    if lib then
      return lib
    end
    if silent then
      return nil
    end
    return error("Invalid or unavailable library: " .. tostring(key))
  end

  function Addon:HasLibrary(key)
    return libraries[key] ~= nil
  end
end

local function InitializeAddon()
  if Addon._initialized then
    return
  end
  Addon._initialized = true
  Addon:GetModule("DB"):Initialize()
  local minimapOk, minimapErr = pcall(function()
    Addon:GetModule("MinimapIcon"):Initialize()
  end)
  Addon._minimapInitOk = minimapOk
  Addon._minimapInitErr = minimapErr
  Addon:GetModule("Commands"):Initialize()
  Addon:GetModule("Data"):StartSpellLoading()
end

do
  local AceAddon = Addon:GetLibrary("AceAddon", true)
  if AceAddon then
    function AceAddon:OnInitialize()
      InitializeAddon()
    end
  else
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(_, _, name)
      if name == ADDON_NAME then
        InitializeAddon()
      end
    end)
  end
end
