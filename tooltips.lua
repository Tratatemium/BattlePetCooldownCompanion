
--- @param frame table
--- @param position "UP"|"DOWN"
--- @param abilityID number
--- @param team "PLAYER"|"ENEMY"
--- @param petSlot number 1|2|3
function BPCC.createTooltip(frame, position, abilityID, team, petSlot)

    local tooltip = FloatingPetBattleAbilityTooltip

    local petOwner = 1
    if team == "ENEMY" then
        petOwner = 2
    end


    local maxHealth = C_PetBattles.GetMaxHealth(petOwner, petSlot) or 100
    local power = C_PetBattles.GetPower(petOwner, petSlot) or 0
    local speed = C_PetBattles.GetSpeed(petOwner, petSlot) or 0
    print("petOwner=", petOwner)
    print("petSlot=", petSlot)
    print("maxHealth =", maxHealth)
    print("power =", power)
    print("speed =", speed)

    -- *** Calculate adjusted power based on "strong/weak vs" ***
    if not abilityID then
        abilityID = 616
    end

    local playerActivePetType = C_PetBattles.GetPetType(1, C_PetBattles.GetActivePet(1))
    
    local _, _, abilityType = C_PetJournal.GetPetAbilityInfo(abilityID)

    local modifier = C_PetBattles.GetAttackModifier(abilityType, playerActivePetType)

    local adjustedPower = power * modifier

    print("adjustedPower =", adjustedPower)

    frame:SetScript("OnEnter", function(self)
        FloatingPetBattleAbility_Show(abilityID, maxHealth, adjustedPower, speed)
        
        tooltip:ClearAllPoints()
        local x, y = self:GetCenter()
        if position == "UP" then
            tooltip:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", x, y + 25)
        else
            tooltip:SetPoint("TOP", UIParent, "BOTTOMLEFT", x, y - 25)
        end

        

        tooltip.CloseButton:Hide()
    end)
    
    frame:SetScript("OnLeave", function(self)
        tooltip:Hide()
    end)
    return tooltip
end 