-- This addon that tracks ability cooldowns and effects on inactive battle pets.
-- It is a remake of Derangement\’s Pet Battle Cooldowns


--- **** TODO:
--- try lockdowns
--- cooldown shadow on inactive pets when active pet ability locked?

BPCC = BPCC or {abilityFrames={}, auraFrames={}}

--[[
    **************************************************
    * SECTION: functions
    **************************************************
--]]


--- *** Locate Pet ***

---Function that returns owner and pet indexes for selected ability icons frame
---@param parentFrame table|Frame
---@return integer team
---@return number petIndex
function BPCC.locatePet(parentFrame)
    local parent = parentFrame

    local team = 0
    local petIndex = 0

    if parent.active == true then
        team = 2
        petIndex = C_PetBattles.GetActivePet(2)
    else
        if parent.team == "PLAYER_TEAM" then
            team = 1
        elseif parent.team == "ENEMY_TEAM" then
            team = 2
        end

        local activePetIndex = C_PetBattles.GetActivePet(team)
        local indexes = {1, 2, 3}
        for j = #indexes, 1, -1 do
            if indexes[j] == activePetIndex then
                table.remove(indexes, j)
            end
        end

        table.unpack = table.unpack or unpack

        if parent.slot == 1 then
            petIndex = math.min(table.unpack(indexes))
        elseif parent.slot == 2 then
            petIndex = math.max(table.unpack(indexes))
        end
    end

    return team, petIndex
end


--- *** Update All Icons ***


function BPCC.updateAllIcons()

    for _, abilityFrame in pairs(BPCC.abilityFrames) do
        if not abilityFrame:IsShown() then
            abilityFrame:Show()
        end
    end

    for _, auraFrame in pairs(BPCC.auraFrames) do
        if not auraFrame:IsShown() then
            auraFrame:Show()
        end
    end

    BPCC.updateIcons(BPCC.abilityFrames.enemyActivePet)

    if C_PetBattles.GetNumPets(1) > 1 then
        BPCC.updateIcons(BPCC.abilityFrames.playerPet1)
    end
    if C_PetBattles.GetNumPets(1) > 2 then
        BPCC.updateIcons(BPCC.abilityFrames.playerPet2)
    end

    if C_PetBattles.GetNumPets(2) > 1 then
        BPCC.updateIcons(BPCC.abilityFrames.enemyPet1)
    end
    if C_PetBattles.GetNumPets(2) > 2 then
        BPCC.updateIcons(BPCC.abilityFrames.enemyPet2)
    end    
end



--[[ 
    **************************************************
    * SECTION: Ability Icons
    **************************************************
--]]


BPCC.abilityFrames.enemyActivePet = CreateFrame("Frame", "BPCC.abilityFrames.enemyActivePet", UIParent)
BPCC.abilityFrames.enemyActivePet.iconSize = 50
BPCC.abilityFrames.enemyActivePet:SetSize(3 * BPCC.abilityFrames.enemyActivePet.iconSize, BPCC.abilityFrames.enemyActivePet.iconSize)
BPCC.abilityFrames.enemyActivePet:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
BPCC.abilityFrames.enemyActivePet.team = "ENEMY_TEAM"
BPCC.abilityFrames.enemyActivePet.active = true
BPCC.abilityFrames.enemyActivePet:Hide()

BPCC.abilityFrames.playerPet1 = CreateFrame("Frame", "BPCC.abilityFrames.playerPet1", UIParent)
BPCC.abilityFrames.playerPet1.iconSize = 38
BPCC.abilityFrames.playerPet1:SetSize(3 * BPCC.abilityFrames.playerPet1.iconSize, BPCC.abilityFrames.playerPet1.iconSize)
BPCC.abilityFrames.playerPet1:SetPoint("CENTER", PetBattleFrame.Ally2, "CENTER", -90, 0)
BPCC.abilityFrames.playerPet1.team = "PLAYER_TEAM"
BPCC.abilityFrames.playerPet1.active = false
BPCC.abilityFrames.playerPet1.slot = 1
BPCC.abilityFrames.playerPet1:Hide()

BPCC.abilityFrames.playerPet2 = CreateFrame("Frame", "BPCC.abilityFrames.playerPet2", UIParent)
BPCC.abilityFrames.playerPet2.iconSize = 38
BPCC.abilityFrames.playerPet2:SetSize(3 * BPCC.abilityFrames.playerPet2.iconSize, BPCC.abilityFrames.playerPet2.iconSize)
BPCC.abilityFrames.playerPet2:SetPoint("CENTER", PetBattleFrame.Ally3, "CENTER", -90, 0)
BPCC.abilityFrames.playerPet2.team = "PLAYER_TEAM"
BPCC.abilityFrames.playerPet2.active = false
BPCC.abilityFrames.playerPet2.slot = 2
BPCC.abilityFrames.playerPet2:Hide()

BPCC.abilityFrames.enemyPet1 = CreateFrame("Frame", "BPCC.abilityFrames.enemyPet1", UIParent)
BPCC.abilityFrames.enemyPet1.iconSize = 38
BPCC.abilityFrames.enemyPet1:SetSize(3 * BPCC.abilityFrames.enemyPet1.iconSize, BPCC.abilityFrames.enemyPet1.iconSize)
BPCC.abilityFrames.enemyPet1:SetPoint("CENTER", PetBattleFrame.Enemy2, "CENTER", 90, 0)
BPCC.abilityFrames.enemyPet1.team = "ENEMY_TEAM"
BPCC.abilityFrames.enemyPet1.active = false
BPCC.abilityFrames.enemyPet1.slot = 1
BPCC.abilityFrames.enemyPet1:Hide()

BPCC.abilityFrames.enemyPet2 = CreateFrame("Frame", "BPCC.abilityFrames.enemyPet2", UIParent)
BPCC.abilityFrames.enemyPet2.iconSize = 38
BPCC.abilityFrames.enemyPet2:SetSize(3 * BPCC.abilityFrames.enemyPet2.iconSize, BPCC.abilityFrames.enemyPet2.iconSize)
BPCC.abilityFrames.enemyPet2:SetPoint("CENTER", PetBattleFrame.Enemy3, "CENTER", 90, 0)
BPCC.abilityFrames.enemyPet2.team = "ENEMY_TEAM"
BPCC.abilityFrames.enemyPet2.active = false
BPCC.abilityFrames.enemyPet2.slot = 2
BPCC.abilityFrames.enemyPet2:Hide()


C_Timer.After(0, function()
    for _, abilityFrame in pairs(BPCC.abilityFrames) do
        BPCC.createIcons(abilityFrame, abilityFrame.iconSize)

        if C_PetBattles.IsInBattle() then
            BPCC.updateAllIcons()
        end
    end
end)


--[[ 
    **************************************************
    * SECTION: Aura Icons
    **************************************************
--]]

local auraIconSize = 20

BPCC.auraFrames.playerPet1 = CreateFrame("Frame", "BPCC.auraFrames.playerPet1", UIParent)
BPCC.auraFrames.playerPet1.iconSize = auraIconSize
BPCC.auraFrames.playerPet1:SetSize(100, BPCC.auraFrames.playerPet1.iconSize)
BPCC.auraFrames.playerPet1:SetPoint("BOTTOMRIGHT", BPCC.abilityFrames.playerPet1, "BOTTOMLEFT", -5, 0)
BPCC.auraFrames.playerPet1.team = "PLAYER_TEAM"
BPCC.auraFrames.playerPet1.active = false
BPCC.auraFrames.playerPet1.slot = 1
BPCC.auraFrames.playerPet1:Hide()

BPCC.auraFrames.playerPet2 = CreateFrame("Frame", "BPCC.auraFrames.playerPet2", UIParent)
BPCC.auraFrames.playerPet2.iconSize = auraIconSize
BPCC.auraFrames.playerPet2:SetSize(100, BPCC.auraFrames.playerPet2.iconSize)
BPCC.auraFrames.playerPet2:SetPoint("BOTTOMRIGHT", BPCC.abilityFrames.playerPet2, "BOTTOMLEFT", -5, 0)
BPCC.auraFrames.playerPet2.team = "PLAYER_TEAM"
BPCC.auraFrames.playerPet2.active = false
BPCC.auraFrames.playerPet2.slot = 2
BPCC.auraFrames.playerPet2:Hide()

BPCC.auraFrames.enemyPet1 = CreateFrame("Frame", "BPCC.auraFrames.enemyPet1", UIParent)
BPCC.auraFrames.enemyPet1.iconSize = auraIconSize
BPCC.auraFrames.enemyPet1:SetSize(100, BPCC.auraFrames.enemyPet1.iconSize)
BPCC.auraFrames.enemyPet1:SetPoint("BOTTOMLEFT", BPCC.abilityFrames.EnemyPet1, "BOTTOMRIGHT", 5, 0)
BPCC.auraFrames.enemyPet1.team = "ENEMY_TEAM"
BPCC.auraFrames.enemyPet1.active = false
BPCC.auraFrames.enemyPet1.slot = 1
BPCC.auraFrames.enemyPet1:Hide()

BPCC.auraFrames.enemyPet2 = CreateFrame("Frame", "BPCC.auraFrames.enemyPet2", UIParent)
BPCC.auraFrames.enemyPet2.iconSize = auraIconSize
BPCC.auraFrames.enemyPet2:SetSize(100, BPCC.auraFrames.enemyPet2.iconSize)
BPCC.auraFrames.enemyPet2:SetPoint("BOTTOMLEFT", BPCC.abilityFrames.enemyPet2, "BOTTOMRIGHT", 5, 0)
BPCC.auraFrames.enemyPet2.team = "ENEMY_TEAM"
BPCC.auraFrames.enemyPet2.active = false
BPCC.auraFrames.enemyPet2.slot = 2
BPCC.auraFrames.enemyPet2:Hide()


C_Timer.After(0, function()
    BPCC.createAuraIcon(BPCC.auraFrames.playerPet1.auraIcon, "BPCC.auraFrames.playerPet1.auraIcon", BPCC.auraFrames.playerPet1, auraIconSize)
    BPCC.createAuraIcon(BPCC.auraFrames.enemyPet2.auraIcon, "BPCC.auraFrames.enemyPet2.auraIcon", BPCC.auraFrames.enemyPet2, auraIconSize)
end)

--[[ 
    **************************************************
    * SECTION: Events
    **************************************************
--]]

-- Create event listner frame
local eventListenerFrame = CreateFrame("Frame", "BPCCEventListenerFrame", UIParent)

local function eventHandler(self, event, ...)

    -- *** On addon load ***

    if event == "ADDON_LOADED" and ... == "BattlePetCooldownCompanion" then
        --Greetings message
        print("|cFF00FF00[BattlePetCooldownCompanion]|r:  BattlePetCooldownCompanion is successfully loaded.")
    end

    if event == "PET_BATTLE_OPENING_START" or "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE" or "PET_BATTLE_PET_CHANGED" then
        BPCC.updateAllIcons()
    end

    if event == "PET_BATTLE_CLOSE" then
        for _, abilityFrame in pairs(BPCC.abilityFrames) do
            BPCC.clearIcons(abilityFrame)
            abilityFrame:Hide()
        end
        for _, auraFrame in pairs(BPCC.auraFrames) do
                auraFrame:Hide()
        end

    end


end

eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("ADDON_LOADED")

eventListenerFrame:RegisterEvent("PET_BATTLE_OPENING_START")
eventListenerFrame:RegisterEvent("PET_BATTLE_CLOSE")



eventListenerFrame:RegisterEvent("PET_BATTLE_PET_CHANGED")
eventListenerFrame:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE")



