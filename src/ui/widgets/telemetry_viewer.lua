local cui = require("ui.cui")
local settings = require("settings")
local style = require("ui.style")
local telemetry = require("telemetry")
local sim = ac.getSim()

local vec2Temp1 = vec2()

local telemetryViewer = {
        isShowingBest = true,
        isShowingLast = true,
}

local function drawTelemetryGraphs()
        local channelsCount = #telemetry.lastLap.channels
        local graphHeight = (ui.windowHeight() / channelsCount) - 20 * cui.scale()
        local graphWidth = ui.windowWidth()
        local fontSize = style.main.font.body.size
        local fontSpace = style.main.font.body.space

        for i, _ in ipairs(telemetry.lastLap.channels) do
                local bestLapChannel = telemetry.bestLap.channels[i]
                local lastLapChannel = telemetry.lastLap.channels[i]

                ui.setCursorX(0)

                ui.invisibleButton(
                        "##channelgraph" .. lastLapChannel.key,
                        vec2Temp1:set(graphWidth, graphHeight),
                        ui.ButtonFlags.Disabled
                )
                local r1, r2 = ui.itemRect()
                ui.drawRectFilled(
                        r1,
                        vec2Temp1:set(r2.x, r1.y + fontSpace),
                        settings.Appearance.uiColorBackground * 0.2
                )

                ui.setCursor(r1)

                cui.offsetCursorX(10)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        string.format("%s %s", lastLapChannel.label, lastLapChannel.units),
                        fontSize,
                        -1,
                        0,
                        vec2(ui.windowWidth(), fontSpace),
                        false,
                        rgbm.colors.white
                )

                if bestLapChannel.data[2] == nil and lastLapChannel.data[2] == nil then
                        ui.setCursorX(0)
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                "NO DATA",
                                style.main.font.title.size,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2Temp1:set(graphWidth, r2.y - ui.getCursorY()),
                                false,
                                rgbm.colors.gray
                        )
                end

                ui.setCursor(r2)

                r1.y = r1.y + fontSpace
                r2.y = r2.y - fontSpace

                local height = r2.y - r1.y
                local yMin = math.max(bestLapChannel.max, lastLapChannel.max)
                local yMax = math.min(bestLapChannel.min, lastLapChannel.min)
                local xSegment = (r2.x - r1.x) / telemetry.dataCount

                if telemetryViewer.isShowingBest then
                        ui.pathClear()
                        for x = 0, telemetry.dataCount - 1 do
                                local y = bestLapChannel.data[x]
                                if y then
                                        ui.pathLineTo(
                                                vec2Temp1:set(
                                                        r1.x + x * xSegment,
                                                        r1.y
                                                                + (
                                                                        math.lerp(
                                                                                0,
                                                                                1,
                                                                                (1 - (y - yMax) / (yMin - yMax))
                                                                        )
                                                                        * height
                                                                )
                                                )
                                        )
                                end
                        end
                        ui.pathSmoothStroke(rgbm(0, 1, 0, 1), false, 2 * cui.scale())
                end

                if telemetryViewer.isShowingLast then
                        ui.pathClear()
                        for x = 0, telemetry.dataCount - 1 do
                                local y = lastLapChannel.data[x]
                                if y then
                                        ui.pathLineTo(
                                                vec2Temp1:set(
                                                        r1.x + x * xSegment,
                                                        r1.y
                                                                + (
                                                                        math.lerp(
                                                                                0,
                                                                                1,
                                                                                (1 - (y - yMax) / (yMin - yMax))
                                                                        )
                                                                        * height
                                                                )
                                                )
                                        )
                                end
                        end
                        ui.pathSmoothStroke(rgbm.colors.red, false, 2 * cui.scale())
                end

                cui.offsetCursorY(20)
        end
end

local function drawTelemetrySlice()
        local mousePos = ui.mouseLocalPos()

        local splinePos = math.round(math.clamp(1 - (ui.windowWidth() - mousePos.x) / ui.windowWidth(), 0, 1), 3)
        local dataIndex = math.floor(splinePos * telemetry.dataCount)

        local bestLapChannel = telemetry.bestLap.channels[1]
        local lastLapChannel = telemetry.lastLap.channels[1]

        if
                not ui.windowHovered()
                or (bestLapChannel.data[dataIndex] == nil and lastLapChannel.data[dataIndex] == nil)
        then
                return
        end

        ui.drawSimpleLine(vec2(mousePos.x, 0), vec2(mousePos.x, ui.windowHeight()), rgbm.colors.yellow)

        local pointData = {
                {
                        label = "Gas",
                        lastLap = telemetry.lastLap.channels[1].data[dataIndex] or 0,
                        bestLap = telemetry.bestLap.channels[1].data[dataIndex] or 0,
                        multiplier = 100,
                        units = "%",
                },
                {
                        label = "Speed",
                        lastLap = telemetry.lastLap.channels[2].data[dataIndex] or 0,
                        bestLap = telemetry.bestLap.channels[2].data[dataIndex] or 0,
                        multiplier = 1,
                        units = "km/h",
                },
                {
                        label = "Brake",
                        lastLap = telemetry.lastLap.channels[3].data[dataIndex] or 0,
                        bestLap = telemetry.bestLap.channels[3].data[dataIndex] or 0,
                        multiplier = 100,
                        units = "%",
                },
                {
                        label = "Gear",
                        lastLap = telemetry.lastLap.channels[4].data[dataIndex] or 0,
                        bestLap = telemetry.bestLap.channels[4].data[dataIndex] or 0,
                        multiplier = 1,
                        units = "",
                },
        }

        ui.setCursor(mousePos)
        if ui.windowHovered() then
                ui.tooltip(function()
                        local fontSize = style.main.font.body.size
                        local textBoxSize = vec2Temp1:set(100 * cui.scale(), style.main.font.body.space)

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                "",
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                textBoxSize,
                                false,
                                rgbm.colors.white
                        )
                        ui.sameLine()
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                "Last",
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                textBoxSize,
                                false,
                                rgbm.colors.red
                        )
                        ui.sameLine()
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                "Best",
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                textBoxSize,
                                false,
                                rgbm(0, 1, 0, 1)
                        )

                        ui.newLine()

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                "Lap Time",
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                textBoxSize,
                                false,
                                rgbm.colors.white
                        )
                        ui.sameLine()
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                ac.lapTimeToString(telemetry.lastLap.lapTimeMs),
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                textBoxSize,
                                false,
                                rgbm.colors.white
                        )
                        ui.sameLine()
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                ac.lapTimeToString(telemetry.bestLap.lapTimeMs),
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                textBoxSize,
                                false,
                                rgbm.colors.white
                        )

                        for _, pointData in ipairs(pointData) do
                                if not pointData then return end

                                cui.snapCursor()
                                ui.dwriteTextAligned(
                                        pointData.label,
                                        fontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        textBoxSize,
                                        false,
                                        rgbm.colors.white
                                )
                                ui.sameLine()
                                cui.snapCursor()
                                ui.dwriteTextAligned(
                                        string.format(
                                                "%.0f %s",
                                                pointData.lastLap * pointData.multiplier,
                                                pointData.units
                                        ),
                                        fontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        textBoxSize,
                                        false,
                                        rgbm.colors.white
                                )
                                ui.sameLine()
                                cui.snapCursor()
                                ui.dwriteTextAligned(
                                        string.format(
                                                "%.0f %s",
                                                pointData.bestLap * pointData.multiplier,
                                                pointData.units
                                        ),
                                        fontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        textBoxSize,
                                        false,
                                        rgbm.colors.white
                                )
                        end
                        ui.newLine()

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                string.format(
                                        "Lap Progress %.0f%% (%.3f km)",
                                        splinePos * 100,
                                        sim.trackLengthM * splinePos * 0.001
                                ),
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2Temp1:set(250, 24) * cui.scale(),
                                false,
                                rgbm.colors.white
                        )
                end)
        end
end

function telemetryViewer:body()
        drawTelemetryGraphs()
        drawTelemetrySlice()
end

function telemetryViewer:drawFooter()
        local changed = false
        local height = ui.windowHeight() * 0.65

        telemetryViewer.isShowingBest =
                drawCheckbox("##telemetryViewerIsShowingBest", "Best Lap", height, telemetryViewer.isShowingBest)
        ui.sameLine()
        cui.offsetCursorX(30)

        telemetryViewer.isShowingLast =
                drawCheckbox("##telemetryViewerIsShowingLast", "Last Lap", height, telemetryViewer.isShowingLast)
end

return telemetryViewer
