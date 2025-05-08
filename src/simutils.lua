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

function simutils.timeToString(timeMs, remaining)
        local totalSeconds = math.floor(timeMs / 1000)
        local minutes = math.floor(totalSeconds / 60)
        local seconds = totalSeconds % 60
        return string.format("%02d:%02d %s", minutes, seconds, remaining and "Remaining" or "")
end

function simutils.sessionTimeLeftString()
        if simutils.session().durationMinutes == 0 then
                if sim.raceSessionType == ac.SessionType.Race then
                        return string.format(
                                "%.0f laps left",
                                simutils.session().laps - simutils.session().leaderCompletedLaps
                        )
                else
                        return simutils.timeToString(sim.currentSessionTime)
                end
        end

        return sim.sessionTimeLeft <= 0 and "--" or simutils.timeToString(sim.sessionTimeLeft, true)
end

function simutils.sessionTotalTimeString()
        if simutils.session().durationMinutes == 0 then
                if sim.raceSessionType == ac.SessionType.Race then
                        return string.format("%.0f laps", simutils.session().laps)
                else
                        return string.format("%.0f laps", car.lapCount)
                end
        end

        return string.format("%.0f min", simutils.session().durationMinutes)
end

function simutils.sessionSkippable() return sim.sessionsCount > 1 and sim.currentSessionIndex < sim.sessionsCount - 1 end

function simutils.sessionRestartable() return car.sessionID == -1 end

function simutils.controlsLocked() return car.currentPenaltyType == ac.PenaltyType.TeleportToPits end

function simutils.controlsLockedTimeRemaining() return simutils.controlsLocked() and car.currentPenaltyParameter or 0 end

function simutils.rideHeightValid() return car.rideHeight[0] >= car.minHeight and car.rideHeight[1] >= car.minHeight end

function simutils.sessionWaitTime()
        if sim.sessionTimeLeft > 0 or sim.sessionsCount == 1 then return 0 end

        if sim.raceSessionType == ac.SessionType.Practice or sim.raceSessionType == ac.SessionType.Qualify then
                return (90000 + sim.sessionTimeLeft) / 1000
        elseif sim.raceSessionType == ac.SessionType.Race then
                return simutils.session().overtimeMs / 1000
        end

        return 0
end

function simutils.sessionOvertime() return simutils.sessionWaitTime() > 0 end

function simutils.readyToDriveState()
        if simutils.controlsLocked() then
                return { false, "Controls Locked", simutils.controlsLockedTimeRemaining() }
        end

        -- if not simutils.rideHeightValid() then

        -- end

        if simutils.sessionOvertime() then return { false, "Wait-Time", simutils.sessionWaitTime() } end

        local carSetupState = ac.getCarSetupState()
        if carSetupState[1] == "validating" then return { false, "Validating Setup", "" } end
        if carSetupState[1] == "illegal" then return { false, "Illegal Setup", carSetupState[2] } end

        return { true, "Drive", "" }
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
