local car = ac.getCar(0)

local dataCount = 1500

local telemetry = {
        dataCount = dataCount,
        bestLap = {
                lapCount = nil,
                channels = {
                        {
                                key = "gas",
                                label = "Gas",
                                data = table.new(dataCount, 0),
                                min = math.huge,
                                max = -math.huge,
                                units = "%",
                        },
                        {
                                key = "speedKmh",
                                label = "Speed",
                                data = table.new(dataCount, 0),
                                min = math.huge,
                                max = -math.huge,
                                units = "km/h",
                        },
                        {
                                key = "brake",
                                label = "Brake",
                                data = table.new(dataCount, 0),
                                min = math.huge,
                                max = -math.huge,
                                units = "%",
                        },
                        {
                                key = "gear",
                                label = "Gear",
                                data = table.new(dataCount, 0),
                                min = math.huge,
                                max = -math.huge,
                                units = "",
                        },
                },
                lapTimeMs = math.huge,
        },
        lastLap = {
                lapCount = nil,
                channels = {
                        {
                                key = "gas",
                                label = "Gas",
                                data = table.new(dataCount, 0),
                                min = math.huge,
                                max = -math.huge,
                                units = "%",
                        },
                        {
                                key = "speedKmh",
                                label = "Speed",
                                data = table.new(dataCount, 0),
                                min = math.huge,
                                max = -math.huge,
                                units = "km/h",
                        },
                        {
                                key = "brake",
                                label = "Brake",
                                data = table.new(dataCount, 0),
                                min = math.huge,
                                max = -math.huge,
                                units = "%",
                        },
                        {
                                key = "gear",
                                label = "Gear",
                                data = table.new(dataCount, 0),
                                min = math.huge,
                                max = -math.huge,
                                units = "",
                        },
                },
                lapTimeMs = 0,
        },
        currentLap = {
                channels = {
                        {
                                key = "gas",
                                label = "Gas",
                                data = table.new(dataCount, 0),
                                min = math.huge,
                                max = -math.huge,
                                units = "%",
                        },
                        {
                                key = "speedKmh",
                                label = "Speed",
                                data = table.new(dataCount, 0),
                                min = math.huge,
                                max = -math.huge,
                                units = "km/h",
                        },
                        {
                                key = "brake",
                                label = "Brake",
                                data = table.new(dataCount, 0),
                                min = math.huge,
                                max = -math.huge,
                                units = "%",
                        },
                        {
                                key = "gear",
                                label = "Gear",
                                data = table.new(dataCount, 0),
                                min = math.huge,
                                max = -math.huge,
                                units = "",
                        },
                },
                lapTimeMs = math.huge,
        },
}

local function resetCurrentLapTelemetry()
        telemetry.currentLap.lapTimeMs = math.huge
        for i = 0, telemetry.dataCount - 1 do
                for _, channel in ipairs(telemetry.currentLap.channels) do
                        channel.data[i] = nil
                end
        end
end

setInterval(function()
        local telemIndex = math.round(car.splinePosition * telemetry.dataCount)
        for _, channel in ipairs(telemetry.currentLap.channels) do
                channel.data[telemIndex] = car[channel.key]
        end
end, 1 / 100, "telemetryCollector100Hz")

ac.onLapCompleted(0, function(carIndex, lapTime, valid, cuts, lapCount)
        ac.debug(tostring(lapCount), ac.lapTimeToString(lapTime))

        telemetry.currentLap.lapTimeMs = lapTime

        telemetry.lastLap = table.clone(telemetry.currentLap, "full")
        telemetry.lastLap.lapCount = lapCount

        for i = 0, telemetry.dataCount - 1 do
                for _, channel in ipairs(telemetry.lastLap.channels) do
                        local dataPoint = channel.data[i]

                        if dataPoint then
                                if dataPoint < channel.min then
                                        channel.min = dataPoint
                                elseif dataPoint > channel.max then
                                        channel.max = dataPoint
                                end
                        end
                end
        end

        if telemetry.lastLap.lapTimeMs <= telemetry.bestLap.lapTimeMs then
                telemetry.bestLap = table.clone(telemetry.lastLap, "full")
        end

        resetCurrentLapTelemetry()
end)

ac.onCarJumped(0, function(carIndex) resetCurrentLapTelemetry() end)

return telemetry
