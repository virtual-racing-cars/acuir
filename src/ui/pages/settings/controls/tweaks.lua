local configs = require("configs")
local controllerTweaks = require("controller_tweaks")
local cui = require("src.ui.cui")
local settings = require("settings")
local sim = ac.getSim()

local tweaks = {}

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

local function drawGammaCurve(value, label)
        ui.setCursorX(ui.windowWidth() * 0.1)
        local f, s = drawCurveBase(vec2(ui.windowWidth() * 0.8, ui.windowWidth() * 0.2))
        for i = 0, 30 do
                local x = (i / 30) ^ 2
                ui.pathLineTo(f + vec2(x, x ^ value) * s)
        end
        ui.pathStroke(settings.Appearance.uiColorSecondary, false, 3 * cui.uiScale())
end

local function drawGamepadGammaCurve()
        ui.setCursorX(ui.windowWidth() * 0.1)
        local f, s = drawCurveBase(vec2(ui.windowWidth() * 0.8, ui.windowWidth() * 0.2))
        local b = ac.getGamepadAxisValue(
                0,
                configs.CONTROLS.data.X360.STEER_THUMB == "LEFT" and ac.GamepadAxis.LeftThumbX
                        or ac.GamepadAxis.RightThumbX
        )
        local relSteer = ac.getCar(0).steer / 396
        ui.drawLine(
                f + vec2(0, (0.5 + 0.5 * relSteer) * s.y),
                f + vec2(s.x, (0.5 + 0.5 * relSteer) * s.y),
                rgbm.colors.gray,
                2 * cui.uiScale()
        )
        ui.drawLine(
                f + vec2((0.5 + 0.5 * b) * s.x, 0),
                f + vec2((0.5 + 0.5 * b) * s.x, s.y),
                rgbm.colors.gray,
                2 * cui.uiScale()
        )

        local v = configs.CONTROLS.data.X360.STEER_GAMMA
        if v == 0 then v = 1 end
        for i0 = 0, 1 do
                for i = 0, 30 do
                        local x = (i / 30) ^ 2
                        if i0 == 1 then
                                ui.pathLineTo(f + vec2(0.5 + 0.5 * x, 0.5 + 0.5 * x ^ v) * s)
                        else
                                ui.pathLineTo(f + vec2(0.5 - 0.5 * x, 0.5 - 0.5 * x ^ v) * s)
                        end
                end
                ui.pathStroke(settings.Appearance.uiColorSecondary, false, 3 * cui.uiScale())
        end
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

local currentSection = 1

function tweaks:draw()
        cui.pushWindow(
                "settings_controls_ffb",
                ui.windowWidth() * 0.75,
                0,
                ui.windowWidth() * 0.25,
                ui.windowHeight(),
                false
        )

        ui.setCursor(0)

        local deviceTabs = controllerTweaks[configs.CONTROLS.ini:get("HEADER", "INPUT_METHOD", "WHEEL")]
        for i, tab in ipairs(deviceTabs) do
                if
                        cui.menuButton(
                                tab.label,
                                vec2(ui.windowWidth() / #deviceTabs, 50 * cui.uiScale()),
                                0,
                                0,
                                0,
                                currentSection == i,
                                false
                        )
                then
                        currentSection = i
                end
                ui.sameLine()
        end

        cui.pushWindow(
                "settings_controls_ffb",
                0,
                50 * cui.uiScale(),
                ui.windowWidth(),
                ui.windowHeight() - 50 * cui.uiScale(),
                true
        )
        ui.setCursor(0)
        ui.offsetCursorY(20)

        if currentSection == 2 then
                ui.setCursorX(ui.windowWidth() * 0.01)
                local value, changed, active, hovered = drawSpinner(
                        "CAR.FFB",
                        "Car FFB Gain",
                        ui.windowWidth() * 0.98,
                        80 * cui.uiScale(),
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
                        controllerTweaks[configs.CONTROLS.ini:get("HEADER", "INPUT_METHOD", "WHEEL")][currentSection].content
                )
        do
                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        tweakSection.group,
                        24 * cui.uiScale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), 36 * cui.uiScale())
                )

                for _, tweak in ipairs(tweakSection.tweaks) do
                        ui.setCursorX(ui.windowWidth() * 0.01)

                        local oldValue = tweak.cfg:get(tweak.section, tweak.id)

                        if tweak.items then tweak.format = tweak.items[oldValue] end

                        local value, changed, active, hovered = drawSpinner(
                                tweak.section .. tweak.id,
                                tweak.label,
                                ui.windowWidth() * 0.98,
                                80 * cui.uiScale(),
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
                                        drawGammaCurve(value)
                                end
                        end
                end
        end

        if currentSection == 2 then
                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        "FFB Gyro",
                        24 * cui.uiScale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), 36 * cui.uiScale())
                )

                local currentGyroMode = (
                        configs.FFBTWEAKS.data.BASIC.ENABLED and configs.FFBTWEAKS.data.GYRO2.ENABLED and 3
                        or configs.SYSTEM.data.FF_EXPERIMENTAL.ENABLE_GYRO and 2
                        or 1
                )
                local gyroStrings = configs.FFBTWEAKS.data.BASIC.ENABLED and { "None", "Standard", "FFB Tweaks" }
                        or { "None", "Standard" }

                ui.setCursorX(ui.windowWidth() * 0.01)
                local value, changed, active, hovered = drawSpinner(
                        "GYRO.GYRO",
                        "Range compression",
                        ui.windowWidth() * 0.98,
                        80 * cui.uiScale(),
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

        if configs.FFBTWEAKS.data.BASIC.ENABLED and currentSection == 2 then
                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        "FFB Post-Processing",
                        24 * cui.uiScale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), 36 * cui.uiScale())
                )

                ui.setCursorX(ui.windowWidth() * 0.01)
                local value, changed, active, hovered = drawSpinner(
                        "POSTPROCESSING.RANGE_COMPRESSION",
                        "Range compression",
                        ui.windowWidth() * 0.98,
                        80 * cui.uiScale(),
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
                        ui.setCursorX(ui.windowWidth() * 0.01)
                        local value, changed, active, hovered = drawSpinner(
                                "POSTPROCESSING.RANGE_COMPRESSION_ASSIST",
                                "Use Car Steer Assist",
                                ui.windowWidth() * 0.98,
                                80 * cui.uiScale(),
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

        if false then --currentSection == 2 then
                local currentPPMode = configs.FFPOSTPROCESS.data.HEADER.ENABLED
                                and (configs.FFPOSTPROCESS.data.HEADER.TYPE == "GAMMA" and 2 or 3)
                        or 1

                local ppModeStrings = { "Disabled", "Gamma", "LUT" }
                ui.setCursorX(ui.windowWidth() * 0.01)
                local value, changed, active, hovered = drawSpinner(
                        "PP.MODE",
                        "Post-Process Mode",
                        ui.windowWidth() * 0.98,
                        80 * cui.uiScale(),
                        false,
                        currentPPMode,
                        {
                                min = 1,
                                max = #ppModeStrings,
                                step = 1,
                                shiftStep = 1,
                                multiplier = 1,
                                offset = 0,
                                format = ppModeStrings[currentPPMode],
                                unit = "%",
                                help = "",
                        },
                        true
                )

                if changed then
                        currentPPMode = value
                        configs.FFPOSTPROCESS:set("HEADER", "ENABLED", currentPPMode ~= 1)
                        if currentPPMode ~= 1 then
                                configs.FFPOSTPROCESS:set("HEADER", "TYPE", currentPPMode == 2 and "GAMMA" or "LUT")
                        end
                end

                if currentPPMode == 2 then
                        ui.setCursorX(ui.windowWidth() * 0.01)
                        local value, changed, active, hovered = drawSpinner(
                                "PP.GAMMA.VALUE",
                                "Gamma",
                                ui.windowWidth() * 0.98,
                                80 * cui.uiScale(),
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

                        ui.setCursorX(ui.windowWidth() * 0.01)
                        local value, changed, active, hovered = drawSpinner(
                                "LUT.CURVES",
                                "Curves ( %s )" % #curves,
                                ui.windowWidth() * 0.98,
                                80 * cui.uiScale(),
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
                        ui.dummy(ui.windowWidth() * 0.8 + 118 * cui.uiScale())
                end
        end

        cui.popWindow(true)

        cui.popWindow()
end

return tweaks
