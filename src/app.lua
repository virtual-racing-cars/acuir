local csp = require("csp")

local app = {}

local appManifestINI = ac.INIConfig.load("manifest.ini", ac.INIFormat.Extended)
local appVersionString = appManifestINI:get("ABOUT", "VERSION", "0.0.0")
local appfullName = appManifestINI:get("ABOUT", "FULL_NAME", "Application")
local appName = appManifestINI:get("ABOUT", "NAME", "App")
local appDescription = appManifestINI:get("ABOUT", "DESCRIPTION", "")
local appDebugMode = appManifestINI:get("DEV", "DEBUG_MODE", 0) == 1

local appFullInfo = string.format("%s: %s | CSP: %s (%s)", appName, appVersionString, csp.version, csp.versionCode)

function app.version() return appVersionString end

function app.fullName() return appfullName end

function app.fullInfo() return appFullInfo end

function app.name() return appName end

function app.description() return appDescription end

function app.rootDir() return ac.getFolder(ac.FolderID.ScriptOrigin) end

function app.configDir() return ac.getFolder(ac.FolderID.ScriptConfig) end

app.state = {
        appOpen = false,
        setupTab = 2,
        debug = appDebugMode,
        blockEscapeButton = false,
        screenTransition = 0,
}

local proxy = {}
setmetatable(proxy, {
        __index = function(_, key)
                local value = rawget(app, key)
                if type(value) == "function" then
                        return value()
                else
                        return value
                end
        end,
})

return proxy
