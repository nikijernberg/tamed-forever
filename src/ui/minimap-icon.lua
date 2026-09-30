local ADDON_NAME, Addon = ...
local Colors = Addon:GetModule("Colors")
local DB = Addon:GetModule("DB")
local L = Addon:GetModule("Locale")
local MinimapIcon = Addon:GetModule("MinimapIcon")
local PinHelper = Addon:GetModule("PinHelper")
local UI = Addon:GetModule("UI")

function MinimapIcon:Initialize()
  local LDB = Addon:GetLibrary("LDB", true)
  local LDBIcon = Addon:GetLibrary("LDBIcon", true)
  if not (LDB and LDBIcon and LDB.NewDataObject) then
    self.available = false
    self.Initialize = nil
    return
  end

  local object = LDB:NewDataObject(ADDON_NAME, {
    type = "data source",
    text = Addon.DISPLAY_NAME,
    icon = Addon.ICON,
    OnClick = function(_, button)
      if button == "LeftButton" then
        UI:Toggle()
      elseif button == "RightButton" then
        PinHelper:Clear()
      end
    end,
    OnTooltipShow = function(tooltip)
      tooltip:AddDoubleLine(
        Colors.Primary(Addon.DISPLAY_NAME),
        Addon.VERSION
      )
      tooltip:AddLine(" ")
      tooltip:AddDoubleLine(L.LEFT_CLICK, L.TOGGLE_UI, nil, nil, nil, 1, 1, 1)
      tooltip:AddDoubleLine(L.RIGHT_CLICK, L.CLEAR_PINS, nil, nil, nil, 1, 1, 1)
    end,
  })

  LDBIcon:Register(ADDON_NAME, object, DB.global.minimapIcon)
  self.available = true
  self.Initialize = nil
end

function MinimapIcon:Show()
  local LDBIcon = Addon:GetLibrary("LDBIcon", true)
  if not (self.available and LDBIcon) then return end
  DB.global.minimapIcon.hide = false
  LDBIcon:Show(ADDON_NAME)
end

function MinimapIcon:Hide()
  local LDBIcon = Addon:GetLibrary("LDBIcon", true)
  if not (self.available and LDBIcon) then
    if DB.global and DB.global.minimapIcon then
      DB.global.minimapIcon.hide = true
    end
    return
  end
  DB.global.minimapIcon.hide = true
  LDBIcon:Hide(ADDON_NAME)
end

function MinimapIcon:Toggle()
  if DB.global.minimapIcon.hide then
    self:Show()
  else
    self:Hide()
  end
end
