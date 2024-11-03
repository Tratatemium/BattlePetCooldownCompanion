
--- @param frame table|Frame
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
--[[     print("petOwner=", petOwner)
    print("petSlot=", petSlot)
    print("power =", power) ]]
  
    -- *** Calculate adjusted power based on "strong/weak vs" ***
    if not abilityID then
        abilityID = 616
    end

    local playerActivePetType = C_PetBattles.GetPetType(1, C_PetBattles.GetActivePet(1))
    
    local _, _, abilityType = C_PetJournal.GetPetAbilityInfo(abilityID)

    local modifier = C_PetBattles.GetAttackModifier(abilityType, playerActivePetType)

    local adjustedPower = power * modifier
--[[ 
    print("adjustedPower =", adjustedPower) ]]

    frame:SetScript("OnEnter", function(self)
        FloatingPetBattleAbility_Show(abilityID, maxHealth, power, speed)
        
        tooltip:ClearAllPoints()
        local x, y = self:GetCenter()
        if position == "UP" then
            tooltip:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", x, y + 25)
        else
            tooltip:SetPoint("TOP", UIParent, "BOTTOMLEFT", x, y - 25)
        end

        local text = tooltip.Description:GetText()

        --PLUS_DAMAGE_TEMPLATE = "+ %s - %s ед. урона"
        local damageFormat = PLUS_SINGLE_DAMAGE_TEMPLATE:gsub("%+", ""):gsub("%%s", "(%%d+)")
        print(PLUS_SINGLE_DAMAGE_TEMPLATE:gsub("^%+ %s", ""))

        text = text:gsub(damageFormat, function(number)

            local function round(num)
                return math.floor(num + 0.5)
            end

            local newNumber = round(modifier * tonumber(number))  -- Calculate 3 * number
            local coloredNumber = ""
            if modifier > 1 then
                coloredNumber = string.format(" |cff00ff00%d|r", newNumber)
            elseif modifier < 1 then
                coloredNumber = string.format(" |cffff0000%d|r", newNumber)
            else
                coloredNumber = string.format(" %d", newNumber)
            end

            

            return coloredNumber .. " " .. PLUS_SINGLE_DAMAGE_TEMPLATE:gsub("^%+ ", ""):gsub("%%s ", "")
        end)
        
        print(text)

        tooltip.CloseButton:Hide()
    end)
    
    frame:SetScript("OnLeave", function(self)
        tooltip:Hide()
    end)
    return tooltip
end 



--[[ PLUS_SINGLE_DAMAGE_TEMPLATE = "+ %s Damage"

print(PLUS_SINGLE_DAMAGE_TEMPLATE:gsub("^%+ %s", ""):gsub("%%s ", ""))

output is "+ Damage" ]]