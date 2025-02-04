local App = {}

local manifestINI = ac.INIConfig.load("manifest.ini", ac.INIFormat.Extended)
local appVersionString = manifestINI:get("ABOUT", "VERSION", "0.0.0")
local appfullName = manifestINI:get("ABOUT", "FULL_NAME", "Application")
local appName = manifestINI:get("ABOUT", "NAME", "App")
local appDescription = manifestINI:get("ABOUT", "DESCRIPTION", "")

function App.version()
	return appVersionString
end

function App.fullName()
	return appfullName
end

function App.name()
	return appName
end

function App.description()
	return appDescription
end

local proxy = {}
setmetatable(proxy, {
	__index = function(_, key)
		local value = rawget(App, key)
		if type(value) == "function" then
			return value() -- Automatically call function
		else
			return value -- Return value normally
		end
	end,
})

return proxy
