local uis = ac.getUI()

local units = {}

function units:speed(speedKmh)
        local speed = math.max(speedKmh, 0)
        return uis.useImperialUnits and speed * 0.621371 or speed
end

function units:mass(massKg) return uis.useImperialUnits and massKg * 2.20462 or massKg end

function units:temperature(temperatureC) return uis.useImperialUnits and temperatureC * (9 / 5) + 32 or temperatureC end

return units
