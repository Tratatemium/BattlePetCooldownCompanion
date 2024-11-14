--- Creates pet ability tooltip
--- @param frame table|Frame
--- @param position "UP"|"DOWN"
--- @param abilityID number
--- @param team number
--- @param petSlot number 1|2|3
function BPCC.createTooltip(frame, position, abilityID, team, petSlot)


    local tooltip = PetBattlePrimaryAbilityTooltip

    frame:SetScript("OnEnter", function(self)

        PetBattleAbilityTooltip_SetAbilityByID(team, petSlot, abilityID)

        local x, y = self:GetCenter()
        if position == "UP" then
            PetBattleAbilityTooltip_Show("BOTTOM", UIParent, "BOTTOMLEFT", x, y + 25);
        else
            PetBattleAbilityTooltip_Show("TOP", UIParent, "BOTTOMLEFT", x, y - 25);
        end
        
    end)
    
    frame:SetScript("OnLeave", function(self)
        tooltip:Hide()
    end)

    return tooltip
end 
