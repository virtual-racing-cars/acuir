local csp = {}

local cspVersion = ac.getPatchVersion()
local cspVersionCode = ac.getPatchVersionCode()
local cspSim = ac.getSim()
local cspUI = ac.getUI()

function csp.version() return cspVersion end

function csp.versionCode() return cspVersionCode end

function csp.sim() return cspSim end

function csp.ui() return cspUI end

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
