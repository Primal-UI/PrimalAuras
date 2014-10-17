-- TODO: implement some system to hide auras that are exact duplicates (Roar of Sacrifice while Stampede is active).

NinjaKittyAuras = { _G = _G }
setfenv(1, NinjaKittyAuras)

local keys = { "name", "rank", "icon", "count", "dispelType", "duration", "expires", "caster", "isStealable",
  "shouldConsolidate", "spellID", "canApplyAura", "isBossDebuff", "value1", "value2", "value3", "filter", "index" }

local maxDisplayedStacks = 5

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

local function setBorderColor(auraFrame, red, green, blue, alpha)
  alpha = alpha or 1
  auraFrame.BorderTop:SetTexture(red, green, blue, alpha)
  auraFrame.BorderRight:SetTexture(red, green, blue, alpha)
  auraFrame.BorderBottom:SetTexture(red, green, blue, alpha)
  auraFrame.BorderLeft:SetTexture(red, green, blue, alpha)
end

local function NKAuraButton_OnUpdate(self, elapsed)
  local seconds = _G.math.floor(self.expires - _G.GetTime() + .5)
  if seconds < 0 then
    self:SetScript("OnUpdate", nil)
    return
  elseif seconds > 99 then
    self.Duration:Hide()
    return
  else
    self.Duration:SetText(_G.tostring(seconds))
  end
end

local function initDisplay(display, group)
  local parent = display.parent and _G[display.parent] or _G.UIParent

  display.wrapperFrame = _G.CreateFrame("Frame", display.name, parent)
  display.wrapperFrame:SetFrameLevel(10)

  -- When the display is implicitly hidden due to a parent frame being hidden, hide it explicitly. Otherwise it will be
  -- shown again when the parent frame becomes visible, even thought we didn't update it.  TODO: isn't that fine?
  display.wrapperFrame:SetScript("OnHide", function(self)
    --self:Hide()
  end)
  display.wrapperFrame:SetScript("OnShow", function(self)
    -- ...
  end)

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
      display.wrapperFrame:SetPoint(display.anchorPoint, relativeTo, display.relativePoint, xOffset, yOffset)
      display.wrapperFrame:SetSize(2 + display.size + (display.numCols - 1) * _G.math.abs(display.xGap), 2)
    elseif display.orientation == "VERTICAL" then
      _G.error("Not implemented.") -- TODO.
    end

    --[[
    local texture = display.wrapperFrame:CreateTexture(nil, "OVERLAY")
    texture:SetParent(display.wrapperFrame)
    texture:SetAllPoints()
    texture:SetTexture(1.0, 1.0, 1.0, 0.3)
    --]]

  end

  display.frames = {}

  for i = 1, display.numRows * display.numCols do
    local frame = _G.CreateFrame("Button", display.name .. i, display.wrapperFrame, "NKAuraButtonTemplate")
    --frame:SetFrameLevel(display.wrapperFrame:GetFrameLevel() - 1)
    frame:SetSize(display.size, display.size)
    --frame:EnableMouse(true)
    frame:RegisterForClicks("RightButtonDown")
    --frame:Hide()

    --[[
    if display.borderColor then
      frame:SetBackdrop(backdrop)
      frame:SetBackdropBorderColor(0, 0, 0)
      frame:SetBackdropColor(0, 0, 0, 0)
    end
    ]]

    --frame.Cooldown:SetDrawBling(false)
    --frame.Cooldown:SetDrawEdge(false)
    --frame.Cooldown:SetDrawSwipe(true)
    --frame.Cooldown:SetReverse(true)
    --[[
    _G.hooksecurefunc(frame.Cooldown, "Hide", function(self)
      self:Show()
    end)
    ]]

    if display.showCooldownSweep then
      --[[
      frame:SetScript("OnShow", function(self)
        if not (frame.Cooldown:IsShown() and frame.Cooldown:GetCooldownDuration()) then
          _G.print(frame.start, frame.duration)
          frame.Cooldown:SetCooldown(frame.start, frame.duration)
        end
      end)
      ]]
      frame:SetScript("OnHide", function(self)
        local start, duration = frame.start, frame.duration
        if start and duration and start ~= 0 and duration ~= 0 and _G.GetTime() <= start + duration then
          self.Cooldown:SetCooldown(start, duration)
        end
      end)
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
        frame:SetPoint(anchorPoint, display.wrapperFrame, anchorPoint, xOffset, yOffset)
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
      local result = comparator(aura1, aura2)
      if result then
        return result
      end
      return nil -- TODO.
    end
  end
  for _, display in _G.ipairs(group.displays) do
    initDisplay(display, group)
  end
end

local auras, maxAuras, numAuras = {}, 100 -- TODO: do we need a maxAuras constant?
for i = 1, maxAuras do
  auras[i] = {}
end

local function GetAuras(group)
  local i = 1
  for _, filter in _G.ipairs(group.filters) do
    local queryIndex = 1
    while queryIndex <= 40 and i <= maxAuras do
      local aura = auras[i]

      aura.name, aura.rank, aura.icon, aura.count, aura.dispelType, aura.duration, aura.expires, aura.caster,
      aura.isStealable, aura.shouldConsolidate, aura.spellID, aura.canApplyAura, aura.isBossDebuff, aura.value1,
      aura.value2, aura.value3 = _G.UnitAura(group.unit, queryIndex, filter)

      if not aura.name then
        break
      end

      aura.filter = filter
      aura.index = queryIndex

      if group.mutators then
        if group.mutators[aura.spellID] then
          group.mutators[aura.spellID](aura)
        elseif group.mutators[aura.name] then
          group.mutators[aura.name](aura)
        end
      end

      aura.isExtraStack = nil
      local j = i + _G.math.min(aura.count or 1, maxDisplayedStacks)
      i = i + 1
      --[[
      -- TODO: implement some sort of blacklist for auras where we don't care about stacks. The Tigereye Brew damage
      -- buff stacks up to 10 times; it could be reasonable to add an aura for every second stack.
      if aura.name ~= "Weakened Armor" and aura.name ~= "Agony" and aura.name ~= "Prayer of Mending" and
        aura.name ~= "Tiger Strikes" and aura.count <= maxDisplayedStacks
      then
        while i < j do
          -- "for k, v in _G.pairs(aura) do" doesn't do it because it will fail to changes entries in auras[i] to nil that
          -- aren't present in aura.
          for _, key in _G.ipairs(keys) do
            auras[i][key] = aura[key]
          end
          auras[i].isExtraStack = true
          i = i + 1
        end
      end
      --]]

      queryIndex = queryIndex + 1
    end
  end

  if group.fakeAuras and _G.UnitExists(group.unit) then
    for _, fakeAura in _G.pairs(group.fakeAuras) do
      if i > maxAuras then break end
      if fakeAura.present(group.unit) then
        auras[i].isExtraStack = nil
        for _, key in _G.ipairs(keys) do
          auras[i][key] = fakeAura[key]
        end
        --[[for k, v in _G.pairs(fakeAura) do
          auras[i][k] = v
        end]]
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

  return auras
end

local selectedAuras = {}

local function updateDisplay(display, group)
  do -- Populate the selectedAuras table with the auras this display will show.
    local numFrames, frameIndex, auraIndex = #display.frames, 1, 1
    while auraIndex <= numAuras and frameIndex <= numFrames do
      local aura = auras[auraIndex]
      if aura.name then
        if display.whitelist and display.whitelist(aura) or display.blacklist and not display.blacklist(aura) or
          not display.whitelist and not display.blacklist
        then
          selectedAuras[frameIndex] = aura
          frameIndex = frameIndex + 1
        end
      end
      auraIndex = auraIndex + 1
    end
    while selectedAuras[frameIndex] do
      selectedAuras[frameIndex] = nil
      frameIndex = frameIndex + 1
    end
  end
  _G.table.sort(selectedAuras, display.compare or group.compare)

  local frameIndex, i, frame, aura = 1, 1, display.frames[1], selectedAuras[1]
  while aura and aura.name and frame do
    if display.whitelist and display.whitelist(aura) or display.blacklist and not display.blacklist(aura) or
      not display.whitelist and not display.blacklist
    then
      frame.auraIndex  = aura.index
      frame.auraFilter = aura.filter

      frame.Icon:SetTexture(aura.icon)

      if aura.isExtraStack then
        frame.Icon:SetAlpha(.75)
        --_G.SetDesaturation(frame.Icon, true) -- http://wowprogramming.com/docs/widgets/Texture/SetDesaturated
      else
        frame.Icon:SetAlpha(1)
        --_G.SetDesaturation(frame.Icon)
      end

      if aura.count and aura.count > 1 then
        frame.Count:Show()
        frame.Count:SetText(aura.count)
        local width = frame.Count:GetStringWidth()
        if width % 2 == 1 then
          width = width + 1
        end
        local height = frame.Count:GetStringHeight()
      else
        frame.Count:Hide()
      end

      if display.borderColor then
        --frame:SetBackdropBorderColor(display.borderColor(aura))
        setBorderColor(frame, display.borderColor(aura))
      end

      frame.duration, frame.expires, frame.start = aura.duration, aura.expires, 0

      if aura.duration == 0 and aura.expires == 0 then
        frame.Cooldown:Hide()
        frame.Duration:Hide()
        frame:SetScript("OnUpdate", nil)
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
          start = 0.000001 -- OmniCC doesn't work with cooldowns starting at 0.
          duration = aura.expires - start
        elseif start > _G.GetTime() then -- The aura wasn't applied yet?! Does this really happen?
          start = _G.GetTime()
          duration = aura.expires - _G.GetTime()
        else
          duration = aura.duration
        end
        frame.Duration:Show()
        frame.start, frame.duration, frame.expires = start, duration, aura.expires
        frame:SetScript("OnUpdate", NKAuraButton_OnUpdate)
        if display.showCooldownSweep then
          --_G.CooldownFrame_SetTimer(frame.Cooldown, start, duration, true)
          frame.Cooldown:SetCooldown(start, duration)
        end
      else--[[if aura.expires <= _G.GetTime() then]] -- Aura has already expired.
        frame.Cooldown:Hide()
        frame.Duration:Hide()
        frame:SetScript("OnUpdate", nil)
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
    aura = selectedAuras[i]
  end

  if display.orientation == "HORIZONTAL" then
    local numAuras = frameIndex - 1
    if display.numRows == 1 then
      local width = 2 + (numAuras >= 1 and display.size + _G.math.abs(display.xGap) * (numAuras - 1) or 0)
      display.wrapperFrame:SetWidth(width)
    end
    local numFrames = _G.math.min(numAuras, display.numRows * display.numCols)
    local numRows = _G.math.ceil(numFrames / display.numCols)
    local height = 2 + (numRows >= 1 and display.size + _G.math.abs(display.yGap) * (numRows - 1) or 0)
    display.wrapperFrame:SetHeight(height)
  elseif display.orientation == "VERTICAL" then
    _G.error("Not implemented.") -- TODO.
  end

  while frame and frame:IsShown() do
    --frame.Icon:SetTexture(nil)
    --_G.CooldownFrame_SetTimer(frame.Cooldown) -- http://wowprogramming.com/utils/xmlbrowser/test/FrameXML/Cooldown.lua
    frame:Hide()
    frameIndex = frameIndex + 1
    frame = display.frames[frameIndex]
  end
end

local function updateGroups(unitID)
  if unitID and not _G.UnitExists(unitID) then
    --[[
    for _, group in _G.ipairs(groups) do
      if group.unit == unitID then
        for _, display in _G.ipairs(group.displays) do
          display.wrapperFrame:Hide()
        end
      end
    end
    ]]
  else
    for _, group in _G.ipairs(groups) do
      if not unitID or group.unit == unitID then
        GetAuras(group) -- Initialize the auras table and the numAuras variable.
        for _, display in _G.ipairs(group.displays) do
          display.wrapperFrame:Show()
          updateDisplay(display, group)
        end
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

  --handlerFrame:RegisterEvent("PLAYER_LOGIN")
  handlerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  --handlerFrame:RegisterEvent("PLAYER_ALIVE")

  handlerFrame:RegisterEvent("UNIT_AURA")
  handlerFrame:RegisterEvent("UNIT_CONNECTION")
  handlerFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
  handlerFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
  --handlerFrame:RegisterEvent("VEHICLE_UPDATE")
  --handlerFrame:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA")
  handlerFrame:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")

  -- Fires when the composition of the party changes?
  handlerFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

  self.ADDON_LOADED = nil
end

function handlerFrame:PLAYER_LOGIN()
  updateGroups()
end

function handlerFrame:PLAYER_ENTERING_WORLD()
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

function handlerFrame:UNIT_ENTERED_VEHICLE(unit, ...)
  _G.assert(unit == "player")
  _G.assert(_G.UnitExists("vehicle")) -- TODO: fails sometimes. E.g. Darkmoon Faire Tonk Challenge.
  updateGroups("vehicle")
end

function handlerFrame:GROUP_ROSTER_UPDATE()
  for i = 1, 4 do
    updateGroups("party" .. i)
  end
end

function handlerFrame:ARENA_OPPONENT_UPDATE() -- TODO?
  -- ...
end

handlerFrame:SetScript("OnEvent", function(self, event, ...)
  return self[event](self, ...)
end)

handlerFrame:RegisterEvent("ADDON_LOADED")

-- vim: tw=120 sw=2 et
