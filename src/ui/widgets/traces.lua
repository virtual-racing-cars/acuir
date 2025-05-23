local cui = require("ui.cui")
local settings = require("settings")
local sim = ac.getSim()

local seconds_of_telemetry = 5
local telemetry_framerate = 60
local updateTime = 0

local traces = {

        {
                data = {},
                update = function(car) return car.gas end,
                color = rgbm(0, 0.7, 0, 1),
        },
        {
                data = {},
                update = function(car) return car.brake end,
                color = rgbm.colors.red,
        },
}

for i = 1, seconds_of_telemetry * telemetry_framerate do
        for _, trace in pairs(traces) do
                trace.data[i] = 0
        end
end

local tracesGraph = {}

local spectatedCarIndexLast = 0

local border = 7.5

function tracesGraph:draw(xPos, yPos, width, height)
        cui.pushWindow("traces_widget_window", xPos, yPos, width, height, false)
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), settings.Appearance.uiThemeColor1)

        border = 7.5 * cui.uiScale()

        cui.pushWindow("traces_widget_window2", border, border, width - border * 2, height - border * 2, false)
        ui.drawRectFilled(0, vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0.1, 0.1, 0.1, 1))

        local quarterHeight = ui.windowHeight() / 4

        for i = 1, 3 do
                ui.drawSimpleLine(
                        vec2(0, i * quarterHeight),
                        vec2(ui.windowWidth(), i * quarterHeight),
                        rgbm(0.15, 0.15, 0.15, 1),
                        2 * cui.uiScale()
                )
        end

        local spectatedCar = ac.getCar(sim.focusedCar)

        if sim.focusedCar ~= spectatedCarIndexLast then
                spectatedCarIndexLast = sim.focusedCar

                for i = 1, seconds_of_telemetry * telemetry_framerate do
                        for _, trace in pairs(traces) do
                                trace.data[i] = 0
                        end
                end
        end

        if updateTime <= 0 then
                updateTime = updateTime + 1 / telemetry_framerate -- next update

                for _, trace in ipairs(traces) do
                        if #trace.data > seconds_of_telemetry * telemetry_framerate then table.remove(trace.data, 1) end

                        if spectatedCar then
                                table.insert(trace.data, trace.update(spectatedCar))
                        else
                                table.insert(trace.data, 0)
                        end
                end
        end

        updateTime = updateTime - ac.getScriptDeltaT()

        local lowerBound = ui.windowHeight() - ui.windowHeight() * 0.1
        local upperBound = ui.windowHeight() - ui.windowHeight() * 0.2

        for _, trace in pairs(traces) do
                ui.pathClear()
                local xSegment = (ui.windowWidth() / (#trace.data + 1))

                for x, v in ipairs(trace.data) do
                        ui.pathLineTo(vec2(xSegment + (x - 1) * xSegment, lowerBound - v * upperBound))
                end
                ui.pathSmoothStroke(trace.color, false, 4 * cui.uiScale())
        end

        cui.popWindow()
        cui.popWindow()
end

return tracesGraph
