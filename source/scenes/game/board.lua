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

    local puzzleSaveData = saveData["puzzles"][self.puzzleDifficulty][self.puzzleNumber]

    local progress = puzzleSaveData["progress"]
    local puzzleAnnotations = puzzleSaveData["annotations"]

    self.selRow = 1
    self.selColumn = 1

    self.cells = {}
    for row = 1, 9 do
        self.cells[row] = {}
        for column = 1, 9 do
            local specifiedValue = rawPuzzle[row][column]
            local progressValue = progress and progress[row][column] or nil
            if progressValue == 0 then
                progressValue = nil
            end
            local annotations = puzzleAnnotations[row .. '-' .. column]

            local offsetX = x + 2 + (column - 1) * (Cell.size + 1)
            local offsetY = y + 2 + (row - 1) * (Cell.size + 1)
            if specifiedValue ~= 0 then
                self.cells[row][column] = Cell(offsetX, offsetY, specifiedValue, true)
            else
                self.cells[row][column] = Cell(offsetX, offsetY, progressValue, false, annotations)
            end
        end
    end

    self.cells[self.selRow][self.selColumn]:setSelected()

    self:setCenter(0, 0)
    self:setImage(pd.datastore.readImage("board"))
    self:moveTo(x, y)
    self:add()
end

function Board:BButtonDown()
    if self.cells[self.selRow][self.selColumn].value then
        return
    end
    if self.cells[self.selRow][self.selColumn]:isAnnotating() then
        self.cells[self.selRow][self.selColumn]:unsetAnnotating()
    else
        self.cells[self.selRow][self.selColumn]:setAnnotating()
    end
end

function Board:AButtonDown()
    if self.cells[self.selRow][self.selColumn]:isAnnotating() then
        self.cells[self.selRow][self.selColumn]:flipSelectedAnnotation()
    else
        self:incrementSelectedCell()
    end
end

function Board:upButtonDown()
    if self.cells[self.selRow][self.selColumn]:isAnnotating() then
        self.cells[self.selRow][self.selColumn]:selectPrevAnnotationRow()
    else
        self:selectPrevRow()
    end
end

function Board:downButtonDown()
    if self.cells[self.selRow][self.selColumn]:isAnnotating() then
        self.cells[self.selRow][self.selColumn]:selectNextAnnotationRow()
    else
        self:selectNextRow()
    end
end

function Board:rightButtonDown()
    if self.cells[self.selRow][self.selColumn]:isAnnotating() then
        self.cells[self.selRow][self.selColumn]:selectNextAnnotationColumn()
    else
        self:selectNextColumn()
    end
end

function Board:leftButtonDown()
    if self.cells[self.selRow][self.selColumn]:isAnnotating() then
        self.cells[self.selRow][self.selColumn]:selectPrevAnnotationColumn()
    else
        self:selectPrevColumn()
    end
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
    puzzleData["annotations"] = {}
    for row = 1, 9 do
        puzzleData["progress"][row] = {}
        for column = 1, 9 do
            local currentCell = self.cells[row][column]

            local value = currentCell.value
            if not value then
                value = 0
            end

            puzzleData["progress"][row][column] = value

            if not currentCell.specified and not currentCell.value then
                local cellAnnotationKey = row .. '-' .. column
                puzzleData["annotations"][cellAnnotationKey] = currentCell.annotations
            end
        end
    end
    pd.datastore.write(saveData)
end
