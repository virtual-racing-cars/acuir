local configs = require("configs")

local inputDeviceKeys = {
        "JOY",
        "KEY",
        "XBOXBUTTON",
}

local controllers = {
        boundDevices = {
                { "Steering", "None" },
                { "Throttle", "None" },
                { "Brakes", "None" },
                { "Clutch", "None" },
                { "Handbrake", "None" },
        },
}

local conIndex = 0
while configs.CONTROLS.ini:get("CONTROLLERS", "CON%s" % conIndex, nil) do
        table.insert(controllers, conIndex, {
                CON = configs.CONTROLS.ini:get("CONTROLLERS", "CON%s" % conIndex, ""),
                PGUID = configs.CONTROLS.ini:get("CONTROLLERS", "PGUID%s" % conIndex, ""),
                __IGUID = configs.CONTROLS.ini:get("CONTROLLERS", "__IGUID%s" % conIndex, ""),
        })

        conIndex = conIndex + 1
end

for k, v in ipairs(controllers.boundDevices) do
        for i in ipairs(inputDeviceKeys) do
                local conIndex = configs.CONTROLS.ini:get(string.upper(v[1]), inputDeviceKeys[i], -1)
                if conIndex ~= -1 then
                        local device = configs.CONTROLS.ini:get("CONTROLLERS", "CON%s" % conIndex, "")

                        controllers.boundDevices[k][2] = device
                end
        end
end

return controllers
