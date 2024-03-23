local xml = require("xml")

MotecLogExtra = {}

function MotecLogExtra:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.laps = {}
	return o
end

function MotecLogExtra:valid_laps()
	return #self.laps >= 2
end

function MotecLogExtra:add_lap(laptime, lapnum)
	if lapnum then
		self.laps[lapnum] = laptime
	else
		table.insert(self.laps, laptime)
	end
end

function MotecLogExtra:get_fastest_lap()
	if #self.laps < 1 then
		return nil, nil
	end

	local laps = self.laps
	if #laps > 1 then
		-- Ignore the outlap
		local sorted_laps = {}
		for i, lap in ipairs(laps) do
			if i > 1 then
				table.insert(sorted_laps, { index = i, time = lap })
			end
		end
		table.sort(sorted_laps, function(a, b)
			return a.time < b.time
		end)
		local fastestlap = sorted_laps[1].index + 1
		local fastesttime = sorted_laps[1].time
		return fastestlap, fastesttime
	else
		-- Just return the one lap we have
		return 1, laps[1]
	end
end

function MotecLogExtra:get_beacons()
	local beacons = {}
	local elapsedtime = 0

	for idx, laptime in ipairs(self.laps) do
		elapsedtime = elapsedtime + laptime * 1000000 -- microseconds
		table.insert(beacons, { idx + 1, elapsedtime })
	end

	return beacons
end

function MotecLogExtra:to_string()
	local ldx = xml.new("LDXFile")
	ldx:set_attribute("locale", "English_United Kingdom.1252")
	ldx:set_attribute("DefaultLocale", "C")
	ldx:set_attribute("Version", "1.6")

	local layers = ldx:add_child("Layers")
	local layer = layers:add_child("Layer")
	local markerblock = layer:add_child("MarkerBlock")
	local markergroup = markerblock:add_child("MarkerGroup")
	markergroup:set_attribute("Name", "Beacons")
	markergroup:set_attribute("Index", tostring(#self.laps - 1)) -- number of beacons 0 index

	for _, beacon in ipairs(self:get_beacons()) do
		local marker = markergroup:add_child("Marker")
		marker:set_attribute("Version", "100")
		marker:set_attribute("ClassName", "BCN")
		marker:set_attribute("Name", "Manual." .. beacon[1])
		marker:set_attribute("Flags", "77")
		marker:set_attribute("Time", string.format("%.2f", beacon[2]))
	end

	local details = layers:add_child("Details")

	local totallaps = details:add_child("String")
	totallaps:set_attribute("Id", "Total Laps")
	totallaps:set_attribute("Value", tostring(#self.laps + 1)) -- include the in-lap

	local fastestlap, fastesttime = self:get_fastest_lap()
	if fastesttime then
		local minutes = math.floor(fastesttime % 3600 // 60)
		local seconds = fastesttime % 3600 % 60
		fastesttime = string.format("%02d:%06.3f", minutes, seconds)

		local ft = details:add_child("String")
		ft:set_attribute("Id", "Fastest Time")
		ft:set_attribute("Value", fastesttime)

		local fl = details:add_child("String")
		fl:set_attribute("Id", "Fastest Lap")
		fl:set_attribute("Value", tostring(fastestlap))
	end

	return ldx:to_xml_string(true)
end

return MotecLogExtra
