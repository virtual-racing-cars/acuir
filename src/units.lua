local uis = ac.getUI()

local units = {}

function units:speed(speedKmh)
        local speed = math.max(speedKmh, 0)
        return uis.useImperialUnits and speed * 0.621371 or speed
end

function units:mass(massKg) return massKg * 2.20462 end

function units:temperature(temperatureC) return temperatureC * (9 / 5) + 32 end

return units
