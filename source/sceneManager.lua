local pd <const> = playdate
local gfx <const> = pd.graphics

class("Scene").extends()

function Scene:enter()
    error("This is an abstract method. It should be implemented.")
end

function Scene:leave()
    error("This is an abstract method. It should be implemented.")
end

class("SceneManager").extends()

function SceneManager:init(startScene)
    self.scene = startScene
    self:emit("enter", nil)
end

function SceneManager:emit(event, ...)
    if self.scene[event] then
        scene[event](scene, ...)
    end
end

function SceneManager:enter(nextScene, ...)
    local previousScene = self.scene
    self:emit("leave", nextScene, ...)
    self.scene = nextScene
    self:emit("enter", previousScene, ...)
end

function SceneManager:hook(handlersToInclude)
    local handlers = {}
    for _, v in pairs(to_include) do
        handlers[v] = function(...) self:emit(v, ...) end
    end
    pd.inputHandlers.push(handlers)
end
