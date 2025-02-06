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

function SimUtils.windDirectionString()
	return windDirectionStrings[math.round((sim.windDirectionDeg + 180) / 24) + 1]
end

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

local trackGripStrings = {
	{ 86, "DUSTY" },
	{ 89, "OLD" },
	{ 95, "GREEN" },
	{ 98, "RUBBERED" },
	{ 100, "OPTIMUM" },
}

function SimUtils.trackGripString()
	return findClosestIndex(sim.roadGrip * 100, trackGripStrings)
end

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

function SimUtils.sessionTimeLeftString()
	return sim.sessionTimeLeft <= 0 and "--" or string.format("%.1f min", sim.sessionTimeLeft / 60000)
end

function SimUtils.sessionTotalTimeString()
	return string.format("%s min", (sim.sessionTimeLeft - sim.timeToSessionStart) / 60000)
end

function SimUtils.sessionSkippable()
	return sim.sessionsCount > 1 and sim.currentSessionIndex + 1 < sim.sessionsCount
end

function SimUtils.sessionRestartable()
	return car.sessionID == -1
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
