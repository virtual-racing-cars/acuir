local app = require("app")
local settings = require("settings")
local sim = ac.getSim()
local uis = ac.getUI()

local accontrol = {}

function accontrol:step()
        if uis.ctrlDown and uis.shiftDown and ui.keyboardButtonPressed(ui.KeyIndex.F5) then
                settings.General.autoStart = not app.state.appOpen
                app.state.appOpen = not app.state.appOpen
        end

        if app.state.appOpen and sim.isInMainMenu then
                ac.tryToOpenRaceMenu(nil)
                ac.tryToOpenRaceMenu("setup")
        end

        local redirectVM = (sim.isInMainMenu and ac.isWindowOpen("main")) or sim.isPaused
        ac.redirectVirtualMirror(redirectVM)
end

return accontrol
