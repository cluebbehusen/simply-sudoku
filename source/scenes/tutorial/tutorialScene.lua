local pd <const> = playdate
local gfx <const> = pd.graphics

import "tutorialText"

class("TutorialScene").extends()

function TutorialScene:enter(sceneManager)
    self.sceneManager = sceneManager

    local menu = pd.getSystemMenu()
    menu:addMenuItem("main menu", function()
        sceneManager:enter("start")
    end)

    local viewMenu = TutorialText("⊙ to View Menu")
    local navigateCells = TutorialText("✛ to Navigate Cells")
    local incrementCell = TutorialText("Ⓐ to Increment Cell Value")
    local enterAnnotationMode = TutorialText("Ⓑ on Empty Cell to Enter Dot Annotation Mode")
    local inAnnotationMode = TutorialText("In Dot Annotation Mode:")
    local naviagteAnnotations = TutorialText("    ✛ to Navigate Dot Annotations")
    local toggleAnnotation = TutorialText("    Ⓐ to Toggle Dot Annotation")

    viewMenu:moveTo(15, 15)
    navigateCells:moveTo(15, 40)
    incrementCell:moveTo(15, 65)
    enterAnnotationMode:moveTo(15, 90)
    inAnnotationMode:moveTo(15, 135)
    naviagteAnnotations:moveTo(15, 160)
    toggleAnnotation:moveTo(15, 185)
end

function TutorialScene:leave()
    local menu = pd.getSystemMenu()
    menu:removeAllMenuItems()
    gfx.sprite.removeAll()
end

function TutorialScene:BButtonUp()
    self.sceneManager:enter("start")
end
