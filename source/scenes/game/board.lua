local pd <const> = playdate
local gfx <const> = pd.graphics

import "cell"
import "util/boardImage"

class("Board").extends(gfx.sprite)

Board.size = Cell.size * 9 + 12
Board.image = getBoardImage(Board.size, Cell.size)

function Board:init(x, y, puzzlePath)
    rawPuzzle = json.decodeFile(puzzlePath)

    self.selRow = 1
    self.selColumn = 1

    self.cells = {}
    for row = 1,9 do
        self.cells[row] = {}
        for column = 1,9 do
            local value = rawPuzzle[row][column]
            local offsetX = x + 2 + (column - 1) * (Cell.size + 1)
            local offsetY = y + 2 + (row - 1) * (Cell.size + 1)
            if value ~= 0 then
                self.cells[row][column] = Cell(offsetX, offsetY, value, true)
            else
                self.cells[row][column] = Cell(offsetX, offsetY, nil, false)
            end
        end
    end

    self.cells[self.selRow][self.selColumn]:setSelected()

    self:setCenter(0, 0)
    self:setImage(Board.image)
    self:moveTo(x, y)
    self:add()
end

function Board:selectNextRow()
    self.cells[self.selRow][self.selColumn]:setUnselected()
    if self.selRow == 9 then
        self.selRow = 0
    else
        self.selRow += 1
    end
    self.cells[self.selRow][self.selColumn]:setSelected()
end

function Board:selectNextRow()
    self.cells[self.selRow][self.selColumn]:setUnselected()
    if self.selRow == 9 then
        self.selRow = 1
    else
        self.selRow += 1
    end
    self.cells[self.selRow][self.selColumn]:setSelected()
end

function Board:selectPrevRow()
    self.cells[self.selRow][self.selColumn]:setUnselected()
    if self.selRow == 1 then
        self.selRow = 9
    else
        self.selRow -= 1
    end
    self.cells[self.selRow][self.selColumn]:setSelected()
end

function Board:selectNextColumn()
    self.cells[self.selRow][self.selColumn]:setUnselected()
    if self.selColumn == 9 then
        self.selColumn = 1
    else
        self.selColumn += 1
    end
    self.cells[self.selRow][self.selColumn]:setSelected()
end

function Board:selectPrevColumn()
    self.cells[self.selRow][self.selColumn]:setUnselected()
    if self.selColumn == 1 then
        self.selColumn = 9
    else
        self.selColumn -= 1
    end
    self.cells[self.selRow][self.selColumn]:setSelected()
end

function Board:incrementSelectedCell()
    local valueChanged = self.cells[self.selRow][self.selColumn]:incrementValue()
    if valueChanged then
        print(self:isSolved())
    end
end

function Board:decrementSelectedCell()
    local valueChanged = self.cells[self.selRow][self.selColumn]:decrementValue()
    if valueChanged then
        print(self:isSolved())
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
    for i = 1,9 do
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
