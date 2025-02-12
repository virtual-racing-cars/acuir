local SimUtils = {}

local sim = ac.getSim()
local car = ac.getCar(0)

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

function SimUtils.windDirectionString()
	return windDirectionStrings[math.round((sim.windDirectionDeg + 180) / 24) + 1]
end

function SimUtils.trackGripString()
	return findClosestIndex(sim.roadGrip * 100, trackGripStrings)
end

function SimUtils.raceSessionTypeString()
	return raceSessiontTypeString[sim.raceSessionType + 1]
end

function SimUtils.ambientTemperatureC()
	return sim.ambientTemperature
end

function SimUtils.ambientTemperatureK()
	return sim.ambientTemperature + 273.15
end

function SimUtils.ambientTemperatureF()
	return sim.ambientTemperature * (9 / 5) + 32
end

function SimUtils.simTimeString()
	return string.format("%02d:%02d:%02d", sim.timeHours, sim.timeMinutes, sim.timeSeconds)
end

function SimUtils.simDateString()
	return os.date("%B %d, %Y", sim.timestamp)
end

function SimUtils.session()
	return ac.getSession(sim.currentSessionIndex)
end

function SimUtils.timeToString(timeMs, remaining)
	local totalSeconds = math.floor(timeMs / 1000)
	local minutes = math.floor(totalSeconds / 60)
	local seconds = totalSeconds % 60
	return string.format("%02d:%02d %s", minutes, seconds, remaining and "Remaining" or "")
end

function SimUtils.sessionTimeLeftString()
	if SimUtils.session().durationMinutes == 0 then
		if sim.raceSessionType == ac.SessionType.Race then
			return string.format("%.0f laps left", SimUtils.session().laps - SimUtils.session().leaderCompletedLaps)
		else
			return SimUtils.timeToString(sim.currentSessionTime)
		end
	end

	return sim.sessionTimeLeft <= 0 and "--" or SimUtils.timeToString(sim.sessionTimeLeft, true)
end

function SimUtils.sessionTotalTimeString()
	if SimUtils.session().durationMinutes == 0 then
		if sim.raceSessionType == ac.SessionType.Race then
			return string.format("%.0f laps", SimUtils.session().laps)
		else
			return string.format("%.0f laps", car.lapCount)
		end
	end

	return string.format("%.0f min", SimUtils.session().durationMinutes)
end

function SimUtils.sessionSkippable()
	return sim.sessionsCount > 1 and sim.currentSessionIndex < sim.sessionsCount - 1
end

function SimUtils.sessionRestartable()
	return car.sessionID == -1
end

function SimUtils.controlsLocked()
	return car.currentPenaltyType == ac.PenaltyType.TeleportToPits
end

function SimUtils.controlsLockedTimeRemaining()
	return SimUtils.controlsLocked() and car.currentPenaltyParameter or 0
end

local proxy = {}
setmetatable(proxy, {
	__index = function(_, key)
		local value = rawget(SimUtils, key)
		if type(value) == "function" then
			return value()
		else
			return value
		end
	end,
})

return proxy
