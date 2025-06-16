local app = require("app")
local csp = require("csp")
local settings = require("settings")
local sim = ac.getSim()
local uis = ac.getUI()

local appControlButton =
        ac.ControlButton("ACUIR_TOGGLE_APP", { keyboard = { key = ui.KeyIndex.F5, ctrl = true, alt = true } })

appControlButton:onPressed(function()
        settings.General.autoStart = not app.state.appOpen
        app.state.appOpen = not app.state.appOpen
end)

local waitTimeMs = sim.resultScreenTime * 1000

local accontrol = { sessionWaitTime = 0 }

function accontrol:step()
        if
                not appControlButton:configured()
                and uis.ctrlDown
                and uis.shiftDown
                and ui.keyboardButtonPressed(ui.KeyIndex.F5)
        then
                settings.General.autoStart = not app.state.appOpen
                app.state.appOpen = not app.state.appOpen
        end

        if app.state.appOpen and sim.isInMainMenu then
                ac.tryToOpenRaceMenu(nil)
                ac.tryToOpenRaceMenu("setup")
        end

        local allCarsInPIts = true
        for _, c in ac.iterateCars.ordered() do
                if not c.isInPitlane then allCarsInPIts = false end
        end

        if accontrol.sessionWaitTime == 0 and allCarsInPIts then
                accontrol.sessionWaitTime = sim.currentSessionTime + waitTimeMs - 5000
        end

        if
                sim.timeToSessionStart > 0
                or sim.sessionTimeLeft > 0
                or sim.leaderLapCount < ac.getSession(sim.currentSessionIndex).laps
        then
                accontrol.sessionWaitTime = 0
        end

        local redirectVM = (sim.isInMainMenu and ac.isWindowOpen("main")) or sim.isPaused
        ac.redirectVirtualMirror(redirectVM)

        if app.state.blockEscapeButton and app.state.appOpen and not sim.isPaused then
                ac.tryToPause(true)
                app.state.blockEscapeButton = false
        end

        if not csp.versionAllowed then app.state.appOpen = false end
end

return accontrol
