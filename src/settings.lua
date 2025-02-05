local settings = {
	General = {
		{ key = "autoStart", label = "Auto-Start new UI", default = true, widget = 1 },
		{ key = "showVersions", label = "Show App and CSP versions", default = true, widget = 1 },
		{ key = "developerMode", label = "Developer Mode", default = false, widget = 1 },
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
