local _, Addon = ...
local AbilityGroup = Addon:GetModule("AbilityGroup")
local Colors = Addon:GetModule("Colors")
local L = Addon:GetModule("Locale")
local Widgets = Addon:GetModule("Widgets")

function AbilityGroup:Create(parent, ability, rankIndex)
  local title = ("%s (%s %s)"):format(ability.name, L.RANK, rankIndex)
  local spellID = ability.ranks[rankIndex] and ability.ranks[rankIndex].spell_id
  Widgets:Button({
    parent = parent,
    fullWidth = true,
    text = "|cFFFFFFFF" .. title .. "|r",
    height = 34,
    onEnter = function()
      if not spellID then
        return
      end
      GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
      if GameTooltip.SetSpellByID then
        GameTooltip:SetSpellByID(spellID)
      else
        GameTooltip:SetHyperlink("spell:" .. spellID)
      end
      GameTooltip:Show()
    end,
    onLeave = function()
      GameTooltip:Hide()
    end
  })

  self:AddPetLevelGroup(parent, ability, rankIndex)
  self:AddTrainingCostGroup(parent, ability, rankIndex)
  self:AddLearnedByGroup(parent, ability)
  self:AddTameableNPCsGroup(parent, ability, rankIndex)
end

function AbilityGroup:AddPetLevelGroup(parent, ability, rankIndex)
  parent = Widgets:InlineGroup({
    parent = parent,
    title = L.PET_LEVEL,
    fullWidth = true,
  })
  Widgets:Label({
    parent = parent,
    text = ability.ranks[rankIndex].pet_level or 1,
    fullWidth = true
  })
end

function AbilityGroup:AddTrainingCostGroup(parent, ability, rankIndex)
  parent = Widgets:InlineGroup({
    parent = parent,
    title = L.TRAINING_COST,
    fullWidth = true,
  })
  Widgets:Label({
    parent = parent,
    text = ability.ranks[rankIndex].training_cost or 0,
    fullWidth = true
  })
end

function AbilityGroup:AddLearnedByGroup(parent, ability)
  parent = Widgets:InlineGroup({
    parent = parent,
    title = L.LEARNABLE_BY,
    fullWidth = true,
  })
  Widgets:Label({
    parent = parent,
    text = (
      #ability.learned_by > 0 and
        table.concat(ability.learned_by, ", ") or
        L.ALL_PET_FAMILIES
    ),
    fullWidth = true
  })
end

function AbilityGroup:AddTameableNPCsGroup(parent, ability, rankIndex)
  parent = Widgets:InlineGroup({
    parent = parent,
    title = L.TAMEABLE_NPCS,
    fullWidth = true
  })

  local npc_ids = ability.ranks[rankIndex].npc_ids
  if #npc_ids > 0 then
    for _, npc_id in ipairs(npc_ids) do
      local npc = Addon.TameableNPCs[tostring(npc_id)]
      self:AddNPC(parent, npc)
    end
  else
    Widgets:Label({
      parent = parent,
      text = L.NONE,
      fullWidth = true
    })
  end
end

function AbilityGroup:AddNPC(parent, npc)
  if not npc then return end

  local LABEL_S = Colors.Label("%s:") .. " %s"

  parent = Widgets:InlineGroup({
    parent = parent,
    title = Colors.Primary(npc.name),
    fullWidth = true
  })

  Widgets:Label({
    parent = parent,
    text = LABEL_S:format(L.LEVEL, npc.level_range),
    fullWidth = true
  })
  Widgets:Label({
    parent = parent,
    text = LABEL_S:format(L.ABILITIES, table.concat(npc.abilities or {}, ", ")),
    fullWidth = true
  })
  Widgets:Label({
    parent = parent,
    text = LABEL_S:format(L.FAMILY, npc.family),
    fullWidth = true
  })
  Widgets:Label({
    parent = parent,
    text = LABEL_S:format(L.DIET, npc.diet),
    fullWidth = true
  })
  Widgets:Label({
    parent = parent,
    text = LABEL_S:format(L.TYPE, npc.type),
    fullWidth = true
  })
  Widgets:Label({
    parent = parent,
    text = LABEL_S:format(L.LOCATION, npc.location),
    fullWidth = true
  })

  local b = Widgets:Button({
    parent = parent,
    text = L.SHOW_ON_MAP,
    onClick = function()
      Addon:ShowNPCOnMap(npc)
    end,
  })

  if not npc.ui_map_id or not npc.coords or #npc.coords == 0 then
    b:SetText(L.MAP_UNAVAILABLE)
    b:SetDisabled(true)
  end
end
