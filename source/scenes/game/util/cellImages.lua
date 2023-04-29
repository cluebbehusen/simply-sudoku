local pd <const> = playdate
local gfx <const> = pd.graphics

function getImageName(selected, specified, value)
    local selectedString = selected and "selected" or "unselected"
    local specifiedString = specified and "specified" or "unspecified"
    if value ~= nil then
        local valueString = tostring(value)
        return selectedString.."-"..specifiedString.."-"..valueString
    end
    return selectedString.."-"..specifiedString
end

local function getCellImageWrapper(cellSize)
    return function (selected, specified, value)
        local image = gfx.image.new(cellSize, cellSize)

        gfx.pushContext(image)
        if selected then
            gfx.fillRect(0, 0, cellSize, cellSize)
            gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
        end

        if value ~= nil then
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

local function valuesGenWrapper(choices, n)
    local function valuesGen(accum)
        if #accum == n then
            coroutine.yield(accum)
        else
            for i, v in ipairs(choices) do
                local updatedAccum = {table.unpack(accum)}
                table.insert(updatedAccum, v)
                valuesGen(updatedAccum)
            end
        end
    end

    return valuesGen
end

local function values(choices, n)
    local valuesGen = valuesGenWrapper(choices, n)

    return coroutine.wrap(function() valuesGen({}) end)
end

function getCellImages(cellSize)
    local images = {}
    local getCellImage = getCellImageWrapper(cellSize)

    for value in values({true, false}, 2) do
        for i = 1,9 do
            images[getImageName(value[1], value[2], i)] = getCellImage(value[1], value[2], i)
        end
        images[getImageName(value[1], value[2])] = getCellImage(value[1], value[2])
    end

    return images
end

