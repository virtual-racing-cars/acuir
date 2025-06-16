local csp = {}

local cspVersion = ac.getPatchVersion()
local cspVersionCode = ac.getPatchVersionCode()
local cspFullVersion = string.format("CSP: %s (%s)", cspVersion, cspVersionCode)

local cspMinVersion = "0.2.11"
local cspMinVersionCode = 3465
local cspFullMinVersion = string.format("CSP: %s (%s)", cspMinVersion, cspMinVersionCode)

function csp.version() return cspVersion end
function csp.versionCode() return cspVersionCode end
function csp.versionString() return cspFullVersion end

function csp.minVersion() return cspMinVersion end
function csp.minVersionCode() return cspMinVersionCode end
function csp.minVersionString() return cspFullMinVersion end

local proxy = {}
setmetatable(proxy, {
        __index = function(_, key)
                local value = rawget(csp, key)
                if type(value) == "function" then
                        return value()
                else
                        return value
                end
        end,
})

return proxy
