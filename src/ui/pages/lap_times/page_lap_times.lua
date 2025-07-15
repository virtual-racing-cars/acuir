local page = {}

local WidgetWindow = require("src.classes.WidgetWindow")
local cui = require("ui.cui")
local lapTimeWidget = require("src.ui.widgets.lap_times")
local simutils = require("simutils")
local lapTimeWindow = WidgetWindow("lap_times")

local sim = ac.getSim()

local vec2Temp1 = vec2()

local lapTimeSession = 0

ac.onSessionStart(function(sessionIndex, restarted) lapTimeWindow.activeWidgetIndex = sessionIndex + 1 end)

function page.update() end

for i = 1, sim.sessionsCount do
        lapTimeWindow:addWidget(simutils.sessionTypeStrings[ac.getSession(i - 1).type], lapTimeWidget)
end

function page.draw()
        lapTimeSession = lapTimeWindow.activeWidgetIndex - 1

        lapTimeWindow:setPosition(0, 0)
        lapTimeWindow:setSize(ui.windowWidth() * 0.5 - 7.5 * cui.scale(), ui.windowHeight() - 255 * cui.scale())
        lapTimeWindow:draw()
        lapTimeWidget.sessionIndex = ac.getSession(lapTimeSession).type
        bottomWidgetBar()

        return "finalize"
end

return page
