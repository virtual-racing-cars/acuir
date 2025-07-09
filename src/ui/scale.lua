local audio = require("audio")
local callback = require("callback")
local settings = require("settings")
local style = require("src.ui.style")
local sim = ac.getSim()
local guiINI = ac.INIConfig.cspModule(ac.CSPModuleID.GUI)

local defaultWidth = 2560
local defaultHeight = 1440

local scale = {}

local _uiScale = 1

local function recalculateScale(width, height)
        guiINI = ac.INIConfig.cspModule(ac.CSPModuleID.GUI)

        local newScale = math.min(height / defaultHeight, width / defaultWidth)
                / guiINI:get("NEW_UI", "UI_SCALE", 1)
                * settings.UI.mainMenuScale

        style:refresh(newScale)

        return newScale
end

ac.onResolutionChange(function(newSize, makingScreenshot) _uiScale = recalculateScale(newSize.x, newSize.y) end)

ac.onCSPConfigChanged(ac.CSPModuleID.GUI, function() _uiScale = recalculateScale(sim.windowWidth, sim.windowHeight) end)

_uiScale = recalculateScale(sim.windowWidth, sim.windowHeight)

function scale.get() return _uiScale end

return scale
