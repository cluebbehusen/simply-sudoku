local pd <const> = playdate
local gfx <const> = pd.graphics

import "cell"
import "util/cellImages"

class('Board').extends(gfx.sprite)

Board.size = 219
Board.cellSize = 24
Board.cellImages = getCellImages(Board.cellSize)

function Board:init(puzzlePath)
    self.gridview = pd.ui.gridview.new(Board.cellSize, Board.cellSize)
    self.gridview.changeRowOnColumnWrap = false
    self.gridview:setNumberOfColumns(9)
    self.gridview:setNumberOfRows(9)

    rawPuzzle = json.decodeFile(puzzlePath)

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
        value = cells[row][column].value or 'blank'
        given = cells[row][column].given
        selectedImages = selected and Board.cellImages.selected or Board.cellImages.unselected
        images = given and selectedImages.given or selectedImages.input

        image = nil
        if (row % 3) == 0 and (column % 3) == 0 then
            image = images.corner[value]
        elseif (row % 3) == 0 then
            image = images.bottomEdge[value]
        elseif (column % 3) == 0 then
            image = images.rightEdge[value]
        else
            image = images.standard[value]
        end

        image:draw(x - 1, y - 1)
    end

    self:setCenter(0, 0)
    self:moveTo(20, 10)
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
        local gridviewImage = gfx.image.new(Board.size, Board.size)
        gfx.pushContext(gridviewImage)
            gfx.setLineWidth(3)
            gfx.setStrokeLocation(gfx.kStrokeInside)
            gfx.drawRect(0, 0, Board.size, Board.size)
            self.gridview:drawInRect(3, 3, Board.size - 3, Board.size - 3)
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
