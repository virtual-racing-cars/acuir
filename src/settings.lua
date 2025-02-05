local settings = {
	General = {
		{ key = "autoStart", label = "Auto-Start new UI", default = true, widget = 1 },
		{ key = "showVersions", label = "Show app and CSP versions", default = true, widget = 1 },
		{ key = "developerMode", label = "Developer Mode", default = false, widget = 1 },
		{ key = "audioTest", label = "Audio Test", min = 0, max = 100, format = "%.0f ", default = 0.5, widget = 2 },
		{ key = "audioTest1", label = "Audio 1 Test", min = 0, max = 100, format = "%.0f ", default = 0.5, widget = 2 },
		{ key = "audioTest2", label = "Audio 2 Test", min = 0, max = 100, format = "%.0f ", default = 0.5, widget = 2 },
	},
	Appearance = {
		{ key = "uiColor1", label = "Primary UI Color", default = "white" },
	},
}

local db = require("database")

for category, settingsTable in pairs(settings) do
	db:register(category, settingsTable)

	setmetatable(settings[category], {
		__index = function(_, key)
			return db:get(category, key)
		end,

		__newindex = function(_, key, value)
			db:set(category, key, value)
		end,
	})
end

return settings
