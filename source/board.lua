local pd <const> = playdate
local gfx <const> = pd.graphics

import "cell"

class('Board').extends(gfx.sprite)

function Board:init()
    self.gridview = pd.ui.gridview.new(23, 23)
    self.gridview.changeRowOnColumnWrap = false
    self.gridview:setNumberOfColumns(9)
    self.gridview:setNumberOfRows(9)

    self.cells = {}
    for i = 1,9 do
        self.cells[i] = {}
        for j = 1,9 do
            self.cells[i][j] = Cell(i, j, j)
        end
    end

    local cells = self.cells
    function self.gridview:drawCell(section, row, column, selected, x, y, width, height)
        local bottomLine = {x, y + height - 1, x + width, y + height - 1}
        local rightLine = {x + width - 1, y, x + width - 1, y + height}

        gfx.setLineWidth(3)

        if (row % 3) == 0 and row ~= 9 then
            gfx.drawLine(table.unpack(bottomLine))
        end
        if (column % 3) == 0 and column ~= 9 then
            gfx.drawLine(table.unpack(rightLine))
        end

        gfx.setLineWidth(1)

        if (row % 3) ~= 0 then
            gfx.drawLine(table.unpack(bottomLine))
        end
        if (column % 3) ~= 0 then
            gfx.drawLine(table.unpack(rightLine))
        end

        local pad = 2
        if selected then
            gfx.fillRect(x + pad, y + pad, width - pad * 2 - 1, height - pad * 2 - 1)
        end

        local value = cells[row][column]:getStringValue()
        local valueImage = gfx.image.new(gfx.getTextSize(value))
        gfx.pushContext(valueImage)
            if selected then
                gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
            end
            gfx.drawText(value, 0, 0)
        gfx.popContext()

        local textScale = 2

        imageX, imageY = valueImage:getSize()
        scaledX = imageX * textScale
        scaledY = imageY * textScale

        offsetX = x + (width - scaledX) / 2
        offsetY = y + (height - scaledY) / 2

        valueImage:drawScaled(offsetX - 1, offsetY - 1, textScale)
    end

    self:setCenter(0, 0)
    self:moveTo(20, 15)
    self:add()
end

function Board:update()
    if pd.buttonJustPressed(pd.kButtonUp) then
        self.gridview:selectPreviousRow(true)
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        self.gridview:selectNextRow(true)
    elseif pd.buttonJustPressed(pd.kButtonLeft) then
        self.gridview:selectPreviousColumn(true)
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        self.gridview:selectNextColumn(true)
    end

    if self.gridview.needsDisplay == true then
        local gridviewImage = gfx.image.new(210, 210)
        gfx.pushContext(gridviewImage)
            gfx.setLineWidth(3)
            gfx.setStrokeLocation(gfx.kStrokeInside)
            gfx.drawRect(0, 0, 210, 210)
            self.gridview:drawInRect(2, 2, 207, 207)
        gfx.popContext()

        self:setImage(gridviewImage)
    end
end
