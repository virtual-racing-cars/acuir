package.add("src")
require("ui.main_window")
require("ui.pause_window")
require("ui.pitstop_window")
require("ui.results_window")
require("audio")
local app = require("app")
local audio = require("audio")
local csp = require("csp")
local cui = require("ui.cui")
local mod = require("install")
local pages = require("ui.pages")
local pitstop = require("pitstop")
local race = require("race")
local replay = require("replay")
local settings = require("settings")
local simutils = require("simutils")

app.state.appOpen = settings.General.autoStart
app.state.hasAppOpened = false

local intializationTimer = os.clock() + 0.1

local modeLast = ""

ui.onExclusiveHUD(function(mode)
        ui.forceSimplifiedComposition()

        if not app.state.appOpen or ac.getLastError() then return end

        local dt = ac.getScriptDeltaT()

        if intializationTimer > os.clock() then
                ui.drawRectFilled(vec2(0, 0), ui.windowWidth(), rgbm.colors.black)

                return "apps"
        end

        if mode == "menu" then
                audio:driver(dt)

                if modeLast ~= mode then pages:setParentMainMenu() end

                modeLast = mode

                return MainMenuWindow(dt)
        end

        -- if mode == "replay" then
        --         audio:driver(dt)

        --         if modeLast ~= mode then pages:setParentMainMenu() end

        --         modeLast = mode

        --         return MainMenuWindow(dt)
        -- end

        if mode == "results" then
                audio:driver(dt)

                if modeLast ~= mode then pages:setParentResultsMenu() end
                modeLast = mode

                return ResultsMenuWindow()
        end

        if mode == "pause" then
                audio:driver(dt)

                if modeLast ~= mode then pages:setParentPauseMenu() end
                modeLast = mode

                return PauseMenuWindow()
        end

        if mode == "game" then
                if modeLast ~= mode then pages:setParentMainMenu() end
        end

        modeLast = mode
end)

ac.setWindowOpen("main", true)
local windowTimeSync = 0
function script.main(dt)
        if not app.state.hasAppOpened then app.state.hasAppOpened = true end
        windowTimeSync = os.clock()
end

teleportPitsCallback = nil

local fov = csp.sim.cameraFOV

if not app.state.debug then ac.log = function() end end

function script.update(dt)
        ac.setLogSilent(true)

        if csp.ui.ctrlDown and csp.ui.shiftDown and ui.keyboardButtonPressed(ui.KeyIndex.F5) then
                settings.General.autoStart = not app.state.appOpen
                app.state.appOpen = not app.state.appOpen
        end

        if not app.state.appOpen or ac.getLastError() then
                pitstop:setWindowOpen(false)
                ac.disableQuickMenuPitstop(false)
                return
        end

        if csp.sim.isInMainMenu then
                if cui.menuZoomAvailable and ui.mouseWheel() ~= 0 then
                        fov = math.clamp(fov - ui.mouseWheel(), 2, 170)
                end

                ac.setCameraFOV(fov)
        else
                fov = csp.sim.cameraFOV
        end

        race:step()
        pitstop:step(dt)
        replay:step(dt)

        if teleportPitsCallback then
                if teleportPitsCallback() then teleportPitsCallback = nil end
        end

        if
                csp.sim.isInMainMenu
                and settings.General.autoStart
                and not app.state.hasAppOpened
                and windowTimeSync < os.clock() - 1
        then
                ac.tryToOpenRaceMenu("race")
                ac.tryToOpenRaceMenu("setup")
        end

        local redirectVM = (csp.sim.isInMainMenu and ac.isWindowOpen("main")) or csp.sim.isPaused
        ac.redirectVirtualMirror(redirectVM)
end

function script.pause() end
