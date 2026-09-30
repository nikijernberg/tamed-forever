local ADDON_NAME, Addon = ...
local Debug = Addon:GetModule("Debug")
local Compat = Addon:GetModule("Compat")
local PinHelper = Addon:GetModule("PinHelper")

local function Count(tbl)
  local n = 0
  if type(tbl) ~= "table" then
    return 0
  end
  for _ in pairs(tbl) do
    n = n + 1
  end
  return n
end

local function PrintLine(text)
  print("|cffaad372[Tamed Forever]|r " .. tostring(text))
end

function Debug:Print()
  local version = Addon.VERSION or "?"
  local build = "?"
  if GetBuildInfo then
    local ok, a, b, c, d = pcall(GetBuildInfo)
    if ok then
      build = table.concat({ tostring(a), tostring(b), tostring(c), tostring(d) }, " / ")
    end
  end

  local unresolved = {}
  for spellID in pairs(Compat.unresolvedSpellIds) do
    unresolved[#unresolved + 1] = tostring(spellID)
    if #unresolved >= 20 then
      break
    end
  end

  PrintLine("version=" .. version)
  PrintLine("addon=" .. ADDON_NAME)
  PrintLine("build=" .. build)
  PrintLine("C_Spell.GetSpellInfo=" .. tostring(C_Spell and C_Spell.GetSpellInfo ~= nil))
  PrintLine("C_Spell.RequestLoadSpellData=" .. tostring(C_Spell and C_Spell.RequestLoadSpellData ~= nil))
  PrintLine("C_Map.GetMapInfo=" .. tostring(C_Map and C_Map.GetMapInfo ~= nil))
  PrintLine("C_Map.GetAreaInfo=" .. tostring(C_Map and C_Map.GetAreaInfo ~= nil))
  PrintLine("C_Map.SetUserWaypoint=" .. tostring(C_Map and C_Map.SetUserWaypoint ~= nil))
  PrintLine("WorldMapFrame=" .. tostring(WorldMapFrame ~= nil))
  PrintLine("map pins=" .. tostring(PinHelper.status or "uninitialized"))
  PrintLine("abilities=" .. Count(Addon.TameableAbilities))
  PrintLine("npcs=" .. Count(Addon.TameableNPCs))
  PrintLine("unresolved spells=" .. Count(Compat.unresolvedSpellIds) .. (unresolved[1] and (" sample=" .. table.concat(unresolved, ",")) or ""))
  PrintLine("AceAddon=" .. tostring(Addon:HasLibrary("AceAddon")))
  PrintLine("AceGUI=" .. tostring(Addon:HasLibrary("AceGUI")))
  PrintLine("LDB=" .. tostring(Addon:HasLibrary("LDB")))
  PrintLine("LDBIcon=" .. tostring(Addon:HasLibrary("LDBIcon")))
  PrintLine("minimap init=" .. tostring(Addon._minimapInitOk))
  PrintLine("data origin=" .. tostring(Addon.DATA_ORIGIN) .. " / " .. tostring(Addon.DATA_FOREVER_STATUS))
end
