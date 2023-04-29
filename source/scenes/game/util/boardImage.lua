local pd <const> = playdate
local gfx <const> = pd.graphics

function writeBoardImage(boardSize, cellSize)
    local paddedBoardSize = boardSize - 2
    local image = gfx.image.new(boardSize, boardSize)

    gfx.pushContext(image)
    for i = 1,8 do
        local offset = 1 + i * (cellSize + 1)
        if i % 3 == 0 then
            gfx.setLineWidth(3)
        else
            gfx.setLineWidth(1)
        end
        gfx.drawLine(0, offset, paddedBoardSize, offset)
        gfx.drawLine(offset, 0, offset, paddedBoardSize)
    end

    gfx.setLineWidth(3)
    gfx.drawRect(1, 1, paddedBoardSize, paddedBoardSize)
    gfx.popContext()

    pd.datastore.writeImage(image, "board")
end
