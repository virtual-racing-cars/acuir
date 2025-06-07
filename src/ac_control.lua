local app = require("app")
local settings = require("settings")
local sim = ac.getSim()
local uis = ac.getUI()

local waitTimeMs = sim.resultScreenTime * 1000

local accontrol = { sessionWaitTime = 0 }

function accontrol:step()
        if uis.ctrlDown and uis.shiftDown and ui.keyboardButtonPressed(ui.KeyIndex.F5) then
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
end

return accontrol
