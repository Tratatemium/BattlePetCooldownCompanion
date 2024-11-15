

function BPCC.createAuraIcon(auraIcon, auraIconName, parent, iconSize)

    auraIcon = CreateFrame("Frame", auraIconName, parent)
    auraIcon:SetSize(iconSize, iconSize)
    auraIcon:SetPoint("BOTTOMRIGHT", parent:GetName(), "BOTTOMRIGHT", 0, 0)

    auraIcon.border = auraIcon:CreateTexture(nil, "OVERLAY")
    auraIcon.border:SetTexture(130759) -- Button border texture
    auraIcon.border:SetSize(iconSize, iconSize)
    auraIcon.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    auraIcon.border:SetVertexColor(1, 0, 10, 1)
    auraIcon.border:SetPoint("CENTER", auraIconName, "CENTER", 0, 0)
    auraIcon.border:SetDrawLayer("OVERLAY", 0)

    auraIcon.iconTexture = auraIcon:CreateTexture(nil, "ARTWORK")
    auraIcon.iconTexture:SetSize(iconSize, iconSize)  -- Icon size
    auraIcon.iconTexture:SetPoint("CENTER", auraIconName, "CENTER", 0, 0)
    auraIcon.iconTexture:SetDesaturated(false)
    auraIcon.iconTexture:SetVertexColor(1, 1, 1, 1)

    auraIcon.iconTexture:SetTexture(134143)
end

