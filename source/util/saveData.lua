local pd <const> = playdate

local function instantiateSaveData()
    local saveData = {
        lastPlayed = nil,
        puzzles = {}
    }

    for _, difficulty in ipairs(DIFFICULTIES) do
        saveData["puzzles"][difficulty] = {}
    end

    for i = 1, NUM_PUZZLES do
        for _, difficulty in ipairs(DIFFICULTIES) do
            saveData["puzzles"][difficulty][i] = {
                time = nil,
                state = "not-started",
                progress = nil,
                annotations = {}
            }
        end
    end

    pd.datastore.write(saveData)
end


function maybeInstantiateSaveData()
    local saveData = pd.datastore.read()

    if not saveData then
        instantiateSaveData()
    end
end
