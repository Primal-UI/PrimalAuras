NinjaKittyAuras = { _G = _G }
setfenv(1, NinjaKittyAuras)

-- http://wowprogramming.com/snippets/Scan_a_tooltip_15
-- http://wowpedia.org/UIOBJECT_GameTooltip#Hidden_tooltip_for_scanning
local scanningTooltip = _G.CreateFrame("GameTooltip", "NKAScanningTooltip", nil, "GameTooltipTemplate")
scanningTooltip:SetOwner(_G.WorldFrame, "ANCHOR_NONE")

function blacklistByTooltip(unit, index, filter, blacklist)
  scanningTooltip:ClearLines()
  scanningTooltip:SetUnitAura(unit, index, filter)
  scanningTooltip:AddFontStrings(scanningTooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
    scanningTooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText"))

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

local function initDisplay(display, group)
  local parent = display.parent and _G[display.parent] or _G.UIParent

  display.anchorFrame = _G.CreateFrame("Frame", display.name, parent)
  display.anchorFrame:SetFrameLevel(10)
  do
    local relativeTo = (display.relativeTo and _G[display.relativeTo]) or (display.parent and _G[display.parent]) or
      _G.UIParent
    local xOffset = display.xOffset
    if _G.string.find(display.anchorPoint, "LEFT", 1, true) then
      xOffset = xOffset - 1
    elseif _G.string.find(display.anchorPoint, "RIGHT", 1, true) then
      xOffset = xOffset + 1
    end
    local yOffset = display.yOffset
    if _G.string.find(display.anchorPoint, "BOTTOM", 1, true) then
      yOffset = yOffset - 1
    elseif _G.string.find(display.anchorPoint, "TOP", 1, true) then
      yOffset = yOffset + 1
    end
    if display.orientation == "HORIZONTAL" then
      display.anchorFrame:SetPoint(display.anchorPoint, relativeTo, display.relativePoint, xOffset, yOffset)
      display.anchorFrame:SetSize(2 + display.size + (display.numCols - 1) * _G.math.abs(display.xGap), 2)
    elseif display.orientation == "VERTICAL" then
      _G.assert(false) -- TODO.
    end

    --[[
    local texture = display.anchorFrame:CreateTexture(nil, "OVERLAY")
    texture:SetParent(display.anchorFrame)
    texture:SetAllPoints()
    texture:SetTexture(1.0, 1.0, 1.0, 0.3)
    --]]

  end

  display.frames = {}

  for i = 1, display.numRows * display.numCols do
    local frame = _G.CreateFrame("Button", display.name .. i, display.anchorFrame)
    frame:SetFrameLevel(display.anchorFrame:GetFrameLevel() - 1)
    frame:SetSize(display.size, display.size)
    frame:EnableMouse(true)
    frame:RegisterForClicks("RightButtonDown")
    frame:Hide()

    if display.borderColor then
      frame:SetBackdrop(backdrop)
      frame:SetBackdropBorderColor(0, 0, 0)
      frame:SetBackdropColor(0, 0, 0, 0)
    end

    frame:SetScript("OnEnter", function(self, motion)
      if group.unit and self.auraIndex and self.auraFilter then
        _G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        _G.GameTooltip:SetUnitAura(group.unit, self.auraIndex, self.auraFilter)
      end
    end)

    frame:SetScript("OnLeave", function(self, motion)
      _G.GameTooltip:Hide()
    end)

    frame:SetScript("OnMouseDown", function(self, button)
      if _G.InCombatLockdown() or not (group.unit and _G.UnitIsUnit(group.unit, "player") and
        self.auraIndex and self.auraFilter)
      then
        return
      end
      if button == "RightButton" then
        _G.CancelUnitBuff("player", self.auraIndex, self.auraFilter)
      end
    end)

    frame.icon = frame:CreateTexture(nil, "BACKGROUND")
    frame.icon:SetAllPoints(frame)

    frame.cooldown = _G.CreateFrame("Cooldown", display.name .. i .. "Cooldown", frame)
    frame.cooldown:SetReverse(true)
    frame.cooldown:SetAllPoints(frame)

    _G.table.insert(display.frames, frame)
  end

  if display.orientation == "HORIZONTAL" then
    local xOffset = display.xGap > 0 and 1 or -1
    local yOffset = display.yGap > 0 and 1 or -1
    local anchorPoint
    if display.xGap > 0 then -- The display grows to the right.
      anchorPoint = "LEFT"
    else
      anchorPoint = "RIGHT"
    end
    if display.yGap > 0 then -- The display grows to the top.
      anchorPoint = "BOTTOM" .. anchorPoint
    else
      anchorPoint = "TOP" .. anchorPoint
    end
    for i = 0, display.numRows - 1 do
      for j = 1, display.numCols do
        local frame = display.frames[i * display.numCols + j]
        frame:SetPoint(anchorPoint, display.anchorFrame, anchorPoint, xOffset, yOffset)
        xOffset = xOffset + display.xGap
      end
      xOffset = display.xGap > 0 and 1 or -1
      yOffset = yOffset + display.yGap
    end
  elseif display.orientation == "VERTICAL" then
    _G.assert(false)
  end
end

local function initGroup(group)
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
  for _, display in _G.ipairs(group.displays) do
    initDisplay(display, group)
  end
end

local auras, maxAuras, numAuras = {}, 80
for i = 1, maxAuras do
  auras[i] = {}
end

local function GetAuras(group)
  local i = 1
  for _, filter in _G.ipairs(group.filters) do
    local queryIndex = 1
    while queryIndex <= 40 and i <= maxAuras do
      auras[i].name, auras[i].rank, auras[i].icon, auras[i].count, auras[i].dispelType, auras[i].duration,
      auras[i].expires, auras[i].caster, auras[i].isStealable, auras[i].shouldConsolidate, auras[i].spellID,
      auras[i].canApplyAura, auras[i].isBossDebuff, auras[i].value1, auras[i].value2, auras[i].value3 =
      _G.UnitAura(group.unit, queryIndex, filter)

      auras[i].filter = filter
      auras[i].index = queryIndex

      if not auras[i].name then
        break
      end
      if group.mutators and group.mutators[auras[i].name] then
        group.mutators[auras[i].name](auras[i])
      end

      i = i + 1
      queryIndex = queryIndex + 1
    end
  end

  if group.fakeAuras and _G.UnitExists(group.unit) then
    for _, fakeAura in _G.pairs(group.fakeAuras) do
      if i > maxAuras then break end
      if fakeAura.present(group.unit) then
        for k, v in _G.pairs(fakeAura) do
          auras[i][k] = v
        end
        auras[i].index = i
        i = i + 1
      end
    end
  end

  numAuras = i - 1

  while i <= maxAuras do
    -- TODO: should (aura.name == nil) already be true for all auras after the first one for which is was?
    auras[i].name = nil
    i = i + 1
  end

  _G.table.sort(auras, group.compare)
  return auras
end

local function updateDisplay(display, group)
  if display.hide and display.hide() or not _G.UnitExists(group.unit) then
    for _, frame in _G.ipairs(display.frames) do
      frame:Hide()
    end
    return
  end

  local frameIndex, i, frame, aura = 1, 1, display.frames[1], auras[1]
  while aura and aura.name and frame do
    if display.whitelist and display.whitelist(aura) or display.blacklist and not display.blacklist(aura) or
      not display.whitelist and not display.blacklist
    then
      frame.auraIndex  = aura.index
      frame.auraFilter = aura.filter

      frame.icon:SetTexture(aura.icon)

      if display.borderColor then
        frame:SetBackdropBorderColor(display.borderColor(aura))
      end

      if aura.duration == 0 and aura.expires == 0 then
        frame.cooldown:Hide()
      elseif aura.duration == 0 then -- We only got the time at which the aura will expire.
        _G.error()
      elseif aura.expires == 0 then -- We only got a duration.
        _G.error()
      elseif aura.expires > _G.GetTime() then -- The aura expires in the future (like you might expect).
        local duration

        -- GetTime() can be quite small and the value of GetTime() when the aura expires may be less than its duration.
        -- Then, this variable (start) is negative.
        -- In such a case Cooldown:SetCooldown bugs out. I think it happens with auras that were applied long before we
        -- logged in. The value of of GetTime() seems to be related to the time of booting the OS.
        local start = aura.expires - aura.duration

        if start < 0 then
          start = 0.01 -- OmniCC doesn't work with cooldowns starting at 0.
          duration = aura.expires - start
        elseif start > _G.GetTime() then -- The aura wasn't applied yet?! Does this really happen?
          start = _G.GetTime()
          duration = aura.expires - _G.GetTime()
        else
          duration = aura.duration
        end
        frame.cooldown:Show()
        _G.CooldownFrame_SetTimer(frame.cooldown, start, duration, true)
      elseif aura.expires <= _G.GetTime() then -- Aura has already expired.
        frame.cooldown:Hide()
      else
        _G.error()
      end
      if frame:IsMouseOver() then
        local handler = frame:GetScript("OnEnter")
        handler(frame, false)
      end
      frame:Show()

      aura.name = nil -- TODO: Make this behaviour controllable?
      frameIndex = frameIndex + 1
      frame = display.frames[frameIndex]
    end
    i = i + 1
    aura = auras[i]
  end
  _G.table.sort(auras, group.compare)

  if display.orientation == "HORIZONTAL" then
    local numAuras = frameIndex - 1
    if display.numRows == 1 then
      local width = 2 + (numAuras >= 1 and display.size + _G.math.abs(display.xGap) * (numAuras - 1) or 0)
      display.anchorFrame:SetWidth(width)
    end
    local numFrames = _G.math.min(numAuras, display.numRows * display.numCols)
    local numRows = _G.math.ceil(numFrames / display.numCols)
    local height = 2 + (numRows >= 1 and display.size + _G.math.abs(display.yGap) * (numRows - 1) or 0)
    display.anchorFrame:SetHeight(height)
  elseif display.orientation == "VERTICAL" then
    _G.error("Not implemented.") -- TODO.
  end

  while frame and frame:IsShown() do
    --frame.icon:SetTexture(nil)
    _G.CooldownFrame_SetTimer(frame.cooldown) -- http://wowprogramming.com/utils/xmlbrowser/test/FrameXML/Cooldown.lua
    frame:Hide()
    frameIndex = frameIndex + 1
    frame = display.frames[frameIndex]
  end
end

local function updateGroups(unitID)
  for _, group in _G.ipairs(groups) do
    if not unitID or group.unit == unitID then
      GetAuras(group) -- Initialize the auras table and the numAuras variable.
      for _, display in _G.ipairs(group.displays) do
        updateDisplay(display, group)
      end
    end
  end
end

local handlerFrame = _G.CreateFrame("Frame")

function handlerFrame:ADDON_LOADED(name)
  _G.assert(_G.NinjaKittyUF)
  self:UnregisterEvent("ADDON_LOADED")

  for _, group in _G.ipairs(groups) do
    initGroup(group)
  end

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
  local stateHandler = _G.CreateFrame("Frame", nil, nil, "SecureHandlerStateTemplate")

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
    --_G.print("Unit exists: \"" .. unitID .. "\".")
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

function handlerFrame:UNIT_AURA(unitID) -- http://wowprogramming.com/docs/events/UNIT_AURA
  updateGroups(unitID)
end

function handlerFrame:UNIT_CONNECTION(unit, hasConnected)
  updateGroups(unitID)
end

function handlerFrame:PLAYER_TARGET_CHANGED(cause)
  --if (_G.select(2, _G.GetInstanceInfo())) ~= "arena" then
    updateGroups("target")
  --end
end

function handlerFrame:PLAYER_FOCUS_CHANGED()
  --if (_G.select(2, _G.GetInstanceInfo())) ~= "arena" then
    updateGroups("focus")
  --end
end

function handlerFrame:GROUP_ROSTER_UPDATE()
  for i = 1, 4 do
    updateGroups("party" .. i)
  end
end

-- TODO.
function handlerFrame:ARENA_OPPONENT_UPDATE()
  -- ...
end

handlerFrame:SetScript("OnEvent", function(self, event, ...)
  return self[event](self, ...)
end)

handlerFrame:RegisterEvent("ADDON_LOADED")

-- vim: tw=120 sw=2 et
