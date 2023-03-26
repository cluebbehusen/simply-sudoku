local pd <const> = playdate
local gfx <const> = pd.graphics

import "cell"

local unselectedImages = {}
local selectedImages = {}
for i = 1,9 do
    local value = tostring(i)

    local selectedImage = gfx.image.new(gfx.getTextSize(value))
    gfx.pushContext(selectedImage)
        gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
        gfx.drawText(value, 0, 0)
    gfx.popContext()
    selectedImages[i] = selectedImage

    local unselectedImage = gfx.image.new(gfx.getTextSize(value))
    gfx.pushContext(unselectedImage)
        gfx.drawText(value, 0, 0)
    gfx.popContext()
    unselectedImages[i] = unselectedImage
end

class('Board').extends(gfx.sprite)

function Board:init(puzzlePath)
    self.gridview = pd.ui.gridview.new(23, 23)
    self.gridview.changeRowOnColumnWrap = false
    self.gridview:setNumberOfColumns(9)
    self.gridview:setNumberOfRows(9)

    rawPuzzle = json.decodeFile('puzzles/1.json')

    self.cells = {}
    for i = 1,9 do
        self.cells[i] = {}
        for j = 1,9 do
            local value = rawPuzzle[i][j]
            if value ~= 0 then
                self.cells[i][j] = Cell(i, j, value, true)
            else
                self.cells[i][j] = Cell(i, j, nil, false)
            end
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

        if selected then
            gfx.fillRect(x, y, width - 1, height - 1)
        end

        local value = cells[row][column].value
        if value then
            local valueImage = selected and selectedImages[value] or unselectedImages[value]

            local textScale = 2

            imageX, imageY = valueImage:getSize()
            scaledX = imageX * textScale
            scaledY = imageY * textScale

            offsetX = x + (width - scaledX) / 2
            offsetY = y + (height - scaledY) / 2

            valueImage:drawScaled(offsetX - 1, offsetY - 1, textScale)
        end
    end

    self:setCenter(0, 0)
    self:moveTo(20, 15)
    self:add()
end

function Board:update()
    local valueChanged = false
    local _, row, column = self.gridview:getSelection()
    if pd.buttonJustPressed(pd.kButtonA) then
        valueChanged = self.cells[row][column]:incrementValue()
    elseif pd.buttonJustPressed(pd.kButtonB) then
        valueChanged = self.cells[row][column]:decrementValue()
    elseif pd.buttonJustPressed(pd.kButtonUp) then
        self.gridview:selectPreviousRow(true)
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        self.gridview:selectNextRow(true)
    elseif pd.buttonJustPressed(pd.kButtonLeft) then
        self.gridview:selectPreviousColumn(true)
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        self.gridview:selectNextColumn(true)
    end

    if valueChanged then
        print(self:isSolved())
    end

    if self.gridview.needsDisplay == true or valueChanged then
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

function Board:checkRow(row)
    local values = {}
    for j = 1,9 do
        local value = self.cells[row][j].value
        if not value or values[value] then
            return false
        end
        values[value] = true
    end
    return true
end

function Board:checkColumn(column)
    local values = {}
    for i = 1, 9 do
        local value = self.cells[i][column].value
        if not value or values[value] then
            return false
        end
        values[value] = true
    end
    return true
end

function Board:checkBlock(blockRow, blockColumn)
    local values = {}
    local startRow = 3 * blockRow - 2
    local startColumn = 3 * blockColumn - 2
    for i = startRow, startRow + 2 do
        for j = startColumn, startColumn + 2 do
            local value = self.cells[i][j].value
            if not value or values[value] then
                return false
            end
            values[value] = true
        end
    end
    return true
end

function Board:isSolved()
    for i = 1,9 do
        if not self:checkRow(i) then
            return false
        end
    end

    for j = 1,9 do
        if not self:checkColumn(j) then
            return false
        end
    end

    for i = 1,3 do
        for j = 1,3 do
            if not self:checkBlock(i, j) then
                return false
            end
        end
    end

    return true
end
