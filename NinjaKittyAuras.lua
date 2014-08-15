NinjaKittyAuras = LibStub("AceAddon-3.0"):NewAddon("NinjaKittyAuras", "AceConsole-3.0")
NinjaKittyAuras._G = _G

setfenv(1, NinjaKittyAuras)

local NinjaKittyAuras = _G.NinjaKittyAuras
local string, math, table = _G.string, _G.math, _G.table
local pairs, ipairs = _G.pairs, _G.ipairs
local assert, select, print = _G.assert, _G.select, _G.print
local UIParent = _G.UIParent
local CreateFrame = _G.CreateFrame
local LibStub = _G.LibStub

-- http://wowprogramming.com/snippets/Scan_a_tooltip_15
-- http://wowpedia.org/UIOBJECT_GameTooltip#Hidden_tooltip_for_scanning
local scanningTooltip = _G.CreateFrame("GameTooltip", "NKAScanningTooltip", nil,
  "GameTooltipTemplate")
scanningTooltip:SetOwner(_G.WorldFrame, "ANCHOR_NONE")

function blacklistByTooltip(unit, index, filter, blacklist)
  scanningTooltip:ClearLines()
  scanningTooltip:SetUnitAura(unit, index, filter)
  scanningTooltip:AddFontStrings(scanningTooltip:CreateFontString("$parentTextLeft1", nil,
    "GameTooltipText"), scanningTooltip:CreateFontString("$parentTextRight1", nil,
    "GameTooltipText"))

  local tooltip = _G.NKAScanningTooltipTextLeft2:GetText()
  for _, v in _G.ipairs(blacklist) do
    if tooltip and _G.string.match(tooltip, v) then return true end
  end
  return false
end

local backdrop = {
  bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
  edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
  tile = false,
  --tileSize = 32,
  edgeSize = 1,
  insets = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
}

local function initGroup(group)
  --_G.assert(not group.parent or _G[group.parent])
  do
    local comparator = group.compare
    group.compare = function(aura1, aura2)
      if aura1.name and not aura2.name then
        return true
      elseif not aura1.name and aura2.name then
        return false
      elseif not aura1.name and not aura2.name then
        return false
      end
      return comparator(aura1, aura2)
    end
  end

  local parent = group.parent and _G[group.parent] or _G.UIParent

  group.anchorFrame = _G.CreateFrame("Frame", group.name .. "Wrapper", parent)
  group.anchorFrame:SetFrameLevel(10)
  do
    local relativeTo = (group.relativeTo and _G[group.relativeTo]) or (group.parent and _G[group.parent]) or _G.UIParent
    local xOffset = group.xOffset
    if _G.string.find(group.anchorPoint, "LEFT", 1, true) then
      xOffset = xOffset - 1
    elseif _G.string.find(group.anchorPoint, "RIGHT", 1, true) then
      xOffset = xOffset + 1
    end
    local yOffset = group.yOffset
    if _G.string.find(group.anchorPoint, "BOTTOM", 1, true) then
      yOffset = yOffset - 1
    elseif _G.string.find(group.anchorPoint, "TOP", 1, true) then
      yOffset = yOffset + 1
    end
    if group.orientation == "HORIZONTAL" then
      group.anchorFrame:SetPoint(group.anchorPoint, relativeTo, group.relativePoint, xOffset, yOffset)
      group.anchorFrame:SetSize(2 + group.size + (group.numCols - 1) * _G.math.abs(group.xGap), 2)
    elseif group.orientation == "VERTICAL" then
      _G.assert(false) -- TODO.
    end

    --[[
    local texture = group.anchorFrame:CreateTexture(nil, "OVERLAY")
    texture:SetParent(group.anchorFrame)
    texture:SetAllPoints()
    texture:SetTexture(1.0, 1.0, 1.0, 0.3)
    --]]

  end

  group.frames = {}

  for i = 1, group.numRows * group.numCols do
    local frame = CreateFrame("Button", group.name .. i, group.anchorFrame)
    frame:SetFrameLevel(group.anchorFrame:GetFrameLevel() - 1)
    frame:SetSize(group.size, group.size)
    frame:EnableMouse(true)
    frame:RegisterForClicks("RightButtonDown")
    frame:Hide()

    if group.borderColor then
      frame:SetBackdrop(backdrop)
      frame:SetBackdropBorderColor(0, 0, 0)
      frame:SetBackdropColor(0, 0, 0, 0)
    end

    frame:SetScript("OnEnter", function(self, motion)
      if not (group.unit and self.auraIndex and self.auraFilter) then return end
      _G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
      _G.GameTooltip:SetUnitAura(group.unit, self.auraIndex, self.auraFilter)
    end)

    frame:SetScript("OnLeave", function(self, motion)
      _G.GameTooltip:Hide()
    end)

    frame:SetScript("OnMouseDown", function(self, button)
      if _G.InCombatLockdown() or not (group.unit and _G.UnitIsUnit(group.unit, "player") and
        self.auraIndex and self.auraFilter) then return end
      if button == "RightButton" then
        _G.CancelUnitBuff("player", self.auraIndex, self.auraFilter)
      end
    end)

    frame.icon = frame:CreateTexture(nil, "BACKGROUND")
    frame.icon:SetAllPoints(frame)

    frame.cooldown = CreateFrame("Cooldown", group.name .. i .. "Cooldown", frame)
    frame.cooldown:SetReverse(true)
    frame.cooldown:SetAllPoints(frame)

    _G.table.insert(group.frames, frame)
  end

  if group.orientation == "HORIZONTAL" then
    local xOffset = group.xGap > 0 and 1 or -1
    local yOffset = group.yGap > 0 and 1 or -1
    local anchorPoint
    if group.xGap > 0 then -- The group grows to the right.
      anchorPoint = "LEFT"
    else
      anchorPoint = "RIGHT"
    end
    if group.yGap > 0 then -- The group grows to the top.
      anchorPoint = "BOTTOM" .. anchorPoint
    else
      anchorPoint = "TOP" .. anchorPoint
    end
    for i = 0, group.numRows - 1 do
      for j = 1, group.numCols do
        local frame = group.frames[i * group.numCols + j]
        frame:SetPoint(anchorPoint, group.anchorFrame, anchorPoint, xOffset, yOffset)
        xOffset = xOffset + group.xGap
      end
      xOffset = group.xGap > 0 and 1 or -1
      yOffset = yOffset + group.yGap
    end
  elseif group.orientation == "VERTICAL" then
    _G.assert(false)
  end
end

local function initGroups()
  for _,group in _G.pairs(NinjaKittyAuras.groups) do
    initGroup(group)
  end
end

local auras, maxAuras, numAuras = {}, 80, 0
for i = 1, maxAuras do
  auras[i] = {}
end

local function GetAuras(group)
  local unit = group.unit
  local i = 1

  for _, filter in _G.ipairs(group.filters) do
    local queryIndex = 1
    while queryIndex <= 40 and i <= maxAuras do
      auras[i].name, auras[i].rank, auras[i].icon, auras[i].count, auras[i].dispelType, auras[i].duration,
      auras[i].expires, auras[i].caster, auras[i].isStealable, auras[i].shouldConsolidate, auras[i].spellID,
      auras[i].canApplyAura, auras[i].isBossDebuff, auras[i].value1, auras[i].value2, auras[i].value3 =
      _G.UnitAura(unit, queryIndex, filter)

      auras[i].filter = filter
      auras[i].index = queryIndex

      if not auras[i].name then
        break
      end
      if group.mutators and group.mutators[auras[i].name] then
        group.mutators[auras[i].name](auras[i])
      end

      if group.whitelist and group.whitelist(auras[i]) then
        i = i + 1  -- Save it.
      elseif group.blacklist and not group.blacklist(auras[i]) then
        i = i + 1  -- Save it.
      elseif not group.whitelist and not group.blacklist then
        i = i + 1  -- Save it.
      end

      queryIndex = queryIndex + 1
    end
  end

  if group.fakeAuras and _G.UnitExists(unit) then
    for _, fakeAura in pairs(group.fakeAuras) do
      if i > maxAuras then break end
      if fakeAura.present(unit) then
        for k, v in pairs(fakeAura) do
          auras[i][k] = v
        end
        auras[i].index = i
        i = i + 1
      end
    end
  end

  numAuras = i - 1

  while i <= maxAuras do
    auras[i].name = nil
    i = i + 1
  end

  _G.table.sort(auras, group.compare)
  return auras
end

local function updateGroup(group)
  if group.hide and group.hide() or not _G.UnitExists(group.unit) then
    for _, frame in _G.ipairs(group.frames) do
      frame:Hide()
    end
    return
  end

  -- Initializes the auras table and the numAuras variable.
  GetAuras(group)

  if group.displays then
    for _, display in _G.ipairs(group.displays) do
      -- ...
    end
  end

  if group.orientation == "HORIZONTAL" then
    if group.numRows == 1 then
      local width = 2 + (numAuras >= 1 and group.size + _G.math.abs(group.xGap) * (numAuras - 1) or 0)
      group.anchorFrame:SetWidth(width)
    end
    local numFrames = _G.math.min(numAuras, group.numRows * group.numCols)
    local numRows = _G.math.ceil(numFrames / group.numCols)
    local height = 2 + (numRows >= 1 and group.size + _G.math.abs(group.yGap) * (numRows - 1) or 0)
    group.anchorFrame:SetHeight(height)
  elseif group.orientation == "VERTICAL" then
    _G.assert(false) -- TODO.
  end

  for i, frame in ipairs(group.frames) do
    --assert(auras[i])
    local texture  = frame.icon
    local cooldown = frame.cooldown
    if not auras[i].name then
      texture:SetTexture(nil)
      -- http://wowprogramming.com/utils/xmlbrowser/test/FrameXML/Cooldown.lua
      _G.CooldownFrame_SetTimer(cooldown)
      frame:Hide()
    else
      -- http://wowprogramming.com/docs/api/GetTime
      frame.auraIndex  = auras[i].index
      frame.auraFilter = auras[i].filter
      texture:SetTexture(auras[i].icon)
      if group.borderColor then frame:SetBackdropBorderColor(group.borderColor(auras[i])) end
      frame:Show()
      --assert(auras[i].expires)
      --assert(auras[i].duration)
      if auras[i].duration == 0 and auras[i].expires == 0 then
        cooldown:Hide()
      elseif auras[i].duration == 0 then -- We only got the time at which the aura will expire.
        --assert(false)
      elseif auras[i].expires == 0 then -- We only got a duration.
        --assert(false)
      elseif auras[i].expires > _G.GetTime() then -- The aura expires in the future (like you might
                                                  -- expect).
        local duration

        -- GetTime() can be quite small and the value of GetTime() when the aura expires may be less
        -- than its duration. Then, this variable (start) is negative.
        -- In such a case Cooldown:SetCooldown bugs out. I think it happens with auras that were
        -- applied long before we logged in. The value of of GetTime() seems to be related to the
        -- time of booting the OS.
        local start = auras[i].expires - auras[i].duration

        if start < 0 then
          start = 0.01 -- OmniCC doesn't work with cooldowns starting at 0.
          duration = auras[i].expires - start
        elseif start > _G.GetTime() then -- The aura wasn't applied yet?! Does this really happen?
          start = _G.GetTime()
          duration = auras[i].expires - _G.GetTime()
        else
          duration = auras[i].duration
        end
        cooldown:Show()
        _G.CooldownFrame_SetTimer(cooldown, start, duration, true)
      elseif auras[i].expires <= _G.GetTime() then -- Aura has already expired.
        cooldown:Hide()
      else
        assert(false)
      end
      if frame:IsMouseOver() then
        local handler = frame:GetScript("OnEnter")
        handler(frame, false)
      end
    end
  end
end

local function updateGroups(unitID)
  for _,group in ipairs(NinjaKittyAuras.groups) do
    if group.unit == unitID or not unitID then
      updateGroup(group)
    end
  end
end

-- Called by AceAddon on ADDON_LOADED?
-- See: wowace.com/addons/ace3/pages/getting-started/#w-standard-methods
function NinjaKittyAuras:OnInitialize()
  --NinjaKittyAuras:Print("OnInitialize() called.")
end

local handlerFrame = CreateFrame("Frame")

function handlerFrame:ADDON_LOADED(name)
  if not _G.NinjaKittyUF then return end
  --if name ~= "NinjaKittyAuras" then return end
  self:UnregisterEvent("ADDON_LOADED")

  NinjaKittyAuras:Print("ADDON_LOADED() called.")

  --------------------------------------------------------------------------------------------------
  initGroups()

  handlerFrame:RegisterEvent("PLAYER_LOGIN")
  --handlerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  --handlerFrame:RegisterEvent("PLAYER_ALIVE")

  handlerFrame:RegisterEvent("UNIT_AURA")
  handlerFrame:RegisterEvent("UNIT_CONNECTION")
  handlerFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
  handlerFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")

  -- Fires when the composition of the party changes?
  handlerFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
  --handlerFrame:RegisterEvent("UNIT_TARGETABLE_CHANGED")

  -- http://wowpedia.org/SecureStateDriver
  -- http://wowpedia.org/API_SecureCmdOptionParse
  local stateHandler = CreateFrame("Frame", nil, nil, "SecureHandlerStateTemplate")

  function stateHandler:onNoExists(unitID)
    updateGroups(unitID)
  end
  for _, unit in _G.ipairs({"target", "focus", "arena1", "arena2", "arena3", "arena4", "arena5"}) do
    stateHandler:SetAttribute("_onstate-" .. unit .. "noexists", [[
      if newstate == "noexists" then
        self:CallMethod("onNoExists","]] .. unit .. [[")
      end
    ]])
    _G.RegisterStateDriver(stateHandler, unit .. "noexists",
      "[@" .. unit .. ",exists]exists;noexists")
  end

  -- This doesn't work: in the end we only have the last state driver.
  --[==[
  function stateHandler:onUnitExists(unitID)
    --NinjaKittyAuras:Print("Unit exists: \"" .. unitID .. "\".")
    updateGroups(unitID)
  end
  -- Arguments: self, stateid, newstate
  stateHandler:SetAttribute("_onstate-unitexists", [[
    if newstate ~= "noexists" then
      self:CallMethod("onUnitExists", newstate)
    end
  ]])
  for i = 1, 5 do
    _G.RegisterStateDriver(stateHandler, "unitexists",
      "[@arena" .. i .. ",exists]arena" .. i .. ";noexists")
  end
  --]==]
  --------------------------------------------------------------------------------------------------

  self.ADDON_LOADED = nil
end

function handlerFrame:PLAYER_LOGIN()
  updateGroups()
end

function handlerFrame:PLAYER_ENTERING_WORLD()
  updateGroups()
end

function handlerFrame:PLAYER_ALIVE()
  updateGroups()
end

-- http://wowprogramming.com/docs/events/UNIT_AURA
function handlerFrame:UNIT_AURA(unitID)
  updateGroups(unitID)
end

function handlerFrame:UNIT_CONNECTION(unit, hasConnected)
  updateGroups(unitID)
end

function handlerFrame:PLAYER_TARGET_CHANGED(cause)
  --if (select(2, _G.GetInstanceInfo())) ~= "arena" then
    updateGroups("target")
  --end
end

function handlerFrame:PLAYER_FOCUS_CHANGED()
  --if (select(2, _G.GetInstanceInfo())) ~= "arena" then
    updateGroups("focus")
  --end
end

function handlerFrame:GROUP_ROSTER_UPDATE()
  --NinjaKittyAuras:Print("GROUP_ROSTER_UPDATE")
  for i = 1, 4 do
    updateGroups("party" .. i)
  end
end

-- http://www.wowinterface.com/forums/showthread.php?p=267998
handlerFrame:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)

handlerFrame:RegisterEvent("ADDON_LOADED")

-- vim: tw=120 sw=2 et
