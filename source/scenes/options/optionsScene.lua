local pd <const> = playdate
local gfx <const> = pd.graphics

import "button"
import "option"
import "text"

class("OptionsScene").extends()

OptionsScene.directionMapping = {
    dots = {
        right = "numbers",
        down = "cancel",
    },
    numbers = {
        left = "dots",
        down = "save",
    },
    cancel = {
        right = "save",
        up = "dots",
    },
    save = {
        left = "cancel",
        up = "numbers",
    },
}

--- Enters the options scene
--- @param sceneManager table The scene manager
function OptionsScene:enter(sceneManager)
    self.sceneManager = sceneManager
    self.selected = "dots"
    local areNumberAnnotationsEnabled = getAreNumberAnnotationsEnabled()
    --- @type "dots"|"numbers"
    self.annotationChecked = areNumberAnnotationsEnabled and "numbers" or "dots"

    self:setUpComponents()

    local directions = {
        "up",
        "down",
        "left",
        "right",
    }
    for _, v in ipairs(directions) do
        local downHandler = v .. "ButtonDown"
        self[downHandler] = function()
            local next = OptionsScene.directionMapping[self.selected][v]
            if not next then return end
            self[self.selected]:setUnselected()
            self[next]:setSelected()
            self.selected = next
        end
    end
end

--- Sets up the components
function OptionsScene:setUpComponents()
    local text = Text("Display annotations as dots or numbers")
    local screenWidth = pd.display.getWidth()
    local textWidth = text:getSize()
    text:moveTo((screenWidth - textWidth) / 2, 30)
    local spacing = 25
    local startingOptionOffset = (screenWidth - (Option.width * 2) - spacing) / 2
    self.dots = Option("Dots", true, self.annotationChecked == "dots")
    self.dots:moveTo(startingOptionOffset, 60)
    self.numbers = Option("Numbers", false, self.annotationChecked == "numbers")
    self.numbers:moveTo(startingOptionOffset + Option.width + spacing, 60)
    local startingButtonOffset = (screenWidth - (Button.width * 2) - spacing) / 2
    self.cancel = Button("Cancel", false)
    self.cancel:moveTo(startingButtonOffset, 180)
    self.save = Button("Save", false)
    self.save:moveTo(startingButtonOffset + Button.width + spacing, 180)
end

--- Leaves the options scene
function OptionsScene:leave()
    gfx.sprite.removeAll()
end

function OptionsScene:AButtonUp()
    if self.selected == "cancel" then
        self.sceneManager:enter("start")
    elseif self.selected == "save" then
        local areNumberAnnotationsEnabled = self.annotationChecked == "numbers"
        setAreNumberAnnotationsEnabled(areNumberAnnotationsEnabled)
        self.sceneManager:enter("start")
    elseif self.selected ~= self.annotationChecked then
        self[self.selected]:setChecked()
        self[self.annotationChecked]:setUnchecked()
        self.annotationChecked = self.selected
    end
end
