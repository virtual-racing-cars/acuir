require("classes.ControlBinding")
require("classes.ControlTabBar")
local keyIndexKey = require("keys")
local settings = require("settings")
local controlsINI = ac.INIConfig.controlsConfig()

local controls = {
        preset = controlsINI:get("__LAUNCHER_CM", "PRESET_NAME", nil),
}

-- local carSpecificPreset = controlsINI:get("__LAUNCHER_CM", "PRESET_NAME", "")
-- local carSpecificPresetEnabled = controlsINI:get("__LAUNCHER_CM", "PRESET_CHANGED", -1) == 0

-- if carSpecificPresetEnabled then
--         carSpecificPreset =
--                 string.replace(string.replace(carSpecificPreset, "savedSetups\\", ""), ".ini", "")
-- end

ac.reloadControlSettings()

ac.onControlSettingsChanged(function() controlsINI = ac.INIConfig.controlsConfig() end)

-- local cfgInputGeneral = MappedConfig(ac.getFolder(ac.FolderID.ExtCfgUser) .. "/general.ini", {
-- 	CONTROL = { NO_MOUSE_STEERING_FOR_INACTIVE = false },
-- })

local bindSectionKeyDefaults = {
        NAME = "",
        TAB = "Generic",
        ORDER = 0,
        REQUIRED = 0,
        ACTIVATION = 0,
        POS = 0,
        DN = 0,
        UP = 0,
        DN_LABEL = "Decrease",
        UP_LABEL = "Increase",
        POS_LABEL_OFFSET = 0,
        POS_LABEL = "Position",
        POS_UNIT = "",
        HOLD_MODE = 0,
        EXT_PHYSICS = 0,
        LUA = 0,
        HELP = "",
}

local function controlsINIDefaults(bind, bindSection, key, default, isCMBind)
        if not bindSection[key] or bindSection[key][1] == "" or bindSection[key][1] == nil then
                local initialValue = bindSection[key] and bindSection[key][1] or nil

                if key == "NAME" then default = bind end

                bindSection[key] = { default }

                if initialValue ~= "" and not isCMBind and settings.General.developerMode then
                        ac.log("[" .. bind .. "] Section is missing " .. key .. " key: Default value: " .. default)
                end
        end

        bindSection[key] = bindSection[key][1]
end

local function loadControls(name, controlsINI)
        local controlsTabBar = ControlsTabBar(name)
        for _i, key in controlsINI:iterateValues("TAB_ORDER", "TAB", true) do
                controlsTabBar:addTab(controlsINI.sections["TAB_ORDER"][key][1])
        end

        for bind, _v in pairs(controlsINI.sections) do
                if bind ~= "TAB_ORDER" then
                        local bindSection = controlsINI.sections[bind]

                        for key, value in pairs(bindSectionKeyDefaults) do
                                controlsINIDefaults(bind, bindSection, key, value)
                        end

                        local controlBinding = ControlBinding(
                                bind,
                                bindSection.NAME,
                                bindSection.TAB,
                                tonumber(bindSection.ORDER),
                                tonumber(bindSection.LUA) == 1,
                                tonumber(bindSection.EXT_PHYSICS) == 1,
                                bindSection.HELP,
                                tonumber(bindSection.ACTIVATION) == 1,
                                bindSection.ACTIVATION_LABEL,
                                tonumber(bindSection.HOLD_MODE) == 1,
                                tonumber(bindSection.DN) ~= 0 and tonumber(bindSection.UP) ~= 0,
                                bindSection.DN,
                                bindSection.DN_LABEL,
                                bindSection.UP,
                                bindSection.UP_LABEL,
                                tonumber(bindSection.POS) > 0,
                                tonumber(bindSection.POS_LABEL_OFFSET),
                                bindSection.POS_LABEL,
                                bindSection.POS_UNIT,
                                tonumber(bindSection.POS)
                        )

                        controlsTabBar:addControl(controlBinding)
                end
        end

        return controlsTabBar
end

local function getCarControls()
        local carControlsFile = ac.getFolder(ac.FolderID.ContentCars)
                .. "\\"
                .. ac.getCarID(0)
                .. "\\extension\\ext_car_controls.ini"

        if not io.fileExists(carControlsFile) then carControlsFile = ac.dirname() .. "\\cfg\\car_controls.ini" end

        local carControlsINI = ac.INIConfig.load(carControlsFile)

        return loadControls("Car", carControlsINI)
end

local function getAppControls()
        local luaDirectory = ac.getFolder(ac.FolderID.ACApps) .. "\\lua"

        local appControls = {}
        io.scanDir(luaDirectory, function(fileName, fileAttributes, callbackData)
                local appDirectory = luaDirectory .. "\\" .. fileName

                if not io.dirExists(appDirectory) then return end

                local appControlsFile = appDirectory .. "\\ext_app_controls.ini"

                if not io.fileExists(appControlsFile) then return end

                local appControlsINI = ac.INIConfig.load(appControlsFile)

                local appManifestFile = appDirectory .. "\\manifest.ini"
                local appManifestINI = ac.INIConfig.load(appManifestFile, ac.INIFormat.Extended)
                local appName = appManifestINI:get("ABOUT", "NAME", fileName)

                table.insert(appControls, loadControls(appName, appControlsINI))
        end)

        return appControls
end

local function getContentManagerControls()
        local contentManagerControlsFile = ac.dirname() .. "\\cfg\\cm_controls.ini"
        local contentManagerControlsINI = ac.INIConfig.load(contentManagerControlsFile)

        return loadControls("Content Manager", contentManagerControlsINI)
end

controls.apps = nil

local inputDeviceKeys = {
        "JOY",
        "KEY",
        "XBOXBUTTON",
}

controls.inputMethod = ""

controls.boundDevices = {
        { "Steering", "None" },
        { "Throttle", "None" },
        { "Brakes", "None" },
        { "Clutch", "None" },
        { "Handbrake", "None" },
}

controls.controllers = {}

local conIndex = 0
while controlsINI:get("CONTROLLERS", "CON%s" % conIndex, nil) do
        table.insert(controls.controllers, conIndex, {
                CON = controlsINI:get("CONTROLLERS", "CON%s" % conIndex, ""),
                PGUID = controlsINI:get("CONTROLLERS", "PGUID%s" % conIndex, ""),
                __IGUID = controlsINI:get("CONTROLLERS", "__IGUID%s" % conIndex, ""),
        })

        conIndex = conIndex + 1
end

local function controllerListener()
        local button1 = -1
        local button2 = -1

        for i = 0, ac.getJoystickCount() - 1 do
                for ii = 0, ac.getJoystickButtonsCount(i) do
                        if ac.isJoystickButtonPressed(i, ii) then
                                if button1 == -1 then
                                        button1 = ii
                                elseif button2 == -1 then
                                        button2 = ii

                                        return button1, button2
                                end
                        end
                end
        end

        return button1, button2
end

local function gamepadListener()
        local button1 = -1
        local button2 = -1

        for i = 0, 7 do
                for k, ii in pairs(ac.GamepadButton) do
                        if ac.isGamepadButtonPressed(i, ii) then
                                if button1 == -1 then
                                        button1 = k
                                elseif button2 == -1 then
                                        button2 = k

                                        return button1, button2
                                end
                        end
                end
        end

        return button1, button2
end

local function keyboardListener() end

local inputListeners = {
        controllerListener,
        gamepadListener,
        keyboardListener,
}

function controls:listener(inputMethod)
        inputListeners[3]()

        if inputMethod == 3 then return end

        return inputListeners[inputMethod]()
end

local function buttonString(button, buttonMod)
        if button == -1 then return "" end

        if buttonMod == -1 then return string.format("Button %s", button) end

        return string.format("Button %s + Button %s", button, buttonMod)
end

local function keybindString(key, keyMod)
        if not key or key == -1 then return "" end

        if not keyMod or keyMod == -1 then return string.format("%s", key) end

        return string.format("%s + %s", key, keyMod)
end

local function controllerBoundTo(bind)
        local con = controlsINI:get(bind, "JOY", -1)
        local button = controlsINI:get(bind, "BUTTON", -1)
        local buttonMod = controlsINI:get(bind, "BUTTON_MODIFICATOR", -1)

        if con >= 0 then
                return controls.controllers[con].CON, buttonString(button, buttonMod)
        else
                return "", "Click to Assign"
        end
end

local function gamepadBoundTo(bind)
        local con = controlsINI:get(bind, "XBOXBUTTON", "")

        if con ~= "" then
                return "Gamepad", con
        else
                return "", "Click to Assign"
        end
end

local function keyBoundTo(bind)
        local key = controlsINI:get(bind, "KEY", -1)
        local keyMod = controlsINI:get(bind, "KEY_MODIFICATOR", -1)

        if key ~= -1 then
                return "Keyboard", keybindString(keyIndexKey[key], keyIndexKey[keyMod])
        else
                return "", "Click to Assign"
        end
end

local bindingBoxCon = {
        controllerBoundTo,
        gamepadBoundTo,
        keyBoundTo,
}

function controls:boundTo(inputMethod, bind) return bindingBoxCon[inputMethod](bind) end

local inputMethods = {
        WHEEL = 1,
        X360 = 2,
        KEYBOARD = 3,
}

local function getInputMethodIndex()
        local inputMethodString = controlsINI:get("HEADER", "INPUT_METHOD", "")

        if inputMethods[inputMethodString] then
                return inputMethods[inputMethodString]
        else
                return 1
        end
end

function controls:initialize()
        controls.apps = getAppControls()
        controls.inputMethod = getInputMethodIndex()

        table.insert(controls.apps, 1, getContentManagerControls())
        table.insert(controls.apps, 1, getCarControls())

        for k, v in ipairs(controls.boundDevices) do
                for i in ipairs(inputDeviceKeys) do
                        local conIndex = controlsINI:get(string.upper(v[1]), inputDeviceKeys[i], -1)
                        if conIndex ~= -1 then
                                local device = controlsINI:get("CONTROLLERS", "CON%s" % conIndex, "")

                                controls.boundDevices[k][2] = device
                        end
                end
        end
end

return controls
