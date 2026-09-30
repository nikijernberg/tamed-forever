local _, Addon = ...
local DB = Addon:GetModule("DB")

local defaults = {
  global = {
    minimapIcon = { hide = false },
    npc_tooltips = true,
  }
}

local function CopyDefaults(dest, src)
  for k, v in pairs(src) do
    if type(v) == "table" then
      if type(dest[k]) ~= "table" then
        dest[k] = {}
      end
      CopyDefaults(dest[k], v)
    elseif dest[k] == nil then
      dest[k] = v
    end
  end
end

function DB:Initialize()
  TamedForeverDB = TamedForeverDB or {}
  if type(TamedForeverDB.global) ~= "table" then
    TamedForeverDB.global = {}
  end
  CopyDefaults(TamedForeverDB.global, defaults.global)
  self.global = TamedForeverDB.global
  self.Initialize = nil
end
