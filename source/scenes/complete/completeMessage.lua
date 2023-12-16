local pd <const> = playdate
local gfx <const> = pd.graphics

class("CompleteMessage").extends(gfx.sprite)

--- Creates a new complete message
function CompleteMessage:init()
    local previousFont = gfx.getFont()

    gfx.setFont(gfx.font.new("fonts/systemBig"))

    local text = "Puzzle\nComplete!"
    local textWidth, textHeight = gfx.getTextSize(text)

    local textImage = gfx.image.new(textWidth, textHeight)

    gfx.pushContext(textImage)
    gfx.drawTextAligned(text, textWidth / 2, 0, kTextAlignment.center)
    gfx.popContext()

    gfx.setFont(previousFont)

    self:moveTo(pd.display.getWidth() / 2, pd.display.getHeight() / 2 - textHeight / 2 + 15)
    self:setImage(textImage)
    self:add()
end
