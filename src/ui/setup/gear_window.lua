local cui = require("ui.cui")
local settings = require("settings")
local car = ac.getCar(0)
local cphys = ac.getCarPhysics(0)

local function getGearMaxSpeedKmh(gear)
        if ac.getCarMaxSpeedWithGear then return math.round(math.max(ac.getCarMaxSpeedWithGear(0, gear), 0)) end

        if not cphys.gearRatio then return 0 end

        return math.round(
                (math.pi * car.wheels[2].tyreRadius * 2 * (car.rpmLimiter - 0))
                        / (60 * cphys.gearRatios[gear + 1] * cphys.finalRatio)
                        * 3.6
        )
end

local maxSpeedWithGear = {
        [0] = 0,
}

local maxSpeed = nil

function gearWindow(spinnerCount)
        local xMin = ui.windowWidth() * 0.5 + 50 * cui.uiScale()
        local xMax = ui.windowWidth() - 30 * cui.uiScale()
        local width = xMax - xMin

        local yMin = 110 * cui.uiScale()
        local yMax = 110 + width
        local height = yMax - yMin

        if spinnerCount <= 1 then
                xMin = ui.windowWidth() / 2 - width / 2
                xMax = ui.windowWidth() / 2 + width / 2
                ui.setCursor(vec2(ui.windowWidth() / 2 - width / 2, yMin * 0.7))
        else
                ui.setCursor(vec2(xMin, yMin * 0.7))
        end

        ui.drawRectFilled(vec2(xMin, yMin), vec2(xMax, yMax), rgbm(0, 0, 0, 0.75))

        if not maxSpeed or maxSpeed == 0 then maxSpeed = getGearMaxSpeedKmh(car.gearCount) * 1.25 end

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
                        24 * cui.uiScale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(65, 20) * cui.uiScale()
                )
                ui.pathLineTo(vec2(xMin + width / 10 * i, yMax))
                ui.pathLineTo(vec2(xMin + width / 10 * i, yMax - height / 50))
                ui.pathStroke(rgbm(0.4, 0.4, 0.4, 1), false, 3)

                ui.setCursor(vec2(xMin - 70, yMin + (yMax - yMin) / 10 * i) - 10)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        math.round(car.rpmLimiter - (car.rpmLimiter / 10) * i),
                        24 * cui.uiScale(),
                        ui.Alignment.End,
                        ui.Alignment.Center,
                        vec2(65, 20) * cui.uiScale()
                )

                ui.pathLineTo(vec2(xMin, yMin + (yMax - yMin) / 10 * i))
                ui.pathLineTo(vec2(xMin + height / 50, yMin + (yMax - yMin) / 10 * i))
                ui.pathStroke(rgbm(0.4, 0.4, 0.4, 1), false, 3)
        end

        for i = 1, car.gearCount do
                local maxGearSpeed = getGearMaxSpeedKmh(i)

                if maxGearSpeed > 0 and maxGearSpeed <= maxSpeed then
                        maxSpeedWithGear[i] = maxGearSpeed
                else
                        maxGearSpeed = maxSpeedWithGear[i]
                end

                local prevGearSpeed = maxSpeedWithGear[i - 1]

                local x1 = xMin + width * (prevGearSpeed / maxSpeed)
                local p1 = vec2(x1, math.max(yMin + (yMax - yMin) * (1 - (prevGearSpeed / maxGearSpeed)), yMin))
                local p2 = vec2(math.max(xMin + width * (maxGearSpeed / maxSpeed), x1), yMin)

                local labelWidth = 125 * cui.uiScale()
                local labelHeight = 24 * cui.uiScale()
                local labelPadding = 4 * cui.uiScale()
                local fontSize = math.floor(24 * cui.uiScale())
                fontSize = (fontSize % 2 == 0) and fontSize + 1 or fontSize

                ui.pathLineTo(p1)
                ui.pathLineTo(p2)
                ui.pathStroke(settings.Appearance.uiColor2, false, 4)

                ui.pathLineTo(p2)
                ui.pathLineTo(vec2(p2.x, yMax - (height / car.gearCount / 2) * i + labelHeight))
                ui.pathStroke(rgbm(1, 1, 1, 0.1), false, 3)

                ui.setCursor(vec2(p2.x - labelWidth, yMax - (height / car.gearCount / 2) * i))
                cui.snapCursor()
                ui.drawRectFilled(
                        ui.getCursor() - vec2(labelPadding, labelPadding),
                        ui.getCursor() + vec2(labelWidth + labelPadding, labelHeight + labelPadding),
                        rgbm.colors.white
                )
                ui.offsetCursorX(-labelPadding)
                ui.dwriteTextAligned(
                        string.format("%s - %s kmh", i, maxGearSpeed),
                        fontSize,
                        0,
                        0,
                        vec2(labelWidth + (labelPadding * 2), labelHeight),
                        false,
                        rgbm.colors.black
                )

                prevGearSpeed = maxGearSpeed
        end
end
