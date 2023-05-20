local pd <const> = playdate
local gfx <const> = pd.graphics

class("SceneManager").extends()

function SceneManager:init(scenes, initialSceneKey)
    self.scenes = scenes
    self.scene = scenes[initialSceneKey]
    self:emit("enter", nil)
end

function SceneManager:emit(event, ...)
    if self.scene[event] then
        self.scene[event](self.scene, self, ...)
    end
end

function SceneManager:enter(nextSceneKey, ...)
    local previousScene = self.scene
    local nextScene = self.scenes[nextSceneKey]
    self:emit("leave", nextScene, ...)
    self.scene = nextScene
    self:emit("enter", previousScene, ...)
end

function SceneManager:hook(handlersToInclude)
    pd.inputHandlers.pop()
    local handlers = {}
    for _, v in ipairs(handlersToInclude) do
        handlers[v] = function(...) self:emit(v, ...) end
    end
    pd.inputHandlers.push(handlers, false)
end
