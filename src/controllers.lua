local controlsINI = ac.INIConfig.controlsConfig()

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
while controlsINI:get("CONTROLLERS", "CON%s" % conIndex, nil) do
        table.insert(controllers, conIndex, {
                CON = controlsINI:get("CONTROLLERS", "CON%s" % conIndex, ""),
                PGUID = controlsINI:get("CONTROLLERS", "PGUID%s" % conIndex, ""),
                __IGUID = controlsINI:get("CONTROLLERS", "__IGUID%s" % conIndex, ""),
        })

        conIndex = conIndex + 1
end

for k, v in ipairs(controllers.boundDevices) do
        for i in ipairs(inputDeviceKeys) do
                local conIndex = controlsINI:get(string.upper(v[1]), inputDeviceKeys[i], -1)
                if conIndex ~= -1 then
                        local device = controlsINI:get("CONTROLLERS", "CON%s" % conIndex, "")

                        controllers.boundDevices[k][2] = device
                end
        end
end

return controllers
