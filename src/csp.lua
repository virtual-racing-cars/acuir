local csp = {}

local cspVersion = ac.getPatchVersion()
local cspVersionCode = ac.getPatchVersionCode()

function csp.version() return cspVersion end

function csp.versionCode() return cspVersionCode end

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
