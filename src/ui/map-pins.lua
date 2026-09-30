local ADDON_NAME, Addon = ...
local Colors = Addon:GetModule("Colors")
local L = Addon:GetModule("Locale")
local PinHelper = Addon:GetModule("PinHelper")

local PIN_TEMPLATE = "TamedForeverMapPinTemplate"
local active = {}
local provider
local overlayPins = {}
local overlayPool = {}

PinHelper.status = "pending"

local function PinTooltip(pin)
  if not pin or not pin.npc then
    return
  end
  GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
  GameTooltip:SetText(Colors.Primary(pin.npc.name))
  GameTooltip:AddDoubleLine(L.LEVEL, pin.npc.level_range, nil, nil, nil, 1, 1, 1)
  if pin.npc.abilities then
    GameTooltip:AddDoubleLine(L.ABILITIES, table.concat(pin.npc.abilities, ", "), nil, nil, nil, 1, 1, 1)
  end
  GameTooltip:AddDoubleLine(L.FAMILY, pin.npc.family, nil, nil, nil, 1, 1, 1)
  GameTooltip:AddDoubleLine(L.DIET, pin.npc.diet, nil, nil, nil, 1, 1, 1)
  GameTooltip:AddDoubleLine(L.TYPE, pin.npc.type, nil, nil, nil, 1, 1, 1)
  GameTooltip:AddDoubleLine(L.LOCATION, pin.npc.location, nil, nil, nil, 1, 1, 1)
  GameTooltip:AddDoubleLine(L.LEFT_CLICK, L.CLEAR_PINS, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6)
  GameTooltip:Show()
end

local function DecoratePin(frame)
  frame:SetSize(14, 14)
  if not frame.texture then
    frame.texture = frame:CreateTexture(nil, "BACKGROUND")
    frame.texture:SetTexture(Addon.ICON)
    frame.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    frame.texture:SetAllPoints()
  end
  if not frame.highlight then
    frame.highlight = frame:CreateTexture(nil, "HIGHLIGHT")
    frame.highlight:SetTexture(Addon.ICON)
    frame.highlight:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    frame.highlight:SetBlendMode("ADD")
    frame.highlight:SetAlpha(0)
    frame.highlight:SetAllPoints(frame.texture)
  end
  frame:SetScript("OnEnter", function(self)
    self.highlight:SetAlpha(0.4)
    PinTooltip(self)
  end)
  frame:SetScript("OnLeave", function(self)
    self.highlight:SetAlpha(0)
    GameTooltip:Hide()
  end)
  frame:SetScript("OnClick", function()
    PinHelper:Clear()
  end)
  frame:EnableMouse(true)
end

local function ClearOverlayPins()
  for _, pin in ipairs(overlayPins) do
    pin:Hide()
    pin.npc = nil
    overlayPool[#overlayPool + 1] = pin
  end
  wipe(overlayPins)
end

local function AcquireOverlayPin()
  local pin = table.remove(overlayPool)
  if not pin then
    local parent = WorldMapFrame
    if WorldMapFrame.GetCanvas then
      local ok, canvas = pcall(WorldMapFrame.GetCanvas, WorldMapFrame)
      if ok and canvas then
        parent = canvas
      end
    end
    pin = CreateFrame("Button", nil, parent)
    DecoratePin(pin)
  end
  overlayPins[#overlayPins + 1] = pin
  return pin
end

local function RefreshOverlayPins()
  ClearOverlayPins()
  if not WorldMapFrame or not WorldMapFrame.GetMapID then
    return
  end
  local mapID = WorldMapFrame:GetMapID()
  local width, height = WorldMapFrame:GetWidth(), WorldMapFrame:GetHeight()
  if WorldMapFrame.GetCanvas then
    local ok, canvas = pcall(WorldMapFrame.GetCanvas, WorldMapFrame)
    if ok and canvas then
      width, height = canvas:GetWidth(), canvas:GetHeight()
    end
  end
  for i = 1, #active do
    local data = active[i]
    if data.uiMapID == mapID then
      local pin = AcquireOverlayPin()
      pin.npc = data.npc
      pin:ClearAllPoints()
      pin:SetPoint("CENTER", pin:GetParent(), "TOPLEFT", data.x * width, -data.y * height)
      pin:Show()
    end
  end
end

local function TryUserWaypoint(uiMapID, x, y)
  if not (C_Map and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates) then
    return
  end
  if C_Map.CanSetUserWaypointOnMap and not C_Map.CanSetUserWaypointOnMap(uiMapID) then
    return
  end
  -- Do not call C_SuperTrack.SetSuperTrackedUserWaypoint; it is protected on Forever.
  pcall(C_Map.SetUserWaypoint, UiMapPoint.CreateFromCoordinates(uiMapID, x, y))
end

local function ClearUserWaypoint()
  if C_Map and C_Map.ClearUserWaypoint then
    pcall(C_Map.ClearUserWaypoint)
  end
end

local function RefreshProvider()
  if provider and provider.GetMap and provider:GetMap() then
    pcall(function()
      provider:RefreshAllData()
    end)
  else
    RefreshOverlayPins()
  end
end

local function InitMapCanvas()
  if provider then
    return true
  end
  if not WorldMapFrame then
    return false
  end
  if not (CreateFromMixins and MapCanvasDataProviderMixin and WorldMapFrame.AddDataProvider) then
    PinHelper.status = "overlay-fallback"
    if WorldMapFrame.HookScript then
      pcall(function()
        WorldMapFrame:HookScript("OnShow", RefreshOverlayPins)
      end)
    end
    return false
  end

  local ok = pcall(function()
    provider = CreateFromMixins(MapCanvasDataProviderMixin)

    function provider:RemoveAllData()
      local map = self:GetMap()
      if map and map.RemoveAllPinsByTemplate then
        map:RemoveAllPinsByTemplate(PIN_TEMPLATE)
      end
    end

    function provider:RefreshAllData()
      self:RemoveAllData()
      local map = self:GetMap()
      if not map then
        return
      end
      local mapID = map:GetMapID()
      for i = 1, #active do
        local data = active[i]
        if data.uiMapID == mapID then
          map:AcquirePin(PIN_TEMPLATE, data)
        end
      end
    end

    if not WorldMapFrame.pinPools then
      WorldMapFrame.pinPools = {}
    end

    local pool = CreateFramePool and CreateFramePool("Button") or nil
    if pool then
      pool.parent = WorldMapFrame.GetCanvas and WorldMapFrame:GetCanvas() or WorldMapFrame
      pool.createFunc = function()
        local frame = CreateFrame("Button", nil, pool.parent)
        DecoratePin(frame)
        if MapCanvasPinMixin then
          Mixin(frame, MapCanvasPinMixin)
        end
        function frame:OnLoad()
        end
        function frame:OnAcquired(data)
          self.npc = data.npc
          if self.SetPosition then
            self:SetPosition(data.x, data.y)
          end
          self:Show()
        end
        function frame:OnReleased()
          self.npc = nil
          self:Hide()
        end
        frame.SetPassThroughButtons = function() end
        return frame
      end
      pool.resetFunc = function(_, pin)
        if pin.OnReleased then
          pin:OnReleased()
        end
      end
      pool.creationFunc = pool.createFunc
      pool.resetterFunc = pool.resetFunc
      WorldMapFrame.pinPools[PIN_TEMPLATE] = pool
    end

    WorldMapFrame:AddDataProvider(provider)
  end)

  if ok then
    PinHelper.status = "mapcanvas"
    return true
  end
  PinHelper.status = "overlay-fallback"
  return false
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(_, event, name)
  if event == "PLAYER_LOGIN" or name == "Blizzard_WorldMap" then
    pcall(InitMapCanvas)
  end
end)

function PinHelper:ShowNPC(npc)
  local ok, shown = pcall(function()
    self:Clear()
    if not npc then
      return false
    end
    Addon:ShowWorldMap(npc.ui_map_id)
    pcall(InitMapCanvas)

    if not npc.ui_map_id or type(npc.coords) ~= "table" or #npc.coords == 0 then
      return false
    end

    local first = true
    for _, coords in pairs(npc.coords) do
      local x = Addon:PercentToMapCoord(coords.x)
      local y = Addon:PercentToMapCoord(coords.y)
      if x and y then
        active[#active + 1] = {
          npc = npc,
          uiMapID = npc.ui_map_id,
          x = x,
          y = y,
        }
        if first then
          TryUserWaypoint(npc.ui_map_id, x, y)
          first = false
        end
      end
    end

    RefreshProvider()
    return #active > 0
  end)
  if not ok then
    PinHelper.status = "error"
    return false
  end
  return shown
end

function PinHelper:Clear()
  wipe(active)
  ClearOverlayPins()
  ClearUserWaypoint()
  if provider and provider.RemoveAllData then
    pcall(function()
      provider:RemoveAllData()
    end)
  end
end

function PinHelper:Hide()
  self:Clear()
end
