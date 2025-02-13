local CSP = {}

local cspVersion = ac.getPatchVersion()
local cspVersionCode = ac.getPatchVersionCode()
local cspSim = ac.getSim()
local cspUI = ac.getUI()

function CSP.version() return cspVersion end

function CSP.versionCode() return cspVersionCode end

function CSP.sim() return cspSim end

function CSP.ui() return cspUI end

local proxy = {}
setmetatable(proxy, {
        __index = function(_, key)
                local value = rawget(CSP, key)
                if type(value) == "function" then
                        return value()
                else
                        return value
                end
        end,
})

return proxy
