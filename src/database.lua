local db = {}

local dbPath = ac.getFolder(ac.FolderID.ScriptConfig)

if not io.isFilePathAcceptable(dbPath) then
	io.createDir(dbPath)
end

local dbStorage = require("shared.utils.dbstorage")
dbStorage.configure(string.format("%s\\storage.db", dbPath))

---@type DbDictionaryStorage<{a: integer, b: string}>
local dbList = {}

function db:register(dbKey, dbTable)
	if not dbList[dbKey] then
		dbList[dbKey] = dbStorage.Dictionary(dbKey)
	end

	for k, v in pairs(dbTable) do
		if not dbList[dbKey]:get(v.key) then
			dbList[dbKey]:set(v.key, { value = v.default })
		end
	end
end

function db:get(dbKey, key)
	return dbList[dbKey]:get(key).value
end

function db:set(dbKey, key, value)
	dbList[dbKey]:set(key, { value = value })
end

return db
