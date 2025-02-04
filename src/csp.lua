local CSP = {}

local cspVersion = ac.getPatchVersion()
local cspVersionCode = ac.getPatchVersionCode()

function CSP.version()
	return cspVersion
end

function CSP.versionCode()
	return cspVersionCode
end

local proxy = {}
setmetatable(proxy, {
	__index = function(_, key)
		local value = rawget(CSP, key)
		if type(value) == "function" then
			return value() -- Automatically call function
		else
			return value -- Return value normally
		end
	end,
})

return proxy
