local pd <const> = playdate
local gfx <const> = pd.graphics

class("StartMenuItem").extends(MenuItem)

function StartMenuItem:init(text, callbacks)
    self.text = text
    self.callbacks = callbacks
end

function StartMenuItem:draw(selected, x, y, width, height)
    local image = gfx.image.new(width, height)

    gfx.pushContext(image)
    local textWidth, textHeight = gfx.getTextSize(self.text)
    local offsetX = (width - textWidth) / 2
    local offsetY = (height - textHeight) / 2
    if selected then
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.fillRoundRect(0, 0, width, height, 5)
    else
        gfx.drawRoundRect(0, 0, width, height, 5)
    end
    gfx.drawText(self.text, offsetX, offsetY)
    gfx.popContext()

    image:draw(x, y)
end

class("PuzzleMenuItem").extends(StartMenuItem)

function PuzzleMenuItem:init(puzzleNumber, puzzleState, callbacks)
    local text = "Puzzle " .. puzzleNumber
    if puzzleState == "in-progress" then
        text = text .. " ⏳"
    elseif puzzleState == "completed" then
        text = text .. " ⎷"
    end

    StartMenuItem.init(self, text, callbacks)
end

function PuzzleMenuItem:AButtonHeld(menu)
    resetPuzzle(self.puzzleDifficulty, self.puzzleNumber)
    self.text = "Puzzle " .. self.puzzleNumber
    self.puzzleState = "not-started"
    self.ignoreNext = true
    menu:forceUpdate()
end

class("DifficultyMenuItem").extends(StartMenuItem)

function DifficultyMenuItem:init(difficulty, callbacks)
    local text = difficulty:gsub("^%l", string.upper)

    StartMenuItem.init(self, text, callbacks)
end
