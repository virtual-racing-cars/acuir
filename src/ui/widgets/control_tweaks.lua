local configs = require("configs")
local controllerTweaks = require("controller_tweaks")
local cui = require("ui.cui")
local settings = require("settings")
local sim = ac.getSim()

local controlTweaks = { section = 1 }

-- The following curve based stuff was written originally by Ilja for Controller Tweaks
local function drawCurveBase(size)
        cui.offsetCursorY(10)
        local from, range = ui.getCursor(), size:clone()
        ui.dummy(range)
        ui.drawRectFilled(from, from + range, rgbm(0.1, 0.1, 0.1, 0.5))
        from.y, range.y = from.y + range.y, -range.y
        cui.offsetCursorY(20)
        return from, range
end

local function drawGammaCurve(gamma, joy, axle, min, max, isSteering)
        local b = ac.getJoystickAxisValue(joy, axle)

        if not isSteering then b = math.abs(math.lerpInvSat(b, min, max)) end

        local ax = math.abs(b)

        ui.setCursorX(ui.windowWidth() * 0.1)
        local f, s = drawCurveBase(vec2(ui.windowWidth() * 0.8, ui.windowWidth() * 0.2))

        if not isSteering then
                local ped = ax ^ gamma

                ui.drawLine(f + vec2(0, ped * s.y), f + vec2(s.x, ped * s.y), rgbm.colors.gray)
                ui.drawLine(f + vec2(b * s.x, 0), f + vec2(b * s.x, s.y), rgbm.colors.gray)

                for i = 0, 30 do
                        local x = (i / 30) ^ 2
                        ui.pathLineTo(f + vec2(x, x ^ gamma) * s)
                end
                ui.pathStroke(settings.Appearance.uiColorSecondary, false, 3 * cui.scale())
        else
                local relSteer = math.clamp(math.sign(b) * (ax ^ gamma), -1, 1)

                ui.drawLine(
                        f + vec2(0, (0.5 + 0.5 * relSteer) * s.y),
                        f + vec2(s.x, (0.5 + 0.5 * relSteer) * s.y),
                        rgbm.colors.gray
                )
                ui.drawLine(f + vec2((0.5 + 0.5 * b) * s.x, 0), f + vec2((0.5 + 0.5 * b) * s.x, s.y), rgbm.colors.gray)

                for i0 = 0, 1 do
                        for i = 0, 100 do
                                local x = (i / 100) ^ 2

                                if i0 == 1 then
                                        ui.pathLineTo(f + vec2(0.5 + 0.5 * x, 0.5 + 0.5 * x ^ gamma) * s)
                                else
                                        ui.pathLineTo(f + vec2(0.5 - 0.5 * x, 0.5 - 0.5 * x ^ gamma) * s)
                                end
                        end
                        ui.pathStroke(settings.Appearance.uiColorSecondary, false, 3 * cui.scale())
                end
        end
end

local steer = 0

local function drawGamepadGammaCurve()
        local gamma = configs.CONTROLS.data.X360.STEER_GAMMA
        local deadzone = configs.CONTROLS.data.X360.STEER_DEADZONE
        local speed = configs.CONTROLS.data.X360.STEER_SPEED

        if gamma == 0 then gamma = 1 end

        ui.setCursorX(ui.windowWidth() * 0.1)
        local f, s = drawCurveBase(vec2(ui.windowWidth() * 0.8, ui.windowWidth() * 0.2))
        local b = ac.getGamepadAxisValue(
                0,
                configs.CONTROLS.data.X360.STEER_THUMB == "LEFT" and ac.GamepadAxis.LeftThumbX
                        or ac.GamepadAxis.RightThumbX
        )

        local ax = math.abs(b)

        local norm = (ax - deadzone) / (1 - deadzone)
        local curved = norm ^ gamma
        local relSteer = math.clamp(math.sign(b) * curved, -1, 1)

        if ax < deadzone then relSteer = 0 end

        local normalSpeed = 100
        local maxSpeed = math.clamp(normalSpeed * (speed + 0.05) / 2.05, 0, normalSpeed * 2)
        local maxDelta = maxSpeed * ac.getScriptDeltaT()

        local delta = relSteer - steer
        local clampedDelta = math.clamp(delta, -maxDelta, maxDelta)
        steer = steer + clampedDelta

        ui.drawLine(
                f + vec2(0, (0.5 + 0.5 * steer) * s.y),
                f + vec2(s.x, (0.5 + 0.5 * steer) * s.y),
                rgbm.colors.gray,
                2 * cui.scale()
        )

        ui.drawLine(
                f + vec2((0.5 + 0.5 * b) * s.x, 0),
                f + vec2((0.5 + 0.5 * b) * s.x, s.y),
                rgbm.colors.gray,
                2 * cui.scale()
        )

        ui.drawLine(
                f + vec2((0.5 + 0.5 * b) * s.x, 0),
                f + vec2((0.5 + 0.5 * b) * s.x, s.y),
                rgbm.colors.gray,
                2 * cui.scale()
        )

        for i0 = 0, 1 do
                for i = 0, 100 do
                        local g = gamma
                        local x = (i / 100) ^ 2
                        local norm = (x - deadzone) / (1 - deadzone)

                        if x >= deadzone then
                                if i0 == 1 then
                                        ui.pathLineTo(f + vec2(0.5 + 0.5 * x, 0.5 + 0.5 * norm ^ g) * s)
                                else
                                        ui.pathLineTo(f + vec2(0.5 - 0.5 * x, 0.5 - 0.5 * norm ^ g) * s)
                                end
                        else
                                if i0 == 1 then
                                        ui.pathLineTo(f + vec2(0.5 + 0.5 * x, 0.5 + 0.5 * 0) * s)
                                else
                                        ui.pathLineTo(f + vec2(0.5 - 0.5 * x, 0.5 - 0.5 * 0) * s)
                                end
                        end
                end
                ui.pathStroke(settings.Appearance.uiColorSecondary, false, 3 * cui.scale())
        end

        ui.drawRectFilled(
                f + vec2(s.x * 0.5 - s.x * deadzone * 0.5, 0),
                f + vec2(s.x * 0.5 + s.x * deadzone * 0.5, s.y),
                rgbm.colors.black * 0.25
        )
end

local curves = {}
local curvesCache = {}

local function loadCurve(curve) return ac.DataLUT11.load(ac.getFolder(ac.FolderID.Cfg) .. "\\" .. curve) end

local function drawCurve(curve, label)
        ui.setCursorX(ui.windowWidth() * 0.1)
        local c = table.getOrCreate(curvesCache, curve, loadCurve, curve)
        if not c then
                ui.text("Curve is missing or damaged")
                return
        end
        local f, s = drawCurveBase(vec2(ui.windowWidth() * 0.8, ui.windowWidth() * 0.8))
        for i = 0, 30 do
                ui.pathLineTo(f + vec2(i / 30, c:get(i / 30)) * s)
        end
        ui.pathStroke(settings.Appearance.uiColorSecondary, false, 5)
end

local function reloadCurves()
        curves = io.scanDir(ac.getFolder(ac.FolderID.Cfg), "*.lut")
        if configs.FFPOSTPROCESS.data.LUT.CURVE and not table.indexOf(curves, configs.FFPOSTPROCESS.data.LUT.CURVE) then
                table.insert(curves, configs.FFPOSTPROCESS.data.LUT.CURVE)
        end
        if
                configs.FFPOSTPROCESS.original.LUT.CURVE
                and not table.indexOf(curves, configs.FFPOSTPROCESS.original.LUT.CURVE)
        then
                table.insert(curves, configs.FFPOSTPROCESS.original.LUT.CURVE)
        end
        table.sort(curves, function(a, b) return a < b end)
        table.clear(curvesCache)
end
reloadCurves()

function controlTweaks:body()
        cui.pushWindow("settings_controls_ffb", 0, 0, ui.windowWidth(), ui.windowHeight(), true)
        ui.setCursor(0)

        local itemWidth = ui.availableSpaceX() - 60 * cui.scale()

        cui.offsetCursorY(15)

        if controlTweaks.section == 2 then
                cui.setCursorX(30)
                local value, changed, active, hovered = cui.spinner(
                        "CAR.FFB",
                        "Car FFB Gain",
                        itemWidth,
                        80 * cui.scale(),
                        false,
                        ac.getCar(0).ffbMultiplier,
                        {
                                section = "CAR",
                                id = "CARFFB",
                                label = "Car FFB",
                                min = 0,
                                max = 2,
                                step = 0.01,
                                shiftStep = 1,
                                multiplier = 100,
                                offset = 0,
                                format = "%.0f %s",
                                unit = "%",
                                help = "",
                        },
                        true
                )

                if changed or active then ac.setFFBMultiplier(value) end
        end

        for _, tweakSection in
                ipairs(
                        controllerTweaks[configs.CONTROLS.ini:get("HEADER", "INPUT_METHOD", "WHEEL")][controlTweaks.section].content
                )
        do
                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        tweakSection.group,
                        24 * cui.scale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), 36 * cui.scale())
                )

                for _, tweak in ipairs(tweakSection.tweaks) do
                        cui.setCursorX(30)

                        local oldValue = tweak.cfg:get(tweak.section, tweak.id)

                        if tweak.items then tweak.format = tweak.items[oldValue] end

                        local value, changed, active, hovered = cui.spinner(
                                tweak.section .. tweak.id,
                                tweak.label,
                                itemWidth,
                                80 * cui.scale(),
                                false,
                                oldValue,
                                tweak,
                                true
                        )

                        if changed then tweak.cfg:set(tweak.section, tweak.id, value) end

                        if tweak.graph then
                                if sim.inputMode == ac.UserInputMode.Gamepad then
                                        drawGamepadGammaCurve()
                                else
                                        drawGammaCurve(
                                                value,
                                                tweak.cfg:get(tweak.section, "JOY"),
                                                tweak.cfg:get(tweak.section, "AXLE"),
                                                tweak.cfg:get(tweak.section, "MIN"),
                                                tweak.cfg:get(tweak.section, "MAX"),
                                                tweak.section == "STEER"
                                        )
                                end
                        end
                end
        end

        if controlTweaks.section == 2 then
                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        "FFB Gyro",
                        24 * cui.scale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), 36 * cui.scale())
                )

                local currentGyroMode = (
                        configs.FFBTWEAKS.data.BASIC.ENABLED and configs.FFBTWEAKS.data.GYRO2.ENABLED and 3
                        or configs.SYSTEM.data.FF_EXPERIMENTAL.ENABLE_GYRO and 2
                        or 1
                )
                local gyroStrings = configs.FFBTWEAKS.data.BASIC.ENABLED and { "None", "Standard", "FFB Tweaks" }
                        or { "None", "Standard" }

                cui.setCursorX(30)
                local value, changed, active, hovered = cui.spinner(
                        "GYRO.GYRO",
                        "Range compression",
                        itemWidth,
                        80 * cui.scale(),
                        false,
                        currentGyroMode,
                        {
                                min = 1,
                                max = #gyroStrings,
                                step = 1,
                                shiftStep = 1,
                                multiplier = 1,
                                offset = 0,
                                format = gyroStrings[currentGyroMode],
                                unit = "%",
                                help = "",
                        },
                        true
                )

                if changed then
                        configs.SYSTEM:set("FF_EXPERIMENTAL", "ENABLE_GYRO", value == 2)
                        configs.FFBTWEAKS:set("GYRO2", "ENABLED", value == 3)
                end
        end

        if configs.FFBTWEAKS.data.BASIC.ENABLED and controlTweaks.section == 2 then
                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        "FFB Post-Processing",
                        24 * cui.scale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), 36 * cui.scale())
                )

                cui.setCursorX(30)
                local value, changed, active, hovered = cui.spinner(
                        "POSTPROCESSING.RANGE_COMPRESSION",
                        "Range compression",
                        itemWidth,
                        80 * cui.scale(),
                        false,
                        configs.FFBTWEAKS:get("POSTPROCESSING", "RANGE_COMPRESSION"),
                        {
                                min = 0.5,
                                max = 4,
                                step = 0.01,
                                shiftStep = 1,
                                multiplier = 100,
                                offset = 0,
                                format = "%.0f %s",
                                unit = "%",
                                help = "",
                        },
                        true
                )

                if changed then configs.FFBTWEAKS:set("POSTPROCESSING", "RANGE_COMPRESSION", value) end

                if configs.FFBTWEAKS.data.POSTPROCESSING.RANGE_COMPRESSION ~= 1 then
                        cui.setCursorX(30)
                        local value, changed, active, hovered = cui.spinner(
                                "POSTPROCESSING.RANGE_COMPRESSION_ASSIST",
                                "Use Car Steer Assist",
                                itemWidth,
                                80 * cui.scale(),
                                false,
                                configs.FFBTWEAKS:get("POSTPROCESSING", "RANGE_COMPRESSION_ASSIST"),
                                {
                                        min = 0,
                                        max = 1,
                                        step = 1,
                                        shiftStep = 1,
                                        multiplier = 1,
                                        offset = 0,
                                        format = configs.FFBTWEAKS:get("POSTPROCESSING", "RANGE_COMPRESSION_ASSIST")
                                                                == 1
                                                        and "Yes"
                                                or "No",
                                        unit = "%",
                                        help = "",
                                },
                                true
                        )

                        if changed then configs.FFBTWEAKS:set("POSTPROCESSING", "RANGE_COMPRESSION_ASSIST", value) end
                end
        end

        if false then --controlTweaks.section == 2 then
                local currentPPMode = configs.FFPOSTPROCESS.data.HEADER.ENABLED
                                and (configs.FFPOSTPROCESS.data.HEADER.TYPE == "GAMMA" and 2 or 3)
                        or 1

                local ppModeStrings = { "Disabled", "Gamma", "LUT" }
                cui.setCursorX(30)
                local value, changed, active, hovered =
                        cui.spinner("PP.MODE", "Post-Process Mode", itemWidth, 80 * cui.scale(), false, currentPPMode, {
                                min = 1,
                                max = #ppModeStrings,
                                step = 1,
                                shiftStep = 1,
                                multiplier = 1,
                                offset = 0,
                                format = ppModeStrings[currentPPMode],
                                unit = "%",
                                help = "",
                        }, true)

                if changed then
                        currentPPMode = value
                        configs.FFPOSTPROCESS:set("HEADER", "ENABLED", currentPPMode ~= 1)
                        if currentPPMode ~= 1 then
                                configs.FFPOSTPROCESS:set("HEADER", "TYPE", currentPPMode == 2 and "GAMMA" or "LUT")
                        end
                end

                if currentPPMode == 2 then
                        cui.setCursorX(30)
                        local value, changed, active, hovered = cui.spinner(
                                "PP.GAMMA.VALUE",
                                "Gamma",
                                itemWidth,
                                80 * cui.scale(),
                                false,
                                configs.FFPOSTPROCESS:get("GAMMA", "VALUE"),
                                {
                                        min = 0.3,
                                        max = 3,
                                        step = 0.01,
                                        shiftStep = 0.01,
                                        multiplier = 100,
                                        offset = 0,
                                        format = "%.0f %s",
                                        unit = "%",
                                        help = "",
                                },
                                true
                        )

                        if changed then configs.FFPOSTPROCESS:set("GAMMA", "VALUE", value) end

                        drawGammaCurve(
                                configs.FFPOSTPROCESS.data.GAMMA.VALUE,
                                "Decrease above 100% to boost smaller forces, increase above 100% to attenuate smaller forces:"
                        )
                elseif currentPPMode == 3 then
                        -- ui.alignTextToFramePadding()
                        -- ui.text("Curve:")
                        -- ui.sameLine(68)
                        -- ui.setNextItemWidth(ui.availableSpaceX() - 24)
                        -- ui.combo("##ppFile", cfgFFPostProcess.data.LUT.CURVE or "None", function()
                        --         for i = 1, #curves do
                        --                 if ui.selectable(curves[i], curves[i] == cfgFFPostProcess.data.LUT.CURVE) then
                        --                         cfgFFPostProcess:set("LUT", "CURVE", curves[i])
                        --                 end
                        --                 if ui.itemHovered() then ui.tooltip(function() drawCurve(curves[i]) end) end
                        --         end
                        --         ui.separator()
                        --         if ui.selectable("Add new curve from LUT…") then importNewCurve() end
                        --         if ui.itemHovered() then
                        --                 ui.setTooltip(
                        --                         "Select a LUT file and it will be copied to “Documents/Assetto Corsa/cfg” and selected"
                        --                 )
                        --         end
                        --         if ui.selectable("Create new curve using WheelCheck…") then
                        --                 ac.setWindowOpen("createLUT", true)
                        --         end
                        --         if ui.itemHovered() then
                        --                 ui.setTooltip("Create new curve for your steering wheel using WheelCheck")
                        --         end
                        -- end)

                        local currentCurve = configs.FFPOSTPROCESS.data.LUT.CURVE or curves[1]
                        local currentCurveIndex = 2

                        for i = 1, #curves do
                                if curves[i] == currentCurve then currentCurveIndex = i end
                        end

                        cui.setCursorX(30)
                        local value, changed, active, hovered = cui.spinner(
                                "LUT.CURVES",
                                "Curves ( %s )" % #curves,
                                itemWidth,
                                80 * cui.scale(),
                                false,
                                currentCurveIndex,
                                {
                                        min = 1,
                                        max = #curves,
                                        step = 1,
                                        shiftStep = 1,
                                        multiplier = 1,
                                        offset = 0,
                                        format = curves[currentCurveIndex],
                                        unit = "%",
                                        help = "",
                                },
                                true
                        )

                        if changed then
                                currentCurveIndex = value
                                configs.FFPOSTPROCESS:set("LUT", "CURVE", curves[currentCurveIndex])
                        end

                        drawCurve(curves[currentCurveIndex])
                else
                        ui.dummy(ui.windowWidth() * 0.8 + 118 * cui.scale())
                end
        end

        cui.popWindow(true)
end

return controlTweaks
