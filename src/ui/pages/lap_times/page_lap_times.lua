local page = {}

local cui = require("ui.cui")
local lapTimeWidget = require("src.ui.widgets.lap_times")
local simutils = require("simutils")
local sim = ac.getSim()

local vec2Temp1 = vec2()

local genericButtonHeight = 50

local lapTimeSession = 0

ac.onSessionStart(function(sessionIndex, restarted) lapTimeSession = sessionIndex end)

function page.update() end

function page.draw()
        local genericButtonHeight = 40 * cui.uiScale()

        cui.pushContentWindow(
                "lap_times_window",
                0,
                0,
                ui.windowWidth() * 0.5,
                ui.windowHeight() - 255 * cui.uiScale(),
                function()
                        ui.setCursor(0)

                        for i = 1, sim.sessionsCount do
                                if
                                        cui.menuButton(
                                                simutils.sessionTypeStrings[ac.getSession(i - 1).type],
                                                genericButtonHeight,
                                                0,
                                                0,
                                                sim.currentSessionIndex + 1 >= i and ui.ButtonFlags.None
                                                        or ui.ButtonFlags.Disabled,
                                                sim.sessionsCount > 1 and lapTimeSession == i - 1,
                                                false,
                                                ui.CornerFlags.TopLeft
                                        )
                                then
                                        lapTimeSession = i - 1
                                end
                                ui.sameLine()
                        end
                end
        )

        lapTimeWidget:draw(0, 0, ui.windowWidth(), ui.windowHeight(), ac.getSession(lapTimeSession).type)

        cui.popContentWindow()

        bottomWidgetBar()

        return ""
end

return page
