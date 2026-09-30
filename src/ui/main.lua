local AddonName, Addon = ...
local AbilityGroup = Addon:GetModule("AbilityGroup")
local AceGUI = Addon:GetLibrary("AceGUI", true)
local Colors = Addon:GetModule("Colors")
local L = Addon:GetModule("Locale")
local OptionsGroup = Addon:GetModule("OptionsGroup")
local TameableAbilities = Addon.TameableAbilities
local UI = Addon:GetModule("UI")
local Widgets = Addon:GetModule("Widgets")

local TreeGroup = {}

function UI:IsShown()
  return self.frame and self.frame:IsShown()
end

function UI:Toggle()
  if self:IsShown() then
    self:Hide()
  else
    self:Show()
  end
end

function UI:Show()
  if not AceGUI then
    print("|cffaad372[Tamed Forever]|r AceGUI is not available.")
    return
  end
  if not self.frame then self:Create() end
  if self.frame then
    self.frame:Show()
  end
end

function UI:Hide()
  if not self.frame then return end
  self.frame:Hide()
end

function UI:Create()
  local frame = AceGUI:Create("Frame")
  frame:SetTitle(Addon.DISPLAY_NAME or "Tamed Forever")
  frame:SetWidth(650)
  frame:SetHeight(500)
  if frame.frame and frame.frame.SetResizeBounds then
    frame.frame:SetResizeBounds(650, 500)
  end
  frame:SetLayout("Flow")
  self.frame = frame

  Widgets:Heading(
    frame,
    ("%s: %s"):format(
      L.VERSION,
      Colors.Primary(Addon.VERSION)
    )
  )
  Widgets:Label({
    parent = frame,
    text = L.DATA_UNVERIFIED,
    fullWidth = true
  })
  Widgets:Spacer(frame)
  TreeGroup:Create(frame)
  self.Create = nil
end

function TreeGroup:Create(parent)
  local treeGroup = AceGUI:Create("TreeGroup")
  treeGroup:SetLayout("Fill")
  treeGroup:EnableButtonTooltips(false)
  treeGroup:SetCallback("OnGroupSelected", self.OnGroupSelected)

  local tree = self:BuildTree()
  treeGroup:SetTree(tree)
  if tree[1] then
    treeGroup:SelectByValue(tree[1].value)
  end

  Widgets:SimpleGroup({
    parent = parent,
    fullWidth = true,
    fullHeight = true,
    layout = "Fill"
  }):AddChild(treeGroup)

  self.Create = nil
  self.BuildTree = nil
end

function TreeGroup:BuildTree()
  local tree = {
    { text = L.OPTIONS, value = "OPTIONS_GROUP" },
    { text = " ", value = "BLANK_1", disabled = true }
  }

  do
    local abilities = {}
    for id, ability in pairs(TameableAbilities) do
      local children = {}
      for i in ipairs(ability.ranks) do
        children[#children + 1] = {
          text = ("%s %s"):format(L.RANK, i),
          value = i
        }
      end
      abilities[#abilities + 1] = {
        text = ability.name,
        value = id,
        icon = ability.icon or Addon.ICON,
        disabled = true,
        children = children
      }
    end
    table.sort(abilities, function(a, b) return a.text < b.text end)
    for _, ability in ipairs(abilities) do
      tree[#tree + 1] = ability
    end
  end

  return tree
end

function TreeGroup:OnGroupSelected(event, value)
  self:ReleaseChildren()

  local parent = AceGUI:Create("ScrollFrame")
  parent:SetLayout("Flow")
  parent:PauseLayout()

  if value == "OPTIONS_GROUP" then
    OptionsGroup:Create(parent)
  else
    local abilityId, abilityRank = value:match("^(.+)\001(%d+)$")
    local ability = TameableAbilities[abilityId]
    if ability then
      AbilityGroup:Create(parent, ability, tonumber(abilityRank))
    end
  end

  parent:ResumeLayout()
  parent:DoLayout()
  self:AddChild(parent)
end

local closeSpecialWindows = _G.CloseSpecialWindows
if type(closeSpecialWindows) == "function" then
  _G.CloseSpecialWindows = function()
    local found = closeSpecialWindows()
    if UI:IsShown() then
      UI:Hide()
      return true
    end
    return found
  end
end
