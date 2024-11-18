--[[ 
    **************************************************
    * SECTION: functions
    **************************************************
--]]


--- *** Create Icons ***

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


--- *** Create Ability Icon ***

---Function that creates pet ability icon frame and textures for it
---@param abilityIcon table|Frame
---@param abilityIconName string
---@param parent table|Frame
---@param xOffset number
---@param iconSize integer
function BPCC.createAbilityIcon(abilityIcon, abilityIconName, parent, xOffset, iconSize)
    iconSize = iconSize - 1

    abilityIcon = CreateFrame("Frame", abilityIconName, parent)
    abilityIcon:SetSize(iconSize, iconSize)
    abilityIcon:SetPoint("CENTER", parent:GetName(), "CENTER", xOffset, 0)

    abilityIcon.border = abilityIcon:CreateTexture(nil, "OVERLAY")
    abilityIcon.border:SetTexture("Interface\\Buttons\\UI-Quickslot2") -- Button border texture
    abilityIcon.border:SetSize(1.6 * iconSize, 1.6 * iconSize)
    abilityIcon.border:SetPoint("CENTER", abilityIconName, "CENTER", 0, 0)
    abilityIcon.border:SetDrawLayer("OVERLAY", 0)
    abilityIcon.border:Hide()

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
    abilityIcon.cooldownShadow:SetVertexColor(1, 1, 1, 0.5)
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


--- *** Clear Icons ***

---Function that clears display of ability icons on selected frame
---@param parentFrame table
function BPCC.clearIcons(parentFrame)
    for _, abilityIcon in ipairs({parentFrame:GetChildren()}) do    
        abilityIcon.iconTexture:SetTexture(nil)
        abilityIcon.modifierTexture:SetTexture(nil)
        abilityIcon.border:Hide()
        abilityIcon.cooldownShadow:Hide()
        abilityIcon.cooldownText:SetText("")
        abilityIcon:SetScript("OnEnter", function(self) end)
    end
end


--- *** Update Ability Icons ***

---Function that updates ability icons on selected frame
---@param parentFrame table
function BPCC.updateIcons(parentFrame)
    for i, abilityIcon in ipairs({parentFrame:GetChildren()}) do    
        BPCC.updateAbilityIcon(abilityIcon, i)
    end
end


--- *** Update Ability Icon ***

---Function that assigns correct textures to pet ability icons and creates tooltips
---@param abilityIcon table|Frame
---@param i number
function BPCC.updateAbilityIcon(abilityIcon, i)

    if not abilityIcon:IsShown() then
        abilityIcon:Show()
    end

    abilityIcon.border:Show()

    local parent = abilityIcon:GetParent()

    local team, petIndex = BPCC.locatePet(parent)


    if C_PetBattles.GetHealth(team, petIndex) == 0 then
        abilityIcon.iconTexture:SetTexture(603587)
        abilityIcon.iconTexture:SetTexCoord(0.77734375, 0.8232421875, 0.880859375, 0.97265625)
        abilityIcon.iconTexture:SetVertexColor(1, 1, 1, 1)
        abilityIcon.iconTexture:SetDesaturated(true)
        abilityIcon.modifierTexture:SetTexture(nil)
        abilityIcon.cooldownShadow:Hide()
        abilityIcon.cooldownText:SetText("")
        abilityIcon:SetScript("OnEnter", function(self) end)
        return
    end

    -- Ability info
    local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(team, petIndex, i)

    if not id then
        abilityIcon.iconTexture:SetTexture(648430)
        abilityIcon.iconTexture:SetVertexColor(0.38, 0.38, 0.38, 0.6)
        abilityIcon.iconTexture:SetDesaturated(true)
        abilityIcon.modifierTexture:SetTexture(nil)        
        abilityIcon.cooldownShadow:Hide()
        abilityIcon.cooldownText:SetText("")
        abilityIcon:SetScript("OnEnter", function(self) end)
        return
    end


    
    -- Icon texture
    if icon then
        abilityIcon.iconTexture:SetVertexColor(1, 1, 1, 1)
        abilityIcon.iconTexture:SetTexCoord(0, 1, 0, 1)
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

