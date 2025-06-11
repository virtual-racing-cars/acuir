local sim = ac.getSim()

local ControlBinding = require("src.classes.ControlBinding")
local ControlTab = require("src.classes.ControlTab")
local MappedConfig = require("src.classes.MappedConfig")
local controlsINI = ac.INIConfig.controlsConfig()

local controls = {
        preset = controlsINI:get("__LAUNCHER_CM", "PRESET_NAME", nil),
        inputMethod = controlsINI:get("HEADER", "INPUT_METHOD", "WHEEL"),
        inputMod = 0,
        tabs = {},
        binds = {},
        cfg = {},
}

controls.cfg.controls = MappedConfig(ac.getFolder(ac.FolderID.Cfg) .. "/controls.ini", {
        HEADER = { INPUT_METHOD = ac.INIConfig.OptionalString },
        KEYBOARD = {
                MOUSE_STEER = false,
                MOUSE_ACCELERATOR_BRAKE = false,
                STEERING_SPEED = 1.75,
                STEERING_OPPOSITE_DIRECTION_SPEED = 2.5,
                STEER_RESET_SPEED = 1.8,
                MOUSE_SPEED = 0.1,
                GAS = 0,
                BRAKE = 0,
                RIGHT = 0,
                LEFT = 0,
                GEAR_UP = 0,
                GEAR_DOWN = 0,
                HANDBRAKE = 0,
        },
        __EXT_KEYBOARD = { SHIFT_WITH_WHEEL = false, SHIFT_WITH_XBUTTONS = false },
        __EXT_KEYBOARD_GAS_RAW = {
                OVERRIDE = 0,
                LAG_UP = 0.5,
                LAG_DOWN = 0.2,
                KEY_MODIFICATOR = -1,
                KEY = -1,
                MOUSE = 0,
                MOUSE_MODIFICATOR = 0,
        },
        X360 = {
                STEER_GAMMA = 2,
                STEER_FILTER = 0.7,
                SPEED_SENSITIVITY = 0.1,
                STEER_DEADZONE = 0,
                RUMBLE_INTENSITY = 0.5,
                STEER_SPEED = 0.2,
                STEER_THUMB = "LEFT",
                JOYPAD_INDEX = 0,
                AXIS_REMAP_THROTTLE = 1,
                AXIS_REMAP_BRAKES = 0,
        },
        STEER = {
                JOY = 0,
                AXLE = -1,
                LOCK = 1080,
                FF_GAIN = 0.8,
                FILTER_FF = 0,
                STEER_GAMMA = 1,
                SPEED_SENSITIVITY = 0,
                DEBOUNCING_MS = 50,
        },
        FF_TWEAKS = { MIN_FF = 0.03, CENTER_BOOST_GAIN = 0, CENTER_BOOST_RANGE = 0.1 },
        FF_ENHANCEMENT = { CURBS = 0.3, ROAD = 0.3, SLIPS = 0.15, ABS = 0.2 },
        FF_ENHANCEMENT_2 = { UNDERSTEER = 0 },
        FF_SKIP_STEPS = { VALUE = 1 },
        THROTTLE = { JOY = 0, AXLE = -1, MIN = -1, MAX = 1, GAMMA = 1 },
        BRAKES = { JOY = 0, AXLE = -1, MIN = 1, MAX = -1, GAMMA = 2.8 },
        CLUTCH = { JOY = 0, AXLE = -1, MIN = 1, MAX = -1, GAMMA = 1 },
        HANDBRAKE = { JOY = 0, AXLE = -1, MIN = 1, MAX = -1, GAMMA = 1 },
})

controls.cfg.ffPostProcess = MappedConfig(ac.getFolder(ac.FolderID.Cfg) .. "/ff_post_process.ini", {
        HEADER = { TYPE = ac.INIConfig.OptionalString, ENABLED = false },
        GAMMA = { VALUE = 1 },
        LUT = { CURVE = ac.INIConfig.OptionalString },
})

controls.cfg.system = MappedConfig(ac.getFolder(ac.FolderID.Root) .. "/system/cfg/assetto_corsa.ini", {
        FF_EXPERIMENTAL = { ENABLE_GYRO = false, DAMPER_MIN_LEVEL = 0, DAMPER_GAIN = 1 },
        LOW_SPEED_FF = { SPEED_KMH = 3, MIN_VALUE = 0.01 },
})

controls.cfg.cspGeneral = MappedConfig(ac.getFolder(ac.FolderID.ExtCfgUser) .. "/general.ini", {
        CONTROL = { NO_MOUSE_STEERING_FOR_INACTIVE = false },
})

controls.cfg.ffbTweaks = MappedConfig(ac.getFolder(ac.FolderID.ExtCfgUser) .. "/ffb_tweaks.ini", {
        BASIC = { ENABLED = true },
        GYRO2 = { ENABLED = false, STRENGTH = 0.25 },
        POSTPROCESSING = { RANGE_COMPRESSION = 1, RANGE_COMPRESSION_ASSIST = false },
})

-- controls.cfg.ffPostProcess.ini:setAndSave("HEADER", "ENABLED", 1)

controls.cfg.controls.ini:setAndSave("FF_ENHANCEMENT", "CURBS", 0.2)

local contentManagerControlsINI = ac.INIConfig.load(ac.dirname() .. "\\cfg\\cm_controls.ini")
local carControlsFile = ac.getFolder(ac.FolderID.ContentCars)
        .. "\\"
        .. ac.getCarID(0)
        .. "\\extension\\ext_car_controls.ini"

if not io.fileExists(carControlsFile) then carControlsFile = ac.dirname() .. "\\cfg\\car_controls.ini" end
local carControlsINI = ac.INIConfig.load(carControlsFile)

ac.onControlSettingsChanged(function() controlsINI = ac.INIConfig.controlsConfig() end)

local function initializeControlTab(name, ini)
        local controlTab = ControlTab(name)
        for _, key in ini:iterateValues("TAB_ORDER", "TAB", true) do
                controlTab:addGroup(ini.sections["TAB_ORDER"][key][1])
        end

        for bind, _ in pairs(ini.sections) do
                if bind ~= "TAB_ORDER" then controlTab:addControl(ControlBinding(bind, ini, controls)) end
        end

        return controlTab
end

function controls:initialize()
        io.scanDir(ac.getFolder(ac.FolderID.ACAppsLua), function(fileName, fileAttributes, callbackData)
                local appDirectory = ac.getFolder(ac.FolderID.ACAppsLua) .. "\\" .. fileName
                local appControlsFile = appDirectory .. "\\ext_app_controls.ini"

                if not io.fileExists(appControlsFile) then return end

                local appName = ac.INIConfig
                        .load(appDirectory .. "\\manifest.ini", ac.INIFormat.Extended)
                        :get("ABOUT", "NAME", fileName)

                table.insert(controls.tabs, initializeControlTab(appName, ac.INIConfig.load(appControlsFile)))
        end)

        controls.input = sim.inputMode > 1 and 1 or 0

        table.insert(controls.tabs, 1, initializeControlTab("General", contentManagerControlsINI))
        table.insert(controls.tabs, 1, initializeControlTab("Car", carControlsINI))
end

return controls

-- local carSpecificPreset = controlsINI:get("__LAUNCHER_CM", "PRESET_NAME", "")
-- local carSpecificPresetEnabled = controlsINI:get("__LAUNCHER_CM", "PRESET_CHANGED", -1) == 0

-- if carSpecificPresetEnabled then
--         carSpecificPreset =
--                 string.replace(string.replace(carSpecificPreset, "savedSetups\\", ""), ".ini", "")
-- end

-- local cfgInputGeneral = MappedConfig(ac.getFolder(ac.FolderID.ExtCfgUser) .. "/general.ini", {
-- 	CONTROL = { NO_MOUSE_STEERING_FOR_INACTIVE = false },
-- })
