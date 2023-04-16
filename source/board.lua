local pd <const> = playdate
local gfx <const> = pd.graphics

import "cell"
import "util/cellImages"

class('Board').extends(gfx.sprite)

Board.size = Cell.size * 9 + 8 + 6

function Board:init(x, y, puzzlePath)
    rawPuzzle = json.decodeFile(puzzlePath)

    self.selectedRow = 1
    self.selectedColumn = 1

    -- self.cells = {}
    -- for i = 1,9 do
    --     self.cells[i] = {}
    --     for j = 1,9 do
    --         local value = rawPuzzle[i][j]
    --         if value ~= 0 then
    --             self.cells[i][j] = Cell(i, j, value, true)
    --         else
    --             self.cells[i][j] = Cell(i, j, nil, false)
    --         end
    --     end
    -- end

    self:setCenter(0, 0)
    self:moveTo(x, y)
    self:add()
end

function Board:update()
    local valueChanged = false
    -- if pd.buttonJustPressed(pd.kButtonA) then
    --     valueChanged = self.cells[row][column]:incrementValue()
    -- elseif pd.buttonJustPressed(pd.kButtonB) then
    --     valueChanged = self.cells[row][column]:decrementValue()
    -- elseif pd.buttonJustPressed(pd.kButtonUp) then
    --     self.gridview:selectPreviousRow(true, false, false)
    -- elseif pd.buttonJustPressed(pd.kButtonDown) then
    --     self.gridview:selectNextRow(true, false, false)
    -- elseif pd.buttonJustPressed(pd.kButtonLeft) then
    --     self.gridview:selectPreviousColumn(true, false, false)
    -- elseif pd.buttonJustPressed(pd.kButtonRight) then
    --     self.gridview:selectNextColumn(true, false, false)
    -- end

    -- if valueChanged then
    --     print(self:isSolved())
    -- end

    local gridviewImage = gfx.image.new(Board.size, Board.size)
    gfx.pushContext(gridviewImage)
        gfx.setLineWidth(3)
        gfx.setStrokeLocation(gfx.kStrokeInside)
        gfx.drawRect(0, 0, Board.size, Board.size)
    gfx.popContext()

    self:setImage(gridviewImage)
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
