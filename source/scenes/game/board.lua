local pd <const> = playdate
local gfx <const> = pd.graphics

import "cell"
import "util/boardImage"

class("Board").extends(gfx.sprite)

Board.size = Cell.size * 9 + 12

writeBoardImage(Board.size, Cell.size)

function Board:init(x, y, puzzleDifficulty, puzzleNumber)
    local rawPuzzles = json.decodeFile("puzzles/" .. puzzleDifficulty .. ".json")
    local rawPuzzle = rawPuzzles[puzzleNumber]["puzzle"]
    self.solution = rawPuzzles[puzzleNumber]["solution"]

    self.selRow = 1
    self.selColumn = 1

    self.cells = {}
    for row = 1, 9 do
        self.cells[row] = {}
        for column = 1, 9 do
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
    self:setImage(pd.datastore.readImage("board"))
    self:moveTo(x, y)
    self:add()
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

function Board:isSolved()
    for row = 1, 9 do
        for column = 1, 9 do
            if self.cells[row][column].value ~= self.solution[row][column] then
                return false
            end
        end
    end
    return true
end
