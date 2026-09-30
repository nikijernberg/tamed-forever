local ADDON_NAME, Addon = ...
local Colors = Addon:GetModule("Colors")
local DB = Addon:GetModule("DB")
local TameableNPCs = Addon.TameableNPCs

local function AppendNPCTooltip(tooltip)
  local ok = pcall(function()
    if not DB.global or not DB.global.npc_tooltips then
      return
    end
    if not tooltip or not tooltip.GetUnit then
      return
    end
    local _, unit = tooltip:GetUnit()
    local id = Addon:GetCreatureID(unit)
    if not id then
      return
    end
    local npc = TameableNPCs[id]
    if not npc then
      return
    end
    tooltip:AddLine(Colors.Primary(Addon.DISPLAY_NAME or ADDON_NAME))
    if type(npc.abilities) == "table" then
      for _, ability in ipairs(npc.abilities) do
        tooltip:AddLine("  " .. ability, 1, 1, 1)
      end
    end
  end)
  return ok
end

local hooked = false

local function TryModernTooltip()
  if not (TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall) then
    return false
  end
  local tooltipType = Enum and Enum.TooltipDataType and Enum.TooltipDataType.Unit
  if not tooltipType then
    return false
  end
  TooltipDataProcessor.AddTooltipPostCall(tooltipType, function(tooltip)
    AppendNPCTooltip(tooltip)
  end)
  return true
end

if not TryModernTooltip() then
  if GameTooltip and GameTooltip.HookScript then
    -- Legacy fallback only if the modern processor is missing.
    pcall(function()
      GameTooltip:HookScript("OnTooltipSetUnit", function(self)
        AppendNPCTooltip(self)
      end)
    end)
  end
end
