local pd <const> = playdate
local gfx <const> = pd.graphics

class("MainMenuMessage").extends(gfx.sprite)

--- Creates a new main menu message
function MainMenuMessage:init()
    local previousFont = gfx.getFont()

    gfx.setFont(gfx.font.new("fonts/system"))

    local text = "Ⓐ Main Menu"
    local textWidth, textHeight = gfx.getTextSize(text)

    local textImage = gfx.image.new(textWidth, textHeight)

    gfx.pushContext(textImage)
    gfx.drawText(text, 0, 0)
    gfx.popContext()

    gfx.setFont(previousFont)

    self:moveTo(pd.display.getWidth() / 2, pd.display.getHeight() / 2 + textHeight / 2 + 30)
    self:setImage(textImage)
end
