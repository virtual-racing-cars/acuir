local page = {}

local cui = require("ui.cui")
local lapTimeWidget = require("src.ui.widgets.lap_times")
local simutils = require("simutils")
local sim = ac.getSim()

local vec2Temp1 = vec2()

local lapTimeSession = 0

ac.onSessionStart(function(sessionIndex, restarted)
        lapTimeSession = sessionIndex
end)

function page.update() end

function page.draw()
        local height = 50 * cui.uiScale()

        cui.pushWindow(
                "home_leaderboard_window",
                0,
                0,
                ui.windowWidth() * 0.5 - 7.5 * cui.uiScale(),
                ui.windowHeight() - 255 * cui.uiScale(),
                false
        )
        ui.drawRectFilled(0, vec2(ui.windowWidth(), 50 * cui.uiScale()), rgbm(0, 0, 0, 1))

        ui.setCursor(0)

        for i = 1, sim.sessionsCount do
                if
                        cui.menuButton(
                                simutils.sessionTypeStrings[ac.getSession(i - 1).type],
                                vec2Temp1:set(ui.windowWidth() / sim.sessionsCount, height),
                                0,
                                0,
                                sim.currentSessionIndex + 1 >= i and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
                                sim.sessionsCount > 1 and lapTimeSession == i - 1,
                                false
                        )
                then
                        lapTimeSession = i - 1
                end
                ui.sameLine()
        end

        lapTimeWidget:draw(0, height, ui.windowWidth(), ui.windowHeight() - height, ac.getSession(lapTimeSession).type)

        cui.popWindow()

        bottomWidgetBar()

        return ""
end

return page
