local pd <const> = playdate
local gfx <const> = pd.graphics

class("HelperText").extends(gfx.sprite)

function HelperText:init()
    local text = "Hold Ⓐ Reset Puzzle"
    local textWidth, textHeight = gfx.getTextSize(text)

    local image = gfx.image.new(textWidth, textHeight)

    gfx.pushContext(image)
    gfx.drawText(text, 0, 0)
    gfx.popContext()

    gfx.setFont(previousFont)

    self:setCenter(0, 0)
    self:moveTo(15, pd.display.getHeight() - 35)
    self:setImage(image)
end
