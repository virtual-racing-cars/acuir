local settings = {}

local db = require("database")

settings.General = {
	{ key = "autoStart", label = "Auto-Start new UI", default = true, widget = 1 },
	{ key = "showVersions", label = "Show app and CSP versions", default = true, widget = 1 },
	{ key = "developerMode", label = "Developer Mode", default = false, widget = 1 },
	{ key = "audioTest", label = "Audio Test", min = 0, max = 100, format = "%.0f ", default = 0.5, widget = 2 },
	{ key = "audioTest1", label = "Audio 1 Test", min = 0, max = 100, format = "%.0f ", default = 0.5, widget = 2 },
	{ key = "audioTest2", label = "Audio 2 Test", min = 0, max = 100, format = "%.0f ", default = 0.5, widget = 2 },
}

settings.Appearance = {
	{ key = "uiColor1", label = "Primary UI Color", default = true },
}

settings.list = {
	settings.General,
	settings.Appearance,
}

for k, v in pairs(settings.list) do
	db:register(k, v)

	setmetatable(v, {
		__index = function(_, key)
			return db[key]
		end,

		__newindex = function(_, key, value)
			db[key] = value
		end,
	})
end

return settings
