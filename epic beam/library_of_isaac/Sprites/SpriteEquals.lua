function TSIL.Sprites.TexelEquals(sprite1, sprite2, position, layer)
    local kColor1 = sprite1:GetTexel(position, Vector.Zero, 1, layer)
    local kColor2 = sprite2:GetTexel(position, Vector.Zero, 1, layer)

    return kColor1.Alpha == kColor2.Alpha and
    kColor1.Blue == kColor2.Blue and
    kColor1.Green == kColor2.Green and
    kColor1.Red == kColor2.Red
end


function TSIL.Sprites.SpriteEquals(sprite1, sprite2, layer, xStart, xFinish, xIncrement, yStart, yFinish, yIncrement)
    for x = xStart, xFinish, xIncrement do
        for y = yStart, yFinish, yIncrement do
            local position = Vector(x, y)

            if not TSIL.Sprites.TexelEquals(sprite1, sprite2, position, layer) then
                return false
            end
        end
    end

    return true
end