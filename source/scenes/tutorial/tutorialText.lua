local pd <const> = playdate
local gfx <const> = pd.graphics

class("TutorialText").extends(gfx.sprite)

function TutorialText:init(text)
    local previousFont = gfx.getFont()

    gfx.setFont(gfx.font.new("fonts/system"))

    local textWidth, textHeight = gfx.getTextSize(text)

    local image = gfx.image.new(textWidth, textHeight)

    gfx.pushContext(image)
    gfx.drawText(text, 0, 0)
    gfx.popContext()

    gfx.setFont(previousFont)

    self:setImage(image)
    self:setCenter(0, 0)
    self:add()
end
