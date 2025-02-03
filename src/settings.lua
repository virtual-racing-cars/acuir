local settings = {}

local settingsDatabasePath = ac.getFolder(ac.FolderID.ScriptConfig)

if not io.isFilePathAcceptable(settingsDatabasePath) then
	io.createDir(settingsDatabasePath)
end

local dbStorage = require("shared.utils.dbstorage")
dbStorage.configure(string.format("%s\\settings.db", settingsDatabasePath))

---@type DbDictionaryStorage<{a: integer, b: string}>
local dbList = dbStorage.Dictionary("TABLE")

-- local dbList = {
-- 	---@type DbDictionaryStorage<{a: integer, b: string}>
-- 	stages = dbStorage.Dictionary("TABLE"),
-- 	---@type DbDictionaryStorage<{a: integer, b: string}>
-- 	sectors = dbStorage.Dictionary("TABLE"),
-- }

function settings:setValue(key, value)
	if value ~= settings:getValue(key) then
		local v = dbList:get(key)
		v.value = value
		dbList:set(key, v)
	end
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
		v.type = type(v.default) == "boolean" and 1 or 0
		v.value = v.default

		local uid = bit.tohex(ac.checksumXXH(stringify(v)))
		if not dbList:get(v.key) or dbList:get(v.key).uid ~= uid then
			v.uid = uid
			dbList:set(v.key, v)
		end
	end
end

setmetatable(settings, {
	__index = function(_, key)
		local value = settings:getValue(key)
		if value == nil then
			ac.log(string.format("Warning: Key '%s' not found in database.", key))
		end
		return value
	end,

	__newindex = function(_, key, value)
		if key and value ~= nil then
			settings:setValue(key, value)
		else
			ac.error("Invalid key or value provided to settings")
		end
	end,
})

return settings
