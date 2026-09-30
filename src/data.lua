local _, Addon = ...
Addon.TameableAbilities = Addon.TameableAbilities or {}
Addon.TameableNPCs = Addon.TameableNPCs or {}
local Colors = Addon:GetModule("Colors")
local Data = Addon:GetModule("Data")
local L = Addon:GetModule("Locale")
local TameableAbilities = Addon.TameableAbilities
local TameableNPCs = Addon.TameableNPCs

Data.uiCallbacks = {}

local function AbilityIcon(ability)
  return ability.icon or Addon.ICON
end

local function FormatAbilityLine(ability, rankIndex)
  return ("|T%s:0|t %s |cFF9D9D9D(%s %s)|r"):format(
    AbilityIcon(ability),
    ability.name or "?",
    L.RANK,
    rankIndex
  )
end

function Data:RefreshNPCAbilities(npc_id, npc)
  local abilities = {}
  for _, ability in pairs(TameableAbilities) do
    for rankIndex, rank in ipairs(ability.ranks) do
      for _, id in ipairs(rank.npc_ids) do
        if npc_id == tostring(id) then
          abilities[#abilities + 1] = {
            ability.name or "",
            FormatAbilityLine(ability, rankIndex)
          }
        end
      end
    end
  end
  table.sort(abilities, function(a, b) return a[1] < b[1] end)
  npc.abilities = {}
  for _, v in ipairs(abilities) do
    npc.abilities[#npc.abilities + 1] = v[2]
  end
end

function Data:RefreshNPCLocation(npc)
  local areaName = Addon:GetAreaName(npc.zone_id)
  local mapName = Addon:GetMapName(npc.ui_map_id)
  npc.location = areaName or mapName or npc.location or ("Zone " .. tostring(npc.zone_id or "?"))
end

function Data:ApplySpellToAbility(ability)
  local firstRank = ability.ranks and ability.ranks[1]
  if not firstRank then
    return
  end
  local info = Addon:GetSpellInfo(firstRank.spell_id)
  if info and info.name then
    ability.name = info.name
    ability.icon = info.icon or ability.icon or Addon.ICON
  else
    ability.icon = ability.icon or Addon.ICON
    Addon:RequestSpellInfo(firstRank.spell_id)
  end
end

function Data:RebuildDerived()
  for npc_id, npc in pairs(TameableNPCs) do
    self:RefreshNPCLocation(npc)
    if npc.classification and npc.level_range and not npc._classificationApplied then
      npc.level_range = ("%s (%s)"):format(
        npc.level_range,
        Colors.Highlight(npc.classification)
      )
      npc._classificationApplied = true
    end
    self:RefreshNPCAbilities(npc_id, npc)
  end
end

function Data:OnSpellLoaded(spellID)
  for _, ability in pairs(TameableAbilities) do
    local firstRank = ability.ranks and ability.ranks[1]
    if firstRank and firstRank.spell_id == spellID then
      self:ApplySpellToAbility(ability)
    end
  end
  self:RebuildDerived()
  for _, cb in ipairs(self.uiCallbacks) do
    pcall(cb)
  end
end

function Data:StartSpellLoading()
  for _, ability in pairs(TameableAbilities) do
    if ability.ranks then
      for _, rank in ipairs(ability.ranks) do
        Addon:RequestSpellInfo(rank.spell_id)
      end
    end
    self:ApplySpellToAbility(ability)
  end
  self:RebuildDerived()
end

-- Overlay runtime fields without deleting static rows.
do
  for _, ability in pairs(TameableAbilities) do
    Data:ApplySpellToAbility(ability)
  end
  for npc_id, npc in pairs(TameableNPCs) do
    Data:RefreshNPCLocation(npc)
    if npc.classification and npc.level_range then
      npc.level_range = ("%s (%s)"):format(
        npc.level_range,
        Colors.Highlight(npc.classification)
      )
      npc._classificationApplied = true
    end
    Data:RefreshNPCAbilities(npc_id, npc)
  end
end
