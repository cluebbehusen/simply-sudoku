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

--- Enters the start scene
--- @param sceneManager table The scene manager
function StartScene:enter(sceneManager)
    self.sceneManager = sceneManager

    self.helperText = HelperText()

    local screenHeight = pd.display.getHeight()
    local screenWidth = pd.display.getWidth()

    Header(StartScene.headerX)

    self:setupMenuItems()

    local menuHeight = screenHeight - 20

    local menuX = (screenWidth - StartScene.menuWidth) - 35
    local menuY = (screenHeight - menuHeight) / 2

    self.menu = Menu(self.mainMenuItems, menuX, menuY, StartScene.menuWidth, menuHeight, StartScene.menuItemHeight,
        StartScene.menuItemPadding)
    self.menu:hook({
        "AButtonHeld",
        "AButtonUp",
        "BButtonUp",
    })

    local handlers = {
        "upButtonDown",
        "upButtonUp",
        "downButtonDown",
        "downButtonUp",
        "AButtonUp",
        "BButtonUp",
        "AButtonHeld",
    }
    for _, v in ipairs(handlers) do
        self[v] = function() self.menu[v](self.menu) end
    end
end

--- Leaves the start scene
function StartScene:leave()
    gfx.sprite.removeAll()
    removeAllTimers()
end

--- Generates the callbacks for a puzzle menu item
--- @param puzzleDifficulty string The puzzle difficulty
--- @param puzzleNumber number The puzzle number
function StartScene:generatePuzzleMenuItemCallbacks(puzzleDifficulty, puzzleNumber)
    local callbacks = {
        AButtonUp = function()
            if self.ignoreNextMenuPress then
                self.ignoreNextMenuPress = nil
                return
            end
            self.sceneManager:enter("game", puzzleDifficulty, puzzleNumber)
        end,
        AButtonHeld = function()
            self.ignoreNextMenuPress = true
            self:handlePuzzleReset(puzzleDifficulty, puzzleNumber)
            self.menu:forceUpdate()
        end,
        BButtonUp = function(menu)
            self.helperText:remove()
            menu:popMenuItems()
        end,
    }
    return callbacks
end

--- Resets a puzzle to its initial state
--- @param puzzleDifficulty string The puzzle difficulty
--- @param puzzleNumber number The puzzle number
function StartScene:handlePuzzleReset(puzzleDifficulty, puzzleNumber)
    local isLastPlayed = isLastPlayed(puzzleDifficulty, puzzleNumber)
    if isLastPlayed then
        table.remove(self.mainMenuItems, 1)
    end

    resetPuzzle(puzzleDifficulty, puzzleNumber)

    local callbacks = self:generatePuzzleMenuItemCallbacks(puzzleDifficulty, puzzleNumber)
    local puzzleMenuItem = PuzzleMenuItem(puzzleNumber, "not-started", callbacks)
    self.puzzleMenuItems[puzzleDifficulty][puzzleNumber] = puzzleMenuItem

    self.menu:forceUpdate()
end

--- Sets up the menu items
function StartScene:setupMenuItems()
    local saveData = pd.datastore.read()
    if not saveData then
        error("No save data found")
    end

    self.mainMenuItems = {}
    self.puzzleMenuItems = {}
    self.difficultyMenuItems = {}

    for _, difficulty in ipairs(DIFFICULTIES) do
        local callbacks = {
            AButtonUp = function(menu)
                self.helperText:add()
                menu:pushMenuItems(self.puzzleMenuItems[difficulty])
            end,
            BButtonUp = function(menu)
                menu:popMenuItems()
            end,
        }

        local difficultyMenuItem = DifficultyMenuItem(difficulty, callbacks)
        table.insert(self.difficultyMenuItems, difficultyMenuItem)

        self.puzzleMenuItems[difficulty] = {}
    end

    for i = 1, NUM_PUZZLES do
        for _, difficulty in ipairs(DIFFICULTIES) do
            local puzzleState = saveData["puzzles"][difficulty][i]["state"]
            local callbacks = self:generatePuzzleMenuItemCallbacks(difficulty, i)
            local puzzleMenuItem = PuzzleMenuItem(i, puzzleState, callbacks)
            table.insert(self.puzzleMenuItems[difficulty], puzzleMenuItem)
        end
    end

    local selectPuzzleMenuItem = StartMenuItem("Select Puzzle", {
        AButtonUp = function(menu)
            menu:pushMenuItems(self.difficultyMenuItems)
        end,
    })
    table.insert(self.mainMenuItems, selectPuzzleMenuItem)

    local tutorialMenuItem = StartMenuItem("Tutorial", {
        AButtonUp = function()
            self.sceneManager:enter("tutorial")
        end,
    })
    table.insert(self.mainMenuItems, tutorialMenuItem)

    local optionMenuItem = StartMenuItem("Options", {
        AButtonUp = function()
            self.sceneManager:enter("options")
        end,
    })
    table.insert(self.mainMenuItems, optionMenuItem)

    if saveData["lastPlayed"] then
        local callbacks = {
            AButtonUp = function()
                local difficulty = saveData["lastPlayed"]["difficulty"]
                local number = saveData["lastPlayed"]["number"]
                self.sceneManager:enter("game", difficulty, number)
            end,
        }
        local continuePuzzleMenuItem = StartMenuItem("Continue Puzzle", callbacks)
        table.insert(self.mainMenuItems, 1, continuePuzzleMenuItem)
    end
end
