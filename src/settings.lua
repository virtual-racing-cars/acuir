local settings = {}

local settingsDatabasePath = ac.getFolder(ac.FolderID.ScriptConfig)

if not io.isFilePathAcceptable(settingsDatabasePath) then
	io.createDir(settingsDatabasePath)
end

local dbStorage = require("shared.utils.dbstorage")
dbStorage.configure(string.format("%s\\settings.db", settingsDatabasePath))

---@type DbDictionaryStorage<{a: integer, b: string}>
local dbList = dbStorage.Dictionary("TABLE")

function settings:setValue(key, value)
	local v = dbList:get(key)
	v.value = value
	dbList:set(key, v)
end

function settings:getValue(key)
	return dbList:get(key).value
end

function settings:resetValue(key)
	local v = dbList:get(key)
	v.value = v.default
	dbList:set(key, v)
end

function settings:register(settingsTable)
	for k, v in pairs(settingsTable) do
		if not dbList:get(v.key) then
			v.value = v.default
			dbList:set(v.key, v)
		end
	end
end

setmetatable(settings, {
	__index = function(_, key)
		return settings:getValue(key)
	end,

	__newindex = function(_, key, value)
		settings:setValue(key, value)
	end,
})

return settings
