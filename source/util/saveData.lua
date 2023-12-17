local pd <const> = playdate

--- Instantiates the default save data when the game is first run
local function instantiateSaveData()
    local saveData = {
        lastPlayed = nil,
        puzzles = {},
        config = {
            numberAnnotations = false,
        }
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

--- Instantiates the default save data if it doesn't exist
function maybeInstantiateSaveData()
    local saveData = pd.datastore.read()

    if not saveData then
        instantiateSaveData()
    end
end

function getAreNumberAnnotationsEnabled()
    local saveData = pd.datastore.read()
    if not saveData then
        error("No save data found")
    end

    --- Handle case of old save data without config
    if not saveData["config"] then
        saveData["config"] = {
            numberAnnotations = false,
        }
        pd.datastore.write(saveData)
    end

    return saveData["config"]["numberAnnotations"]
end

function setAreNumberAnnotationsEnabled(enabled)
    local saveData = pd.datastore.read()
    if not saveData then
        error("No save data found")
    end

    saveData["config"]["numberAnnotations"] = enabled
    pd.datastore.write(saveData)
end

--- Checks if the supplied difficulty and number match the last played puzzle
--- @param difficulty string The difficulty
--- @param number number The number
function isLastPlayed(difficulty, number)
    local saveData = pd.datastore.read()
    if not saveData then
        error("No save data found")
    end

    local lastPlayed = saveData["lastPlayed"]
    if not lastPlayed then
        return false
    end

    return lastPlayed["difficulty"] == difficulty and lastPlayed["number"] == number
end

--- Resets the progress of a single puzzle
--- @param difficulty string The difficulty
--- @param number number The number
function resetPuzzle(difficulty, number)
    local saveData = pd.datastore.read()
    if not saveData then
        error("No save data found")
    end

    local puzzle = saveData["puzzles"][difficulty][number]

    puzzle["state"] = "not-started"
    puzzle["time"] = nil
    puzzle["progress"] = nil
    puzzle["annotations"] = {}

    local lastPlayed = saveData["lastPlayed"]
    if lastPlayed and lastPlayed["difficulty"] == difficulty and lastPlayed["number"] == number then
        saveData["lastPlayed"] = nil
    end

    pd.datastore.write(saveData)
end
