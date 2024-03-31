local function InitQuestionMarkSprite()
    local sprite = Sprite()
    sprite:Load("gfx/005.100_collectible.anm2", false)
    sprite:ReplaceSpritesheet(1, "gfx/items/collectibles/questionmark.png")
    sprite:LoadGraphics()

    return sprite
end

local questionMarkSprite = InitQuestionMarkSprite()


function TSIL.Collectibles.IsBlindCollectible(collectible)
    if collectible.Type ~= EntityType.ENTITY_PICKUP or
    collectible.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
        error("The IsBlindCollectible function was given a non collectible: " .. collectible.Type)
    end

    local sprite = collectible:GetSprite()
    local animation = sprite:GetAnimation()
    local frame = sprite:GetFrame()

    questionMarkSprite:SetFrame(animation, frame)

    return TSIL.Collectibles.CollectibleSpriteEquals(sprite, questionMarkSprite)
end





