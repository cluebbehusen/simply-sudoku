local pd <const> = playdate
local gfx <const> = pd.graphics

function getImageKey(specified, value)
    local specifiedString = specified and "specified" or "unspecified"
    if value then
        local valueString = tostring(value)
        return specifiedString.."-"..valueString
    end
    return specifiedString
end

local function getCellImageWrapper(cellSize)
    return function (specified, value)
        local image = gfx.image.new(cellSize, cellSize)

        gfx.pushContext(image)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, cellSize, cellSize)

        if value then
            local valueString = specified and "*"..tostring(value).."*" or tostring(value)
            local textWidth, textHeight = gfx.getTextSize(valueString)
            local offsetX = (cellSize - textWidth - 1) / 2
            local offsetY = (cellSize - textHeight - 1) / 2

            gfx.drawText(valueString, offsetX, offsetY)
        end
        gfx.popContext()

        return image
    end
end

function getCellImages(cellSize)
    local images = {}
    local getCellImage = getCellImageWrapper(cellSize)

    for i = 1,9 do
        images[getImageKey(true, i)] = getCellImage(true, i)
        images[getImageKey(false, i)] = getCellImage(false, i)
    end
    images[getImageKey(true)] = getCellImage(true)
    images[getImageKey(false)] = getCellImage(false)

    return images
end

