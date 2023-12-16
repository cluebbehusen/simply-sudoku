local pd <const> = playdate
local gfx <const> = pd.graphics

class("SceneManager").extends()

--- Creates a new scene manager
--- @param scenes table<string, table> The scenes
--- @param initialSceneKey string The initial scene key
function SceneManager:init(scenes, initialSceneKey)
    self.scenes = scenes
    self:enter(initialSceneKey)
end

--- Emits an event to the current scene
--- @param event string The event
--- @vararg any The arguments
function SceneManager:emit(event, ...)
    if self.scene and self.scene[event] then
        self.scene[event](self.scene, self, ...)
    end
end

--- Enters a new scene
--- @param nextSceneKey string The next scene key
--- @vararg any The arguments
function SceneManager:enter(nextSceneKey, ...)
    local previousScene = self.scene
    local nextScene = self.scenes[nextSceneKey]
    self:emit("leave", nextScene, ...)
    self.scene = nextScene
    self:emit("enter", previousScene, ...)
end

--- Hooks the input handlers
--- @param handlersToInclude string[] The handlers to include
function SceneManager:hook(handlersToInclude)
    pd.inputHandlers.pop()
    local handlers = {}
    for _, v in ipairs(handlersToInclude) do
        handlers[v] = function(...) self:emit(v, ...) end
    end
    pd.inputHandlers.push(handlers, false)
end

--- Emits gameWillTerminate
function SceneManager:gameWillTerminate()
    self:emit("gameWillTerminate")
end

--- Emits deviceWillSleep
function SceneManager:deviceWillSleep()
    self:emit("deviceWillSleep")
end
