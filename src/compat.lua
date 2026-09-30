local _, Addon = ...

local Compat = Addon:GetModule("Compat")
Compat.unresolvedSpellIds = {}
Compat.spellInfoCache = {}

local function IsSecret(value)
  if value == nil then
    return false
  end
  if issecretvalue then
    local ok, secret = pcall(issecretvalue, value)
    return ok and secret
  end
  return false
end

function Addon:SafeText(value, fallback)
  if value == nil then
    return fallback
  end
  if IsSecret(value) then
    return fallback
  end
  return value
end

function Addon:SafeCall(fn, ...)
  if type(fn) ~= "function" then
    return false
  end
  return pcall(fn, ...)
end

function Addon:GetSpellInfo(spellID)
  spellID = tonumber(spellID)
  if not spellID then
    return nil
  end
  local cached = Compat.spellInfoCache[spellID]
  if cached then
    return cached
  end
  if not (C_Spell and C_Spell.GetSpellInfo) then
    return nil
  end
  local ok, info = pcall(C_Spell.GetSpellInfo, spellID)
  if not ok or type(info) ~= "table" then
    Compat.unresolvedSpellIds[spellID] = true
    return nil
  end
  local result = {
    name = info.name,
    icon = info.iconID or info.originalIconID,
    spellID = info.spellID or spellID,
  }
  if type(result.name) == "string" then
    Compat.spellInfoCache[spellID] = result
    Compat.unresolvedSpellIds[spellID] = nil
  else
    Compat.unresolvedSpellIds[spellID] = true
  end
  return result
end

function Addon:RequestSpellInfo(spellID)
  spellID = tonumber(spellID)
  if not spellID then
    return
  end
  if C_Spell and C_Spell.RequestLoadSpellData then
    pcall(C_Spell.RequestLoadSpellData, spellID)
  end
end

function Addon:GetMapName(mapID)
  mapID = tonumber(mapID)
  if not mapID then
    return nil
  end
  if C_Map and C_Map.GetMapInfo then
    local ok, info = pcall(C_Map.GetMapInfo, mapID)
    if ok and type(info) == "table" and type(info.name) == "string" then
      return info.name
    end
  end
  return nil
end

function Addon:GetAreaName(areaID)
  areaID = tonumber(areaID)
  if not areaID then
    return nil
  end
  if C_Map and C_Map.GetAreaInfo then
    local ok, name = pcall(C_Map.GetAreaInfo, areaID)
    if ok and type(name) == "string" and name ~= "" then
      return name
    end
  end
  return nil
end

function Addon:GetCreatureID(unit)
  if not unit then
    return nil
  end
  if not UnitGUID then
    return nil
  end
  local ok, guid = pcall(UnitGUID, unit)
  if not ok or type(guid) ~= "string" or guid == "" then
    return nil
  end
  local unitType, _, _, _, _, id = strsplit("-", guid)
  if unitType == "Creature" and id then
    return id
  end
  return nil
end

function Addon:ShowWorldMap(mapID)
  if C_AddOns and C_AddOns.LoadAddOn then
    pcall(C_AddOns.LoadAddOn, "Blizzard_WorldMap")
  elseif LoadAddOn then
    pcall(LoadAddOn, "Blizzard_WorldMap")
  end
  if not WorldMapFrame then
    return false
  end
  if ShowUIPanel then
    pcall(ShowUIPanel, WorldMapFrame)
  else
    pcall(function()
      WorldMapFrame:Show()
    end)
  end
  mapID = tonumber(mapID)
  if mapID and WorldMapFrame.SetMapID then
    pcall(WorldMapFrame.SetMapID, WorldMapFrame, mapID)
  end
  return true
end

function Addon:ShowNPCOnMap(npc)
  local pins = Addon:GetModule("PinHelper")
  if pins.ShowNPC then
    return pins:ShowNPC(npc)
  end
  return false
end

function Addon:PercentToMapCoord(value)
  value = tonumber(value)
  if not value then
    return nil
  end
  -- Original Tamed stores zone percents (0-100). MapCanvas uses 0-1.
  if value > 1 then
    return value * 0.01
  end
  return value
end

do
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("SPELL_DATA_LOAD_RESULT")
  frame:SetScript("OnEvent", function(_, event, spellID, success)
    if event ~= "SPELL_DATA_LOAD_RESULT" then
      return
    end
    spellID = tonumber(spellID)
    if not spellID then
      return
    end
    -- success may be false when only partial data exists; still try to read.
    Addon:GetSpellInfo(spellID)
    local Data = Addon:GetModule("Data")
    if Data.OnSpellLoaded then
      Data:OnSpellLoaded(spellID)
    end
  end)
end
