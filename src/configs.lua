local MappedConfig = require("classes.MappedConfig")

local configs = {
        CM = ac.INIConfig.load(ac.dirname() .. "\\cfg\\cm_controls.ini"),
        CAR_DEFAULT = ac.INIConfig.load(ac.dirname() .. "\\cfg\\car_controls.ini"),
        CAR_DRIVING = ac.INIConfig.load(ac.dirname() .. "\\cfg\\axis_controls.ini"),
        CAR = ac.INIConfig.load(
                ac.getFolder(ac.FolderID.ContentCars) .. "\\" .. ac.getCarID(0) .. "\\extension\\ext_car_controls.ini"
        ),
        CONTROLS = MappedConfig(ac.getFolder(ac.FolderID.Cfg) .. "/controls.ini", {
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
        }),

        FFPOSTPROCESS = MappedConfig(ac.getFolder(ac.FolderID.Cfg) .. "/ff_post_process.ini", {
                HEADER = { TYPE = ac.INIConfig.OptionalString, ENABLED = false },
                GAMMA = { VALUE = 1 },
                LUT = { CURVE = ac.INIConfig.OptionalString },
        }),

        SYSTEM = MappedConfig(ac.getFolder(ac.FolderID.Root) .. "/system/cfg/assetto_corsa.ini", {
                FF_EXPERIMENTAL = { ENABLE_GYRO = false, DAMPER_MIN_LEVEL = 0, DAMPER_GAIN = 1 },
                LOW_SPEED_FF = { SPEED_KMH = 3, MIN_VALUE = 0.01 },
        }),

        CSPGENERAL = MappedConfig(ac.getFolder(ac.FolderID.ExtCfgUser) .. "/general.ini", {
                CONTROL = { NO_MOUSE_STEERING_FOR_INACTIVE = false },
        }),

        FFBTWEAKS = MappedConfig(ac.getFolder(ac.FolderID.ExtCfgUser) .. "/ffb_tweaks.ini", {
                BASIC = { ENABLED = true },
                GYRO2 = { ENABLED = false, STRENGTH = 0.25 },
                POSTPROCESSING = { RANGE_COMPRESSION = 1, RANGE_COMPRESSION_ASSIST = false },
        }),
}

return configs
