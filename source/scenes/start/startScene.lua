local pd <const> = playdate
local gfx <const> = pd.graphics

import "header"
import "helperText"
import "menuItems"

class("StartScene").extends()

StartScene.menuWidth = 150
StartScene.menuItemHeight = 33
StartScene.menuItemPadding = 4
StartScene.headerX = 95

function StartScene:enter(sceneManager)
    self.sceneManager = sceneManager

    self.helperText = HelperText()

    local saveData = pd.datastore.read()
    if not saveData then
        error("No save data found")
    end

    local screenHeight = pd.display.getHeight()
    local screenWidth = pd.display.getWidth()

    Header(StartScene.headerX)

    self.mainMenuItems = {}
    self.puzzleMenuItems = {}
    self.difficultyMenuItems = {}
    for _, difficulty in ipairs(DIFFICULTIES) do
        self.puzzleMenuItems[difficulty] = {}
    end

    for i = 1, NUM_PUZZLES do
        for _, difficulty in ipairs(DIFFICULTIES) do
            local puzzleState = saveData["puzzles"][difficulty][i]["state"]

            local puzzleMenuItem = PuzzleMenuItem(i, difficulty, puzzleState)

            table.insert(self.puzzleMenuItems[difficulty], puzzleMenuItem)
        end
    end

    for _, difficulty in ipairs(DIFFICULTIES) do
        local difficultyMenuItem = DifficultyMenuItem(difficulty)

        table.insert(self.difficultyMenuItems, difficultyMenuItem)
    end

    local selectPuzzleMenuItem = StartMenuItem("Select Puzzle")
    local difficultyMenuItems = self.difficultyMenuItems
    function selectPuzzleMenuItem:AButtonUp(menu)
        menu:pushMenuItems(difficultyMenuItems)
    end

    table.insert(self.mainMenuItems, selectPuzzleMenuItem)
    table.insert(self.mainMenuItems, StartMenuItem("Tutorial"))

    if saveData["lastPlayed"] then
        local continuePuzzleMenuItem = StartMenuItem("Continue Puzzle")
        function continuePuzzleMenuItem:AButtonUp()
            local difficulty = saveData["lastPlayed"]["difficulty"]
            local number = saveData["lastPlayed"]["number"]
            sceneManager:enter("game", difficulty, number)
        end

        table.insert(self.mainMenuItems, 1, continuePuzzleMenuItem)
    end

    local menuHeight = screenHeight - 20

    local menuX = (screenWidth - StartScene.menuWidth) - 35
    local menuY = (screenHeight - menuHeight) / 2

    self.menu = Menu(self.mainMenuItems, self, menuX, menuY, StartScene.menuWidth, menuHeight, StartScene.menuItemHeight,
        StartScene.menuItemPadding)
    self.menu:hook({
        "AButtonHeld",
        "AButtonUp",
        "BButtonUp",
    })
end

function StartScene:leave()
    gfx.sprite.removeAll()

    local allTimers = pd.timer.allTimers()
    if not allTimers then
        return
    end

    for _, timer in ipairs(allTimers) do
        timer:remove()
    end
end

function StartScene:upButtonDown()
    self.menu:upButtonDown()
end

function StartScene:upButtonUp()
    self.menu:upButtonUp()
end

function StartScene:downButtonDown()
    self.menu:downButtonDown()
end

function StartScene:downButtonUp()
    self.menu:downButtonUp()
end

function StartScene:AButtonUp()
    self.menu:AButtonUp()
end

function StartScene:BButtonUp()
    self.menu:BButtonUp()
end

function StartScene:AButtonHeld()
    self.menu:AButtonHeld()
end

function StartScene:MenuItemAButtonUp(menuItem, menu)
    if menuItem:isa(DifficultyMenuItem) then
        self.helperText:add()
        menu:pushMenuItems(self.puzzleMenuItems[menuItem.difficulty])
    elseif menuItem:isa(PuzzleMenuItem) then
        if menuItem.puzzleState == "completed" then
            return
        end
        if menuItem.ignoreNext then
            menuItem.ignoreNext = nil
            return
        end
        self.sceneManager:enter("game", menuItem.puzzleDifficulty, menuItem.puzzleNumber)
    end
end

function StartScene:MenuItemBButtonUp(menuItem)
    if menuItem:isa(PuzzleMenuItem) then
        self.helperText:remove()
    end
end

function StartScene:MenuItemAButtonHeld(menuItem)
    if menuItem:isa(PuzzleMenuItem) then
        local isLastPlayed = isLastPlayed(menuItem.puzzleDifficulty, menuItem.puzzleNumber)
        if isLastPlayed then
            table.remove(self.mainMenuItems, 1)
        end
    end
end
