-- TODO: Add these auras: Orb of Power (?), 118358 (Drink).  Only show Smoke Bomb if it's casted by a hostile Rogue?
-- Show Faerie Fire and Faerie Swarm as CC?

local addonName, addon = ...
setfenv(1, addon)

trackedDrCats = {
  root         = true,
  stun         = true,
  disorient    = true,
  knockback    = true,
}

auras, groups, comparators, mutators, fakeAuras = {}, {}, {}, {}, {}

-- Dispel types.
local ENRAGE  = ""
local CURSE   = "Curse"
local DISEASE = "Disease"
local MAGIC   = "Magic"
local POISON  = "Poison"

-- Use this one for all buff groups.  We never care about these auras.
auras.irrelevantAuras = {
  [142247] = true, -- Brawling Champion
  [2479]   = true, -- Honorless Target
  [46705]  = true, -- Honorless Target; TODO: are both of these used?
  [72968]  = true, -- Precious's Ribbon
  [70404]  = true, -- Precious's Ribbon; TODO: are both of these used?
  [145389] = true, -- Temporal Anomaly
  [186404] = true, -- Sign of the Emissary
  [186401] = true, -- Sign of the Skirmisher
  [186406] = true, -- Sign of the Critter
}

-- These auras are already shown by other addons (for the player).  TODO: Leader of the Pack?
auras.coveredPlayerAuras = {
  [1066]   = true, -- Aquatic Form
  [22812]  = true, -- Barkskin
  [5487]   = true, -- Bear Form
  [50334]  = true, -- Berserk (Bear Form)
  [106951] = true, -- Berserk (Cat Form)
  [26297]  = true, -- Berserking (Troll Racial)
  [126690] = true, -- Call of Conquest
  [768]    = true, -- Cat Form
  [171745] = true, -- Claws of Shirvallah
  [135700] = true, -- Clearcasting
  [1850]   = true, -- Dash
  [108292] = true, -- Heart of the Wild (Feral)
  [102543] = true, -- Incarnation: King of the Jungle
  [124974] = true, -- Nature's Vigil
  [69369]  = true, -- Predatory Swiftness
--[5215]   = true, -- Prowl
--[102547] = true, -- Prowl (while "Incarnation: King of the Jungle" is active)
  [52610]  = true, -- Savage Roar
  [174544] = true, -- Savage Roar (from Glyph of Savage Roar)
  [58984]  = true, -- Shadowmeld
  [81022]  = true, -- Stampede
  [131538] = true, -- Stampede
  [77761]  = true, -- Stampeding Roar (when used in bear form)
  [77764]  = true, -- Stampeding Roar (when used in cat form)
  [106898] = true, -- Stampeding Roar (when used in caster form)
  [182068] = true, -- Surge of Conquest (Primal Gladiator's Insignia of Conquest)
  [182059] = true, -- Surge of Conquest (Wild Combatant's Insignia of Conquest)
  [190026] = true, -- Surge of Conquest (Wild Gladiator's Insignia of Conquest)
  [61336]  = true, -- Survival Instincts
  [40120]  = true, -- Swift Flight Form
  [5217]   = true, -- Tiger's Fury
  [783]    = true, -- Travel Form
}

auras.importantOwnDebuffs = {
  [155722] = true, -- Rake
  [1079]   = true, -- Rip
}

auras.roots = {
  [96294]  = true, -- Chains of Ice
  [339]    = true, -- Entangling Roots
  [170855] = true, -- Entangling Roots (Nature's Grasp).  Nature's Grasp is 170856.
  [113770] = true, -- Entangling Roots (Force of Nature).  This spell ID is correct for Feral; TODO: also for Balance?
  [102359] = true, -- Mass Entanglement
  [136634] = true, -- Narrow Escape.  TODO: confirm spell ID.
  [33395]  = true, -- Freeze (Water Elemental).  TODO: confirm spell ID.
  [102051] = true, -- Frostjaw (Silence and Root).  TODO: confirm spell ID.
  [122]    = true, -- Frost Nova.  TODO: confirm spell ID.
  [116706] = true, -- Disable.  TODO: confirm spell ID.
  [87194]  = true, -- Glyph of Mind Blast.  TODO: confirm spell ID.
  [114404] = true, -- Void Tendril's Grasp.  TODO: confirm spell ID.
  [115197] = true, -- Partial Paralysis.  TODO: confirm spell ID.
  [63685]  = true, -- Freeze (Frost Shock with Frozen Power talent).  TODO: confirm spell ID.
  [107566] = true, -- Staggering Shout.  TODO: confirm spell ID.
  [105771] = true, -- Warbringer (Charge).  TODO: confirm spell ID.
  [91807]  = true, -- Shambling Rush (Ghoul with Dark Transformation; Unholy Death Knight).  Spell ID confirmed.
  [45334]  = true, -- Immobilized (Bear Form Wild Charge)
  [64803]  = true, -- Entrapment.  TODO: confirm spell ID.  I think this isn't the correct ID.
  [135373] = true, -- Entrapment.  TODO: confirm spell ID.  I think this is the correct ID.
  [111340] = true, -- Ice Ward.  TODO: confirm spell ID.
  [123407] = true, -- Spinning Fire Blossom.  TODO: confirm spell ID.
  [64695]  = true, -- Earthgrab.  TODO: confirm spell ID.
  -- TODO: Are the following pet skills still in the game?
  [53148]  = true, -- Charge (Tenacity pet).  TODO: confirm spell ID.
  [50245]  = true, -- Pin (Crab pet).  TODO: confirm spell ID.
  [90327]  = true, -- Lock Jaw (Dog pet).  TODO: confirm spell ID.
  [4167]   = true, -- Web (Spider pet).  TODO: confirm spell ID.
  [54706]  = true, -- Venom Web Spray (Silithid pet).  TODO: confirm spell ID.
}

-- Full Crowd Control and Silences.  Based on http://us.battle.net/wow/en/forum/topic/10195910192,
-- http://www.arenajunkies.com/topic/227748-mop-diminishing-returns-updating-the-list and Gladius.  TODO: sort these
-- into the actual remaining categories.
auras.fullCc = {
  -- *Stuns* --
  [108194] = true, -- Asphyxiate
  [91800]  = true, -- Gnaw (Ghoul)
  [91797]  = true, -- Monstrous Blow (Ghoul with Dark Transformation)
  [115001] = true, -- Remorseless Winter
  [102795] = true, -- Bear Hug
  [22570]  = true, -- Maim
  [5211]   = true, -- Mighty Bash
  [163505] = true, -- Rake
  [117526] = true, -- Binding Shot
  [24394]  = true, -- Intimidation
  [157997] = true, -- Ice Nova
  --[118271] = true, -- Combustion Impact
  [44572]  = true, -- Deep Freeze
  [123687] = true, -- Charging Ox Wave.  Confirmed ID.
  [122242] = true, -- Clash
  [120086] = true, -- Fists of Fury
  [119381] = true, -- Leg Sweep
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
  -- *Stuns (off DR?)* --
  --[113953] = true, -- Paralysis (Paralytic Poison stun)
  [7922]   = true, -- Charge Stun -- This spell ID appears to be correct (96273 isn't).
  [77505]  = true, -- Earthquake -- TODO: is this the correct ID?
  [118895] = true, -- Dragon Roar -- TODO: is this the correct ID?
  ---------------------
  -- *Incapacitates* --
  [55041]  = true, -- Freezing Trap Effect -- TODO: Which one do we need?
  [1499]   = true, -- Freezing Trap Effect
  [3355]   = true, -- Freezing Trap (Trap Launcher)
  [60192]  = true, -- Freezing Trap (Trap Launcher)
  [19386]  = true, -- Wyvern Sting
  [118]    = true, -- Polymorph
  [28271]  = true, -- Polymorph (Turtle)
  [28272]  = true, -- Polymorph (Pig)
  [61305]  = true, -- Polymorph (Black Cat)
  [61721]  = true, -- Polymorph (Rabbit)
  [61780]  = true, -- Polymorph (Turkey)
  [126819] = true, -- Polymorph (Porcupine)
  [161353] = true, -- Polymorph (Polar Bear Cub)
  [161354] = true, -- Polymorph (Monkey)
  [161355] = true, -- Polymorph (Penguin)
  [161372] = true, -- Polymorph (Peacock)
  [61025]  = true, -- Polymorph (Serpent)
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
  [99]     = true, -- Incapacitating Roar
  [123393] = true, -- Breath of Fire (Glyphed)
  [88625]  = true, -- Holy Word: Chastise
  [137143] = true, -- Blood Horror, 111397 is the ID of the spell and the buff the warlock gains.
  [64044]  = true, -- Psychic Horror
  [6789]   = true, -- Mortal Coil
  [605]    = true, -- Dominate Mind
  [137460] = true, -- Incapacitated (Ring of Peace)
  ------------------
  -- *Disorients* --
  [31661]  = true, -- Dragon's Breath
  [105421] = true, -- Blinding Light; TODO: confirm spell ID.
  [33786]  = true, -- Cyclone
  [10326]  = true, -- Turn Evil
  [145067] = true, -- Turn Evil (glyphed?); TODO; removed?
  [8122]   = true, -- Psychic Scream
  [2094]   = true, -- Blind
  [5782]   = true, -- Fear; TODO: unused?
  [118699] = true, -- Fear
  [130616] = true, -- Fear (glyphed?)
  [5484]   = true, -- Howl of Terror
  [115268] = true, -- Mesmerize (Shivarra)
  [6358]   = true, -- Seduction (Succubus)
  [5246]   = true, -- Intimidating Shout
  ----------------
  -- *Silences* -- -- TODO: is there a silcence separate from the stun for Asphyxiate?
  [47476]   = true, -- Strangulate
  [114237]  = true, -- Glyph of Fae Silence
  [78675]   = true, -- Solar Beam
  [102051]  = true, -- Frostjaw (Silence and Root)
  [31935]   = true, -- Avenger's Shield
  [15487]   = true, -- Silence (Priest)
  [1330]    = true, -- Garrote - Silence
  [31117]   = true, -- Unstable Affliction; TODO: confirm spell ID
  [65813]   = true, -- Unstable Affliction; TODO: probably wrong spell ID
  [43523]   = true, -- Unstable Affliction; TODO: probably wrong spell ID
  [28730]   = true, -- Arcane Torrent (Blood Elf Racial, classes with mana?)
  [25046]   = true, -- Arcane Torrent (Blood Elf Racial, Rogue)
  [69179]   = true, -- Arcane Torrent (Blood Elf Racial, Warrior)
  [50613]   = true, -- Arcane Torrent (Blood Elf Racial, Death Knight)
  [80483]   = true, -- Arcane Torrent (Blood Elf Racial, Hunter)
  [129597]  = true, -- Arcane Torrent (Blood Elf Racial, Monk)
  [155145]  = true, -- Arcane Torrent (Blood Elf Racial, Paladin)
  ------------
  -- *TODO* --
  [87204]  = true, -- Sin and Punishment; TODO: still exists?
}

auras.otherDebuffs = {
  [79140] = true, -- Vendetta; TODO: confirm spell ID
--[79140] = true, -- A Murder of Crows; TODO
--[79140] = true, -- Devouring Plague; TODO
}

auras.immunities = {
  [110909] = true, -- Alter Time
  [48707]  = true, -- Anti-Magic Shell
  [46924]  = true, -- Bladestorm
  [170847] = true, -- Celestial Protection; Druid WoD PvP Balance 4P Bonus (aura mastery); TODO: cofirm spell ID
  [31224]  = true, -- Cloak of Shadows
  [110913] = true, -- Dark Bargain
  [122465] = true, -- Dematerialize
  [19263]  = true, -- Deterrence
  [67801]  = true, -- Deterrence (?)
  [110617] = true, -- Deterrence (?)
  [110618] = true, -- Deterrence (?)
  [114406] = true, -- Deterrence (?)
  [148467] = true, -- Deterrence (?)
  [115018] = true, -- Desecrated Ground
  [152150] = true, -- Death from Above
  [47585]  = true, -- Dispersion
  [642]    = true, -- Divine Shield
  [31821]  = true, -- Devotion Aura.  TODO: confirm spell ID.
  [6346]   = true, -- Fear Ward
  [159438] = true, -- Glyph of Enchanted Bark
  [115760] = true, -- Glyph of Ice Block
                   -- Greater Invisibility: TODO.
  [8178]   = true, -- Grounding Totem Effect
  [89523]  = true, -- Grounding Totem (with reflect glyph); TODO: confirm spell ID
  [1044]   = true, -- Hand of Freedom; TODO: confirm spell ID
  [1022]   = true, -- Hand of Protection
  [152175] = true, -- Hurricane Strike
  [45438]  = true, -- Ice Block
  [48792]  = true, -- Icebound Fortitude
  [3411]   = true, -- Intervene
  [147833] = true, -- Intervene; TODO: remove incorrect spell ID, confirm spell ID.
  [32612]  = true, -- Invisibility; Seems to be correct spell ID.  66 is the ID of the spell.
  [51690]  = true, -- Killing Spree
  [114028] = true, -- Mass Spell Reflection
  [54216]  = true, -- Master's Call; TODO: remove one of these?
  [62305]  = true, -- Master's Call; TODO: remove one of these?
  [137562] = true, -- Nimble Brew
  [159630] = true, -- Shadow Magic.
                   -- Shroud of Concealment: TODO?
  [114029] = true, -- Safeguard
  [112833] = true, -- Spectral Guise
  [23920]  = true, -- Spell Reflection
  [131558] = true, -- Spiritwalker's Aegis; TODO: confirm spell ID
  [79206]  = true, -- Spiritwalker's Grace; TODO: confirm spell ID
                   -- TODO: Tremor Totem; does this even apply an aura?
  [114896] = true, -- Windwalk Totem
  [124488] = true, -- Zen Focus; FIXME: this is probably the wrong spell ID
  [159546] = true, -- Glyph of Zen Focus; TODO: confirm spell ID
  [115176] = true, -- Zen Meditation
}

auras.defensive = {
  [108271] = true, -- Astral Shift
  [22812]  = true, -- Barkskin
  [74002]  = true, -- Combat Insight
  [118038] = true, -- Die by the Sword
  [5277]   = true, -- Evasion
  [1966]   = true, -- Feint
  [47788]  = true, -- Guardian Spirit
  [6940]   = true, -- Hand of Sacrifice; TODO: confirm spell ID
  [102342] = true, -- Ironbark
  [12975]  = true, -- Last Stand
  [116849] = true, -- Life Cocoon
  [33206]  = true, -- Pain Suppression
  [97463]  = true, -- Rallying Cry
  [53480]  = true, -- Roar of Sacrifice
  [46947]  = true, -- Safeguard (damage reduction); TODO: confirm spell ID
  [30823]  = true, -- Shamanistic Rage
  [61336]  = true, -- Survival Instincts
  [871]    = true, -- Shield Wall
  [125174] = true, -- Touch of Karma (Buff)
  [114030] = true, -- Vigilance; TODO: confirm spell ID
}

auras.offensive = {
  [13750]  = true, -- Adrenaline Rush; TODO: confirm spell ID
  [106951] = true, -- Berserk (Cat Form)
  [112071] = true, -- Celestial Alignment
  [113860] = true, -- Dark Soul: Misery; Affliction; TODO: confirm spell ID
  [113858] = true, -- Dark Soul: Instability; Destruction; TODO: confirm spell ID
  [113861] = true, -- Dark Soul: Knowledge; Demonology; TODO: confirm spell ID
  [84747]  = true, -- Deep Insight
  [82692]  = true, -- Focus Fire; TODO: confirm spell ID
  [102543] = true, -- Incarnation: King of the Jungle
  [84746]  = true, -- Moderate Insight
  [51713]  = true, -- Shadow Dance; TODO: confirm spell ID
  [84745]  = true, -- Shallow Insight
}

auras.utility = {
  -- ...
}

auras.other = {
  [31842]  = true, -- Avenging Wrath
  [111397] = true, -- Blood Horror, TODO: confirm spell ID
  [74001]  = true, -- Combat Readiness
  [770]    = true, -- Faerie Fire; should this be classified as CC?
  [102355] = true, -- Faerie Swarm; should this be classified as CC?
  [25771]  = true, -- Forbearance, TODO: confirm spell ID
  [41425]  = true, -- Hypothermia, TODO: confirm spell ID
  [54149]  = true, -- Infusion of Light, TODO: confirm spell ID
  [132158] = true, -- Nature's Swiftness
  [115000] = true, -- Remorseless Winter
  [155274] = true, -- Saving Grace
  [114108] = true, -- Soul of the Forest (Restoration Druid Buff)
  [73685]  = true, -- Unleash Life
  [23335]  = true, -- Alliance Flag
  [140876] = true, -- Alliance Mine Cart
  [23333]  = true, -- Horde Flag
  [141210] = true, -- Horde Mine Cart
  [34976]  = true, -- Netherstorm Flag
}

auras.playerBuffTooltipBlacklist = {
  "Increases ground speed by %d%d%d?%%",
}

local function shouldConsolidate(aura)
  aura.shouldConsolidate = 1
end

mutators.generalBuffMutators = {
  [110310] = shouldConsolidate, -- Dampening; doesn't work because it's a debuff: TODO
  [128943] = shouldConsolidate, -- Cyclonic Inspiration (Shrine of Seven Stars)
  [131526] = shouldConsolidate, -- Cyclonic Inspiration (Shrine of Two Moons)
  [181201] = shouldConsolidate, -- Gladiator's Distinction
  [81744]  = shouldConsolidate, -- Horde; applied when playing an RBG on Horde side as Alliance
  [77769]  = shouldConsolidate, -- Trap Launcher; TODO: confirm ID
  [118694] = shouldConsolidate, -- Spirit Bond; TODO: confirm ID
  [189325] = shouldConsolidate, -- King of the Jungle
  [190632] = shouldConsolidate, -- Trailblazer
}

-- TODO: Use spell IDs.
mutators.debuffMutators = {
  ["Faerie Fire"] = function(aura)
    aura.caster = "player"
  end,
  ["Faerie Swarm"] = function(aura)
    aura.caster = "player"
  end,
}

auras.targetDebuffBlacklist = {
  [155722] = true, -- Rake
  [1079]   = true, -- Rip
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
    duration = 0,
    expires = 0,
    spellId = 1126,
    value2 = 5,
    present = function(unit)
      if not _G.UnitIsConnected(unit) or _G.UnitIsDeadOrGhost(unit) or not _G.UnitInPhase(unit) then
        return false
      end
      -- TODO: this is not the correct range and this isn't updated when it should be.
      --[[
      local inRange = _G.IsSpellInRange("Mark of the Wild", unit)
      if not inRange or inRange == 0 then return false end
      ]]
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
-- sorted array.  Note that Lua's table.sort is not a stable sort.  TODO: should these be specified for each display
-- instead of group?
------------------------------------------------------------------------------------------------------------------------
comparators.longerFirst = function(aura1, aura2)
  if (aura1.expires == 0 and aura2.expires == 0) or aura1.expires == aura2.expires then -- Neither aura expires.
    --[[
    if aura1.isExtraStack and not aura2.isExtraStack then
      return false
    elseif not aura1.isExtraStack and aura2.isExtraStack then
      return true
    end
    --]]
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

comparators.drFirst = function(aura1, aura2)
  if aura1.filter == "DR" and aura2.filter ~= "DR" then
    return true
  elseif aura1.filter ~= "DR" and aura2.filter == "DR" then
    return false
  end
  return comparators.buffsFirst(aura1, aura2)
end

-- TODO: should border colors be global instead of being specified uniquely for each display?
local function borderColor(aura)
  if aura.dispelType then
    if aura.dispelType == CURSE then
      return .75, .25, 1
    elseif aura.dispelType == POISON then
      return .1, 1, .15
    end
  end
  if aura.filter == "HARMFUL" then
    return 1, 0, 0
  elseif aura.filter == "DR" then
    return 0.75, 0.75, 0.75
  end
  return 0, 0, 0
end
------------------------------------------------------------------------------------------------------------------------

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
      numRows = 1,
      numCols = 4,
      orientation = "HORIZONTAL",
      showCooldownSweep = true,
      whitelist = function(aura)
        return auras.fullCc[aura.spellId] or auras.roots[aura.spellId] or aura.spellId == 122470 --[[Touch of Karma]] or
          aura.spellId == 1022 --[[Hand of Protection]] or aura.spellId == 88611 --[[Smoke Bomb]] or
          aura.spellId == 117405 --[[Binding Shot]]
      end,
      borderColor = borderColor,
    },
    {
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
      showCooldownSweep = true,
      whitelist = function(aura)
        return auras.immunities[aura.spellId] or auras.defensive[aura.spellId] or aura.name == "Soul Reaper"
          or aura.name == "Dark Simulacrum" or aura.name == "Devouring Plague" or aura.spellId == 6346 --[[Fear Ward]]
          or aura.spellId == 115000 --[[Remorseless Winter (shift at 4 stacks)]] or aura.spellId == 770
          or aura.spellId == 102355 --[[Faerie Fire and Faerie Swarm]]
      end,
      borderColor = borderColor,
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
        return aura.filter == "HELPFUL" and (auras.irrelevantAuras[aura.spellId] or
          auras.coveredPlayerAuras[aura.spellId] or aura.duration >= 300 or aura.shouldConsolidate
          or blacklistByTooltip("player", aura.index, "HELPFUL", auras.playerBuffTooltipBlacklist))
      end,
      borderColor = borderColor,
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
        return auras.irrelevantAuras[aura.spellId] or auras.coveredPlayerAuras[aura.spellId]
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
      borderColor = borderColor,
    },
  },
})

_G.table.insert(groups, {
  unit = "target",
  filters = { "HELPFUL", "HARMFUL" },
  includeDr = true,
  mutators = mutators.generalBuffMutators,
  compare = comparators.drFirst,
  displays = {
    {
      name = "NKATargetDr",
      parent = "NKTargetFrame",
      anchorPoint = "TOPLEFT",
      relativePoint = "BOTTOMLEFT",
      xOffset = 0,
      yOffset = -2,
      size = 28,
      xGap = (28 + 2),
      yGap = -(28 + 2),
      numRows = 1,
      numCols = 7,
      orientation = "HORIZONTAL",
      whitelist = function(aura)
        return aura.filter == "DR" or auras.offensive[aura.spellId] or auras.other[aura.spellId] or
          aura.dispelType == ENRAGE
      end,
      borderColor = borderColor,
    },
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
      showCooldownSweep = true,
      whitelist = function(aura)
        return auras.immunities[aura.spellId] or auras.fullCc[aura.spellId] or auras.defensive[aura.spellId] or
          auras.roots[aura.spellId]
      end,
      borderColor = borderColor,
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
        return auras.immunities[aura.spellId] or auras.fullCc[aura.spellId] or auras.defensive[aura.spellId] or
          auras.irrelevantAuras[aura.spellId] or (aura.filter == "HELPFUL" and aura.duration >= 300) or
          aura.shouldConsolidate or (auras.targetDebuffBlacklist[aura.spellId] and aura.caster == "player")
      end,
      borderColor = borderColor,
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
        return auras.irrelevantAuras[aura.spellId] or (aura.duration < 300 and not aura.shouldConsolidate)
      end,
    },
  },
})

_G.table.insert(groups, {
  unit = "focus",
  filters = { "HELPFUL", "HARMFUL" },
  includeDr = true,
  mutators = mutators.debuffMutators,
  compare = comparators.drFirst,
  displays = {
    {
      name = "NKAFocusDr",
      parent = "NKFocusFrame",
      anchorPoint = "TOPLEFT",
      relativePoint = "BOTTOMLEFT",
      xOffset = 0,
      yOffset = -2,
      size = 28,
      xGap = (28 + 2),
      yGap = -(28 + 2),
      numRows = 1,
      numCols = 7,
      orientation = "HORIZONTAL",
      whitelist = function(aura)
        return aura.filter == "DR" or auras.offensive[aura.spellId] or auras.other[aura.spellId] or
          aura.dispelType == ENRAGE
      end,
      borderColor = borderColor,
    },
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
      showCooldownSweep = true,
      --[[
      whitelist = function(aura)
        return auras.immunities[aura.spellId] or auras.fullCc[aura.spellId]
      end,
      ]]
      whitelist = function(aura)
        return auras.immunities[aura.spellId] or auras.fullCc[aura.spellId] or auras.defensive[aura.spellId] or
          auras.roots[aura.spellId]
      end,
      borderColor = borderColor,
    },
    --[[
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
        return aura.filter == "HARMFUL" and auras.importantOwnDebuffs[aura.spellId] and aura.caster == "player"
      end,
      borderColor = borderColor,
    },
    ]]
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
        showCooldownSweep = true,
        whitelist = function(aura)
          return auras.immunities[aura.spellId] or auras.fullCc[aura.spellId] or auras.defensive[aura.spellId] or
            auras.roots[aura.spellId]
        end,
        borderColor = borderColor,
      },
      {
        name = "NKAOtherParty" .. i .. "Auras",
        parent = "NKParty" .. i .. "Frame",
        ----[[
        anchorPoint = "BOTTOMRIGHT",
        relativePoint = "TOPRIGHT",
        xOffset = 0,
        yOffset = 2,
        --]]
        --[[
        anchorPoint = "TOPRIGHT",
        relativePoint = "BOTTOMRIGHT",
        xOffset = 0,
        yOffset = -2,
        --]]
        size = 28,
        xGap = -(28 + 2),
        yGap = -(28 + 2),
        numRows = 1,
        numCols = 7,
        orientation = "HORIZONTAL",
        blacklist = function(aura)
          return not auras.otherDebuffs[aura.spellId] and ((aura.filter == "HELPFUL" and (aura.duration >= 300 or
            aura.shouldConsolidate or aura.caster ~= "player")) or (aura.filter == "HARMFUL" and
            aura.dispelType ~= CURSE and aura.dispelType ~= POISON and aura.name ~= "Stats missing"))
        end,
        borderColor = borderColor,
      },
    },
  })
end

for i = 1, 3 do -- Define groups for arena opponents.
  _G.table.insert(groups, {
    unit = "arena" .. i,
    filters = { "HELPFUL", "HARMFUL" },
    includeDr = true,
    compare = comparators.drFirst,
    displays = {
      {
        name = "NKArena" .. i .. "Dr",
        parent = "NKArena" .. i .. "Frame",
        anchorPoint = "TOPLEFT",
        relativePoint = "BOTTOMLEFT",
        xOffset = 0,
        yOffset = -2,
        size = 28,
        xGap = (28 + 2),
        yGap = -(28 + 2),
        numRows = 1,
        numCols = 7,
        orientation = "HORIZONTAL",
        whitelist = function(aura)
          return aura.filter == "DR" or auras.offensive[aura.spellId] or auras.other[aura.spellId] or
            aura.dispelType == ENRAGE
        end,
        borderColor = borderColor,
      },
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
        showCooldownSweep = true,
        whitelist = function(aura)
          return auras.immunities[aura.spellId] or auras.fullCc[aura.spellId] or auras.defensive[aura.spellId] or
            auras.roots[aura.spellId]
        end,
        borderColor = borderColor,
      },
    },
  })
end

-- vim: tw=120 sts=2 sw=2 et
