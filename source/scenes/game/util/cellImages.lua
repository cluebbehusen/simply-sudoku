local pd <const> = playdate
local gfx <const> = pd.graphics

local function getValueImages()
    local valueImages = {
        selected = {
            given = {},
            input = {}
        },
        unselected = {
            given = {},
            input = {},
        },
    }

    local function drawTextImage(image, text, white)
        gfx.pushContext(image)
            if white then
                gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
            end
            gfx.drawText(text, 0, 0)
        gfx.popContext()
    end

    for i = 1,9 do
        local value = tostring(i)

        local selectedInputImage = gfx.image.new(gfx.getTextSize(value))
        drawTextImage(selectedInputImage, value, true)
        valueImages.selected.input[i] = selectedInputImage

        local unselectedInputImage = gfx.image.new(gfx.getTextSize(value))
        drawTextImage(unselectedInputImage, value, false)
        valueImages.unselected.input[i] = unselectedInputImage

        local boldValue = "*"..value.."*"

        local selectedGivenImage = gfx.image.new(gfx.getTextSize(boldValue))
        drawTextImage(selectedGivenImage, boldValue, true)
        valueImages.selected.given[i] = selectedGivenImage

        local unselectedGivenImage = gfx.image.new(gfx.getTextSize(boldValue))
        drawTextImage(unselectedGivenImage, boldValue, false)
        valueImages.unselected.given[i] = unselectedGivenImage
    end

    return valueImages
end

local function getCellImageWrapper(cellSize)
    return function (selected, valueImage)
        local image = gfx.image.new(cellSize, cellSize)
        gfx.pushContext(image)
            if selected then
                gfx.fillRect(0, 0, cellSize, cellSize)
            end

            if valueImage then
                local imageX, imageY = valueImage:getSize()
                local offsetX = (cellSize - imageX - 1) / 2
                local offsetY = (cellSize - imageY - 1) / 2

                valueImage:draw(offsetX, offsetY)
            end
        gfx.popContext()

        return image
    end
end

function getCellImages(cellSize)
    local images = {
        selected = {
            given = {},
            input = {},
        },
        unselected = {
            given = {},
            input = {},
        }
    }
    local getCellImage = getCellImageWrapper(cellSize)
    local valueImages = getValueImages()

    for i = 1,9 do
        images.selected.input[i] = getCellImage(true, valueImages.selected.input[i])
        images.unselected.input[i] = getCellImage(false, valueImages.unselected.input[i])

        images.selected.given[i] = getCellImage(true, valueImages.selected.given[i])
        images.unselected.given[i] = getCellImage(false, valueImages.unselected.given[i])
    end

    -- It can be assumed that any blank cell is not given, so put it in input
    images.selected.input.blank = getCellImage(true)
    images.unselected.input.blank = getCellImage(false)

    return images
end
