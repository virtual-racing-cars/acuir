local state = {}

local storedBools = {}

function state.loadStoredBool(id, defaultTrue)
        if storedBools[id] == nil then storedBools[id] = defaultTrue and true or false end

        return storedBools[id]
end

function state.storeBool(id, value) storedBools[id] = value end

return state
