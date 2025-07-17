local cui = require("ui.cui")
local settings = require("settings")
local simutils = require("simutils")
local style = require("ui.cui.style")
local units = require("units")
local weather = require("weather")
local sim = ac.getSim()
local uis = ac.getUI()
local car = ac.getCar(0)

local gearSpeedsWidget = {}

local function getGearMaxSpeed(gear) return math.round(units:speed(ac.getCarMaxSpeedWithGear(0, gear))) end

local maxSpeedWithGear = {
        [0] = 0,
}

local maxSpeed = nil

local gearSpeedWarning = false
local showLabels = true

function gearSpeedsWidget:body()
        local xMin = 85 * cui.scale()
        local xMax = ui.windowWidth() - 30 * cui.scale()
        local width = xMax - xMin

        local yMin = 20 * cui.scale()
        local yMax = ui.windowHeight() - 50 * cui.scale()
        local height = yMax - yMin
        if not maxSpeed or maxSpeed == 0 then maxSpeed = getGearMaxSpeed(car.gearCount) end

        ui.pathLineTo(vec2(xMin, yMax))
        ui.pathLineTo(vec2(xMin + width, yMax))
        ui.pathStroke(rgbm(0.4, 0.4, 0.4, 1), false, 3)
        ui.pathLineTo(vec2(xMin, yMin))
        ui.pathLineTo(vec2(xMin, yMax))
        ui.pathStroke(rgbm(0.4, 0.4, 0.4, 1), false, 3)

        for i = 0, 10 do
                ui.setCursor(vec2(xMin + width / 10 * i - 32, yMax + 10))
                cui.snapCursor()
                ui.dwriteTextAligned(
                        math.round(i / 10 * maxSpeed),
                        style.main.font.body.size,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(65, 24) * cui.scale()
                )
                ui.pathLineTo(vec2(xMin + width / 10 * i, yMax))
                ui.pathLineTo(vec2(xMin + width / 10 * i, yMax - height / 50))
                ui.pathStroke(rgbm(0.4, 0.4, 0.4, 1), false, 3)

                ui.setCursor(vec2(xMin - 70 * cui.scale(), yMin + (yMax - yMin) / 10 * i) - 10 * cui.scale())
                cui.snapCursor()
                ui.dwriteTextAligned(
                        math.round(car.rpmLimiter - (car.rpmLimiter / 10) * i),
                        style.main.font.body.size,
                        ui.Alignment.End,
                        ui.Alignment.Center,
                        vec2(65, 24) * cui.scale()
                )

                ui.pathLineTo(vec2(xMin, yMin + (yMax - yMin) / 10 * i))
                ui.pathLineTo(vec2(xMin + height / 50, yMin + (yMax - yMin) / 10 * i))
                ui.pathStroke(rgbm(0.4, 0.4, 0.4, 1), false, 3)
        end

        gearSpeedWarning = false

        for i = 1, car.gearCount do
                local maxGearSpeed = getGearMaxSpeed(i)
                local prevGearSpeed = maxSpeedWithGear[i - 1]
                local nextGearSpeed = maxSpeedWithGear[math.min(i + 1, car.gearCount)] or maxGearSpeed
                maxSpeedWithGear[i] = maxGearSpeed

                if maxGearSpeed > maxSpeed then maxSpeed = maxGearSpeed end

                local warning = (maxGearSpeed >= nextGearSpeed or maxGearSpeed >= maxSpeed) and i ~= car.gearCount
                if not gearSpeedWarning then gearSpeedWarning = warning end

                local x1 = xMin + width * (prevGearSpeed / maxSpeed)
                local p1 = vec2(x1, math.max(yMin + (yMax - yMin) * (1 - (prevGearSpeed / maxGearSpeed)), yMin))
                local p2 = vec2(math.max(xMin + width * (maxGearSpeed / maxSpeed), x1), yMin)

                local labelWidth = 125 * cui.scale()
                local labelHeight = 20 * cui.scale()
                local fontSize = 18 * cui.scale()

                ui.pathLineTo(p1)
                ui.pathLineTo(p2)
                ui.pathStroke(settings.Appearance.uiColorSecondary, false, 4)

                if showLabels then
                        local labelYPos = yMax - 10 * cui.scale() - (height / car.gearCount * 0.8) * i

                        ui.pathLineTo(p2)
                        ui.pathLineTo(vec2(p2.x, labelYPos + labelHeight))
                        ui.pathStroke(rgbm(1, 1, 1, 0.1), false, 3)

                        ui.setCursor(vec2(p2.x - labelWidth, labelYPos))
                        -- ui.drawRectFilled(
                        --         ui.getCursor(),
                        --         ui.getCursor() + vec2(labelWidth, labelHeight),
                        --         warning and settings.Appearance.uiColorSecondary or settings.Appearance.uiColorText,
                        --         6 * cui.scale()
                        -- )

                        cui.offsetCursorX(-5)
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                string.format("%s - %s %s", i, maxGearSpeed, uis.useImperialUnits and "mph" or "kmh"),
                                fontSize,
                                1,
                                0,
                                vec2(labelWidth, labelHeight),
                                false,
                                warning and settings.Appearance.uiColorSecondary or settings.Appearance.uiColorText
                        )
                end

                prevGearSpeed = maxGearSpeed
        end

        maxSpeed = getGearMaxSpeed(car.gearCount)
end

function gearSpeedsWidget:drawFooter()
        showLabels = cui.checkbox("GEARSPEED.labels", "Show Labels", style.main.font.body.size, showLabels)

        if not gearSpeedWarning then return end

        ui.setCursorX(ui.windowWidth() * 0.5)
        ui.setCursorY(0)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "*Warning! Some gear max speeds exceed the next gear's max speed.",
                style.main.font.body.size,
                ui.Alignment.Start,
                0,
                ui.windowSize(),
                false,
                settings.Appearance.uiColorSecondary
        )
end

return gearSpeedsWidget
