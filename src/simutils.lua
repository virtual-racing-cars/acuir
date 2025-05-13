local simutils = {}

local sim = ac.getSim()
local car = ac.getCar(0)

local round = math.ceil

local windDirectionStrings = {
        "N",
        "NNE",
        "NE",
        "ENE",
        "E",
        "SE",
        "SSE",
        "S",
        "SSW",
        "SW",
        "WSW",
        "W",
        "WNW",
        "NW",
        "NNW",
}

local trackGripStrings = {
        { 86, "DUSTY" },
        { 89, "OLD" },
        { 95, "GREEN" },
        { 98, "RUBBERED" },
        { 100, "OPTIMUM" },
}

local raceSessiontTypeString = {
        "Undefined",
        "Practice",
        "Qualify",
        "Race",
        "Hotlap",
        "Time Attack",
        "Drift",
        "Drag",
}

local function findClosestIndex(input, numbers)
        local trackGripString = nil
        local smallestDifference = math.huge

        for i, num in ipairs(numbers) do
                local difference = math.abs(input - num[1])
                if difference < smallestDifference then
                        smallestDifference = difference
                        trackGripString = num[2]
                end
        end

        return trackGripString
end

function simutils.windDirectionString() return windDirectionStrings[math.round((sim.windDirectionDeg + 180) / 24) + 1] end

function simutils.trackGripString() return findClosestIndex(sim.roadGrip * 100, trackGripStrings) end

function simutils.raceSessionTypeString() return raceSessiontTypeString[sim.raceSessionType + 1] end

function simutils.ambientTemperatureC() return sim.ambientTemperature end

function simutils.ambientTemperatureK() return sim.ambientTemperature + 273.15 end

function simutils.ambientTemperatureF() return sim.ambientTemperature * (9 / 5) + 32 end

function simutils.simTimeString()
        return string.format("%02d:%02d:%02d", sim.timeHours, sim.timeMinutes, sim.timeSeconds)
end

function simutils.simDateString() return os.date("%B %d, %Y", sim.timestamp) end

function simutils.session() return ac.getSession(sim.currentSessionIndex) end

function simutils.timeToString(timeMs, postfix)
        local totalSeconds = math.floor(timeMs / 1000)
        local minutes = math.floor(totalSeconds / 60)
        local seconds = totalSeconds % 60
        return string.format("%s %02d:%02d", postfix, minutes, seconds)
end

function simutils.sessionTimeLeftString()
        if simutils.session().durationMinutes == 0 then
                if sim.raceSessionType == ac.SessionType.Race then
                        return string.format(
                                "%.0f laps left",
                                simutils.session().laps - simutils.session().leaderCompletedLaps
                        )
                else
                        return simutils.timeToString(sim.currentSessionTime, "Time -")
                end
        end

        if sim.sessionTimeLeft <= 0 then
                return "Session Over"
        elseif sim.timeToSessionStart > 0 then
                return simutils.timeToString(sim.timeToSessionStart, "Starts in -")
        else
                return simutils.timeToString(sim.sessionTimeLeft, "Remaining -")
        end
end

function simutils.sessionTotalTimeString()
        if simutils.session().durationMinutes == 0 then
                if sim.raceSessionType == ac.SessionType.Race then
                        return string.format("- %.0f laps", simutils.session().laps)
                else
                        return string.format("- %.0f laps", car.lapCount)
                end
        end

        return string.format("- %.0f min", simutils.session().durationMinutes)
end

function simutils.sessionSkippable() return sim.sessionsCount > 1 and sim.currentSessionIndex < sim.sessionsCount - 1 end

function simutils.sessionRestartable() return car.sessionID == -1 end

function simutils.controlsLocked() return car.currentPenaltyType == ac.PenaltyType.TeleportToPits end

function simutils.controlsLockedTimeRemaining() return simutils.controlsLocked() and car.currentPenaltyParameter or 0 end

function simutils.rideHeightValid() return car.rideHeight[0] >= car.minHeight and car.rideHeight[1] >= car.minHeight end

function simutils.sessionWaitTime()
        if sim.sessionTimeLeft > 0 or sim.sessionsCount == 1 then return 0 end

        return round(sim.resultScreenTime + sim.sessionTimeLeft / 1000)
end

function simutils.sessionOvertime() return simutils.sessionWaitTime() > 0 end

function simutils.readyToDriveState()
        if simutils.controlsLocked() then
                return { false, "Controls Locked", simutils.controlsLockedTimeRemaining(), rgbm.colors.gray }
        end

        if simutils.sessionOvertime() then
                return { false, "Wait-Time", simutils.sessionWaitTime(), rgbm.colors.gray }
        end

        local carSetupState, invalidReason = ac.getCarSetupState()
        if carSetupState == "validating" then return { false, "Validating Setup", "", rgbm.colors.orange } end
        if carSetupState == "illegal" then
                if not simutils.rideHeightValid() then invalidReason = "Ride height is too low" end

                return { false, "Invalid Setup", invalidReason, rgbm.colors.gray }
        end

        return { true, "Drive", "", rgbm.colors.green }
end

local proxy = {}
setmetatable(proxy, {
        __index = function(_, key)
                local value = rawget(simutils, key)
                if type(value) == "function" then
                        return value()
                else
                        return value
                end
        end,
})

return proxy
