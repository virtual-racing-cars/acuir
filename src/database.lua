local db = {}

local dbPath = ac.getFolder(ac.FolderID.ScriptConfig)

if not io.isFilePathAcceptable(dbPath) then
	io.createDir(dbPath)
end

local dbStorage = require("shared.utils.dbstorage")
dbStorage.configure(string.format("%s\\storage.db", dbPath))

---@type DbDictionaryStorage<{a: integer, b: string}>
local dbList = dbStorage.Dictionary("TABLE")

function db:setValue(key, value)
	local v = dbList:get(key)
	v.value = value
	dbList:set(key, v)
end

function db:getValue(key)
	return dbList:get(key).value
end

function db:resetValue(key)
	local v = dbList:get(key)
	v.value = v.default
	dbList:set(key, v)
end

function db:register(dictName, dbTable)
	for k, v in pairs(dbTable) do
		v.key = string.format("%s.%s", dictName, v.key)
		if not dbList:get(v.key) then
			v.value = v.default
			dbList:set(v.key, v)
		else
			v.value = dbList:get(v.key).value
		end
	end
end

setmetatable(db, {
	__index = function(_, key)
		if not dbList:get(key) then
			ac.error("Database does not contain key [%s]!" % key)
			return
		end

		return db:getValue(key)
	end,

	__newindex = function(_, key, value)
		db:setValue(key, value)
	end,
})

return db
