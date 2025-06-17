local sim = ac.getSim()

local ControlBinding = require("src.classes.ControlBinding")
local ControlTab = require("src.classes.ControlTab")
local MappedConfig = require("src.classes.MappedConfig")

local configs = require("configs")

local controls = {
        tabs = {},
}

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

ac.onControlSettingsChanged(function()
        local carSpecificPreset = configs.CONTROLS.ini:get("__LAUNCHER_CM", "PRESET_NAME", "")
        local carSpecificPresetEnabled = configs.CONTROLS.ini:get("__LAUNCHER_CM", "PRESET_CHANGED", -1) == 0

        if carSpecificPresetEnabled then
                setTimeout(function()
                        local carSpecficPresetFile =
                                io.open(ac.getFolder(ac.FolderID.Cfg) .. "\\controllers\\" .. carSpecificPreset, "w+")
                        carSpecficPresetFile:write(configs.CONTROLS.ini:serialize())
                        carSpecficPresetFile:close()
                end, 0.5, "updateCarSpecificPreset")
        end
end)

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

function controls:iterate()
        return coroutine.wrap(function()
                for _, controlTab in ipairs(self.tabs) do
                        for _, controlTabGroup in ipairs(controlTab.groups) do
                                for _, bind in ipairs(controlTabGroup.content) do
                                        for _, button in ipairs(bind.buttons) do
                                                coroutine.yield(button)
                                        end
                                end
                        end
                end
        end)
end

return controls
