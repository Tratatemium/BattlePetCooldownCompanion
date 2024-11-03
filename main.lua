-- This addon that tracks ability cooldowns and effects on inactive battle pets.
-- It is a remake of Derangement\’s Pet Battle Cooldowns

BPCC = BPCC or {}

--[[ 
    **************************************************
    * SECTION: functions
    **************************************************
--]]

---Function that creates pet ability icon frame and textures for it
---@param abilityIcon table|Frame
---@param abilityIconName string
---@param parent table|Frame
---@param xOffset number
function BPCC.createAbilityIcon(abilityIcon, abilityIconName, parent, xOffset)
    abilityIcon = CreateFrame("Frame", abilityIconName, parent)
    abilityIcon:SetSize(50, 50)
    abilityIcon:SetPoint("CENTER", parent:GetName(), "CENTER", xOffset, 0)

    abilityIcon.border = abilityIcon:CreateTexture(nil, "OVERLAY")
    abilityIcon.border:SetTexture("Interface\\Buttons\\UI-Quickslot2") -- Button border texture
    abilityIcon.border:SetSize(80, 80)
    abilityIcon.border:SetPoint("CENTER", abilityIconName, "CENTER", 0, 0)
    abilityIcon.border:SetDrawLayer("OVERLAY", 0)

    abilityIcon.iconTexture = abilityIcon:CreateTexture(nil, "ARTWORK")
    abilityIcon.iconTexture:SetSize(50, 50)  -- Icon size
    abilityIcon.iconTexture:SetPoint("CENTER", abilityIconName, "CENTER", 0, 0)

    abilityIcon.modifierTexture = abilityIcon:CreateTexture(nil, "OVERLAY")
    abilityIcon.modifierTexture:SetSize(20, 20)  -- Icon size
    abilityIcon.modifierTexture:SetPoint("CENTER", abilityIconName, "CENTER", 15, -15)
    abilityIcon.modifierTexture:SetDrawLayer("OVERLAY", 1)
end



---Function that assigns correct textures to pet ability icons and creates tooltips
---@param abilityIcon table|Frame
---@param i number
function BPCC.updateAbilityIcon(abilityIcon, i)

    -- Ability info
    local activeEnemyPetIndex = C_PetBattles.GetActivePet(2)
    local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(2, activeEnemyPetIndex, i)
    
    -- Icon texture
    if icon then
        abilityIcon.iconTexture:SetTexture(icon)
    end

    -- Strong vs / Weak vs texture
    local playerActivePetType = C_PetBattles.GetPetType(1, C_PetBattles.GetActivePet(1))    
    local _, _, abilityType = C_PetJournal.GetPetAbilityInfo(id)
    local modifier = C_PetBattles.GetAttackModifier(abilityType, playerActivePetType)
    if modifier > 1 then
        abilityIcon.modifierTexture:SetTexture(608706)
    elseif modifier < 1 then
        abilityIcon.modifierTexture:SetTexture(608707)
    end

    --Create tooltip
    C_Timer.After(0, function()
        BPCC.createTooltip(abilityIcon, "UP", id, "ENEMY", activeEnemyPetIndex)
    end)
end



function BPCC.UpdateIcons(parentFrame)
    for i, abilityIcon in ipairs({parentFrame:GetChildren()}) do    
        BPCC.updateAbilityIcon(abilityIcon, i)
    end
end


---Function that creates 3 pet ability icons
---@param parentFrame table|Frame
function BPCC.createIcons(parentFrame)
    local abilityIcons = {}
    local abilityIconNames = {}
    local xOffsetValues = {-50, 0, 50}

    for i = 1, 3 do
        local abilityKey = "ability_" .. i
        parentFrame[abilityKey] = {}
        abilityIcons[i] = parentFrame[abilityKey]
        abilityIconNames[i] = parentFrame:GetName() .. ".ability_" .. i
    end

    for i, abilityIcon in ipairs(abilityIcons) do    
        BPCC.createAbilityIcon(abilityIcon, abilityIconNames[i], parentFrame, xOffsetValues[i])
    end
end

--[[ 
    **************************************************
    * SECTION: frames
    **************************************************
--]]

local enemyActivePetCooldownsFrame = CreateFrame("Frame", "enemyActivePetCooldownsFrame", UIParent)
enemyActivePetCooldownsFrame:SetSize(300, 80)
enemyActivePetCooldownsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
enemyActivePetCooldownsFrame:Hide()

SLASH_BPCC1 = "/bpcc"
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
end

BPCC.createIcons(enemyActivePetCooldownsFrame)



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
        BPCC.UpdateIcons(enemyActivePetCooldownsFrame)

    end

    if event == "PET_BATTLE_PET_ROUND_RESULTS" then

        BPCC.UpdateIcons(enemyActivePetCooldownsFrame)

    end

    if event == "PET_BATTLE_PET_CHANGED" then

        BPCC.UpdateIcons(enemyActivePetCooldownsFrame)

    end


    if event == "PET_BATTLE_CLOSE" then
        enemyActivePetCooldownsFrame:Hide()
    end


end

eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("ADDON_LOADED")

eventListenerFrame:RegisterEvent("PET_BATTLE_OPENING_START")
eventListenerFrame:RegisterEvent("PET_BATTLE_CLOSE")


eventListenerFrame:RegisterEvent("PET_BATTLE_PET_ROUND_RESULTS")
eventListenerFrame:RegisterEvent("PET_BATTLE_PET_CHANGED")
eventListenerFrame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
eventListenerFrame:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")