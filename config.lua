setfenv(1, NinjaKittyAuras)

local NinjaKittyAuras = _G.NinjaKittyAuras

auras, groups, comparators, mutators, fakeAuras = {}, {}, {}, {}, {}

-- Use this one for all buff groups. We never care about these auras.
auras.generalBuffBlacklist = {
  ["Precious's Ribbon"] = true,
  ["Temporal Anomaly"] = true,
}
-- TODO: Just gave generalAuraBlacklist?

-- TODO: Use spell IDs.
auras.playerBuffBlacklist = {
  ["Aquatic Form"] = true,
  ["Barkskin"] = true,
  ["Bear Form"] = true,
  ["Berserk"] = true,
  ["Berserking"] = true,
  ["Call of Conquest"] = true,
  ["Cat Form"] = true,
  ["Clearcasting"] = true,
  ["Dash"] = true,
  ["Dream of Cenarius"] = true,
  ["Glyph of Amberskin Protection"] = true,
  ["Heart of the Wild"] = true,
  ["Honorless Target"] = true,
  ["Incarnation: King of the Jungle"] = true,
  ["Might of Ursoc"] = true,
  ["Nature's Grasp"] = true,
  ["Nature's Vigil"] = true,
  ["Predatory Swiftness"] = true,
  ["Prowl"] = true,
  ["Savage Roar"] = true,
  ["Shadowmeld"] = true,
  ["Stampede"] = true,
  ["Stampeding Roar"] = true,
  ["Surge of Conquest"] = true,
  ["Survival Instincts"] = true,
  ["Swift Flight Form"] = true,
  ["Synapse Springs"] = true,
  ["Tiger's Fury"] = true,
  ["Travel Form"] = true,
}
-- http://lua-users.org/wiki/SetOperations

auras.longPlayerBuffBlacklist = {
  ["Leader of the Pack"] = true,
  --["Symbiosis"] = true,
}

auras.playerBuffTooltipBlacklist = {
  "Increases ground speed by %d%d%d?%%",
}

auras.importantOwnDebuffs = {
  [1822] = true, -- Rake
  [1079] = true, -- Rip
  [770]  = true, -- Faerie Fire
}

-- TODO.
auras.roots = {

}

-- TODO.
auras.shortRoots = {

}

auras.disarms = {
  [50541]  = true, -- Clench (Scorpid pet)
  [676]    = true, -- Disarm
  [137461] = true, -- Disarmed (Ring of Peace)
  [51722]  = true, -- Dismantle
  [117368] = true, -- Grapple Weapon
  [126458] = true, -- Grapple Weapon
  [91644]  = true, -- Snatch (Bird of Prey pet)
  [64058]  = true, -- Psychic Horror
}

-- Full Crowd Control and Silences. Based on http://us.battle.net/wow/en/forum/topic/10195910192,
-- http://www.arenajunkies.com/topic/227748-mop-diminishing-returns-updating-the-list and Gladius.
auras.fullCC = {
  -- *Stuns*
  [108194] = true, -- Asphyxiate
  [47481]  = true, -- Gnaw (Ghoul)
  [91797]  = true, -- Monstrous Blow (Ghoul with Dark Transformation)
  [115001] = true, -- Remorseless Winter
  [102795] = true, -- Bear Hug
  [22570]  = true, -- Maim
  [5211]   = true, -- Mighty Bash
  [9005]   = true, -- Pounce
  [102546] = true, -- Pounce (Incarnation)
  [110698] = true, -- Hammer of Justice (Symbiosis)
  -- TODO: Are we missing stuff added by Symbiosis?
  [117526] = true, -- Binding Shot
  [24394]  = true, -- Intimidation
  -- TODO: Are all these pet abilities actually stuns?
  [90337]  = true, -- Bad Manner (Monkey pet)
  [126246] = true, -- Lullaby (Crane pet)
  [126423] = true, -- Petrifying Gaze (Basilisk pet)
  [126355] = true, -- Paralyzing Quill (Porcupine Pet)
  [56626]  = true, -- Sting (Wasp pet)
  [50519]  = true, -- Sonic Blast (Bat pet)
  [96201]  = true, -- Web Wrap (Shale Spider pet)
  [118271] = true, -- Combustion Impact
  [44572]  = true, -- Deep Freeze
  [119392] = true, -- Charging Ox Wave
  [122242] = true, -- Clash
  [120086] = true, -- Fists of Fury
  [119381] = true, -- Leg Sweep
  [115752] = true, -- Blinding Light (Glyphed)
  [853]    = true, -- Hammer of Justice
  [119072] = true, -- Holy Wrath
  [105593] = true, -- Fist of Justice
  [1833]   = true, -- Cheap Shot
  [408]    = true, -- Kidney Shot
  [118345] = true, -- Pulverize (Primal Earth Elemental)
  [118905] = true, -- Static Charge (Capacitor Totem)
  [89766]  = true, -- Axe Toss (Felguard)
  [30283]  = true, -- Shadowfury
  [22703]  = true, -- Infernal Awakening (Summon Infernal stun)
  -- TODO: Which  is the real Showckwave?
  [46968]  = true, -- Shockwave
  [132168] = true, -- Shockwave
  -- TODO: Which  is the real Storm Bolt?
  [107570] = true, -- Storm Bolt
  [132169] = true, -- Storm Bolt
  [20549]  = true, -- War Stomp (Tauren Racial)

  [127361] = true, -- Bear Hug (Windwalker Monk Symbiosis)

  -- *Stuns (Short)*
  [113953] = true, -- Paralysis (Paralytic Poison stun)
  [96273]  = true, -- Charge Stun (Charge)
  [77505]  = true, -- Earthquake -- TODO: is this the correct ID?
  [118895] = true, -- Dragon Roar -- TODO: is this the correct ID?

  -- *Mesmerizes*
  [2637]  = true, -- Hibernate
  -- TODO: Which one do we need?
  [55041]  = true, -- Freezing Trap Effect
  [1499]   = true, -- Freezing Trap Effect
  [3355]   = true, -- Freezing Trap (Trap Launcher)
  [60192]  = true, -- Freezing Trap (Trap Launcher)
  [19386]  = true, -- Wyvern Sting
  [118]    = true, -- Polymorph
  [61305]  = true, -- Polymorph (Black Cat)
  [28272]  = true, -- Polymorph (Pig)
  [61025]  = true, -- Polymorph (Serpent)
  [28271]  = true, -- Polymorph (Turtle)
  [82691]  = true, -- Ring of Frost
  [115078] = true, -- Paralysis
  [20066]  = true, -- Repentance
  [9484]   = true, -- Shackle Undead
  [1776]   = true, -- Gouge
  [6770]   = true, -- Sap
  [76780]  = true, -- Bind Elemental
  [51514]  = true, -- Hex
  [710]    = true, -- Banish
  [107079] = true, -- Quaking Palm (Pandaren Racial)

  -- *Mesmerizes (Short)*
  [99]     = true, -- Disorienting Roar
  [19503]  = true, -- Scatter Shot
  [31661]  = true, -- Dragon's Breath
  [123393] = true, -- Breath of Fire (Glyphed)
  [88625]  = true, -- Holy Word: Chastise

  -- *Fears*
  [113004] = true, -- Intimidating Roar (Druid Symbiosis)
  [113056] = true, -- Intimidating Roar (Druid Symbiosis)
  [1513]   = true, -- Scare Beast
  [105421] = true, -- Blinding Light
  [10326]  = true, -- Turn Evil
  [145067] = true, -- Turn Evil (?)
  [8122]   = true, -- Psychic Scream
  [113792] = true, -- Psychic Terror (Psyfiend)
  [2094]   = true, -- Blind
  [5782]   = true, -- Fear
  [118699] = true, -- Fear
  [130616] = true, -- Fear
  [5484]   = true, -- Howl of Terror
  [115268] = true, -- Mesmerize (Shivarra)
  [6358]   = true, -- Seduction (Succubus)
  [5246]   = true, -- Intimidating Shout

  -- *Horrors*
  [111397] = true, -- Blood Horror
  [64044]  = true, -- Psychic Horror
  [87204]  = true, -- Sin and Punishment
  [6789]   = true, -- Mortal Coil

  -- *Silences*
                    -- Asphyxiate?
  [47476]   = true, -- Strangulate
  [114237]  = true, -- Glyph of Fae Silence
  [34490]   = true, -- Silencing Shot
  [102051]  = true, -- Frostjaw
  [55021]   = true, -- Silenced - Improved Counterspell
  [137460]  = true, -- Silenced (Ring of Peace)
  [116709]  = true, -- Spear Hand Strike
  [31935]   = true, -- Avenger's Shield
  [15487]   = true, -- Silence (Priest)
  [1330]    = true, -- Garrote - Silence
  [19647]   = true, -- Spell Lock (Fel Hunter)
  [115782]  = true, -- Optical Blast (Observer)
  [28730]   = true, -- Arcane Torrent (Blood Elf Racial, classes with mana?)
  [25046]   = true, -- Arcane Torrent (Blood Elf Racial, Rogue)
  [69179]   = true, -- Arcane Torrent (Blood Elf Racial, Warrior)
  [50613]   = true, -- Arcane Torrent (Blood Elf Racial, Death Knight)
  [80483]   = true, -- Arcane Torrent (Blood Elf Racial, Hunter)
  [129597]  = true, -- Arcane Torrent (Blood Elf Racial, Monk)
  [155145]  = true, -- Arcane Torrent (Blood Elf Racial, Paladin)

  -- *Cyclone*
  [33786]  = true, -- Cyclone
  [113506] = true, -- Cyclone (Symbiosis)

  -- *Charms*
  [605] = true, -- Dominate Mind
}

-- TODO: Windwalk Totem?
auras.immunities = {
  [108978] = true, -- Alter Time
  [110909] = true, -- Alter Time (actual buff)
  [48707]  = true, -- Anti-Magic Shell
  [110570] = true, -- Anti-Magic Shell (Symbiosis)
  [46924]  = true, -- Bladestorm
  [31224]  = true, -- Cloak of Shadows
  [110788] = true, -- Cloak of Shadows (Symbiosis)
  [110913] = true, -- Dark Bargain
  [19263]  = true, -- Deterrence
  [67801]  = true, -- Deterrence (?)
  [110617] = true, -- Deterrence (?)
  [110618] = true, -- Deterrence (?)
  [114406] = true, -- Deterrence (?)
  [148467] = true, -- Deterrence (?)
  [122465] = true, -- Dematerialize
  [47585]  = true, -- Dispersion
  [110715] = true, -- Dispersion
  [642]    = true, -- Divine Shield
  [110700] = true, -- Divine Shield (Symbiosis)
  [6346]   = true, -- Fear Ward
  [115760] = true, -- Glyph of Ice Block
  [8178]   = true, -- Grounding Totem Effect
  [1022]   = true, -- Hand of Protection
  [48792]  = true, -- Icebound Fortitude
  [110575] = true, -- Icebound Fortitude (Symbiosis)
  [45438]  = true, -- Ice Block
  [110696] = true, -- Ice Block (Symbiosis)
  [3411]   = true, -- Intervene
  [147833] = true, -- Intervene (?)
  [122292] = true, -- Intervene (Symbiosis)
  [66]     = true, -- Invisibility
  [114028] = true, -- Mass Spell Reflection
  [137562] = true, -- Nimble Brew
  [112833] = true, -- Spectral Guise
  [114029] = true, -- Safeguard
  [23920]  = true, -- Spell Reflection
  [113002] = true, -- Spell Reflection (Symbiosis)
  [114896] = true, -- Windwalk Totem
  [115176] = true, -- Zen Meditation
}

auras.defensives = {
  [108271] = true, -- Astral Shift
  [22812] = true,  -- Barkskin
  [74001] = true,  -- Combat Readiness
  [118038] = true, -- Die by the Sword
  [5277] = true,   -- Evasion
  [1966] = true,   -- Feint
  [113613] = true, -- Growl (Rogue Symbiosis)
  [47788] = true,  -- Guardian Spirit
  [102342] = true, -- Ironbark
  [116849] = true, -- Life Cocoon
  [33206] = true,  -- Pain Suppression
  [53480] = true,  -- Roar of Sacrifice
  [30823] = true,  -- Shamanistic Rage
  [61336] = true,  -- Survival Instincts
  [113306] = true, -- Survival Instincts (Brewmaster Monk Symbiosis)
  [871] = true,    -- Shield Wall
  [125174] = true, -- Touch of Karma (buff)
}

-- TODO: Use spell IDs.
mutators.generalBuffMutators = {
  ["Inner Fire"] = function(aura)
    aura.shouldConsolidate = 1
  end,
  ["Inner Will"] = function(aura)
    aura.shouldConsolidate = 1
  end,
  ["Gaze of the Black Prince"] = function(aura)
    aura.shouldConsolidate = 1
  end,
}

mutators.debuffMutators = {
  ["Faerie Fire"] = function(aura)
    aura.caster = "player"
  end,
  ["Faerie Swarm"] = function(aura)
    aura.caster = "player"
  end,
  ["Weakened Blows"] = function(aura)
    aura.caster = "player"
  end,
  ["Weakened Armor"] = function(aura)
    aura.caster = "player"
  end,
}

auras.targetDebuffBlacklist = {
  [1822] = true, -- Rake
  [1079] = true, -- Rip
}

do
  -- http://www.wowhead.com/spell=1126/mark-of-the-wild#comments
  local increasedStats = {
    ["Mark of the Wild"] = true,
    ["Legacy of the Emperor"] = true,
    ["Blessing of Kings"] = true,
    ["Embrace of the Shale Spider"] = true,
    ["Xuen's Presence: Mark of the Wild"] = true,
  }

  fakeAuras.statsMissing = {
    name = "Stats missing",
    icon = [[Interface\Icons\Spell_Nature_Regeneration]],
    count = 0,
    dispelType = "Curse",
    duration = 0,
    expires = 0,
    spellID = 1126,
    value2 = 5,
    present = function(unit)
      if not _G.UnitIsConnected(unit) or _G.UnitIsDeadOrGhost(unit) or not _G.UnitInPhase(unit) then
        return false
      end
      local inRange = _G.IsSpellInRange("Mark of the Wild", unit)
      if not inRange or inRange == 0 then return false end -- TODO: this is not the correct range
        -- and this isn't updated when it should be.
      for k, _ in _G.pairs(increasedStats) do
        if _G.UnitAura(unit, k, nil , "HELPFUL") then
          return false
        end
      end
      return true
    end,
    filter = "HARMFUL",
  }
end

-- These order functions receive two arguments and must return true if the first argument should
-- come first in the sorted array. Note that Lua's table.sort is not a stable sort.

comparators.longerFirst = function(aura1, aura2)
  if aura1.expires == 0 and aura2.expires == 0 then -- Neither aura expires.
    return aura1.index < aura2.index
  elseif aura1.expires == 0 then -- Only aura1 is permanent.
    return true
  elseif aura2.expires == 0 then -- Only aura2 is permanent.
    return false
  else -- Both auras expire.
    return aura1.expires > aura2.expires
  end
end

-- Auras applied by the player first.
comparators.defaultCompare = function(aura1, aura2)
  if aura1.caster and aura1.caster == "player" and not (aura2.caster and aura2.caster == "player")
  then
    return true
  elseif aura2.caster and aura2.caster == "player" and
    not (aura1.caster and aura1.caster == "player")
  then
    return false
  else -- Both auras or neither are player-applied.
    return comparators.longerFirst(aura1, aura2)
  end
end

comparators.buffsFirst = function(aura1, aura2)
  if aura1.filter == "HELPFUL" and aura2.filter == "HARMFUL" then
    return true
  elseif aura1.filter == "HARMFUL" and aura2.filter == "HELPFUL" then
    return false
  end

  return comparators.longerFirst(aura1, aura2)
end

-- TODO: display defensives that aren't cast by player?
_G.table.insert(groups, {
  name = "NKPlayerCC",
  unit = "player",
  --[[
  parent = "NKPlayerFrame",
  anchorPoint = "TOPLEFT",
  relativePoint = "TOPRIGHT",
  xOffset = 2,
  yOffset = 0,
  size = 32,
  xGap = 32 + 2,
  yGap = -(32 + 2),
  --]]
  ----[[
  anchorPoint = "CENTER",
  relativePoint = "CENTER",
  xOffset = 0,
  yOffset = -46, -- 44 + 2 = 46
  size = 44,
  xGap = (44 + 2),
  yGap = -(44 + 2),
  --]]
  numRows = 1,
  numCols = 4,
  orientation = "HORIZONTAL",
  filters = { "HARMFUL" },
  compare = comparators.buffsFirst,
  whitelist = function(aura)
    return auras.fullCC[aura.spellID] or auras.disarms[aura.spellID] or
      aura.spellID == 122470 --[[Touch of Karma]]
  end,
  borderColor = function(aura)
    if aura.filter == "HARMFUL" then
      return 192, 0, 0
    end
    return 0, 0, 0
  end,
})

-- TODO: filter auras that are also returned for the vehicle unit?
_G.table.insert(groups, {
  name = "NKPlayerAuras",
  unit = "player",
  parent = "NKPlayerFrame",
  anchorPoint = "BOTTOMRIGHT",
  relativePoint = "TOPRIGHT",
  xOffset = 0,
  yOffset = 2,
  size = 28,
  xGap = -(28 + 2),
  yGap = (28 + 2),
  numRows = 3,
  numCols = 7,
  orientation = "HORIZONTAL",
  filters = { "HELPFUL", "HARMFUL" },
  compare = comparators.buffsFirst,
  blacklist = function(aura)
    return auras.fullCC[aura.spellID] or auras.disarms[aura.spellID] or
      (aura.filter == "HELPFUL" and (auras.generalBuffBlacklist[aura.name] or
      auras.playerBuffBlacklist[aura.name] or aura.duration >= 300 or aura.shouldConsolidate
      or blacklistByTooltip("player", aura.index, "HELPFUL", auras.playerBuffTooltipBlacklist)))
  end,
  mutators = mutators.generalBuffMutators,
  fakeAuras = {
    statsMissing = fakeAuras.statsMissing,
  },
  borderColor = function(aura)
    if aura.filter == "HARMFUL" then
      return 192, 0, 0
    end
    return 0, 0, 0
  end,
})

_G.table.insert(groups, {
  name = "NKLongPlayerBuffs",
  unit = "player",
  anchorPoint = "TOPLEFT",
  relativePoint = "TOPLEFT",
  xOffset = 2,
  yOffset = -2,
  size = 28,
  xGap = (28 + 2),
  yGap = -(28 + 2),
  numRows = 1,
  numCols = 14,
  orientation = "HORIZONTAL",
  filters = { "HELPFUL" },
  compare = comparators.defaultCompare,
  blacklist = function(aura)
    return auras.generalBuffBlacklist[aura.name] or
      auras.longPlayerBuffBlacklist[aura.name] or
      (aura.duration < 300 and not aura.shouldConsolidate)
  end,
  mutators = mutators.generalBuffMutators,
})

_G.table.insert(groups, {
  name = "NKVehicleAuras",
  unit = "vehicle",
  parent = "NKVehicleFrame",
  anchorPoint = "BOTTOMRIGHT",
  relativePoint = "TOPRIGHT",
  xOffset = 0,
  yOffset = 2,
  size = 28,
  xGap = -(28 + 2),
  yGap = (28 + 2),
  numRows = 3,
  numCols = 7,
  orientation = "HORIZONTAL",
  filters = { "HELPFUL", "HARMFUL" },
  compare = comparators.buffsFirst,
  borderColor = function(aura)
    if aura.filter == "HARMFUL" then
      return 192, 0, 0
    end
    return 0, 0, 0
  end,
})

_G.table.insert(groups, {
  name = "NKTargetAuras",
  unit = "target",
  parent = "NKTargetFrame",
  anchorPoint = "TOPRIGHT",
  relativePoint = "TOPLEFT",
  xOffset = -2,
  yOffset = 0,
  size = 32,
  xGap = -(32 + 2),
  yGap = -(32 + 2),
  numRows = 1,
  numCols = 4,
  orientation = "HORIZONTAL",
  filters = { "HELPFUL", "HARMFUL" },
  compare = comparators.buffsFirst,
  whitelist = function(aura)
    return auras.immunities[aura.spellID] or auras.fullCC[aura.spellID] or
      auras.disarms[aura.spellID] or auras.defensives[aura.spellID]
  end,
  borderColor = function(aura)
    if aura.filter == "HARMFUL" then
      return 192, 0, 0
    end
    return 0, 0, 0
  end,
})

_G.table.insert(groups, {
  name = "NKOtherTargetAuras",
  unit = "target",
  parent = "NKTargetFrame",
  anchorPoint = "BOTTOMLEFT",
  relativeTo = "NKTargetFrame",
  relativePoint = "TOPLEFT",
  xOffset = 0,
  yOffset = 2,
  size = 28,
  xGap = (28 + 2),
  yGap = (28 + 2),
  numRows = 3,
  numCols = 7,
  orientation = "HORIZONTAL",
  filters = { "HELPFUL", "HARMFUL" },
  compare = comparators.buffsFirst,
  blacklist = function(aura)
    return auras.immunities[aura.spellID] or auras.fullCC[aura.spellID] or
      auras.disarms[aura.spellID] or auras.defensives[aura.spellID] or
      auras.generalBuffBlacklist[aura.name] or
      (aura.filter == "HELPFUL" and aura.duration >= 300) or aura.shouldConsolidate or
      (auras.targetDebuffBlacklist[aura.spellID] and aura.caster == "player")
    --[[
    return (aura.filter == "HELPFUL" and (auras.generalBuffBlacklist[aura.name] or
      auras.immunities[aura.spellID] or aura.duration >= 300 or aura.shouldConsolidate)) or
      (aura.filter == "HARMFUL" and
      ((auras.targetDebuffBlacklist[aura.spellID] and aura.caster == "player") or
      auras.fullCC[aura.spellID] or auras.disarms[aura.spellID]))
    --]]
  end,
  mutators = mutators.generalBuffMutators,
  borderColor = function(aura)
    if aura.filter == "HARMFUL" then
      return 192, 0, 0
    end
    return 0, 0, 0
  end,
})

_G.table.insert(groups, {
  name = "NKLongTargetBuffs",
  unit = "target",
  parent = "NKTargetFrame",
  anchorPoint = "TOPRIGHT",
  relativeTo = "UIParent",
  relativePoint = "TOPRIGHT",
  xOffset = -2,
  yOffset = -2,
  size = 28,
  xGap = -(28 + 2),
  yGap = -(28 + 2),
  numRows = 1,
  numCols = 16,
  orientation = "HORIZONTAL",
  filters = { "HELPFUL" },
  compare = comparators.longerFirst,
  blacklist = function(aura)
    return auras.generalBuffBlacklist[aura.name] or (aura.duration < 300 and not
      aura.shouldConsolidate)
  end,
  mutators = mutators.generalBuffMutators,
})

_G.table.insert(groups, {
  name = "NKFocusAuras",
  unit = "focus",
  parent = "NKFocusFrame",
  anchorPoint = "TOPRIGHT",
  relativePoint = "TOPLEFT",
  xOffset = -2,
  yOffset = 0,
  size = 32,
  xGap = -(32 + 2),
  yGap = -(32 + 2),
  numRows = 1,
  numCols = 4,
  orientation = "HORIZONTAL",
  filters = { "HELPFUL", "HARMFUL" },
  compare = comparators.buffsFirst,
  blacklist = function(aura)
    return (aura.filter == "HELPFUL" and not auras.immunities[aura.spellID]) or
    (aura.filter == "HARMFUL" and not auras.fullCC[aura.spellID] and not
    auras.disarms[aura.spellID])
  end,
  borderColor = function(aura)
    if aura.filter == "HARMFUL" then
      return 192, 0, 0
    end
    return 0, 0, 0
  end,
})

_G.table.insert(groups, {
  name = "NKOtherFocusAuras",
  unit = "focus",
  parent = "NKFocusFrame",
  anchorPoint = "TOPRIGHT",
  relativePoint = "BOTTOMRIGHT",
  xOffset = 0,
  yOffset = -2,
  size = 28,
  xGap = -(28 + 2),
  yGap = -(28 + 2),
  numRows = 1,
  numCols = 4,
  orientation = "HORIZONTAL",
  filters = { "HELPFUL", "HARMFUL" },
  compare = comparators.buffsFirst,
  blacklist = function(aura)
    return aura.filter == "HELPFUL" or (aura.filter == "HARMFUL" and
    (not auras.importantOwnDebuffs[aura.spellID] or aura.caster ~= "player"))
  end,
  mutators = mutators.debuffMutators,
  borderColor = function(aura)
    if aura.filter == "HARMFUL" then
      return 192, 0, 0
    end
    return 0, 0, 0
  end,
})

-- Define groups for party members.
for i = 1, 4 do
  _G.table.insert(groups, {
    name = "NKParty" .. i .. "Auras",
    unit = "party" .. i,
    parent = "NKParty" .. i .. "Frame",
    anchorPoint = "TOPLEFT",
    relativePoint = "TOPRIGHT",
    xOffset = 2,
    yOffset = 0,
    size = 32,
    xGap = 32 + 2,
    yGap = -(32 + 2),
    numRows = 1,
    numCols = 4,
    orientation = "HORIZONTAL",
    filters = { "HARMFUL" },
    compare = comparators.buffsFirst,
    blacklist = function(aura)
      return aura.filter == "HARMFUL" and not auras.fullCC[aura.spellID] and not
      auras.disarms[aura.spellID]
    end,
    borderColor = function(aura)
      if aura.filter == "HARMFUL" then
        return 192, 0, 0
      end
      return 0, 0, 0
    end,
  })
  _G.table.insert(groups, {
    name = "NKOtherParty" .. i .. "Auras",
    unit = "party" .. i,
    parent = "NKParty" .. i .. "Frame",
    anchorPoint = "BOTTOMRIGHT",
    relativePoint = "TOPRIGHT",
    xOffset = 0,
    yOffset = 2,
    size = 28,
    xGap = -(28 + 2),
    yGap = -(28 + 2),
    numRows = 1,
    numCols = 7,
    orientation = "HORIZONTAL",
    filters = { "HELPFUL", "HARMFUL" },
    compare = comparators.buffsFirst,
    fakeAuras = {
      statsMissing = fakeAuras.statsMissing,
    },
    blacklist = function(aura)
      return (aura.filter == "HELPFUL" and (aura.duration >= 300 or aura.shouldConsolidate or
        aura.caster ~= "player")) or (aura.filter == "HARMFUL" and aura.dispelType ~= "Curse" and
        aura.dispelType ~= "Poison")
    end,
    borderColor = function(aura)
      if aura.filter == "HARMFUL" then
        return 192, 0, 0
      end
      return 0, 0, 0
    end,
    --[[
    hide = function()
      return _G.GetNumGroupMembers() > 5
    end,
    ]]
  })
end
--
-- Define groups for arena opponents.
for i = 1, 3 do
  _G.table.insert(groups, {
    name = "NKArena" .. i .. "Auras",
    unit = "arena" .. i,
    parent = "NKArena" .. i .. "Frame",
    anchorPoint = "TOPRIGHT",
    relativePoint = "TOPLEFT",
    xOffset = -2,
    yOffset = 0,
    size = 32,
    xGap = -(32 + 2),
    yGap = -(32 + 2),
    numRows = 1,
    numCols = 4,
    orientation = "HORIZONTAL",
    filters = { "HELPFUL", "HARMFUL" },
    compare = comparators.buffsFirst,
    blacklist = function(aura)
      return (aura.filter == "HELPFUL" and not auras.immunities[aura.spellID]) or
        (aura.filter == "HARMFUL" and not auras.fullCC[aura.spellID] and not
        auras.disarms[aura.spellID])
    end,
    borderColor = function(aura)
      if aura.filter == "HARMFUL" then
        return 192, 0, 0
      end
      return 0, 0, 0
    end,
  })
end

-- vim: tw=120 sw=2 expandtab
