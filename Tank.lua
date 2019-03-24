function Tank_Configuration_Init()
    TANK_VERSION = "1.0.0"
    if not Fury_Configuration then
        TANK_Configuration = {}
    end
end

local function ActiveStance()
    --Detect the active stance
    for i = 1, 3 do
        local _, _, active = GetShapeshiftFormInfo(i)
        if active then
            return i
        end
    end
    return nil
end

local function SpellId(spellname)
    local id = 1
    for i = 1, GetNumSpellTabs() do
        local _, _, _, numSpells = GetSpellTabInfo(i)
        for j = 1, numSpells do
            local spellName = GetSpellName(id, BOOKTYPE_SPELL)
            if spellName == spellname then
                return id
            end
            id = id + 1
        end
    end
    return nil
end

local function SpellReadyIn(spellname)
    local id = SpellId(spellname)
    if id then
        local start, duration = GetSpellCooldown(id, 0)
        if start == 0 and duration == 0 and FuryLastSpellCast + 1 <= GetTime() then
            return 0
        end
        local remaining = duration - (GetTime() - start)
        if remaining >= 0 then
            return remaining
        end
    end
    return 86400
end

local function Tank_Configuration_Default()
    TANK_Configuration["Enabled"] = true
    if TANK_Configuration[SKILL_FUCHOU] == nil then
        TANK_Configuration[SKILL_FUCHOU] = true
    end
end

function tank()
    if TANK_Configuration["Enabled"] then
        if Fury_Configuration[ABILITY_REVENGE_FURY]
                and FuryCombat
                and UnitMana("player") >= 5
                and FuryRevengeReadyUntil > GetTime()
                and SpellReadyIn(ABILITY_REVENGE_FURY) == 0 then
            Debug("29. Revenge")
            CastSpellByName(ABILITY_REVENGE_FURY)
        end
    end
end


function Tank_OnLoad(event)
    if event == "VARIABLES_LOADED" then
        --Check for settings
        Tank_Configuration_Init()
    end
    SlashCmdList["TANK"] = Tank_SlashCommand
    SLASH_TANK1 = "/tank"
end


