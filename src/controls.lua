local ControlBinding = require("src.classes.ControlBinding")
local ControlTab = require("src.classes.ControlTab")
local controlsINI = ac.INIConfig.controlsConfig()

local contentManagerControlsINI = ac.INIConfig.load(ac.dirname() .. "\\cfg\\cm_controls.ini")
local carControlsFile = ac.getFolder(ac.FolderID.ContentCars)
        .. "\\"
        .. ac.getCarID(0)
        .. "\\extension\\ext_car_controls.ini"

if not io.fileExists(carControlsFile) then carControlsFile = ac.dirname() .. "\\cfg\\car_controls.ini" end
local carControlsINI = ac.INIConfig.load(carControlsFile)

local controls = {
        preset = controlsINI:get("__LAUNCHER_CM", "PRESET_NAME", nil),
        inputMethod = 1,
        inputMethods = {
                WHEEL = 1,
                X360 = 2,
                KEYBOARD = 3,
        },
        tabs = {},
}

-- local carSpecificPreset = controlsINI:get("__LAUNCHER_CM", "PRESET_NAME", "")
-- local carSpecificPresetEnabled = controlsINI:get("__LAUNCHER_CM", "PRESET_CHANGED", -1) == 0

-- if carSpecificPresetEnabled then
--         carSpecificPreset =
--                 string.replace(string.replace(carSpecificPreset, "savedSetups\\", ""), ".ini", "")
-- end

-- local cfgInputGeneral = MappedConfig(ac.getFolder(ac.FolderID.ExtCfgUser) .. "/general.ini", {
-- 	CONTROL = { NO_MOUSE_STEERING_FOR_INACTIVE = false },
-- })

ac.reloadControlSettings()
ac.onControlSettingsChanged(function() controlsINI = ac.INIConfig.controlsConfig() end)

local function initializeControlTab(name, ini)
        local controlTab = ControlTab(name)
        for _, key in ini:iterateValues("TAB_ORDER", "TAB", true) do
                controlTab:addGroup(ini.sections["TAB_ORDER"][key][1])
        end

        for bind, _ in pairs(ini.sections) do
                if bind ~= "TAB_ORDER" then controlTab:addControl(ControlBinding(bind, ini)) end
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

        controls.inputMethod = controlsINI:get("HEADER", "INPUT_METHOD", 1)

        table.insert(controls.tabs, 1, initializeControlTab("General", contentManagerControlsINI))
        table.insert(controls.tabs, 1, initializeControlTab("Car", carControlsINI))
end

return controls
