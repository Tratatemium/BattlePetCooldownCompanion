-- This addon that tracks ability cooldowns and effects on inactive battle pets.
-- It is a remake of Derangement\’s Pet Battle Cooldowns


--- **** TODO:
--- try lockdowns
--- cooldown shadow on inactive pets when active pet ability locked?

BPCC = BPCC or {abilityFrames={}, debuffFrames={}, buffFrames ={}}

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

    for _, auraFrame in pairs(BPCC.buffFrames) do
        if not auraFrame:IsShown() then
            auraFrame:Show()
        end
    end

    for _, auraFrame in pairs(BPCC.debuffFrames) do
        if not auraFrame:IsShown() then
            auraFrame:Show()
        end
    end

    BPCC.updateIcons(BPCC.abilityFrames.enemyActivePet)

    if C_PetBattles.GetNumPets(1) > 1 then
        BPCC.updateIcons(BPCC.abilityFrames.playerPet1)
        BPCC.updateAuraIcons(BPCC.buffFrames.playerPet1, BPCC.debuffFrames.playerPet1)
    end
    if C_PetBattles.GetNumPets(1) > 2 then
        BPCC.updateIcons(BPCC.abilityFrames.playerPet2)
        BPCC.updateAuraIcons(BPCC.buffFrames.playerPet2, BPCC.debuffFrames.playerPet2)
    end

    if C_PetBattles.GetNumPets(2) > 1 then
        BPCC.updateIcons(BPCC.abilityFrames.enemyPet1)
        BPCC.updateAuraIcons(BPCC.buffFrames.enemyPet1, BPCC.debuffFrames.enemyPet1)
    end
    if C_PetBattles.GetNumPets(2) > 2 then
        BPCC.updateIcons(BPCC.abilityFrames.enemyPet2)
        BPCC.updateAuraIcons(BPCC.buffFrames.enemyPet2, BPCC.debuffFrames.enemyPet2)
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
BPCC.abilityFrames.enemyActivePet:SetPoint("BOTTOM", PetBattleFrame.BottomFrame, "TOP", 0, 30)
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

local auraIconSize = 19

BPCC.debuffFrames.playerPet1 = CreateFrame("Frame", "BPCC.debuffFrames.playerPet1", UIParent)
BPCC.debuffFrames.playerPet1.iconSize = auraIconSize
BPCC.debuffFrames.playerPet1:SetSize(100, BPCC.debuffFrames.playerPet1.iconSize)
BPCC.debuffFrames.playerPet1:SetPoint("BOTTOMRIGHT", BPCC.abilityFrames.playerPet1, "BOTTOMLEFT", -5, 0)
BPCC.debuffFrames.playerPet1.team = "PLAYER_TEAM"
BPCC.debuffFrames.playerPet1.isBuff = false
BPCC.debuffFrames.playerPet1.slot = 1
BPCC.debuffFrames.playerPet1:Hide()

BPCC.buffFrames.playerPet1 = CreateFrame("Frame", "BPCC.buffFrames.playerPet1", UIParent)
BPCC.buffFrames.playerPet1.iconSize = auraIconSize
BPCC.buffFrames.playerPet1:SetSize(100, BPCC.buffFrames.playerPet1.iconSize)
BPCC.buffFrames.playerPet1:SetPoint("BOTTOMRIGHT", BPCC.abilityFrames.playerPet1, "BOTTOMLEFT", -5, auraIconSize)
BPCC.buffFrames.playerPet1.team = "PLAYER_TEAM"
BPCC.buffFrames.playerPet1.isBuff = true
BPCC.buffFrames.playerPet1.slot = 1
BPCC.buffFrames.playerPet1:Hide()

BPCC.debuffFrames.playerPet2 = CreateFrame("Frame", "BPCC.debuffFrames.playerPet2", UIParent)
BPCC.debuffFrames.playerPet2.iconSize = auraIconSize
BPCC.debuffFrames.playerPet2:SetSize(100, BPCC.debuffFrames.playerPet2.iconSize)
BPCC.debuffFrames.playerPet2:SetPoint("BOTTOMRIGHT", BPCC.abilityFrames.playerPet2, "BOTTOMLEFT", -5, 0)
BPCC.debuffFrames.playerPet2.team = "PLAYER_TEAM"
BPCC.debuffFrames.playerPet2.isBuff = false
BPCC.debuffFrames.playerPet2.slot = 2
BPCC.debuffFrames.playerPet2:Hide()

BPCC.buffFrames.playerPet2 = CreateFrame("Frame", "BPCC.buffFrames.playerPet2", UIParent)
BPCC.buffFrames.playerPet2.iconSize = auraIconSize
BPCC.buffFrames.playerPet2:SetSize(100, BPCC.buffFrames.playerPet2.iconSize)
BPCC.buffFrames.playerPet2:SetPoint("BOTTOMRIGHT", BPCC.abilityFrames.playerPet2, "BOTTOMLEFT", -5, auraIconSize)
BPCC.buffFrames.playerPet2.team = "PLAYER_TEAM"
BPCC.buffFrames.playerPet2.isBuff = true
BPCC.buffFrames.playerPet2.slot = 2
BPCC.buffFrames.playerPet2:Hide()

BPCC.debuffFrames.enemyPet1 = CreateFrame("Frame", "BPCC.debuffFrames.enemyPet1", UIParent)
BPCC.debuffFrames.enemyPet1.iconSize = auraIconSize
BPCC.debuffFrames.enemyPet1:SetSize(100, BPCC.debuffFrames.enemyPet1.iconSize)
BPCC.debuffFrames.enemyPet1:SetPoint("BOTTOMLEFT", BPCC.abilityFrames.enemyPet1, "BOTTOMRIGHT", 5, 0)
BPCC.debuffFrames.enemyPet1.team = "ENEMY_TEAM"
BPCC.debuffFrames.enemyPet1.isBuff = false
BPCC.debuffFrames.enemyPet1.slot = 1
BPCC.debuffFrames.enemyPet1:Hide()

BPCC.buffFrames.enemyPet1 = CreateFrame("Frame", "BPCC.buffFrames.enemyPet1", UIParent)
BPCC.buffFrames.enemyPet1.iconSize = auraIconSize
BPCC.buffFrames.enemyPet1:SetSize(100, BPCC.buffFrames.enemyPet1.iconSize)
BPCC.buffFrames.enemyPet1:SetPoint("BOTTOMLEFT", BPCC.abilityFrames.enemyPet1, "BOTTOMRIGHT", 5, auraIconSize)
BPCC.buffFrames.enemyPet1.team = "ENEMY_TEAM"
BPCC.buffFrames.enemyPet1.isBuff = true
BPCC.buffFrames.enemyPet1.slot = 1
BPCC.buffFrames.enemyPet1:Hide()

BPCC.debuffFrames.enemyPet2 = CreateFrame("Frame", "BPCC.debuffFrames.enemyPet2", UIParent)
BPCC.debuffFrames.enemyPet2.iconSize = auraIconSize
BPCC.debuffFrames.enemyPet2:SetSize(100, BPCC.debuffFrames.enemyPet2.iconSize)
BPCC.debuffFrames.enemyPet2:SetPoint("BOTTOMLEFT", BPCC.abilityFrames.enemyPet2, "BOTTOMRIGHT", 5, 0)
BPCC.debuffFrames.enemyPet2.team = "ENEMY_TEAM"
BPCC.debuffFrames.enemyPet2.isBuff = false
BPCC.debuffFrames.enemyPet2.slot = 2
BPCC.debuffFrames.enemyPet2:Hide()

BPCC.buffFrames.enemyPet2 = CreateFrame("Frame", "BPCC.buffFrames.enemyPet2", UIParent)
BPCC.buffFrames.enemyPet2.iconSize = auraIconSize
BPCC.buffFrames.enemyPet2:SetSize(100, BPCC.buffFrames.enemyPet2.iconSize)
BPCC.buffFrames.enemyPet2:SetPoint("BOTTOMLEFT", BPCC.abilityFrames.enemyPet2, "BOTTOMRIGHT", 5, auraIconSize)
BPCC.buffFrames.enemyPet2.team = "ENEMY_TEAM"
BPCC.buffFrames.enemyPet2.isBuff = true
BPCC.buffFrames.enemyPet2.slot = 2
BPCC.buffFrames.enemyPet2:Hide()


C_Timer.After(0, function()
    for _, subTable in pairs({BPCC.buffFrames, BPCC.debuffFrames}) do
        for _, auraFrame in pairs(subTable) do
            BPCC.createAuraIcons(auraFrame, auraFrame.iconSize)
        end
    end
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

    elseif event == "PET_BATTLE_OPENING_START" or event == "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE" or event == "PET_BATTLE_PET_CHANGED" then
        print("all icons updated", event)
        BPCC.updateAllIcons()

    elseif event == "PET_BATTLE_AURA_APPLIED" or event == "PET_BATTLE_AURA_CHANGED" then
        if C_PetBattles.GetNumPets(1) > 1 then
            BPCC.updateAuraIcons(BPCC.buffFrames.playerPet1, BPCC.debuffFrames.playerPet1)
        end
        if C_PetBattles.GetNumPets(1) > 2 then
            BPCC.updateAuraIcons(BPCC.buffFrames.playerPet2, BPCC.debuffFrames.playerPet2)
        end    
        if C_PetBattles.GetNumPets(2) > 1 then
            BPCC.updateAuraIcons(BPCC.buffFrames.enemyPet1, BPCC.debuffFrames.enemyPet1)
        end
        if C_PetBattles.GetNumPets(2) > 2 then
            BPCC.updateAuraIcons(BPCC.buffFrames.enemyPet2, BPCC.debuffFrames.enemyPet2)
        end

    elseif event == "PET_BATTLE_CLOSE" then
        for _, abilityFrame in pairs(BPCC.abilityFrames) do
            BPCC.clearIcons(abilityFrame)
            abilityFrame:Hide()
            for _, child in ipairs({abilityFrame:GetChildren()}) do
                child:Hide()
            end
        end
        for _, subTable in pairs({BPCC.buffFrames, BPCC.debuffFrames}) do
            for _, auraFrame in pairs(subTable) do
                auraFrame:Hide()
                for _, child in ipairs({auraFrame:GetChildren()}) do
                    child:Hide()
                end
            end
        end

    end


end

eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("ADDON_LOADED")

eventListenerFrame:RegisterEvent("PET_BATTLE_OPENING_START")
eventListenerFrame:RegisterEvent("PET_BATTLE_CLOSE")

eventListenerFrame:RegisterEvent("PET_BATTLE_PET_CHANGED")
eventListenerFrame:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE")
eventListenerFrame:RegisterEvent("PET_BATTLE_AURA_APPLIED")
eventListenerFrame:RegisterEvent("PET_BATTLE_AURA_CHANGED")




