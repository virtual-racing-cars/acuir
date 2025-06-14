local sim = ac.getSim()

local ControlBinding = require("src.classes.ControlBinding")
local ControlTab = require("src.classes.ControlTab")
local MappedConfig = require("src.classes.MappedConfig")

local configs = require("configs")

local controls = {
        tabs = {},
        binds = {},
}

-- setTimeout(function()
--         configs.CONTROLS.ini:setAndSave("TEST", "TESTER", { { 1, 2, 3 } })
--         ac.log("hi")
-- end, 2)

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

                local appCfg = MappedConfig(appControlsFile, { TAB_ORDER = { TAB_1 = "Generic" } })
                local appName = appCfg.ini:get("ABOUT", "NAME", fileName)

                table.insert(controls.tabs, initializeControlTab(appName, ac.INIConfig.load(appControlsFile)))
        end)

        controls.input = sim.inputMode > 1 and 1 or 0

        table.insert(controls.tabs, 1, initializeControlTab("General", configs.CM))
        table.insert(controls.tabs, 1, initializeControlTab("Car", configs.CAR_DEFAULT))
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
