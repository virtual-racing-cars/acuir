local ignoreChangesUntil = 0

---@class MappedConfig
---@field filename string
---@field ini ac.INIConfig
---@field data table
---@field original table
---@field map table
local MappedConfig = class("MappedConfig")

function MappedConfig:initialize(filename, map)
        local ini = ac.INIConfig.load(filename, ac.INIFormat.Extended)
        local data = ini:mapConfig(map)

        self.filename = filename
        self.ini = ini
        self.map = map
        self.data = data
        self.original = stringify.parse(stringify(data))

        ac.onFileChanged(filename, function()
                if ui.time() < ignoreChangesUntil then return end
                self:reload()
        end)
end

function MappedConfig:reload()
        self.ini = ac.INIConfig.load(self.filename, ac.INIFormat.Extended) or self.ini
        self.data = self.ini:mapConfig(self.map)
end

---@param section string
---@param key string
---@param value number|boolean
---@param triggerControlReload boolean?
function MappedConfig:set(section, key, value, triggerControlReload, hexFormat)
        if not self.data[section] then self.data[section] = {} end
        if type(value) == "number" and not (value > -1e9 and value < 1e9) then
                error("Sanity check failed: " .. tostring(value))
        end
        if self.data[section][key] == value then return end
        self.data[section][key] = value
        setTimeout(function()
                -- ac.log("Saving updated value: " .. tostring(value), self.filename)
                if self.onConfigChange then self:onConfigChange() end
                self.ini:setAndSave(
                        section,
                        key,
                        hexFormat and string.format("0x%x", self.data[section][key]) or self.data[section][key]
                )
                if triggerControlReload ~= false then
                        setTimeout(function()
                                -- ac.log("Reloading control settings now")
                                ac.reloadControlSettings()
                        end, 0.02, "reload")
                end
                ignoreChangesUntil = ui.time() + 4
        end, 0.02, section .. key)
end

function MappedConfig:get(section, key, defaultValue)
        if not self.data[section] then
                self.data[section] = {}
                self.data[section][key] = self.ini:get(section, key, defaultValue or -1)
        end

        local value = self.data[section][key]

        return type(value) == "boolean" and (value and 1 or 0) or value
end

return MappedConfig
