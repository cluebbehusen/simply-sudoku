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
        valueImages.selected.given[i] = selectedInputImage

        local unselectedInputImage = gfx.image.new(gfx.getTextSize(value))
        drawTextImage(unselectedInputImage, value, false)
        valueImages.unselected.given[i] = unselectedInputImage

        local boldValue = "*"..value.."*"

        local selectedGivenImage = gfx.image.new(gfx.getTextSize(boldValue))
        drawTextImage(selectedGivenImage, boldValue, true)
        valueImages.selected.input[i] = selectedGivenImage

        local unselectedGivenImage = gfx.image.new(gfx.getTextSize(boldValue))
        drawTextImage(unselectedGivenImage, boldValue, false)
        valueImages.unselected.input[i] = unselectedGivenImage
    end

    return valueImages
end

local function getCellImageWrapper(cellSize)
    return function (edgeRight, edgeBottom, selected, valueImage)
        local image = gfx.image.new(cellSize + 1, cellSize + 1)
        gfx.pushContext(image)
            gfx.setLineWidth(3)
            if edgeBottom then
                gfx.drawLine(0, cellSize - 1, cellSize, cellSize - 1)
            end
            if edgeRight then
                gfx.drawLine(cellSize - 1, 0, cellSize - 1, cellSize)
            end

            gfx.setLineWidth(1)
            if not edgeBottom then
                gfx.drawLine(0, cellSize - 1, cellSize, cellSize - 1)
            end
            if not edgeRight then
                gfx.drawLine(cellSize - 1, 0, cellSize - 1, cellSize)
            end

            if selected then
                gfx.fillRect(0, 0, cellSize - 1, cellSize - 1)
            end

            if valueImage then
                imageX, imageY = valueImage:getSize()
                offsetX = (cellSize - imageX - 1) / 2
                offsetY = (cellSize - imageY - 1) / 2

                valueImage:draw(offsetX, offsetY)
            end
        gfx.popContext()

        return image
    end
end

function getCellImages(cellSize, textScale)
    local images = {
        selected = {
            given = {
                standard = {},
                rightEdge = {},
                bottomEdge = {},
                corner = {},
            },
            input = {
                standard = {},
                rightEdge = {},
                bottomEdge = {},
                corner = {},
            },
        },
        unselected = {
            given = {
                standard = {},
                rightEdge = {},
                bottomEdge = {},
                corner = {},
            },
            input = {
                standard = {},
                rightEdge = {},
                bottomEdge = {},
                corner = {},
            },
        }
    }
    local getCellImage = getCellImageWrapper(cellSize, textScale)
    local valueImages = getValueImages()

    for i = 1,9 do
        images.selected.input.standard[i] = getCellImage(false, false, true, valueImages.selected.input[i])
        images.unselected.input.standard[i] = getCellImage(false, false, false, valueImages.unselected.input[i])

        images.selected.input.rightEdge[i] = getCellImage(true, false, true, valueImages.selected.input[i])
        images.unselected.input.rightEdge[i] = getCellImage(true, false, false, valueImages.unselected.input[i])

        images.selected.input.bottomEdge[i] = getCellImage(false, true, true, valueImages.selected.input[i])
        images.unselected.input.bottomEdge[i] = getCellImage(false, true, false, valueImages.unselected.input[i])

        images.selected.input.corner[i] = getCellImage(true, true, true, valueImages.selected.input[i])
        images.unselected.input.corner[i] = getCellImage(true, true, false, valueImages.unselected.input[i])

        images.selected.given.standard[i] = getCellImage(false, false, true, valueImages.selected.given[i])
        images.unselected.given.standard[i] = getCellImage(false, false, false, valueImages.unselected.given[i])

        images.selected.given.rightEdge[i] = getCellImage(true, false, true, valueImages.selected.given[i])
        images.unselected.given.rightEdge[i] = getCellImage(true, false, false, valueImages.unselected.given[i])

        images.selected.given.bottomEdge[i] = getCellImage(false, true, true, valueImages.selected.given[i])
        images.unselected.given.bottomEdge[i] = getCellImage(false, true, false, valueImages.unselected.given[i])

        images.selected.given.corner[i] = getCellImage(true, true, true, valueImages.selected.given[i])
        images.unselected.given.corner[i] = getCellImage(true, true, false, valueImages.unselected.given[i])
    end

    -- It can be assumed that any blank cell is not given, so put it in input
    images.selected.input.standard.blank = getCellImage(false, false, true)
    images.unselected.input.standard.blank = getCellImage(false, false, false)

    images.selected.input.rightEdge.blank = getCellImage(true, false, true)
    images.unselected.input.rightEdge.blank = getCellImage(true, false, false)

    images.selected.input.bottomEdge.blank = getCellImage(false, true, true)
    images.unselected.input.bottomEdge.blank = getCellImage(false, true, false)

    images.selected.input.corner.blank = getCellImage(true, true, true)
    images.unselected.input.corner.blank = getCellImage(true, true, false)

    return images
end
