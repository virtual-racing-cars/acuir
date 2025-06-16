local cui = require("ui.cui")
local settings = require("settings")
local sim = ac.getSim()

local tracesGraph = {}

local spectatedCarIndexLast = 0
local border = 7.5

local traceLifetime = 5
local traceFramerate = 60
local updateTimer = 0

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

local function getMaxDataCount() return traceLifetime * traceFramerate end

for i = 1, getMaxDataCount() do
        for _, trace in pairs(traces) do
                trace.data[i] = 0
        end
end

local function resetUpdateTimer() updateTimer = updateTimer + (1 / traceFramerate) end

local function clearTraceData()
        for i = 1, getMaxDataCount() do
                for _, trace in pairs(traces) do
                        trace.data[i] = 0
                end
        end

        resetUpdateTimer()
end

local function updateTraceData(car)
        for _, trace in ipairs(traces) do
                if #trace.data > getMaxDataCount() then table.remove(trace.data, 1) end

                if car then
                        table.insert(trace.data, trace.update(car))
                else
                        table.insert(trace.data, 0)
                end
        end

        resetUpdateTimer()
end

local function drawGridLines()
        local quarterHeight = ui.windowHeight() / 4

        for i = 1, 3 do
                ui.drawSimpleLine(
                        vec2(0, i * quarterHeight),
                        vec2(ui.windowWidth(), i * quarterHeight),
                        rgbm(0.15, 0.15, 0.15, 1),
                        2 * cui.uiScale()
                )
        end
end

local function drawTraces()
        for _, trace in pairs(traces) do
                ui.pathClear()
                local xSegment = (ui.windowWidth() / (#trace.data + 1))

                for x, v in ipairs(trace.data) do
                        ui.pathLineTo(
                                vec2(
                                        xSegment + (x - 1) * xSegment,
                                        ui.windowHeight() * 0.1 + ((1 - v) * ui.windowHeight() * 0.8)
                                )
                        )
                end
                ui.pathSmoothStroke(trace.color, false, 4 * cui.uiScale())
        end
end

function tracesGraph:draw(xPos, yPos, width, height)
        cui.pushWindow("traces_widget_window", xPos, yPos, width, height, false)
        ui.drawRectFilled(
                vec2(0, 0),
                vec2(ui.windowWidth(), ui.windowHeight()),
                settings.Appearance.uiColorBackground,
                12
        )

        border = 7.5 * cui.uiScale()

        cui.pushWindow("traces_widget_window2", border, border, width - border * 2, height - border * 2, false)
        drawGridLines()

        if sim.focusedCar ~= spectatedCarIndexLast then
                clearTraceData()
                spectatedCarIndexLast = sim.focusedCar
        end

        if updateTimer <= 0 then updateTraceData(ac.getCar(sim.focusedCar)) end

        drawTraces()

        updateTimer = updateTimer - ac.getScriptDeltaT()

        cui.popWindow()
        cui.popWindow()
end

return tracesGraph
