-- This addon that tracks ability cooldowns and effects on inactive battle pets.
-- It is a remake of Derangement\’s Pet Battle Cooldowns


--- **** TODO:
--- try lockdowns

BPCC = BPCC or {}

--[[ 
    **************************************************
    * SECTION: functions
    **************************************************
--]]

---Function that creates 3 pet ability icons
---@param parentFrame table|Frame
---@param iconSize integer
function BPCC.createIcons(parentFrame, iconSize)
    local abilityIcons = {}
    local abilityIconNames = {}
    local xOffsetValues = {-iconSize, 0, iconSize}

    for i = 1, 3 do
        local abilityKey = "ability_" .. i
        parentFrame[abilityKey] = {}
        abilityIcons[i] = parentFrame[abilityKey]
        abilityIconNames[i] = parentFrame:GetName() .. ".ability_" .. i
    end

    for i, abilityIcon in ipairs(abilityIcons) do    
        BPCC.createAbilityIcon(abilityIcon, abilityIconNames[i], parentFrame, xOffsetValues[i], iconSize)
    end
end

---Function that creates pet ability icon frame and textures for it
---@param abilityIcon table|Frame
---@param abilityIconName string
---@param parent table|Frame
---@param xOffset number
---@param iconSize integer
function BPCC.createAbilityIcon(abilityIcon, abilityIconName, parent, xOffset, iconSize)
    abilityIcon = CreateFrame("Frame", abilityIconName, parent)
    abilityIcon:SetSize(50, 50)
    abilityIcon:SetPoint("CENTER", parent:GetName(), "CENTER", xOffset, 0)

    abilityIcon.border = abilityIcon:CreateTexture(nil, "OVERLAY")
    abilityIcon.border:SetTexture("Interface\\Buttons\\UI-Quickslot2") -- Button border texture
    abilityIcon.border:SetSize(1.6 * iconSize, 1.6 * iconSize)
    abilityIcon.border:SetPoint("CENTER", abilityIconName, "CENTER", 0, 0)
    abilityIcon.border:SetDrawLayer("OVERLAY", 0)

    abilityIcon.iconTexture = abilityIcon:CreateTexture(nil, "ARTWORK")
    abilityIcon.iconTexture:SetSize(iconSize, iconSize)  -- Icon size
    abilityIcon.iconTexture:SetPoint("CENTER", abilityIconName, "CENTER", 0, 0)
    abilityIcon.iconTexture:SetDesaturated(false)
    abilityIcon.iconTexture:SetVertexColor(1, 1, 1, 1)

    abilityIcon.modifierTexture = abilityIcon:CreateTexture(nil, "OVERLAY")
    abilityIcon.modifierTexture:SetSize(0.4 * iconSize, 0.4 * iconSize)  -- Icon size
    abilityIcon.modifierTexture:SetPoint("CENTER", abilityIconName, "CENTER", 0.3 * iconSize, -0.3 * iconSize)
    abilityIcon.modifierTexture:SetDrawLayer("OVERLAY", 1)

    abilityIcon.cooldownShadow = abilityIcon:CreateTexture(nil, "BORDER")
    abilityIcon.cooldownShadow:SetTexture(603587)
    abilityIcon.cooldownShadow:SetSize(iconSize, iconSize)  -- Icon size
    abilityIcon.cooldownShadow:SetTexCoord(0.716796875, 0.7685546875, 0.853515625, 0.955078125)
    abilityIcon.cooldownShadow:SetPoint("CENTER", abilityIconName, "CENTER", 0, 0)
    abilityIcon.cooldownShadow:SetDrawLayer("OVERLAY", 1)
    abilityIcon.cooldownShadow:Hide()

    abilityIcon.cooldownText = abilityIcon:CreateFontString(nil, "OVERLAY")
    abilityIcon.cooldownText:SetDrawLayer("OVERLAY", 1)
    abilityIcon.cooldownText:SetFont("fonts/frizqt__.ttf", 0.6 * iconSize)
    abilityIcon.cooldownText:SetTextColor(1, 0.8196, 0, 1)
    abilityIcon.cooldownText:SetPoint("CENTER", abilityIconName, "CENTER", 0, 0)    
    abilityIcon.cooldownText:SetText("")

end



function BPCC.UpdateIcons(parentFrame)
    for i, abilityIcon in ipairs({parentFrame:GetChildren()}) do    
        BPCC.updateAbilityIcon(abilityIcon, i)
    end
end



---Function that assigns correct textures to pet ability icons and creates tooltips
---@param abilityIcon table|Frame
---@param i number
function BPCC.updateAbilityIcon(abilityIcon, i)

    local parent = abilityIcon:GetParent()

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

    -- Ability info
    local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(team, petIndex, i)
    
    -- Icon texture
    if icon then
        abilityIcon.iconTexture:SetTexture(icon)
    end

    -- Strong vs / Weak vs texture
    local opposingTeam = 1
    if team == 1 then
        opposingTeam = 2
    end

    local playerActivePetType = C_PetBattles.GetPetType(opposingTeam, C_PetBattles.GetActivePet(opposingTeam))    
    local _, _, abilityType = C_PetJournal.GetPetAbilityInfo(id)
    local modifier = C_PetBattles.GetAttackModifier(abilityType, playerActivePetType)
    if modifier == 1  or noStrongWeakHints then
        abilityIcon.modifierTexture:SetTexture(nil)
    elseif modifier > 1 then
        abilityIcon.modifierTexture:SetTexture(608706)
    else
        abilityIcon.modifierTexture:SetTexture(608707)
    end

    -- Cooldown
    local isUsable, currentCooldown, currentLockdown = C_PetBattles.GetAbilityState(team, petIndex, i)
    if isUsable then
        abilityIcon.iconTexture:SetDesaturated(false)
        abilityIcon.iconTexture:SetVertexColor(1, 1, 1, 1)
        abilityIcon.cooldownShadow:Hide()
        abilityIcon.cooldownText:SetText("")
    else
        abilityIcon.iconTexture:SetDesaturated(true)
        abilityIcon.iconTexture:SetVertexColor(0.502, 0.502, 0.502, 1)
        abilityIcon.cooldownShadow:Show()
        if currentCooldown > 0 then
            abilityIcon.cooldownText:SetTextColor(1, 0.8196, 0, 1)
            abilityIcon.cooldownText:SetText(currentCooldown)
            
        else
            abilityIcon.cooldownText:SetText("")
        end        
    end

    --Create tooltip
    local direction = "DOWN"
    if parent.active then
        direction = "UP"
    end
    C_Timer.After(0, function()
        BPCC.createTooltip(abilityIcon, direction, id, team, petIndex)
    end)
end







--[[ 
    **************************************************
    * SECTION: frames
    **************************************************
--]]

--[[ SLASH_BPCC1 = "/bpcc"
SlashCmdList["BPCC"] = function(msg)
    if msg == "" then
        if enemyActivePetCooldownsFrame:IsShown() then
            enemyActivePetCooldownsFrame:Hide()
        else
            enemyActivePetCooldownsFrame:Show()
        end
    else
        -- If invalid argument is provided
        print("Invalid command usage.")
    end
end ]]

local enemyActivePetCooldownsFrame = CreateFrame("Frame", "enemyActivePetCooldownsFrame", UIParent)
enemyActivePetCooldownsFrame:SetSize(150, 50)
enemyActivePetCooldownsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
enemyActivePetCooldownsFrame.team = "ENEMY_TEAM"
enemyActivePetCooldownsFrame.active = true
enemyActivePetCooldownsFrame:Hide()

local playerPet1CooldownsFrame = CreateFrame("Frame", "playerPet1CooldownsFrame", UIParent)
playerPet1CooldownsFrame:SetSize(150, 50)
playerPet1CooldownsFrame:SetPoint("CENTER", PetBattleFrame.Ally2, "CENTER", -90, 0)
playerPet1CooldownsFrame.team = "PLAYER_TEAM"
playerPet1CooldownsFrame.active = false
playerPet1CooldownsFrame.slot = 1
playerPet1CooldownsFrame:Hide()

local playerPet2CooldownsFrame = CreateFrame("Frame", "playerPet2CooldownsFrame", UIParent)
playerPet2CooldownsFrame:SetSize(150, 50)
playerPet2CooldownsFrame:SetPoint("CENTER", PetBattleFrame.Ally3, "CENTER", -90, 0)
playerPet2CooldownsFrame.team = "PLAYER_TEAM"
playerPet2CooldownsFrame.active = false
playerPet2CooldownsFrame.slot = 2
playerPet2CooldownsFrame:Hide()

local enemyPet1CooldownsFrame = CreateFrame("Frame", "enemyPet1CooldownsFrame", UIParent)
enemyPet1CooldownsFrame:SetSize(150, 50)
enemyPet1CooldownsFrame:SetPoint("CENTER", PetBattleFrame.Enemy2, "CENTER", 90, 0)
enemyPet1CooldownsFrame.team = "ENEMY_TEAM"
enemyPet1CooldownsFrame.active = false
enemyPet1CooldownsFrame.slot = 1
enemyPet1CooldownsFrame:Hide()

local enemyPet2CooldownsFrame = CreateFrame("Frame", "enemyPet2CooldownsFrame", UIParent)
enemyPet2CooldownsFrame:SetSize(150, 50)
enemyPet2CooldownsFrame:SetPoint("CENTER", PetBattleFrame.Enemy3, "CENTER", 90, 0)
enemyPet2CooldownsFrame.team = "ENEMY_TEAM"
enemyPet2CooldownsFrame.active = false
enemyPet2CooldownsFrame.slot = 2
enemyPet2CooldownsFrame:Hide()



BPCC.createIcons(enemyActivePetCooldownsFrame, 50)
BPCC.createIcons(playerPet1CooldownsFrame, 38)
BPCC.createIcons(playerPet2CooldownsFrame, 38)
BPCC.createIcons(enemyPet1CooldownsFrame, 38)
BPCC.createIcons(enemyPet2CooldownsFrame, 38)

local function updateAllIcons()
    BPCC.UpdateIcons(enemyActivePetCooldownsFrame)
    BPCC.UpdateIcons(playerPet1CooldownsFrame)
    BPCC.UpdateIcons(playerPet2CooldownsFrame)
    BPCC.UpdateIcons(enemyPet1CooldownsFrame)
    BPCC.UpdateIcons(enemyPet2CooldownsFrame)
end


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

    if event == "PET_BATTLE_OPENING_START" then

        enemyActivePetCooldownsFrame:Show()
        playerPet1CooldownsFrame:Show()
        playerPet2CooldownsFrame:Show()
        enemyPet1CooldownsFrame:Show()
        enemyPet2CooldownsFrame:Show()
        updateAllIcons()

    end

    if event == "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE" then

        updateAllIcons()

    end

    if event == "PET_BATTLE_PET_CHANGED" then

        updateAllIcons()

    end

    if event == "PET_BATTLE_CLOSE" then
        enemyActivePetCooldownsFrame:Hide()
        playerPet1CooldownsFrame:Hide()
        playerPet2CooldownsFrame:Hide()
        enemyPet1CooldownsFrame:Hide()
        enemyPet2CooldownsFrame:Hide()
    end


end

eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("ADDON_LOADED")

eventListenerFrame:RegisterEvent("PET_BATTLE_OPENING_START")
eventListenerFrame:RegisterEvent("PET_BATTLE_CLOSE")


eventListenerFrame:RegisterEvent("PET_BATTLE_PET_ROUND_RESULTS")
eventListenerFrame:RegisterEvent("PET_BATTLE_PET_CHANGED")
eventListenerFrame:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE")
eventListenerFrame:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")