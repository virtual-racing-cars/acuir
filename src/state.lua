local state = {}

local db = require("database")

state.list = {
	UI = {
		{ key = "appOpen", label = "Show UI", default = true },
		{ key = "hasAppOpened", label = "Show UI", default = true },
		{ key = "setupTab", label = "Show UI", default = 1 },
	},
}

for k, v in pairs(state.list) do
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

return state
