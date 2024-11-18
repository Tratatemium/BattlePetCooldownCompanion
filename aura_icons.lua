
---Finction that ctreatee aura icons for selected aura frame
---@param parentFrame table
---@param iconSize integer
function BPCC.createAuraIcons(parentFrame, iconSize)
    local auraIcons = {}
    local auraIconNames = {}

    local ancorPoint = "TOPRIGHT"
    if parentFrame.team == "PLAYER_TEAM" then
        if parentFrame.isBuff then
            ancorPoint = "TOPRIGHT"
        else
            ancorPoint = "BOTTOMRIGHT"
        end
    else
        if parentFrame.isBuff then
            ancorPoint = "TOPLEFT"
        else
            ancorPoint = "BOTTOMLEFT"
        end
    end

    local xOffsetValues = {}
    if parentFrame.team == "PLAYER_TEAM" then
        for i = 0, 5 do
            xOffsetValues[i + 1] = -i * iconSize
        end
    else
        for i = 0, 5 do
            xOffsetValues[i + 1] = i * iconSize
        end
    end
    
    for i = 1, 6 do
        local auraKey = "aura_" .. i
        parentFrame[auraKey] = {}
        auraIcons[i] = parentFrame[auraKey]
        auraIconNames[i] = parentFrame:GetName() .. ".aura_" .. i
    end

    for i, auraIcon in ipairs(auraIcons) do    
        BPCC.createAuraIcon(auraIcon, auraIconNames[i], parentFrame, iconSize, ancorPoint, xOffsetValues[i])
    end
end



-- "BOTTOMLEFT"|"TOPLEFT"|"BOTTOMRIGHT"|"TOPRIGHT"


---Fuction that creates aura effect icon
---@param auraIcon table
---@param auraIconName string
---@param parent table
---@param iconSize integer
---@param ancorPoint "BOTTOMLEFT"|"TOPLEFT"|"BOTTOMRIGHT"|"TOPRIGHT"
---@param xOffset number
function BPCC.createAuraIcon(auraIcon, auraIconName, parent, iconSize, ancorPoint, xOffset)

    auraIcon = CreateFrame("Frame", auraIconName, parent)
    auraIcon:SetSize(iconSize, iconSize)
    auraIcon:SetPoint(ancorPoint, parent:GetName(), ancorPoint, xOffset, 0)

    auraIcon.border = auraIcon:CreateTexture(nil, "OVERLAY")
    auraIcon.border:SetTexture(130759)
    auraIcon.border:SetSize(iconSize, iconSize)
    auraIcon.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    auraIcon.border:SetVertexColor(1, 0, 0, 1)
    auraIcon.border:SetPoint("CENTER", auraIconName, "CENTER", 0, 0)
    auraIcon.border:SetDrawLayer("OVERLAY", 0)
    auraIcon.border:Hide()

    auraIcon.iconTexture = auraIcon:CreateTexture(nil, "ARTWORK")
    auraIcon.iconTexture:SetSize(iconSize, iconSize) 
    auraIcon.iconTexture:SetPoint("CENTER", auraIconName, "CENTER", 0, 0)

    auraIcon.durationText = auraIcon:CreateFontString(nil, "OVERLAY")
    auraIcon.durationText:SetDrawLayer("OVERLAY", 1)
    auraIcon.durationText:SetFont("fonts/frizqt__.ttf", 0.8 * iconSize, "OUTLINE")
    auraIcon.durationText:SetTextColor(1, 0.8196, 0, 1)
    auraIcon.durationText:SetPoint("CENTER", auraIconName, "CENTER", 0, 0)
    auraIcon.durationText:SetText("")

end

--- *** Update Icons ***

---Function that updates ability icons on selected frame
---@param parentBuffFrame table
---@param parentDebuffFrame table
function BPCC.updateAuraIcons(parentBuffFrame, parentDebuffFrame)

    -- Creating clean table with aura info to depict aura icons and tooltips
    BPCC.auraMap = {buffs = {}, debuffs ={}}
    for i = 1, 6 do
        BPCC.auraMap.buffs[i] = {auraID = nil, turnsRemaining = 0, isBuff = true}
        BPCC.auraMap.debuffs[i] = {auraID = nil, turnsRemaining = 0, isBuff = false}
    end

    -- Locating pet owner and index and checking number of auras that pet has
    local petOwner, petIndex = BPCC.locatePet(parentBuffFrame)
    local numAuras = C_PetBattles.GetNumAuras(petOwner, petIndex)

    -- Sort auras buy buff/debuff and fill aura info in the table
    if numAuras > 0 then
        local buff_i, debuff_i = 1, 1
        for i = 1, numAuras do
            local auraID, instanceID, turnsRemaining, isBuff = C_PetBattles.GetAuraInfo(petOwner, petIndex, i)

            if isBuff then
                if buff_i < 6 then
                    BPCC.auraMap.buffs[buff_i].auraID = auraID
                    BPCC.auraMap.buffs[buff_i].turnsRemaining = turnsRemaining
                    BPCC.auraMap.buffs[buff_i].isBuff = true
                    buff_i = buff_i + 1
                end
            else
                if debuff_i < 6 then
                    BPCC.auraMap.debuffs[debuff_i].auraID = auraID
                    BPCC.auraMap.debuffs[debuff_i].turnsRemaining = turnsRemaining
                    BPCC.auraMap.debuffs[debuff_i].isBuff = false
                    debuff_i = debuff_i + 1
                end
            end

        end
    end

    -- Update each aura icon according to map
    for i, auraIcon in ipairs({parentBuffFrame:GetChildren()}) do
        local auraID, turnsRemaining, isBuff = BPCC.auraMap.buffs[i].auraID, BPCC.auraMap.buffs[i].turnsRemaining, BPCC.auraMap.buffs[i].isBuff
        BPCC.updateAuraIcon(auraIcon, auraID, turnsRemaining, isBuff, petOwner, petIndex)
    end
    for i, auraIcon in ipairs({parentDebuffFrame:GetChildren()}) do  
        local auraID, turnsRemaining, isBuff = BPCC.auraMap.debuffs[i].auraID, BPCC.auraMap.debuffs[i].turnsRemaining, BPCC.auraMap.debuffs[i].isBuff
        BPCC.updateAuraIcon(auraIcon, auraID, turnsRemaining, isBuff, petOwner, petIndex)
    end
end

function BPCC.updateAuraIcon(auraIcon, auraID, turnsRemaining, isBuff, petOwner, petIndex)
    if not auraIcon:IsShown() then
        auraIcon:Show()
    end
    if auraID then
        local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfoByID(auraID)
        auraIcon.iconTexture:SetTexture(icon)
        if not isBuff then
            auraIcon.border:Show()
        else
            auraIcon.border:Hide()
        end
        if turnsRemaining > 0 then
            auraIcon.durationText:SetText(turnsRemaining)
        else
            auraIcon.durationText:SetText("")
        end
        

        C_Timer.After(0, function()
            BPCC.createTooltip(auraIcon, "DOWN", id, petOwner, petIndex)
        end)

    else
        auraIcon.iconTexture:SetTexture(nil)
        auraIcon.border:Hide()
        auraIcon.durationText:SetText("")
        auraIcon:SetScript("OnEnter", function(self) end)
    end
end