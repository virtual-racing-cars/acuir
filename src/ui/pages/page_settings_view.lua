local page = {}

local cui = require("ui.cui")
local pages = require("ui.pages")
local settings = require("settings")
local style = require("ui.cui.style")
local sim = ac.getSim()

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local firstPersonCameraFOV = sim.firstPersonCameraFOV
local onboardParamsDefaults = ac.getOnboardCameraDefaultParams(0)

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
                label = "RESET TO SAVED",
                enabled = true,
                func = function()
                        ac.setOnboardCameraParams(0, onboardParamsDefaults, false)
                        ac.setFirstPersonCameraFOV(firstPersonCameraFOV)
                end,
        },
        {
                label = "SAVE",
                enabled = true,
                func = function()
                        firstPersonCameraFOV = sim.firstPersonCameraFOV
                        ac.setOnboardCameraParams(0, ac.getOnboardCameraParams(0), true)
                        onboardParamsDefaults = ac.getOnboardCameraParams(0)
                end,
        },
}

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
        ui.forceSimplifiedComposition()

        ui.drawSimpleLine(
                vec2Temp1:set(ui.windowWidth() * 0.5, 0),
                vec2Temp2:set(ui.windowWidth() * 0.5, ui.windowHeight()),
                settings.Appearance.uiColorSecondary
        )

        cui.pushFittedWindow("settings_view_main_window")
        ui.drawRectFilled(
                0,
                vec2Temp1:set(ui.windowWidth(), 130 * cui.scale()),
                settings.Appearance.uiColorBackground,
                12 * cui.scale()
        )

        topSubBar("View")

        cui.pushContentWindow(
                "settings_view_window",
                0,
                180 * cui.scale(),
                ui.windowWidth(),
                style.main.font.header.space * 8,
                nil,
                function() end,
                true
        )

        local onboardParams = ac.getOnboardCameraParams(0)

        ui.setCursorY(style.main.font.header.space * 0.25)
        for i, viewSetting in ipairs(views) do
                if i % 2 == 0 then
                        ui.sameLine()
                        ui.setCursorX(ui.windowWidth() * 0.5 + 30 * cui.scale())
                else
                        cui.setCursorX(30)
                end

                local value, changed = cui.spinner(
                        "##" .. viewSetting.id,
                        viewSetting.label,
                        ui.windowWidth() * 0.5 - 60 * cui.scale(),
                        95 * cui.scale(),
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

        bottomBarButtons[3].enabled = ac.areOnboardCameraParamsNeedSaving()

        cui.popContentWindow()
        bottomBar(bottomBarButtons)
        cui.popWindow()

        return ""
end

return page
