package.add("src")
require("ui.main_window")
require("ui.pause_window")
require("ui.pitstop_window")
require("audio")
local app = require("app")
local audio = require("audio")
local csp = require("csp")
local mod = require("install")
local pages = require("ui.pages")
local pitstop = require("pitstop")
local settings = require("settings")

app.state.appOpen = settings.General.autoStart
app.state.hasAppOpened = false

local modeLast = ""
ui.onExclusiveHUD(function(mode)
        if not app.state.appOpen or ac.getLastError() then return end

        local dt = ac.getScriptDeltaT()

        if mode == "menu" then
                audio:driver(dt)

                if modeLast ~= mode then pages:setParentMainMenu() end

                modeLast = mode

                return MainMenuWindow(dt)
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
function script.update(dt)
        if not app.state.appOpen or ac.getLastError() then
                ac.disableQuickMenuPitstop(false)
                return
        end

        pitstop:step(dt)

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

        if csp.ui.ctrlDown and csp.ui.shiftDown and ui.keyboardButtonPressed(ui.KeyIndex.F5) then
                settings.General.autoStart = not app.state.appOpen
                app.state.appOpen = not app.state.appOpen
        end

        if not app.state.appOpen then return end

        local redirectVM = (csp.sim.isInMainMenu and ac.isWindowOpen("main")) or csp.sim.isPaused
        ac.redirectVirtualMirror(redirectVM)
end

function script.pause() end
