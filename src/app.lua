local App = {}

local appManifestINI = ac.INIConfig.load("manifest.ini", ac.INIFormat.Extended)
local appVersionString = appManifestINI:get("ABOUT", "VERSION", "0.0.0")
local appfullName = appManifestINI:get("ABOUT", "FULL_NAME", "Application")
local appName = appManifestINI:get("ABOUT", "NAME", "App")
local appDescription = appManifestINI:get("ABOUT", "DESCRIPTION", "")
local appDebugMode = appManifestINI:get("DEV", "DEBUG_MODE", 0) == 1

function App.version() return appVersionString end

function App.fullName() return appfullName end

function App.name() return appName end

function App.description() return appDescription end

function App.rootDir() return ac.getFolder(ac.FolderID.ScriptOrigin) end

function App.configDir() return ac.getFolder(ac.FolderID.ScriptConfig) end

App.state = {
        appOpen = false,
        hasAppOpened = false,
        setupTab = 1,
        debug = appDebugMode,
}

local proxy = {}
setmetatable(proxy, {
        __index = function(_, key)
                local value = rawget(App, key)
                if type(value) == "function" then
                        return value()
                else
                        return value
                end
        end,
})

return proxy
