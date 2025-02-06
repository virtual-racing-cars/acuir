local SimUtils = {}

local sim = ac.getSim()
local car = ac.getCar(0)

local raceConfigINI = ac.INIConfig.raceConfig()

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

local sessionLimits = {}
local sessionTimed = {}

local function getSessionInfo()
	raceConfigINI = ac.INIConfig.raceConfig()

	for i = 0, sim.sessionsCount - 1 do
		local duration = raceConfigINI:get("SESSION_%s" % i, "DURATION_MINUTES", 0)
		local laps = raceConfigINI:get("SESSION_%s" % i, "LAPS", 0)
		local timed = duration > 0

		sessionTimed[i] = timed
		sessionLimits[i] = timed and duration or laps
	end
end

ac.onSessionStart(function(sessionIndex, restarted)
	getSessionInfo()
end)
getSessionInfo()

function SimUtils.simTimeString()
	return string.format("%02d:%02d:%02d", sim.timeHours, sim.timeMinutes, sim.timeSeconds)
end

function SimUtils.simDateString()
	return os.date("%B %d, %Y", sim.timestamp)
end

function SimUtils.sessionTimeLeftString()
	if not sessionTimed[sim.currentSessionIndex] then
		return string.format("%.0f laps left", sessionLimits[sim.currentSessionIndex] - sim.leaderLapCount)
	end

	local totalSeconds = math.floor(sim.sessionTimeLeft / 1000)
	local minutes = math.floor(totalSeconds / 60)
	local seconds = totalSeconds % 60
	local timeLeftString = string.format("%02d:%02d Remaining", minutes, seconds)

	return sim.sessionTimeLeft <= 0 and "--" or timeLeftString
end

function SimUtils.sessionTotalTimeString()
	return string.format(
		"%s %s",
		sessionLimits[sim.currentSessionIndex],
		sessionTimed[sim.currentSessionIndex] and "min" or "laps"
	)
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
