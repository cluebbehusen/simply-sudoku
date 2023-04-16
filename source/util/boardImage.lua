local pd <const> = playdate
local gfx <const> = pd.graphics

function getBoardImage(boardSize, cellSize)
    local image = gfx.image.new(boardSize + 2, boardSize + 2)

    gfx.pushContext(image)
        for i = 1,8 do
            local offset = 1 + i * (cellSize + 1)
            if i % 3 == 0 then
                gfx.setLineWidth(3)
            else
                gfx.setLineWidth(1)
            end
            gfx.drawLine(0, offset, boardSize, offset)
            gfx.drawLine(offset, 0, offset, boardSize)
        end

        gfx.setLineWidth(3)
        gfx.drawRect(1, 1, boardSize, boardSize)
    gfx.popContext()

    return image
end
