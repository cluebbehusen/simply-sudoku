local pd <const> = playdate
local gfx <const> = pd.graphics

import "cell"
import "util/boardImage"

class("Board").extends(gfx.sprite)

Board.size = Cell.size * 9 + 12

writeBoardImage(Board.size, Cell.size)

function Board:init(x, y, puzzleDifficulty, puzzleNumber)
    self.puzzleDifficulty = puzzleDifficulty
    self.puzzleNumber = puzzleNumber

    local rawPuzzles = json.decodeFile("puzzles/" .. puzzleDifficulty .. ".json")
    local rawPuzzle = rawPuzzles[puzzleNumber]["puzzle"]
    self.solution = rawPuzzles[puzzleNumber]["solution"]

    local saveData = pd.datastore.read()
    if not saveData then
        error("No save data found")
    end

    local progress = saveData["puzzles"][self.puzzleDifficulty][self.puzzleNumber]["progress"]

    self.selRow = 1
    self.selColumn = 1

    self.cells = {}
    for row = 1, 9 do
        self.cells[row] = {}
        for column = 1, 9 do
            local value = rawPuzzle[row][column]
            local progressValue = progress and progress[row][column] or 0
            local offsetX = x + 2 + (column - 1) * (Cell.size + 1)
            local offsetY = y + 2 + (row - 1) * (Cell.size + 1)
            if value ~= 0 then
                self.cells[row][column] = Cell(offsetX, offsetY, value, true)
            elseif progressValue ~= 0 then
                self.cells[row][column] = Cell(offsetX, offsetY, progressValue, false)
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

function Board:save()
    local saveData = pd.datastore.read()
    if not saveData then
        error("No save data found")
    end

    saveData["lastPlayed"] = {
        ["difficulty"] = self.puzzleDifficulty,
        ["number"] = self.puzzleNumber
    }

    local puzzleData = saveData["puzzles"][self.puzzleDifficulty][self.puzzleNumber]
    puzzleData["state"] = "in-progress"
    puzzleData["progress"] = {}
    for row = 1, 9 do
        puzzleData["progress"][row] = {}
        for column = 1, 9 do
            local value = self.cells[row][column].value
            if not value then
                value = 0
            end

            puzzleData["progress"][row][column] = self.cells[row][column].value
        end
    end
    pd.datastore.write(saveData)
end
