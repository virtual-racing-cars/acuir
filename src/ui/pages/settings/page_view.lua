local page = {}

local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local settings = require("settings")
local sim = ac.getSim()
local firstPersonCameraFOV = sim.firstPersonCameraFOV

local bottomBarButtons = {
        {
                label = "BACK",
                enabled = true,
                func = function() pages:undo() end,
        },
        {
                label = "RESET TO DEFAULT",
                enabled = true,
                func = function()
                        ac.setOnboardCameraParams(0, ac.getOnboardCameraDefaultParams(0), false)
                        ac.resetFirstPersonCameraFOV()
                end,
        },
        {
                label = "RESET",
                enabled = false,
                func = function()
                        ac.setOnboardCameraParams(0, ac.getOnboardCameraDefaultParams(0), false)
                        ac.setFirstPersonCameraFOV(firstPersonCameraFOV)
                end,
        },
        {
                label = "SAVE",
                enabled = true,
                func = function()
                        firstPersonCameraFOV = sim.firstPersonCameraFOV
                        ac.setOnboardCameraParams(0, ac.getOnboardCameraParams(0), true)
                end,
        },
}

local onboardParamsDefaults = ac.getOnboardCameraDefaultParams(0)

local views = {
        {
                id = "SEAT.PARAM.HEIGHT",
                label = "Height",
                min = 0,
                max = 2,
                step = 0.0001,
                multiplier = 100,
                format = "%.2f %s",
                unit = "cm",
                default = onboardParamsDefaults.position.y,
                get = function(seatParams) return seatParams.position.y end,
                set = function(seatParams, newValue)
                        seatParams.position.y = newValue
                        ac.setCurrentCamera(ac.CameraMode.Cockpit)
                        ac.setOnboardCameraParams(0, seatParams, false)
                end,
        },
        {
                id = "SEAT.PARAM.LATERAL",
                label = "Lateral",
                min = -1,
                max = 1,
                step = 0.0001,
                multiplier = -100,
                format = "%.2f %s",
                unit = "cm",
                default = -onboardParamsDefaults.position.x,
                get = function(seatParams) return -seatParams.position.x end,
                set = function(seatParams, newValue)
                        seatParams.position.x = -newValue
                        ac.setCurrentCamera(ac.CameraMode.Cockpit)
                        ac.setOnboardCameraParams(0, seatParams, false)
                end,
        },
        {
                id = "SEAT.PARAM.DISTANCE",
                label = "Distance",
                min = -2,
                max = 2,
                step = 0.0001,
                multiplier = 100,
                format = "%.2f %s",
                unit = "cm",
                default = onboardParamsDefaults.position.z,
                get = function(seatParams) return seatParams.position.z end,
                set = function(seatParams, newValue)
                        seatParams.position.z = newValue
                        ac.setCurrentCamera(ac.CameraMode.Cockpit)
                        ac.setOnboardCameraParams(0, seatParams, false)
                end,
        },
        {
                id = "SEAT.PARAM.FOV",
                label = "FOV",
                min = 1,
                max = 125,
                step = 0.01,
                multiplier = 1,
                format = "%.2f %s",
                unit = "°",
                default = 56,
                get = function(seatParams) return sim.firstPersonCameraFOV end,
                set = function(seatParams, newValue)
                        ac.setCurrentCamera(ac.CameraMode.Cockpit)
                        ac.setFirstPersonCameraFOV(newValue)
                end,
        },
        {
                id = "SEAT.PARAM.PITCH",
                label = "Pitch",
                min = -14,
                max = 14,
                step = 0.01,
                multiplier = 1,
                format = "%.3f %s",
                unit = "°",
                default = onboardParamsDefaults.pitch,
                get = function(seatParams) return seatParams.pitch end,
                set = function(seatParams, newValue)
                        seatParams.pitch = newValue
                        ac.setCurrentCamera(ac.CameraMode.Cockpit)
                        ac.setOnboardCameraParams(0, seatParams, false)
                end,
        },
        {
                id = "SEAT.PARAM.YAW",
                label = "Yaw",
                min = -45,
                max = 45,
                step = 0.01,
                multiplier = 1,
                format = "%.3f %s",
                unit = "°",
                default = onboardParamsDefaults.yaw,
                get = function(seatParams) return seatParams.yaw end,
                set = function(seatParams, newValue)
                        seatParams.yaw = newValue
                        ac.setCurrentCamera(ac.CameraMode.Cockpit)
                        ac.setOnboardCameraParams(0, seatParams, false)
                end,
        },
}

function page:draw()
        ui.drawSimpleLine(
                vec2(ui.windowWidth() * 0.5, 0),
                vec2(ui.windowWidth() * 0.5, ui.windowHeight()),
                settings.Appearance.uiColorSecondary
        )

        cui.pushWindowFitted("settings_view_main_window")
        ui.drawRectFilled(0, vec2(ui.windowWidth(), 130 * cui.uiScale()), rgbm(0.1, 0.1, 0.1, 0.95))

        topSubBar("View")

        cui.pushWindow("settings_view_window", 0, 180 * cui.uiScale(), ui.windowWidth(), ui.windowHeight() * 0.8, false)

        ui.drawRectFilled(
                vec2(0, 0),
                vec2(ui.windowWidth(), ui.windowHeight() * 0.3),
                settings.Appearance.uiColorPrimary * 0.2,
                12 * cui.uiScale()
        )

        local onboardParams = ac.getOnboardCameraParams(0)

        cui.setCursorY(10)
        for i, viewSetting in ipairs(views) do
                if i % 2 == 0 then
                        ui.sameLine()
                        ui.setCursorX(ui.windowWidth() * 0.5)
                else
                        ui.setCursorX(0)
                end

                local value, changed = drawSpinner(
                        "##" .. viewSetting.id,
                        viewSetting.label,
                        ui.windowWidth() * 0.5,
                        95 * cui.uiScale(),
                        false,
                        viewSetting.get(onboardParams),
                        {
                                min = viewSetting.min,
                                max = viewSetting.max,
                                step = viewSetting.step,
                                shiftStep = 1,
                                multiplier = viewSetting.multiplier,
                                default = viewSetting.default,
                                offset = 0,
                                format = viewSetting.format,
                                unit = viewSetting.unit,
                                help = "",
                        }
                )

                if changed then viewSetting.set(onboardParams, value) end
        end

        -- bottomBarButtons[2].enabled = ac.areOnboardCameraParamsNeedSaving()

        cui.popWindow()
        bottomBar(bottomBarButtons)
        cui.popWindow()

        return ""
end

return page
