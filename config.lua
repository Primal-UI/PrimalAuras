setfenv(1, NinjaKittyAuras)

local NinjaKittyAuras = _G.NinjaKittyAuras

auras, groups, comparators, mutators, fakeAuras = {}, {}, {}, {}, {}

-- Use this one for all buff groups. We never care about these auras.
auras.irrelevantAuras = {
  [72968] = true, -- Precious's Ribbon
  [70404] = true, -- Precious's Ribbon -- TODO: remove one of these?
  [145389] = true, -- Temporal Anomaly
}

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

-- TODO: Use spell IDs.
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

auras.roots = {
  [96294]  = true, -- Chains of Ice
  [339]    = true, -- Entangling Roots
  [19975]  = true, -- Entangling Roots (Nature's Grasp). Nature's Grasp is 16689.
  [113770] = true, -- Entangling Roots (Force of Nature). This spell ID is correct for Feral; TODO: also for Balance?
  [102359] = true, -- Mass Entanglement
  [53148]  = true, -- Charge (Tenacity pet). TODO: confirm spell ID.
  [136634] = true, -- Narrow Escape. TODO: confirm spell ID.
  [50245]  = true, -- Pin (Crab pet). TODO: confirm spell ID.
  [90327]  = true, -- Lock Jaw (Dog pet). TODO: confirm spell ID.
  [4167]   = true, -- Web (Spider pet). TODO: confirm spell ID.
  [54706]  = true, -- Venom Web Spray (Silithid pet). TODO: confirm spell ID.
  [33395]  = true, -- Freeze (Water Elemental). TODO: confirm spell ID.
  [102051] = true, -- Frostjaw (Silence and Root). TODO: confirm spell ID.
  [122]    = true, -- Frost Nova. TODO: confirm spell ID.
  [116706] = true, -- Disable. TODO: confirm spell ID.
  [113275] = true, -- Entangling Roots (Mistweaver Monk Symbiosis). TODO: confirm spell ID.
  [87194]  = true, -- Glyph of Mind Blast. TODO: confirm spell ID.
  [114404] = true, -- Void Tendril's Grasp. TODO: confirm spell ID.
  [115197] = true, -- Partial Paralysis. TODO: confirm spell ID.
  [63685]  = true, -- Freeze (Frost Shock with Frozen Power talent). TODO: confirm spell ID.
  [107566] = true, -- Staggering Shout. TODO: confirm spell ID.
  [105771] = true, -- Warbringer (Charge). TODO: confirm spell ID.
}

auras.shortRoots = {
  [45334]  = true, -- Immobilized (Bear Form Wild Charge)
  [64803]  = true, -- Entrapment. TODO: confirm spell ID.
  [111340] = true, -- Ice Ward. TODO: confirm spell ID.
  [123407] = true, -- Spinning Fire Blossom. TODO: confirm spell ID.
  [64695]  = true, -- Earthgrab. TODO: confirm spell ID.
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
  -- *Stuns* --
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
  [127361] = true, -- Bear Hug (Windwalker Monk Symbiosis)
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
  [46968]  = true, -- Shockwave
  [132168] = true, -- Shockwave -- TODO: Which  is the real Showckwave?
  [107570] = true, -- Storm Bolt
  [132169] = true, -- Storm Bolt -- TODO: Which  is the real Storm Bolt?
  [20549]  = true, -- War Stomp (Tauren Racial)
  ---------------------
  -- *Stuns (Short)* --
  [113953] = true, -- Paralysis (Paralytic Poison stun)
  [7922]   = true, -- Charge Stun -- This spell ID appears to be correct (96273 isn't).
  [77505]  = true, -- Earthquake -- TODO: is this the correct ID?
  [118895] = true, -- Dragon Roar -- TODO: is this the correct ID?
  ------------------
  -- *Mesmerizes* --
  [2637]  = true, -- Hibernate
  [55041]  = true, -- Freezing Trap Effect -- TODO: Which one do we need?
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
  --------------------------
  -- *Mesmerizes (Short)* --
  [99]     = true, -- Disorienting Roar
  [19503]  = true, -- Scatter Shot
  [31661]  = true, -- Dragon's Breath
  [123393] = true, -- Breath of Fire (Glyphed)
  [88625]  = true, -- Holy Word: Chastise
  -------------
  -- *Fears* --
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
  ---------------
  -- *Horrors* --
  [111397] = true, -- Blood Horror
  [64044]  = true, -- Psychic Horror
  [87204]  = true, -- Sin and Punishment
  [6789]   = true, -- Mortal Coil
  ----------------
  -- *Silences* -- -- TODO: is there a silcence separate from the stun for Asphyxiate?
  [47476]   = true, -- Strangulate
  [114237]  = true, -- Glyph of Fae Silence
  [34490]   = true, -- Silencing Shot
  [102051]  = true, -- Frostjaw (Silence and Root)
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
  ---------------
  -- *Cyclone* --
  [33786]  = true, -- Cyclone
  [113506] = true, -- Cyclone (Symbiosis)
  --------------
  -- *Charms* --
  [605] = true, -- Dominate Mind
}

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

-- TODO: Might of Ursoc? Last Stand? Combat Insight?
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
  [97463] = true,  -- Rallying Cry. Spell ID confirmed. 97462 is the actual spell.
  [53480] = true,  -- Roar of Sacrifice
  [30823] = true,  -- Shamanistic Rage
  [61336] = true,  -- Survival Instincts
  [113306] = true, -- Survival Instincts (Brewmaster Monk Symbiosis)
  [871] = true,    -- Shield Wall
  [125174] = true, -- Touch of Karma (buff)
}

-- TODO: Use spell IDs!
mutators.generalBuffMutators = {
  ["Inner Fire"] = function(aura)
    aura.shouldConsolidate = 1
  end,
  ["Inner Will"] = function(aura)
    aura.shouldConsolidate = 1
  end,
  [161780] = function(aura) -- Gaze of the Black Prince
    aura.shouldConsolidate = 1
  end,
}

-- TODO: Use spell IDs.
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
  local increasedStats = { -- TODO: spell IDs?
    ["Mark of the Wild"]                  = true,
    ["Legacy of the Emperor"]             = true,
    ["Blessing of Kings"]                 = true,
    ["Embrace of the Shale Spider"]       = true,
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
      if not inRange or inRange == 0 then return false end -- TODO: this is not the correct range and this isn't updated
                                                           -- when it should be.
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

-- These order functions receive two arguments and must return true if the first argument should come first in the
-- sorted array. Note that Lua's table.sort is not a stable sort.

comparators.longerFirst = function(aura1, aura2)
  if aura1.expires == 0 and aura2.expires == 0 then -- Neither aura expires.
    return aura1.index < aura2.index -- TODO: sort by name instead of index?
  elseif aura1.expires == 0 then -- Only aura1 is permanent.
    return true
  elseif aura2.expires == 0 then -- Only aura2 is permanent.
    return false
  end
  return aura1.expires > aura2.expires -- Both auras expire.
end

-- Auras applied by the player first.
comparators.defaultCompare = function(aura1, aura2)
  if aura1.caster and aura1.caster == "player" and not (aura2.caster and aura2.caster == "player") then
    return true
  elseif aura2.caster and aura2.caster == "player" and not (aura1.caster and aura1.caster == "player") then
    return false
  end
  return comparators.longerFirst(aura1, aura2) -- Both auras or neither are player-applied.
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
  unit = "player",
  filters = { "HELPFUL", "HARMFUL" },
  mutators = mutators.generalBuffMutators,
  fakeAuras = {
    statsMissing = fakeAuras.statsMissing,
  },
  -- TODO: allow black- and whitelists that apply to all displays in a group.
  compare = comparators.buffsFirst,
  displays = {
    {
      name = "NKAPlayerCC",
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
      whitelist = function(aura)
        return auras.fullCC[aura.spellID] or auras.disarms[aura.spellID] or aura.spellID == 122470 --[[Touch of Karma]] or
          auras.roots[aura.spellID] or auras.shortRoots[aura.spellID]
      end,
      borderColor = function(aura)
        if aura.filter == "HARMFUL" then
          return 192, 0, 0
        end
        return 0, 0, 0
      end,
    },
    { -- TODO: display some big defensives like Guardian Spirit and Pain Suppression here.
      name = "NKAPrimaryPlayerAuras",
      parent = "NKPlayerFrame",
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
      whitelist = function(aura) -- TODO.
        return aura.name == "Guardian Spirit"
      end,
      borderColor = function(aura)
        if aura.filter == "HARMFUL" then
          return 192, 0, 0
        end
        return 0, 0, 0
      end,
    },
    { -- TODO: filter auras that are also returned for the vehicle unit?
      name = "NKASecondaryPlayerAuras",
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
      blacklist = function(aura)
        return aura.filter == "HELPFUL" and (auras.irrelevantAuras[aura.spellID] or
          auras.playerBuffBlacklist[aura.name] or aura.duration >= 300 or aura.shouldConsolidate
          or blacklistByTooltip("player", aura.index, "HELPFUL", auras.playerBuffTooltipBlacklist))
      end,
      borderColor = function(aura)
        if aura.filter == "HARMFUL" then
          return 192, 0, 0
        end
        return 0, 0, 0
      end,
    },
    {
      name = "NKALongPlayerBuffs",
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
      blacklist = function(aura)
        return auras.irrelevantAuras[aura.spellID] or auras.playerBuffBlacklist[aura.name] or
          auras.longPlayerBuffBlacklist[aura.name]
      end,
    }
  },
})

_G.table.insert(groups, {
  unit = "vehicle",
  filters = { "HELPFUL", "HARMFUL" },
  compare = comparators.buffsFirst,
  displays = {
    {
      name = "NKAVehicleAuras",
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
      borderColor = function(aura)
        if aura.filter == "HARMFUL" then
          return 192, 0, 0
        end
        return 0, 0, 0
      end,
    },
  },
})

_G.table.insert(groups, {
  unit = "target",
  filters = { "HELPFUL", "HARMFUL" },
  mutators = mutators.generalBuffMutators,
  compare = comparators.buffsFirst,
  displays = {
    {
      name = "NKATargetAuras",
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
      whitelist = function(aura)
        return auras.immunities[aura.spellID] or auras.fullCC[aura.spellID] or auras.disarms[aura.spellID] or
          auras.defensives[aura.spellID] or auras.roots[aura.spellID] or auras.shortRoots[aura.spellID]
      end,
      borderColor = function(aura)
        if aura.filter == "HARMFUL" then
          return 192, 0, 0
        end
        return 0, 0, 0
      end,
    },
    {
      name = "NKAOtherTargetAuras",
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
      blacklist = function(aura)
        return auras.immunities[aura.spellID] or auras.fullCC[aura.spellID] or auras.disarms[aura.spellID] or
          auras.defensives[aura.spellID] or auras.irrelevantAuras[aura.spellID] or
          (aura.filter == "HELPFUL" and aura.duration >= 300) or aura.shouldConsolidate or
          (auras.targetDebuffBlacklist[aura.spellID] and aura.caster == "player")
      end,
      borderColor = function(aura)
        if aura.filter == "HARMFUL" then
          return 192, 0, 0
        end
        return 0, 0, 0
      end,
    },
    {
      name = "NKALongTargetBuffs",
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
      blacklist = function(aura)
        return auras.irrelevantAuras[aura.spellID] or (aura.duration < 300 and not aura.shouldConsolidate)
      end,
    },
  },
})

_G.table.insert(groups, {
  unit = "focus",
  filters = { "HELPFUL", "HARMFUL" },
  mutators = mutators.debuffMutators,
  compare = comparators.buffsFirst,
  displays = {
    {
      name = "NKAFocusAuras",
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
      whitelist = function(aura)
        return aura.filter == "HELPFUL" and auras.immunities[aura.spellID] or
          aura.filter == "HARMFUL" and (auras.fullCC[aura.spellID] or auras.disarms[aura.spellID])
      end,
      borderColor = function(aura)
        if aura.filter == "HARMFUL" then
          return 192, 0, 0
        end
        return 0, 0, 0
      end,
    },
    {
      name = "NKAOtherFocusAuras",
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
      whitelist = function(aura)
        return aura.filter == "HARMFUL" and auras.importantOwnDebuffs[aura.spellID] and aura.caster == "player"
      end,
      borderColor = function(aura)
        if aura.filter == "HARMFUL" then
          return 192, 0, 0
        end
        return 0, 0, 0
      end,
    },
  },
})

for i = 1, 4 do
  _G.table.insert(groups, {
    unit = "party" .. i,
    filters = { "HELPFUL", "HARMFUL" },
    fakeAuras = {
      statsMissing = fakeAuras.statsMissing,
    },
    compare = comparators.buffsFirst,
    displays = {
      {
        name = "NKAParty" .. i .. "Auras",
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
        whitelist = function(aura)
          return aura.filter == "HARMFUL" and (auras.fullCC[aura.spellID] or auras.disarms[aura.spellID])
        end,
        borderColor = function(aura)
          if aura.filter == "HARMFUL" then
            return 192, 0, 0
          end
          return 0, 0, 0
        end,
      },
      {
        name = "NKAOtherParty" .. i .. "Auras",
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
      },
    },
  })
end

-- Define groups for arena opponents.
for i = 1, 3 do
  _G.table.insert(groups, {
    unit = "arena" .. i,
    filters = { "HELPFUL", "HARMFUL" },
    compare = comparators.buffsFirst,
    displays = {
      {
        name = "NKArena" .. i .. "Auras",
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
      },
    },
  })
end

-- vim: tw=120 sw=2 et
