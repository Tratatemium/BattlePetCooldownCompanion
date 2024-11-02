-- This addon that tracks ability cooldowns and effects on inactive battle pets.
-- It is a remake of Derangement\’s Pet Battle Cooldowns

BPCC = BPCC or {}

--[[ 
    **************************************************
    * SECTION: functions
    **************************************************
--]]

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


enemyActivePetCooldownsFrame.ability_1 = CreateFrame("Frame", "enemyActivePetCooldownsFrame.ability_1", enemyActivePetCooldownsFrame)
enemyActivePetCooldownsFrame.ability_1:SetSize(50, 50)
enemyActivePetCooldownsFrame.ability_1:SetPoint("CENTER", "enemyActivePetCooldownsFrame", "CENTER", -50, 0)

enemyActivePetCooldownsFrame.ability_1.border = enemyActivePetCooldownsFrame.ability_1:CreateTexture(nil, "OVERLAY")
enemyActivePetCooldownsFrame.ability_1.border:SetTexture("Interface\\Buttons\\UI-Quickslot2") -- Button border texture
enemyActivePetCooldownsFrame.ability_1.border:SetSize(80, 80)
enemyActivePetCooldownsFrame.ability_1.border:SetPoint("CENTER", "enemyActivePetCooldownsFrame.ability_1", "CENTER", 0, 0)

enemyActivePetCooldownsFrame.ability_1.iconTexture = enemyActivePetCooldownsFrame.ability_1:CreateTexture(nil, "ARTWORK")
enemyActivePetCooldownsFrame.ability_1.iconTexture:SetSize(50, 50)  -- Icon size
enemyActivePetCooldownsFrame.ability_1.iconTexture:SetPoint("CENTER", "enemyActivePetCooldownsFrame.ability_1", "CENTER", 0, 0)



--[[ local tooltip = FloatingPetBattleAbilityTooltip

enemyActivePetCooldownsFrame.ability_1:SetScript("OnEnter", function(self)
    FloatingPetBattleAbility_Show(616,2000,250,313) 
    tooltip:ClearAllPoints()
    local x, y = self:GetCenter()
    tooltip:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", x, y + 30)
    tooltip.CloseButton:Hide()
end)

enemyActivePetCooldownsFrame.ability_1:SetScript("OnLeave", function(self)
    tooltip:Hide()
end) ]]





enemyActivePetCooldownsFrame.ability_2 = CreateFrame("Frame", "enemyActivePetCooldownsFrame.ability_2", enemyActivePetCooldownsFrame)
enemyActivePetCooldownsFrame.ability_2:SetSize(80, 80)
enemyActivePetCooldownsFrame.ability_2:SetPoint("CENTER", "enemyActivePetCooldownsFrame", "CENTER", 0, 0)
enemyActivePetCooldownsFrame.ability_2.border = enemyActivePetCooldownsFrame.ability_2:CreateTexture(nil, "OVERLAY")
enemyActivePetCooldownsFrame.ability_2.border:SetTexture("Interface\\Buttons\\UI-Quickslot2") -- Button border texture
enemyActivePetCooldownsFrame.ability_2.border:SetAllPoints(enemyActivePetCooldownsFrame.ability_2)


enemyActivePetCooldownsFrame.ability_3 = CreateFrame("Frame", "enemyActivePetCooldownsFrame.ability_3", enemyActivePetCooldownsFrame)
enemyActivePetCooldownsFrame.ability_3:SetSize(80, 80)
enemyActivePetCooldownsFrame.ability_3:SetPoint("CENTER", "enemyActivePetCooldownsFrame", "CENTER", 50, 0)
enemyActivePetCooldownsFrame.ability_3.border = enemyActivePetCooldownsFrame.ability_3:CreateTexture(nil, "OVERLAY")
enemyActivePetCooldownsFrame.ability_3.border:SetTexture("Interface\\Buttons\\UI-Quickslot2") -- Button border texture
enemyActivePetCooldownsFrame.ability_3.border:SetAllPoints(enemyActivePetCooldownsFrame.ability_3)




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

        local activeEnemyPetIndex = C_PetBattles.GetActivePet(2)
        local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(2, activeEnemyPetIndex, 1)
        if icon then
            enemyActivePetCooldownsFrame.ability_1.iconTexture:SetTexture(icon)
        end
        C_Timer.After(0, function()
            BPCC.createTooltip(enemyActivePetCooldownsFrame.ability_1, "UP", id, "ENEMY", activeEnemyPetIndex)
        end)


    end
    if event == "PET_BATTLE_PET_ROUND_RESULTS" then

        print("PET_BATTLE_PET_ROUND_RESULTS")

        enemyActivePetCooldownsFrame:Show()

        local activeEnemyPetIndex = C_PetBattles.GetActivePet(2)
        local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(2, activeEnemyPetIndex, 1)
        print("activeEnemyPetIndex=" .. (activeEnemyPetIndex or "no index") .. "  id=" .. (id or "no id"))
        if icon then
            enemyActivePetCooldownsFrame.ability_1.iconTexture:SetTexture(icon)
        end
        C_Timer.After(0, function()
            BPCC.createTooltip(enemyActivePetCooldownsFrame.ability_1, "UP", id, "ENEMY", activeEnemyPetIndex)
        end)


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
eventListenerFrame:RegisterEvent("BANKFRAME_CLOSED")
eventListenerFrame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
eventListenerFrame:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")