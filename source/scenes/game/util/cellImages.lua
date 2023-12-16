local pd <const> = playdate
local gfx <const> = pd.graphics

--- Creates a string key for a cell image
--- @param specified boolean Whether the cell has a specified (given) value
--- @param value? number The value of the cell
--- @return string key The key
function getCellImageKey(specified, value)
    local specifiedString = specified and "specified" or "unspecified"
    if value then
        local valueString = tostring(value)
        return specifiedString .. "-" .. valueString
    end
    return specifiedString
end

--- Creates a function that returns a cell image based on size
--- @param cellSize number The size of the cell
--- @return function getCellImage The function that returns a cell image
local function getCellImageWrapper(cellSize)
    return function(specified, value)
        local image = gfx.image.new(cellSize, cellSize)

        gfx.pushContext(image)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, cellSize, cellSize)

        if value then
            local valueString = specified and "*" .. tostring(value) .. "*" or tostring(value)
            local textWidth, textHeight = gfx.getTextSize(valueString)
            local offsetX = (cellSize - textWidth - 1) / 2
            local offsetY = (cellSize - textHeight - 1) / 2

            gfx.drawText(valueString, offsetX, offsetY)
        end
        gfx.popContext()

        return image
    end
end

--- Creates a table of cell images for faster loading later
--- @param cellSize number The size of the cell
--- @return table images The table of cell images
function getCellImages(cellSize)
    local previousFont = gfx.getFont()

    local fontPaths = {
        [gfx.font.kVariantNormal] = "fonts/normalNumbers",
        [gfx.font.kVariantBold] = "fonts/boldNumbers",
    }
    local fontFamily = gfx.font.newFamily(fontPaths)
    gfx.setFontFamily(fontFamily)

    local images = {}
    local getCellImage = getCellImageWrapper(cellSize)

    for i = 1, 9 do
        images[getImageKey(true, i)] = getCellImage(true, i)
        images[getImageKey(false, i)] = getCellImage(false, i)
    end
    images[getImageKey(true)] = getCellImage(true)
    images[getImageKey(false)] = getCellImage(false)

    gfx.setFont(previousFont)

    return images
end
