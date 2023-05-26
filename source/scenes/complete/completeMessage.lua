local pd <const> = playdate
local gfx <const> = pd.graphics

class("CompleteMessage").extends(gfx.sprite)

function CompleteMessage:init()
    local previousFont = gfx.getFont()

    gfx.setFont(gfx.font.new("fonts/systemBig"))

    local mainText = "Puzzle\nComplete!"
    local mainTextWidth, mainTextHeight = gfx.getTextSize(mainText)

    local mainTextImage = gfx.image.new(mainTextWidth, mainTextHeight)

    gfx.pushContext(mainTextImage)
    gfx.drawTextAligned(mainText, mainTextWidth / 2, 0, kTextAlignment.center)
    gfx.popContext()

    gfx.setFont(gfx.font.new("fonts/system"))

    local subText = "Ⓐ Main Menu"
    local subTextWidth, subTextHeight = gfx.getTextSize(subText)

    local subTextImage = gfx.image.new(subTextWidth, subTextHeight)

    gfx.pushContext(subTextImage)
    gfx.drawText(subText, 0, 0)
    gfx.popContext()

    gfx.setFont(previousFont)

    local image = gfx.image.new(mainTextWidth, mainTextHeight + subTextHeight + 20)

    gfx.pushContext(image)
    mainTextImage:draw(0, 0)
    subTextImage:draw((mainTextWidth - subTextWidth) / 2, mainTextHeight + 20)
    gfx.popContext()

    self:moveTo(pd.display.getWidth() / 2, pd.display.getHeight() / 2)
    self:setImage(image)
    self:add()
end
