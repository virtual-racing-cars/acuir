local sim = ac.getSim()

local ControlBinding = require("classes.ControlBinding")
local ControlTab = require("classes.ControlTab")
local MappedConfig = require("classes.MappedConfig")

local configs = require("configs")

local controls = {
        tabs = {},
}

local function initializeControlTab(name, ini)
        if table.same(ini.sections, {}) then
                ac.log("Invalid control config: %s" % name)
                return nil
        end

        local controlTab = ControlTab(name)

        for _, key in ini:iterateValues("TAB_ORDER", "TAB", true) do
                controlTab:addGroup(ini.sections["TAB_ORDER"][key][1])
        end

        for bind, _ in pairs(ini.sections) do
                if bind ~= "TAB_ORDER" then controlTab:addControl(ControlBinding(bind, ini, controls)) end
        end

        -- for _, group in ipairs(controlTab.groups) do
        --         for _, tab in ipairs(group.content) do
        --                 tab.buttons = table.flatten(tab.buttons, 1)
        --         end
        -- end

        table.insert(controls.tabs, controlTab)
end

ac.onControlSettingsChanged(function()
        local carSpecificPreset = configs.CONTROLS.ini:get("__LAUNCHER_CM", "PRESET_NAME", "")
        local carSpecificPresetEnabled = configs.CONTROLS.ini:get("__LAUNCHER_CM", "PRESET_CHANGED", 1) == 0

        if carSpecificPresetEnabled and carSpecificPreset ~= "" then
                setTimeout(function()
                        local carSpecficPresetFilename = ac.getFolder(ac.FolderID.Cfg)
                                .. "\\controllers\\"
                                .. carSpecificPreset

                        local carSpecficPresetFile = io.open(carSpecficPresetFilename, "w+")
                        carSpecficPresetFile:write(configs.CONTROLS.ini:serialize())
                        carSpecficPresetFile:close()
                end, 0.5, "updateCarSpecificPreset")
        end
end)

function controls:initialize()
        initializeControlTab(ac.getCarName(0), configs.CAR)
        initializeControlTab("Driving Controls", configs.CAR_DRIVING)
        initializeControlTab("Cockpit Controls", configs.CAR_DEFAULT)
        initializeControlTab("General", configs.CM)

        io.scanDir(ac.getFolder(ac.FolderID.ACAppsLua), function(fileName, fileAttributes, callbackData)
                local appDirectory = ac.getFolder(ac.FolderID.ACAppsLua) .. "\\" .. fileName
                local appControlsFile = appDirectory .. "\\ext_app_controls.ini"
                local appManifestFile = appDirectory .. "\\manifest.ini"

                if not io.fileExists(appControlsFile) or not io.fileExists(appControlsFile) then return end

                local appManifest = ac.INIConfig.load(appManifestFile, ac.INIFormat.Extended)
                local appCfg = MappedConfig(appControlsFile, { TAB_ORDER = { TAB_1 = "Generic" } })
                local appName = appManifest:get("ABOUT", "NAME", "")

                initializeControlTab(appName, ac.INIConfig.load(appControlsFile))
        end)
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
