local Utils = {}

local sim = ac.getSim()

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

function Utils.windDirectionString()
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

function Utils.trackGripString()
	return findClosestIndex(sim.roadGrip * 100, trackGripStrings)
end

local raceSessiontTypeString = {
	"Undefined",
	"Practice",
	"Qualify",
	"Race",
	"Hotlap",
	"TimeAttack",
	"Drift",
	"Drag",
}

function Utils.raceSessionTypeString()
	return raceSessiontTypeString[sim.raceSessionType + 1]
end

function Utils.ambientTemperatureC()
	return sim.ambientTemperature
end

function Utils.ambientTemperatureK()
	return sim.ambientTemperature + 273.15
end

function Utils.ambientTemperatureF()
	return sim.ambientTemperature * (9 / 5) + 32
end

function Utils.simTimeString()
	return string.format("%02d:%02d", sim.timeHours, sim.timeMinutes)
end

local proxy = {}
setmetatable(proxy, {
	__index = function(_, key)
		local value = rawget(Utils, key)
		if type(value) == "function" then
			return value()
		else
			return value
		end
	end,
})

return proxy
