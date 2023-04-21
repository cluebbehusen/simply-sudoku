local pd <const> = playdate
local gfx <const> = pd.graphics

class("SceneManager").extends()

function SceneManager:init(startScene)
    self.scene = startScene
    self:emit("enter", nil)
end

function SceneManager:emit(event, ...)
    if self.scene[event] then
        self.scene[event](self.scene, ...)
    end
end

function SceneManager:enter(nextScene, ...)
    local previousScene = self.scene
    self:emit("leave", nextScene, ...)
    self.scene = nextScene
    self:emit("enter", previousScene, ...)
end

function SceneManager:hook(handlersToInclude)
    pd.inputHandlers.pop()
    local handlers = {}
    for _, v in pairs(handlersToInclude) do
        handlers[v] = function(...) self:emit(v, ...) end
    end
    pd.inputHandlers.push(handlers, false)
end
