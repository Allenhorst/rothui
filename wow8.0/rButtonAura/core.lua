
-- rButtonAura: core
-- zork, 2018

-----------------------------
-- Variables
-----------------------------

local A, L = ...

local tick = 0.1

local GetTime, UnitAura = GetTime, UnitAura
local numAuras = 0
local auras = {}

-----------------------------
-- rButtonAura Global
-----------------------------

rButtonAura = {}
rButtonAura.addonName = A

-----------------------------
-- Functions
-----------------------------

--AddAura
local function AddAura(aura)
  table.insert(auras,aura)
end
rButtonAura.AddAura = AddAura

--SetTick
local function SetTick(newTick)
  tick = newTick
end
rButtonAura.SetTick = SetTick

--UpdateAura
local function UpdateAura(aura)
  local name, icon, count, debuffType, duration, expires, caster = AuraUtil.FindAuraByName(aura.spellName, aura.unit, aura.filter)
  if name and caster == aura.caster then
    if aura.bar then
      local perc = (duration+GetTime()-expires)/duration
      local w = aura.bar.maxwidth-perc*aura.bar.maxwidth
      aura.bar:SetWidth(w)
      aura.bar:Show()
    end
    if aura.border then
      aura.border:Show()
    end
  else
    if aura.bar then
      aura.bar:Hide()
    end
    if aura.border then
      aura.border:Hide()
    end
  end
end

--UpdateAuras
local function UpdateAuras()
  for i, aura in next, auras do
    UpdateAura(aura)
  end
end

--Tick
local function Tick()
  UpdateAuras()
  C_Timer.After(tick, Tick)
end

--Login
local function Login()
  numAuras = #auras
  if numAuras == 0 then return end
  local error = false
  for i, aura in next, auras do
    local border = _G[aura.button:GetName.."Border"]
    if not aura.border then
      print(A,aura.spellId,"border not found")
      error = true
      break
    else
      aura.border = border
    end
    local spellName = GetSpellInfo(aura.spellid)
    if not aura.spellName then
      print(A,aura.spellid,"spell id not found")
      error = true
      break
    else
      aura.spellName = spellName
    end
--[[     if aura.useBar then
      local la, li = aura.border:GetDrawLayer()
      aura.bar = aura.border:GetParent():CreateTexture(nil,la,nil,li)
      aura.bar:SetColorTexture(unpack(aura.barColor))
      aura.bar:SetBlendMode("ADD")
      aura.bar:SetPoint("TOPLEFT")
      aura.bar:SetSize(0,aura.border:GetParent():GetHeight()/10)
      aura.bar:Hide()
      aura.bar.maxwidth = aura.border:GetParent():GetWidth()
    end ]]
    if aura.useBorder then
      aura.border:SetVertexColor(unpack(aura.borderColor))
    end
  end
  if not error then
    Tick()
  end
end

--RegisterCallback PLAYER_LOGIN
rLib:RegisterCallback("PLAYER_LOGIN", Login)

