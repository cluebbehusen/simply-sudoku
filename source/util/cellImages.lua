local pd <const> = playdate
local gfx <const> = pd.graphics

local function getValueImages()
    local valueImages = {
        selected = {},
        unselected = {},
    }

    for i = 1,9 do
        local value = tostring(i)

        local selectedImage = gfx.image.new(gfx.getTextSize(value))
        gfx.pushContext(selectedImage)
            gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
            gfx.drawText(value, 0, 0)
        gfx.popContext()
        valueImages.selected[i] = selectedImage

        local unselectedImage = gfx.image.new(gfx.getTextSize(value))
        gfx.pushContext(unselectedImage)
            gfx.drawText(value, 0, 0)
        gfx.popContext()
        valueImages.unselected[i] = unselectedImage
    end

    return valueImages
end

local function getCellImageWrapper(cellSize, textScale)
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
                scaledX = imageX * textScale
                scaledY = imageY * textScale

                offsetX = (cellSize - scaledX) / 2
                offsetY = (cellSize - scaledY) / 2

                valueImage:drawScaled(offsetX - 1, offsetY - 1, textScale)
            end
        gfx.popContext()

        return image
    end
end

function getCellImages(cellSize, textScale)
    local images = {
        selected = {
            standard = {},
            rightEdge = {},
            bottomEdge = {},
            corner = {},
        },
        unselected = {
            standard = {},
            rightEdge = {},
            bottomEdge = {},
            corner = {},
        }
    }
    local getCellImage = getCellImageWrapper(cellSize, textScale)
    local valueImages = getValueImages()

    for i = 1,9 do
        images.selected.standard[i] = getCellImage(false, false, true, valueImages.selected[i])
        images.unselected.standard[i] = getCellImage(false, false, false, valueImages.unselected[i])

        images.selected.rightEdge[i] = getCellImage(true, false, true, valueImages.selected[i])
        images.unselected.rightEdge[i] = getCellImage(true, false, false, valueImages.unselected[i])

        images.selected.bottomEdge[i] = getCellImage(false, true, true, valueImages.selected[i])
        images.unselected.bottomEdge[i] = getCellImage(false, true, false, valueImages.unselected[i])

        images.selected.corner[i] = getCellImage(true, true, true, valueImages.selected[i])
        images.unselected.corner[i] = getCellImage(true, true, false, valueImages.unselected[i])
    end

    images.selected.standard.blank = getCellImage(false, false, true)
    images.unselected.standard.blank = getCellImage(false, false, false)

    images.selected.rightEdge.blank = getCellImage(true, false, true)
    images.unselected.rightEdge.blank = getCellImage(true, false, false)

    images.selected.bottomEdge.blank = getCellImage(false, true, true)
    images.unselected.bottomEdge.blank = getCellImage(false, true, false)

    images.selected.corner.blank = getCellImage(true, true, true)
    images.unselected.corner.blank = getCellImage(true, true, false)

    return images
end
